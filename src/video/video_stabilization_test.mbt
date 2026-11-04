///|
test "StabilizationMethod: 枚举值" {
  assert_true(@video.MotionModel is @video.MotionModel)
  assert_true(@video.Affine is @video.Affine)
  assert_true(@video.Perspective is @video.Perspective)
}

///|
test "TrajectorySmoothing: 枚举值" {
  assert_true(@video.Gaussian is @video.Gaussian)
  assert_true(@video.MovingAverage is @video.MovingAverage)
  assert_true(@video.MedianFilter is @video.MedianFilter)
}

///|
test "TrajectoryPoint: 构造与字段" {
  let p : @video.TrajectoryPoint = { x: 1.5, y: -2.0, frame_index: 5, }
  assert_eq(p.x, 1.5)
  assert_eq(p.y, -2.0)
  assert_eq(p.frame_index, 5)
}

///|
test "StabilizationConfig: 构造与字段" {
  let config : @video.StabilizationConfig = {
    stab_method: @video.Affine,
    smoothing: @video.MovingAverage,
    smoothing_radius: 10,
    crop_margin: 0.05,
  }
  assert_eq(config.smoothing_radius, 10)
  assert_eq(config.crop_margin, 0.05)
  assert_true(config.stab_method is @video.Affine)
  assert_true(config.smoothing is @video.MovingAverage)
}

///|
test "default_stabilization_config: 默认值" {
  let config = @video.default_stabilization_config()
  assert_eq(config.smoothing_radius, 15)
  assert_eq(config.crop_margin, 0.1)
  assert_true(config.stab_method is @video.MotionModel)
  assert_true(config.smoothing is @video.Gaussian)
}

///|
test "compute_trajectory: 基本轨迹" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 100, 100, 100]),
  }
  let frames = [frame, frame, frame]
  let traj = @video.compute_trajectory(frames)
  assert_eq(traj.length(), 3)
  assert_eq(traj[0].x, 0.0)
  assert_eq(traj[0].y, 0.0)
  assert_eq(traj[0].frame_index, 0)
}

///|
test "compute_trajectory: 空视频" {
  let frames : Array[@types.Image] = []
  let traj = @video.compute_trajectory(frames)
  assert_eq(traj.length(), 0)
}

///|
test "smooth_trajectory: 高斯平滑" {
  let traj : Array[@video.TrajectoryPoint] = [
    { x: 0.0, y: 0.0, frame_index: 0, },
    { x: 1.0, y: 0.0, frame_index: 1, },
    { x: 0.0, y: 1.0, frame_index: 2, },
  ]
  let config : @video.StabilizationConfig = {
    stab_method: @video.MotionModel,
    smoothing: @video.Gaussian,
    smoothing_radius: 1,
    crop_margin: 0.1,
  }
  let smoothed = @video.smooth_trajectory(traj, config)
  assert_eq(smoothed.length(), 3)
}

///|
test "smooth_trajectory: 移动平均" {
  let traj : Array[@video.TrajectoryPoint] = [
    { x: 0.0, y: 0.0, frame_index: 0, },
    { x: 3.0, y: 3.0, frame_index: 1, },
    { x: 6.0, y: 6.0, frame_index: 2, },
  ]
  let config : @video.StabilizationConfig = {
    stab_method: @video.MotionModel,
    smoothing: @video.MovingAverage,
    smoothing_radius: 1,
    crop_margin: 0.1,
  }
  let smoothed = @video.smooth_trajectory(traj, config)
  assert_eq(smoothed.length(), 3)
  // 中间点应为 (0+3+6)/3 = 3
  assert_true(smoothed[1].x > 2.0 && smoothed[1].x < 4.0)
}

///|
test "smooth_trajectory: 中值滤波" {
  let traj : Array[@video.TrajectoryPoint] = [
    { x: 0.0, y: 0.0, frame_index: 0, },
    { x: 10.0, y: 10.0, frame_index: 1, },
    { x: 2.0, y: 2.0, frame_index: 2, },
  ]
  let config : @video.StabilizationConfig = {
    stab_method: @video.MotionModel,
    smoothing: @video.MedianFilter,
    smoothing_radius: 1,
    crop_margin: 0.1,
  }
  let smoothed = @video.smooth_trajectory(traj, config)
  assert_eq(smoothed.length(), 3)
  // 中间点的中值应为 2.0
  assert_eq(smoothed[1].x, 2.0)
}

///|
test "stabilize_frame: 基本稳定" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let orig : @video.TrajectoryPoint = { x: 2.0, y: 1.0, frame_index: 0, }
  let smoothed : @video.TrajectoryPoint = { x: 1.0, y: 0.5, frame_index: 0, }
  let result = @video.stabilize_frame(img, orig, smoothed)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "compute_crop_region: 基本裁剪区域" {
  let (x, y, w, h) = @video.compute_crop_region(100, 100, 0.1)
  assert_eq(x, 10)
  assert_eq(y, 10)
  assert_eq(w, 80)
  assert_eq(h, 80)
}

///|
test "compute_crop_region: 零边距" {
  let (x, y, w, h) = @video.compute_crop_region(100, 100, 0.0)
  assert_eq(x, 0)
  assert_eq(y, 0)
  assert_eq(w, 100)
  assert_eq(h, 100)
}

///|
test "stabilize_video_sequence: 基本稳定" {
  let frame : @types.Image = {
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(64, 100)),
  }
  let frames = [frame, frame, frame, frame]
  let config = @video.default_stabilization_config()
  let result = @video.stabilize_video_sequence(frames, config)
  assert_eq(result.frames.length(), 4)
  assert_eq(result.trajectory.length(), 4)
  assert_eq(result.smoothed_trajectory.length(), 4)
  assert_true(result.crop_width > 0)
  assert_true(result.crop_height > 0)
}

///|
test "stabilize_video_sequence: 空视频" {
  let frames : Array[@types.Image] = []
  let config = @video.default_stabilization_config()
  let result = @video.stabilize_video_sequence(frames, config)
  assert_eq(result.frames.length(), 0)
  assert_eq(result.trajectory.length(), 0)
}

///|
test "stabilization_score: 相同轨迹满分" {
  let traj : Array[@video.TrajectoryPoint] = [
    { x: 1.0, y: 2.0, frame_index: 0, },
    { x: 3.0, y: 4.0, frame_index: 1, },
  ]
  let score = @video.stabilization_score(traj, traj)
  assert_eq(score, 100.0)
}

///|
test "stabilization_score: 空轨迹零分" {
  let traj : Array[@video.TrajectoryPoint] = []
  let score = @video.stabilization_score(traj, traj)
  assert_eq(score, 0.0)
}

///|
test "StabilizationResult: 构造与字段" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let result : @video.StabilizationResult = {
    frames: [frame],
    trajectory: [{ x: 0.0, y: 0.0, frame_index: 0, }],
    smoothed_trajectory: [{ x: 0.0, y: 0.0, frame_index: 0, }],
    crop_x: 1,
    crop_y: 1,
    crop_width: 6,
    crop_height: 6,
  }
  assert_eq(result.frames.length(), 1)
  assert_eq(result.crop_x, 1)
  assert_eq(result.crop_width, 6)
}
