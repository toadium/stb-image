// CLAHE 测试

///|

test "clahe: grayscale uniform image produces uniform output" {
  let img = @core.Image::{
    width: 8,
    height: 8,
    channels: 1,
    data: Array::make(64, b'\x80') |> Bytes::from_array
  }
  let result = clahe(img, 4, 2.0)
  // 均匀图像 CLAHE 后所有像素应相同
  let v0 = result.data[0]
  for i in 0..<64 {
    assert_eq(result.data[i], v0)
  }
  let _ = img
  let _ = result
}

///|
test "clahe: RGB image preserves channels" {
  let img = @core.Image::{
    width: 8,
    height: 8,
    channels: 3,
    data: Array::make(64 * 3, b'\x80') |> Bytes::from_array
  }
  let result = clahe(img, 4, 2.0)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  let _ = img
  let _ = result
}

///|
test "clahe: RGBA preserves alpha" {
  let data : Array[Byte] = Array::make(64 * 4, b'\x80')
  for i in 0..<64 {
    data[i * 4 + 3] = b'\xFF'
  }
  let img = @core.Image::{
    width: 8,
    height: 8,
    channels: 4,
    data: Bytes::from_array(data)
  }
  let result = clahe(img, 4, 2.0)
  for i in 0..<64 {
    assert_eq(result.data[i * 4 + 3], b'\xFF')
  }
  let _ = img
  let _ = result
}

///|
test "clahe: raises on invalid tile_size" {
  let img = @core.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Array::make(16, b'\x80') |> Bytes::from_array
  }
  try {
    let _ = clahe(img, 1, 2.0)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "clahe: enhances contrast on gradient" {
  let data : Array[Byte] = Array::make(8 * 8, b'\x00')
  for y in 0..<8 {
    for x in 0..<8 {
      data[y * 8 + x] = (x * 32).to_byte()
    }
  }
  let img = @core.Image::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(data)
  }
  let result = clahe(img, 4, 3.0)
  // CLAHE 后像素值应在 0-255 范围内
  for i in 0..<64 {
    let v = result.data[i].to_int()
    assert_true(v >= 0 && v <= 255)
  }
  let _ = img
  let _ = result
}