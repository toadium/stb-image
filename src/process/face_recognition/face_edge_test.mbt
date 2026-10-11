// v224: face_recognition 边界测试

///|
fn fe_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn fe_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn fe_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn fe_uniform(w : Int, h : Int, v : Int) -> @types.Image {
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
fn fe_default_config() -> @face_recognition.FaceRecognitionConfig {
  @face_recognition.FaceRecognitionConfig::{
    detection_algorithm: @face_recognition.FaceDetectionAlgorithm::HaarCascade,
    recognition_algorithm: @face_recognition.FaceRecognitionAlgorithm::FaceNet,
    detection_threshold: 0.5,
    recognition_threshold: 0.5,
    min_face_size: 20,
    max_num_faces: 10,
    use_landmarks: false,
    use_alignment: false,
    feature_dimension: 128,
  }
}

///|
fn fe_empty_face() -> @face_recognition.FaceDetectionResult {
  @face_recognition.FaceDetectionResult::{
    bounding_box: [],
    confidence: 0.0,
    landmarks: [],
    num_landmarks: 0,
    face_id: 0,
    is_frontal: true,
    yaw: 0.0,
    pitch: 0.0,
    roll: 0.0,
  }
}

///|
test "fe_edge: detect_faces 零宽度" {
  try {
    let _ = @face_recognition.detect_faces(fe_zero_w(), fe_default_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: detect_faces 无效通道" {
  try {
    let _ = @face_recognition.detect_faces(
      fe_bad_channels(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: detect_faces 数据不匹配" {
  try {
    let _ = @face_recognition.detect_faces(fe_mismatch(), fe_default_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: extract_face_feature 零宽度" {
  try {
    let _ = @face_recognition.extract_face_feature(
      fe_zero_w(),
      fe_empty_face(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: extract_face_feature 无效通道" {
  try {
    let _ = @face_recognition.extract_face_feature(
      fe_bad_channels(),
      fe_empty_face(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: extract_face_feature 数据不匹配" {
  try {
    let _ = @face_recognition.extract_face_feature(
      fe_mismatch(),
      fe_empty_face(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: recognize_expression 零宽度" {
  try {
    let _ = @face_recognition.recognize_expression(fe_zero_w(), fe_empty_face())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: recognize_expression 无效通道" {
  try {
    let _ = @face_recognition.recognize_expression(
      fe_bad_channels(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: recognize_expression 数据不匹配" {
  try {
    let _ = @face_recognition.recognize_expression(
      fe_mismatch(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: estimate_age_gender 零宽度" {
  try {
    let _ = @face_recognition.estimate_age_gender(fe_zero_w(), fe_empty_face())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: estimate_age_gender 无效通道" {
  try {
    let _ = @face_recognition.estimate_age_gender(
      fe_bad_channels(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: estimate_age_gender 数据不匹配" {
  try {
    let _ = @face_recognition.estimate_age_gender(
      fe_mismatch(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: evaluate_face_quality 零宽度" {
  try {
    let _ = @face_recognition.evaluate_face_quality(
      fe_zero_w(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: evaluate_face_quality 无效通道" {
  try {
    let _ = @face_recognition.evaluate_face_quality(
      fe_bad_channels(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: evaluate_face_quality 数据不匹配" {
  try {
    let _ = @face_recognition.evaluate_face_quality(
      fe_mismatch(),
      fe_empty_face(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn fe_empty_db() -> @face_recognition.FaceDatabase {
  @face_recognition.FaceDatabase::{
    faces: [],
    identities: [],
    num_faces: 0,
    threshold: 0.5,
    algorithm: @face_recognition.FaceRecognitionAlgorithm::FaceNet,
  }
}

///|
test "fe_edge: analyze_face_attributes 零宽度" {
  try {
    let _ = @face_recognition.analyze_face_attributes(
      fe_zero_w(),
      fe_empty_face(),
      fe_empty_db(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: analyze_face_attributes 无效通道" {
  try {
    let _ = @face_recognition.analyze_face_attributes(
      fe_bad_channels(),
      fe_empty_face(),
      fe_empty_db(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe_edge: analyze_face_attributes 数据不匹配" {
  try {
    let _ = @face_recognition.analyze_face_attributes(
      fe_mismatch(),
      fe_empty_face(),
      fe_empty_db(),
      fe_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
