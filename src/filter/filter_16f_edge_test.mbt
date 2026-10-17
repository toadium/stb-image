// filter_16f 错误路径补充测试

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
