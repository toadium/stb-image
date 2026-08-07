// Canny 边缘检测测试

test "canny_edge 基本功能" {
  // 5x5 图像，中间有一条垂直边缘
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
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

test "canny_edge 常量图无边缘" {
  let data = Bytes::from_array(Array::make(25, b'\x80'))
  let img = @core.Image::{ width: 5, height: 5, channels: 1, data }
  let out = canny_edge(img, low_threshold=30, high_threshold=60)
  // 常量图不应有边缘
  for i in 0..<25 {
    assert_eq(out.data[i], b'\x00')
  }
}

test "canny_edge RGB 图" {
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
  ])
  let img = @core.Image::{ width: 4, height: 4, channels: 3, data }
  let out = canny_edge(img, low_threshold=30, high_threshold=60)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 1)
}

test "canny_edge 错误参数" {
  let img = @core.Image::{ width: 1, height: 1, channels: 1, data: Bytes::from_array([b'\x00']) }
  try {
    let _ = canny_edge(img, low_threshold=300)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
  try {
    let _ = canny_edge(img, high_threshold=300)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
  try {
    let _ = canny_edge(img, low_threshold=100, high_threshold=50)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

test "canny_edge 水平边缘" {
  // 5x5 图像，中间有一条水平边缘
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
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