// 时空原语：TInterval / TFrame / TImage / TVideo。
// Spatiotemporal primitives: time interval, temporal frame, time-varying image, video.
//
// 核心思想（GeoVerse）：时间不是属性标签，是原生第 3 维。
// 静态图像 = 单帧 TImage；动画/视频 = 多帧 TImage。

///|
/// 时间区间 [start, end)，单位秒。
/// Time interval [start, end), in seconds.
pub(all) struct TInterval {
  start : Float
  end : Float
} derive(Eq, @debug.Debug)

///|
pub extend TInterval with @debug.Debug::{to_repr}

///|
pub extend TInterval with Eq::{not_equal, equal}

///|
/// 创建时间区间，要求 end >= start。
/// Create a time interval; requires end >= start.
pub fn TInterval::make(
  start : Float,
  end : Float,
) -> TInterval raise @types.LoadError {
  if end < start {
    raise @types.LoadError::DecodeFailed(
      "TInterval::make: end 必须大于等于 start",
    )
  }
  { start, end, }
}

///|
/// 时间区间长度。
/// Duration of the time interval.
pub fn TInterval::duration(self : TInterval) -> Float {
  self.end - self.start
}

///|
/// 时空帧：单帧图像 + 时间戳 + 持续时间。
/// Temporal frame: a single image with timestamp and duration.
pub(all) struct TFrame {
  image : @types.Image
  timestamp : Float
  duration : Float
} derive(Eq, @debug.Debug)

///|
pub extend TFrame with @debug.Debug::{to_repr}

///|
pub extend TFrame with Eq::{not_equal, equal}

///|
/// 创建时空帧。
/// Create a temporal frame.
pub fn TFrame::make(
  image : @types.Image,
  timestamp : Float,
  duration : Float,
) -> TFrame raise @types.LoadError {
  if duration < 0.0F {
    raise @types.LoadError::DecodeFailed("TFrame::make: duration 必须非负")
  }
  { image, timestamp, duration, }
}

///|
/// 时变图像：多帧序列 + 维度 + 帧率。
/// Time-varying image: multi-frame sequence with dimensions and fps.
pub(all) struct TImage {
  frames : Array[TFrame]
  width : Int32
  height : Int32
  channels : Int32
  fps : Float
} derive(Eq, @debug.Debug)

///|
pub extend TImage with @debug.Debug::{to_repr}

///|
pub extend TImage with Eq::{not_equal, equal}

///|
/// 创建时变图像，所有帧尺寸必须一致。
/// Create a time-varying image; all frames must have the same dimensions.
pub fn TImage::make(
  frames : Array[TFrame],
  fps : Float,
) -> TImage raise @types.LoadError {
  if frames.length() == 0 {
    raise @types.LoadError::DecodeFailed("TImage::make: 帧序列不能为空")
  }
  if fps <= 0.0F {
    raise @types.LoadError::DecodeFailed("TImage::make: fps 必须大于0")
  }
  let first = frames[0]
  let w = first.image.width
  let h = first.image.height
  let ch = first.image.channels
  for i in 1..<frames.length() {
    let f = frames[i]
    if f.image.width != w || f.image.height != h || f.image.channels != ch {
      raise @types.LoadError::DecodeFailed(
        "TImage::make: 所有帧尺寸和通道数必须一致",
      )
    }
  }
  { frames, width: w, height: h, channels: ch, fps, }
}

///|
/// 时变图像的帧数。
/// Number of frames in the time-varying image.
pub fn TImage::frame_count(self : TImage) -> Int32 {
  self.frames.length()
}

///|
/// 时变图像总时长（秒）。
/// Total duration of the time-varying image (seconds).
pub fn TImage::total_duration(self : TImage) -> Float {
  let mut sum = 0.0F
  for i in 0..<self.frames.length() {
    sum = sum + self.frames[i].duration
  }
  sum
}

///|
/// 从单帧静态图像创建时变图像。
/// Create a time-varying image from a single static image frame.
pub fn TImage::from_static(
  image : @types.Image,
) -> TImage raise @types.LoadError {
  let frame = TFrame::make(image, 0.0F, 0.0F)
  TImage::make([frame], 1.0F)
}

///|
/// 时空视频：时变图像 + 元数据。
/// Spatiotemporal video: time-varying image with metadata.
pub(all) struct TVideo {
  timage : TImage
  codec_name : String
  total_duration : Float
} derive(Eq, @debug.Debug)

///|
pub extend TVideo with @debug.Debug::{to_repr}

///|
pub extend TVideo with Eq::{not_equal, equal}

///|
/// 从时变图像创建视频。
/// Create a video from a time-varying image.
pub fn TVideo::from_timage(timage : TImage, codec_name : String) -> TVideo {
  { timage, codec_name, total_duration: timage.total_duration(), }
}
