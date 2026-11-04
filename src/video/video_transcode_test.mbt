///|
test "VideoFormat: 枚举值" {
  assert_true(@video.Raw is @video.Raw)
  assert_true(@video.MPEG is @video.MPEG)
  assert_true(@video.H264 is @video.H264)
  assert_true(@video.VP9 is @video.VP9)
  assert_true(@video.AV1 is @video.AV1)
}

///|
test "ResolutionMode: 枚举值" {
  assert_true(@video.Scale is @video.Scale)
  assert_true(@video.Crop is @video.Crop)
  assert_true(@video.Pad is @video.Pad)
}

///|
test "BitrateMode: 枚举值" {
  assert_true(@video.CBR is @video.CBR)
  assert_true(@video.VBR is @video.VBR)
  assert_true(@video.CRF is @video.CRF)
}

///|
test "TranscodeParams: 构造与字段" {
  let p : @video.TranscodeParams = {
    target_format: @video.H264,
    target_width: 640,
    target_height: 480,
    resolution_mode: @video.Scale,
    bitrate_mode: @video.CBR,
    target_bitrate: 1000,
    crf: 20,
    fps: 24,
  }
  assert_eq(p.target_width, 640)
  assert_eq(p.target_height, 480)
  assert_eq(p.target_bitrate, 1000)
  assert_eq(p.crf, 20)
  assert_eq(p.fps, 24)
  assert_true(p.target_format is @video.H264)
  assert_true(p.resolution_mode is @video.Scale)
  assert_true(p.bitrate_mode is @video.CBR)
}

///|
test "default_transcode_params: 默认值" {
  let p = @video.default_transcode_params()
  assert_eq(p.target_width, 1280)
  assert_eq(p.target_height, 720)
  assert_eq(p.crf, 23)
  assert_eq(p.fps, 30)
  assert_true(p.target_format is @video.H264)
  assert_true(p.resolution_mode is @video.Scale)
  assert_true(p.bitrate_mode is @video.CRF)
}

///|
test "scale_image: 基本缩放" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @video.scale_image(img, 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.channels, 1)
}

///|
test "scale_image: 同尺寸返回相同" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 20, 30, 40]),
  }
  let result = @video.scale_image(img, 2, 2)
  assert_eq(result.data[0], 10)
  assert_eq(result.data[1], 20)
  assert_eq(result.data[2], 30)
  assert_eq(result.data[3], 40)
}

///|
test "crop_image: 基本裁剪" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @video.crop_image(img, 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "pad_image: 基本填充" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let result = @video.pad_image(img, 4, 4, (0 : Byte))
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  // 角落应为填充值
  assert_eq(result.data[0], 0)
  // 中心应为原图值
  assert_eq(result.data[5], 100)
}

///|
test "resize_image: 缩放模式" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 50)),
  }
  let result = @video.resize_image(img, 2, 2, @video.Scale)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "resize_image: 裁剪模式" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 50)),
  }
  let result = @video.resize_image(img, 2, 2, @video.Crop)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "resize_image: 填充模式" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let result = @video.resize_image(img, 4, 4, @video.Pad)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "compute_bitrate: 基本计算" {
  let br = @video.compute_bitrate(1920, 1080, 30, 23)
  assert_true(br > 0)
}

///|
test "compute_bitrate: 高 CRF 低码率" {
  let br_low = @video.compute_bitrate(640, 480, 30, 40)
  let br_high = @video.compute_bitrate(640, 480, 30, 10)
  assert_true(br_high > br_low)
}

///|
test "estimate_quality: CRF 影响" {
  let q_low = @video.estimate_quality(45, 500)
  let q_high = @video.estimate_quality(10, 500)
  assert_true(q_high > q_low)
}

///|
test "estimate_quality: 范围 0-100" {
  let q1 = @video.estimate_quality(0, 0)
  let q2 = @video.estimate_quality(51, 10000)
  assert_true(q1 >= 0.0 && q1 <= 100.0)
  assert_true(q2 >= 0.0 && q2 <= 100.0)
}

///|
test "transcode_video: 基本转码" {
  let frame : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let frames = [frame, frame, frame]
  let params : @video.TranscodeParams = {
    target_format: @video.H264,
    target_width: 640,
    target_height: 480,
    resolution_mode: @video.Scale,
    bitrate_mode: @video.CRF,
    target_bitrate: 1000,
    crf: 23,
    fps: 30,
  }
  let result = @video.transcode_video(frames, params)
  assert_eq(result.frames.length(), 3)
  assert_eq(result.width, 640)
  assert_eq(result.height, 480)
  assert_true(result.bitrate > 0)
  assert_true(result.size_bytes > 0)
}

///|
test "transcode_video: 空视频" {
  let frames : Array[@types.Image] = []
  let params = @video.default_transcode_params()
  let result = @video.transcode_video(frames, params)
  assert_eq(result.frames.length(), 0)
  assert_eq(result.bitrate, 0)
}

///|
test "transcode_video: CBR 码率" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let frames = [frame]
  let params : @video.TranscodeParams = {
    target_format: @video.MPEG,
    target_width: 2,
    target_height: 2,
    resolution_mode: @video.Scale,
    bitrate_mode: @video.CBR,
    target_bitrate: 2000,
    crf: 23,
    fps: 30,
  }
  let result = @video.transcode_video(frames, params)
  assert_eq(result.bitrate, 2000)
}

///|
test "adjust_framerate: 同帧率" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame, frame]
  let result = @video.adjust_framerate(frames, 30, 30)
  assert_eq(result.length(), 3)
}

///|
test "adjust_framerate: 降低帧率" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame, frame, frame]
  let result = @video.adjust_framerate(frames, 30, 15)
  assert_eq(result.length(), 2)
}

///|
test "adjust_framerate: 提升帧率" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame]
  let result = @video.adjust_framerate(frames, 15, 30)
  assert_eq(result.length(), 4)
}

///|
test "compute_duration: 基本计算" {
  let dur = @video.compute_duration(30, 30)
  assert_eq(dur, 1.0)
}

///|
test "compute_duration: 零帧率" {
  let dur = @video.compute_duration(100, 0)
  assert_eq(dur, 0.0)
}

///|
test "transcode_compression_ratio: 基本计算" {
  let ratio = @video.transcode_compression_ratio(1000, 200)
  assert_eq(ratio, 5.0)
}

///|
test "transcode_compression_ratio: 零大小" {
  let ratio = @video.transcode_compression_ratio(1000, 0)
  assert_eq(ratio, 0.0)
}

///|
test "TranscodeResult: 构造与字段" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let result : @video.TranscodeResult = {
    frames: [frame],
    format: @video.AV1,
    width: 2,
    height: 2,
    bitrate: 500,
    fps: 24,
    size_bytes: 100,
  }
  assert_eq(result.bitrate, 500)
  assert_eq(result.fps, 24)
  assert_eq(result.size_bytes, 100)
  assert_true(result.format is @video.AV1)
}
