// 视频超分 — 时空/递归/深度
// Video super-resolution: spatio-temporal / recursive / depth
//
// Phase 17 v402: 视频处理大扩展 — 视频超分。

///|
/// 视频超分方法。
/// Video super-resolution method.
pub(all) enum VideoSRMethod {
  BicubicSR // 双三次插值
  SpatioTemporal // 时空超分
  RecursiveSR // 递归超分
} derive(Eq, @debug.Debug)

///|
pub extend VideoSRMethod with @debug.Debug::{to_repr}

///|
pub extend VideoSRMethod with Eq::{not_equal, equal}

///|
/// 视频超分配置。
/// Video super-resolution configuration.
pub(all) struct VideoSRConfig {
  sr_method : VideoSRMethod
  scale_factor : Int32 // 放大倍数 (2/4/8)
  temporal_window : Int32 // 时域窗口大小
  blend_factor : Double // 混合因子 (0.0-1.0)
} derive(Eq, @debug.Debug)

///|
pub extend VideoSRConfig with @debug.Debug::{to_repr}

///|
pub extend VideoSRConfig with Eq::{not_equal, equal}

///|
/// 视频超分结果。
/// Video super-resolution result.
pub(all) struct VideoSRResult {
  frames : Array[@types.Image] // 超分后帧序列
  scale_factor : Int32 // 实际放大倍数
  quality_score : Double // 质量分数 (0.0-1.0)
} derive(Eq, @debug.Debug)

///|
pub extend VideoSRResult with @debug.Debug::{to_repr}

///|
pub extend VideoSRResult with Eq::{not_equal, equal}

///|
/// 默认超分配置。
/// Default super-resolution configuration.
pub fn default_sr_config() -> VideoSRConfig {
  {
    sr_method: BicubicSR,
    scale_factor: 2,
    temporal_window: 3,
    blend_factor: 0.5,
  }
}

