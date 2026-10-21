// v32.0.0 人体姿态估计与动作识别测试 — pose_estimation 模块 12 函数

///|
fn create_solid_pe(w : Int32, h : Int32, v : Int32) -> @types.Image {
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
fn create_gradient_pe(w : Int32, h : Int32) -> @types.Image {
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
test "create_default_pose_config: 默认配置" {
  let config = @pose_estimation.create_default_pose_config()
  assert_true(config.num_keypoints == 17)
  assert_true(
    config.confidence_threshold > 0.0 && config.confidence_threshold < 1.0,
  )
  assert_true(config.nms_threshold > 0.0)
  assert_true(config.max_num_people > 0)
  assert_true(config.use_tracking)
  assert_true(config.use_smoothing)
  assert_true(config.smoothing_factor > 0.0 && config.smoothing_factor < 1.0)
}

///|
test "create_default_action_config: 默认配置" {
  let config = @pose_estimation.create_default_action_config()
  assert_true(config.num_classes > 0)
  assert_true(config.window_size > 0)
  assert_true(config.stride > 0)
  assert_true(config.confidence_threshold > 0.0)
  assert_true(config.use_temporal_smoothing)
  assert_true(config.smoothing_window > 0)
}

///|
test "get_coco_keypoint_names: 17个关键点" {
  let names = @pose_estimation.get_coco_keypoint_names()
  assert_true(names.length() == 17)
  assert_true(names[0] == "nose")
  assert_true(names[16] == "right_ankle")
}

///|
test "get_coco_skeleton_connections: 骨架连接" {
  let conns = @pose_estimation.get_coco_skeleton_connections()
  assert_true(conns.length() == 16)
  assert_true(conns[0].length() == 2)
  assert_true(conns[0][0] == 0)
  assert_true(conns[0][1] == 1)
}

///|
test "detect_keypoints: 渐变图像检测人体" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  assert_true(poses.length() >= 1)
  assert_true(poses[0].num_keypoints == 17)
  assert_true(poses[0].keypoints.length() == 17)
  assert_true(poses[0].bounding_box.length() == 4)
}

///|
test "detect_keypoints: 纯色图像检测" {
  let img = create_solid_pe(128, 128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  assert_true(poses.length() >= 1)
  assert_true(poses[0].num_keypoints == 17)
}

///|
test "extract_skeleton: 提取骨架连接" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  let skeleton = @pose_estimation.extract_skeleton(poses[0])
  assert_true(skeleton.length() == 16)
  assert_true(skeleton[0].joint1 == 0)
  assert_true(skeleton[0].joint2 == 1)
}

///|
test "calculate_joint_angle: 计算关节角度" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  let angle = @pose_estimation.calculate_joint_angle(poses[0], 5, 7, 9)
  assert_true(angle >= 0.0 && angle <= 180.0)
}

///|
test "calculate_joint_angle: 越界索引返回0" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  let angle = @pose_estimation.calculate_joint_angle(poses[0], 100, 101, 102)
  assert_true(angle == 0.0)
}

///|
test "recognize_action: 空姿态列表" {
  let poses : Array[@pose_estimation.HumanPose] = []
  let config = @pose_estimation.create_default_action_config()
  let result = @pose_estimation.recognize_action(poses, config)
  assert_true(result.action_name == "unknown")
  assert_true(result.confidence == 0.0)
  assert_true(result.action_id == -1)
}

///|
test "recognize_action: 有姿态列表" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_action_config()
  let pose_config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, pose_config)
  let result = @pose_estimation.recognize_action(poses, config)
  assert_true(result.action_name.length() > 0)
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  assert_true(result.is_completed)
}

///|
test "recognize_gesture: 手势识别" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  let result = @pose_estimation.recognize_gesture(poses[0])
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  assert_true(result.bounding_box.length() == 4)
}

///|
test "visualize_pose: 可视化姿态" {
  let img = create_gradient_pe(128, 128)
  let config = @pose_estimation.create_default_pose_config()
  let poses = @pose_estimation.detect_keypoints(img, config)
  let visualized = @pose_estimation.visualize_pose(img, poses[0])
  assert_true(visualized.width == img.width)
  assert_true(visualized.height == img.height)
  assert_true(visualized.channels == img.channels)
}

///|
test "pose_estimation_report_to_string: 报告非空" {
  let img = create_gradient_pe(128, 128)
  let pose_config = @pose_estimation.create_default_pose_config()
  let action_config = @pose_estimation.create_default_action_config()
  let poses = @pose_estimation.detect_keypoints(img, pose_config)
  let action_result = @pose_estimation.recognize_action(poses, action_config)
  let report = @pose_estimation.pose_estimation_report_to_string(
    poses, action_result,
  )
  assert_true(report.length() > 0)
}
