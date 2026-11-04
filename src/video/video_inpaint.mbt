// 视频修复 — 补全/去抖/去闪烁
// Video inpainting: completion / de-flicker / de-shimmer
//
// Phase 17 v401: 视频处理大扩展 — 视频修复。

///|
/// 视频修复方法。
/// Video inpainting method.
pub(all) enum VideoInpaintMethod {
  Temporal // 时域修复（用前后帧填补）
  Spatial // 空域修复（用周围像素填补）
  Hybrid // 混合修复
} derive(Eq, @debug.Debug)

///|
pub extend VideoInpaintMethod with @debug.Debug::{to_repr}

///|
pub extend VideoInpaintMethod with Eq::{not_equal, equal}

///|
/// 去闪烁方法。
/// De-flicker method.
pub(all) enum FlickerMethod {
  TemporalFlicker // 时域闪烁去除
  HistogramFlicker // 直方图稳定
  LuminanceFlicker // 亮度归一化
} derive(Eq, @debug.Debug)

///|
pub extend FlickerMethod with @debug.Debug::{to_repr}

///|
pub extend FlickerMethod with Eq::{not_equal, equal}

///|
/// 视频修复配置。
/// Video inpainting configuration.
pub(all) struct VideoInpaintConfig {
  inpaint_method : VideoInpaintMethod
  temporal_radius : Int32 // 时域半径（前后帧数）
  spatial_radius : Int32 // 空域半径（像素）
  blend_factor : Double // 混合因子 (0.0-1.0)
} derive(Eq, @debug.Debug)

///|
pub extend VideoInpaintConfig with @debug.Debug::{to_repr}

///|
pub extend VideoInpaintConfig with Eq::{not_equal, equal}

///|
/// 去闪烁配置。
/// De-flicker configuration.
pub(all) struct FlickerConfig {
  flicker_method : FlickerMethod
  temporal_window : Int32 // 时域窗口大小
  strength : Double // 去闪烁强度 (0.0-1.0)
} derive(Eq, @debug.Debug)

///|
pub extend FlickerConfig with @debug.Debug::{to_repr}

///|
pub extend FlickerConfig with Eq::{not_equal, equal}

///|
/// 闪烁检测结果。
/// Flicker detection result.
pub(all) struct FlickerDetection {
  has_flicker : Bool // 是否检测到闪烁
  flicker_score : Double // 闪烁分数 (0.0-1.0)
  frame_indices : Array[Int32] // 闪烁帧索引
} derive(Eq, @debug.Debug)

///|
pub extend FlickerDetection with @debug.Debug::{to_repr}

///|
pub extend FlickerDetection with Eq::{not_equal, equal}

///|
/// 默认修复配置。
/// Default inpainting configuration.
pub fn default_inpaint_config() -> VideoInpaintConfig {
  {
    inpaint_method: Temporal,
    temporal_radius: 3,
    spatial_radius: 5,
    blend_factor: 0.5,
  }
}

///|
/// 默认去闪烁配置。
/// Default de-flicker configuration.
pub fn default_flicker_config() -> FlickerConfig {
  { flicker_method: TemporalFlicker, temporal_window: 5, strength: 0.8, }
}

///|
/// 计算图像平均亮度。
/// Compute mean luminance of an image.
fn compute_mean_luminance(img : @types.Image) -> Double {
  let n = img.width * img.height * img.channels
  if n == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<n {
    total = total + img.data[i].to_double()
  }
  total / n.to_double()
}

