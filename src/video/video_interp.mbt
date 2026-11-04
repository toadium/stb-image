// 视频插帧 — 光流/相位/深度
// Video frame interpolation: optical flow / phase / depth
//
// Phase 17 v403: 视频处理大扩展 — 视频插帧。

///|
/// 视频插帧方法。
/// Video frame interpolation method.
pub(all) enum FrameInterpMethod {
  LinearInterp // 线性插值
  OpticalFlowInterp // 光流插值
  PhaseInterp // 相位插值
} derive(Eq, @debug.Debug)

///|
pub extend FrameInterpMethod with @debug.Debug::{to_repr}

///|
pub extend FrameInterpMethod with Eq::{not_equal, equal}

///|
/// 视频插帧配置。
/// Video frame interpolation configuration.
pub(all) struct FrameInterpConfig {
  interp_method : FrameInterpMethod
  num_interp_frames : Int32 // 每对帧间插入帧数
  motion_threshold : Double // 运动阈值
  blend_factor : Double // 混合因子 (0.0-1.0)
} derive(Eq, @debug.Debug)

///|
pub extend FrameInterpConfig with @debug.Debug::{to_repr}

///|
pub extend FrameInterpConfig with Eq::{not_equal, equal}

///|
/// 帧间运动估计结果。
/// Inter-frame motion estimation result.
pub(all) struct MotionEstimateResult {
  motion_score : Double // 运动分数 (0.0-1.0)
  dominant_direction : (Double, Double) // 主运动方向 (dx, dy)
  static_ratio : Double // 静态像素比例
} derive(Eq, @debug.Debug)

///|
pub extend MotionEstimateResult with @debug.Debug::{to_repr}

///|
pub extend MotionEstimateResult with Eq::{not_equal, equal}

///|
/// 默认插帧配置。
/// Default interpolation configuration.
pub fn default_interp_config() -> FrameInterpConfig {
  {
    interp_method: LinearInterp,
    num_interp_frames: 1,
    motion_threshold: 10.0,
    blend_factor: 0.5,
  }
}

