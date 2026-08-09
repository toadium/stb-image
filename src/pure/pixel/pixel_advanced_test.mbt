// 纯 MoonBit 高级像素操作测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 pixelate_pure / replace_color_pure / convolve_pure / swap_channels_pure 正确性

///|
fn pa_make_rgb_image(
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
fn pa_make_rgba_image(
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
test "pixelate_pure: basic pixelation" {
  // 4x4 RGB，像素逐行递增 (i,i,i)，i 从 0 到 15
  let img = pa_make_rgb_image(4, 4, [
    (0, 0, 0),
    (1, 1, 1),
    (2, 2, 2),
    (3, 3, 3),
    (4, 4, 4),
    (5, 5, 5),
    (6, 6, 6),
    (7, 7, 7),
    (8, 8, 8),
    (9, 9, 9),
    (10, 10, 10),
    (11, 11, 11),
    (12, 12, 12),
    (13, 13, 13),
    (14, 14, 14),
    (15, 15, 15),
  ])
  let out = pixelate_pure(img, 2)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // block (0,0) 取左上角 (0,0)=0
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[3], b'\x00')
  assert_eq(out.data[12], b'\x00')
  assert_eq(out.data[15], b'\x00')
  // block (1,0) 取左上角 (2,0)=2
  assert_eq(out.data[6], b'\x02')
  assert_eq(out.data[9], b'\x02')
  assert_eq(out.data[18], b'\x02')
  assert_eq(out.data[21], b'\x02')
  // block (0,1) 取左上角 (0,2)=8
  assert_eq(out.data[24], b'\x08')
  assert_eq(out.data[27], b'\x08')
  assert_eq(out.data[36], b'\x08')
  assert_eq(out.data[39], b'\x08')
  // block (1,1) 取左上角 (2,2)=10
  assert_eq(out.data[30], b'\x0A')
  assert_eq(out.data[33], b'\x0A')
  assert_eq(out.data[42], b'\x0A')
  assert_eq(out.data[45], b'\x0A')
  let _ = img
  let _ = out
}

///|
test "pixelate_pure: invalid block_size raises" {
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  // block_size=0
  let raised_zero = try {
    let _ = pixelate_pure(img, 0)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised_zero)
  // block_size=-1
  let raised_neg = try {
    let _ = pixelate_pure(img, -1)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised_neg)
  let _ = img
}

///|
test "replace_color_pure: exact match" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(10,20,30)/(40,50,60)
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (10, 20, 30),
    (40, 50, 60),
  ])
  let out = replace_color_pure(
    img,
    [b'\x0A', b'\x14', b'\x1E'],
    [b'\xFF', b'\x00', b'\x00'],
    0,
  )
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // (10,20,30) 像素替换为 (255,0,0)
  assert_eq(out.data[0], b'\xFF')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // (40,50,60) 像素不变
  assert_eq(out.data[3], b'\x28')
  assert_eq(out.data[4], b'\x32')
  assert_eq(out.data[5], b'\x3C')
  // (10,20,30) 像素替换为 (255,0,0)
  assert_eq(out.data[6], b'\xFF')
  assert_eq(out.data[7], b'\x00')
  assert_eq(out.data[8], b'\x00')
  // (40,50,60) 像素不变
  assert_eq(out.data[9], b'\x28')
  assert_eq(out.data[10], b'\x32')
  assert_eq(out.data[11], b'\x3C')
  let _ = img
  let _ = out
}

///|
test "replace_color_pure: tolerance match" {
  // 2x2 RGB: (10,20,30)/(12,22,32)/(50,60,70)/(52,62,72)
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (12, 22, 32),
    (50, 60, 70),
    (52, 62, 72),
  ])
  let out = replace_color_pure(
    img,
    [b'\x0A', b'\x14', b'\x1E'],
    [b'\x00', b'\xFF', b'\x00'],
    3,
  )
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 前两像素（差分 ≤3）替换为 (0,255,0)
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\xFF')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[3], b'\x00')
  assert_eq(out.data[4], b'\xFF')
  assert_eq(out.data[5], b'\x00')
  // 后两像素不变
  assert_eq(out.data[6], b'\x32')
  assert_eq(out.data[7], b'\x3C')
  assert_eq(out.data[8], b'\x46')
  assert_eq(out.data[9], b'\x34')
  assert_eq(out.data[10], b'\x3E')
  assert_eq(out.data[11], b'\x48')
  let _ = img
  let _ = out
}

