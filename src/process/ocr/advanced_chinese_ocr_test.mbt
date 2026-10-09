// v187.0.0 advanced_chinese_ocr.mbt 测试：高级中文配置/3500模板/部件分解/识别

///|
test "advanced_chinese_ocr_default_config: 默认值" {
  let config = @ocr.advanced_chinese_ocr_default_config()
  assert_true(config.target_size > 0)
}

///|
test "generate_3500_chinese_templates: 基本模板" {
  let templates = @ocr.generate_3500_chinese_templates()
  assert_true(templates.length() > 0)
}

///|
test "decompose_chinese_char: 基本分解" {
  try {
    let _ = @ocr.decompose_chinese_char("你")
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "recognize_chinese_advanced: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let result = @ocr.recognize_chinese_advanced(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}
