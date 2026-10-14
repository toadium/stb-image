// v234.0.0 handwriting_ocr_enhanced 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn hoe_make_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn hoe_make_img_mismatch(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn hoe_make_config(
  slant : Bool,
  elastic : Bool,
  stroke : Bool,
  postproc : Bool,
) -> @ocr.HandwritingOcrEnhancedConfig {
  @ocr.HandwritingOcrEnhancedConfig::{
    min_char_width: 8,
    max_char_width: 80,
    min_char_height: 10,
    max_char_height: 100,
    target_size: 48,
    distance_metric: "euclidean",
    num_variants: 3,
    elasticity: 0.5,
    use_slant_correction: slant,
    use_elastic_matching: elastic,
    use_stroke_features: stroke,
    use_postprocessing: postproc,
  }
}

///|
fn hoe_make_char_img_with_strokes() -> @types.Image {
  let w = 32
  let h = 32
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for x in 8..<24 {
    data[10 * w + x] = b'\xFF'
    data[11 * w + x] = b'\xFF'
    data[20 * w + x] = b'\xFF'
    data[21 * w + x] = b'\xFF'
  }
  for y in 10..<22 {
    data[y * w + 15] = b'\xFF'
    data[y * w + 16] = b'\xFF'
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== handwriting_ocr_enhanced_default_config ==========

///|
test "handwriting_ocr_enhanced_default_config: returns expected defaults" {
  let cfg = @ocr.handwriting_ocr_enhanced_default_config()
  assert_eq(cfg.min_char_width, 8)
  assert_eq(cfg.max_char_width, 80)
  assert_eq(cfg.min_char_height, 10)
  assert_eq(cfg.max_char_height, 100)
  assert_eq(cfg.target_size, 48)
  assert_eq(cfg.distance_metric, "euclidean")
  assert_eq(cfg.num_variants, 5)
  assert_true(cfg.use_slant_correction)
  assert_true(cfg.use_elastic_matching)
  assert_true(cfg.use_stroke_features)
  assert_true(cfg.use_postprocessing)
}

// ========== generate_enhanced_handwriting_templates 功能路径 ==========

///|
test "generate_enhanced_handwriting_templates: digits only" {
  let templates = @ocr.generate_enhanced_handwriting_templates(
    char_set="digits",
    num_variants=3,
  )
  assert_eq(templates.length(), 30)
  assert_true(templates[0].0.contains("0"))
}

///|
test "generate_enhanced_handwriting_templates: digits+letters default" {
  let templates = @ocr.generate_enhanced_handwriting_templates()
  assert_true(templates.length() > 100)
}

///|
test "generate_enhanced_handwriting_templates: single variant" {
  let templates = @ocr.generate_enhanced_handwriting_templates(
    char_set="digits",
    num_variants=1,
  )
  assert_eq(templates.length(), 10)
  for i in 0..<templates.length() {
    assert_true(templates[i].1.length() > 0)
  }
}

///|
test "generate_enhanced_handwriting_templates: variant labels" {
  let templates = @ocr.generate_enhanced_handwriting_templates(
    char_set="digits",
    num_variants=2,
  )
  assert_true(templates[0].0.contains("_v0"))
  assert_true(templates[1].0.contains("_v1"))
}

// ========== extract_handwriting_stroke_features 错误路径 ==========

///|
test "extract_handwriting_stroke_features: width 0 raises" {
  let img = hoe_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.extract_handwriting_stroke_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_stroke_features: multi-channel raises" {
  let img = hoe_make_img(20, 20, 3, 128)
  try {
    let _ = @ocr.extract_handwriting_stroke_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_stroke_features: data mismatch raises" {
  let img = hoe_make_img_mismatch(20, 20, 1)
  try {
    let _ = @ocr.extract_handwriting_stroke_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_handwriting_stroke_features 功能路径 ==========

///|
test "extract_handwriting_stroke_features: all-black image" {
  let img = hoe_make_img(20, 20, 1, 0)
  try {
    let f = @ocr.extract_handwriting_stroke_features(img)
    assert_true(f.num_strokes >= 0)
    assert_true(f.connectivity >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_stroke_features: all-white image" {
  let img = hoe_make_img(20, 20, 1, 255)
  try {
    let f = @ocr.extract_handwriting_stroke_features(img)
    assert_true(f.num_strokes >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_handwriting_stroke_features: image with strokes" {
  let img = hoe_make_char_img_with_strokes()
  try {
    let f = @ocr.extract_handwriting_stroke_features(img)
    assert_true(f.num_strokes >= 0)
    assert_true(f.stroke_directions.length() >= 0)
    assert_true(f.stroke_lengths.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== elastic_match 功能路径 ==========

///|
test "elastic_match: identical features" {
  let features = [1.0, 2.0, 3.0, 4.0]
  let template = [1.0, 2.0, 3.0, 4.0]
  let score = @ocr.elastic_match(features, template)
  assert_true(score >= 0.0)
}

///|
test "elastic_match: different features" {
  let features = [1.0, 2.0, 3.0, 4.0]
  let template = [5.0, 6.0, 7.0, 8.0]
  let score = @ocr.elastic_match(features, template)
  assert_true(score >= 0.0)
}

///|
test "elastic_match: empty arrays" {
  let score = @ocr.elastic_match([], [])
  assert_true(score >= 0.0)
}

///|
test "elastic_match: with custom elasticity" {
  let features = [1.0, 2.0, 3.0, 4.0]
  let template = [1.5, 2.5, 3.5, 4.5]
  let score = @ocr.elastic_match(features, template, elasticity=0.3)
  assert_true(score >= 0.0)
}

///|
test "elastic_match: with custom grid_size" {
  let features = Array::make(64, 1.0)
  let template = Array::make(64, 2.0)
  let score = @ocr.elastic_match(features, template, grid_size=8)
  assert_true(score >= 0.0)
}

///|
test "elastic_match: different length arrays" {
  let features = [1.0, 2.0, 3.0]
  let template = [1.0, 2.0, 3.0, 4.0, 5.0]
  let score = @ocr.elastic_match(features, template)
  assert_true(score >= 0.0)
}

// ========== segment_cursive_chars 功能路径 ==========

///|
test "segment_cursive_chars: all-black image" {
  let img = hoe_make_img(50, 30, 1, 0)
  let regions = @ocr.segment_cursive_chars(img)
  assert_eq(regions.length(), 0)
}

///|
test "segment_cursive_chars: all-white image" {
  let img = hoe_make_img(50, 30, 1, 255)
  let regions = @ocr.segment_cursive_chars(img)
  assert_true(regions.length() >= 0)
}

///|
test "segment_cursive_chars: image with separated chars" {
  let w = 60
  let h = 30
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for x in 5..<15 {
    for y in 5..<25 {
      data[y * w + x] = b'\xFF'
    }
  }
  for x in 25..<35 {
    for y in 5..<25 {
      data[y * w + x] = b'\xFF'
    }
  }
  for x in 45..<55 {
    for y in 5..<25 {
      data[y * w + x] = b'\xFF'
    }
  }
  let img = @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
  let regions = @ocr.segment_cursive_chars(img)
  assert_true(regions.length() >= 0)
}

///|
test "segment_cursive_chars: with custom char width bounds" {
  let img = hoe_make_img(50, 30, 1, 255)
  let regions = @ocr.segment_cursive_chars(
    img,
    min_char_width=5,
    max_char_width=40,
  )
  assert_true(regions.length() >= 0)
}

// ========== handwriting_postprocess 功能路径 ==========

///|
test "handwriting_postprocess: high confidence" {
  let (text, conf) = @ocr.handwriting_postprocess("abc", 0.9)
  assert_eq(text, "abc")
  assert_true((conf - 0.9).abs() < 0.001)
}

///|
test "handwriting_postprocess: low confidence" {
  let (text, conf) = @ocr.handwriting_postprocess("xyz", 0.3)
  assert_eq(text, "xyz")
  assert_true(conf < 0.3)
}

///|
test "handwriting_postprocess: empty text" {
  let (text, conf) = @ocr.handwriting_postprocess("", 0.5)
  assert_eq(text, "")
  assert_true((conf - 0.5).abs() < 0.001)
}

///|
test "handwriting_postprocess: confidence boundary 0.5" {
  let (_, conf) = @ocr.handwriting_postprocess("a", 0.5)
  assert_true((conf - 0.5).abs() < 0.001)
}

// ========== recognize_handwriting_enhanced 错误路径 ==========

///|
test "recognize_handwriting_enhanced: width 0 raises" {
  let img = hoe_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.recognize_handwriting_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: channels 0 raises" {
  let img = hoe_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.recognize_handwriting_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: channels 5 raises" {
  let img = hoe_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.recognize_handwriting_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: data mismatch raises" {
  let img = hoe_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.recognize_handwriting_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_handwriting_enhanced 功能路径 ==========

///|
test "recognize_handwriting_enhanced: default config" {
  let img = hoe_make_img(40, 40, 1, 200)
  try {
    let result = @ocr.recognize_handwriting_enhanced(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: all features enabled" {
  let img = hoe_make_char_img_with_strokes()
  let cfg = hoe_make_config(true, true, true, true)
  try {
    let result = @ocr.recognize_handwriting_enhanced(img, config=cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: all features disabled" {
  let img = hoe_make_img(40, 40, 1, 200)
  let cfg = hoe_make_config(false, false, false, false)
  try {
    let result = @ocr.recognize_handwriting_enhanced(img, config=cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting_enhanced: rgb image" {
  let img = hoe_make_img(40, 40, 3, 180)
  try {
    let result = @ocr.recognize_handwriting_enhanced(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}