///|
/// 时域修复：用前后帧填补掩码区域。
/// Temporal inpainting: fill masked region using adjacent frames.
pub fn temporal_inpaint(
  current : @types.Image,
  prev_frame : @types.Image,
  next_frame : @types.Image,
  mask : Array[Bool],
  config : VideoInpaintConfig,
) -> @types.Image {
  let w = current.width
  let h = current.height
  let ch = current.channels
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    if mask[i / ch] {
      let prev_val = prev_frame.data[i].to_double()
      let next_val = next_frame.data[i].to_double()
      let blend = config.blend_factor
      let val = prev_val * (1.0 - blend) * 0.5 + next_val * blend * 0.5
      data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
    } else {
      data.push(current.data[i])
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 空域修复：用周围像素填补掩码区域。
/// Spatial inpainting: fill masked region using surrounding pixels.
pub fn spatial_inpaint(
  current : @types.Image,
  mask : Array[Bool],
  config : VideoInpaintConfig,
) -> @types.Image {
  let w = current.width
  let h = current.height
  let ch = current.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if mask[idx] {
        let radius = config.spatial_radius
        let sum : Array[Double] = []
        let mut count = 0
        for _ in 0..<ch {
          sum.push(0.0)
        }
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dx == 0 && dy == 0 {
              continue
            }
            let nx = x + dx * radius
            let ny = y + dy * radius
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let nidx = ny * w + nx
              if !mask[nidx] {
                for c in 0..<ch {
                  let ci = nidx * ch + c
                  sum[c] = sum[c] + current.data[ci].to_double()
                }
                count = count + 1
              }
            }
          }
        }
        if count > 0 {
          for c in 0..<ch {
            let val = sum[c] / count.to_double()
            data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
          }
        } else {
          for c in 0..<ch {
            data.push(current.data[idx * ch + c])
          }
        }
      } else {
        for c in 0..<ch {
          data.push(current.data[idx * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 视频修复主流程。
/// Video inpainting pipeline.
pub fn video_inpaint(
  frames : Array[@types.Image],
  mask : Array[Bool],
  config : VideoInpaintConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  let result : Array[@types.Image] = []
  for i in 0..<n {
    let prev_idx = if i > 0 { i - 1 } else { 0 }
    let next_idx = if i < n - 1 { i + 1 } else { n - 1 }
    let inpainted = match config.inpaint_method {
      Temporal =>
        temporal_inpaint(
          frames[i],
          frames[prev_idx],
          frames[next_idx],
          mask,
          config,
        )
      Spatial => spatial_inpaint(frames[i], mask, config)
      Hybrid => {
        let temp = temporal_inpaint(
          frames[i],
          frames[prev_idx],
          frames[next_idx],
          mask,
          config,
        )
        spatial_inpaint(temp, mask, config)
      }
    }
    result.push(inpainted)
  }
  result
}

///|
/// 检测闪烁：分析帧间亮度变化。
/// Detect flicker: analyze inter-frame luminance changes.
pub fn detect_flicker(
  frames : Array[@types.Image],
  threshold : Double,
) -> FlickerDetection {
  let n = frames.length()
  if n < 2 {
    return { has_flicker: false, flicker_score: 0.0, frame_indices: [], }
  }
  let luminances : Array[Double] = []
  for frame in frames {
    luminances.push(compute_mean_luminance(frame))
  }
  let mut mean_diff = 0.0
  for i in 1..<n {
    mean_diff = mean_diff + (luminances[i] - luminances[i - 1]).abs()
  }
  mean_diff = mean_diff / (n - 1).to_double()
  let flicker_indices : Array[Int32] = []
  for i in 1..<n {
    let diff = (luminances[i] - luminances[i - 1]).abs()
    if diff > threshold {
      flicker_indices.push(i)
    }
  }
  let score = (mean_diff / 255.0).clamp(min=0.0, max=1.0)
  {
    has_flicker: score > 0.05,
    flicker_score: score,
    frame_indices: flicker_indices,
  }
}

///|
/// 时域去闪烁：用时域窗口平滑亮度。
/// Temporal de-flicker: smooth luminance using temporal window.
pub fn deflicker_temporal(
  frames : Array[@types.Image],
  config : FlickerConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  if n == 0 {
    return []
  }
  let window = config.temporal_window
  let luminances : Array[Double] = []
  for frame in frames {
    luminances.push(compute_mean_luminance(frame))
  }
  let result : Array[@types.Image] = []
  for i in 0..<n {
    let mut sum_lum = 0.0
    let mut count = 0
    let half = window / 2
    let start = if i > half { i - half } else { 0 }
    let end = if i + half < n { i + half } else { n - 1 }
    for j in start..<=end {
      sum_lum = sum_lum + luminances[j]
      count = count + 1
    }
    let target_lum = sum_lum / count.to_double()
    let current_lum = luminances[i]
    let ratio = if current_lum > 0.0 { target_lum / current_lum } else { 1.0 }
    let blended_ratio = 1.0 + (ratio - 1.0) * config.strength
    let w = frames[i].width
    let h = frames[i].height
    let ch = frames[i].channels
    let data : Array[Byte] = []
    for k in 0..<(w * h * ch) {
      let val = frames[i].data[k].to_double() * blended_ratio
      data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
    }
    result.push({
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(data),
    })
  }
  result
}

///|
/// 直方图去闪烁：稳定帧间直方图分布。
/// Histogram de-flicker: stabilize inter-frame histogram distribution.
pub fn deflicker_histogram(
  frames : Array[@types.Image],
  config : FlickerConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  if n == 0 {
    return []
  }
  let result : Array[@types.Image] = []
  let prev_hist : Array[Double] = []
  for _ in 0..<256 {
    prev_hist.push(0.0)
  }
  for i in 0..<n {
    let w = frames[i].width
    let h = frames[i].height
    let ch = frames[i].channels
    let curr_hist : Array[Double] = []
    for _ in 0..<256 {
      curr_hist.push(0.0)
    }
    let total = (w * h * ch).to_double()
    for k in 0..<(w * h * ch) {
      let bin = frames[i].data[k].to_int()
      curr_hist[bin] = curr_hist[bin] + 1.0 / total
    }
    let data : Array[Byte] = []
    if i == 0 {
      for k in 0..<(w * h * ch) {
        data.push(frames[i].data[k])
      }
    } else {
      for k in 0..<(w * h * ch) {
        let bin = frames[i].data[k].to_int()
        let target = prev_hist[bin] * (1.0 - config.strength) +
          curr_hist[bin] * config.strength
        let curr = curr_hist[bin]
        let ratio = if curr > 0.0 { target / curr } else { 1.0 }
        let val = frames[i].data[k].to_double() * ratio
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
    for b in 0..<256 {
      prev_hist[b] = curr_hist[b]
    }
    result.push({
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(data),
    })
  }
  result
}

///|
/// 亮度去闪烁：归一化帧间亮度。
/// Luminance de-flicker: normalize inter-frame luminance.
pub fn deflicker_luminance(
  frames : Array[@types.Image],
  config : FlickerConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  if n == 0 {
    return []
  }
  let luminances : Array[Double] = []
  for frame in frames {
    luminances.push(compute_mean_luminance(frame))
  }
  let mut ref_lum = 0.0
  for lum in luminances {
    ref_lum = ref_lum + lum
  }
  ref_lum = ref_lum / n.to_double()
  let result : Array[@types.Image] = []
  for i in 0..<n {
    let current_lum = luminances[i]
    let ratio = if current_lum > 0.0 { ref_lum / current_lum } else { 1.0 }
    let blended_ratio = 1.0 + (ratio - 1.0) * config.strength
    let w = frames[i].width
    let h = frames[i].height
    let ch = frames[i].channels
    let data : Array[Byte] = []
    for k in 0..<(w * h * ch) {
      let val = frames[i].data[k].to_double() * blended_ratio
      data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
    }
    result.push({
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(data),
    })
  }
  result
}

///|
/// 视频去闪烁主流程。
/// Video de-flicker pipeline.
pub fn video_deflicker(
  frames : Array[@types.Image],
  config : FlickerConfig,
) -> Array[@types.Image] {
  match config.flicker_method {
    TemporalFlicker => deflicker_temporal(frames, config)
    HistogramFlicker => deflicker_histogram(frames, config)
    LuminanceFlicker => deflicker_luminance(frames, config)
  }
}

///|
/// 去抖动：减少帧间像素抖动。
/// De-shimmer: reduce inter-frame pixel jitter.
pub fn deshimmer(
  frames : Array[@types.Image],
  strength : Double,
) -> Array[@types.Image] {
  let n = frames.length()
  if n < 2 {
    return frames
  }
  let result : Array[@types.Image] = []
  result.push(frames[0])
  for i in 1..<n {
    let w = frames[i].width
    let h = frames[i].height
    let ch = frames[i].channels
    let data : Array[Byte] = []
    for k in 0..<(w * h * ch) {
      let curr = frames[i].data[k].to_double()
      let prev = frames[i - 1].data[k].to_double()
      let val = curr * (1.0 - strength) + prev * strength
      data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
    }
    result.push({
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(data),
    })
  }
  result
}

///|
/// 视频修复流水线：修复 + 去闪烁 + 去抖动。
/// Video inpainting pipeline: inpaint + de-flicker + de-shimmer.
pub fn inpaint_pipeline(
  frames : Array[@types.Image],
  mask : Array[Bool],
  inpaint_config : VideoInpaintConfig,
  flicker_config : FlickerConfig,
  shimmer_strength : Double,
) -> Array[@types.Image] {
  let inpainted = video_inpaint(frames, mask, inpaint_config)
  let deflickered = video_deflicker(inpainted, flicker_config)
  deshimmer(deflickered, shimmer_strength)
}
