// 纯 MoonBit 直方图操作测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 histogram_pure / histogram_equalize_pure / histogram_normalize_pure 正确性

///|
fn hist_make_image(
  width : Int,
  height : Int,
  channels : Int,
  data : Array[Byte],
) -> @types.Image {
  @types.Image::{
    width,
    height,
    channels,
    data: Bytes::from_array(data),
  }
}

///|
test "histogram_pure: grayscale image" {
  // 2x2 灰度（channels=1）像素 [0,128,255,64]
  let img = hist_make_image(2, 2, 1, [b'\x00', b'\x80', b'\xFF', b'\x40'])
  let hist = histogram_pure(img)
  assert_eq(hist.length(), 256)
  assert_eq(hist[0], 1)
  assert_eq(hist[64], 1)
  assert_eq(hist[128], 1)
  assert_eq(hist[255], 1)
  // 其余 bin 为 0
  for i in 0..<256 {
    if i != 0 && i != 64 && i != 128 && i != 255 {
      assert_eq(hist[i], 0)
    }
  }
  let _ = img
  let _ = hist
}

///|
test "histogram_pure: RGB image converts to grayscale" {
  // 2x1 RGB 像素 (255,0,0)/(0,255,0)
  // (255,0,0): (255*299+0*587+0*114)/1000 = 76245/1000 = 76
  // (0,255,0): (0*299+255*587+0*114)/1000 = 149685/1000 = 149
  let img = hist_make_image(2, 1, 3, [b'\xFF', b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00'])
  let hist = histogram_pure(img)
  assert_eq(hist.length(), 256)
  assert_eq(hist[76], 1)
  assert_eq(hist[149], 1)
  // 其余 bin 为 0
  for i in 0..<256 {
    if i != 76 && i != 149 {
      assert_eq(hist[i], 0)
    }
  }
  let _ = img
  let _ = hist
}

///|
test "histogram_pure: uniform image" {
  // 2x2 灰度全 128
  let img = hist_make_image(2, 2, 1, [b'\x80', b'\x80', b'\x80', b'\x80'])
  let hist = histogram_pure(img)
  assert_eq(hist.length(), 256)
  assert_eq(hist[128], 4)
  // 其余 bin 为 0
  for i in 0..<256 {
    if i != 128 {
      assert_eq(hist[i], 0)
    }
  }
  let _ = img
  let _ = hist
}

///|
test "histogram_equalize_pure: uniform image is unchanged" {
  // 3x3 灰度全 128，denom = n - cdf_min = 9 - 9 = 0 <= 0，返回原图
  let img = hist_make_image(
    3,
    3,
    1,
    [
      b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80',
    ],
  )
  let out = histogram_equalize_pure(img)
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
test "histogram_equalize_pure: normal equalization" {
  // 2x2 灰度像素 [0,64,128,255]
  // hist[0]=1, hist[64]=1, hist[128]=1, hist[255]=1
  // cdf[0]=1, cdf[64]=2, cdf[128]=3, cdf[255]=4, cdf_min=1, denom=4-1=3
  // lut[0]=(1-1)*255/3=0, lut[64]=(2-1)*255/3=85, lut[128]=(3-1)*255/3=170, lut[255]=(4-1)*255/3=255
  // 输出 data = [0, 85, 170, 255]
  let img = hist_make_image(2, 2, 1, [b'\x00', b'\x40', b'\x80', b'\xFF'])
  let out = histogram_equalize_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 1)
  assert_eq(out.data[0].to_int(), 0)
  assert_eq(out.data[1].to_int(), 85)
  assert_eq(out.data[2].to_int(), 170)
  assert_eq(out.data[3].to_int(), 255)
  let _ = img
  let _ = out
}

///|
test "histogram_equalize_pure: preserves alpha channel" {
  // 2x2 RGBA，alpha=[255,128,0,64]，像素颜色各不相同
  // 均衡化后 alpha 通道与原始完全一致
  let img = hist_make_image(
    2,
    2,
    4,
    [
      b'\x0A', b'\x14', b'\x1E', b'\xFF',
      b'\x28', b'\x32', b'\x3C', b'\x80',
      b'\x46', b'\x50', b'\x5A', b'\x00',
      b'\x64', b'\x6E', b'\x78', b'\x40',
    ],
  )
  let orig = img
  let out = histogram_equalize_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha 通道保留：out.data[i*4+3] == orig.data[i*4+3]
  for i in 0..<4 {
    assert_eq(out.data[i * 4 + 3], orig.data[i * 4 + 3])
  }
  // 显式验证 alpha 值
  assert_eq(out.data[3].to_int(), 255)
  assert_eq(out.data[7].to_int(), 128)
  assert_eq(out.data[11].to_int(), 0)
  assert_eq(out.data[15].to_int(), 64)
  let _ = img
  let _ = orig
  let _ = out
}

///|
test "histogram_equalize_pure: all same pixels returns original" {
  // 2x2 灰度全 100，denom = n - cdf_min = 4 - 4 = 0 <= 0，返回原图
  let img = hist_make_image(2, 2, 1, [b'\x64', b'\x64', b'\x64', b'\x64'])
  let out = histogram_equalize_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 1)
  for i in 0..<4 {
    assert_eq(out.data[i].to_int(), 100)
  }
  let _ = img
  let _ = out
}

///|
test "histogram_normalize_pure: uniform image is unchanged" {
  // 3x3 灰度全 128，min=128, max=128, range=0，返回原图
  let img = hist_make_image(
    3,
    3,
    1,
    [
      b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80', b'\x80',
    ],
  )
  let out = histogram_normalize_pure(img)
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
test "histogram_normalize_pure: normal normalization" {
  // 2x2 灰度像素 [50,100,150,200]
  // min=50, max=200, range=150
  // v=50: (50-50)*255/150=0
  // v=100: (100-50)*255/150=85
  // v=150: (150-50)*255/150=170
  // v=200: (200-50)*255/150=255
  // 输出 data = [0, 85, 170, 255]
  let img = hist_make_image(2, 2, 1, [b'\x32', b'\x64', b'\x96', b'\xC8'])
  let out = histogram_normalize_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 1)
  assert_eq(out.data[0].to_int(), 0)
  assert_eq(out.data[1].to_int(), 85)
  assert_eq(out.data[2].to_int(), 170)
  assert_eq(out.data[3].to_int(), 255)
  let _ = img
  let _ = out
}

///|
test "histogram_normalize_pure: preserves alpha channel" {
  // 2x2 RGBA，alpha=[255,128,0,64]，像素颜色各不相同
  // 归一化后 alpha 通道与原始完全一致
  let img = hist_make_image(
    2,
    2,
    4,
    [
      b'\x0A', b'\x14', b'\x1E', b'\xFF',
      b'\x28', b'\x32', b'\x3C', b'\x80',
      b'\x46', b'\x50', b'\x5A', b'\x00',
      b'\x64', b'\x6E', b'\x78', b'\x40',
    ],
  )
  let orig = img
  let out = histogram_normalize_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha 通道保留：out.data[i*4+3] == orig.data[i*4+3]
  for i in 0..<4 {
    assert_eq(out.data[i * 4 + 3], orig.data[i * 4 + 3])
  }
  // 显式验证 alpha 值
  assert_eq(out.data[3].to_int(), 255)
  assert_eq(out.data[7].to_int(), 128)
  assert_eq(out.data[11].to_int(), 0)
  assert_eq(out.data[15].to_int(), 64)
  let _ = img
  let _ = orig
  let _ = out
}
