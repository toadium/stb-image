// 时序快照：取指定时间帧、截取子片段、帧抽取。
// Temporal snapshot: frame at time, subclip, frame extraction.

///|
/// 取指定时间的最近帧（不插值）。
/// Get the nearest frame at the given time (no interpolation).
pub fn st_snapshot(timage : TImage, time : Float) -> @types.Image {
  if timage.frames.length() == 1 {
    return timage.frames[0].image
  }
  let mut acc = 0.0F
  for i in 0..<timage.frames.length() {
    let frame = timage.frames[i]
    let frame_end = acc + frame.duration
    if time < frame_end || i == timage.frames.length() - 1 {
      return frame.image
    }
    acc = frame_end
  }
  timage.frames[timage.frames.length() - 1].image
}

///|
/// 截取子片段：从 start 到 end 时间区间的帧组成新 TImage。
/// Extract a subclip from start to end time.
pub fn st_subclip(
  timage : TImage,
  start : Float,
  end : Float,
) -> TImage raise @types.LoadError {
  if start >= end {
    raise @types.LoadError::DecodeFailed("st_subclip: start 必须小于 end")
  }
  let mut acc = 0.0F
  let selected : Array[TFrame] = []
  for i in 0..<timage.frames.length() {
    let frame = timage.frames[i]
    let frame_end = acc + frame.duration
    // 帧在 [start, end) 范围内
    if frame_end > start && acc < end {
      let new_ts = if acc > start { acc - start } else { 0.0F }
      let frame_start_in_clip = if acc > start { acc } else { start }
      let frame_end_in_clip = if frame_end < end { frame_end } else { end }
      let new_dur = frame_end_in_clip - frame_start_in_clip
      let new_frame = TFrame::make(frame.image, new_ts, new_dur)
      selected.push(new_frame)
    }
    acc = frame_end
  }
  if selected.length() == 0 {
    raise @types.LoadError::DecodeFailed("st_subclip: 时间范围内无帧")
  }
  TImage::make(selected, timage.fps)
}

///|
/// 抽取指定索引的帧。
/// Extract a specific frame by index.
pub fn st_extract_frame(
  timage : TImage,
  index : Int,
) -> @types.Image raise @types.LoadError {
  if index < 0 || index >= timage.frames.length() {
    raise @types.LoadError::DecodeFailed("st_extract_frame: 索引越界")
  }
  timage.frames[index].image
}

///|
/// 从 GIF 动画创建时变图像。
/// Create a time-varying image from a GIF animation.
pub fn st_from_gif_animation(
  gif : @types.GifAnimation,
) -> TImage raise @types.LoadError {
  if gif.frames.length() == 0 {
    raise @types.LoadError::DecodeFailed("st_from_gif_animation: GIF 无帧")
  }
  let frames : Array[TFrame] = []
  let mut ts = 0.0F
  for i in 0..<gif.frames.length() {
    let dur = Float::from_int(gif.delays[i]) / 1000.0F
    let frame = TFrame::make(gif.frames[i], ts, dur)
    frames.push(frame)
    ts = ts + dur
  }
  // 推断 fps
  let total = ts
  let fps = if total > 0.0F {
    Float::from_int(gif.frames.length()) / total
  } else {
    1.0F
  }
  TImage::make(frames, fps)
}
