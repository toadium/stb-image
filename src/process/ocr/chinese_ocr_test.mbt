// v187.0.0 chinese_ocr.mbt 测试：中文OCR配置/模板/识别

///|
test "chinese_ocr_default_config: 默认值" {
  let config = @ocr.chinese_ocr_default_config()
  assert_true(config.target_size > 0)
}

///|
test "generate_chinese_templates: 基本模板" {
  let templates = @ocr.generate_chinese_templates()
  assert_true(templates.length() > 0)
}

///|
test "recognize_chinese: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let result = @ocr.recognize_chinese(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}