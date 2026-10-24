// 闪光去除 — 闪光检测/校正/多帧去除
// Flash removal: detection / correction / multi-frame
//
// Phase 16 v388: 计算摄影大扩展 — 闪光去除。

///|
/// 闪光检测方法。
/// Flash detection method.
pub(all) enum FlashDetectionMethod {
  Threshold // 亮度阈值
  LocalPeak // 局部峰值检测
  Gradient // 梯度突变检测
  MultiFrame // 多帧差分
} derive(Eq, @debug.Debug)

///|
pub extend FlashDetectionMethod with @debug.Debug::{to_repr}

///|
pub extend FlashDetectionMethod with Eq::{not_equal, equal}

///|
/// 闪光去除参数。
/// Flash removal parameters.
pub(all) struct FlashRemovalParams {
  detection_method : FlashDetectionMethod
  threshold : Double // 闪光亮度阈值 (0.0~1.0)
  min_flash_size : Int32 // 最小闪光区域大小
  correction_strength : Double // 校正强度 (0.0~1.0)
  dilation_radius : Int32 // 闪光区域膨胀半径
} derive(Eq, @debug.Debug)

///|
pub extend FlashRemovalParams with @debug.Debug::{to_repr}

///|
pub extend FlashRemovalParams with Eq::{not_equal, equal}

///|
/// 闪光检测结果。
/// Flash detection result.
pub(all) struct FlashDetectionResult {
  flash_mask : Array[Bool] // 闪光掩模
  flash_ratio : Double // 闪光像素比例
  num_flash_regions : Int32 // 闪光区域数
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend FlashDetectionResult with @debug.Debug::{to_repr}

///|
pub extend FlashDetectionResult with Eq::{not_equal, equal}

///|
/// 基于亮度阈值检测闪光。
/// Detect flash using brightness threshold.
pub fn detect_flash_threshold(
  img : @types.Image,
  threshold : Double,
) -> FlashDetectionResult {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let mask : Array[Bool] = []
  let mut flash_count = 0
  let t = threshold.clamp(min=0.5, max=1.0) * 255.0
  for i in 0..<(w * h) {
    let mut max_val = 0.0
    for c in 0..<ch {
      let val = img.data[i * ch + c].to_int().to_double()
      if val > max_val {
        max_val = val
      }
    }
    let is_flash = max_val > t
    mask.push(is_flash)
    if is_flash {
      flash_count = flash_count + 1
    }
  }
  let ratio = if w * h > 0 {
    flash_count.to_double() / (w * h).to_double()
  } else {
    0.0
  }
  {
    flash_mask: mask,
    flash_ratio: ratio,
    num_flash_regions: flash_count,
    width: w,
    height: h,
  }
}

///|
/// 基于局部峰值检测闪光。
/// Detect flash using local peak detection.
pub fn detect_flash_local_peak(
  img : @types.Image,
  threshold : Double,
  radius : Int32,
) -> FlashDetectionResult {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let r = radius.clamp(min=1, max=5)
  let mask : Array[Bool] = []
  let mut flash_count = 0
  let t = threshold.clamp(min=0.5, max=1.0) * 255.0
  for y in 0..<h {
    for x in 0..<w {
      let pi = (y * w + x) * ch
      let center_val = img.data[pi].to_int().to_double()
      let mut is_peak = center_val > t
      if is_peak {
        let mut neighbor_max = 0.0
        for dy in [-r, 0, r] {
          for dx in [-r, 0, r] {
            if dx == 0 && dy == 0 {
              continue
            }
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch
              let nval = img.data[npi].to_int().to_double()
              if nval > neighbor_max {
                neighbor_max = nval
              }
            }
          }
        }
        // 中心亮度远高于邻居 → 闪光
        is_peak = center_val > neighbor_max * 1.5
      }
      mask.push(is_peak)
      if is_peak {
        flash_count = flash_count + 1
      }
    }
  }
  let ratio = if w * h > 0 {
    flash_count.to_double() / (w * h).to_double()
  } else {
    0.0
  }
  {
    flash_mask: mask,
    flash_ratio: ratio,
    num_flash_regions: flash_count,
    width: w,
    height: h,
  }
}

