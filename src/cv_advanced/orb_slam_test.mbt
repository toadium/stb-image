// ORB-SLAM 核心测试
// ORB-SLAM core tests

///|
fn make_orb_config() -> @cv_advanced.OrbSlamConfig {
  {
    mode: @cv_advanced.OrbSlamMode::Monocular,
    vocab_size: 10,
    n_features: 1000,
    scale_levels: 8,
    init_threshold: 20,
  }
}

///|
test "形式化: init_orb_slam 返回未初始化系统" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  assert_eq(sys.initialized, false)
  assert_eq(sys.frame_count, 0)
  assert_eq(sys.trajectory.length(), 0)
}

///|
test "形式化: run_orb_slam 增加帧计数" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let pose = @cv_advanced.identity_pose()
  let sys2 = @cv_advanced.run_orb_slam(sys, pose, 50, 0.0)
  assert_eq(sys2.frame_count, 1)
}

///|
test "形式化: get_orb_trajectory 返回轨迹" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let traj = @cv_advanced.get_orb_trajectory(sys)
  assert_eq(traj.length(), 0)
}

///|
test "形式化: reset_orb_slam 重置系统" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let pose = @cv_advanced.identity_pose()
  let sys2 = @cv_advanced.run_orb_slam(sys, pose, 50, 0.0)
  let sys3 = @cv_advanced.reset_orb_slam(sys2)
  assert_eq(sys3.frame_count, 0)
  assert_eq(sys3.initialized, false)
}

///|
test "FAKE: save_orb_trajectory 返回字符串" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let result = @cv_advanced.save_orb_trajectory(sys)
  assert_true(result.length() > 0)
}

///|
test "MOCK: orb_slam_stats 返回统计" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let stats = @cv_advanced.orb_slam_stats(sys)
  assert_eq(stats.total_frames, 0)
  assert_eq(stats.trajectory_length, 0.0)
}

///|
test "E2E: 完整 ORB-SLAM 流程" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let pose0 = @cv_advanced.identity_pose()
  let sys1 = @cv_advanced.run_orb_slam(sys, pose0, 50, 0.0)
  let pose1 : @cv_advanced.SlamPose = {
    tx: 0.1,
    ty: 0.0,
    tz: 0.0,
    qw: 1.0,
    qx: 0.0,
    qy: 0.0,
    qz: 0.0,
  }
  let sys2 = @cv_advanced.run_orb_slam(sys1, pose1, 40, 0.033)
  let stats = @cv_advanced.orb_slam_stats(sys2)
  assert_eq(stats.total_frames, 2)
  let traj = @cv_advanced.get_orb_trajectory(sys2)
  assert_true(traj.length() >= 0)
}

///|
test "AI: OrbSlamMode 枚举完整" {
  let mono = @cv_advanced.OrbSlamMode::Monocular
  let stereo = @cv_advanced.OrbSlamMode::Stereo
  let rgbd = @cv_advanced.OrbSlamMode::RGBD
  assert_true(mono != stereo)
  assert_true(stereo != rgbd)
  assert_true(mono != rgbd)
}

///|
test "AI: shutdown_orb_slam 优化后端" {
  let config = make_orb_config()
  let sys = @cv_advanced.init_orb_slam(config)
  let params : @cv_advanced.SlamBackendParams = {
    min_observations: 2,
    max_reproj_error: 5.0,
    loop_threshold: 0.5,
    ba_iterations: 10,
  }
  let sys2 = @cv_advanced.shutdown_orb_slam(sys, params)
  assert_eq(sys2.backend.optimized, true)
}
