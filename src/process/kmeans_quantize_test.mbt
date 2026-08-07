// K-means 量化测试

///|

test "k_means_quantize: k=1 gives single color" {
  let data : Array[Byte] = [
    b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00'
  ]
  let img = @core.Image::{ width: 2, height: 2, channels: 3, data: Bytes::from_array(data) }
  let result = k_means_quantize(img, 1, 20)
  // k=1 时所有像素应该是同一个颜色（平均值）
  let r0 = result.data[0]
  let g0 = result.data[1]
  let b0 = result.data[2]
  for i in 0..<4 {
    assert_eq(result.data[i * 3], r0)
    assert_eq(result.data[i * 3 + 1], g0)
    assert_eq(result.data[i * 3 + 2], b0)
  }
  let _ = img
  let _ = result
}

///|
test "k_means_quantize: preserves channels" {
  let img = @core.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Array::make(48, b'\x80') |> Bytes::from_array
  }
  let result = k_means_quantize(img, 4, 10)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let _ = img
  let _ = result
}

///|
test "k_means_quantize: RGBA preserves alpha" {
  let data : Array[Byte] = Array::make(4 * 4, b'\x80')
  for i in 0..<4 {
    data[i * 4 + 3] = b'\xFF'
  }
  let img = @core.Image::{ width: 2, height: 2, channels: 4, data: Bytes::from_array(data) }
  let result = k_means_quantize(img, 2, 10)
  for i in 0..<4 {
    assert_eq(result.data[i * 4 + 3], b'\xFF')
  }
  let _ = img
  let _ = result
}

///|
test "k_means_quantize: raises on invalid k" {
  let img = @core.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Array::make(12, b'\x80') |> Bytes::from_array
  }
  try {
    let _ = k_means_quantize(img, 0, 10)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "k_means_quantize: two distinct colors with k=2" {
  let data : Array[Byte] = [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF'
  ]
  let img = @core.Image::{ width: 2, height: 2, channels: 3, data: Bytes::from_array(data) }
  let result = k_means_quantize(img, 2, 20)
  // 前两个像素应该是同一个颜色，后两个也是同一个颜色
  assert_eq(result.data[0], result.data[3])
  assert_eq(result.data[6], result.data[9])
  let _ = img
  let _ = result
}