///|
/// 基于梯度突变检测闪光。
/// Detect flash using gradient discontinuity.
pub fn detect_flash_gradient(
  img : @types.Image,
  threshold : Double,
) -> FlashDetectionResult {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let mask : Array[Bool] = []
  let mut flash_count = 0
  let grad_t = threshold.clamp(min=0.3, max=1.0) * 255.0
  for y in 0..<h {
    for x in 0..<w {
      let pi = (y * w + x) * ch
      let center = img.data[pi].to_int().to_double()
      let mut max_grad = 0.0
      if x > 0 {
        let g = (center - img.data[(y * w + x - 1) * ch].to_int().to_double()).abs()
        if g > max_grad {
          max_grad = g
        }
      }
      if x + 1 < w {
        let g = (center - img.data[(y * w + x + 1) * ch].to_int().to_double()).abs()
        if g > max_grad {
          max_grad = g
        }
      }
      if y > 0 {
        let g = (center - img.data[((y - 1) * w + x) * ch].to_int().to_double()).abs()
        if g > max_grad {
          max_grad = g
        }
      }
      if y + 1 < h {
        let g = (center - img.data[((y + 1) * w + x) * ch].to_int().to_double()).abs()
        if g > max_grad {
          max_grad = g
        }
      }
      // 高亮度 + 高梯度 → 闪光边缘
      let is_flash = center > 200.0 && max_grad > grad_t
      mask.push(is_flash)
      if is_flash {
        flash_count = flash_count + 1
      }
    }
  }
  let ratio = if w * h > 0 {
    flash_count.to_double() / (w * h).to_double()
  } else {
    0.0
  }
  {
    flash_mask: mask,
    flash_ratio: ratio,
    num_flash_regions: flash_count,
    width: w,
    height: h,
  }
}

///|
/// 多帧闪光检测：比较多帧图像找出闪光区域。
/// Multi-frame flash detection: compare frames to find flash regions.
pub fn detect_flash_multi_frame(
  images : Array[@types.Image],
  threshold : Double,
) -> FlashDetectionResult {
  let n = images.length()
  let w = if n > 0 { images[0].width } else { 0 }
  let h = if n > 0 { images[0].height } else { 0 }
  let ch = if n > 0 { images[0].channels } else { 1 }
  if n < 2 {
    return {
      flash_mask: [],
      flash_ratio: 0.0,
      num_flash_regions: 0,
      width: w,
      height: h,
    }
  }
  let mask : Array[Bool] = []
  let mut flash_count = 0
  let t = threshold.clamp(min=0.3, max=1.0) * 255.0
  for i in 0..<(w * h) {
    // 计算各帧该像素的亮度
    let vals : Array[Double] = []
    for k in 0..<n {
      let pi = i * ch
      if pi < images[k].data.length() {
        vals.push(images[k].data[pi].to_int().to_double())
      } else {
        vals.push(0.0)
      }
    }
    // 计算最大值和最小值
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
    // 某帧亮度远高于其他帧 → 闪光
    let is_flash = max_val - min_val > t
    mask.push(is_flash)
    if is_flash {
      flash_count = flash_count + 1
    }
  }
  let ratio = if w * h > 0 {
    flash_count.to_double() / (w * h).to_double()
  } else {
    0.0
  }
  {
    flash_mask: mask,
    flash_ratio: ratio,
    num_flash_regions: flash_count,
    width: w,
    height: h,
  }
}

///|
/// 膨胀闪光掩模。
/// Dilate flash mask.
pub fn dilate_flash_mask(
  mask : Array[Bool],
  width : Int32,
  height : Int32,
  radius : Int32,
) -> Array[Bool] {
  if radius <= 0 {
    return mask
  }
  let r = radius
  let dilated : Array[Bool] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut found = false
      for dy in [-r, 0, r] {
        for dx in [-r, 0, r] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < width && ny >= 0 && ny < height {
            let idx = ny * width + nx
            if idx < mask.length() && mask[idx] {
              found = true
            }
          }
        }
      }
      dilated.push(found)
    }
  }
  dilated
}

