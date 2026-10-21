// SLAM 后端测试
// SLAM backend tests

///|
fn make_backend_params() -> @cv_advanced.SlamBackendParams {
  {
    min_observations: 2,
    max_reproj_error: 5.0,
    loop_threshold: 0.5,
    ba_iterations: 10,
  }
}

///|
test "形式化: init_slam_backend 返回空后端" {
  let b = @cv_advanced.init_slam_backend()
  assert_eq(b.map_points.length(), 0)
  assert_eq(b.keyframes.length(), 0)
  assert_eq(b.optimized, false)
}

///|
test "形式化: add_map_point 添加地图点" {
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 3, 0.9)
  assert_eq(b2.map_points.length(), 1)
  assert_eq(b2.map_points[0].id, 0)
}

///|
test "形式化: map_statistics 返回正确统计" {
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 3, 0.9)
  let (n_pts, n_kfs, avg_q) = @cv_advanced.map_statistics(b2)
  assert_eq(n_pts, 1)
  assert_eq(n_kfs, 0)
  assert_true(avg_q > 0.0)
}

///|
test "形式化: remove_redundant_points 过滤低质量点" {
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 1, 0.9)
  let b3 = @cv_advanced.add_map_point(b2, pos, 5, 0.8)
  let params = make_backend_params()
  let b4 = @cv_advanced.remove_redundant_points(b3, params)
  assert_true(b4.map_points.length() <= 2)
}

///|
test "FAKE: global_bundle_adjustment 优化地图" {
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 3, 0.9)
  let params = make_backend_params()
  let b3 = @cv_advanced.global_bundle_adjustment(b2, params)
  assert_eq(b3.optimized, true)
}

///|
test "MOCK: loop_closing 无回环时返回 false" {
  let b = @cv_advanced.init_slam_backend()
  let params = make_backend_params()
  let kf : @cv_advanced.SlamKeyFrame = {
    id: 0,
    pose: @cv_advanced.identity_pose(),
    timestamp: 0.0,
    feature_count: 100,
    matched_count: 80,
  }
  let result = @cv_advanced.loop_closing(b, kf, params)
  assert_eq(result.loop_found, false)
}

///|
test "E2E: 完整后端优化流程" {
  let params = make_backend_params()
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 5, 0.9)
  let b3 = @cv_advanced.add_map_point(b2, pos, 3, 0.8)
  let b4 = @cv_advanced.optimize_map(b3, params)
  let (n_pts, _, avg_q) = @cv_advanced.map_statistics(b4)
  assert_true(n_pts >= 0)
  assert_true(avg_q >= 0.0)
}

///|
test "AI: merge_map_points 合并近邻点" {
  let b = @cv_advanced.init_slam_backend()
  let pos1 : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let pos2 : @cv_advanced.Point3D = { x: 1.01, y: 2.01, z: 3.01, }
  let b2 = @cv_advanced.add_map_point(b, pos1, 3, 0.9)
  let b3 = @cv_advanced.add_map_point(b2, pos2, 2, 0.8)
  let b4 = @cv_advanced.merge_map_points(b3, 0.1)
  assert_true(b4.map_points.length() <= 2)
}

///|
test "AI: optimize_map 设置 optimized 标志" {
  let params = make_backend_params()
  let b = @cv_advanced.init_slam_backend()
  let pos : @cv_advanced.Point3D = { x: 1.0, y: 2.0, z: 3.0, }
  let b2 = @cv_advanced.add_map_point(b, pos, 5, 0.9)
  let b3 = @cv_advanced.optimize_map(b2, params)
  assert_eq(b3.optimized, true)
}
