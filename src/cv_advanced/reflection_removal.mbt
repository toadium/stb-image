// 反射去除 — 偏振/多帧/深度感知反射检测与去除
// Reflection removal: polarization / multi-frame / depth-aware
//
// Phase 16 v389: 计算摄影大扩展 — 反射去除。

///|
/// 反射去除方法。
/// Reflection removal method.
pub(all) enum ReflectionRemovalMethod {
  Polarization // 偏振分离
  MultiFrame // 多帧差分
  DepthAware // 深度感知
  Gradient // 梯度分离
} derive(Eq, @debug.Debug)

///|
pub extend ReflectionRemovalMethod with @debug.Debug::{to_repr}

///|
pub extend ReflectionRemovalMethod with Eq::{not_equal, equal}

///|
/// 反射去除参数。
/// Reflection removal parameters.
pub(all) struct ReflectionRemovalParams {
  rr_method : ReflectionRemovalMethod
  threshold : Double // 反射检测阈值
  strength : Double // 去除强度 (0.0~1.0)
  num_polarization_angles : Int32 // 偏振角度数
  smoothing_radius : Int32 // 平滑半径
} derive(Eq, @debug.Debug)

///|
pub extend ReflectionRemovalParams with @debug.Debug::{to_repr}

///|
pub extend ReflectionRemovalParams with Eq::{not_equal, equal}

