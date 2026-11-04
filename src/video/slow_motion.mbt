// 慢动作 — 光流插帧/运动模糊
// Slow motion: optical flow interpolation / motion blur
//
// Phase 17 v397: 视频处理大扩展 — 慢动作。

///|
/// 慢动作方法。
/// Slow motion method.
pub(all) enum SlowMotionMethod {
  OpticalFlow // 光流插帧
  FrameBlending // 帧混合
  MotionCompensation // 运动补偿
} derive(Eq, @debug.Debug)

///|
pub extend SlowMotionMethod with @debug.Debug::{to_repr}

///|
pub extend SlowMotionMethod with Eq::{not_equal, equal}

///|
/// 慢动作配置。
/// Slow motion configuration.
pub(all) struct SlowMotionConfig {
  sm_method : SlowMotionMethod
  speed_factor : Int32 // 慢放倍数 (2=半速, 4=1/4速)
  blur_amount : Double // 运动模糊强度 (0.0-1.0)
  blur_direction : Int32 // 模糊方向 (0=水平, 1=垂直, 2=径向)
} derive(Eq, @debug.Debug)

///|
pub extend SlowMotionConfig with @debug.Debug::{to_repr}

///|
pub extend SlowMotionConfig with Eq::{not_equal, equal}

///|
/// 默认慢动作配置。
/// Default slow motion configuration.
pub fn default_slow_motion_config() -> SlowMotionConfig {
  {
    sm_method: FrameBlending,
    speed_factor: 2,
    blur_amount: 0.0,
    blur_direction: 0,
  }
}

