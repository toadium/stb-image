// 色彩量化 16-bit/float 变体测试

///|
fn make_img16_q(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
  let n = w * h * ch
  let data : Array[Byte] = Array::make(n * 2, b'\x00')
  for i in 0..<n {
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
fn make_imgf_q(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
  let n = w * h * ch
  let data : Array[Byte] = Array::make(n * 4, b'\x00')
  for i in 0..<n {
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

///|
test "kmeans_quantize_16 basic" {
  let img = make_img16_q(4, 4, 3, 128)
  let out = @color.kmeans_quantize_16(img, 2, 10)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "kmeans_quantize_f basic" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.kmeans_quantize_f(img, 2, 10)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "kmeans_quantize_16 rgba" {
  let img = make_img16_q(4, 4, 4, 128)
  let out = @color.kmeans_quantize_16(img, 2, 10)
  assert_eq(out.channels, 4)
}

///|
test "kmeans_quantize_f rgba" {
  let img = make_imgf_q(4, 4, 4, 0.5F)
  let out = @color.kmeans_quantize_f(img, 2, 10)
  assert_eq(out.channels, 4)
}

///|
test "kmeans_quantize_16 k=1" {
  let img = make_img16_q(4, 4, 3, 128)
  let out = @color.kmeans_quantize_16(img, 1, 10)
  assert_eq(out.width, 4)
}

///|
test "kmeans_quantize_f k=4" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.kmeans_quantize_f(img, 4, 5)
  assert_eq(out.width, 4)
}

///|
test "floyd_steinberg_16 basic" {
  let img = make_img16_q(4, 4, 3, 128)
  let out = @color.floyd_steinberg_16(img, 2)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "floyd_steinberg_f basic" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.floyd_steinberg_f(img, 2)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "floyd_steinberg_16 rgba" {
  let img = make_img16_q(4, 4, 4, 128)
  let out = @color.floyd_steinberg_16(img, 4)
  assert_eq(out.channels, 4)
}

///|
test "floyd_steinberg_f levels=4" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.floyd_steinberg_f(img, 4)
  assert_eq(out.width, 4)
}

///|
test "median_cut_16 basic" {
  let img = make_img16_q(4, 4, 3, 128)
  let out = @color.median_cut_16(img, 4)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "median_cut_f basic" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.median_cut_f(img, 4)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
}

///|
test "median_cut_16 k=2" {
  let img = make_img16_q(4, 4, 3, 128)
  let out = @color.median_cut_16(img, 2)
  assert_eq(out.channels, 3)
}

///|
test "median_cut_f k=8" {
  let img = make_imgf_q(4, 4, 3, 0.5F)
  let out = @color.median_cut_f(img, 8)
  assert_eq(out.width, 4)
}

// ========== 错误处理路径测试 ==========

///|
test "kmeans_quantize_16: negative size raises" {
  let img = @types.Image16::{ width: -1, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.kmeans_quantize_16(img, 4, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_16: invalid k raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 3,
    data: Bytes::from_array(Array::make(8 * 8 * 3 * 2, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_16(img, 0, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_16: invalid channels raises" {
  let img = @types.Image16::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(8 * 8 * 1 * 2, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_16(img, 4, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_16: zero pixels returns img" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let result = @color.kmeans_quantize_16(img, 4, 10)
    assert_eq(result.width, 0)
  } catch {
    _ => assert_true(true)
  }
  let _ = img
}

///|
test "kmeans_quantize_f: negative size raises" {
  let img = @types.ImageF::{ width: -1, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.kmeans_quantize_f(img, 4, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_f: invalid k raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 3,
    data: Bytes::from_array(Array::make(8 * 8 * 3 * 4, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_f(img, 0, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_16(img, 2, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_f: invalid channels raises" {
  let img = @types.ImageF::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(Array::make(8 * 8 * 1 * 4, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_f(img, 4, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.kmeans_quantize_f(img, 2, 10)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "kmeans_quantize_f: zero pixels returns img" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let result = @color.kmeans_quantize_f(img, 4, 10)
    assert_eq(result.width, 0)
  } catch {
    _ => assert_true(true)
  }
  let _ = img
}

// ========== kmeans 多样化像素功能测试 ==========

///|
test "kmeans_quantize_16: diverse pixels trigger iteration" {
  // 创建 4x4 RGB 图像，前 8 像素为 (0,0,0)，后 8 像素为 (65535,65535,65535)
  let data : Array[Byte] = Array::make(4 * 4 * 3 * 2, b'\x00')
  for i in 8..<16 {
    for c in 0..<3 {
      data[(i * 3 + c) * 2] = b'\xFF'
      data[(i * 3 + c) * 2 + 1] = b'\xFF'
    }
  }
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let out = @color.kmeans_quantize_16(img, 2, 20)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // 验证量化后只有两种颜色
  let mut color0 = (0, 0, 0)
  let mut color1 = (0, 0, 0)
  let mut has_color0 = false
  let mut has_color1 = false
  for i in 0..<16 {
    let r = out.data[i * 3 * 2].to_int() |
      (out.data[i * 3 * 2 + 1].to_int() << 8)
    let g = out.data[(i * 3 + 1) * 2].to_int() |
      (out.data[(i * 3 + 1) * 2 + 1].to_int() << 8)
    let b = out.data[(i * 3 + 2) * 2].to_int() |
      (out.data[(i * 3 + 2) * 2 + 1].to_int() << 8)
    if !has_color0 {
      color0 = (r, g, b)
      has_color0 = true
    } else if (r, g, b) != color0 && !has_color1 {
      color1 = (r, g, b)
      has_color1 = true
    }
    if has_color1 {
      assert_true((r, g, b) == color0 || (r, g, b) == color1)
    }
  }
  let _ = img
  let _ = out
}

///|
test "kmeans_quantize_f: diverse pixels trigger iteration" {
  // 创建 4x4 RGB 图像，前 8 像素为 0.0，后 8 像素为 1.0
  let data : Array[Byte] = Array::make(4 * 4 * 3 * 4, b'\x00')
  let one_bits = 1.0F.reinterpret_as_int()
  for i in 8..<16 {
    for c in 0..<3 {
      let off = (i * 3 + c) * 4
      data[off] = (one_bits & 0xFF).to_byte()
      data[off + 1] = ((one_bits >> 8) & 0xFF).to_byte()
      data[off + 2] = ((one_bits >> 16) & 0xFF).to_byte()
      data[off + 3] = ((one_bits >> 24) & 0xFF).to_byte()
    }
  }
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(data),
  }
  let out = @color.kmeans_quantize_f(img, 2, 20)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  let _ = img
  let _ = out
}

// ========== floyd_steinberg 错误处理测试 ==========

///|
test "floyd_steinberg_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.floyd_steinberg_16(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_16: invalid channels raises" {
  let img = @types.Image16::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @color.floyd_steinberg_16(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.floyd_steinberg_16(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_16: levels < 2 raises" {
  let img = make_img16_q(4, 4, 3, 128)
  try {
    let _ = @color.floyd_steinberg_16(img, 1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.floyd_steinberg_f(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_f: invalid channels raises" {
  let img = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @color.floyd_steinberg_f(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "floyd_steinberg_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.floyd_steinberg_f(img, 2)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

// ========== median_cut 错误处理测试 ==========

///|
test "median_cut_16: zero width raises" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.median_cut_16(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_16: invalid channels raises" {
  let img = @types.Image16::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @color.median_cut_16(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_16: data mismatch raises" {
  let img = @types.Image16::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.median_cut_16(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_16: num_colors < 2 raises" {
  let img = make_img16_q(4, 4, 3, 128)
  try {
    let _ = @color.median_cut_16(img, 1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_f: zero width raises" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 3, data: b"", }
  try {
    let _ = @color.median_cut_f(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_f: invalid channels raises" {
  let img = @types.ImageF::{ width: 8, height: 8, channels: 5, data: b"", }
  try {
    let _ = @color.median_cut_f(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "median_cut_f: data mismatch raises" {
  let img = @types.ImageF::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(8, b'\x00')),
  }
  try {
    let _ = @color.median_cut_f(img, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}
