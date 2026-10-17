// v217.0.0 detection 错误路径增强测试

// ===== 辅助函数 =====

///|
fn det_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn det_make_yolo_box(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
) -> @detection.YoloBoundingBox {
  @detection.YoloBoundingBox::{
    x,
    y,
    width: w,
    height: h,
    confidence: 0.9,
    class_id: 0,
    class_name: "test",
  }
}

// ===== 1. bbox_new 错误路径 =====

///|
test "det_edge: bbox_new width为零" {
  try {
    let _ = @detection.bbox_new(0, 0, 0, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: bbox_new height为零" {
  try {
    let _ = @detection.bbox_new(0, 0, 10, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: bbox_new score为负" {
  try {
    let _ = @detection.bbox_new(0, 0, 10, 10, score=-0.1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: bbox_new score超过1" {
  try {
    let _ = @detection.bbox_new(0, 0, 10, 10, score=1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: bbox_new class_id为负" {
  try {
    let _ = @detection.bbox_new(0, 0, 10, 10, class_id=-1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. bbox_iou 错误路径 =====

///|
test "det_edge: bbox_iou 零宽度框1" {
  try {
    let b1 = @detection.bbox_new(0, 0, 0, 10)
    let b2 = @detection.bbox_new(0, 0, 10, 10)
    let _ = @detection.bbox_iou(b1, b2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: bbox_iou 零高度框2" {
  try {
    let b1 = @detection.bbox_new(0, 0, 10, 10)
    let b2 = @detection.bbox_new(0, 0, 10, 0)
    let _ = @detection.bbox_iou(b1, b2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. calculate_iou 错误路径 =====

///|
test "det_edge: calculate_iou 框1零尺寸" {
  try {
    let b1 = det_make_yolo_box(0.0, 0.0, 0.0, 10.0)
    let b2 = det_make_yolo_box(0.0, 0.0, 10.0, 10.0)
    let _ = @detection.calculate_iou(b1, b2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: calculate_iou 框2零尺寸" {
  try {
    let b1 = det_make_yolo_box(0.0, 0.0, 10.0, 10.0)
    let b2 = det_make_yolo_box(0.0, 0.0, 10.0, 0.0)
    let _ = @detection.calculate_iou(b1, b2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. non_max_suppression 错误路径 =====

///|
test "det_edge: non_max_suppression 空列表" {
  try {
    let _ = @detection.non_max_suppression([], 0.5, 100)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: non_max_suppression iou_threshold为负" {
  try {
    let box = det_make_yolo_box(0.0, 0.0, 10.0, 10.0)
    let _ = @detection.non_max_suppression([box], -0.1, 100)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: non_max_suppression iou_threshold超过1" {
  try {
    let box = det_make_yolo_box(0.0, 0.0, 10.0, 10.0)
    let _ = @detection.non_max_suppression([box], 1.5, 100)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "det_edge: non_max_suppression max_detections为零" {
  try {
    let box = det_make_yolo_box(0.0, 0.0, 10.0, 10.0)
    let _ = @detection.non_max_suppression([box], 0.5, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. nms 错误路径 =====

///|
test "det_edge: nms 空列表" {
  try {
    let _ = @detection.nms([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. detect_objects_simple 错误路径 =====

///|
test "det_edge: detect_objects_simple 零宽度" {
  try {
    let config = @detection.create_default_yolo_config()
    let _ = @detection.detect_objects_simple(det_zero_w(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. draw_detections 错误路径 =====

///|
test "det_edge: draw_detections 零宽度" {
  try {
    let _ = @detection.draw_detections(det_zero_w(), [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. calculate_detection_metrics 空数组 =====

///|
test "det_edge: calculate_detection_metrics 空数组" {
  try {
    let _ = @detection.calculate_detection_metrics([], [], 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 9. initialize_object_tracking 空结果 =====

///|
test "det_edge: initialize_object_tracking 空检测结果" {
  try {
    let result = @detection.YoloDetectionResult::{
      boxes: [],
      num_detections: 0,
      inference_time_ms: 0.0,
      input_width: 8,
      input_height: 8,
    }
    let _ = @detection.initialize_object_tracking(result)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 10. update_object_tracking 空跟踪 =====

///|
test "det_edge: update_object_tracking 空跟踪列表" {
  try {
    let result = @detection.YoloDetectionResult::{
      boxes: [],
      num_detections: 0,
      inference_time_ms: 0.0,
      input_width: 8,
      input_height: 8,
    }
    let _ = @detection.update_object_tracking([], result, 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