///|
/// 帧混合插帧。
/// Frame blending interpolation.
pub fn interpolate_frame_blend(
  from : @types.Image,
  to_ : @types.Image,
  alpha : Double,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let data : Array[Byte] = []
  let a = alpha.clamp(min=0.0, max=1.0)
  for i in 0..<(w * h * ch) {
    let fv = from.data[i].to_int().to_double()
    let tv = to_.data[i].to_int().to_double()
    let val = fv * (1.0 - a) + tv * a
    data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 光流插帧（简化：用帧差作为光流近似）。
/// Optical flow interpolation (simplified: frame difference as flow approximation).
pub fn interpolate_frame_optical_flow(
  from : @types.Image,
  to_ : @types.Image,
  alpha : Double,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let data : Array[Byte] = []
  let a = alpha.clamp(min=0.0, max=1.0)
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let idx = (y * w + x) * ch + c
        let fv = from.data[idx].to_int().to_double()
        let tv = to_.data[idx].to_int().to_double()
        // 简化光流：用帧差作为位移近似
        let diff = tv - fv
        let val = fv + diff * a
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 运动补偿插帧。
/// Motion compensation interpolation.
pub fn interpolate_frame_motion_compensation(
  from : @types.Image,
  to_ : @types.Image,
  alpha : Double,
) -> @types.Image {
  // 简化：与帧混合相同
  interpolate_frame_blend(from, to_, alpha)
}

///|
/// 插帧分发。
/// Interpolation dispatch.
pub fn interpolate_frames_slow_motion(
  from : @types.Image,
  to_ : @types.Image,
  alpha : Double,
  sm_method : SlowMotionMethod,
) -> @types.Image {
  match sm_method {
    OpticalFlow => interpolate_frame_optical_flow(from, to_, alpha)
    FrameBlending => interpolate_frame_blend(from, to_, alpha)
    MotionCompensation =>
      interpolate_frame_motion_compensation(from, to_, alpha)
  }
}

///|
/// 生成慢动作序列。
/// Generate slow motion sequence.
pub fn generate_slow_motion(
  frames : Array[@types.Image],
  config : SlowMotionConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  let n = frames.length()
  if n == 0 {
    return result
  }
  let factor = config.speed_factor.clamp(min=1, max=100)
  result.push(frames[0])
  for i in 1..<n {
    for j in 1..<factor {
      let alpha = j.to_double() / factor.to_double()
      let interpolated = interpolate_frames_slow_motion(
        frames[i - 1],
        frames[i],
        alpha,
        config.sm_method,
      )
      result.push(interpolated)
    }
    result.push(frames[i])
  }
  result
}

///|
/// 应用运动模糊（水平方向）。
/// Apply motion blur (horizontal).
fn motion_blur_horizontal(img : @types.Image, amount : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let radius = (amount * 10.0).to_int().clamp(min=1, max=10)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let mut sum = 0.0
        let mut count = 0.0
        for dx in [-radius, 0, radius] {
          let sx = x + dx
          if sx >= 0 && sx < w {
            sum = sum + img.data[(y * w + sx) * ch + c].to_int().to_double()
            count = count + 1.0
          }
        }
        let val = if count > 0.0 { sum / count } else { 0.0 }
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 应用运动模糊（垂直方向）。
/// Apply motion blur (vertical).
fn motion_blur_vertical(img : @types.Image, amount : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let radius = (amount * 10.0).to_int().clamp(min=1, max=10)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-radius, 0, radius] {
          let sy = y + dy
          if sy >= 0 && sy < h {
            sum = sum + img.data[(sy * w + x) * ch + c].to_int().to_double()
            count = count + 1.0
          }
        }
        let val = if count > 0.0 { sum / count } else { 0.0 }
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 应用运动模糊（径向）。
/// Apply motion blur (radial).
fn motion_blur_radial(img : @types.Image, amount : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let cx = w / 2
  let cy = h / 2
  let radius = (amount * 10.0).to_int().clamp(min=1, max=10)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let dx = x - cx
        let dy = y - cy
        let dist = (dx * dx + dy * dy).to_double().sqrt()
        if dist < 0.5 {
          data.push(img.data[(y * w + x) * ch + c])
          continue
        }
        let ux = (dx.to_double() / dist * radius.to_double()).to_int()
        let uy = (dy.to_double() / dist * radius.to_double()).to_int()
        let mut sum = 0.0
        let mut count = 0.0
        for t in [-1, 0, 1] {
          let sx = x + ux * t
          let sy = y + uy * t
          if sx >= 0 && sx < w && sy >= 0 && sy < h {
            sum = sum + img.data[(sy * w + sx) * ch + c].to_int().to_double()
            count = count + 1.0
          }
        }
        let val = if count > 0.0 { sum / count } else { 0.0 }
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 应用运动模糊。
/// Apply motion blur.
pub fn apply_motion_blur(
  img : @types.Image,
  amount : Double,
  direction : Int32,
) -> @types.Image {
  match direction {
    0 => motion_blur_horizontal(img, amount)
    1 => motion_blur_vertical(img, amount)
    _ => motion_blur_radial(img, amount)
  }
}

///|
/// 运动模糊序列。
/// Apply motion blur to sequence.
pub fn motion_blur_sequence(
  frames : Array[@types.Image],
  config : SlowMotionConfig,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  for frame in frames {
    if config.blur_amount > 0.0 {
      result.push(
        apply_motion_blur(frame, config.blur_amount, config.blur_direction),
      )
    } else {
      result.push(frame)
    }
  }
  result
}

///|
/// 慢动作流水线（插帧 + 运动模糊）。
/// Slow motion pipeline (interpolation + motion blur).
pub fn slow_motion_pipeline(
  frames : Array[@types.Image],
  config : SlowMotionConfig,
) -> Array[@types.Image] {
  let interpolated = generate_slow_motion(frames, config)
  motion_blur_sequence(interpolated, config)
}

///|
/// 计算插帧数。
/// Compute number of interpolated frames.
pub fn compute_interpolated_count(
  frame_count : Int32,
  speed_factor : Int32,
) -> Int32 {
  if frame_count <= 0 || speed_factor <= 0 {
    return 0
  }
  frame_count + (frame_count - 1) * (speed_factor - 1)
}
