// Canny 边缘检测测试

///|
test "canny_edge 基本功能" {
  // 5x5 图像，中间有一条垂直边缘
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF',
    b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\xFF',
    b'\xFF', b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
  ])
  let img = @core.Image::{ width: 5, height: 5, channels: 1, data }
  let out = canny_edge(img, low_threshold=30, high_threshold=60)
  assert_eq(out.width, 5)
  assert_eq(out.height, 5)
  assert_eq(out.channels, 1)
  // 应检测到边缘
  let mut has_edge = false
  for i in 0..<25 {
    if out.data[i] == b'\xFF' {
      has_edge = true
      break
    }
  }
  assert_true(has_edge)
}

///|
test "canny_edge 1x1 功能测试" {
  let img = @core.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([b'\x80']),
  }
  let out = canny_edge(img)
  assert_eq(out.width, 1)
  assert_eq(out.height, 1)
  assert_eq(out.channels, 1)
  assert_eq(out.data[0], b'\x00')
}

///|
test "canny_edge 水平边缘" {
  // 5x5 图像，中间有一条水平边缘
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
  ])
  let img = @core.Image::{ width: 5, height: 5, channels: 1, data }
  let out = canny_edge(img, low_threshold=30, high_threshold=60)
  // 应检测到边缘
  let mut has_edge = false
  for i in 0..<25 {
    if out.data[i] == b'\xFF' {
      has_edge = true
      break
    }
  }
  assert_true(has_edge)
}
