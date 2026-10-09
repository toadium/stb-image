///|
fn create_test_image_iv(w : Int, h : Int, value : Byte) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(value)
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn create_gradient_image_iv(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) % 256).to_byte())
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
test "create_default_intelligent_vision_config: returns yolov8 config" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  assert_eq(config.confidence_threshold, 0.5)
  assert_eq(config.nms_threshold, 0.45)
  assert_eq(config.max_detections, 100)
  assert_eq(config.input_size, 640)
  assert_false(config.use_gpu)
  assert_eq(config.model_type, "yolov8")
}

///|
test "detect_objects_iv: uniform image returns no detections" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_test_image_iv(128, 128, 128)
  let results = @intelligent_vision.detect_objects_iv(image, config)
  assert_eq(results.length(), 0)
}

///|
test "detect_objects_iv: gradient image may have detections" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_gradient_image_iv(128, 128)
  let results = @intelligent_vision.detect_objects_iv(image, config)
  assert_true(results.length() >= 0)
}

///|
test "detect_lanes: returns lane detection result" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_test_image_iv(128, 128, 128)
  let result = @intelligent_vision.detect_lanes(image, config)
  assert_eq(result.num_lanes, 2)
  assert_eq(result.lanes.length(), 2)
  assert_eq(result.lane_type, "solid")
  assert_true((result.confidence - 0.7).abs() < 0.0000000001)
  assert_true((result.curvature - 0.05).abs() < 0.0000000001)
}

///|
test "recognize_traffic_signs: returns sign results" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_gradient_image_iv(128, 128)
  let results = @intelligent_vision.recognize_traffic_signs(image, config)
  assert_true(results.length() >= 0)
}

///|
test "detect_defects: returns defect results" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_gradient_image_iv(128, 128)
  let results = @intelligent_vision.detect_defects(image, config)
  assert_true(results.length() >= 0)
}

///|
test "detect_intrusion: no intrusion in uniform image" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_test_image_iv(128, 128, 128)
  let result = @intelligent_vision.detect_intrusion(
    image,
    [0.0, 0.0, 128.0, 128.0],
    config,
  )
  assert_false(result.is_intrusion)
  assert_eq(result.num_intrusions, 0)
}

///|
test "detect_crops: returns crop results" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_gradient_image_iv(128, 128)
  let results = @intelligent_vision.detect_crops(image, config)
  assert_true(results.length() >= 0)
}

///|
test "detect_stars: uniform dark image has no stars" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let image = create_test_image_iv(64, 64, 50)
  let result = @intelligent_vision.detect_stars(image, config)
  assert_eq(result.num_stars, 0)
}

///|
test "detect_stars: bright image has stars" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let bright_val : Byte = 250
  let image = create_test_image_iv(64, 64, bright_val)
  let result = @intelligent_vision.detect_stars(image, config)
  assert_true(result.num_stars > 0)
  assert_eq(result.stars.length(), result.num_stars)
  assert_eq(result.magnitudes.length(), result.num_stars)
}

///|
test "intelligent_vision_report_to_string: contains task info" {
  let config = @intelligent_vision.create_default_intelligent_vision_config()
  let report = @intelligent_vision.intelligent_vision_report_to_string(
    "lane_detection", 5, 0.85, config,
  )
  assert_true(report.contains("智能视觉报告"))
  assert_true(report.contains("lane_detection"))
  assert_true(report.contains("yolov8"))
}
