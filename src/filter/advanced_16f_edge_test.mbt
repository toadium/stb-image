// advanced_16f 错误路径补充测试

///|
fn make_i16_a(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image16 {
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
fn make_if_a(w : Int32, h : Int32, ch : Int32, val : Float) -> @types.ImageF {
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

// ========== inpaint 错误路径 ==========

///|
test "inpaint_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  let mask = make_i16_a(8, 8, 1, 0)
  try {
    let _ = @filter.inpaint_16(img, mask)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "inpaint_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  let mask = make_if_a(8, 8, 1, 0.0F)
  try {
    let _ = @filter.inpaint_f(img, mask)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "inpaint_fast_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  let mask = make_i16_a(8, 8, 1, 0)
  try {
    let _ = @filter.inpaint_fast_16(img, mask)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "inpaint_fast_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  let mask = make_if_a(8, 8, 1, 0.0F)
  try {
    let _ = @filter.inpaint_fast_f(img, mask)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== nlm_denoise 错误路径 ==========

///|
test "nlm_denoise_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.nlm_denoise_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.nlm_denoise_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.nlm_denoise_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.nlm_denoise_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_fast_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.nlm_denoise_fast_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_fast_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.nlm_denoise_fast_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_fast_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @filter.nlm_denoise_fast_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "nlm_denoise_fast_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @filter.nlm_denoise_fast_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
