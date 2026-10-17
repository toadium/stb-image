// color_convert_16f 错误路径补充测试

// ========== to_rgb_f ==========

///|
test "to_rgb_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.to_rgb_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_rgb_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.to_rgb_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== to_rgba ==========

///|
test "to_rgba_16: negative size raises" {
  let img = @types.Image16::{ width: -1, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.to_rgba_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_rgba_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.to_rgba_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_rgba_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.to_rgba_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "to_rgba_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.to_rgba_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== premultiply_alpha ==========

///|
test "premultiply_alpha_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 4, data: b"", }
  try {
    let _ = @color.premultiply_alpha_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "premultiply_alpha_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 4,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.premultiply_alpha_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "premultiply_alpha_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 4, data: b"", }
  try {
    let _ = @color.premultiply_alpha_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "premultiply_alpha_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 4,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.premultiply_alpha_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== unpremultiply_alpha ==========

///|
test "unpremultiply_alpha_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 4, data: b"", }
  try {
    let _ = @color.unpremultiply_alpha_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "unpremultiply_alpha_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 4,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.unpremultiply_alpha_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "unpremultiply_alpha_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 4, data: b"", }
  try {
    let _ = @color.unpremultiply_alpha_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "unpremultiply_alpha_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 4,
    data: b"\x00\x01",
  }
  try {
    let _ = @color.unpremultiply_alpha_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
