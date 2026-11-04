// 视频转码 — 格式/分辨率/码率
// Video transcoding: format / resolution / bitrate
//
// Phase 17 v394: 视频处理大扩展 — 视频转码。

///|
/// 视频格式。
/// Video format.
pub(all) enum VideoFormat {
  Raw // 原始格式
  MPEG // MPEG
  H264 // H.264
  VP9 // VP9
  AV1 // AV1
} derive(Eq, @debug.Debug)

///|
pub extend VideoFormat with @debug.Debug::{to_repr}

///|
pub extend VideoFormat with Eq::{not_equal, equal}

///|
/// 分辨率调整模式。
/// Resolution adjustment mode.
pub(all) enum ResolutionMode {
  Scale // 缩放
  Crop // 裁剪
  Pad // 填充
} derive(Eq, @debug.Debug)

///|
pub extend ResolutionMode with @debug.Debug::{to_repr}

///|
pub extend ResolutionMode with Eq::{not_equal, equal}

///|
/// 码率控制模式。
/// Bitrate control mode.
pub(all) enum BitrateMode {
  CBR // 恒定码率
  VBR // 可变码率
  CRF // 恒定质量
} derive(Eq, @debug.Debug)

///|
pub extend BitrateMode with @debug.Debug::{to_repr}

///|
pub extend BitrateMode with Eq::{not_equal, equal}

///|
/// 转码参数。
/// Transcode parameters.
pub(all) struct TranscodeParams {
  target_format : VideoFormat
  target_width : Int32
  target_height : Int32
  resolution_mode : ResolutionMode
  bitrate_mode : BitrateMode
  target_bitrate : Int32 // kbps
  crf : Int32 // 1-51 (仅 CRF 模式)
  fps : Int32 // 帧率
} derive(Eq, @debug.Debug)

///|
pub extend TranscodeParams with @debug.Debug::{to_repr}

///|
pub extend TranscodeParams with Eq::{not_equal, equal}

