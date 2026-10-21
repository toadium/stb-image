// SLAM 前端测试
// SLAM frontend tests

///|
fn make_slam_params() -> @cv_advanced.SlamFrontendParams {
  {
    min_features: 10,
    max_features: 200,
    keyframe_distance: 0.1,
    keyframe_angle: 0.1,
    lost_threshold: 5,
  }
}

///|
test "形式化: identity_pose 返回单位位姿" {
  let p = @cv_advanced.identity_pose()
  assert_eq(p.tx, 0.0)
  assert_eq(p.ty, 0.0)
  assert_eq(p.tz, 0.0)
  assert_eq(p.qw, 1.0)
}

///|
test "形式化: init_slam_frontend 返回空前端" {
  let f = @cv_advanced.init_slam_frontend()
  assert_eq(f.keyframes.length(), 0)
  assert_eq(f.tracking_status, 0)
  assert_eq(f.lost_count, 0)
}

///|
test "形式化: process_keyframe 添加关键帧" {
  let f = @cv_advanced.init_slam_frontend()
  let pose = @cv_advanced.identity_pose()
  let f2 = @cv_advanced.process_keyframe(f, pose, 0.0, 100, 80)
  assert_eq(f2.keyframes.length(), 1)
  assert_eq(f2.tracking_status, 1)
}

///|
test "形式化: keyframe_selection 首帧总是关键帧" {
  let f = @cv_advanced.init_slam_frontend()
  let pose = @cv_advanced.identity_pose()
  let params = make_slam_params()
  let is_kf = @cv_advanced.keyframe_selection(f, pose, params)
  assert_true(is_kf)
}

///|
test "FAKE: track_keyframe 更新位姿" {
  let f = @cv_advanced.init_slam_frontend()
  let pose = @cv_advanced.identity_pose()
  let params = make_slam_params()
  let (f2, tracking) = @cv_advanced.track_keyframe(
    f,
    pose,
    (0.1, 0.0, 0.0),
    50,
    params,
  )
  assert_true(f2.current_pose.tx > 0.0)
  assert_true(tracking)
}

///|
test "MOCK: estimate_pose 返回位姿" {
  let pts3d : Array[@cv_advanced.Point3D] = [
    { x: 1.0, y: 2.0, z: 3.0, },
    { x: 4.0, y: 5.0, z: 6.0, },
  ]
  let pts2d : Array[(Double, Double)] = [(10.0, 20.0), (30.0, 40.0)]
  let intrinsics : @cv_advanced.CameraIntrinsics = {
    fx: 500.0,
    fy: 500.0,
    cx: 320.0,
    cy: 240.0,
    k1: 0.0,
    k2: 0.0,
    k3: 0.0,
    p1: 0.0,
    p2: 0.0,
  }
  let pose = @cv_advanced.estimate_pose(pts3d, pts2d, intrinsics)
  assert_true(pose.tz > 0.0)
}

///|
test "E2E: 完整 SLAM 前端流程" {
  let params = make_slam_params()
  let f = @cv_advanced.init_slam_frontend()
  let pose0 = @cv_advanced.identity_pose()
  let f1 = @cv_advanced.process_keyframe(f, pose0, 0.0, 100, 80)
  let (f2, t1) = @cv_advanced.track_keyframe(
    f1,
    pose0,
    (0.2, 0.0, 0.0),
    50,
    params,
  )
  let is_kf = @cv_advanced.keyframe_selection(f2, f2.current_pose, params)
  assert_true(t1)
  if is_kf {
    let f3 = @cv_advanced.process_keyframe(f2, f2.current_pose, 0.1, 90, 70)
    assert_eq(f3.keyframes.length(), 2)
  }
}

///|
test "AI: is_tracking_lost 检测丢失" {
  let params = make_slam_params()
  let f : @cv_advanced.SlamFrontend = {
    keyframes: [],
    current_pose: @cv_advanced.identity_pose(),
    tracking_status: 0,
    lost_count: 10,
  }
  assert_true(@cv_advanced.is_tracking_lost(f, params))
}

///|
test "AI: relocalize 恢复跟踪" {
  let f : @cv_advanced.SlamFrontend = {
    keyframes: [],
    current_pose: @cv_advanced.identity_pose(),
    tracking_status: 0,
    lost_count: 10,
  }
  let ref_kf : @cv_advanced.SlamKeyFrame = {
    id: 0,
    pose: @cv_advanced.identity_pose(),
    timestamp: 0.0,
    feature_count: 100,
    matched_count: 80,
  }
  let recovered = @cv_advanced.relocalize(f, ref_kf)
  assert_eq(recovered.tracking_status, 1)
  assert_eq(recovered.lost_count, 0)
}
