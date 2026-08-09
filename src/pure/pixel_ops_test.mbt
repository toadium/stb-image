// 纯 MoonBit 像素操作测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 threshold_pure / posterize_pure / extract_channel_pure 正确性

///|
fn po_make_rgb_image(
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
  @types.Image::{
    width,
    height,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
fn po_make_rgba_image(
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
  @types.Image::{
    width,
    height,
    channels: 4,
    data: Bytes::from_array(data),
  }
}

///|
test "threshold_pure: basic binarization" {
  // 2x2 RGB: (10,20,30)/(200,100,50)/(128,64,200)/(0,255,128)
  let img = po_make_rgb_image(2, 2, [
    (10, 20, 30), (200, 100, 50), (128, 64, 200), (0, 255, 128),
  ])
  let out = threshold_pure(img, 128)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // out[0,0]=(0,0,0)（10<128,20<128,30<128）
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // out[1,0]=(255,0,0)（200>=128,100<128,50<128）
  assert_eq(out.data[3], b'\xFF')
  assert_eq(out.data[4], b'\x00')
  assert_eq(out.data[5], b'\x00')
  // out[0,1]=(255,0,255)（128>=128,64<128,200>=128）
  assert_eq(out.data[6], b'\xFF')
  assert_eq(out.data[7], b'\x00')
  assert_eq(out.data[8], b'\xFF')
  // out[1,1]=(0,255,255)（0<128,255>=128,128>=128）
  assert_eq(out.data[9], b'\x00')
  assert_eq(out.data[10], b'\xFF')
  assert_eq(out.data[11], b'\xFF')
  let _ = img
  let _ = out
}

///|
test "threshold_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  let img = po_make_rgba_image(2, 2, [
    (10, 20, 30, 255), (200, 100, 50, 128), (128, 64, 200, 0), (0, 255, 128, 64),
  ])
  let out = threshold_pure(img, 128)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 颜色通道二值化正确
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[4], b'\xFF')
  assert_eq(out.data[5], b'\x00')
  assert_eq(out.data[6], b'\x00')
  assert_eq(out.data[8], b'\xFF')
  assert_eq(out.data[9], b'\x00')
  assert_eq(out.data[10], b'\xFF')
  assert_eq(out.data[12], b'\x00')
  assert_eq(out.data[13], b'\xFF')
  assert_eq(out.data[14], b'\xFF')
  // alpha 通道与原始完全一致
  assert_eq(out.data[3], img.data[3])
  assert_eq(out.data[7], img.data[7])
  assert_eq(out.data[11], img.data[11])
  assert_eq(out.data[15], img.data[15])
  let _ = img
  let _ = out
}

///|
test "threshold_pure: all below threshold" {
  // 2x2 RGB 像素全 (10,20,30)
  let img = po_make_rgb_image(2, 2, [
    (10, 20, 30), (10, 20, 30), (10, 20, 30), (10, 20, 30),
  ])
  let out = threshold_pure(img, 128)
  // data 全 0（全部 < 128）
  for i in 0..<out.data.length() {
    assert_eq(out.data[i], b'\x00')
  }
  let _ = img
  let _ = out
}

///|
test "posterize_pure: basic quantization" {
  // 2x2 RGB: (0,0,0)/(64,64,64)/(128,128,128)/(255,255,255)
  let img = po_make_rgb_image(2, 2, [
    (0, 0, 0), (64, 64, 64), (128, 128, 128), (255, 255, 255),
  ])
  let out = posterize_pure(img, 4)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // step=64.0，量化：(0/64).to_int()*64=0、(64/64).to_int()*64=64、(128/64).to_int()*64=128、(255/64).to_int()*64=192
  // out[0,0]=(0,0,0)
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // out[1,0]=(64,64,64)
  assert_eq(out.data[3], b'\x40')
  assert_eq(out.data[4], b'\x40')
  assert_eq(out.data[5], b'\x40')
  // out[0,1]=(128,128,128)
  assert_eq(out.data[6], b'\x80')
  assert_eq(out.data[7], b'\x80')
  assert_eq(out.data[8], b'\x80')
  // out[1,1]=(192,192,192)
  assert_eq(out.data[9], b'\xC0')
  assert_eq(out.data[10], b'\xC0')
  assert_eq(out.data[11], b'\xC0')
  let _ = img
  let _ = out
}

///|
test "posterize_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  let img = po_make_rgba_image(2, 2, [
    (0, 0, 0, 255), (64, 64, 64, 128), (128, 128, 128, 0), (255, 255, 255, 64),
  ])
  let out = posterize_pure(img, 4)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 颜色通道量化正确
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[4], b'\x40')
  assert_eq(out.data[5], b'\x40')
  assert_eq(out.data[6], b'\x40')
  assert_eq(out.data[8], b'\x80')
  assert_eq(out.data[9], b'\x80')
  assert_eq(out.data[10], b'\x80')
  assert_eq(out.data[12], b'\xC0')
  assert_eq(out.data[13], b'\xC0')
  assert_eq(out.data[14], b'\xC0')
  // alpha 通道与原始完全一致
  assert_eq(out.data[3], img.data[3])
  assert_eq(out.data[7], img.data[7])
  assert_eq(out.data[11], img.data[11])
  assert_eq(out.data[15], img.data[15])
  let _ = img
  let _ = out
}

///|
test "posterize_pure: invalid levels raises" {
  // 2x2 RGB
  let img = po_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // levels < 2
  let raised_low = try {
    let _ = posterize_pure(img, 1)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised_low)
  // levels > 256
  let raised_high = try {
    let _ = posterize_pure(img, 257)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised_high)
  let _ = img
}

///|
test "extract_channel_pure: extract R channel" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let img = po_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let out = extract_channel_pure(img, 0)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 1)
  // data == [10,40,70,100]（提取 R 通道）
  assert_eq(out.data[0], b'\x0A')
  assert_eq(out.data[1], b'\x28')
  assert_eq(out.data[2], b'\x46')
  assert_eq(out.data[3], b'\x64')
  let _ = img
  let _ = out
}

///|
test "extract_channel_pure: channel out of range raises" {
  // 2x2 RGB（channels=3）
  let img = po_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // channel >= channels（channel=3, channels=3）
  let raised = try {
    let _ = extract_channel_pure(img, 3)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}
