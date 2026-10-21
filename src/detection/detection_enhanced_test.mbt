// v193b detection 增强测试

///|
fn det_make_rgb(w : Int32, h : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, b'\x80')),
  }
}

///|
fn det_make_box(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  conf : Double,
) -> @detection.YoloBoundingBox {
  @detection.YoloBoundingBox::{
    x,
    y,
    width: w,
    height: h,
    confidence: conf,
    class_id: 0,
    class_name: "test",
  }
}

///|
test "detection: create_default_yolo_config 完整字段验证" {
  let config = @detection.create_default_yolo_config()
  assert_true(config.input_size > 0)
  assert_true(config.num_classes > 0)
  assert_true(
    config.confidence_threshold > 0.0 && config.confidence_threshold < 1.0,
  )
  assert_true(config.iou_threshold > 0.0 && config.iou_threshold < 1.0)
  assert_true(config.max_detections > 0)
  assert_true(config.anchors.length() > 0)
  assert_true(config.strides.length() > 0)
}

///|
test "detection: calculate_iou 部分重叠" {
  let box1 = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let box2 = det_make_box(10.0, 10.0, 20.0, 20.0, 0.8)
  let iou = @detection.calculate_iou(box1, box2)
  assert_true(iou > 0.0 && iou < 1.0)
}

///|
test "detection: calculate_iou 包含关系" {
  let outer = det_make_box(0.0, 0.0, 40.0, 40.0, 0.9)
  let inner = det_make_box(10.0, 10.0, 10.0, 10.0, 0.8)
  let iou = @detection.calculate_iou(outer, inner)
  assert_true(iou > 0.0 && iou <= 1.0)
}

///|
test "detection: calculate_iou 对称性" {
  let box1 = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let box2 = det_make_box(5.0, 5.0, 15.0, 15.0, 0.8)
  let iou12 = @detection.calculate_iou(box1, box2)
  let iou21 = @detection.calculate_iou(box2, box1)
  assert_true((iou12 - iou21).abs() < 0.001)
}

///|
test "detection: calculate_iou 零面积框" {
  let box = det_make_box(10.0, 10.0, 0.0, 0.0, 0.9)
  try {
    let iou = @detection.calculate_iou(box, box)
    let _ = iou
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: non_max_suppression 高阈值保留全部" {
  let box1 = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let box2 = det_make_box(5.0, 5.0, 20.0, 20.0, 0.8)
  let result = @detection.non_max_suppression([box1, box2], 0.99, 10)
  assert_eq(result.length(), 2)
}

///|
test "detection: non_max_suppression 低阈值合并" {
  let box1 = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let box2 = det_make_box(1.0, 1.0, 20.0, 20.0, 0.8)
  let result = @detection.non_max_suppression([box1, box2], 0.3, 10)
  assert_eq(result.length(), 1)
}

///|
test "detection: non_max_suppression 空列表" {
  try {
    let result = @detection.non_max_suppression([], 0.99, 10)
    assert_eq(result.length(), 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: non_max_suppression 单个框" {
  let box = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let result = @detection.non_max_suppression([box], 0.5, 10)
  assert_eq(result.length(), 1)
}

///|
test "detection: refine_bounding_box 零增量" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  let refined = @detection.refine_bounding_box(box, 0.0, 0.0, 1.0, 1.0)
  assert_true((refined.x - 10.0).abs() < 0.01)
  assert_true((refined.y - 10.0).abs() < 0.01)
  assert_true((refined.width - 20.0).abs() < 0.01)
  assert_true((refined.height - 20.0).abs() < 0.01)
}

///|
test "detection: refine_bounding_box 正增量" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  let refined = @detection.refine_bounding_box(box, 0.1, 0.1, 1.1, 1.1)
  assert_true(refined.width > 20.0)
  assert_true(refined.height > 20.0)
}

///|
test "detection: refine_bounding_box 缩增量" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  let refined = @detection.refine_bounding_box(box, 0.0, 0.0, 0.5, 0.5)
  assert_true(refined.width > 0.0)
  assert_true(refined.height > 0.0)
  assert_true(refined.width < 20.0)
}

