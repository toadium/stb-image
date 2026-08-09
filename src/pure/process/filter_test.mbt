// 纯 MoonBit 图像滤波测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 box_blur_pure / gaussian_blur_pure / sharpen_pure / edge_detect_sobel_pure 正确性

///|
fn flt_make_image(
  width : Int,
  height : Int,
  channels : Int,
  data : Array[Byte],
) -> @types.Image {
  @types.Image::{ width, height, channels, data: Bytes::from_array(data) }
}

///|
test "box_blur_pure: radius=0 is identity" {
  // 2x2 RGB，radius=0 直接返回原图
  let img = flt_make_image(2, 2, 3, [
    b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80',
    b'\x00', b'\xFF', b'\x00',
  ])
  let out = box_blur_pure(img, 0)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "box_blur_pure: radius=1 smooths image" {
  // 3x3 RGB 中心白点，其余全黑
  // 手算：水平模糊后中间行 R=G=B=85，其余 0；垂直模糊后全图 R=G=B=28
  let img = flt_make_image(3, 3, 3, [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let out = box_blur_pure(img, 1)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 3)
  // 全图每个像素均为 (28, 28, 28)
  for i in 0..<9 {
    assert_eq(out.data[i * 3].to_int(), 28)
    assert_eq(out.data[i * 3 + 1].to_int(), 28)
    assert_eq(out.data[i * 3 + 2].to_int(), 28)
  }
  let _ = img
  let _ = out
}

///|
test "box_blur_pure: preserves alpha channel" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64），radius=1 模糊后 alpha 不变
  let img = flt_make_image(2, 2, 4, [
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x80', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x40',
  ])
  let out = box_blur_pure(img, 1)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha 通道与原始完全一致
  assert_eq(out.data[3].to_int(), 255)
  assert_eq(out.data[7].to_int(), 128)
  assert_eq(out.data[11].to_int(), 0)
  assert_eq(out.data[15].to_int(), 64)
  let _ = img
  let _ = out
}

///|
test "box_blur_pure: uniform image is unchanged" {
  // 3x3 灰度（channels=1）全 255，radius=1 模糊后仍全 255
  let img = flt_make_image(3, 3, 1, [
    b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF', b'\xFF',
  ])
  let out = box_blur_pure(img, 1)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 1)
  for i in 0..<9 {
    assert_eq(out.data[i].to_int(), 255)
  }
  let _ = img
  let _ = out
}

///|
test "box_blur_pure: radius exceeds image size" {
  // 2x2 RGB，radius=100（超出图像尺寸），验证 width/height/channels 不变
  let img = flt_make_image(2, 2, 3, [
    b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80',
    b'\x00', b'\xFF', b'\x00',
  ])
  let out = box_blur_pure(img, 100)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data.length(), 12)
  let _ = img
  let _ = out
}

///|
test "gaussian_blur_pure: radius=0 is identity" {
  // 2x2 RGB，radius=0 直接返回原图
  let img = flt_make_image(2, 2, 3, [
    b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80',
    b'\x00', b'\xFF', b'\x00',
  ])
  let out = gaussian_blur_pure(img, 0, 1.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "gaussian_blur_pure: uniform image is unchanged" {
  // 3x3 灰度全 128，radius=1 sigma=1.0 模糊后仍全 128
  let img = flt_make_image(3, 3, 1, [
    b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80',
  ])
  let out = gaussian_blur_pure(img, 1, 1.0F)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 1)
  for i in 0..<9 {
    assert_eq(out.data[i].to_int(), 128)
  }
  let _ = img
  let _ = out
}

///|
test "gaussian_blur_pure: preserves alpha channel" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64），radius=1 sigma=1.0 模糊后 alpha 不变
  let img = flt_make_image(2, 2, 4, [
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x80', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x40',
  ])
  let out = gaussian_blur_pure(img, 1, 1.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha 通道与原始完全一致
  assert_eq(out.data[3].to_int(), 255)
  assert_eq(out.data[7].to_int(), 128)
  assert_eq(out.data[11].to_int(), 0)
  assert_eq(out.data[15].to_int(), 64)
  let _ = img
  let _ = out
}

///|
test "sharpen_pure: amount=0 is identity" {
  // 2x2 RGB，amount=0.0 返回原图（center=1.0，val=cx*1.0-0=cx）
  let img = flt_make_image(2, 2, 3, [
    b'\x64', b'\xC8', b'\x32', b'\x0A', b'\x14', b'\x1E', b'\xFF', b'\x00', b'\x80',
    b'\x00', b'\xFF', b'\x00',
  ])
  let out = sharpen_pure(img, 0.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "sharpen_pure: uniform image is unchanged" {
  // 3x3 灰度全 128，amount=1.0 锐化后仍全 128（均匀图拉普拉斯响应为 0）
  let img = flt_make_image(3, 3, 1, [
    b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80',
  ])
  let out = sharpen_pure(img, 1.0F)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 1)
  for i in 0..<9 {
    assert_eq(out.data[i].to_int(), 128)
  }
  let _ = img
  let _ = out
}

///|
test "sharpen_pure: preserves alpha" {
  // 2x2 RGBA，amount=0.5 锐化后 alpha 通道与原始完全一致
  let img = flt_make_image(2, 2, 4, [
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x80', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x40',
  ])
  let out = sharpen_pure(img, 0.5F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha 通道与原始完全一致
  assert_eq(out.data[3].to_int(), 255)
  assert_eq(out.data[7].to_int(), 128)
  assert_eq(out.data[11].to_int(), 0)
  assert_eq(out.data[15].to_int(), 64)
  let _ = img
  let _ = out
}

///|
test "edge_detect_sobel_pure: uniform image has no edges" {
  // 4x4 RGB 全 128，输出 channels=1 且 data 全 0（均匀图梯度为 0）
  let img = flt_make_image(4, 4, 3, Array::make(48, b'\x80'))
  let out = edge_detect_sobel_pure(img)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 1)
  for i in 0..<16 {
    assert_eq(out.data[i].to_int(), 0)
  }
  let _ = img
  let _ = out
}

///|
test "edge_detect_sobel_pure: detects edges in non-uniform image" {
  // 4x4 RGB 左半黑右半白（x>=2 为 255），输出 channels=1 且至少 1 像素 > 0
  let data : Array[Byte] = []
  for y in 0..<4 {
    for x in 0..<4 {
      let v = if x >= 2 { b'\xFF' } else { b'\x00' }
      data.push(v)
      data.push(v)
      data.push(v)
    }
    let _ = y
  }
  let img = flt_make_image(4, 4, 3, data)
  let out = edge_detect_sobel_pure(img)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 1)
  let mut has_edge = false
  for i in 0..<16 {
    if out.data[i].to_int() > 0 {
      has_edge = true
    }
  }
  assert_true(has_edge)
  let _ = img
  let _ = out
}
