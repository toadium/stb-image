// 帧间插值：线性插值 + 指定时间取帧。
// Frame interpolation: linear blend + frame at specific time.

///|
/// 线性插值两帧图像：(1 - alpha) * frame1 + alpha * frame2。
/// 两帧尺寸和通道数必须一致，alpha 通常在 [0, 1]。
/// Linear interpolation between two frames: (1 - alpha) * f1 + alpha * f2.
pub fn st_interpolate_linear(
  frame1 : @types.Image,
  frame2 : @types.Image,
  alpha : Float,
) -> @types.Image raise @types.LoadError {
  if frame1.width != frame2.width ||
    frame1.height != frame2.height ||
    frame1.channels != frame2.channels {
    raise @types.LoadError::DecodeFailed(
      "st_interpolate_linear: 两帧尺寸和通道数必须一致",
    )
  }
  let w = frame1.width
  let h = frame1.height
  let ch = frame1.channels
  let n = w * h * ch
  let buf : Array[Byte] = Array::make(n, b'\x00')
  let one_minus = 1.0F - alpha
  for i in 0..<n {
    let v1 = Float::from_int(frame1.data[i].to_int())
    let v2 = Float::from_int(frame2.data[i].to_int())
    let blended = one_minus * v1 + alpha * v2
    buf[i] = (blended + 0.5F).to_int().clamp(min=0, max=255).to_byte()
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(buf), }
}

///|
/// 在指定时间取帧：找到时间所在的帧区间，线性插值。
/// 若时间超出范围且非循环，返回最近边界帧。
/// Get interpolated frame at the given time.
pub fn st_interpolate_at(
  timage : TImage,
  time : Float,
) -> @types.Image raise @types.LoadError {
  if timage.frames.length() == 1 {
    return timage.frames[0].image
  }
  // 计算累积时间，找到 time 所在的帧区间
  let mut acc = 0.0F
  for i in 0..<timage.frames.length() {
    let frame = timage.frames[i]
    let frame_end = acc + frame.duration
    if time < frame_end || i == timage.frames.length() - 1 {
      if frame.duration <= 0.0F {
        return frame.image
      }
      let alpha = (time - acc) / frame.duration
      let clamped_alpha = if alpha < 0.0F {
        0.0F
      } else if alpha > 1.0F {
        1.0F
      } else {
        alpha
      }
      if i + 1 < timage.frames.length() {
        return st_interpolate_linear(
          frame.image,
          timage.frames[i + 1].image,
          clamped_alpha,
        )
      }
      return frame.image
    }
    acc = frame_end
  }
  timage.frames[timage.frames.length() - 1].image
}