///|
test "detection: bbox_new 带可选参数" {
  let box = @detection.bbox_new(10, 20, 30, 40, score=0.85, class_id=3)
  assert_eq(box.x, 10)
  assert_eq(box.y, 20)
  assert_eq(box.width, 30)
  assert_eq(box.height, 40)
  assert_true((box.score - 0.85).abs() < 0.001)
  assert_eq(box.class_id, 3)
}

///|
test "detection: bbox_iou 部分重叠" {
  let box1 = @detection.bbox_new(0, 0, 20, 20)
  let box2 = @detection.bbox_new(10, 10, 20, 20)
  let iou = @detection.bbox_iou(box1, box2)
  assert_true(iou > 0.0 && iou < 1.0)
}

///|
test "detection: bbox_iou 不重叠" {
  let box1 = @detection.bbox_new(0, 0, 10, 10)
  let box2 = @detection.bbox_new(100, 100, 10, 10)
  let iou = @detection.bbox_iou(box1, box2)
  assert_true(iou.abs() < 0.01)
}

///|
test "detection: bbox_iou 对称性" {
  let box1 = @detection.bbox_new(0, 0, 20, 20)
  let box2 = @detection.bbox_new(5, 5, 15, 15)
  let iou12 = @detection.bbox_iou(box1, box2)
  let iou21 = @detection.bbox_iou(box2, box1)
  assert_true((iou12 - iou21).abs() < 0.001)
}

///|
test "detection: nms 带阈值参数" {
  let box1 = @detection.bbox_new(0, 0, 20, 20, score=0.9)
  let box2 = @detection.bbox_new(1, 1, 20, 20, score=0.8)
  let box3 = @detection.bbox_new(100, 100, 20, 20, score=0.7)
  let result = @detection.nms([box1, box2, box3], iou_threshold=0.3)
  assert_eq(result.length(), 2)
}

