///|
test "VideoSRMethod: 枚举值" {
  assert_true(@video.BicubicSR is @video.BicubicSR)
  assert_true(@video.SpatioTemporal is @video.SpatioTemporal)
  assert_true(@video.RecursiveSR is @video.RecursiveSR)
}

///|
test "VideoSRConfig: 构造与字段" {
  let config : @video.VideoSRConfig = {
    sr_method: @video.SpatioTemporal,
    scale_factor: 4,
    temporal_window: 5,
    blend_factor: 0.6,
  }
  assert_eq(config.scale_factor, 4)
  assert_eq(config.temporal_window, 5)
  assert_eq(config.blend_factor, 0.6)
  assert_true(config.sr_method is @video.SpatioTemporal)
}

///|
test "default_sr_config: 默认值" {
  let config = @video.default_sr_config()
  assert_eq(config.scale_factor, 2)
  assert_eq(config.temporal_window, 3)
  assert_eq(config.blend_factor, 0.5)
  assert_true(config.sr_method is @video.BicubicSR)
}

///|
test "bicubic_super_resolve: 2x 放大" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let config = @video.default_sr_config()
  let result = @video.bicubic_super_resolve([img], config)
  assert_eq(result.length(), 1)
  assert_eq(result[0].width, 4)
  assert_eq(result[0].height, 4)
}

///|
test "bicubic_super_resolve: 多帧" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config = @video.default_sr_config()
  let result = @video.bicubic_super_resolve([img, img, img], config)
  assert_eq(result.length(), 3)
  assert_eq(result[0].width, 2)
}

///|
test "spatio_temporal_sr: 利用时域信息" {
  let frame1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let frame2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([120]),
  }
  let frame3 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([110]),
  }
  let config = @video.default_sr_config()
  let result = @video.spatio_temporal_sr([frame1, frame2, frame3], config)
  assert_eq(result.length(), 3)
  assert_eq(result[0].width, 2)
  assert_eq(result[0].height, 2)
}

///|
test "spatio_temporal_sr: 空帧" {
  let config = @video.default_sr_config()
  let result = @video.spatio_temporal_sr([], config)
  assert_eq(result.length(), 0)
}

///|
test "recursive_sr: 4x 递归" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config : @video.VideoSRConfig = {
    sr_method: @video.RecursiveSR,
    scale_factor: 4,
    temporal_window: 3,
    blend_factor: 0.5,
  }
  let result = @video.recursive_sr([img], config)
  assert_eq(result.length(), 1)
  assert_eq(result[0].width, 4)
  assert_eq(result[0].height, 4)
}

///|
test "recursive_sr: scale=1 不放大" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let config : @video.VideoSRConfig = {
    sr_method: @video.RecursiveSR,
    scale_factor: 1,
    temporal_window: 3,
    blend_factor: 0.5,
  }
  let result = @video.recursive_sr([img], config)
  assert_eq(result.length(), 1)
  assert_eq(result[0].width, 2)
}

///|
test "video_super_resolve: BicubicSR 方法" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let config = @video.default_sr_config()
  let result = @video.video_super_resolve([img], config)
  assert_eq(result.frames.length(), 1)
  assert_eq(result.scale_factor, 2)
  assert_true(result.quality_score >= 0.0)
  assert_true(result.quality_score <= 1.0)
}

///|
test "video_super_resolve: SpatioTemporal 方法" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config : @video.VideoSRConfig = {
    sr_method: @video.SpatioTemporal,
    scale_factor: 2,
    temporal_window: 3,
    blend_factor: 0.5,
  }
  let result = @video.video_super_resolve([img, img, img], config)
  assert_eq(result.frames.length(), 3)
  assert_eq(result.scale_factor, 2)
}

///|
test "video_super_resolve: RecursiveSR 方法" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config : @video.VideoSRConfig = {
    sr_method: @video.RecursiveSR,
    scale_factor: 4,
    temporal_window: 3,
    blend_factor: 0.5,
  }
  let result = @video.video_super_resolve([img], config)
  assert_eq(result.frames.length(), 1)
  assert_eq(result.frames[0].width, 4)
}

///|
test "compute_sr_quality: 完美一致性" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let sr : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let quality = @video.compute_sr_quality([img], [sr], 2)
  // 完美一致时质量分数应接近 1.0
  assert_true(quality > 0.99)
}

///|
test "compute_sr_quality: 空帧" {
  let quality = @video.compute_sr_quality([], [], 2)
  assert_eq(quality, 0.0)
}

///|
test "sr_pipeline: 完整流水线" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 50, 200]),
  }
  let config = @video.default_sr_config()
  let result = @video.sr_pipeline([img, img], config)
  assert_eq(result.frames.length(), 2)
  assert_eq(result.scale_factor, 2)
}

///|
test "VideoSRResult: 构造与字段" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let result : @video.VideoSRResult = {
    frames: [img],
    scale_factor: 2,
    quality_score: 0.95,
  }
  assert_eq(result.frames.length(), 1)
  assert_eq(result.scale_factor, 2)
  assert_eq(result.quality_score, 0.95)
}
