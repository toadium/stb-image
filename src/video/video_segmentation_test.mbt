///|
test "VideoSegmentationMethod: 枚举值" {
  assert_true(@video.FrameDifference is @video.FrameDifference)
  assert_true(@video.BackgroundSubtraction is @video.BackgroundSubtraction)
  assert_true(@video.MotionBased is @video.MotionBased)
}

///|
test "SegmentationConfig: 构造与字段" {
  let config : @video.SegmentationConfig = {
    seg_method: @video.BackgroundSubtraction,
    threshold: 25.0,
    learning_rate: 0.1,
    min_motion_area: 20,
  }
  assert_eq(config.threshold, 25.0)
  assert_eq(config.learning_rate, 0.1)
  assert_eq(config.min_motion_area, 20)
  assert_true(config.seg_method is @video.BackgroundSubtraction)
}

///|
test "default_segmentation_config: 默认值" {
  let config = @video.default_segmentation_config()
  assert_eq(config.threshold, 30.0)
  assert_eq(config.learning_rate, 0.05)
  assert_eq(config.min_motion_area, 10)
  assert_true(config.seg_method is @video.FrameDifference)
}

///|
test "segment_frame_difference: 检测运动" {
  let prev : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 10, 10, 10]),
  }
  let curr : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 100, 10, 100]),
  }
  let result = @video.segment_frame_difference(prev, curr, 30.0)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.foreground_mask.length(), 4)
  // 变化大的像素应被检测为前景
  assert_true(result.foreground_mask[1])
  assert_true(result.foreground_mask[3])
  // 未变化的像素不应被检测为前景
  assert_true(!result.foreground_mask[0])
  assert_true(!result.foreground_mask[2])
  assert_true(result.foreground_ratio > 0.0)
}

///|
test "segment_frame_difference: 无运动" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let result = @video.segment_frame_difference(img, img, 30.0)
  assert_eq(result.foreground_ratio, 0.0)
  assert_eq(result.motion_area, 0)
}

///|
test "build_background_model: 基本构建" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 100]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([60, 90]),
  }
  let model = @video.build_background_model([frame1, frame2])
  assert_true(model is Some(_))
}

///|
test "build_background_model: 空帧返回 None" {
  let model = @video.build_background_model([])
  assert_true(model is None)
}

///|
test "update_background_model: 基本更新" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 100]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([60, 90]),
  }
  let model = @video.build_background_model([frame1, frame2])
  if model is Some(m) {
    let updated = @video.update_background_model(m, frame1, 0.1)
    assert_eq(updated.frame_count, 3)
  }
}

///|
test "subtract_background: 基本减除" {
  let bg_frame : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 50]),
  }
  let model = @video.build_background_model([bg_frame, bg_frame])
  let test_frame : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 200]),
  }
  if model is Some(m) {
    let result = @video.subtract_background(test_frame, m, 30.0)
    assert_eq(result.width, 2)
    assert_eq(result.height, 1)
    // 第二像素差异大，应为前景
    assert_true(result.foreground_mask[1])
  }
}

///|
test "segment_motion: 基本运动分割" {
  let frame1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([10, 10]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 10]),
  }
  let frame3 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([10, 100]),
  }
  let results = @video.segment_motion([frame1, frame2, frame3], 30.0)
  assert_eq(results.length(), 2)
}

///|
test "video_segmentation_pipeline: 帧差法" {
  let frame1 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 10, 10, 10]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 10, 10, 10]),
  }
  let config = @video.default_segmentation_config()
  let results = @video.video_segmentation_pipeline([frame1, frame2], config)
  assert_eq(results.length(), 1)
}

///|
test "video_segmentation_pipeline: 背景减除" {
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
    data: Bytes::from_array([50, 200, 50, 50]),
  }
  let config : @video.SegmentationConfig = {
    seg_method: @video.BackgroundSubtraction,
    threshold: 30.0,
    learning_rate: 0.05,
    min_motion_area: 10,
  }
  let results = @video.video_segmentation_pipeline([frame1, frame2], config)
  assert_eq(results.length(), 2)
}

///|
test "motion_consistency: 基本计算" {
  let r1 : @video.SegmentationResult = {
    foreground_mask: [true, false, true, false],
    foreground_ratio: 0.5,
    motion_area: 2,
    width: 2,
    height: 2,
  }
  let r2 : @video.SegmentationResult = {
    foreground_mask: [true, false, true, false],
    foreground_ratio: 0.5,
    motion_area: 2,
    width: 2,
    height: 2,
  }
  let consistency = @video.motion_consistency([r1, r2])
  // 两个像素在所有帧中都是前景，一致性 = 0.5
  assert_eq(consistency, 0.5)
}

///|
test "motion_consistency: 空结果" {
  let consistency = @video.motion_consistency([])
  assert_eq(consistency, 0.0)
}

///|
test "extract_foreground: 基本提取" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 50, 50, 100]),
  }
  let result : @video.SegmentationResult = {
    foreground_mask: [true, false, false, true],
    foreground_ratio: 0.5,
    motion_area: 2,
    width: 2,
    height: 2,
  }
  let fg = @video.extract_foreground(img, result)
  assert_eq(fg.data[0], 100)
  assert_eq(fg.data[1], 0)
  assert_eq(fg.data[2], 0)
  assert_eq(fg.data[3], 100)
}

///|
test "SegmentationResult: 构造与字段" {
  let result : @video.SegmentationResult = {
    foreground_mask: [true, false],
    foreground_ratio: 0.5,
    motion_area: 1,
    width: 2,
    height: 1,
  }
  assert_eq(result.foreground_mask.length(), 2)
  assert_eq(result.foreground_ratio, 0.5)
  assert_eq(result.motion_area, 1)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
}