///|
/// 闪光校正：用周围像素修复闪光区域。
/// Flash correction: repair flash regions using surrounding pixels.
pub fn correct_flash(
  img : @types.Image,
  flash_mask : Array[Bool],
  correction_strength : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let strength = correction_strength.clamp(min=0.0, max=1.0)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let is_flash = idx < flash_mask.length() && flash_mask[idx]
      for c in 0..<ch {
        let pi = idx * ch + c
        if !is_flash || strength <= 0.0 {
          data.push(img.data[pi])
          continue
        }
        // 用周围非闪光像素的均值修复
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-2, -1, 1, 2] {
          for dx in [-2, -1, 1, 2] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let nidx = ny * w + nx
              if nidx < flash_mask.length() && !flash_mask[nidx] {
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
          let result = original * (1.0 - strength) + repaired * strength
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
/// 多帧闪光去除：利用无闪光帧修复闪光帧。
/// Multi-frame flash removal: use non-flash frames to repair flash frames.
pub fn remove_flash_multi_frame(
  images : Array[@types.Image],
  params : FlashRemovalParams,
) -> Array[@types.Image] {
  let n = images.length()
  if n <= 1 {
    return images
  }
  let detection = detect_flash_multi_frame(images, params.threshold)
  let results : Array[@types.Image] = []
  for k in 0..<n {
    let w = images[k].width
    let h = images[k].height
    let ch = images[k].channels
    let data : Array[Byte] = []
    for y in 0..<h {
      for x in 0..<w {
        let idx = y * w + x
        let is_flash = idx < detection.flash_mask.length() &&
          detection.flash_mask[idx]
        for c in 0..<ch {
          let pi = idx * ch + c
          if !is_flash {
            data.push(images[k].data[pi])
            continue
          }
          // 从其他帧找非闪光的像素
          let mut sum = 0.0
          let mut count = 0.0
          for j in 0..<n {
            if j == k {
              continue
            }
            let jpi = idx * ch + c
            if jpi < images[j].data.length() {
              sum = sum + images[j].data[jpi].to_int().to_double()
              count = count + 1.0
            }
          }
          if count > 0.0 {
            let repaired = sum / count
            let original = images[k].data[pi].to_int().to_double()
            let result = original * (1.0 - params.correction_strength) +
              repaired * params.correction_strength
            data.push(result.clamp(min=0.0, max=255.0).to_int().to_byte())
          } else {
            data.push(images[k].data[pi])
          }
        }
      }
    }
    results.push({
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(data),
    })
  }
  results
}

///|
/// 闪光去除流水线。
/// Flash removal pipeline.
pub fn flash_removal_pipeline(
  img : @types.Image,
  params : FlashRemovalParams,
) -> @types.Image {
  let detection = match params.detection_method {
    Threshold => detect_flash_threshold(img, params.threshold)
    LocalPeak =>
      detect_flash_local_peak(img, params.threshold, params.dilation_radius)
    Gradient => detect_flash_gradient(img, params.threshold)
    MultiFrame => detect_flash_threshold(img, params.threshold)
  }
  let dilated_mask = dilate_flash_mask(
    detection.flash_mask,
    detection.width,
    detection.height,
    params.dilation_radius,
  )
  correct_flash(img, dilated_mask, params.correction_strength)
}

///|
/// 创建默认闪光去除参数。
/// Create default flash removal parameters.
pub fn default_flash_removal_params(
  detection_method : FlashDetectionMethod,
) -> FlashRemovalParams {
  {
    detection_method,
    threshold: 0.85,
    min_flash_size: 10,
    correction_strength: 0.8,
    dilation_radius: 2,
  }
}
