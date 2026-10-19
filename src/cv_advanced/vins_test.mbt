// VINS 测试
// VINS tests

///|
fn make_vins_config() -> @cv_advanced.VinsConfig {
  {
    gravity: 9.81,
    imu_freq: 200.0,
    cam_freq: 30.0,
    init_period: 1.0,
    max_iterations: 10,
  }
}

///|
fn make_imu_data(ts : Double) -> @cv_advanced.ImuData {
  { timestamp: ts, ax: 0.0, ay: 0.0, az: 9.81, gx: 0.0, gy: 0.0, gz: 0.0, }
}

///|
test "形式化: init_vins 返回未初始化状态" {
  let config = make_vins_config()
  let (state, _) = @cv_advanced.init_vins(config)
  assert_eq(state.initialized, false)
  assert_eq(state.imu_count, 0)
  assert_eq(state.frame_count, 0)
}

///|
test "形式化: process_imu 增加 IMU 计数" {
  let config = make_vins_config()
  let (state, cfg) = @cv_advanced.init_vins(config)
  let imu = make_imu_data(0.0)
  let state2 = @cv_advanced.process_imu(state, cfg, imu, 0.005)
  assert_eq(state2.imu_count, 1)
}

///|
test "形式化: process_image_vins 增加帧计数" {
  let config = make_vins_config()
  let (state, _) = @cv_advanced.init_vins(config)
  let pose = @cv_advanced.identity_pose()
  let state2 = @cv_advanced.process_image_vins(state, pose, 0.0)
  assert_eq(state2.frame_count, 1)
}

///|
test "形式化: get_vins_state 返回位姿" {
  let config = make_vins_config()
  let (state, _) = @cv_advanced.init_vins(config)
  let pose = @cv_advanced.get_vins_state(state)
  assert_eq(pose.tx, 0.0)
  assert_eq(pose.ty, 0.0)
  assert_eq(pose.tz, 0.0)
}

///|
test "FAKE: vins_optimize 优化偏差" {
  let config = make_vins_config()
  let (state, cfg) = @cv_advanced.init_vins(config)
  let optimized = @cv_advanced.vins_optimize(state, cfg)
  assert_eq(optimized.imu_count, state.imu_count)
}

///|
test "MOCK: vins_stats 返回统计" {
  let config = make_vins_config()
  let (state, _) = @cv_advanced.init_vins(config)
  let stats = @cv_advanced.vins_stats(state, [])
  assert_eq(stats.total_imu, 0)
  assert_eq(stats.total_frames, 0)
  assert_eq(stats.initialized, false)
}

///|
test "E2E: 完整 VINS 流程" {
  let config = make_vins_config()
  let (state, cfg) = @cv_advanced.init_vins(config)
  let mut current = state
  for i in 0..<200 {
    let imu = make_imu_data(i.to_double() * 0.005)
    current = @cv_advanced.process_imu(current, cfg, imu, 0.005)
  }
  let pose : @cv_advanced.SlamPose = {
    tx: 0.1,
    ty: 0.0,
    tz: 0.0,
    qw: 1.0,
    qx: 0.0,
    qy: 0.0,
    qz: 0.0,
  }
  current = @cv_advanced.process_image_vins(current, pose, 1.0)
  let stats = @cv_advanced.vins_stats(current, [pose])
  assert_eq(stats.total_imu, 200)
  assert_eq(stats.total_frames, 1)
}

///|
test "AI: vins_check_initialization 检查初始化" {
  let config = make_vins_config()
  let (state, _) = @cv_advanced.init_vins(config)
  assert_eq(@cv_advanced.vins_check_initialization(state), false)
}

///|
test "AI: reset_vins 重置状态" {
  let config = make_vins_config()
  let (state, cfg) = @cv_advanced.init_vins(config)
  let imu = make_imu_data(0.0)
  let _ = @cv_advanced.process_imu(state, cfg, imu, 0.005)
  let (state3, _) = @cv_advanced.reset_vins(cfg)
  assert_eq(state3.imu_count, 0)
  assert_eq(state3.initialized, false)
}
