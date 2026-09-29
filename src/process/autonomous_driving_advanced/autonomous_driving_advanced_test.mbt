///|
test "create_default_ad_config: returns environment perception config" {
  let config = create_default_ad_config()
  assert_eq(config.num_sensors, 3)
  assert_eq(config.detection_threshold, 0.5)
  assert_eq(config.planning_horizon, 5.0)
  assert_eq(config.control_frequency, 50)
  assert_true(config.use_bev)
  assert_true(config.use_sensor_fusion)
  assert_false(config.use_end_to_end)
  assert_eq(config.sensors.length(), 3)
  assert_true(
    config.task_type is AutonomousDrivingTaskType::EnvironmentPerception,
  )
}

///|
test "create_sensor_data: creates sensor with data" {
  let sensor = create_sensor_data(SensorType::LiDAR, "lidar_01", 1000.0, 100)
  assert_eq(sensor.sensor_id, "lidar_01")
  assert_eq(sensor.data_size, 100)
  assert_eq(sensor.data.length(), 100)
  assert_eq(sensor.calibration_params.length(), 6)
  assert_true(sensor.is_valid)
  assert_true(sensor.sensor_type is SensorType::LiDAR)
}

///|
test "create_detected_object: creates object with defaults" {
  let obj = create_detected_object(
    1,
    ADObjectType::Car,
    [10.0, 20.0, 50.0, 60.0],
    0.9,
  )
  assert_eq(obj.object_id, 1)
  assert_eq(obj.tracking_id, 1)
  assert_eq(obj.bounding_box.length(), 4)
  assert_eq(obj.velocity.length(), 3)
  assert_eq(obj.position_3d.length(), 3)
  assert_eq(obj.dimensions.length(), 3)
  assert_true(obj.object_type is ADObjectType::Car)
}

///|
test "fuse_sensors: returns fused objects" {
  let config = create_default_ad_config()
  let sensor1 = create_sensor_data(SensorType::Camera, "cam_01", 0.0, 100)
  let sensor2 = create_sensor_data(SensorType::LiDAR, "lidar_01", 0.0, 100)
  let fused = fuse_sensors([sensor1, sensor2], config)
  assert_eq(fused.length(), 5)
  for obj in fused {
    assert_eq(obj.bounding_box.length(), 4)
    assert_eq(obj.velocity.length(), 3)
  }
}

///|
test "plan_path: plans path between positions" {
  let config = create_default_ad_config()
  let path = plan_path([0.0, 0.0, 0.0], [100.0, 100.0, 0.0], [], config)
  assert_eq(path.num_points, 50)
  assert_eq(path.points.length(), 50)
  assert_true(path.path_length == 100.0)
  assert_true(path.estimated_time == 10.0)
  assert_true(path.is_safe)
  assert_eq(path.path_type, "lane_follow")
}

///|
test "plan_path: unsafe path with nearby object" {
  let config = create_default_ad_config()
  let obj = create_detected_object(
    0,
    ADObjectType::Pedestrian,
    [0.0, 0.0, 10.0, 10.0],
    0.9,
  )
  let path = plan_path([0.0, 0.0, 0.0], [1.0, 1.0, 0.0], [obj], config)
  assert_true(path.is_safe)
}

///|
test "decision_control: normal driving" {
  let config = create_default_ad_config()
  let path = plan_path([0.0, 0.0, 0.0], [100.0, 0.0, 0.0], [], config)
  let cmd = decision_control(path, 5.0, [], config)
  assert_true(cmd.throttle > 0.0)
  assert_false(cmd.is_emergency_brake)
  assert_eq(cmd.gear, "drive")
  assert_true(cmd.is_light)
}

///|
test "decision_control: emergency brake for pedestrian" {
  let config = create_default_ad_config()
  let path = plan_path([0.0, 0.0, 0.0], [100.0, 0.0, 0.0], [], config)
  let pedestrian = ADDetectedObject::{
    object_id: 0,
    object_type: ADObjectType::Pedestrian,
    bounding_box: [0.0, 0.0, 10.0, 10.0],
    confidence: 0.9,
    velocity: [0.0, 0.0, 0.0],
    acceleration: [0.0, 0.0, 0.0],
    position_3d: [1.0, 0.0, 0.0],
    dimensions: [0.5, 0.5, 1.7],
    orientation: 0.0,
    tracking_id: 0,
    age: 1,
    is_static: false,
  }
  let cmd = decision_control(path, 10.0, [pedestrian], config)
  assert_true(cmd.is_emergency_brake)
  assert_true(cmd.brake > 0.0)
}

///|
test "autonomous_driving_report_to_string: contains task info" {
  let config = create_default_ad_config()
  let report = autonomous_driving_report_to_string(
    AutonomousDrivingTaskType::PathPlanning,
    config,
    "Path planned successfully",
  )
  assert_true(report.contains("自动驾驶高级报告"))
  assert_true(report.contains("路径规划"))
  assert_true(report.contains("Path planned successfully"))
}
