///|
/// HDR+ 合并模式
pub(all) enum HdrPlusMode {
  Weighted
  Mertens
  DeGhost
} derive(Eq, @debug.Debug)

///|
pub extend HdrPlusMode with @debug.Debug::{to_repr}

///|
pub extend HdrPlusMode with Eq::{not_equal, equal}

///|
/// HDR+ 参数
pub(all) struct HdrPlusParams {
  mode : HdrPlusMode
  align_threshold : Double
  ghost_threshold : Double
  num_pyramid_levels : Int
} derive(Eq, @debug.Debug)

///|
pub extend HdrPlusParams with @debug.Debug::{to_repr}

///|
pub extend HdrPlusParams with Eq::{not_equal, equal}

///|
/// 构建 HDR+ 参数
pub fn hdr_plus_build_params(
  mode : HdrPlusMode,
  align_threshold? : Double = 2.0,
  ghost_threshold? : Double = 0.3,
  num_pyramid_levels? : Int = 5,
) -> HdrPlusParams {
  HdrPlusParams::{ mode, align_threshold, ghost_threshold, num_pyramid_levels, }
}

///|
/// 鬼影检测结果
pub(all) struct GhostMap {
  width : Int
  height : Int
  mask : Array[Bool]
} derive(Eq, @debug.Debug)

///|
pub extend GhostMap with @debug.Debug::{to_repr}

///|
pub extend GhostMap with Eq::{not_equal, equal}

///|
/// 检测鬼影区域：比较参考帧与其他帧的差异，标记运动区域
pub fn hdr_plus_detect_ghost(
  reference : @types.Image,
  other : @types.Image,
  threshold : Double,
) -> GhostMap {
  let w = reference.width
  let h = reference.height
  let c = reference.channels
  let mask : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut diff = 0.0
      for ch in 0..<c {
        let r = reference.data[(y * w + x) * c + ch].to_int()
        let o = other.data[(y * w + x) * c + ch].to_int()
        diff = diff + (r - o).to_double() * (r - o).to_double()
      }
      diff = diff / c.to_double().sqrt()
      mask.push(diff > threshold * 255.0)
    }
  }
  GhostMap::{ width: w, height: h, mask, }
}

///|
/// 应用鬼影掩码：在标记区域使用参考帧，未标记区域使用其他帧
pub fn hdr_plus_apply_ghost_map(
  reference : @types.Image,
  other : @types.Image,
  ghost : GhostMap,
) -> @types.Image {
  let w = reference.width
  let h = reference.height
  let c = reference.channels
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let use_ref = ghost.mask[y * w + x]
      for ch in 0..<c {
        let v = if use_ref {
          reference.data[(y * w + x) * c + ch]
        } else {
          other.data[(y * w + x) * c + ch]
        }
        out.push(v)
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: c,
    data: Bytes::from_array(out),
  }
}

