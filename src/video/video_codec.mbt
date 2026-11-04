// 视频编解码 — 帧内/帧间/熵编码
// Video codec: intra-frame / inter-frame / entropy coding
//
// Phase 17 v392: 视频处理大扩展 — 视频编解码。

///|
/// 帧类型。
/// Frame type.
pub(all) enum FrameType {
  IFrame // 帧内编码
  PFrame // 前向预测
  BFrame // 双向预测
} derive(Eq, @debug.Debug)

///|
pub extend FrameType with @debug.Debug::{to_repr}

///|
pub extend FrameType with Eq::{not_equal, equal}

///|
/// 编码参数。
/// Codec parameters.
pub(all) struct VideoCodecParams {
  qp : Int32 // 量化参数 (1-50)
  block_size : Int32 // 块大小 (通常 8 或 16)
  search_range : Int32 // 运动搜索范围
  iframe_interval : Int32 // I 帧间隔
} derive(Eq, @debug.Debug)

///|
pub extend VideoCodecParams with @debug.Debug::{to_repr}

///|
pub extend VideoCodecParams with Eq::{not_equal, equal}

///|
/// 编码帧。
/// Encoded frame.
pub(all) struct EncodedFrame {
  frame_type : FrameType
  data : Bytes // 压缩数据
  motion_vectors : Array[Int32] // 运动矢量 (dx, dy 交替)
  width : Int32
  height : Int32
  channels : Int32
} derive(Eq, @debug.Debug)

///|
pub extend EncodedFrame with @debug.Debug::{to_repr}

///|
pub extend EncodedFrame with Eq::{not_equal, equal}

///|
/// 编码视频。
/// Encoded video.
pub(all) struct EncodedVideo {
  frames : Array[EncodedFrame]
  params : VideoCodecParams
  width : Int32
  height : Int32
  channels : Int32
} derive(Eq, @debug.Debug)

///|
pub extend EncodedVideo with @debug.Debug::{to_repr}

///|
pub extend EncodedVideo with Eq::{not_equal, equal}

///|
/// 默认编码参数。
/// Default codec parameters.
pub fn default_video_codec_params() -> VideoCodecParams {
  { qp: 10, block_size: 8, search_range: 8, iframe_interval: 10, }
}

///|
/// 游程编码 (RLE)。
/// Run-length encoding.
pub fn rle_encode(data : Array[Int32]) -> Bytes {
  let result : Array[Byte] = []
  let n = data.length()
  if n == 0 {
    return Bytes::from_array(result)
  }
  let mut i = 0
  while i < n {
    let val = data[i]
    let mut run = 1
    while i + run < n && data[i + run] == val && run < 255 {
      run = run + 1
    }
    result.push(run.to_byte())
    result.push(val.clamp(min=0, max=255).to_byte())
    i = i + run
  }
  Bytes::from_array(result)
}

///|
/// 游程解码 (RLE)。
/// Run-length decoding.
pub fn rle_decode(data : Bytes) -> Array[Int32] {
  let result : Array[Int32] = []
  let n = data.length()
  let mut i = 0
  while i + 1 < n {
    let run = data[i].to_int()
    let val = data[i + 1].to_int()
    for _ in 0..<run {
      result.push(val)
    }
    i = i + 2
  }
  result
}

///|
/// 量化。
/// Quantization.
pub fn quantize(values : Array[Int32], qp : Int32) -> Array[Int32] {
  if qp <= 0 {
    return values
  }
  let q = qp
  let result : Array[Int32] = []
  for v in values {
    result.push((v + q / 2) / q)
  }
  result
}

///|
/// 反量化。
/// Dequantization.
pub fn dequantize(values : Array[Int32], qp : Int32) -> Array[Int32] {
  if qp <= 0 {
    return values
  }
  let result : Array[Int32] = []
  for v in values {
    result.push(v * qp)
  }
  result
}

///|
/// 帧内编码：将图像转为像素数组 + RLE 压缩。
/// Intra-frame encoding: pixel array + RLE compression.
pub fn encode_frame_intra(
  img : @types.Image,
  params : VideoCodecParams,
) -> EncodedFrame {
  let pixels : Array[Int32] = []
  for i in 0..<img.data.length() {
    pixels.push(img.data[i].to_int())
  }
  let quantized = quantize(pixels, params.qp)
  let compressed = rle_encode(quantized)
  {
    frame_type: IFrame,
    data: compressed,
    motion_vectors: [],
    width: img.width,
    height: img.height,
    channels: img.channels,
  }
}

///|
/// 帧内解码。
/// Intra-frame decoding.
pub fn decode_frame_intra(frame : EncodedFrame) -> @types.Image {
  let quantized = rle_decode(frame.data)
  let pixels = dequantize(
    quantized,
    frame.width * frame.height * frame.channels,
  )
  let data : Array[Byte] = []
  let n = pixels.length()
  for i in 0..<(frame.width * frame.height * frame.channels) {
    if i < n {
      data.push(pixels[i].clamp(min=0, max=255).to_byte())
    } else {
      data.push((0 : Byte))
    }
  }
  {
    width: frame.width,
    height: frame.height,
    channels: frame.channels,
    data: Bytes::from_array(data),
  }
}

