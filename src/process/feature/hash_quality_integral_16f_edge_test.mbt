// hash_quality_integral_16f 错误路径补充测试

///|
fn make_i16_e(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn make_if_e(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== dhash_16 / phash_16 数据不匹配 ==========

///|
test "dhash_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.dhash_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "phash_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.phash_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== ahash_f 错误路径 ==========

///|
test "ahash_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.ahash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ahash_f: invalid channels raises" {
  let img = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @feature.ahash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ahash_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.ahash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== dhash_f 错误路径 + 功能 ==========

///|
test "dhash_f: basic" {
  let img = make_if_e(32, 32, 1, 0.5F)
  let result = @feature.dhash_f(img)
  assert_eq(result.length() > 0, true)
}

///|
test "dhash_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.dhash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "dhash_f: invalid channels raises" {
  let img = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @feature.dhash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "dhash_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.dhash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== phash_f 错误路径 + 功能 ==========

///|
test "phash_f: basic" {
  let img = make_if_e(32, 32, 1, 0.5F)
  let result = @feature.phash_f(img)
  assert_eq(result.length() > 0, true)
}

///|
test "phash_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.phash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "phash_f: invalid channels raises" {
  let img = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @feature.phash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "phash_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.phash_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== mse_16 错误路径 ==========

///|
test "mse_16: img1 zero width raises" {
  let img1 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.mse_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_16: img1 data mismatch raises" {
  let img1 = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.mse_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_16: img2 zero width raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.mse_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_16: size mismatch raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = make_i16_e(16, 16, 1, 100)
  try {
    let _ = @feature.mse_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== psnr_16 错误路径 ==========

///|
test "psnr_16: img1 zero width raises" {
  let img1 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.psnr_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_16: img1 data mismatch raises" {
  let img1 = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.psnr_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_16: img2 zero width raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.psnr_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_16: size mismatch raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = make_i16_e(16, 16, 1, 100)
  try {
    let _ = @feature.psnr_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== ssim_16 错误路径 ==========

///|
test "ssim_16: img1 zero width raises" {
  let img1 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.ssim_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_16: img1 data mismatch raises" {
  let img1 = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_i16_e(8, 8, 1, 100)
  try {
    let _ = @feature.ssim_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_16: img2 zero width raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.ssim_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_16: size mismatch raises" {
  let img1 = make_i16_e(8, 8, 1, 100)
  let img2 = make_i16_e(16, 16, 1, 100)
  try {
    let _ = @feature.ssim_16(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== mse_f 错误路径 ==========

///|
test "mse_f: img1 zero width raises" {
  let img1 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.mse_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_f: img1 data mismatch raises" {
  let img1 = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.mse_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_f: img2 zero width raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.mse_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "mse_f: size mismatch raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = make_if_e(16, 16, 1, 0.5F)
  try {
    let _ = @feature.mse_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== psnr_f 错误路径 ==========

///|
test "psnr_f: img1 zero width raises" {
  let img1 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.psnr_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_f: img1 data mismatch raises" {
  let img1 = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.psnr_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_f: img2 zero width raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.psnr_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "psnr_f: size mismatch raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = make_if_e(16, 16, 1, 0.5F)
  try {
    let _ = @feature.psnr_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== ssim_f 错误路径 ==========

///|
test "ssim_f: img1 zero width raises" {
  let img1 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.ssim_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_f: img1 data mismatch raises" {
  let img1 = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  let img2 = make_if_e(8, 8, 1, 0.5F)
  try {
    let _ = @feature.ssim_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_f: img2 zero width raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.ssim_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "ssim_f: size mismatch raises" {
  let img1 = make_if_e(8, 8, 1, 0.5F)
  let img2 = make_if_e(16, 16, 1, 0.5F)
  try {
    let _ = @feature.ssim_f(img1, img2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== integral_image 错误路径 ==========

///|
test "integral_image_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.integral_image_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.integral_image_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_sq_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.integral_image_sq_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_sq_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.integral_image_sq_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.integral_image_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.integral_image_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_sq_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.integral_image_sq_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "integral_image_sq_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: b"\x00\x01",
  }
  try {
    let _ = @feature.integral_image_sq_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
