// v187.0.0 multilingual_ocr.mbt 测试：多语言配置/标点模板/语言检测/识别

///|
test "multilingual_ocr_default_config: 默认值" {
  let config = @ocr.multilingual_ocr_default_config()
  assert_eq(config.enable_chinese, true)
  assert_eq(config.enable_english, true)
  assert_eq(config.enable_digits, true)
  assert_eq(config.target_size, 48)
}

///|
test "generate_punctuation_templates: 基本模板" {
  let templates = @ocr.generate_punctuation_templates()
  assert_true(templates.length() > 0)
}

///|
test "detect_char_language: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 128)),
    }
    let lang = @ocr.detect_char_language(img)
    assert_true(lang == @ocr.LanguageType::English || lang == @ocr.LanguageType::Chinese || lang == @ocr.LanguageType::Unknown)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_document_language: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let _ = @ocr.detect_document_language(img)
    assert_true(true)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let result = @ocr.recognize_multilingual(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}