// v235.0.0 handwriting_recognition 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn hr_make_img(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn hr_make_img_mismatch(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn hr_make_config() -> @ocr.HandwritingRecognitionConfig {
  @ocr.HandwritingRecognitionConfig::{
    min_stroke_length: 5.0,
    max_stroke_angle: 45.0,
    segmentation_threshold: 0.3,
    similarity_threshold: 0.6,
    enable_slant_correction: true,
    enable_size_normalization: true,
    enable_stroke_order: true,
    max_candidates: 5,
    style_priority: @ocr.HandwritingStyle::SemiCursive,
  }
}

///|
fn hr_make_char_feature(char : String) -> @ocr.HandwritingCharFeature {
  @ocr.HandwritingCharFeature::{
    char,
    num_strokes: 1,
    stroke_types: [@ocr.StrokeType::Horizontal],
    aspect_ratio: 1.0,
    density: 0.5,
    center_of_mass_x: 0.5,
    center_of_mass_y: 0.5,
    horizontal_projection: [1.0, 2.0, 1.0],
    vertical_projection: [1.0, 2.0, 1.0],
    contour_complexity: 0.3,
    slant_angle: 0.0,
    size_normalized: true,
  }
}

///|
fn hr_make_template(char : String) -> @ocr.HandwritingTemplate {
  @ocr.HandwritingTemplate::{
    char,
    style: @ocr.HandwritingStyle::Print,
    features: hr_make_char_feature(char),
    sample_count: 1,
    avg_accuracy: 0.9,
  }
}

///|
fn hr_make_result(
  char : String,
  conf : Double,
) -> @ocr.HandwritingRecognitionResult {
  @ocr.HandwritingRecognitionResult::{
    predicted_char: char,
    confidence: conf,
    top_candidates: [(char, conf)],
    detected_style: @ocr.HandwritingStyle::Print,
    num_strokes_detected: 1,
    slant_angle: 0.0,
    preprocessing_time_ms: 1.0,
    feature_extraction_time_ms: 2.0,
    matching_time_ms: 3.0,
    total_time_ms: 6.0,
  }
}