///|
/// 线性插值两帧之间。
/// Linear interpolation between two frames.
pub fn linear_interpolate_frames(
  frame1 : @types.Image,
  frame2 : @types.Image,
  num_frames : Int32,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  let w = frame1.width
  let h = frame1.height
  let ch = frame1.channels
  for k in 1..<=num_frames {
    let alpha = k.to_double() / (num_frames + 1).to_double()
    let data : Array[Byte] = []
    for i in 0..<(w * h * ch) {
      let v1 = frame1.data[i].to_double()
      let v2 = frame2.data[i].to_double()
      let val = v1 * (1.0 - alpha) + v2 * alpha
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
/// 计算帧间运动估计。
/// Compute motion estimation between frames.
pub fn compute_motion_between_frames(
  frame1 : @types.Image,
  frame2 : @types.Image,
) -> MotionEstimateResult {
  let w = frame1.width
  let h = frame1.height
  let ch = frame1.channels
  let mut total_diff = 0.0
  let mut sum_dx = 0.0
  let mut sum_dy = 0.0
  let mut static_count = 0
  let total_pixels = w * h
  for y in 0..<h {
    for x in 0..<w {
      let mut diff = 0.0
      for c in 0..<ch {
        let idx = (y * w + x) * ch + c
        diff = diff +
          (frame1.data[idx].to_double() - frame2.data[idx].to_double()).abs()
      }
      diff = diff / ch.to_double()
      total_diff = total_diff + diff
      if diff < 5.0 {
        static_count = static_count + 1
      }
      if x > 0 && x < w - 1 {
        let mut grad_x = 0.0
        for c in 0..<ch {
          let left = frame2.data[(y * w + (x - 1)) * ch + c].to_double()
          let right = frame2.data[(y * w + (x + 1)) * ch + c].to_double()
          grad_x = grad_x + (right - left) * 0.5
        }
        if grad_x.abs() > 1.0 {
          sum_dx = sum_dx + diff / grad_x
        }
      }
      if y > 0 && y < h - 1 {
        let mut grad_y = 0.0
        for c in 0..<ch {
          let top = frame2.data[((y - 1) * w + x) * ch + c].to_double()
          let bottom = frame2.data[((y + 1) * w + x) * ch + c].to_double()
          grad_y = grad_y + (bottom - top) * 0.5
        }
        if grad_y.abs() > 1.0 {
          sum_dy = sum_dy + diff / grad_y
        }
      }
    }
  }
  let motion_score = (total_diff / total_pixels.to_double() / 255.0).clamp(
    min=0.0,
    max=1.0,
  )
  let dx = if total_pixels > 0 {
    sum_dx / total_pixels.to_double()
  } else {
    0.0
  }
  let dy = if total_pixels > 0 {
    sum_dy / total_pixels.to_double()
  } else {
    0.0
  }
  let static_ratio = if total_pixels > 0 {
    static_count.to_double() / total_pixels.to_double()
  } else {
    0.0
  }
  { motion_score, dominant_direction: (dx, dy), static_ratio, }
}

///|
/// 光流插值两帧之间。
/// Optical flow interpolation between two frames.
pub fn optical_flow_interpolate(
  frame1 : @types.Image,
  frame2 : @types.Image,
  num_frames : Int32,
  config : FrameInterpConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  let w = frame1.width
  let h = frame1.height
  let ch = frame1.channels
  let motion = compute_motion_between_frames(frame1, frame2)
  let (dx, dy) = motion.dominant_direction
  for k in 1..<=num_frames {
    let alpha = k.to_double() / (num_frames + 1).to_double()
    let data : Array[Byte] = []
    for y in 0..<h {
      for x in 0..<w {
        let src_x = x.to_double() - dx * alpha
        let src_y = y.to_double() - dy * alpha
        let x0 = src_x.to_int()
        let y0 = src_y.to_int()
        let x1 = if x0 + 1 < w { x0 + 1 } else { x0 }
        let y1 = if y0 + 1 < h { y0 + 1 } else { y0 }
        let cx = src_x - x0.to_double()
        let cy = src_y - y0.to_double()
        for c in 0..<ch {
          let v00 = if x0 >= 0 && y0 >= 0 && x0 < w && y0 < h {
            frame1.data[(y0 * w + x0) * ch + c].to_double()
          } else {
            0.0
          }
          let v01 = if x1 >= 0 && y0 >= 0 && x1 < w && y0 < h {
            frame1.data[(y0 * w + x1) * ch + c].to_double()
          } else {
            0.0
          }
          let v10 = if x0 >= 0 && y1 >= 0 && x0 < w && y1 < h {
            frame1.data[(y1 * w + x0) * ch + c].to_double()
          } else {
            0.0
          }
          let v11 = if x1 >= 0 && y1 >= 0 && x1 < w && y1 < h {
            frame1.data[(y1 * w + x1) * ch + c].to_double()
          } else {
            0.0
          }
          let warped = v00 * (1.0 - cx) * (1.0 - cy) +
            v01 * cx * (1.0 - cy) +
            v10 * (1.0 - cx) * cy +
            v11 * cx * cy
          let v2 = frame2.data[(y * w + x) * ch + c].to_double()
          let motion_weight = if (v2 - warped).abs() > config.motion_threshold {
            config.blend_factor
          } else {
            1.0
          }
          let val = (warped * (1.0 - alpha) + v2 * alpha) * motion_weight +
            v2 * (1.0 - motion_weight)
          data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
        }
      }
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
/// 相位插值两帧之间。
/// Phase interpolation between two frames.
pub fn phase_interpolate(
  frame1 : @types.Image,
  frame2 : @types.Image,
  num_frames : Int32,
  config : FrameInterpConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  let w = frame1.width
  let h = frame1.height
  let ch = frame1.channels
  for k in 1..<=num_frames {
    let alpha = k.to_double() / (num_frames + 1).to_double()
    let data : Array[Byte] = []
    for i in 0..<(w * h * ch) {
      let v1 = frame1.data[i].to_double()
      let v2 = frame2.data[i].to_double()
      let phase1 = v1 / 255.0 * 2.0 * 3.141592653589793
      let phase2 = v2 / 255.0 * 2.0 * 3.141592653589793
      let mag1 = v1
      let mag2 = v2
      let interp_phase = phase1 * (1.0 - alpha) + phase2 * alpha
      let interp_mag = mag1 * (1.0 - alpha) + mag2 * alpha
      let val = interp_mag *
        (0.5 + 0.5 * (interp_phase / 3.141592653589793).abs())
      let blended = val * config.blend_factor +
        (v1 * (1.0 - alpha) + v2 * alpha) * (1.0 - config.blend_factor)
      data.push(blended.clamp(min=0.0, max=255.0).to_int().to_byte())
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
/// 插帧主流程：在每对帧间插入新帧。
/// Frame interpolation pipeline: insert new frames between each pair.
pub fn video_interpolate_frames(
  frames : Array[@types.Image],
  config : FrameInterpConfig,
) -> Array[@types.Image] {
  let n = frames.length()
  if n < 2 {
    return frames
  }
  let result : Array[@types.Image] = []
  for i in 0..<(n - 1) {
    result.push(frames[i])
    let interp = match config.interp_method {
      LinearInterp =>
        linear_interpolate_frames(
          frames[i],
          frames[i + 1],
          config.num_interp_frames,
        )
      OpticalFlowInterp =>
        optical_flow_interpolate(
          frames[i],
          frames[i + 1],
          config.num_interp_frames,
          config,
        )
      PhaseInterp =>
        phase_interpolate(
          frames[i],
          frames[i + 1],
          config.num_interp_frames,
          config,
        )
    }
    for frame in interp {
      result.push(frame)
    }
  }
  result.push(frames[n - 1])
  result
}

///|
/// 帧率转换：从原帧率转换到目标帧率。
/// Frame rate conversion: from original to target frame rate.
pub fn frame_rate_conversion(
  frames : Array[@types.Image],
  original_fps : Double,
  target_fps : Double,
  config : FrameInterpConfig,
) -> Array[@types.Image] {
  if target_fps <= original_fps {
    let step = (original_fps / target_fps).to_int()
    let result : Array[@types.Image] = []
    let n = frames.length()
    for i in 0..<n {
      if i % step == 0 {
        result.push(frames[i])
      }
    }
    result
  } else {
    let ratio = target_fps / original_fps
    let num_interp = (ratio - 1.0).to_int()
    let updated_config : FrameInterpConfig = {
      interp_method: config.interp_method,
      num_interp_frames: num_interp,
      motion_threshold: config.motion_threshold,
      blend_factor: config.blend_factor,
    }
    video_interpolate_frames(frames, updated_config)
  }
}

///|
/// 插帧流水线：插帧 + 运动分析。
/// Interpolation pipeline: interpolate + motion analysis.
pub fn interp_pipeline(
  frames : Array[@types.Image],
  config : FrameInterpConfig,
) -> Array[@types.Image] {
  video_interpolate_frames(frames, config)
}
