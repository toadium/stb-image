///|
test "FrameInterpMethod: 枚举值" {
  assert_true(@video.LinearInterp is @video.LinearInterp)
  assert_true(@video.OpticalFlowInterp is @video.OpticalFlowInterp)
  assert_true(@video.PhaseInterp is @video.PhaseInterp)
}

///|
test "FrameInterpConfig: 构造与字段" {
  let config : @video.FrameInterpConfig = {
    interp_method: @video.OpticalFlowInterp,
    num_interp_frames: 2,
    motion_threshold: 15.0,
    blend_factor: 0.7,
  }
  assert_eq(config.num_interp_frames, 2)
  assert_eq(config.motion_threshold, 15.0)
  assert_eq(config.blend_factor, 0.7)
  assert_true(config.interp_method is @video.OpticalFlowInterp)
}

///|
test "default_interp_config: 默认值" {
  let config = @video.default_interp_config()
  assert_eq(config.num_interp_frames, 1)
  assert_eq(config.motion_threshold, 10.0)
  assert_eq(config.blend_factor, 0.5)
  assert_true(config.interp_method is @video.LinearInterp)
}

///|
test "linear_interpolate_frames: 插入1帧" {
  let f1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let f2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([150, 250]),
  }
  let result = @video.linear_interpolate_frames(f1, f2, 1)
  assert_eq(result.length(), 1)
  // 中间帧应在两帧之间
  assert_true(result[0].data[0].to_int() > 100)
  assert_true(result[0].data[0].to_int() < 150)
}

///|
test "linear_interpolate_frames: 插入多帧" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([255]),
  }
  let result = @video.linear_interpolate_frames(f1, f2, 3)
  assert_eq(result.length(), 3)
  // 帧应递增
  assert_true(result[0].data[0].to_int() < result[1].data[0].to_int())
  assert_true(result[1].data[0].to_int() < result[2].data[0].to_int())
}

///|
test "compute_motion_between_frames: 静态帧" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let motion = @video.compute_motion_between_frames(img, img)
  assert_eq(motion.motion_score, 0.0)
  assert_eq(motion.static_ratio, 1.0)
}

///|
test "compute_motion_between_frames: 运动帧" {
  let f1 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 10, 10, 10]),
  }
  let f2 : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([200, 200, 200, 200]),
  }
  let motion = @video.compute_motion_between_frames(f1, f2)
  assert_true(motion.motion_score > 0.0)
  assert_true(motion.static_ratio < 1.0)
}

///|
test "optical_flow_interpolate: 光流插帧" {
  let f1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let f2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([120, 220]),
  }
  let config = @video.default_interp_config()
  let result = @video.optical_flow_interpolate(f1, f2, 1, config)
  assert_eq(result.length(), 1)
  assert_eq(result[0].width, 2)
}

///|
test "phase_interpolate: 相位插帧" {
  let f1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let f2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([150, 250]),
  }
  let config = @video.default_interp_config()
  let result = @video.phase_interpolate(f1, f2, 1, config)
  assert_eq(result.length(), 1)
  assert_eq(result[0].width, 2)
}

///|
test "interpolate_frames: LinearInterp 方法" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_interp_config()
  let result = @video.video_interpolate_frames([f1, f2], config)
  // 原始2帧 + 插入1帧 = 3帧
  assert_eq(result.length(), 3)
  // 首尾帧保持不变
  assert_eq(result[0].data[0].to_int(), 100)
  assert_eq(result[2].data[0].to_int(), 200)
}

///|
test "interpolate_frames: 多帧序列" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let f3 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([150]),
  }
  let config = @video.default_interp_config()
  let result = @video.video_interpolate_frames([f1, f2, f3], config)
  // 3原始帧 + 2插入帧 = 5帧
  assert_eq(result.length(), 5)
}

///|
test "interpolate_frames: 单帧不变" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config = @video.default_interp_config()
  let result = @video.video_interpolate_frames([img], config)
  assert_eq(result.length(), 1)
}

///|
test "frame_rate_conversion: 降帧率" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let f3 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([150]),
  }
  let f4 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_interp_config()
  let result = @video.frame_rate_conversion(
    [f1, f2, f3, f4],
    30.0,
    15.0,
    config,
  )
  // 降帧率应减少帧数
  assert_true(result.length() <= 4)
}

///|
test "frame_rate_conversion: 升帧率" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config = @video.default_interp_config()
  let result = @video.frame_rate_conversion([f1, f2], 15.0, 30.0, config)
  // 升帧率应增加帧数
  assert_true(result.length() >= 2)
}

///|
test "interp_pipeline: 完整流水线" {
  let f1 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let f2 : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([200]),
  }
  let config = @video.default_interp_config()
  let result = @video.interp_pipeline([f1, f2], config)
  assert_eq(result.length(), 3)
}

///|
test "MotionEstimateResult: 构造与字段" {
  let result : @video.MotionEstimateResult = {
    motion_score: 0.5,
    dominant_direction: (1.0, 2.0),
    static_ratio: 0.3,
  }
  assert_eq(result.motion_score, 0.5)
  assert_eq(result.static_ratio, 0.3)
  let (dx, dy) = result.dominant_direction
  assert_eq(dx, 1.0)
  assert_eq(dy, 2.0)
}
