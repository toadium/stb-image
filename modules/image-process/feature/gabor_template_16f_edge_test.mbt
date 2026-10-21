// gabor_template_16f 错误路径补充测试

///|
fn make_i16_g(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i * 2] = (val & 0xFF).to_byte()
    data[i * 2 + 1] = ((val >> 8) & 0xFF).to_byte()
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn make_if_g(w : Int32, h : Int32, ch : Int32, val : Float) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for i in 0..<(w * h * ch) {
    let bits = val.reinterpret_as_int()
    data[i * 4] = (bits & 0xFF).to_byte()
    data[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    data[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    data[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== gabor_filter_16 补充错误路径 ==========

///|
test "gabor_filter_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.gabor_filter_16(img, 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== gabor_filter_f 错误路径 ==========

///|
test "gabor_filter_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.gabor_filter_f(img, 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gabor_filter_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.gabor_filter_f(img, 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== gabor_filter_bank 错误路径 ==========

///|
test "gabor_filter_bank_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.gabor_filter_bank_16(img, 3, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gabor_filter_bank_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.gabor_filter_bank_16(img, 3, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gabor_filter_bank_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.gabor_filter_bank_f(img, 3, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gabor_filter_bank_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.gabor_filter_bank_f(img, 3, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== template_match 错误路径 ==========

///|
test "template_match_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let tmpl = make_i16_g(4, 4, 1, 100)
  try {
    let _ = @feature.template_match_16(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let tmpl = make_i16_g(4, 4, 1, 100)
  try {
    let _ = @feature.template_match_16(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let tmpl = make_if_g(4, 4, 1, 0.5F)
  try {
    let _ = @feature.template_match_f(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let tmpl = make_if_g(4, 4, 1, 0.5F)
  try {
    let _ = @feature.template_match_f(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== template_match_best 错误路径 ==========

///|
test "template_match_best_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let tmpl = make_i16_g(4, 4, 1, 100)
  try {
    let _ = @feature.template_match_best_16(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_best_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let tmpl = make_i16_g(4, 4, 1, 100)
  try {
    let _ = @feature.template_match_best_16(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_best_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let tmpl = make_if_g(4, 4, 1, 0.5F)
  try {
    let _ = @feature.template_match_best_f(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "template_match_best_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let tmpl = make_if_g(4, 4, 1, 0.5F)
  try {
    let _ = @feature.template_match_best_f(img, tmpl)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
