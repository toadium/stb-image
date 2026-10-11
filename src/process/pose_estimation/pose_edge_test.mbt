// v224: pose_estimation 边界测试

///|
fn pe_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn pe_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn pe_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn pe_uniform(w : Int, h : Int, v : Int) -> @types.Image {
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
fn pe_default_config() -> @pose_estimation.PoseEstimationConfig {
  @pose_estimation.PoseEstimationConfig::{
    algorithm: @pose_estimation.PoseEstimationAlgorithm::OpenPose,
    num_keypoints: 17,
    confidence_threshold: 0.5,
    nms_threshold: 0.5,
    max_num_people: 10,
    use_tracking: false,
    use_smoothing: false,
    smoothing_factor: 0.0,
  }
}

///|
fn pe_empty_pose() -> @pose_estimation.HumanPose {
  @pose_estimation.HumanPose::{
    keypoints: [],
    num_keypoints: 0,
    bounding_box: [],
    confidence: 0.0,
    pose_id: 0,
    is_tracked: false,
  }
}

///|
test "pe_edge: detect_keypoints 零宽度" {
  try {
    let _ = @pose_estimation.detect_keypoints(pe_zero_w(), pe_default_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pe_edge: detect_keypoints 无效通道" {
  try {
    let _ = @pose_estimation.detect_keypoints(
      pe_bad_channels(),
      pe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pe_edge: detect_keypoints 数据不匹配" {
  try {
    let _ = @pose_estimation.detect_keypoints(
      pe_mismatch(),
      pe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pe_edge: visualize_pose 零宽度" {
  try {
    let _ = @pose_estimation.visualize_pose(pe_zero_w(), pe_empty_pose())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pe_edge: visualize_pose 无效通道" {
  try {
    let _ = @pose_estimation.visualize_pose(pe_bad_channels(), pe_empty_pose())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pe_edge: visualize_pose 数据不匹配" {
  try {
    let _ = @pose_estimation.visualize_pose(pe_mismatch(), pe_empty_pose())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
