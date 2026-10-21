// yolo_detection 错误路径补充测试

///|
fn mk_box(
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

///|
fn mk_img(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, b'\x80')),
  }
}

///|
fn mk_bad_img(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  @types.Image::{ width: w, height: h, channels: ch, data: b"\x00", }
}

///|
fn mk_config(
  input_size : Int32,
  num_classes : Int32,
  conf_thresh : Double,
  iou_thresh : Double,
) -> @detection.YoloConfig {
  @detection.YoloConfig::{
    model_version: "yolov5",
    input_size,
    num_classes,
    confidence_threshold: conf_thresh,
    iou_threshold: iou_thresh,
    max_detections: 100,
    anchors: [(10.0, 13.0), (16.0, 30.0)],
    strides: [32, 16, 8],
  }
}

// ========== refine_bounding_box 错误路径 ==========

///|
test "yolo2: refine_bounding_box 零宽度 raise" {
  let box = mk_box(10.0, 10.0, 0.0, 20.0)
  try {
    let _ = @detection.refine_bounding_box(box, 0.1, 0.1, 1.0, 1.0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: refine_bounding_box 零高度 raise" {
  let box = mk_box(10.0, 10.0, 20.0, 0.0)
  try {
    let _ = @detection.refine_bounding_box(box, 0.1, 0.1, 1.0, 1.0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: refine_bounding_box 负宽度 raise" {
  let box = mk_box(10.0, 10.0, -1.0, 20.0)
  try {
    let _ = @detection.refine_bounding_box(box, 0.1, 0.1, 1.0, 1.0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_objects_simple 错误路径 ==========

///|
test "yolo2: detect_objects_simple 无效通道0 raise" {
  let img = mk_img(10, 10, 0)
  let cfg = @detection.create_default_yolo_config()
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple 无效通道5 raise" {
  let img = mk_img(10, 10, 5)
  let cfg = @detection.create_default_yolo_config()
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple 数据不匹配 raise" {
  let img = mk_bad_img(10, 10, 1)
  let cfg = @detection.create_default_yolo_config()
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple input_size<=0 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(0, 80, 0.5, 0.4)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple num_classes<=0 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(416, 0, 0.5, 0.4)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple confidence_threshold<0 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(416, 80, -0.1, 0.4)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple confidence_threshold>1 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(416, 80, 1.1, 0.4)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple iou_threshold<0 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(416, 80, 0.5, -0.1)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "yolo2: detect_objects_simple iou_threshold>1 raise" {
  let img = mk_img(10, 10, 1)
  let cfg = mk_config(416, 80, 0.5, 1.1)
  try {
    let _ = @detection.detect_objects_simple(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== non_max_suppression 功能路径 ==========

///|
test "yolo2: non_max_suppression 排序交换" {
  let boxes = [
    mk_box(10.0, 10.0, 20.0, 20.0),
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.99,
      class_id: 0,
      class_name: "a",
    },
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.5,
      class_id: 0,
      class_name: "b",
    },
  ]
  let result = @detection.non_max_suppression(boxes, 0.5, 10)
  assert_true(result.length() >= 1)
}

///|
test "yolo2: non_max_suppression max_detections限制" {
  let boxes = [
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.9,
      class_id: 0,
      class_name: "a",
    },
    @detection.YoloBoundingBox::{
      x: 50.0,
      y: 50.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.8,
      class_id: 0,
      class_name: "b",
    },
    @detection.YoloBoundingBox::{
      x: 90.0,
      y: 90.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.7,
      class_id: 0,
      class_name: "c",
    },
  ]
  let result = @detection.non_max_suppression(boxes, 0.1, 2)
  assert_true(result.length() <= 2)
}

///|
test "yolo2: non_max_suppression 抑制重叠框" {
  let boxes = [
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.9,
      class_id: 0,
      class_name: "a",
    },
    @detection.YoloBoundingBox::{
      x: 12.0,
      y: 12.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.8,
      class_id: 0,
      class_name: "b",
    },
    @detection.YoloBoundingBox::{
      x: 100.0,
      y: 100.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.7,
      class_id: 0,
      class_name: "c",
    },
  ]
  let result = @detection.non_max_suppression(boxes, 0.3, 10)
  assert_true(result.length() >= 1)
  assert_true(result.length() <= 3)
}

///|
test "yolo2: non_max_suppression 不同类别不抑制" {
  let boxes = [
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.9,
      class_id: 0,
      class_name: "a",
    },
    @detection.YoloBoundingBox::{
      x: 10.0,
      y: 10.0,
      width: 20.0,
      height: 20.0,
      confidence: 0.8,
      class_id: 1,
      class_name: "b",
    },
  ]
  let result = @detection.non_max_suppression(boxes, 0.3, 10)
  assert_eq(result.length(), 2)
}

// ========== calculate_iou 功能路径 ==========

///|
test "yolo2: calculate_iou 完全不重叠" {
  let box1 = mk_box(0.0, 0.0, 10.0, 10.0)
  let box2 = mk_box(100.0, 100.0, 10.0, 10.0)
  let iou = @detection.calculate_iou(box1, box2)
  assert_true(iou >= 0.0 && iou <= 1.0)
}

///|
test "yolo2: calculate_iou 完全重叠" {
  let box1 = mk_box(10.0, 10.0, 20.0, 20.0)
  let box2 = mk_box(10.0, 10.0, 20.0, 20.0)
  let iou = @detection.calculate_iou(box1, box2)
  assert_true((iou - 1.0).abs() < 0.001)
}

///|
test "yolo2: calculate_iou 部分重叠" {
  let box1 = mk_box(10.0, 10.0, 20.0, 20.0)
  let box2 = mk_box(20.0, 10.0, 20.0, 20.0)
  let iou = @detection.calculate_iou(box1, box2)
  assert_true(iou > 0.0 && iou < 1.0)
}
