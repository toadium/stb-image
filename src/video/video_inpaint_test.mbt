///|
test "VideoInpaintMethod: 枚举值" {
  assert_true(@video.Temporal is @video.Temporal)
  assert_true(@video.Spatial is @video.Spatial)
  assert_true(@video.Hybrid is @video.Hybrid)
}

///|
test "FlickerMethod: 枚举值" {
  assert_true(@video.TemporalFlicker is @video.TemporalFlicker)
  assert_true(@video.HistogramFlicker is @video.HistogramFlicker)
  assert_true(@video.LuminanceFlicker is @video.LuminanceFlicker)
}

///|
test "VideoInpaintConfig: 构造与字段" {
  let config : @video.VideoInpaintConfig = {
    inpaint_method: @video.Spatial,
    temporal_radius: 5,
    spatial_radius: 7,
    blend_factor: 0.7,
  }
  assert_eq(config.temporal_radius, 5)
  assert_eq(config.spatial_radius, 7)
  assert_eq(config.blend_factor, 0.7)
  assert_true(config.inpaint_method is @video.Spatial)
}

///|
test "FlickerConfig: 构造与字段" {
  let config : @video.FlickerConfig = {
    flicker_method: @video.HistogramFlicker,
    temporal_window: 7,
    strength: 0.9,
  }
  assert_eq(config.temporal_window, 7)
  assert_eq(config.strength, 0.9)
  assert_true(config.flicker_method is @video.HistogramFlicker)
}

///|
test "default_inpaint_config: 默认值" {
  let config = @video.default_inpaint_config()
  assert_eq(config.temporal_radius, 3)
  assert_eq(config.spatial_radius, 5)
  assert_eq(config.blend_factor, 0.5)
  assert_true(config.inpaint_method is @video.Temporal)
}

///|
test "default_flicker_config: 默认值" {
  let config = @video.default_flicker_config()
  assert_eq(config.temporal_window, 5)
  assert_eq(config.strength, 0.8)
  assert_true(config.flicker_method is @video.TemporalFlicker)
}

///|
test "temporal_inpaint: 填补掩码区域" {
  let curr : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0]),
  }
  let prev : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 50]),
  }
  let next : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([120, 60]),
  }
  let mask = [true, false]
  let config = @video.default_inpaint_config()
  let result = @video.temporal_inpaint(curr, prev, next, mask, config)
  // 掩码区域应被修复（非0）
  assert_true(result.data[0].to_int() > 0)
  // 非掩码区域保持不变
  assert_eq(result.data[1].to_int(), 0)
}

///|
test "spatial_inpaint: 用周围像素填补" {
  let img : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 0, 200]),
  }
  let mask = [false, true, false]
  let config : @video.VideoInpaintConfig = {
    inpaint_method: @video.Spatial,
    temporal_radius: 1,
    spatial_radius: 1,
    blend_factor: 0.5,
  }
  let result = @video.spatial_inpaint(img, mask, config)
  // 中间像素应被周围像素修复
  assert_true(result.data[1].to_int() > 0)
  // 两端保持不变
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[2].to_int(), 200)
}

///|
test "video_inpaint: Temporal 方法" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 50]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 50]),
  }
  let frame3 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 50]),
  }
  let mask = [true, false]
  let config = @video.default_inpaint_config()
  let result = @video.video_inpaint([frame1, frame2, frame3], mask, config)
  assert_eq(result.length(), 3)
  // 中间帧的掩码区域应被修复
  assert_true(result[1].data[0].to_int() > 0)
}

///|
test "video_inpaint: Spatial 方法" {
  let img : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 0, 200]),
  }
  let mask = [false, true, false]
  let config : @video.VideoInpaintConfig = {
    inpaint_method: @video.Spatial,
    temporal_radius: 1,
    spatial_radius: 1,
    blend_factor: 0.5,
  }
  let result = @video.video_inpaint([img], mask, config)
  assert_eq(result.length(), 1)
  assert_true(result[0].data[1].to_int() > 0)
}

///|
test "detect_flicker: 无闪烁" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let detection = @video.detect_flicker([img, img, img], 50.0)
  assert_true(!detection.has_flicker)
  assert_eq(detection.frame_indices.length(), 0)
}

///|
test "detect_flicker: 有闪烁" {
  let dark : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 10, 10, 10]),
  }
  let bright : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([200, 200, 200, 200]),
  }
  let detection = @video.detect_flicker([dark, bright, dark, bright], 50.0)
  assert_true(detection.has_flicker)
  assert_true(detection.flicker_score > 0.0)
  assert_true(detection.frame_indices.length() > 0)
}

///|
test "deflicker_temporal: 平滑亮度" {
  let dark : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([10]),
  }
  let bright : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_flicker_config()
  let result = @video.deflicker_temporal([dark, bright, dark], config)
  assert_eq(result.length(), 3)
  // 中间帧亮度应被平滑（降低）
  assert_true(result[1].data[0].to_int() < 200)
}

///|
test "deflicker_luminance: 归一化亮度" {
  let dark : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let bright : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_flicker_config()
  let result = @video.deflicker_luminance([dark, bright], config)
  assert_eq(result.length(), 2)
  // 两帧亮度应趋近
  let diff_after = (result[0].data[0].to_int() - result[1].data[0].to_int()).abs()
  let diff_before = (50 - 200).abs()
  assert_true(diff_after < diff_before)
}

///|
test "video_deflicker: TemporalFlicker 方法" {
  let dark : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([10]),
  }
  let bright : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_flicker_config()
  let result = @video.video_deflicker([dark, bright, dark], config)
  assert_eq(result.length(), 3)
}

///|
test "video_deflicker: LuminanceFlicker 方法" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config : @video.FlickerConfig = {
    flicker_method: @video.LuminanceFlicker,
    temporal_window: 3,
    strength: 0.5,
  }
  let result = @video.video_deflicker([img, img, img], config)
  assert_eq(result.length(), 3)
}

///|
test "deshimmer: 减少抖动" {
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
  let result = @video.deshimmer([frame1, frame2, frame3], 0.3)
  assert_eq(result.length(), 3)
  // 第一帧不变
  assert_eq(result[0].data[0].to_int(), 100)
  // 后续帧被平滑
  assert_true(result[1].data[0].to_int() < 120)
}

///|
test "inpaint_pipeline: 完整流水线" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 50]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 50]),
  }
  let frame3 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 50]),
  }
  let mask = [true, false]
  let inpaint_config = @video.default_inpaint_config()
  let flicker_config = @video.default_flicker_config()
  let result = @video.inpaint_pipeline(
    [frame1, frame2, frame3],
    mask,
    inpaint_config,
    flicker_config,
    0.2,
  )
  assert_eq(result.length(), 3)
}

///|
test "FlickerDetection: 构造与字段" {
  let detection : @video.FlickerDetection = {
    has_flicker: true,
    flicker_score: 0.5,
    frame_indices: [1, 3, 5],
  }
  assert_true(detection.has_flicker)
  assert_eq(detection.flicker_score, 0.5)
  assert_eq(detection.frame_indices.length(), 3)
}
