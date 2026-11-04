///|
test "SlowMotionMethod: 枚举值" {
  assert_true(@video.OpticalFlow is @video.OpticalFlow)
  assert_true(@video.FrameBlending is @video.FrameBlending)
  assert_true(@video.MotionCompensation is @video.MotionCompensation)
}

///|
test "SlowMotionConfig: 构造与字段" {
  let config : @video.SlowMotionConfig = {
    sm_method: @video.OpticalFlow,
    speed_factor: 4,
    blur_amount: 0.5,
    blur_direction: 1,
  }
  assert_eq(config.speed_factor, 4)
  assert_eq(config.blur_amount, 0.5)
  assert_eq(config.blur_direction, 1)
  assert_true(config.sm_method is @video.OpticalFlow)
}

///|
test "default_slow_motion_config: 默认值" {
  let config = @video.default_slow_motion_config()
  assert_eq(config.speed_factor, 2)
  assert_eq(config.blur_amount, 0.0)
  assert_eq(config.blur_direction, 0)
  assert_true(config.sm_method is @video.FrameBlending)
}

///|
test "interpolate_frame_blend: 中间值" {
  let from : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0]),
  }
  let to_ : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let mid = @video.interpolate_frame_blend(from, to_, 0.5)
  assert_true(mid.data[0].to_int() > 40 && mid.data[0].to_int() < 60)
}

///|
test "interpolate_frame_blend: alpha=0 返回 from" {
  let from : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let to_ : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let result = @video.interpolate_frame_blend(from, to_, 0.0)
  assert_eq(result.data[0], 50)
}

///|
test "interpolate_frame_blend: alpha=1 返回 to" {
  let from : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let to_ : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let result = @video.interpolate_frame_blend(from, to_, 1.0)
  assert_eq(result.data[0], 200)
}

///|
test "interpolate_frame_optical_flow: 基本插帧" {
  let from : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0]),
  }
  let to_ : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100]),
  }
  let mid = @video.interpolate_frame_optical_flow(from, to_, 0.5)
  assert_eq(mid.width, 2)
  assert_eq(mid.height, 1)
}

///|
test "interpolate_frame_motion_compensation: 基本插帧" {
  let from : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let to_ : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([150]),
  }
  let mid = @video.interpolate_frame_motion_compensation(from, to_, 0.5)
  assert_eq(mid.data[0].to_int(), 100)
}

///|
test "interpolate_frames_slow_motion: 分发" {
  let from : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0]),
  }
  let to_ : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let result = @video.interpolate_frames_slow_motion(
    from,
    to_,
    0.5,
    @video.FrameBlending,
  )
  assert_eq(result.width, 1)
}

///|
test "generate_slow_motion: 2倍慢放" {
  let frame1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0]),
  }
  let frame2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let frames = [frame1, frame2]
  let config = @video.default_slow_motion_config()
  let result = @video.generate_slow_motion(frames, config)
  // 2帧 + 1插帧 = 3帧
  assert_eq(result.length(), 3)
}

///|
test "generate_slow_motion: 空视频" {
  let frames : Array[@types.Image] = []
  let config = @video.default_slow_motion_config()
  let result = @video.generate_slow_motion(frames, config)
  assert_eq(result.length(), 0)
}

///|
test "apply_motion_blur: 水平模糊" {
  let img : @types.Image = {
    width: 4,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 0, 255, 255]),
  }
  let result = @video.apply_motion_blur(img, 0.5, 0)
  assert_eq(result.width, 4)
  assert_eq(result.height, 1)
}

///|
test "apply_motion_blur: 垂直模糊" {
  let img : @types.Image = {
    width: 1,
    height: 4,
    channels: 1,
    data: Bytes::from_array([0, 0, 255, 255]),
  }
  let result = @video.apply_motion_blur(img, 0.5, 1)
  assert_eq(result.width, 1)
  assert_eq(result.height, 4)
}

///|
test "apply_motion_blur: 径向模糊" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let result = @video.apply_motion_blur(img, 0.5, 2)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "motion_blur_sequence: 零模糊保持原帧" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 60, 70, 80]),
  }
  let frames = [frame, frame]
  let config = @video.default_slow_motion_config()
  let result = @video.motion_blur_sequence(frames, config)
  assert_eq(result.length(), 2)
  assert_eq(result[0].data[0], 50)
}

///|
test "motion_blur_sequence: 有模糊" {
  let frame : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let frames = [frame, frame]
  let config : @video.SlowMotionConfig = {
    sm_method: @video.FrameBlending,
    speed_factor: 2,
    blur_amount: 0.5,
    blur_direction: 0,
  }
  let result = @video.motion_blur_sequence(frames, config)
  assert_eq(result.length(), 2)
}

///|
test "slow_motion_pipeline: 基本流水线" {
  let frame1 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([0, 0, 0, 0]),
  }
  let frame2 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let frames = [frame1, frame2]
  let config = @video.default_slow_motion_config()
  let result = @video.slow_motion_pipeline(frames, config)
  assert_eq(result.length(), 3)
}

///|
test "compute_interpolated_count: 基本计算" {
  // 2帧，2倍慢放：2 + 1*(2-1) = 3
  let count = @video.compute_interpolated_count(2, 2)
  assert_eq(count, 3)
}

///|
test "compute_interpolated_count: 4倍慢放" {
  // 3帧，4倍慢放：3 + 2*(4-1) = 9
  let count = @video.compute_interpolated_count(3, 4)
  assert_eq(count, 9)
}

///|
test "compute_interpolated_count: 零帧" {
  let count = @video.compute_interpolated_count(0, 2)
  assert_eq(count, 0)
}
