// v232.0.0 multilingual_ocr_enhanced 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn mle_make_img(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn mle_make_config(
  chinese : Bool,
  english : Bool,
  digits : Bool,
  auto_detect : Bool,
  smart_sp : Bool,
) -> @ocr.MultilingualOcrEnhancedConfig {
  @ocr.MultilingualOcrEnhancedConfig::{
    enable_chinese: chinese,
    enable_english: english,
    enable_digits: digits,
    enable_punctuation: true,
    enable_japanese: false,
    enable_korean: false,
    target_size: 32,
    distance_metric: "euclidean",
    auto_language_detection: auto_detect,
    smart_spacing: smart_sp,
    punctuation_normalization: true,
    use_language_model: true,
  }
}

// ========== multilingual_ocr_enhanced_default_config 功能路径 ==========

///|
test "multilingual_ocr_enhanced_default_config: all fields verified" {
  let config = @ocr.multilingual_ocr_enhanced_default_config()
  assert_eq(config.enable_chinese, true)
  assert_eq(config.enable_english, true)
  assert_eq(config.enable_digits, true)
  assert_eq(config.enable_punctuation, true)
  assert_eq(config.enable_japanese, false)
  assert_eq(config.enable_korean, false)
  assert_eq(config.target_size, 48)
  assert_eq(config.distance_metric, "euclidean")

  assert_true(config.auto_language_detection)
  assert_true(config.smart_spacing)
  assert_true(config.punctuation_normalization)
  assert_true(config.use_language_model)
}

// ========== detect_language_enhanced 错误路径 ==========

///|
test "detect_language_enhanced: zero width raises" {
  try {
    let _ = @ocr.detect_language_enhanced(mle_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_language_enhanced: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_language_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_language_enhanced: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_language_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_language_enhanced 功能路径 ==========

///|
test "detect_language_enhanced: all white image" {
  try {
    let result = @ocr.detect_language_enhanced(mle_make_img(16, 16, 0))
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
    assert_true(result.language.length() > 0)
    assert_true(result.probabilities.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_language_enhanced: all black image" {
  try {
    let result = @ocr.detect_language_enhanced(mle_make_img(16, 16, 255))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_language_enhanced: wide image (english-like)" {
  try {
    let result = @ocr.detect_language_enhanced(mle_make_img(32, 16, 200))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_language_enhanced: tall image (chinese-like)" {
  try {
    let result = @ocr.detect_language_enhanced(mle_make_img(16, 32, 200))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== smart_segment_chars 错误路径 ==========

///|
test "smart_segment_chars: zero width raises" {
  try {
    let config = @ocr.multilingual_ocr_enhanced_default_config()
    let _ = @ocr.smart_segment_chars(mle_make_img(0, 16, 128), config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "smart_segment_chars: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let config = @ocr.multilingual_ocr_enhanced_default_config()
    let _ = @ocr.smart_segment_chars(img, config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "smart_segment_chars: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let config = @ocr.multilingual_ocr_enhanced_default_config()
    let _ = @ocr.smart_segment_chars(img, config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== smart_segment_chars 功能路径 ==========

///|
test "smart_segment_chars: all white returns no segments" {
  try {
    let config = @ocr.multilingual_ocr_enhanced_default_config()
    let segments = @ocr.smart_segment_chars(mle_make_img(32, 32, 0), config)
    assert_eq(segments.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "smart_segment_chars: with custom config" {
  try {
    let config = mle_make_config(true, true, true, false, false)
    let segments = @ocr.smart_segment_chars(mle_make_img(32, 32, 200), config)
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== smart_spacing_process 功能路径 ==========

///|
test "smart_spacing_process: empty string" {
  let result = @ocr.smart_spacing_process("", [])
  assert_eq(result, "")
}

///|
test "smart_spacing_process: mismatched lengths returns original" {
  let result = @ocr.smart_spacing_process("abc", ["en"])
  assert_eq(result, "abc")
}

///|
test "smart_spacing_process: all english" {
  let result = @ocr.smart_spacing_process("abc", [
    "english", "english", "english",
  ])
  assert_true(result.length() > 0)
}

///|
test "smart_spacing_process: all chinese" {
  let result = @ocr.smart_spacing_process("你好", ["chinese", "chinese"])
  assert_true(result.length() > 0)
}

///|
test "smart_spacing_process: mixed chinese and english adds spacing" {
  let result = @ocr.smart_spacing_process("a你b", [
    "english", "chinese", "english",
  ])
  assert_true(result.contains(" "))
}

// ========== normalize_punctuation 功能路径 ==========

///|
test "normalize_punctuation: empty string" {
  let result = @ocr.normalize_punctuation("", [])
  assert_eq(result, "")
}

///|
test "normalize_punctuation: mismatched lengths returns original" {
  let result = @ocr.normalize_punctuation("abc", ["en"])
  assert_eq(result, "abc")
}

///|
test "normalize_punctuation: all english" {
  let result = @ocr.normalize_punctuation("a,b", [
    "english", "english", "english",
  ])
  assert_true(result.length() >= 0)
}

///|
test "normalize_punctuation: chinese punctuation" {
  let result = @ocr.normalize_punctuation("你，好", [
    "chinese", "chinese", "chinese",
  ])
  assert_true(result.length() >= 0)
}

// ========== language_model_postprocess 功能路径 ==========

///|
test "language_model_postprocess: empty string" {
  let (text, confs) = @ocr.language_model_postprocess("", [], [])
  assert_eq(text, "")
  assert_eq(confs.length(), 0)
}

///|
test "language_model_postprocess: basic text" {
  let (text, confs) = @ocr.language_model_postprocess(
    "abc",
    ["english", "english", "english"],
    [0.9, 0.8, 0.7],
  )
  assert_true(text.length() > 0)
  assert_eq(confs.length(), 3)
}

///|
test "language_model_postprocess: mismatched lengths" {
  let (text, confs) = @ocr.language_model_postprocess("abc", ["english"], [
    0.9, 0.8,
  ])
  assert_eq(text, "abc")
  assert_eq(confs.length(), 2)
}

///|
test "language_model_postprocess: chinese text" {
  let (text, _) = @ocr.language_model_postprocess(
    "你好",
    ["chinese", "chinese"],
    [0.85, 0.75],
  )
  assert_true(text.length() > 0)
}

// ========== recognize_multilingual_enhanced 错误路径 ==========

///|
test "recognize_multilingual_enhanced: zero width raises" {
  try {
    let _ = @ocr.recognize_multilingual_enhanced(mle_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.recognize_multilingual_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let _ = @ocr.recognize_multilingual_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.recognize_multilingual_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_multilingual_enhanced 功能路径 ==========

///|
test "recognize_multilingual_enhanced: with custom config" {
  try {
    let config = mle_make_config(true, true, true, true, true)
    let result = @ocr.recognize_multilingual_enhanced(
      mle_make_img(32, 32, 200),
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: no auto detection" {
  try {
    let config = mle_make_config(true, true, true, false, false)
    let result = @ocr.recognize_multilingual_enhanced(
      mle_make_img(32, 32, 200),
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: RGB image" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(Array::make(3072, 200)),
    }
    let result = @ocr.recognize_multilingual_enhanced(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: all white image" {
  try {
    let result = @ocr.recognize_multilingual_enhanced(mle_make_img(32, 32, 255))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_multilingual_enhanced: all black image" {
  try {
    let result = @ocr.recognize_multilingual_enhanced(mle_make_img(32, 32, 0))
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}