///|
/// Mertens 曝光融合：无需 HDR 中间步骤，直接加权融合多曝光图像
///
/// 权重基于对比度、饱和度、亮度三因素
pub fn hdr_plus_mertens_fusion(images : Array[@types.Image]) -> @types.Image {
  if images.length() == 0 {
    return @types.Image::{
      width: 1,
      height: 1,
      channels: 1,
      data: Bytes::from_array([0]),
    }
  }
  if images.length() == 1 {
    return images[0]
  }
  let w = images[0].width
  let h = images[0].height
  let c = images[0].channels
  let n = images.length()
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut sum_r = 0.0
      let mut sum_g = 0.0
      let mut sum_b = 0.0
      let mut sum_w = 0.0
      for idx in 0..<n {
        let img = images[idx]
        let r = img.data[(y * w + x) * c].to_double() / 255.0
        let g = if c > 1 {
          img.data[(y * w + x) * c + 1].to_double() / 255.0
        } else {
          r
        }
        let b = if c > 2 {
          img.data[(y * w + x) * c + 2].to_double() / 255.0
        } else {
          r
        }
        let weight = mertens_weight(r, g, b)
        sum_r = sum_r + r * weight
        sum_g = sum_g + g * weight
        sum_b = sum_b + b * weight
        sum_w = sum_w + weight
      }
      let nr = if sum_w > 0.0 { sum_r / sum_w * 255.0 } else { 0.0 }
      let ng = if sum_w > 0.0 { sum_g / sum_w * 255.0 } else { 0.0 }
      let nb = if sum_w > 0.0 { sum_b / sum_w * 255.0 } else { 0.0 }
      out.push(clamp_d(nr).to_byte())
      out.push(clamp_d(ng).to_byte())
      out.push(clamp_d(nb).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
fn mertens_weight(r : Double, g : Double, b : Double) -> Double {
  let contrast = (r - g).abs() + (g - b).abs() + (r - b).abs()
  let saturation = (r - g).sqrt() * (r - g) +
    (g - b) * (g - b) +
    (r - b) * (r - b)
  let lum = (r + g + b) / 3.0
  let well_exposed = @math.exp(-(lum - 0.5) * (lum - 0.5) / 0.2)
  contrast * 0.2 + saturation * 0.8 + well_exposed * 1.0 + 0.01
}

///|
/// 加权 HDR 合并：基于曝光值的对数加权
pub fn hdr_plus_weighted_merge(
  images : Array[@types.Image],
  exposures : Array[Double],
) -> @types.Image {
  if images.length() == 0 {
    return @types.Image::{
      width: 1,
      height: 1,
      channels: 1,
      data: Bytes::from_array([0]),
    }
  }
  let w = images[0].width
  let h = images[0].height
  let c = images[0].channels
  let n = images.length()
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let sum = Array::make(c, 0.0)
      let mut sum_w = 0.0
      for idx in 0..<n {
        let img = images[idx]
        let exp = if idx < exposures.length() { exposures[idx] } else { 0.0 }
        let weight = @math.exp(-exp * exp / 2.0)
        for ch in 0..<c {
          let v = img.data[(y * w + x) * c + ch].to_double() / 255.0
          let _ = sum
          sum[ch] = sum[ch] + v * weight
        }
        sum_w = sum_w + weight
      }
      for ch in 0..<c {
        let v = if sum_w > 0.0 { sum[ch] / sum_w * 255.0 } else { 0.0 }
        out.push(clamp_d(v).to_byte())
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: c,
    data: Bytes::from_array(out),
  }
}

///|
/// 响应曲线标定：从多曝光图像对估计相机响应函数
///
/// 返回 256 个值的查找表，将观测像素值映射到线性响应
pub fn hdr_plus_calibrate_response(
  images : Array[@types.Image],
  exposures : Array[Double],
) -> Array[Double] {
  let curve : Array[Double] = []
  for i in 0..<256 {
    let mut sum = 0.0
    let mut count = 0.0
    for idx in 0..<images.length() {
      let img = images[idx]
      let n = img.width * img.height * img.channels
      for px in 0..<n {
        if img.data[px].to_int() == i {
          let exp = if idx < exposures.length() { exposures[idx] } else { 0.0 }
          sum = sum + exp
          count = count + 1.0
        }
      }
    }
    if count > 0.0 {
      curve.push(sum / count)
    } else {
      curve.push(i.to_double() / 255.0)
    }
  }
  curve
}

///|
/// HDR+ 完整流水线：对齐 → 去鬼影 → 合并 → 输出
pub fn hdr_plus_pipeline(
  images : Array[@types.Image],
  params : HdrPlusParams,
) -> @types.Image {
  if images.length() == 0 {
    return @types.Image::{
      width: 1,
      height: 1,
      channels: 1,
      data: Bytes::from_array([0]),
    }
  }
  if images.length() == 1 {
    return images[0]
  }
  let reference = images[0]
  let aligned : Array[@types.Image] = [reference]
  for i in 1..<images.length() {
    let ghost = hdr_plus_detect_ghost(
      reference,
      images[i],
      params.ghost_threshold,
    )
    let deghosted = hdr_plus_apply_ghost_map(reference, images[i], ghost)
    aligned.push(deghosted)
  }
  match params.mode {
    Mertens => hdr_plus_mertens_fusion(aligned)
    Weighted => hdr_plus_weighted_merge(aligned, [])
    DeGhost => hdr_plus_mertens_fusion(aligned)
  }
}

///|
/// 计算图像曝光值（对数域）
pub fn hdr_plus_estimate_exposure(img : @types.Image) -> Double {
  let w = img.width
  let h = img.height
  let c = img.channels
  let n = w * h * c
  let mut sum = 0.0
  for i in 0..<n {
    let v = img.data[i].to_double() / 255.0
    if v > 0.01 {
      sum = sum + @math.log2(v)
    }
  }
  if n > 0 {
    sum / n.to_double()
  } else {
    0.0
  }
}

///|
fn clamp_d(v : Double) -> Int {
  if v > 255.0 {
    255
  } else if v < 0.0 {
    0
  } else {
    v.to_int()
  }
}
