///|
test "FrameType: 枚举值" {
  assert_true(@video.IFrame is @video.IFrame)
  assert_true(@video.PFrame is @video.PFrame)
  assert_true(@video.BFrame is @video.BFrame)
}

///|
test "VideoCodecParams: 构造与字段" {
  let p : @video.VideoCodecParams = {
    qp: 5,
    block_size: 4,
    search_range: 2,
    iframe_interval: 5,
  }
  assert_eq(p.qp, 5)
  assert_eq(p.block_size, 4)
  assert_eq(p.search_range, 2)
  assert_eq(p.iframe_interval, 5)
}

///|
test "default_video_codec_params: 默认值" {
  let p = @video.default_video_codec_params()
  assert_eq(p.qp, 10)
  assert_eq(p.block_size, 8)
  assert_eq(p.search_range, 8)
  assert_eq(p.iframe_interval, 10)
}

///|
test "rle_encode / rle_decode: 往返" {
  let data = [10, 10, 10, 20, 20, 30, 30, 30, 30]
  let encoded = @video.rle_encode(data)
  let decoded = @video.rle_decode(encoded)
  assert_eq(decoded, data)
}

///|
test "rle_encode: 空数组" {
  let encoded = @video.rle_encode([])
  assert_eq(encoded.length(), 0)
  let decoded = @video.rle_decode(encoded)
  assert_eq(decoded.length(), 0)
}

///|
test "rle_encode: 单元素" {
  let encoded = @video.rle_encode([42])
  let decoded = @video.rle_decode(encoded)
  assert_eq(decoded, [42])
}

///|
test "quantize / dequantize: 往返" {
  let values = [100, 200, 50, 150, 250]
  let qp = 10
  let quantized = @video.quantize(values, qp)
  let dequantized = @video.dequantize(quantized, qp)
  // 量化有误差，但应在 qp 范围内
  for i in 0..<values.length() {
    assert_true((values[i] - dequantized[i]).abs() <= qp)
  }
}

///|
test "quantize: qp 为零返回原值" {
  let values = [100, 200, 50]
  let result = @video.quantize(values, 0)
  assert_eq(result, values)
}

///|
test "encode_frame_intra / decode_frame_intra: 往返" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let params = @video.default_video_codec_params()
  let encoded = @video.encode_frame_intra(img, params)
  assert_true(encoded.frame_type is @video.IFrame)
  assert_eq(encoded.width, 2)
  assert_eq(encoded.height, 2)
  assert_eq(encoded.channels, 1)
  let decoded = @video.decode_frame_intra(encoded)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.channels, 1)
}

///|
test "encode_frame_inter: 运动矢量" {
  let ref_img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    ]),
  }
  let cur_img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10,
    ]),
  }
  let params = @video.default_video_codec_params()
  let encoded = @video.encode_frame_inter(cur_img, ref_img, params)
  assert_true(encoded.frame_type is @video.PFrame)
  assert_eq(encoded.width, 4)
  assert_eq(encoded.height, 4)
}

///|
test "compute_motion_vectors: 相同帧零矢量" {
  let img : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
      50, 50, 50, 50, 50, 50, 50, 50, 50,
    ]),
  }
  let vectors = @video.compute_motion_vectors(img, img, 4)
  // 相同帧的运动矢量应全为零
  for v in vectors {
    assert_eq(v, 0)
  }
}

///|
test "encode_video / decode_video: 往返" {
  let frame1 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([60, 60, 60, 60]),
  }
  let frame3 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([70, 70, 70, 70]),
  }
  let frames = [frame1, frame2, frame3]
  let params : @video.VideoCodecParams = {
    qp: 1,
    block_size: 8,
    search_range: 4,
    iframe_interval: 2,
  }
  let encoded = @video.encode_video(frames, params)
  assert_eq(encoded.frames.length(), 3)
  assert_eq(encoded.width, 2)
  assert_eq(encoded.height, 2)
  assert_eq(encoded.channels, 1)
  // 第一帧应为 I 帧
  assert_true(encoded.frames[0].frame_type is @video.IFrame)
  // 第二帧应为 P 帧（iframe_interval=2）
  assert_true(encoded.frames[1].frame_type is @video.PFrame)
  // 第三帧应为 I 帧（iframe_interval=2）
  assert_true(encoded.frames[2].frame_type is @video.IFrame)
  let decoded = @video.decode_video(encoded)
  assert_eq(decoded.length(), 3)
}

///|
test "encode_video: 空视频" {
  let frames : Array[@types.Image] = []
  let params = @video.default_video_codec_params()
  let encoded = @video.encode_video(frames, params)
  assert_eq(encoded.frames.length(), 0)
  assert_eq(encoded.width, 0)
  assert_eq(encoded.height, 0)
}

///|
test "compute_compression_ratio: 基本计算" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let frames = [img]
  let params = @video.default_video_codec_params()
  let encoded = @video.encode_video(frames, params)
  let ratio = @video.compute_compression_ratio(frames, encoded)
  assert_true(ratio > 0.0)
}

///|
test "EncodedFrame: 构造与字段" {
  let frame : @video.EncodedFrame = {
    frame_type: @video.IFrame,
    data: Bytes::from_array([1, 2, 3]),
    motion_vectors: [0, 0, 1, 1],
    width: 2,
    height: 2,
    channels: 1,
  }
  assert_true(frame.frame_type is @video.IFrame)
  assert_eq(frame.data.length(), 3)
  assert_eq(frame.motion_vectors.length(), 4)
  assert_eq(frame.width, 2)
  assert_eq(frame.height, 2)
  assert_eq(frame.channels, 1)
}
