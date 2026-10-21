///|
test "create_default_robot_vision_config: returns grasping config" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  assert_eq(config.num_joints, 6)
  assert_eq(config.end_effector_type, "parallel_jaw")
  assert_eq(config.control_frequency, 100)
  assert_eq(config.planning_time_limit, 5.0)
  assert_true(config.use_force_control)
  assert_true(config.use_visual_servoing)
  assert_false(config.use_realtime)
  assert_eq(config.camera_intrinsics.length(), 9)
  assert_true(
    config.task_type
    is @robot_vision_advanced.RobotVisionTaskType::ObjectGrasping,
  )
  assert_true(
    config.robot_type is @robot_vision_advanced.RobotType::Manipulator,
  )
}

///|
test "estimate_object_pose: estimates pose from bbox and depth" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let depth_image : Array[Double] = []
  for _ in 0..<307200 {
    depth_image.push(1.0)
  }
  let pose = @robot_vision_advanced.estimate_object_pose(
    1,
    [100.0, 100.0, 200.0, 200.0],
    depth_image,
    config,
  )
  assert_eq(pose.object_id, 1)
  assert_eq(pose.position.length(), 3)
  assert_eq(pose.orientation.length(), 4)
  assert_eq(pose.coordinate_frame, "camera")
  assert_true((pose.confidence - 0.85).abs() < 0.0000000001)
}

///|
test "plan_grasp: plans grasp from object pose" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let pose = @robot_vision_advanced.ObjectPose::{
    position: [0.5, 0.3, 0.8],
    orientation: [0.0, 0.0, 0.0, 1.0],
    confidence: 0.9,
    object_id: 1,
    coordinate_frame: "camera",
  }
  let grasp = @robot_vision_advanced.plan_grasp(pose, [0.1, 0.1, 0.1], config)
  assert_eq(grasp.grasp_position.length(), 3)
  assert_eq(grasp.approach_direction.length(), 3)
  assert_true(grasp.is_force_closure)
  assert_true((grasp.quality_score - 0.8).abs() < 0.0000000001)
  assert_true(grasp.grasp_type is @robot_vision_advanced.GraspType::ParallelJaw)
}

///|
test "plan_arm_trajectory: plans trajectory between poses" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let start = @robot_vision_advanced.ObjectPose::{
    position: [0.0, 0.0, 0.0],
    orientation: [0.0, 0.0, 0.0, 1.0],
    confidence: 1.0,
    object_id: 0,
    coordinate_frame: "base",
  }
  let goal = @robot_vision_advanced.ObjectPose::{
    position: [1.0, 0.5, 0.8],
    orientation: [0.0, 0.0, 0.0, 1.0],
    confidence: 1.0,
    object_id: 1,
    coordinate_frame: "base",
  }
  let traj = @robot_vision_advanced.plan_arm_trajectory(start, goal, config)
  assert_eq(traj.num_points, 50)
  assert_eq(traj.points.length(), 50)
  assert_true(traj.is_collision_free)
  assert_true(traj.is_singularity_free)
  assert_eq(traj.planner_type, "RRTConnect")
}

///|
test "visual_servoing: computes control from error" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let current = @robot_vision_advanced.ObjectPose::{
    position: [0.0, 0.0, 0.0],
    orientation: [0.0, 0.0, 0.0, 1.0],
    confidence: 1.0,
    object_id: 0,
    coordinate_frame: "camera",
  }
  let desired = @robot_vision_advanced.ObjectPose::{
    position: [1.0, 2.0, 3.0],
    orientation: [0.0, 0.0, 0.0, 1.0],
    confidence: 1.0,
    object_id: 0,
    coordinate_frame: "camera",
  }
  let control = @robot_vision_advanced.visual_servoing(current, desired, config)
  assert_eq(control.length(), 3)
  assert_true((control[0] - 0.5).abs() < 0.0000000001)
  assert_true((control[1] - 1.0).abs() < 0.0000000001)
  assert_true((control[2] - 1.5).abs() < 0.0000000001)
}

///|
test "generate_point_cloud: generates point cloud from depth" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let depth_image : Array[Double] = []
  let rgb_image : Array[Array[Int32]] = []
  for _ in 0..<307200 {
    depth_image.push(1.0)
  }
  let cloud = @robot_vision_advanced.generate_point_cloud(
    depth_image, rgb_image, config,
  )
  assert_eq(cloud.width, 640)
  assert_eq(cloud.height, 480)
  assert_true(cloud.num_points >= 0)
  assert_eq(cloud.coordinate_frame, "camera")
}

///|
test "robot_vision_report_to_string: contains task info" {
  let config = @robot_vision_advanced.create_default_robot_vision_config()
  let report = @robot_vision_advanced.robot_vision_report_to_string(
    @robot_vision_advanced.RobotVisionTaskType::VisualServoing,
    config,
    "Servoing converged",
  )
  assert_true(report.contains("机器人视觉高级报告"))
  assert_true(report.contains("视觉伺服"))
  assert_true(report.contains("Servoing converged"))
}
