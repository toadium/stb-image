// v236.0.0 chinese_ocr + advanced_chinese_ocr + english_ocr 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn co_make_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn co_make_img_mismatch(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn co_make_char_img() -> @types.Image {
  let w = 48
  let h = 48
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  for x in 12..<36 {
    data[20 * w + x] = b'\x00'
    data[21 * w + x] = b'\x00'
    data[28 * w + x] = b'\x00'
    data[29 * w + x] = b'\x00'
  }
  for y in 20..<30 {
    data[y * w + 23] = b'\x00'
    data[y * w + 24] = b'\x00'
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== chinese_ocr_default_config ==========

///|
test "chinese_ocr_default_config: returns expected defaults" {
  let cfg = @ocr.chinese_ocr_default_config()
  assert_eq(cfg.min_char_width, 10)
  assert_eq(cfg.max_char_width, 100)
  assert_eq(cfg.target_size, 48)
  assert_eq(cfg.distance_metric, "euclidean")
  assert_eq(cfg.char_set, "common")
}

// ========== generate_chinese_templates 功能路径 ==========

///|
test "generate_chinese_templates: default common set" {
  let templates = @ocr.generate_chinese_templates()
  assert_true(templates.length() > 50)
}

///|
test "generate_chinese_templates: full set" {
  let templates = @ocr.generate_chinese_templates(char_set="full")
  assert_true(templates.length() > 50)
}

///|
test "generate_chinese_templates: template has features" {
  let templates = @ocr.generate_chinese_templates()
  assert_true(templates[0].1.length() > 0)
}

// ========== recognize_chinese 错误路径 ==========

///|
test "recognize_chinese: width 0 raises" {
  let img = co_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.recognize_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese: multi-channel raises" {
  let img = co_make_img(20, 20, 3, 128)
  try {
    let _ = @ocr.recognize_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese: data mismatch raises" {
  let img = co_make_img_mismatch(20, 20, 1)
  try {
    let _ = @ocr.recognize_chinese(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_chinese 功能路径 ==========

///|
test "recognize_chinese: default config" {
  let img = co_make_img(48, 48, 1, 200)
  try {
    let result = @ocr.recognize_chinese(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese: with custom config" {
  let img = co_make_char_img()
  let cfg = @ocr.ChineseOcrConfig::{
    min_char_width: 8,
    max_char_width: 80,
    target_size: 32,
    distance_metric: "manhattan",
    char_set: "full",
  }
  try {
    let result = @ocr.recognize_chinese(img, config=cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== advanced_chinese_ocr_default_config ==========

///|
test "advanced_chinese_ocr_default_config: returns expected defaults" {
  let cfg = @ocr.advanced_chinese_ocr_default_config()
  assert_eq(cfg.min_char_width, 10)
  assert_eq(cfg.max_char_width, 100)
  assert_eq(cfg.target_size, 48)
  assert_eq(cfg.distance_metric, "euclidean")
  assert_eq(cfg.char_set, "common3500")
  assert_true(cfg.use_radical_decomposition)
  assert_true(cfg.use_structure_analysis)
}

// ========== generate_3500_chinese_templates 功能路径 ==========

///|
test "generate_3500_chinese_templates: default set" {
  let templates = @ocr.generate_3500_chinese_templates()
  assert_true(templates.length() > 50)
}

///|
test "generate_3500_chinese_templates: common100 set" {
  let templates = @ocr.generate_3500_chinese_templates(char_set="common100")
  assert_true(templates.length() > 0)
}

///|
test "generate_3500_chinese_templates: template has features" {
  let templates = @ocr.generate_3500_chinese_templates()
  assert_true(templates[0].1.length() > 0)
}

// ========== decompose_chinese_char 错误路径 ==========

///|
test "decompose_chinese_char: empty char raises" {
  try {
    let _ = @ocr.decompose_chinese_char("")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== decompose_chinese_char 功能路径 ==========

///|
test "decompose_chinese_char: valid char" {
  try {
    let s = @ocr.decompose_chinese_char("的")
    assert_eq(s.char, "的")
    assert_true(s.strokes > 0)
    assert_true(s.components.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decompose_chinese_char: structure type valid" {
  try {
    let s = @ocr.decompose_chinese_char("人")
    assert_true(
      s.structure_type == "single" ||
      s.structure_type == "left-right" ||
      s.structure_type == "top-bottom" ||
      s.structure_type == "surround" ||
      s.structure_type == "complex",
    )
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decompose_chinese_char: radical non-empty" {
  try {
    let s = @ocr.decompose_chinese_char("大")
    assert_true(s.radical.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== recognize_chinese_advanced 错误路径 ==========

///|
test "recognize_chinese_advanced: width 0 raises" {
  let img = co_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.recognize_chinese_advanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese_advanced: channels 0 raises" {
  let img = co_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.recognize_chinese_advanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese_advanced: channels 5 raises" {
  let img = co_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.recognize_chinese_advanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese_advanced: data mismatch raises" {
  let img = co_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.recognize_chinese_advanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_chinese_advanced 功能路径 ==========

///|
test "recognize_chinese_advanced: default config" {
  let img = co_make_img(48, 48, 1, 200)
  try {
    let result = @ocr.recognize_chinese_advanced(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese_advanced: with custom config" {
  let img = co_make_char_img()
  let cfg = @ocr.AdvancedChineseOcrConfig::{
    min_char_width: 8,
    max_char_width: 80,
    target_size: 32,
    distance_metric: "manhattan",
    char_set: "common100",
    use_radical_decomposition: false,
    use_structure_analysis: false,
  }
  try {
    let result = @ocr.recognize_chinese_advanced(img, config=cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_chinese_advanced: rgb image" {
  let img = co_make_img(48, 48, 3, 180)
  try {
    let result = @ocr.recognize_chinese_advanced(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== english_ocr_default_config ==========

///|
test "english_ocr_default_config: returns expected defaults" {
  let cfg = @ocr.english_ocr_default_config()
  assert_eq(cfg.min_char_width, 5)
  assert_eq(cfg.max_char_width, 60)
  assert_eq(cfg.target_size, 32)
  assert_eq(cfg.distance_metric, "euclidean")
  assert_true(!cfg.case_sensitive)
}

// ========== generate_english_templates 功能路径 ==========

///|
test "generate_english_templates: case insensitive" {
  let templates = @ocr.generate_english_templates()
  assert_eq(templates.length(), 36)
}

///|
test "generate_english_templates: case sensitive" {
  let templates = @ocr.generate_english_templates(case_sensitive=true)
  assert_eq(templates.length(), 62)
}

///|
test "generate_english_templates: template has features" {
  let templates = @ocr.generate_english_templates()
  assert_true(templates[0].1.length() > 0)
}

///|
test "generate_english_templates: contains digits" {
  let templates = @ocr.generate_english_templates()
  assert_eq(templates[0].0, "0")
  assert_eq(templates[9].0, "9")
}

///|
test "generate_english_templates: contains uppercase" {
  let templates = @ocr.generate_english_templates()
  assert_eq(templates[10].0, "A")
  assert_eq(templates[35].0, "Z")
}

// ========== recognize_english 错误路径 ==========

///|
test "recognize_english: width 0 raises" {
  let img = co_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.recognize_english(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_english: multi-channel raises" {
  let img = co_make_img(20, 20, 3, 128)
  try {
    let _ = @ocr.recognize_english(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_english: data mismatch raises" {
  let img = co_make_img_mismatch(20, 20, 1)
  try {
    let _ = @ocr.recognize_english(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_english 功能路径 ==========

///|
test "recognize_english: default config" {
  let img = co_make_img(32, 32, 1, 200)
  try {
    let result = @ocr.recognize_english(img)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_english: with custom config" {
  let img = co_make_char_img()
  let cfg = @ocr.EnglishOcrConfig::{
    min_char_width: 4,
    max_char_width: 50,
    target_size: 24,
    distance_metric: "manhattan",
    case_sensitive: true,
  }
  try {
    let result = @ocr.recognize_english(img, config=cfg)
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_english: char image" {
  let img = co_make_char_img()
  try {
    let result = @ocr.recognize_english(img)
    assert_true(result.confidence >= 0.0)
    assert_true(result.text.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