///|
test "replace_color_pure: color array too short raises" {
  // 2x2 RGB（channels=3），old_color=[10,20]（length=2 < 3）
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let raised = try {
    let _ = replace_color_pure(
      img,
      [b'\x0A', b'\x14'],
      [b'\xFF', b'\x00', b'\x00'],
      0,
    )
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "convolve_pure: basic sharpen" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  // 锐化核 [0,-1,0,-1,5,-1,0,-1,0] bias=0 scale=1
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let out = convolve_pure(
    img,
    [0.0F, -1.0F, 0.0F, -1.0F, 5.0F, -1.0F, 0.0F, -1.0F, 0.0F],
    0.0F,
    1.0F,
  )
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // (0,0) = (0, 0, 0)（手算 R=-80→0, G=-70→0, B=-60→0）
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // (1,0) = (10, 20, 30)（手算 R=10, G=20, B=30）
  assert_eq(out.data[3], b'\x0A')
  assert_eq(out.data[4], b'\x14')
  assert_eq(out.data[5], b'\x1E')
  // (0,1) = (100, 110, 120)（手算 R=100, G=110, B=120）
  assert_eq(out.data[6], b'\x64')
  assert_eq(out.data[7], b'\x6E')
  assert_eq(out.data[8], b'\x78')
  // (1,1) = (190, 200, 210)（手算 R=190, G=200, B=210）
  assert_eq(out.data[9], b'\xBE')
  assert_eq(out.data[10], b'\xC8')
  assert_eq(out.data[11], b'\xD2')
  let _ = img
  let _ = out
}

///|
test "convolve_pure: kernel too short raises" {
  // kernel=[1.0,2.0,3.0]（length=3 < 9）
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let raised = try {
    let _ = convolve_pure(img, [1.0F, 2.0F, 3.0F], 0.0F, 1.0F)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "convolve_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  let img = pa_make_rgba_image(2, 2, [
    (10, 20, 30, 255),
    (40, 50, 60, 128),
    (70, 80, 90, 0),
    (100, 110, 120, 64),
  ])
  let out = convolve_pure(
    img,
    [0.0F, -1.0F, 0.0F, -1.0F, 5.0F, -1.0F, 0.0F, -1.0F, 0.0F],
    0.0F,
    1.0F,
  )
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 颜色通道卷积结果（与 basic sharpen 测试同构）
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[4], b'\x0A')
  assert_eq(out.data[5], b'\x14')
  assert_eq(out.data[6], b'\x1E')
  assert_eq(out.data[8], b'\x64')
  assert_eq(out.data[9], b'\x6E')
  assert_eq(out.data[10], b'\x78')
  assert_eq(out.data[12], b'\xBE')
  assert_eq(out.data[13], b'\xC8')
  assert_eq(out.data[14], b'\xD2')
  // alpha 通道与原始完全一致
  assert_eq(out.data[3], img.data[3])
  assert_eq(out.data[7], img.data[7])
  assert_eq(out.data[11], img.data[11])
  assert_eq(out.data[15], img.data[15])
  let _ = img
  let _ = out
}

///|
test "swap_channels_pure: swap R and B" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let out = swap_channels_pure(img, 0, 2)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // (30,20,10)
  assert_eq(out.data[0], b'\x1E')
  assert_eq(out.data[1], b'\x14')
  assert_eq(out.data[2], b'\x0A')
  // (60,50,40)
  assert_eq(out.data[3], b'\x3C')
  assert_eq(out.data[4], b'\x32')
  assert_eq(out.data[5], b'\x28')
  // (90,80,70)
  assert_eq(out.data[6], b'\x5A')
  assert_eq(out.data[7], b'\x50')
  assert_eq(out.data[8], b'\x46')
  // (120,110,100)
  assert_eq(out.data[9], b'\x78')
  assert_eq(out.data[10], b'\x6E')
  assert_eq(out.data[11], b'\x64')
  let _ = img
  let _ = out
}

///|
test "swap_channels_pure: channel out of range raises" {
  // 2x2 RGB（channels=3），ch1=3（越界）
  let img = pa_make_rgb_image(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let raised = try {
    let _ = swap_channels_pure(img, 3, 0)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}
