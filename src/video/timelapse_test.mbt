///|
test "ExposureMode: 枚举值" {
  assert_true(@video.Linear is @video.Linear)
  assert_true(@video.Logarithmic is @video.Logarithmic)
  assert_true(@video.Gamma is @video.Gamma)
}

///|
test "TimelapseConfig: 构造与字段" {
  let config : @video.TimelapseConfig = {
    sample_interval: 5,
    exposure_mode: @video.Gamma,
    exposure_compensation: 1.0,
    gamma: 2.2,
    stabilize: true,
  }
  assert_eq(config.sample_interval, 5)
  assert_eq(config.exposure_compensation, 1.0)
  assert_eq(config.gamma, 2.2)
  assert_eq(config.stabilize, true)
  assert_true(config.exposure_mode is @video.Gamma)
}

///|
test "default_timelapse_config: 默认值" {
  let config = @video.default_timelapse_config()
  assert_eq(config.sample_interval, 10)
  assert_eq(config.exposure_compensation, 0.0)
  assert_eq(config.gamma, 1.0)
  assert_eq(config.stabilize, false)
  assert_true(config.exposure_mode is @video.Linear)
}

///|
test "sample_frames: 基本采样" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame, frame, frame, frame, frame]
  let sampled = @video.sample_frames(frames, 2)
  assert_eq(sampled.length(), 3)
}

///|
test "sample_frames: 间隔为1返回全部" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame, frame]
  let sampled = @video.sample_frames(frames, 1)
  assert_eq(sampled.length(), 3)
}

///|
test "sample_frames: 零间隔返回全部" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let frames = [frame, frame, frame]
  let sampled = @video.sample_frames(frames, 0)
  assert_eq(sampled.length(), 3)
}

///|
test "adjust_exposure: 线性零补偿保持不变" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config = @video.default_timelapse_config()
  let result = @video.adjust_exposure(img, config)
  assert_eq(result.data[0], 100)
}

///|
test "adjust_exposure: 正补偿增亮" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50]),
  }
  let config : @video.TimelapseConfig = {
    sample_interval: 10,
    exposure_mode: @video.Linear,
    exposure_compensation: 1.0,
    gamma: 1.0,
    stabilize: false,
  }
  let result = @video.adjust_exposure(img, config)
  assert_true(result.data[0].to_int() > 50)
}

///|
test "adjust_exposure: 伽马校正" {
  let img : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let config : @video.TimelapseConfig = {
    sample_interval: 10,
    exposure_mode: @video.Gamma,
    exposure_compensation: 0.0,
    gamma: 2.0,
    stabilize: false,
  }
  let result = @video.adjust_exposure(img, config)
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
}

///|
test "adjust_exposure_sequence: 序列调整" {
  let frame : @types.Image = {
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100]),
  }
  let frames = [frame, frame, frame]
  let config = @video.default_timelapse_config()
  let result = @video.adjust_exposure_sequence(frames, config)
  assert_eq(result.length(), 3)
}

///|
test "create_timelapse: 基本创建" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let frames = [frame, frame, frame, frame, frame, frame]
  let config = @video.default_timelapse_config()
  let result = @video.create_timelapse(frames, config)
  // 6帧，间隔10，取1帧
  assert_eq(result.length(), 1)
}

///|
test "create_timelapse: 间隔2" {
  let frame : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50]),
  }
  let frames = [frame, frame, frame, frame, frame, frame]
  let config : @video.TimelapseConfig = {
    sample_interval: 2,
    exposure_mode: @video.Linear,
    exposure_compensation: 0.0,
    gamma: 1.0,
    stabilize: false,
  }
  let result = @video.create_timelapse(frames, config)
  assert_eq(result.length(), 3)
}

///|
test "timelapse_pipeline: 基本流水线" {
  let frame : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let frames = [frame, frame, frame, frame]
  let config : @video.TimelapseConfig = {
    sample_interval: 2,
    exposure_mode: @video.Linear,
    exposure_compensation: 0.0,
    gamma: 1.0,
    stabilize: false,
  }
  let result = @video.timelapse_pipeline(frames, config, 0.0)
  assert_eq(result.length(), 2)
}

///|
test "timelapse_pipeline: 带运动模糊" {
  let frame : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(16, 100)),
  }
  let frames = [frame, frame, frame, frame]
  let config : @video.TimelapseConfig = {
    sample_interval: 2,
    exposure_mode: @video.Linear,
    exposure_compensation: 0.0,
    gamma: 1.0,
    stabilize: false,
  }
  let result = @video.timelapse_pipeline(frames, config, 0.5)
  assert_eq(result.length(), 2)
}

///|
test "compute_timelapse_count: 基本计算" {
  let count = @video.compute_timelapse_count(100, 10)
  assert_eq(count, 10)
}

///|
test "compute_timelapse_count: 零帧" {
  let count = @video.compute_timelapse_count(0, 10)
  assert_eq(count, 0)
}

///|
test "compute_timelapse_duration: 基本计算" {
  let dur = @video.compute_timelapse_duration(100, 10, 30)
  // 10帧 / 30fps = 0.333...
  assert_true(dur > 0.3 && dur < 0.4)
}

///|
test "compute_time_compression: 基本计算" {
  let ratio = @video.compute_time_compression(10.0, 1.0)
  assert_eq(ratio, 10.0)
}

///|
test "compute_time_compression: 零时长" {
  let ratio = @video.compute_time_compression(10.0, 0.0)
  assert_eq(ratio, 0.0)
}
