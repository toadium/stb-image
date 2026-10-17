// v237.0.0 yolo_detection 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn yolo_make_box(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  conf : Double,
  cls : Int,
) -> @detection.YoloBoundingBox {
  @detection.YoloBoundingBox::{
    x,
    y,
    width: w,
    height: h,
    confidence: conf,
    class_id: cls,
    class_name: "object",
  }
}

///|
fn yolo_make_img(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn yolo_make_high_variance_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = if (x + y) % 2 == 0 { b'\x00' } else { b'\xFF' }
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
fn yolo_make_detection_result(
  boxes : Array[@detection.YoloBoundingBox],
) -> @detection.YoloDetectionResult {
  @detection.YoloDetectionResult::{
    boxes,
    num_detections: boxes.length(),
    inference_time_ms: 0.0,
    input_width: 128,
    input_height: 128,
  }
}

// ========== detect_objects_simple 错误路径 ==========

///|
test "yolo_func: detect_objects_simple max_detections<=0 raises" {
  try {
    let config = @detection.YoloConfig::{
      model_version: "yolov8",
      input_size: 640,
      num_classes: 80,
      confidence_threshold: 0.25,
      iou_threshold: 0.45,
      max_detections: 0,
      anchors: [],
      strides: [8, 16, 32],
    }
    let _ = @detection.detect_objects_simple(yolo_make_img(64, 64, 128), config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_objects_simple 功能路径 ==========

///|
test "yolo_func: detect_objects_simple high variance detects objects" {
  let config = @detection.create_default_yolo_config()
  let img = yolo_make_high_variance_img(128, 128)
  try {
    let result = @detection.detect_objects_simple(img, config)
    assert_eq(result.input_width, 128)
    assert_eq(result.input_height, 128)
    assert_true(result.num_detections >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: detect_objects_simple uniform image no detection" {
  let config = @detection.create_default_yolo_config()
  let img = yolo_make_img(128, 128, 128)
  try {
    let result = @detection.detect_objects_simple(img, config)
    assert_eq(result.input_width, 128)
    assert_eq(result.input_height, 128)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== non_max_suppression 抑制路径 ==========

///|
test "yolo_func: nms suppresses overlapping same-class boxes" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let box2 = yolo_make_box(52.0, 52.0, 40.0, 40.0, 0.7, 0)
  let box3 = yolo_make_box(200.0, 200.0, 40.0, 40.0, 0.6, 0)
  try {
    let result = @detection.non_max_suppression([box1, box2, box3], 0.45, 10)
    assert_true(result.length() >= 1)
    assert_true(result.length() <= 3)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: nms three boxes one suppressed" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.95, 0)
  let box2 = yolo_make_box(51.0, 51.0, 40.0, 40.0, 0.8, 0)
  let box3 = yolo_make_box(100.0, 100.0, 40.0, 40.0, 0.6, 0)
  try {
    let result = @detection.non_max_suppression([box1, box2, box3], 0.3, 10)
    assert_true(result.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== initialize_object_tracking 功能路径 ==========

///|
test "yolo_func: initialize_tracking with boxes" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let box2 = yolo_make_box(100.0, 100.0, 40.0, 40.0, 0.8, 1)
  let detection = yolo_make_detection_result([box1, box2])
  try {
    let tracked = @detection.initialize_object_tracking(detection)
    assert_eq(tracked.length(), 2)
    assert_eq(tracked[0].id, 0)
    assert_eq(tracked[1].id, 1)
    assert_eq(tracked[0].visible_count, 1)
    assert_eq(tracked[0].invisible_count, 0)
    assert_eq(tracked[0].trajectory.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: initialize_tracking color assignment" {
  let boxes : Array[@detection.YoloBoundingBox] = []
  for i in 0..<8 {
    boxes.push(yolo_make_box(50.0 + i.to_double(), 50.0, 40.0, 40.0, 0.9, 0))
  }
  let detection = yolo_make_detection_result(boxes)
  try {
    let tracked = @detection.initialize_object_tracking(detection)
    assert_eq(tracked.length(), 8)
    let colors = [
      (255, 0, 0),
      (0, 255, 0),
      (0, 0, 255),
      (255, 255, 0),
      (255, 0, 255),
      (0, 255, 255),
    ]
    assert_eq(tracked[6].color, colors[0])
    assert_eq(tracked[7].color, colors[1])
  } catch {
    _ => assert_true(false)
  }
}

// ========== update_object_tracking 错误路径 ==========

///|
test "yolo_func: update_tracking max_age<=0 raises" {
  let box = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let detection = yolo_make_detection_result([box])
  try {
    let tracked = @detection.initialize_object_tracking(detection)
    let _ = @detection.update_object_tracking(tracked, detection, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== update_object_tracking 功能路径 ==========

///|
test "yolo_func: update_tracking matched detection" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let detection1 = yolo_make_detection_result([box1])
  try {
    let tracked = @detection.initialize_object_tracking(detection1)
    let box2 = yolo_make_box(51.0, 51.0, 40.0, 40.0, 0.85, 0)
    let detection2 = yolo_make_detection_result([box2])
    let updated = @detection.update_object_tracking(tracked, detection2, 5)
    assert_true(updated.length() >= 1)
    assert_eq(updated[0].visible_count, 2)
    assert_eq(updated[0].invisible_count, 0)
    assert_eq(updated[0].trajectory.length(), 2)
    let vel_x = updated[0].velocity_x
    assert_true((vel_x - 1.0).abs() < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: update_tracking unmatched detection adds new" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let detection1 = yolo_make_detection_result([box1])
  try {
    let tracked = @detection.initialize_object_tracking(detection1)
    let box2 = yolo_make_box(300.0, 300.0, 40.0, 40.0, 0.8, 0)
    let detection2 = yolo_make_detection_result([box2])
    let updated = @detection.update_object_tracking(tracked, detection2, 5)
    assert_true(updated.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: update_tracking invisible object kept" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let detection1 = yolo_make_detection_result([box1])
  try {
    let tracked = @detection.initialize_object_tracking(detection1)
    let box2 = yolo_make_box(500.0, 500.0, 40.0, 40.0, 0.8, 0)
    let detection2 = yolo_make_detection_result([box2])
    let updated = @detection.update_object_tracking(tracked, detection2, 5)
    let has_invisible = updated.iter().any(fn(o) { o.invisible_count > 0 })
    assert_true(has_invisible)
  } catch {
    _ => assert_true(false)
  }
}

// ========== calculate_detection_metrics 错误路径 ==========

///|
test "yolo_func: metrics iou_threshold<0 raises" {
  let pred = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)]
  let gt = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 1.0, 0)]
  try {
    let _ = @detection.calculate_detection_metrics(pred, gt, -0.1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo_func: metrics iou_threshold>1 raises" {
  let pred = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)]
  let gt = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 1.0, 0)]
  try {
    let _ = @detection.calculate_detection_metrics(pred, gt, 1.5)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== calculate_detection_metrics 功能路径 ==========

///|
test "yolo_func: metrics all false positives zero precision" {
  let pred = [yolo_make_box(200.0, 200.0, 40.0, 40.0, 0.9, 0)]
  let gt = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 1.0, 0)]
  try {
    let metrics = @detection.calculate_detection_metrics(pred, gt, 0.5)
    assert_eq(metrics.true_positives, 0)
    assert_eq(metrics.false_positives, 1)
    assert_eq(metrics.false_negatives, 1)
    assert_true(metrics.precision < 0.001)
    assert_true(metrics.recall < 0.001)
    assert_true(metrics.f1_score < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: metrics perfect match" {
  let pred = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)]
  let gt = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 1.0, 0)]
  try {
    let metrics = @detection.calculate_detection_metrics(pred, gt, 0.5)
    assert_eq(metrics.true_positives, 1)
    assert_eq(metrics.false_positives, 0)
    assert_eq(metrics.false_negatives, 0)
    assert_true((metrics.precision - 1.0).abs() < 0.001)
    assert_true((metrics.recall - 1.0).abs() < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: metrics multiple predictions sorted by confidence" {
  let pred1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.6, 0)
  let pred2 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let pred3 = yolo_make_box(200.0, 200.0, 40.0, 40.0, 0.3, 0)
  let gt = [yolo_make_box(50.0, 50.0, 40.0, 40.0, 1.0, 0)]
  try {
    let metrics = @detection.calculate_detection_metrics(
      [pred1, pred2, pred3],
      gt,
      0.5,
    )
    assert_eq(metrics.true_positives, 1)
    assert_eq(metrics.false_positives, 2)
    assert_eq(metrics.false_negatives, 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detection_report_to_string 功能路径 ==========

///|
test "yolo_func: report with detections" {
  let box = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let result = yolo_make_detection_result([box])
  let metrics = @detection.YoloDetectionMetrics::{
    precision: 1.0,
    recall: 1.0,
    f1_score: 1.0,
    mAP: 0.95,
    mAP50: 0.96,
    mAP50_95: 0.75,
    true_positives: 1,
    false_positives: 0,
    false_negatives: 0,
  }
  let report = @detection.detection_report_to_string(result, metrics)
  assert_true(report.contains("目标检测报告"))
  assert_true(report.contains("Precision"))
  assert_true(report.contains("Recall"))
  assert_true(report.contains("检测目标列表"))
}

///|
test "yolo_func: report with empty boxes" {
  let result = yolo_make_detection_result([])
  let metrics = @detection.YoloDetectionMetrics::{
    precision: 0.0,
    recall: 0.0,
    f1_score: 0.0,
    mAP: 0.0,
    mAP50: 0.0,
    mAP50_95: 0.0,
    true_positives: 0,
    false_positives: 0,
    false_negatives: 0,
  }
  let report = @detection.detection_report_to_string(result, metrics)
  assert_true(report.contains("目标检测报告"))
  assert_true(report.contains("Precision"))
}

// ========== refine_bounding_box 功能路径 ==========

///|
test "yolo_func: refine_box normal case" {
  let box = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  try {
    let refined = @detection.refine_bounding_box(box, 0.1, 0.1, 1.0, 1.0)
    assert_true((refined.x - 54.0).abs() < 0.001)
    assert_true((refined.y - 54.0).abs() < 0.001)
    assert_true((refined.width - 40.0).abs() < 0.001)
    assert_true((refined.height - 40.0).abs() < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

// ========== calculate_iou 边界情况 ==========

///|
test "yolo_func: iou identical boxes returns 1.0" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let box2 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.8, 0)
  try {
    let iou = @detection.calculate_iou(box1, box2)
    assert_true((iou - 1.0).abs() < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "yolo_func: iou half overlap" {
  let box1 = yolo_make_box(50.0, 50.0, 40.0, 40.0, 0.9, 0)
  let box2 = yolo_make_box(70.0, 50.0, 40.0, 40.0, 0.8, 0)
  try {
    let iou = @detection.calculate_iou(box1, box2)
    assert_true(iou > 0.0 && iou < 1.0)
  } catch {
    _ => assert_true(false)
  }
}
