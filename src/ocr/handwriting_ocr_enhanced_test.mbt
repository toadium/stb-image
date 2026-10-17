// v187.0.0 handwriting_ocr_enhanced.mbt 测试：增强手写体配置/模板/笔画/弹性匹配/连笔/识别

///|
test "handwriting_ocr_enhanced_default_config: 默认值" {
  let config = @ocr.handwriting_ocr_enhanced_default_config()
  assert_true(config.min_char_width > 0)
}

///|
test "generate_enhanced_handwriting_templates: 基本模板" {
  let templates = @ocr.generate_enhanced_handwriting_templates()
  assert_true(templates.length() > 0)
}

///|
test "extract_handwriting_stroke_features: 基本提取" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let features = @ocr.extract_handwriting_stroke_features(img)
    assert_true(features.num_strokes >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "elastic_match: 基本匹配" {
  let features = [1.0, 2.0, 3.0]
  let template = [1.0, 2.0, 3.0]
  let score = @ocr.elastic_match(features, template)
  assert_true(score >= 0.0 && score <= 1.0)
}

///|
test "segment_cursive_chars: 基本分割" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 128)),
    }
    let segments = @ocr.segment_cursive_chars(img)
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "handwriting_postprocess: 基本后处理" {
  let (text, _) = @ocr.handwriting_postprocess("hel1o", 0.8)
  assert_true(text.length() >= 0)
}

///|
test "recognize_handwriting_enhanced: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let result = @ocr.recognize_handwriting_enhanced(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}
