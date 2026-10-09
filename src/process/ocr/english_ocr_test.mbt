// v187.0.0 english_ocr.mbt 测试：英文OCR配置/模板/识别

///|
test "english_ocr_default_config: 默认值" {
  let config = @ocr.english_ocr_default_config()
  assert_eq(config.min_char_width, 5)
  assert_eq(config.max_char_width, 60)
  assert_eq(config.target_size, 32)
  assert_eq(config.case_sensitive, false)
}

///|
test "generate_english_templates: 基本模板" {
  let templates = @ocr.generate_english_templates()
  assert_true(templates.length() >= 10)
}

///|
test "recognize_english: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let result = @ocr.recognize_english(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}