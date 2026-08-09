// 纯 MoonBit 图像工具测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 pad_pure / add_border_pure 正确性

///|
fn iu_make_rgb_image(
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
test "pad_pure: basic padding" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let img = iu_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let out = pad_pure(img, 1, 1, [b'\xFF', b'\xFF', b'\xFF'])
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // 输出 4x4，中心 2x2 为原始像素，四周为 (255,255,255)
  // out[0,0]=(255,255,255)（边框）
  assert_eq(out.data[0], b'\xFF')
  assert_eq(out.data[1], b'\xFF')
  assert_eq(out.data[2], b'\xFF')
  // out[1,1]=(10,20,30)（原始 [0,0]）：偏移 (1*4+1)*3 = 15
  assert_eq(out.data[15], b'\x0A')
  assert_eq(out.data[16], b'\x14')
  assert_eq(out.data[17], b'\x1E')
  // out[2,2]=(100,110,120)（原始 [1,1]）：偏移 (2*4+2)*3 = 30
  assert_eq(out.data[30], b'\x64')
  assert_eq(out.data[31], b'\x6E')
  assert_eq(out.data[32], b'\x78')
  // out[3,3]=(255,255,255)（边框）：偏移 (3*4+3)*3 = 45
  assert_eq(out.data[45], b'\xFF')
  assert_eq(out.data[46], b'\xFF')
  assert_eq(out.data[47], b'\xFF')
  let _ = img
  let _ = out
}

///|
test "pad_pure: negative px raises" {
  // 2x2 RGB
  let img = iu_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // px < 0
  let raised = try {
    let _ = pad_pure(img, -1, 1, [b'\x00'])
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "pad_pure: empty pad_color raises" {
  // 2x2 RGB
  let img = iu_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // pad_color 为空
  let raised = try {
    let _ = pad_pure(img, 1, 1, [])
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "add_border_pure: basic border" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let img = iu_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let out = add_border_pure(img, 1, 1, 1, 1, [b'\x00', b'\x00', b'\x00'])
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // 输出 4x4，中心 2x2 为原始像素，边框为 (0,0,0)
  // out[0,0]=(0,0,0)（边框）
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // out[1,1]=(10,20,30)（原始 [0,0]）：偏移 (1*4+1)*3 = 15
  assert_eq(out.data[15], b'\x0A')
  assert_eq(out.data[16], b'\x14')
  assert_eq(out.data[17], b'\x1E')
  // out[2,2]=(100,110,120)（原始 [1,1]）：偏移 (2*4+2)*3 = 30
  assert_eq(out.data[30], b'\x64')
  assert_eq(out.data[31], b'\x6E')
  assert_eq(out.data[32], b'\x78')
  // out[3,3]=(0,0,0)（边框）：偏移 (3*4+3)*3 = 45
  assert_eq(out.data[45], b'\x00')
  assert_eq(out.data[46], b'\x00')
  assert_eq(out.data[47], b'\x00')
  let _ = img
  let _ = out
}

///|
test "add_border_pure: negative border raises" {
  // 2x2 RGB
  let img = iu_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // top < 0
  let raised = try {
    let _ = add_border_pure(img, -1, 1, 1, 1, [b'\x00'])
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}
