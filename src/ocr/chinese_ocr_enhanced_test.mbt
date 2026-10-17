// v187.0.0 chinese_ocr_enhanced.mbt 测试：增强中文配置/字库/模板/结构过滤/笔画/识别

///|
test "enhanced_chinese_ocr_default_config: 默认值" {
  let config = @ocr.enhanced_chinese_ocr_default_config()
  assert_true(config.target_size > 0)
}

///|
test "generate_chinese_char_info_db: 基本字库" {
  let db = @ocr.generate_chinese_char_info_db()
  assert_true(db.length() > 0)
}

///|
test "generate_enhanced_chinese_templates: 基本模板" {
  let templates = @ocr.generate_enhanced_chinese_templates()
  assert_true(templates.length() > 0)
}

///|
test "structure_based_filter: 基本过滤" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let db = @ocr.generate_chinese_char_info_db()
    let filtered = @ocr.structure_based_filter(img, db)
    assert_true(filtered.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_stroke_features: 基本提取" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let features = @ocr.extract_stroke_features(img)
    assert_true(features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_enhanced_chinese: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let result = @ocr.recognize_enhanced_chinese(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}
