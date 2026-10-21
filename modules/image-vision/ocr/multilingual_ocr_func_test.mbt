// v233.0.0 multilingual_ocr 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn mo_make_img(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn mo_make_config(
  chinese : Bool,
  english : Bool,
  digits : Bool,
) -> @ocr.MultilingualOcrConfig {
  @ocr.MultilingualOcrConfig::{
    enable_chinese: chinese,
    enable_english: english,
    enable_digits: digits,
    enable_punctuation: true,
    target_size: 32,
    distance_metric: "euclidean",
    auto_language_detection: true,
  }
}

// ========== multilingual_ocr_default_config 功能路径 ==========

///|
test "multilingual_ocr_default_config: all fields verified" {
  let config = @ocr.multilingual_ocr_default_config()
  assert_eq(config.enable_chinese, true)
  assert_eq(config.enable_english, true)
  assert_eq(config.enable_digits, true)
  assert_eq(config.enable_punctuation, true)
  assert_eq(config.target_size, 48)
  assert_eq(config.distance_metric, "euclidean")
  assert_true(config.auto_language_detection)
}

// ========== generate_punctuation_templates 功能路径 ==========

///|
test "generate_punctuation_templates: returns non-empty" {
  let templates = @ocr.generate_punctuation_templates()
  assert_true(templates.length() > 0)
  let first = templates[0]
  assert_true(first.char.length() > 0)
  assert_true(first.features.length() > 0)
}

// ========== detect_char_language 错误路径 ==========

///|
test "detect_char_language: zero width raises" {
  try {
    let _ = @ocr.detect_char_language(mo_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.detect_char_language(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let _ = @ocr.detect_char_language(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_char_language(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_char_language 功能路径 ==========

///|
test "detect_char_language: all white image" {
  try {
    let lang = @ocr.detect_char_language(mo_make_img(16, 16, 0))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: all black image" {
  try {
    let lang = @ocr.detect_char_language(mo_make_img(16, 16, 255))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: wide image (english-like)" {
  try {
    let lang = @ocr.detect_char_language(mo_make_img(32, 16, 200))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: tall image (chinese-like)" {
  try {
    let lang = @ocr.detect_char_language(mo_make_img(16, 32, 200))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_char_language: RGB image" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 200)),
    }
    let lang = @ocr.detect_char_language(img)
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_document_language 错误路径 ==========

///|
test "detect_document_language: zero width raises" {
  try {
    let _ = @ocr.detect_document_language(mo_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_document_language: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.detect_document_language(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_document_language: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_document_language(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_document_language 功能路径 ==========

///|
test "detect_document_language: uniform image" {
  try {
    let lang = @ocr.detect_document_language(mo_make_img(32, 32, 128))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_document_language: all white" {
  try {
    let lang = @ocr.detect_document_language(mo_make_img(32, 32, 255))
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_document_language: RGB image" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(Array::make(3072, 200)),
    }
    let lang = @ocr.detect_document_language(img)
    ignore(lang)
  } catch {
    _ => assert_true(false)
  }
}

// ========== recognize_multilingual 错误路径 ==========

///|
test "recognize_multilingual: zero width raises" {
  try {
    let _ = @ocr.recognize_multilingual(mo_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.recognize_multilingual(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let _ = @ocr.recognize_multilingual(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.recognize_multilingual(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_multilingual 功能路径 ==========

///|
test "recognize_multilingual: with custom config all enabled" {
  try {
    let config = mo_make_config(true, true, true)
    let result = @ocr.recognize_multilingual(mo_make_img(32, 32, 200), config~)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: with custom config chinese only" {
  try {
    let config = mo_make_config(true, false, false)
    let result = @ocr.recognize_multilingual(mo_make_img(32, 32, 200), config~)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: with custom config english only" {
  try {
    let config = mo_make_config(false, true, false)
    let result = @ocr.recognize_multilingual(mo_make_img(32, 32, 200), config~)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: RGB image" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(Array::make(3072, 200)),
    }
    let result = @ocr.recognize_multilingual(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: all white image" {
  try {
    let result = @ocr.recognize_multilingual(mo_make_img(32, 32, 255))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: all black image" {
  try {
    let result = @ocr.recognize_multilingual(mo_make_img(32, 32, 0))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}
