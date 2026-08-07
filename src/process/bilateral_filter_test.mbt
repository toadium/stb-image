// 双边滤波测试

///|
test "bilateral_filter: 均匀图像不变" {
  let data = Bytes::from_array(Array::make(8 * 8, b'\x80'))
  let img = @core.Image::{ width: 8, height: 8, channels: 1, data }
  let result = bilateral_filter(img, 2, 2.0F, 30.0F)
  for i in 0..<64 {
    assert_eq(result.data[i], b'\x80')
  }
}

///|
test "bilateral_filter: 保边去噪" {
  // 左半黑右半白，边界应被保留
  let data : Array[Byte] = Array::make(8 * 4, b'\x00')
  for y in 0..<4 {
    for x in 4..<8 {
      data[y * 8 + x] = b'\xFF'
    }
  }
  let img = @core.Image::{ width: 8, height: 4, channels: 1, data: Bytes::from_array(data) }
  let result = bilateral_filter(img, 2, 2.0F, 30.0F)
  assert_eq(result.width, 8)
  assert_eq(result.height, 4)
  // 远离边界的区域应接近原值
  assert_eq(result.data[0], b'\x00')
  assert_true(result.data[31].to_int() >= 250)
}

///|
test "bilateral_filter: 输出范围 0-255" {
  let data = Bytes::from_array([
    b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF',
    b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00',
    b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF',
    b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00',
  ])
  let img = @core.Image::{ width: 8, height: 4, channels: 1, data }
  let result = bilateral_filter(img, 2, 2.0F, 30.0F)
  for i in 0..<32 {
    assert_true(result.data[i].to_int() >= 0)
    assert_true(result.data[i].to_int() <= 255)
  }
}

///|
test "bilateral_filter: RGB 图像" {
  let data = Bytes::from_array([
    b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00',
  ])
  let img = @core.Image::{ width: 2, height: 2, channels: 3, data }
  let result = bilateral_filter(img, 1, 1.0F, 30.0F)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.channels, 3)
}

///|
test "bilateral_filter: radius 验证" {
  let data = Bytes::from_array([b'\x80', b'\x80'])
  let img = @core.Image::{ width: 1, height: 2, channels: 1, data }
  try {
    let _ = bilateral_filter(img, 0, 1.0F, 30.0F)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bilateral_filter: 通道验证" {
  let data = Bytes::from_array([b'\x00', b'\x00'])
  let img = @core.Image::{ width: 1, height: 1, channels: 2, data }
  try {
    let _ = bilateral_filter(img, 1, 1.0F, 30.0F)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "bilateral_filter_fast: downsample=1 等价于普通双边滤波" {
  let data = Bytes::from_array(Array::make(8 * 8, b'\x80'))
  let img = @core.Image::{ width: 8, height: 8, channels: 1, data }
  let result = bilateral_filter_fast(img, 2, 2.0F, 30.0F, 1)
  for i in 0..<64 {
    assert_eq(result.data[i], b'\x80')
  }
}