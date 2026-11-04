// 时间 lapse — 采样/稳定/曝光
// Timelapse: sampling / stabilization / exposure
//
// Phase 17 v398: 视频处理大扩展 — 时间 lapse。

///|
/// 曝光调整模式。
/// Exposure adjustment mode.
pub(all) enum ExposureMode {
  Linear // 线性
  Logarithmic // 对数
  Gamma // 伽马校正
} derive(Eq, @debug.Debug)

///|
pub extend ExposureMode with @debug.Debug::{to_repr}

///|
pub extend ExposureMode with Eq::{not_equal, equal}

///|
/// 时间 lapse 配置。
/// Timelapse configuration.
pub(all) struct TimelapseConfig {
  sample_interval : Int32 // 采样间隔（每 N 帧取 1 帧）
  exposure_mode : ExposureMode
  exposure_compensation : Double // 曝光补偿 (-2.0 ~ +2.0)
  gamma : Double // 伽马值 (仅 Gamma 模式)
  stabilize : Bool // 是否启用稳定
} derive(Eq, @debug.Debug)

///|
pub extend TimelapseConfig with @debug.Debug::{to_repr}

///|
pub extend TimelapseConfig with Eq::{not_equal, equal}

///|
/// 默认时间 lapse 配置。
/// Default timelapse configuration.
pub fn default_timelapse_config() -> TimelapseConfig {
  {
    sample_interval: 10,
    exposure_mode: Linear,
    exposure_compensation: 0.0,
    gamma: 1.0,
    stabilize: false,
  }
}

///|
/// 按间隔采样帧。
/// Sample frames at interval.
pub fn sample_frames(
  frames : Array[@types.Image],
  interval : Int32,
) -> Array[@types.Image] {
  if interval <= 0 {
    return frames
  }
  let result : Array[@types.Image] = []
  let n = frames.length()
  let mut i = 0
  while i < n {
    result.push(frames[i])
    i = i + interval
  }
  result
}

///|
/// 线性曝光调整。
/// Linear exposure adjustment.
fn adjust_exposure_linear(
  img : @types.Image,
  compensation : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  // compensation: -2.0 ~ +2.0, 映射到 0.25x ~ 4x
  let factor = @math.exp(compensation * 0.6931471805599453)
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() * factor
    data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 对数曝光调整。
/// Logarithmic exposure adjustment.
fn adjust_exposure_log(
  img : @types.Image,
  compensation : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let shift = compensation * 50.0
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double()
    // 对数映射: output = log(1 + val) * scale + shift
    let log_val = @math.log10(1.0 + val) * 100.0 + shift
    data.push(log_val.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 伽马曝光调整。
/// Gamma exposure adjustment.
fn adjust_exposure_gamma(img : @types.Image, gamma : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let g = if gamma > 0.0 { gamma } else { 1.0 }
  for i in 0..<(w * h * ch) {
    let val = img.data[i].to_int().to_double() / 255.0
    let corrected = @math.pow(val, 1.0 / g) * 255.0
    data.push(corrected.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 调整曝光。
/// Adjust exposure.
pub fn adjust_exposure(
  img : @types.Image,
  config : TimelapseConfig,
) -> @types.Image {
  match config.exposure_mode {
    Linear => adjust_exposure_linear(img, config.exposure_compensation)
    Logarithmic => adjust_exposure_log(img, config.exposure_compensation)
    Gamma =>
      adjust_exposure_gamma(
        adjust_exposure_linear(img, config.exposure_compensation),
        config.gamma,
      )
  }
}

///|
/// 曝光调整序列。
/// Adjust exposure for sequence.
pub fn adjust_exposure_sequence(
  frames : Array[@types.Image],
  config : TimelapseConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  for f in frames {
    result.push(adjust_exposure(f, config))
  }
  result
}

///|
/// 创建时间 lapse。
/// Create timelapse from frames.
pub fn create_timelapse(
  frames : Array[@types.Image],
  config : TimelapseConfig,
) -> Array[@types.Image] {
  // 1. 采样
  let sampled = sample_frames(frames, config.sample_interval)
  // 2. 曝光调整
  let exposed = adjust_exposure_sequence(sampled, config)
  // 3. 稳定（可选）
  if config.stabilize {
    let stab_config = default_stabilization_config()
    let result = stabilize_video_sequence(exposed, stab_config)
    result.frames
  } else {
    exposed
  }
}

///|
/// 时间 lapse 流水线（采样 + 曝光 + 稳定 + 运动模糊）。
/// Timelapse pipeline.
pub fn timelapse_pipeline(
  frames : Array[@types.Image],
  config : TimelapseConfig,
  motion_blur_amount : Double,
) -> Array[@types.Image] {
  let timelapse = create_timelapse(frames, config)
  if motion_blur_amount > 0.0 {
    let result : Array[@types.Image] = []
    for frame in timelapse {
      result.push(apply_motion_blur(frame, motion_blur_amount, 0))
    }
    result
  } else {
    timelapse
  }
}

///|
/// 计算时间 lapse 帧数。
/// Compute timelapse frame count.
pub fn compute_timelapse_count(
  frame_count : Int32,
  sample_interval : Int32,
) -> Int32 {
  if frame_count <= 0 || sample_interval <= 0 {
    return 0
  }
  (frame_count + sample_interval - 1) / sample_interval
}

///|
/// 计算时间 lapse 时长。
/// Compute timelapse duration.
pub fn compute_timelapse_duration(
  frame_count : Int32,
  sample_interval : Int32,
  target_fps : Int32,
) -> Double {
  let tl_count = compute_timelapse_count(frame_count, sample_interval)
  if target_fps <= 0 {
    return 0.0
  }
  tl_count.to_double() / target_fps.to_double()
}

///|
/// 计算时间压缩比。
/// Compute time compression ratio.
pub fn compute_time_compression(
  source_duration : Double,
  timelapse_duration : Double,
) -> Double {
  if timelapse_duration <= 0.0 {
    return 0.0
  }
  source_duration / timelapse_duration
}
