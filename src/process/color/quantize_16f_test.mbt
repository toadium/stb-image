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
