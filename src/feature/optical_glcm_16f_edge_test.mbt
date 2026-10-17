// optical_glcm_16f 错误路径补充测试

///|
fn make_i16_o(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn make_if_o(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== lucas_kanade_16 补充错误路径 ==========

///|
test "lucas_kanade_16: data mismatch raises" {
  let prev = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let next = make_i16_o(8, 8, 1, 100)
  try {
    let _ = @feature.lucas_kanade_16(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lucas_kanade_16: next zero width raises" {
  let prev = make_i16_o(8, 8, 1, 100)
  let next = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.lucas_kanade_16(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lucas_kanade_16: size mismatch raises" {
  let prev = make_i16_o(8, 8, 1, 100)
  let next = make_i16_o(16, 16, 1, 100)
  try {
    let _ = @feature.lucas_kanade_16(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lucas_kanade_16: empty points raises" {
  let prev = make_i16_o(8, 8, 1, 100)
  let next = make_i16_o(8, 8, 1, 100)
  try {
    let _ = @feature.lucas_kanade_16(prev, next, [])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== lucas_kanade_f 错误路径 ==========

///|
test "lucas_kanade_f: zero width raises" {
  let prev = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let next = make_if_o(8, 8, 1, 0.5F)
  try {
    let _ = @feature.lucas_kanade_f(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lucas_kanade_f: invalid channels raises" {
  let prev = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  let next = make_if_o(8, 8, 1, 0.5F)
  try {
    let _ = @feature.lucas_kanade_f(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "lucas_kanade_f: data mismatch raises" {
  let prev = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let next = make_if_o(8, 8, 1, 0.5F)
  try {
    let _ = @feature.lucas_kanade_f(prev, next, [(4, 4)])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== horn_schunck 错误路径 ==========

///|
test "horn_schunck_16: zero width raises" {
  let prev = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let next = make_i16_o(8, 8, 1, 100)
  try {
    let _ = @feature.horn_schunck_16(prev, next)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "horn_schunck_16: data mismatch raises" {
  let prev = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let next = make_i16_o(8, 8, 1, 100)
  try {
    let _ = @feature.horn_schunck_16(prev, next)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "horn_schunck_f: zero width raises" {
  let prev = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let next = make_if_o(8, 8, 1, 0.5F)
  try {
    let _ = @feature.horn_schunck_f(prev, next)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "horn_schunck_f: data mismatch raises" {
  let prev = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let next = make_if_o(8, 8, 1, 0.5F)
  try {
    let _ = @feature.horn_schunck_f(prev, next)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== compute_glcm 错误路径 ==========

///|
test "compute_glcm_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.compute_glcm_16(img, 1, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "compute_glcm_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.compute_glcm_16(img, 1, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "compute_glcm_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.compute_glcm_f(img, 1, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "compute_glcm_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.compute_glcm_f(img, 1, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== glcm_features_multi_direction 错误路径 ==========

///|
test "glcm_features_multi_direction_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.glcm_features_multi_direction_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "glcm_features_multi_direction_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.glcm_features_multi_direction_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "glcm_features_multi_direction_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.glcm_features_multi_direction_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "glcm_features_multi_direction_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.glcm_features_multi_direction_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