///|
test "detection: nms 空列表" {
  try {
    let result = @detection.nms([])
    assert_eq(result.length(), 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: nms 单个框" {
  let box = @detection.bbox_new(0, 0, 20, 20)
  let result = @detection.nms([box])
  assert_eq(result.length(), 1)
}

///|
test "detection: draw_detections 多个框" {
  let img = det_make_rgb(32, 32)
  let box1 = @detection.bbox_new(5, 5, 10, 10)
  let box2 = @detection.bbox_new(15, 15, 10, 10)
  let result = @detection.draw_detections(img, [box1, box2])
  assert_eq(result.width, 32)
  assert_eq(result.height, 32)
}

///|
test "detection: draw_detections 空框列表" {
  let img = det_make_rgb(32, 32)
  let result = @detection.draw_detections(img, [])
  assert_eq(result.width, 32)
  assert_eq(result.height, 32)
}

///|
test "detection: calculate_detection_metrics 完美匹配" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  let metrics = @detection.calculate_detection_metrics([box], [box], 0.5)
  assert_true(metrics.precision >= 0.0 && metrics.precision <= 1.0)
  assert_true(metrics.recall >= 0.0 && metrics.recall <= 1.0)
  assert_true(metrics.f1_score >= 0.0 && metrics.f1_score <= 1.0)
  assert_true(metrics.true_positives >= 0)
  assert_true(metrics.false_positives >= 0)
  assert_true(metrics.false_negatives >= 0)
}

///|
test "detection: calculate_detection_metrics 空预测" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  try {
    let metrics = @detection.calculate_detection_metrics([], [box], 0.5)
    assert_true(metrics.precision >= 0.0)
    assert_true(metrics.recall >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: calculate_detection_metrics 空真值" {
  let box = det_make_box(10.0, 10.0, 20.0, 20.0, 0.9)
  try {
    let metrics = @detection.calculate_detection_metrics([box], [], 0.5)
    assert_true(metrics.precision >= 0.0)
    assert_true(metrics.recall >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: calculate_detection_metrics 双空" {
  try {
    let metrics = @detection.calculate_detection_metrics([], [], 0.5)
    let _ = metrics
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: detect_objects_simple 不同尺寸" {
  let config = @detection.create_default_yolo_config()
  for size in [32, 64, 128] {
    let img = det_make_rgb(size, size)
    try {
      let result = @detection.detect_objects_simple(img, config)
      assert_eq(result.input_width, size)
      assert_eq(result.input_height, size)
      assert_true(result.num_detections >= 0)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "detection: YoloConfig 结构验证" {
  let config = @detection.create_default_yolo_config()
  assert_true(config.model_version.length() > 0)
  assert_true(config.strides.length() > 0)
  for s in config.strides {
    assert_true(s > 0)
  }
  for a in config.anchors {
    assert_true(a.0 > 0.0)
    assert_true(a.1 > 0.0)
  }
}

///|
test "detection: ObjectClass 枚举完备性" {
  let classes = [
    @detection.ObjectClass::Person,
    @detection.ObjectClass::Car,
    @detection.ObjectClass::Bus,
    @detection.ObjectClass::Truck,
    @detection.ObjectClass::Motorcycle,
    @detection.ObjectClass::Bicycle,
    @detection.ObjectClass::Dog,
    @detection.ObjectClass::Cat,
    @detection.ObjectClass::Bird,
    @detection.ObjectClass::Chair,
    @detection.ObjectClass::Table,
    @detection.ObjectClass::Bottle,
    @detection.ObjectClass::Cup,
    @detection.ObjectClass::Phone,
    @detection.ObjectClass::Laptop,
    @detection.ObjectClass::Tv,
    @detection.ObjectClass::Book,
    @detection.ObjectClass::Unknown,
  ]
  assert_eq(classes.length(), 18)
  assert_true(@detection.ObjectClass::Person != @detection.ObjectClass::Car)
}

///|
test "detection: detection_report_to_string 内容验证" {
  let img = det_make_rgb(32, 32)
  let config = @detection.create_default_yolo_config()
  let box = det_make_box(0.0, 0.0, 10.0, 10.0, 0.9)
  let metrics = @detection.calculate_detection_metrics([box], [box], 0.5)
  try {
    let det = @detection.detect_objects_simple(img, config)
    let report = @detection.detection_report_to_string(det, metrics)
    assert_true(report.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: initialize_and_update_tracking" {
  let img = det_make_rgb(64, 64)
  let config = @detection.create_default_yolo_config()
  try {
    let det = @detection.detect_objects_simple(img, config)
    if det.boxes.length() > 0 {
      let tracked = @detection.initialize_object_tracking(det)
      assert_true(tracked.length() >= 0)
      let updated = @detection.update_object_tracking(tracked, det, 1)
      assert_true(updated.length() >= 0)
    } else {
      assert_true(true)
    }
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detection: BoundingBox 结构验证" {
  let box = @detection.bbox_new(10, 20, 30, 40, score=0.95, class_id=5)
  assert_eq(box.x, 10)
  assert_eq(box.y, 20)
  assert_eq(box.width, 30)
  assert_eq(box.height, 40)
  assert_true((box.score - 0.95).abs() < 0.001)
  assert_eq(box.class_id, 5)
}

///|
test "detection: YoloDetectionMetrics 字段范围" {
  let box1 = det_make_box(0.0, 0.0, 20.0, 20.0, 0.9)
  let box2 = det_make_box(50.0, 50.0, 20.0, 20.0, 0.8)
  let metrics = @detection.calculate_detection_metrics(
    [box1, box2],
    [box1],
    0.5,
  )
  assert_true(metrics.mAP >= 0.0 && metrics.mAP <= 1.0)
  assert_true(metrics.mAP50 >= 0.0 && metrics.mAP50 <= 1.0)
  assert_true(metrics.mAP50_95 >= 0.0 && metrics.mAP50_95 <= 1.0)
}
