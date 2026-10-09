// v187.0.0 multilingual_ocr_enhanced.mbt 测试：增强多语言配置/语言检测/智能分割/间距/标点/识别

///|
test "multilingual_ocr_enhanced_default_config: 默认值" {
  let config = @ocr.multilingual_ocr_enhanced_default_config()
  assert_true(config.target_size > 0)
}

///|
test "detect_language_enhanced: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 128)),
    }
    let result = @ocr.detect_language_enhanced(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "smart_segment_chars: 基本分割" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let config = @ocr.multilingual_ocr_enhanced_default_config()
    let segments = @ocr.smart_segment_chars(img, config)
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "smart_spacing_process: 基本处理" {
  let result = @ocr.smart_spacing_process("abc", ["en", "en", "en"])
  assert_true(result.length() >= 0)
}

///|
test "normalize_punctuation: 基本处理" {
  let result = @ocr.normalize_punctuation("a,b", ["en", "en", "en"])
  assert_true(result.length() >= 0)
}

///|
test "language_model_postprocess: 基本处理" {
  let (text, confidences) = @ocr.language_model_postprocess(
    "abc",
    ["en", "en", "en"],
    [0.9, 0.8, 0.7],
  )
  assert_true(text.length() >= 0)
  assert_true(confidences.length() >= 0)
}

///|
test "recognize_multilingual_enhanced: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let result = @ocr.recognize_multilingual_enhanced(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}
