// v187.0.0 handwriting_ocr.mbt 测试：手写体OCR配置/模板/倾斜校正/识别

///|
test "handwriting_ocr_default_config: 默认值" {
  let config = @ocr.handwriting_ocr_default_config()
  assert_eq(config.min_char_width, 8)
  assert_eq(config.target_size, 48)
  assert_true((config.flexibility - 0.7).abs() < 0.01)
  assert_eq(config.use_slant_correction, true)
}

///|
test "generate_handwriting_templates: 数字模板" {
  let templates = @ocr.generate_handwriting_templates()
  assert_true(templates.length() > 0)
}

///|
test "generate_handwriting_templates: 数字+字母" {
  let templates = @ocr.generate_handwriting_templates(char_set="digits+letters")
  assert_true(templates.length() > 10)
}

///|
test "correct_slant: 基本校正" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.correct_slant(img)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_handwriting: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let result = @ocr.recognize_handwriting(img)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}
