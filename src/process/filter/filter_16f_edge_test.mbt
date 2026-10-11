// filter_16f 错误路径补充测试

///|
fn make_i16_f(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn make_if_f(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== box_blur 数据不匹配 ==========

///|
test "box_blur_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.box_blur_16(img, 1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "box_blur_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.box_blur_f(img, 1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== gaussian_blur 错误路径 ==========

///|
test "gaussian_blur_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.gaussian_blur_16(img, 1, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gaussian_blur_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.gaussian_blur_16(img, 1, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gaussian_blur_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.gaussian_blur_f(img, 1, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "gaussian_blur_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.gaussian_blur_f(img, 1, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== median_blur 错误路径 ==========

///|
test "median_blur_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.median_blur_16(img, 3)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "median_blur_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.median_blur_16(img, 3)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "median_blur_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.median_blur_f(img, 3)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "median_blur_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.median_blur_f(img, 3)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== sharpen 错误路径 ==========

///|
test "sharpen_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.sharpen_16(img, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "sharpen_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.sharpen_16(img, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "sharpen_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.sharpen_f(img, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "sharpen_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.sharpen_f(img, 1.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