///|
/// 计算运动矢量（简化块匹配）。
/// Compute motion vectors (simplified block matching).
pub fn compute_motion_vectors(
  current : @types.Image,
  reference : @types.Image,
  search_range : Int32,
) -> Array[Int32] {
  let vectors : Array[Int32] = []
  let w = current.width
  let h = current.height
  let ch = current.channels
  let block = 8
  let mut by = 0
  while by < h {
    let mut bx = 0
    while bx < w {
      let mut best_dx = 0
      let mut best_dy = 0
      let mut best_sad = 999999999.0
      for dy in [0, -search_range, search_range] {
        for dx in [0, -search_range, search_range] {
          let mut sad = 0.0
          for py in 0..<block {
            for px in 0..<block {
              let cx = bx + px
              let cy = by + py
              if cx >= w || cy >= h {
                continue
              }
              let rx = cx + dx
              let ry = cy + dy
              if rx < 0 || rx >= w || ry < 0 || ry >= h {
                continue
              }
              let ci = (cy * w + cx) * ch
              let ri = (ry * w + rx) * ch
              let diff = current.data[ci].to_int() - reference.data[ri].to_int()
              sad = sad + diff.to_double().abs()
            }
          }
          if sad < best_sad {
            best_sad = sad
            best_dx = dx
            best_dy = dy
          }
        }
      }
      vectors.push(best_dx)
      vectors.push(best_dy)
      bx = bx + block
    }
    by = by + block
  }
  vectors
}

///|
/// 帧间编码：运动估计 + 残差编码。
/// Inter-frame encoding: motion estimation + residual coding.
pub fn encode_frame_inter(
  current : @types.Image,
  reference : @types.Image,
  params : VideoCodecParams,
) -> EncodedFrame {
  let vectors = compute_motion_vectors(current, reference, params.search_range)
  // 残差 = 当前帧 - 运动补偿参考帧
  let residuals : Array[Int32] = []
  let w = current.width
  let h = current.height
  let ch = current.channels
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let ci = (y * w + x) * ch + c
        let cur = current.data[ci].to_int()
        let ref_val = reference.data[ci].to_int()
        residuals.push(cur - ref_val + 128)
      }
    }
  }
  let quantized = quantize(residuals, params.qp)
  let compressed = rle_encode(quantized)
  {
    frame_type: PFrame,
    data: compressed,
    motion_vectors: vectors,
    width: w,
    height: h,
    channels: ch,
  }
}

///|
/// 帧间解码：运动补偿 + 残差。
/// Inter-frame decoding: motion compensation + residual.
pub fn decode_frame_inter(
  frame : EncodedFrame,
  reference : @types.Image,
) -> @types.Image {
  let quantized = rle_decode(frame.data)
  let residuals = dequantize(
    quantized,
    frame.width * frame.height * frame.channels,
  )
  let data : Array[Byte] = []
  let w = frame.width
  let h = frame.height
  let ch = frame.channels
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let i = (y * w + x) * ch + c
        let ref_val = reference.data[i].to_int()
        let res = if i < residuals.length() { residuals[i] - 128 } else { 0 }
        let val = ref_val + res
        data.push(val.clamp(min=0, max=255).to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 视频编码流水线。
/// Video encoding pipeline.
pub fn encode_video(
  frames : Array[@types.Image],
  params : VideoCodecParams,
) -> EncodedVideo {
  let encoded : Array[EncodedFrame] = []
  let n = frames.length()
  if n == 0 {
    return { frames: encoded, params, width: 0, height: 0, channels: 0, }
  }
  let w = frames[0].width
  let h = frames[0].height
  let ch = frames[0].channels
  for i in 0..<n {
    if i % params.iframe_interval == 0 || i == 0 {
      encoded.push(encode_frame_intra(frames[i], params))
    } else {
      encoded.push(encode_frame_inter(frames[i], frames[i - 1], params))
    }
  }
  { frames: encoded, params, width: w, height: h, channels: ch, }
}

///|
/// 视频解码流水线。
/// Video decoding pipeline.
pub fn decode_video(encoded : EncodedVideo) -> Array[@types.Image] {
  let frames : Array[@types.Image] = []
  let n = encoded.frames.length()
  for i in 0..<n {
    let frame = encoded.frames[i]
    if frame.frame_type is IFrame {
      frames.push(decode_frame_intra(frame))
    } else if i > 0 {
      let prev = decode_frame_intra(encoded.frames[i - 1])
      frames.push(decode_frame_inter(frame, prev))
    } else {
      frames.push(decode_frame_intra(frame))
    }
  }
  frames
}

///|
/// 计算压缩比。
/// Compute compression ratio.
pub fn compute_compression_ratio(
  original : Array[@types.Image],
  encoded : EncodedVideo,
) -> Double {
  let mut original_size = 0
  for img in original {
    original_size = original_size + img.data.length()
  }
  let mut encoded_size = 0
  for frame in encoded.frames {
    encoded_size = encoded_size + frame.data.length()
  }
  if encoded_size == 0 {
    return 0.0
  }
  original_size.to_double() / encoded_size.to_double()
}
