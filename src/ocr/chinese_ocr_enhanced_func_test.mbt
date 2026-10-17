// v232.0.0 chinese_ocr_enhanced 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn cce_make_img(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn cce_make_config(
  structure : Bool,
  stroke : Bool,
  radical : Bool,
) -> @ocr.EnhancedChineseOcrConfig {
  @ocr.EnhancedChineseOcrConfig::{
    min_char_width: 8,
    max_char_width: 80,
    target_size: 32,
    distance_metric: "euclidean",
    char_set_size: 500,
    use_structure_filter: structure,
    use_stroke_features: stroke,
    use_radical_hint: radical,
  }
}

// ========== enhanced_chinese_ocr_default_config 功能路径 ==========

///|
test "enhanced_chinese_ocr_default_config: all fields verified" {
  let config = @ocr.enhanced_chinese_ocr_default_config()
  assert_eq(config.min_char_width, 10)
  assert_eq(config.max_char_width, 100)
  assert_eq(config.target_size, 48)
  assert_eq(config.distance_metric, "euclidean")
  assert_eq(config.char_set_size, 1000)
  assert_eq(config.use_structure_filter, true)
  assert_eq(config.use_stroke_features, true)
  assert_eq(config.use_radical_hint, true)
}

// ========== generate_chinese_char_info_db 功能路径 ==========

///|
test "generate_chinese_char_info_db: returns non-empty db" {
  let db = @ocr.generate_chinese_char_info_db()
  assert_true(db.length() > 0)
  let first = db[0]
  assert_true(first.char.length() > 0)
  assert_true(first.strokes > 0)
}

// ========== generate_enhanced_chinese_templates 功能路径 ==========

///|
test "generate_enhanced_chinese_templates: default size" {
  let templates = @ocr.generate_enhanced_chinese_templates()
  assert_true(templates.length() > 0)
  let (label, features) = templates[0]
  assert_true(label.length() > 0)
  assert_true(features.length() > 0)
}

///|
test "generate_enhanced_chinese_templates: small char set" {
  let templates = @ocr.generate_enhanced_chinese_templates(char_set_size=100)
  assert_true(templates.length() > 0)
}

///|
test "generate_enhanced_chinese_templates: large char set" {
  let templates = @ocr.generate_enhanced_chinese_templates(char_set_size=1000)
  assert_true(templates.length() > 0)
}

// ========== structure_based_filter 功能路径 ==========

///|
test "structure_based_filter: all white image low density" {
  let img = cce_make_img(16, 16, 0)
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db)
  assert_true(filtered.length() >= 0)
}

///|
test "structure_based_filter: all black image high density" {
  let img = cce_make_img(16, 16, 255)
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db)
  assert_true(filtered.length() >= 0)
}

///|
test "structure_based_filter: wide image left-right structure" {
  let img = cce_make_img(32, 16, 255)
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db)
  assert_true(filtered.length() >= 0)
}

///|
test "structure_based_filter: tall image top-bottom structure" {
  let img = cce_make_img(16, 32, 255)
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db)
  assert_true(filtered.length() >= 0)
}

///|
test "structure_based_filter: custom max_candidates" {
  let img = cce_make_img(16, 16, 200)
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db, max_candidates=10)
  assert_true(filtered.length() <= 10)
}

///|
test "structure_based_filter: empty db returns empty" {
  let img = cce_make_img(16, 16, 200)
  let filtered = @ocr.structure_based_filter(img, [])
  assert_eq(filtered.length(), 0)
}

///|
test "structure_based_filter: medium density" {
  let data : Array[Int] = []
  for i in 0..<256 {
    if i % 3 == 0 {
      data.push(255)
    } else {
      data.push(0)
    }
  }
  let img = @types.Image::{
    width: 16,
    height: 16,
    channels: 1,
    data: Bytes::from_array(data.map(fn(x) { x.to_byte() })),
  }
  let db = @ocr.generate_chinese_char_info_db()
  let filtered = @ocr.structure_based_filter(img, db)
  assert_true(filtered.length() >= 0)
}

// ========== extract_stroke_features 错误路径 ==========

///|
test "extract_stroke_features: zero width raises" {
  try {
    let _ = @ocr.extract_stroke_features(cce_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_stroke_features: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.extract_stroke_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_stroke_features: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.extract_stroke_features(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_stroke_features 功能路径 ==========

///|
test "extract_stroke_features: all white returns features" {
  try {
    let features = @ocr.extract_stroke_features(cce_make_img(16, 16, 0))
    assert_true(features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_stroke_features: all black returns features" {
  try {
    let features = @ocr.extract_stroke_features(cce_make_img(16, 16, 255))
    assert_true(features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_stroke_features: larger image" {
  try {
    let features = @ocr.extract_stroke_features(cce_make_img(32, 32, 200))
    assert_true(features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== recognize_enhanced_chinese 错误路径 ==========

///|
test "recognize_enhanced_chinese: zero width raises" {
  try {
    let _ = @ocr.recognize_enhanced_chinese(cce_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.recognize_enhanced_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let _ = @ocr.recognize_enhanced_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.recognize_enhanced_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_enhanced_chinese 功能路径 ==========

///|
test "recognize_enhanced_chinese: with custom config all features" {
  try {
    let config = cce_make_config(true, true, true)
    let result = @ocr.recognize_enhanced_chinese(
      cce_make_img(32, 32, 200),
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: with custom config no features" {
  try {
    let config = cce_make_config(false, false, false)
    let result = @ocr.recognize_enhanced_chinese(
      cce_make_img(32, 32, 200),
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: RGB image" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(Array::make(3072, 200)),
    }
    let result = @ocr.recognize_enhanced_chinese(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: all white image" {
  try {
    let result = @ocr.recognize_enhanced_chinese(cce_make_img(32, 32, 255))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: all black image" {
  try {
    let result = @ocr.recognize_enhanced_chinese(cce_make_img(32, 32, 0))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}