///|
fn hr_make_stroke_img() -> @types.Image {
  let w = 32
  let h = 32
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  for x in 8..<24 {
    data[15 * w + x] = b'\x00'
    data[16 * w + x] = b'\x00'
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== create_default_handwriting_config ==========

///|
test "create_default_handwriting_config: returns expected defaults" {
  let cfg = @ocr.create_default_handwriting_config()
  assert_true(cfg.min_stroke_length > 0.0)
  assert_true(cfg.max_stroke_angle > 0.0)
  assert_true(cfg.segmentation_threshold > 0.0)
  assert_true(cfg.similarity_threshold > 0.0)
  assert_true(cfg.enable_slant_correction)
  assert_true(cfg.enable_size_normalization)
  assert_true(cfg.enable_stroke_order)
  assert_true(cfg.max_candidates > 0)
}

// ========== detect_handwriting_slant 错误路径 ==========

///|
test "detect_handwriting_slant: width 0 raises" {
  let img = hr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.detect_handwriting_slant(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_handwriting_slant: channels 0 raises" {
  let img = hr_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.detect_handwriting_slant(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_handwriting_slant: data mismatch raises" {
  let img = hr_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.detect_handwriting_slant(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_handwriting_slant 功能路径 ==========

///|
test "detect_handwriting_slant: uniform image" {
  let img = hr_make_img(30, 30, 1, 200)
  try {
    let slant = @ocr.detect_handwriting_slant(img)
    assert_true(slant >= -180.0 && slant <= 180.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_handwriting_slant: rgb image" {
  let img = hr_make_img(30, 30, 3, 180)
  try {
    let slant = @ocr.detect_handwriting_slant(img)
    assert_true(slant >= -180.0 && slant <= 180.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== normalize_handwriting_size 错误路径 ==========

///|
test "normalize_handwriting_size: width 0 raises" {
  let img = hr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.normalize_handwriting_size(img, 32)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "normalize_handwriting_size: target 0 raises" {
  let img = hr_make_img(20, 20, 1, 128)
  try {
    let _ = @ocr.normalize_handwriting_size(img, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "normalize_handwriting_size: data mismatch raises" {
  let img = hr_make_img_mismatch(20, 20, 1)
  try {
    let _ = @ocr.normalize_handwriting_size(img, 32)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== normalize_handwriting_size 功能路径 ==========

///|
test "normalize_handwriting_size: valid image" {
  let img = hr_make_img(20, 20, 1, 200)
  try {
    let result = @ocr.normalize_handwriting_size(img, 32)
    assert_true(result.width > 0)
    assert_true(result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "normalize_handwriting_size: rgb image" {
  let img = hr_make_img(20, 20, 3, 180)
  try {
    let result = @ocr.normalize_handwriting_size(img, 48)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_hw_stroke_features 功能路径 ==========

///|
test "extract_hw_stroke_features: all-white image" {
  let img = hr_make_img(20, 20, 1, 255)
  let strokes = @ocr.extract_hw_stroke_features(img)
  assert_eq(strokes.length(), 0)
}

///|
test "extract_hw_stroke_features: all-black image" {
  let img = hr_make_img(20, 20, 1, 0)
  let strokes = @ocr.extract_hw_stroke_features(img)
  assert_eq(strokes.length(), 400)
}

///|
test "extract_hw_stroke_features: stroke image" {
  let img = hr_make_stroke_img()
  let strokes = @ocr.extract_hw_stroke_features(img)
  assert_true(strokes.length() > 0)
}

// ========== segment_connected_strokes 功能路径 ==========

///|
test "segment_connected_strokes: white image" {
  let img = hr_make_img(30, 30, 1, 255)
  let cfg = hr_make_config()
  let result = @ocr.segment_connected_strokes(img, cfg)
  assert_true(result.num_strokes >= 0)
}

///|
test "segment_connected_strokes: stroke image" {
  let img = hr_make_stroke_img()
  let cfg = hr_make_config()
  let result = @ocr.segment_connected_strokes(img, cfg)
  assert_true(result.num_strokes >= 0)
  assert_true(result.confidence >= 0.0)
}

// ========== extract_handwriting_features 错误路径 ==========

///|
test "extract_handwriting_features: width 0 raises" {
  let img = hr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.extract_handwriting_features(img, "A")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_features: channels 5 raises" {
  let img = hr_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.extract_handwriting_features(img, "A")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_features: data mismatch raises" {
  let img = hr_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.extract_handwriting_features(img, "A")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_handwriting_features 功能路径 ==========

///|
test "extract_handwriting_features: valid image" {
  let img = hr_make_img(20, 20, 1, 200)
  try {
    let feat = @ocr.extract_handwriting_features(img, "A")
    assert_eq(feat.char, "A")
    assert_true(feat.num_strokes >= 0)
    assert_true(feat.density >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_features: stroke image" {
  let img = hr_make_stroke_img()
  try {
    let feat = @ocr.extract_handwriting_features(img, "B")
    assert_eq(feat.char, "B")
    assert_true(feat.aspect_ratio > 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== handwriting_feature_similarity 功能路径 ==========

///|
test "handwriting_feature_similarity: identical features" {
  let f = hr_make_char_feature("A")
  let score = @ocr.handwriting_feature_similarity(f, f)
  assert_true(score >= 0.0 && score <= 1.0)
}

///|
test "handwriting_feature_similarity: different features" {
  let f1 = hr_make_char_feature("A")
  let f2 = @ocr.HandwritingCharFeature::{
    char: "B",
    num_strokes: 5,
    stroke_types: [@ocr.StrokeType::Vertical],
    aspect_ratio: 2.0,
    density: 0.2,
    center_of_mass_x: 0.3,
    center_of_mass_y: 0.7,
    horizontal_projection: [3.0, 1.0],
    vertical_projection: [2.0, 4.0],
    contour_complexity: 0.8,
    slant_angle: 15.0,
    size_normalized: false,
  }
  let score = @ocr.handwriting_feature_similarity(f1, f2)
  assert_true(score >= 0.0 && score <= 1.0)
}

// ========== create_handwriting_template 错误路径 ==========

///|
test "create_handwriting_template: empty char raises" {
  let img = hr_make_img(20, 20, 1, 200)
  try {
    let _ = @ocr.create_handwriting_template("", @ocr.HandwritingStyle::Print, [
      img,
    ])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(true)
  }
}

// ========== create_handwriting_template 功能路径 ==========

///|
test "create_handwriting_template: empty samples returns default" {
  try {
    let t = @ocr.create_handwriting_template(
      "A",
      @ocr.HandwritingStyle::Print,
      [],
    )
    assert_eq(t.char, "A")
    assert_eq(t.sample_count, 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "create_handwriting_template: with samples" {
  let img = hr_make_img(20, 20, 1, 200)
  try {
    let t = @ocr.create_handwriting_template(
      "X",
      @ocr.HandwritingStyle::Cursive,
      [img],
    )
    assert_eq(t.char, "X")
    assert_eq(t.sample_count, 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "create_handwriting_template: multiple samples" {
  let img1 = hr_make_img(20, 20, 1, 200)
  let img2 = hr_make_img(20, 20, 1, 180)
  try {
    let t = @ocr.create_handwriting_template(
      "Y",
      @ocr.HandwritingStyle::Block,
      [img1, img2],
    )
    assert_eq(t.sample_count, 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== recognize_handwriting_char 错误路径 ==========

///|
test "recognize_handwriting_char: width 0 raises" {
  let img = hr_make_img(0, 10, 1, 128)
  let cfg = hr_make_config()
  let tmpl = hr_make_template("A")
  try {
    let _ = @ocr.recognize_handwriting_char(img, [tmpl], cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_char: empty templates raises" {
  let img = hr_make_img(20, 20, 1, 200)
  let cfg = hr_make_config()
  try {
    let _ = @ocr.recognize_handwriting_char(img, [], cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_char: data mismatch raises" {
  let img = hr_make_img_mismatch(20, 20, 1)
  let cfg = hr_make_config()
  let tmpl = hr_make_template("A")
  try {
    let _ = @ocr.recognize_handwriting_char(img, [tmpl], cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_handwriting_char 功能路径 ==========

///|
test "recognize_handwriting_char: valid image with template" {
  let img = hr_make_img(20, 20, 1, 200)
  let cfg = hr_make_config()
  let tmpl = hr_make_template("A")
  try {
    let result = @ocr.recognize_handwriting_char(img, [tmpl], cfg)
    assert_true(result.confidence >= 0.0)
    assert_true(result.predicted_char.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_char: multiple templates" {
  let img = hr_make_stroke_img()
  let cfg = hr_make_config()
  let templates = [
    hr_make_template("A"),
    hr_make_template("B"),
    hr_make_template("C"),
  ]
  try {
    let result = @ocr.recognize_handwriting_char(img, templates, cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== handwriting_report_to_string 功能路径 ==========

///|
test "handwriting_report_to_string: contains report header" {
  let result = hr_make_result("A", 0.9)
  let report = @ocr.handwriting_report_to_string(result)
  assert_true(report.contains("手写体识别报告"))
}

///|
test "handwriting_report_to_string: contains predicted char" {
  let result = hr_make_result("X", 0.85)
  let report = @ocr.handwriting_report_to_string(result)
  assert_true(report.contains("X"))
}

///|
test "handwriting_report_to_string: contains confidence" {
  let result = hr_make_result("A", 0.75)
  let report = @ocr.handwriting_report_to_string(result)
  assert_true(report.contains("75"))
}

///|
test "handwriting_report_to_string: contains style" {
  let result = hr_make_result("A", 0.9)
  let report = @ocr.handwriting_report_to_string(result)
  assert_true(report.contains("印刷体"))
}