///|
/// 反射检测结果。
/// Reflection detection result.
pub(all) struct ReflectionDetectionResult {
  reflection_mask : Array[Bool] // 反射掩模
  reflection_ratio : Double // 反射像素比例
  confidence : Array[Double] // 每像素置信度
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend ReflectionDetectionResult with @debug.Debug::{to_repr}

///|
pub extend ReflectionDetectionResult with Eq::{not_equal, equal}

///|
/// 检测反射区域：高亮度 + 高饱和度 + 局部对比度突变。
/// Detect reflection regions.
pub fn detect_reflection(
  img : @types.Image,
  threshold : Double,
) -> ReflectionDetectionResult {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let mask : Array[Bool] = []
  let confidence : Array[Double] = []
  let mut ref_count = 0
  let t = threshold.clamp(min=0.5, max=1.0)
  for y in 0..<h {
    for x in 0..<w {
      let pi = (y * w + x) * ch
      let mut max_val = 0.0
      let mut min_val = 255.0
      let mut sum = 0.0
      for c in 0..<ch {
        let v = img.data[pi + c].to_int().to_double()
        sum = sum + v
        if v > max_val {
          max_val = v
        }
        if v < min_val {
          min_val = v
        }
      }
      let brightness = sum / ch.to_double() / 255.0
      let saturation = if max_val > 0.0 {
        (max_val - min_val) / max_val
      } else {
        0.0
      }
      // 反射特征：高亮度 + 低饱和度（白色高光）
      let is_ref = brightness > t && saturation < 0.3
      let conf = if is_ref { brightness * (1.0 - saturation) } else { 0.0 }
      mask.push(is_ref)
      confidence.push(conf)
      if is_ref {
        ref_count = ref_count + 1
      }
    }
  }
  let ratio = if w * h > 0 {
    ref_count.to_double() / (w * h).to_double()
  } else {
    0.0
  }
  {
    reflection_mask: mask,
    reflection_ratio: ratio,
    confidence,
    width: w,
    height: h,
  }
}

///|
/// 偏振反射去除：利用多偏振角度图像分离反射。
/// Polarization-based reflection removal.
/// I_reflection = max(I_angles) - min(I_angles)
/// I_scene = mean(I_angles) - alpha * I_reflection
pub fn remove_reflection_polarization(
  polarization_images : Array[@types.Image],
  strength : Double,
) -> @types.Image {
  let n = polarization_images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  let w = polarization_images[0].width
  let h = polarization_images[0].height
  let ch = polarization_images[0].channels
  let alpha = strength.clamp(min=0.0, max=1.0)
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let mut max_val = 0.0
    let mut min_val = 255.0
    let mut sum = 0.0
    for k in 0..<n {
      if i < polarization_images[k].data.length() {
        let v = polarization_images[k].data[i].to_int().to_double()
        sum = sum + v
        if v > max_val {
          max_val = v
        }
        if v < min_val {
          min_val = v
        }
      }
    }
    let mean = sum / n.to_double()
    let reflection_component = max_val - min_val
    let scene = mean - alpha * reflection_component
    data.push(scene.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 多帧反射去除：利用多帧图像中反射的位置变化去除反射。
/// Multi-frame reflection removal.
pub fn remove_reflection_multi_frame(
  images : Array[@types.Image],
  threshold : Double,
  strength : Double,
) -> @types.Image {
  let n = images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  if n == 1 {
    return images[0]
  }
  let w = images[0].width
  let h = images[0].height
  let ch = images[0].channels
  let alpha = strength.clamp(min=0.0, max=1.0)
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let vals : Array[Double] = []
    for k in 0..<n {
      if i < images[k].data.length() {
        vals.push(images[k].data[i].to_int().to_double())
      } else {
        vals.push(0.0)
      }
    }
    // 排序取中值（中值滤波去除反射异常值）
    vals.sort()
    let median = vals[vals.length() / 2]
    let mut max_val = 0.0
    let mut min_val = 255.0
    for v in vals {
      if v > max_val {
        max_val = v
      }
      if v < min_val {
        min_val = v
      }
    }
    // 反射分量 = max - median，超过阈值才去除
    let reflection = max_val - median
    let effective_alpha = if reflection > threshold * 255.0 {
      alpha
    } else {
      0.0
    }
    let scene = median - effective_alpha * reflection
    data.push(scene.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 深度感知反射去除：利用深度图分离前景和反射。
/// Depth-aware reflection removal.
pub fn remove_reflection_depth_aware(
  img : @types.Image,
  depth : DepthMap,
  threshold : Double,
  strength : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let alpha = strength.clamp(min=0.0, max=1.0)
  let detection = detect_reflection(img, threshold)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let is_ref = idx < detection.reflection_mask.length() &&
        detection.reflection_mask[idx]
      let depth_val = if idx < depth.depths.length() && depth.valid[idx] {
        depth.depths[idx]
      } else {
        0.0
      }
      for c in 0..<ch {
        let pi = idx * ch + c
        if !is_ref {
          data.push(img.data[pi])
          continue
        }
        // 用深度信息加权：远处反射更容易去除
        let depth_weight = depth_val.clamp(min=0.0, max=1.0)
        let local_strength = alpha * (0.5 + 0.5 * 9 * depth_weight)
        // 用周围非反射像素修复
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-2, -1, 1, 2] {
          for dx in [-2, -1, 1, 2] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let nidx = ny * w + nx
              if nidx < detection.reflection_mask.length() &&
                !detection.reflection_mask[nidx] {
                let npi = nidx * ch + c
                sum = sum + img.data[npi].to_int().to_double()
                count = count + 1.0
              }
            }
          }
        }
        if count > 0.0 {
          let repaired = sum / count
          let original = img.data[pi].to_int().to_double()
          let result = original * (1.0 - local_strength) +
            repaired * local_strength
          data.push(result.clamp(min=0.0, max=255.0).to_int().to_byte())
        } else {
          data.push(img.data[pi])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 梯度反射去除：利用梯度方向分离反射和场景。
/// Gradient-based reflection removal.
pub fn remove_reflection_gradient(
  img : @types.Image,
  threshold : Double,
  strength : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let alpha = strength.clamp(min=0.0, max=1.0)
  let detection = detect_reflection(img, threshold)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let is_ref = idx < detection.reflection_mask.length() &&
        detection.reflection_mask[idx]
      for c in 0..<ch {
        let pi = idx * ch + c
        if !is_ref {
          data.push(img.data[pi])
          continue
        }
        // 计算梯度方向
        let center = img.data[pi].to_int().to_double()
        let gx = if x + 1 < w {
          center - img.data[(y * w + x + 1) * ch + c].to_int().to_double()
        } else {
          0.0
        }
        let gy = if y + 1 < h {
          center - img.data[((y + 1) * w + x) * ch + c].to_int().to_double()
        } else {
          0.0
        }
        let grad_mag = (gx * gx + gy * gy).sqrt()
        // 反射区域梯度大，用逆梯度加权修复
        let weight = alpha / (1.0 + grad_mag / 50.0)
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dx == 0 && dy == 0 {
              continue
            }
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch + c
              sum = sum + img.data[npi].to_int().to_double()
              count = count + 1.0
            }
          }
        }
        if count > 0.0 {
          let mean = sum / count
          let result = center * (1.0 - weight) + mean * weight
          data.push(result.clamp(min=0.0, max=255.0).to_int().to_byte())
        } else {
          data.push(img.data[pi])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 反射去除流水线。
/// Reflection removal pipeline.
pub fn reflection_removal_pipeline(
  img : @types.Image,
  params : ReflectionRemovalParams,
) -> @types.Image {
  match params.rr_method {
    Polarization =>
      // 单图像退化为梯度方法
      remove_reflection_gradient(img, params.threshold, params.strength)
    MultiFrame =>
      remove_reflection_multi_frame([img], params.threshold, params.strength)
    DepthAware =>
      // 无深度图退化为梯度方法
      remove_reflection_gradient(img, params.threshold, params.strength)
    Gradient =>
      remove_reflection_gradient(img, params.threshold, params.strength)
  }
}

///|
/// 创建默认反射去除参数。
/// Create default reflection removal parameters.
pub fn default_reflection_removal_params(
  rr_method : ReflectionRemovalMethod,
) -> ReflectionRemovalParams {
  {
    rr_method,
    threshold: 0.8,
    strength: 0.7,
    num_polarization_angles: 4,
    smoothing_radius: 2,
  }
}
