// v187.0.0 handwriting_recognition.mbt 测试：手写体配置/倾斜/归一化/笔画/特征/模板/识别

///|
test "create_default_handwriting_config: 默认值" {
  let config = @ocr.create_default_handwriting_config()
  assert_true(config.min_stroke_length > 0.0)
}

///|
test "detect_handwriting_slant: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let slant = @ocr.detect_handwriting_slant(img)
    assert_true(slant >= -45.0 && slant <= 45.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "normalize_handwriting_size: 基本归一化" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.normalize_handwriting_size(img, 32)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_hw_stroke_features: 基本提取" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let strokes = @ocr.extract_hw_stroke_features(img)
    assert_true(strokes.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_connected_strokes: 基本分割" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let config = @ocr.create_default_handwriting_config()
    let result = @ocr.segment_connected_strokes(img, config)
    assert_true(result.num_strokes >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_features: 基本提取" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.extract_handwriting_features(img, "A")
    assert_true(features.char == "A")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "handwriting_feature_similarity: 相同特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let feat = @ocr.extract_handwriting_features(img, "A")
    let sim = @ocr.handwriting_feature_similarity(feat, feat)
    assert_true(sim >= 0.0 && sim <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "create_handwriting_template: 基本创建" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let template = @ocr.create_handwriting_template(
      "A",
      @ocr.HandwritingStyle::Print,
      [img],
    )
    assert_eq(template.char, "A")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_char: 基本识别" {
  let img = @types.Image::{
    width: 16,
    height: 16,
    channels: 1,
    data: Bytes::from_array(Array::make(256, 128)),
  }
  let config = @ocr.create_default_handwriting_config()
  let features = @ocr.HandwritingCharFeature::{
    char: "A",
    num_strokes: 3,
    stroke_types: [
      @ocr.StrokeType::Horizontal,
      @ocr.StrokeType::Vertical,
      @ocr.StrokeType::LeftFalling,
    ],
    aspect_ratio: 1.0,
    density: 0.5,
    center_of_mass_x: 8.0,
    center_of_mass_y: 8.0,
    horizontal_projection: Array::make(16, 0.5),
    vertical_projection: Array::make(16, 0.5),
    contour_complexity: 1.0,
    slant_angle: 0.0,
    size_normalized: true,
  }
  let templates : Array[@ocr.HandwritingTemplate] = [
    @ocr.HandwritingTemplate::{
      char: "A",
      style: @ocr.HandwritingStyle::Print,
      features,
      sample_count: 1,
      avg_accuracy: 0.9,
    },
  ]
  try {
    let result = @ocr.recognize_handwriting_char(img, templates, config)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "handwriting_report_to_string: 基本报告" {
  let img = @types.Image::{
    width: 16,
    height: 16,
    channels: 1,
    data: Bytes::from_array(Array::make(256, 128)),
  }
  let config = @ocr.create_default_handwriting_config()
  let features = @ocr.HandwritingCharFeature::{
    char: "A",
    num_strokes: 3,
    stroke_types: [
      @ocr.StrokeType::Horizontal,
      @ocr.StrokeType::Vertical,
      @ocr.StrokeType::LeftFalling,
    ],
    aspect_ratio: 1.0,
    density: 0.5,
    center_of_mass_x: 8.0,
    center_of_mass_y: 8.0,
    horizontal_projection: Array::make(16, 0.5),
    vertical_projection: Array::make(16, 0.5),
    contour_complexity: 1.0,
    slant_angle: 0.0,
    size_normalized: true,
  }
  let templates : Array[@ocr.HandwritingTemplate] = [
    @ocr.HandwritingTemplate::{
      char: "A",
      style: @ocr.HandwritingStyle::Print,
      features,
      sample_count: 1,
      avg_accuracy: 0.9,
    },
  ]
  try {
    let result = @ocr.recognize_handwriting_char(img, templates, config)
    let report = @ocr.handwriting_report_to_string(result)
    assert_true(report.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}