///|
/// 双线性上采样。
/// Bilinear upscaling.
pub fn bilinear_upscale(img : @types.Image, scale : Int32) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let new_w = w * scale
  let new_h = h * scale
  let data : Array[Byte] = []
  for y in 0..<new_h {
    for x in 0..<new_w {
      let src_x = x.to_double() / scale.to_double()
      let src_y = y.to_double() / scale.to_double()
      let x0 = src_x.to_int()
      let y0 = src_y.to_int()
      let x1 = if x0 + 1 < w { x0 + 1 } else { x0 }
      let y1 = if y0 + 1 < h { y0 + 1 } else { y0 }
      let fx = src_x - x0.to_double()
      let fy = src_y - y0.to_double()
      for c in 0..<ch {
        let v00 = img.data[(y0 * w + x0) * ch + c].to_double()
        let v01 = img.data[(y0 * w + x1) * ch + c].to_double()
        let v10 = img.data[(y1 * w + x0) * ch + c].to_double()
        let v11 = img.data[(y1 * w + x1) * ch + c].to_double()
        let val = v00 * (1.0 - fx) * (1.0 - fy) +
          v01 * fx * (1.0 - fy) +
          v10 * (1.0 - fx) * fy +
          v11 * fx * fy
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: new_w, height: new_h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 双三次上采样（简化版）。
/// Bicubic upscaling (simplified).
fn bicubic_upscale(img : @types.Image, scale : Int32) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let new_w = w * scale
  let new_h = h * scale
  let data : Array[Byte] = []
  for y in 0..<new_h {
    for x in 0..<new_w {
      let src_x = x.to_double() / scale.to_double()
      let src_y = y.to_double() / scale.to_double()
      let cx = src_x.to_int()
      let cy = src_y.to_int()
      for c in 0..<ch {
        let mut sum = 0.0
        let mut weight_sum = 0.0
        for dy in [-1, 0, 1, 2] {
          for dx in [-1, 0, 1, 2] {
            let nx = cx + dx
            let ny = cy + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let wx = cubic_weight(src_x - nx.to_double())
              let wy = cubic_weight(src_y - ny.to_double())
              let weight = wx * wy
              sum = sum + img.data[(ny * w + nx) * ch + c].to_double() * weight
              weight_sum = weight_sum + weight
            }
          }
        }
        let val = if weight_sum > 0.0 { sum / weight_sum } else { 0.0 }
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: new_w, height: new_h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 三次样条权重函数。
/// Cubic spline weight function.
fn cubic_weight(t : Double) -> Double {
  let t = t.abs()
  if t < 1.0 {
    1.5 * t * t * t - 2.5 * t * t + 1.0
  } else if t < 2.0 {
    -0.5 * t * t * t + 2.5 * t * t - 4.0 * t + 2.0
  } else {
    0.0
  }
}

///|
/// 双三次超分。
/// Bicubic super-resolution.
pub fn bicubic_super_resolve(
  frames : Array[@types.Image],
  config : VideoSRConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  for frame in frames {
    result.push(bicubic_upscale(frame, config.scale_factor))
  }
  result
}

///|
/// 时空超分：利用时域信息增强空间分辨率。
/// Spatio-temporal super-resolution: use temporal info to enhance spatial resolution.
pub fn spatio_temporal_sr(
  frames : Array[@types.Image],
  config : VideoSRConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  if n == 0 {
    return []
  }
  let result : Array[@types.Image] = []
  let half = config.temporal_window / 2
  for i in 0..<n {
    let upscaled = bicubic_upscale(frames[i], config.scale_factor)
    let start = if i > half { i - half } else { 0 }
    let end = if i + half < n { i + half } else { n - 1 }
    let w = upscaled.width
    let h = upscaled.height
    let ch = upscaled.channels
    let data : Array[Byte] = []
    for k in 0..<(w * h * ch) {
      let mut sum = upscaled.data[k].to_double()
      let mut count = 1.0
      for j in start..<=end {
        if j != i {
          let ref_upscaled = bicubic_upscale(frames[j], config.scale_factor)
          sum = sum + ref_upscaled.data[k].to_double() * config.blend_factor
          count = count + config.blend_factor
        }
      }
      let val = sum / count
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
/// 递归超分：多次小倍数超分级联。
/// Recursive super-resolution: cascade multiple small-scale super-resolution.
pub fn recursive_sr(
  frames : Array[@types.Image],
  config : VideoSRConfig,
) -> Array[@types.Image] {
  let scale = config.scale_factor
  if scale <= 1 {
    return frames
  }
  let mut current = frames
  let mut remaining = scale
  while remaining > 1 {
    let step = if remaining >= 2 { 2 } else { remaining }
    let step_result : Array[@types.Image] = []
    for frame in current {
      step_result.push(bicubic_upscale(frame, step))
    }
    current = step_result
    remaining = remaining / step
  }
  current
}

///|
/// 视频超分主流程。
/// Video super-resolution pipeline.
pub fn video_super_resolve(
  frames : Array[@types.Image],
  config : VideoSRConfig,
) -> VideoSRResult {
  let result = match config.sr_method {
    BicubicSR => bicubic_super_resolve(frames, config)
    SpatioTemporal => spatio_temporal_sr(frames, config)
    RecursiveSR => recursive_sr(frames, config)
  }
  let quality = compute_sr_quality(frames, result, config.scale_factor)
  { frames: result, scale_factor: config.scale_factor, quality_score: quality, }
}

///|
/// 计算超分质量分数（基于下采样一致性）。
/// Compute super-resolution quality score (based on downsample consistency).
pub fn compute_sr_quality(
  original : Array[@types.Image],
  super_resolved : Array[@types.Image],
  scale : Int32,
) -> Double {
  let n = original.length()
  if n == 0 || super_resolved.length() == 0 {
    return 0.0
  }
  let mut total_score = 0.0
  for i in 0..<n {
    let sr = super_resolved[i]
    let w = sr.width
    let h = sr.height
    let ch = sr.channels
    let orig_w = original[i].width
    let orig_h = original[i].height
    if w != orig_w * scale || h != orig_h * scale {
      continue
    }
    let mut diff_sum = 0.0
    let mut count = 0
    for y in 0..<orig_h {
      for x in 0..<orig_w {
        for c in 0..<ch {
          let sr_x = x * scale
          let sr_y = y * scale
          let sr_val = sr.data[(sr_y * w + sr_x) * ch + c].to_double()
          let orig_val = original[i].data[(y * orig_w + x) * ch + c].to_double()
          diff_sum = diff_sum + (sr_val - orig_val).abs()
          count = count + 1
        }
      }
    }
    if count > 0 {
      let avg_diff = diff_sum / count.to_double()
      let score = 1.0 - (avg_diff / 255.0).clamp(min=0.0, max=1.0)
      total_score = total_score + score
    }
  }
  total_score / n.to_double()
}

///|
/// 超分流水线：超分 + 质量评估。
/// Super-resolution pipeline: super-resolve + quality evaluation.
pub fn sr_pipeline(
  frames : Array[@types.Image],
  config : VideoSRConfig,
) -> VideoSRResult {
  video_super_resolve(frames, config)
}
