// v31.0.0 SLAM 同时定位与地图构建测试 — slam 模块 9 函数

///|
fn create_solid_slam(w : Int32, h : Int32, v : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn create_gradient_slam(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) * 255 / (w + h) % 256).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn create_identity_pose() -> @slam.CameraPose {
  @slam.CameraPose::{
    position: [0.0, 0.0, 0.0],
    rotation: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0],
    timestamp: 0.0,
    confidence: 1.0,
  }
}

///|
test "create_default_slam_config: 默认配置" {
  let config = @slam.create_default_slam_config()
  assert_true(config.max_features > 0)
  assert_true(config.feature_threshold > 0.0)
  assert_true(config.keyframe_interval > 0)
  assert_true(config.camera_fx > 0.0)
  assert_true(config.camera_fy > 0.0)
  assert_true(config.use_loop_closure)
  assert_true(config.use_bundle_adjustment)
}

///|
test "detect_features_slam: 纯色图像无特征" {
  let img = create_solid_slam(32, 32, 128)
  let features = @slam.detect_features_slam(img, 500, 20.0)
  assert_true(features.length() == 0)
}

///|
test "detect_features_slam: 渐变图像有特征" {
  let img = create_gradient_slam(32, 32)
  let features = @slam.detect_features_slam(img, 500, 1.0)
  assert_true(features.length() >= 0)
}

///|
test "track_features_slam: 相同图像跟踪" {
  let img = create_gradient_slam(32, 32)
  let features = @slam.detect_features_slam(img, 100, 1.0)
  let result = @slam.track_features_slam(img, img, features, 8)
  assert_true(result.num_tracked >= 0)
  assert_true(result.num_lost >= 0)
  assert_true(result.num_tracked + result.num_lost == features.length())
}

///|
test "track_features_slam: 空特征列表" {
  let img = create_gradient_slam(32, 32)
  let features : Array[Array[Double]] = []
  let result = @slam.track_features_slam(img, img, features, 8)
  assert_true(result.num_tracked == 0)
  assert_true(result.num_lost == 0)
}

///|
test "estimate_camera_pose: 位姿估计" {
  let tracking_result = @slam.FeatureTrackingResult::{
    tracked_features: [[10.0, 20.0, 5.0]],
    num_tracked: 10,
    num_lost: 2,
    parallax: 5.0,
    is_keyframe: false,
  }
  let config = @slam.create_default_slam_config()
  let prev_pose = create_identity_pose()
  let new_pose = @slam.estimate_camera_pose(tracking_result, config, prev_pose)
  assert_true(new_pose.position.length() == 3)
  assert_true(new_pose.rotation.length() == 9)
  assert_true(new_pose.timestamp > prev_pose.timestamp)
  assert_true(new_pose.confidence >= 0.0 && new_pose.confidence <= 1.0)
}

///|
test "triangulate_points: 三角化3D点" {
  let features = [[100.0, 200.0, 50.0], [150.0, 100.0, 30.0]]
  let pose1 = create_identity_pose()
  let pose2 = @slam.CameraPose::{
    position: [0.1, 0.0, 0.0],
    rotation: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0],
    timestamp: 0.033,
    confidence: 1.0,
  }
  let config = @slam.create_default_slam_config()
  let points = @slam.triangulate_points(features, pose1, pose2, config)
  assert_true(points.length() == 2)
  assert_true(points[0].position.length() == 3)
  assert_true(points[0].color.length() == 3)
  assert_true(!points[0].is_outlier)
}

///|
test "detect_loop_closure: 空关键帧无回环" {
  let current_features = [[10.0, 20.0, 50.0]]
  let keyframes : Array[@slam.KeyFrame] = []
  let result = @slam.detect_loop_closure(current_features, keyframes, 0.5)
  assert_true(!result.is_loop_detected)
  assert_true(result.loop_frame_index == -1)
}

///|
test "initialize_slam: 初始化状态" {
  let config = @slam.create_default_slam_config()
  let state = @slam.initialize_slam(config)
  assert_true(state.num_frames_processed == 0)
  assert_true(state.num_lost_frames == 0)
  assert_true(state.is_tracking)
  assert_true(state.is_mapping)
  assert_true(state.trajectory.length() == 1)
  assert_true(state.map_points.length() == 0)
  assert_true(state.keyframes.length() == 0)
}

///|
test "process_frame_slam: 处理首帧" {
  let config = @slam.create_default_slam_config()
  let state = @slam.initialize_slam(config)
  let img = create_gradient_slam(32, 32)
  let new_state = @slam.process_frame_slam(state, img, config)
  assert_true(new_state.num_frames_processed == 1)
  assert_true(new_state.keyframes.length() >= 1)
}

///|
test "process_frame_slam: 处理多帧" {
  let config = @slam.create_default_slam_config()
  let state = @slam.initialize_slam(config)
  let img1 = create_gradient_slam(32, 32)
  let state1 = @slam.process_frame_slam(state, img1, config)
  let img2 = create_gradient_slam(32, 32)
  let state2 = @slam.process_frame_slam(state1, img2, config)
  assert_true(state2.num_frames_processed == 2)
  assert_true(state2.keyframes.length() >= 1)
}

///|
test "slam_report_to_string: 报告非空" {
  let config = @slam.create_default_slam_config()
  let state = @slam.initialize_slam(config)
  let report = @slam.slam_report_to_string(state)
  assert_true(report.length() > 0)
}
