// 纯 MoonBit 噪声生成测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 add_noise_gaussian_pure / add_noise_salt_pepper_pure 正确性

///|
fn in_make_rgb_image(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data) }
}

///|
fn in_make_rgba_image(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
    data.push(p.3.to_byte())
  }
  @types.Image::{ width, height, channels: 4, data: Bytes::from_array(data) }
}

///|
test "add_noise_gaussian_pure: basic noise" {
  // 2x2 RGB 像素全 128
  let img = in_make_rgb_image(2, 2, [
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
  ])
  let out1 = add_noise_gaussian_pure(img, 10.0F, 42U)
  assert_eq(out1.width, 2)
  assert_eq(out1.height, 2)
  assert_eq(out1.channels, 3)
  // 固定种子可重现：两次调用结果一致
  let out2 = add_noise_gaussian_pure(img, 10.0F, 42U)
  assert_eq(out1.data, out2.data)
  let _ = img
  let _ = out1
  let _ = out2
}

///|
test "add_noise_gaussian_pure: sigma=0 is identity" {
  // 2x2 RGB 像素全 128
  let img = in_make_rgb_image(2, 2, [
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
  ])
  let out = add_noise_gaussian_pure(img, 0.0F, 42U)
  // sigma=0 时噪声 = gaussian*0 = 0，输出与原图完全一致
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "add_noise_gaussian_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  let img = in_make_rgba_image(2, 2, [
    (128, 128, 128, 255),
    (128, 128, 128, 128),
    (128, 128, 128, 0),
    (128, 128, 128, 64),
  ])
  let out = add_noise_gaussian_pure(img, 10.0F, 42U)
  // 验证 alpha 通道与原始完全一致
  for i in 0..<4 {
    assert_eq(out.data[i * 4 + 3], img.data[i * 4 + 3])
  }
  let _ = img
  let _ = out
}

///|
test "add_noise_salt_pepper_pure: basic noise" {
  // 2x2 RGB 像素全 128
  let img = in_make_rgb_image(2, 2, [
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
  ])
  let out1 = add_noise_salt_pepper_pure(img, 0.5F, 42U)
  assert_eq(out1.width, 2)
  assert_eq(out1.height, 2)
  assert_eq(out1.channels, 3)
  // 固定种子可重现
  let out2 = add_noise_salt_pepper_pure(img, 0.5F, 42U)
  assert_eq(out1.data, out2.data)
  let _ = img
  let _ = out1
  let _ = out2
}

///|
test "add_noise_salt_pepper_pure: prob=0 is identity" {
  // 2x2 RGB 像素全 128
  let img = in_make_rgb_image(2, 2, [
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
  ])
  let out = add_noise_salt_pepper_pure(img, 0.0F, 42U)
  // prob=0 时 r < 0.0 恒为 false，所有像素走 else 分支复制原图
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}
