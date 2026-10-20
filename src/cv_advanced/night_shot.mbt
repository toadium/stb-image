///|
/// 夜景合成模式
pub(all) enum NightShotMode {
  Temporal
  Spatial
  Hybrid
} derive(Eq, @debug.Debug)

///|
pub extend NightShotMode with @debug.Debug::{to_repr}

///|
pub extend NightShotMode with Eq::{not_equal, equal}

///|
/// 夜景合成参数
pub(all) struct NightShotParams {
  mode : NightShotMode
  align_threshold : Double
  noise_strength : Double
  brightness_boost : Double
  contrast_boost : Double
} derive(Eq, @debug.Debug)

///|
pub extend NightShotParams with @debug.Debug::{to_repr}

///|
pub extend NightShotParams with Eq::{not_equal, equal}

///|
/// 构建夜景合成参数
pub fn night_build_params(
  mode : NightShotMode,
  align_threshold? : Double = 3.0,
  noise_strength? : Double = 0.5,
  brightness_boost? : Double = 1.5,
  contrast_boost? : Double = 1.2,
) -> NightShotParams {
  NightShotParams::{
    mode,
    align_threshold,
    noise_strength,
    brightness_boost,
    contrast_boost,
  }
}

///|
/// 多帧时域降噪：对齐后加权平均，降低随机噪声
pub fn night_temporal_denoise(images : Array[@types.Image]) -> @types.Image {
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
      for ch in 0..<c {
        let mut sum = 0
        for idx in 0..<n {
          sum = sum + images[idx].data[(y * w + x) * c + ch].to_int()
        }
        out.push((sum / n).to_byte())
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
/// 运动检测：比较参考帧与当前帧，返回运动掩码
pub fn night_detect_motion(
  reference : @types.Image,
  current : @types.Image,
  threshold : Double,
) -> Array[Bool] {
  let w = reference.width
  let h = reference.height
  let c = reference.channels
  let mask : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut diff = 0.0
      for ch in 0..<c {
        let r = reference.data[(y * w + x) * c + ch].to_int()
        let cur = current.data[(y * w + x) * c + ch].to_int()
        diff = diff + (r - cur).to_double() * (r - cur).to_double()
      }
      diff = (diff / c.to_double()).sqrt()
      mask.push(diff > threshold * 255.0)
    }
  }
  mask
}

///|
/// 运动补偿降噪：在运动区域保留参考帧，非运动区域做时域平均
pub fn night_motion_compensated_denoise(
  reference : @types.Image,
  images : Array[@types.Image],
  threshold : Double,
) -> @types.Image {
  if images.length() == 0 {
    return reference
  }
  let w = reference.width
  let h = reference.height
  let c = reference.channels
  let n = images.length()
  let out : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let motion = night_detect_motion(reference, images[0], threshold)
      let is_motion = motion[y * w + x]
      for ch in 0..<c {
        let v = if is_motion {
          reference.data[(y * w + x) * c + ch]
        } else {
          let mut sum = reference.data[(y * w + x) * c + ch].to_int()
          for idx in 0..<n {
            sum = sum + images[idx].data[(y * w + x) * c + ch].to_int()
          }
          (sum / (n + 1)).to_byte()
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
/// 夜景亮度增强：提升暗部亮度，保留亮部细节
pub fn night_enhance_brightness(
  img : @types.Image,
  boost : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let c = img.channels
  let n = w * h * c
  let out : Array[Byte] = []
  for i in 0..<n {
    let v = img.data[i].to_double() / 255.0
    let enhanced = v * boost / (1.0 + v * boost - v)
    out.push(clamp_d2((enhanced * 255.0).to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: c,
    data: Bytes::from_array(out),
  }
}

///|
/// 夜景对比度增强：S 曲线增强
pub fn night_enhance_contrast(
  img : @types.Image,
  boost : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let c = img.channels
  let n = w * h * c
  let out : Array[Byte] = []
  for i in 0..<n {
    let v = img.data[i].to_double() / 255.0
    let enhanced = 0.5 +
      (v - 0.5) * boost / (1.0 + (v - 0.5).abs() * (boost - 1.0))
    out.push(clamp_d2((enhanced * 255.0).to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: c,
    data: Bytes::from_array(out),
  }
}

///|
/// 夜景色彩校正：增强暖色调，减少偏蓝
pub fn night_correct_color(img : @types.Image) -> @types.Image {
  if img.channels < 3 {
    return img
  }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = []
  for i in 0..<n {
    let r = img.data[i * 3].to_int()
    let g = img.data[i * 3 + 1].to_int()
    let b = img.data[i * 3 + 2].to_int()
    out.push(clamp_d2((r.to_double() * 1.1).to_int()).to_byte())
    out.push(clamp_d2((g.to_double() * 1.05).to_int()).to_byte())
    out.push(clamp_d2((b.to_double() * 0.9).to_int()).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
/// 夜景合成完整流水线：对齐 → 降噪 → 亮度增强 → 对比度增强 → 色彩校正
pub fn night_pipeline(
  images : Array[@types.Image],
  params : NightShotParams,
) -> @types.Image {
  if images.length() == 0 {
    return @types.Image::{
      width: 1,
      height: 1,
      channels: 1,
      data: Bytes::from_array([0]),
    }
  }
  let reference = images[0]
  let denoised = match params.mode {
    Temporal => night_temporal_denoise(images)
    Spatial =>
      night_motion_compensated_denoise(
        reference,
        array_tail(images),
        params.align_threshold / 255.0,
      )
    Hybrid => {
      let temporal = night_temporal_denoise(images)
      if images.length() > 1 {
        night_motion_compensated_denoise(
          temporal,
          array_tail(images),
          params.align_threshold / 255.0,
        )
      } else {
        temporal
      }
    }
  }
  let brightened = night_enhance_brightness(denoised, params.brightness_boost)
  let contrasted = night_enhance_contrast(brightened, params.contrast_boost)
  night_correct_color(contrasted)
}

///|
/// 估计图像噪声水平（基于局部方差）
pub fn night_estimate_noise(img : @types.Image) -> Double {
  let w = img.width
  let h = img.height
  let c = img.channels
  let mut total_var = 0.0
  let mut count = 0.0
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      for ch in 0..<c {
        let center = img.data[(y * w + x) * c + ch].to_double()
        let mut sum = 0.0
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            sum = sum + img.data[((y + dy) * w + (x + dx)) * c + ch].to_double()
          }
        }
        let avg = sum / 9.0
        total_var = total_var + (center - avg) * (center - avg)
        count = count + 1.0
      }
    }
  }
  if count > 0.0 {
    (total_var / count).sqrt() / 255.0
  } else {
    0.0
  }
}

///|
fn clamp_d2(v : Int) -> Int {
  if v > 255 {
    255
  } else if v < 0 {
    0
  } else {
    v
  }
}

///|
fn array_tail(arr : Array[@types.Image]) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  for i in 1..<arr.length() {
    result.push(arr[i])
  }
  result
}