///|
/// 转码结果。
/// Transcode result.
pub(all) struct TranscodeResult {
  frames : Array[@types.Image]
  format : VideoFormat
  width : Int32
  height : Int32
  bitrate : Int32
  fps : Int32
  size_bytes : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TranscodeResult with @debug.Debug::{to_repr}

///|
pub extend TranscodeResult with Eq::{not_equal, equal}

///|
/// 默认转码参数。
/// Default transcode parameters.
pub fn default_transcode_params() -> TranscodeParams {
  {
    target_format: H264,
    target_width: 1280,
    target_height: 720,
    resolution_mode: Scale,
    bitrate_mode: CRF,
    target_bitrate: 2000,
    crf: 23,
    fps: 30,
  }
}

///|
/// 缩放图像。
/// Scale image to target size.
pub fn scale_image(
  img : @types.Image,
  target_width : Int32,
  target_height : Int32,
) -> @types.Image {
  if target_width <= 0 || target_height <= 0 {
    return img
  }
  let ch = img.channels
  let data : Array[Byte] = []
  let sx = img.width.to_double() / target_width.to_double()
  let sy = img.height.to_double() / target_height.to_double()
  for oy in 0..<target_height {
    for ox in 0..<target_width {
      let ix = (ox.to_double() * sx).to_int().clamp(min=0, max=img.width - 1)
      let iy = (oy.to_double() * sy).to_int().clamp(min=0, max=img.height - 1)
      for c in 0..<ch {
        data.push(img.data[(iy * img.width + ix) * ch + c])
      }
    }
  }
  {
    width: target_width,
    height: target_height,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
/// 裁剪图像。
/// Crop image to target size.
pub fn crop_image(
  img : @types.Image,
  target_width : Int32,
  target_height : Int32,
) -> @types.Image {
  if target_width <= 0 || target_height <= 0 {
    return img
  }
  let ch = img.channels
  let x0 = (img.width - target_width) / 2
  let y0 = (img.height - target_height) / 2
  let data : Array[Byte] = []
  for y in 0..<target_height {
    for x in 0..<target_width {
      let sx = (x0 + x).clamp(min=0, max=img.width - 1)
      let sy = (y0 + y).clamp(min=0, max=img.height - 1)
      for c in 0..<ch {
        data.push(img.data[(sy * img.width + sx) * ch + c])
      }
    }
  }
  {
    width: target_width,
    height: target_height,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
/// 填充图像到目标尺寸。
/// Pad image to target size.
pub fn pad_image(
  img : @types.Image,
  target_width : Int32,
  target_height : Int32,
  fill : Byte,
) -> @types.Image {
  if target_width <= 0 || target_height <= 0 {
    return img
  }
  let ch = img.channels
  let data : Array[Byte] = []
  let x0 = (target_width - img.width) / 2
  let y0 = (target_height - img.height) / 2
  for y in 0..<target_height {
    for x in 0..<target_width {
      let sx = x - x0
      let sy = y - y0
      for c in 0..<ch {
        if sx >= 0 && sx < img.width && sy >= 0 && sy < img.height {
          data.push(img.data[(sy * img.width + sx) * ch + c])
        } else {
          data.push(fill)
        }
      }
    }
  }
  {
    width: target_width,
    height: target_height,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
/// 调整分辨率。
/// Adjust resolution.
pub fn resize_image(
  img : @types.Image,
  target_width : Int32,
  target_height : Int32,
  mode : ResolutionMode,
) -> @types.Image {
  match mode {
    Scale => scale_image(img, target_width, target_height)
    Crop => crop_image(img, target_width, target_height)
    Pad => pad_image(img, target_width, target_height, (0 : Byte))
  }
}

///|
/// 计算估计码率。
/// Compute estimated bitrate.
pub fn compute_bitrate(
  width : Int32,
  height : Int32,
  fps : Int32,
  crf : Int32,
) -> Int32 {
  // 简化估算：码率 ∝ 宽×高×帧率 / (CRF因子)
  let pixels = width.to_double() * height.to_double()
  let crf_factor = crf.to_double() / 51.0 * 10.0 + 1.0
  let bitrate = pixels * fps.to_double() * 0.01 / crf_factor
  (bitrate / 1000.0).to_int()
}

///|
/// 估计质量分数。
/// Estimate quality score (0-100).
pub fn estimate_quality(crf : Int32, bitrate : Int32) -> Double {
  let crf_score = (51 - crf).to_double() / 51.0 * 50.0
  let bitrate_score = (bitrate.to_double() / 5000.0).clamp(min=0.0, max=1.0) *
    50.0
  (crf_score + bitrate_score).clamp(min=0.0, max=100.0)
}

///|
/// 转码视频。
/// Transcode video.
pub fn transcode_video(
  frames : Array[@types.Image],
  params : TranscodeParams,
) -> TranscodeResult {
  if frames.length() == 0 {
    return {
      frames: [],
      format: params.target_format,
      width: params.target_width,
      height: params.target_height,
      bitrate: 0,
      fps: params.fps,
      size_bytes: 0,
    }
  }
  let transcoded : Array[@types.Image] = []
  for frame in frames {
    transcoded.push(
      resize_image(
        frame,
        params.target_width,
        params.target_height,
        params.resolution_mode,
      ),
    )
  }
  let bitrate = match params.bitrate_mode {
    CBR => params.target_bitrate
    VBR => params.target_bitrate * 9 / 10
    CRF =>
      compute_bitrate(
        params.target_width,
        params.target_height,
        params.fps,
        params.crf,
      )
  }
  let mut size = 0
  for frame in transcoded {
    size = size + frame.data.length()
  }
  // 格式压缩比估算
  let compression = match params.target_format {
    Raw => 1.0
    MPEG => 0.3
    H264 => 0.2
    VP9 => 0.15
    AV1 => 0.1
  }
  let compressed_size = (size.to_double() * compression).to_int()
  {
    frames: transcoded,
    format: params.target_format,
    width: params.target_width,
    height: params.target_height,
    bitrate,
    fps: params.fps,
    size_bytes: compressed_size,
  }
}

///|
/// 调整视频帧率。
/// Adjust video framerate.
pub fn adjust_framerate(
  frames : Array[@types.Image],
  source_fps : Int32,
  target_fps : Int32,
) -> Array[@types.Image] {
  if source_fps <= 0 || target_fps <= 0 {
    return frames
  }
  if target_fps == source_fps {
    return frames
  }
  if target_fps > source_fps {
    // 帧率提升：重复帧
    let ratio = target_fps / source_fps
    let result : Array[@types.Image] = []
    for frame in frames {
      for _ in 0..<ratio {
        result.push(frame)
      }
    }
    result
  } else {
    // 帧率降低：跳帧
    let ratio = source_fps / target_fps
    let result : Array[@types.Image] = []
    let n = frames.length()
    let mut i = 0
    while i < n {
      result.push(frames[i])
      i = i + ratio
    }
    result
  }
}

///|
/// 计算视频时长（秒）。
/// Compute video duration in seconds.
pub fn compute_duration(frame_count : Int32, fps : Int32) -> Double {
  if fps <= 0 {
    return 0.0
  }
  frame_count.to_double() / fps.to_double()
}

///|
/// 计算压缩比。
/// Compute compression ratio.
pub fn transcode_compression_ratio(
  original_size : Int32,
  transcoded_size : Int32,
) -> Double {
  if transcoded_size <= 0 {
    return 0.0
  }
  original_size.to_double() / transcoded_size.to_double()
}
