// color_16f 错误路径补充测试

// ========== adjust_brightness ==========

///|
test "adjust_brightness_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_brightness_16(img, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_brightness_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_brightness_16(img, 100)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_brightness_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_brightness_f(img, 0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_brightness_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_brightness_f(img, 0.1F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== adjust_contrast ==========

///|
test "adjust_contrast_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_contrast_16(img, 1.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_contrast_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_contrast_16(img, 1.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_contrast_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_contrast_f(img, 1.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_contrast_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_contrast_f(img, 1.5F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== adjust_gamma ==========

///|
test "adjust_gamma_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_gamma_16(img, 2.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_gamma_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_gamma_16(img, 2.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_gamma_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.adjust_gamma_f(img, 2.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "adjust_gamma_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.adjust_gamma_f(img, 2.0F)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== invert ==========

///|
test "invert_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.invert_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "invert_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.invert_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "invert_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.invert_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "invert_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.invert_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== to_grayscale ==========

///|
test "to_grayscale_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.to_grayscale_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_grayscale_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.to_grayscale_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_grayscale_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.to_grayscale_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_grayscale_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.to_grayscale_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
