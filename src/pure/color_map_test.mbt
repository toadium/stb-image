// 纯 MoonBit 色彩映射测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 apply_lut_pure / gradient_map_pure / set_alpha_pure / fill_alpha_pure 正确性

///|
fn cm_make_rgb_image(
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
fn cm_make_rgba_image(
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
fn cm_make_invert_lut() -> Array[Byte] {
  let lut : Array[Byte] = Array::make(256, b'\x00')
  for v in 0..<256 {
    lut[v] = (255 - v).to_byte()
  }
  lut
}

///|
test "apply_lut_pure: basic LUT" {
  // 2x2 RGB: (0,128,255)/(64,192,32)/(100,150,200)/(50,75,125)
  let img = cm_make_rgb_image(2, 2, [
    (0, 128, 255), (64, 192, 32), (100, 150, 200), (50, 75, 125),
  ])
  let lut = cm_make_invert_lut()
  let out = apply_lut_pure(img, lut)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // (0,128,255) → (255,127,0)
  assert_eq(out.data[0], b'\xFF')
  assert_eq(out.data[1], b'\x7F')
  assert_eq(out.data[2], b'\x00')
  // (64,192,32) → (191,63,223)
  assert_eq(out.data[3], b'\xBF')
  assert_eq(out.data[4], b'\x3F')
  assert_eq(out.data[5], b'\xDF')
  // (100,150,200) → (155,105,55)
  assert_eq(out.data[6], b'\x9B')
  assert_eq(out.data[7], b'\x69')
  assert_eq(out.data[8], b'\x37')
  // (50,75,125) → (205,180,130)
  assert_eq(out.data[9], b'\xCD')
  assert_eq(out.data[10], b'\xB4')
  assert_eq(out.data[11], b'\x82')
  let _ = img
  let _ = out
  let _ = lut
}

///|
test "apply_lut_pure: lut too short raises" {
  // lut.length=255（< 256）
  let img = cm_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let lut : Array[Byte] = Array::make(255, b'\x00')
  let raised = try {
    let _ = apply_lut_pure(img, lut)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
  let _ = lut
}

///|
test "apply_lut_pure: RGBA alpha preserved" {
  // 2x2 RGBA，alpha 通道设 4 个不同值（255/128/0/64）
  let img = cm_make_rgba_image(2, 2, [
    (0, 128, 255, 255), (64, 192, 32, 128), (100, 150, 200, 0), (50, 75, 125, 64),
  ])
  let lut = cm_make_invert_lut()
  let out = apply_lut_pure(img, lut)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 颜色通道 v→255-v
  assert_eq(out.data[0], b'\xFF')
  assert_eq(out.data[1], b'\x7F')
  assert_eq(out.data[2], b'\x00')
  assert_eq(out.data[4], b'\xBF')
  assert_eq(out.data[5], b'\x3F')
  assert_eq(out.data[6], b'\xDF')
  assert_eq(out.data[8], b'\x9B')
  assert_eq(out.data[9], b'\x69')
  assert_eq(out.data[10], b'\x37')
  assert_eq(out.data[12], b'\xCD')
  assert_eq(out.data[13], b'\xB4')
  assert_eq(out.data[14], b'\x82')
  // alpha 通道与原始完全一致
  assert_eq(out.data[3], img.data[3])
  assert_eq(out.data[7], img.data[7])
  assert_eq(out.data[11], img.data[11])
  assert_eq(out.data[15], img.data[15])
  let _ = img
  let _ = out
  let _ = lut
}

///|
test "gradient_map_pure: basic gradient" {
  // 2x2 RGB: (0,0,0)/(128,128,128)/(255,255,255)/(64,64,64)
  let img = cm_make_rgb_image(2, 2, [
    (0, 0, 0), (128, 128, 128), (255, 255, 255), (64, 64, 64),
  ])
  // color_stops=[(0,0,0,0),(255,255,255,255)]（黑→白渐变）
  let stops : Array[(Int, Byte, Byte, Byte)] = [
    (0, b'\x00', b'\x00', b'\x00'),
    (255, b'\xFF', b'\xFF', b'\xFF'),
  ]
  let out = gradient_map_pure(img, stops)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 亮度 0→(0,0,0)
  assert_eq(out.data[0], b'\x00')
  assert_eq(out.data[1], b'\x00')
  assert_eq(out.data[2], b'\x00')
  // 亮度 128→(128,128,128)
  assert_eq(out.data[3], b'\x80')
  assert_eq(out.data[4], b'\x80')
  assert_eq(out.data[5], b'\x80')
  // 亮度 255→(255,255,255)
  assert_eq(out.data[6], b'\xFF')
  assert_eq(out.data[7], b'\xFF')
  assert_eq(out.data[8], b'\xFF')
  // 亮度 64→(64,64,64)
  assert_eq(out.data[9], b'\x40')
  assert_eq(out.data[10], b'\x40')
  assert_eq(out.data[11], b'\x40')
  let _ = img
  let _ = out
  let _ = stops
}

///|
test "gradient_map_pure: insufficient color stops raises" {
  // color_stops=[(0,0,0,0)]（length=1 < 2）
  let img = cm_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let stops : Array[(Int, Byte, Byte, Byte)] = [
    (0, b'\x00', b'\x00', b'\x00'),
  ]
  let raised = try {
    let _ = gradient_map_pure(img, stops)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
  let _ = stops
}

///|
test "set_alpha_pure: set alpha" {
  // 2x2 RGBA，alpha 通道初始全 255
  let img = cm_make_rgba_image(2, 2, [
    (10, 20, 30, 255), (40, 50, 60, 255), (70, 80, 90, 255), (100, 110, 120, 255),
  ])
  let out = set_alpha_pure(img, b'\x80')
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 颜色通道不变
  assert_eq(out.data[0], b'\x0A')
  assert_eq(out.data[1], b'\x14')
  assert_eq(out.data[2], b'\x1E')
  assert_eq(out.data[4], b'\x28')
  assert_eq(out.data[5], b'\x32')
  assert_eq(out.data[6], b'\x3C')
  assert_eq(out.data[8], b'\x46')
  assert_eq(out.data[9], b'\x50')
  assert_eq(out.data[10], b'\x5A')
  assert_eq(out.data[12], b'\x64')
  assert_eq(out.data[13], b'\x6E')
  assert_eq(out.data[14], b'\x78')
  // alpha 通道全为 128
  assert_eq(out.data[3], b'\x80')
  assert_eq(out.data[7], b'\x80')
  assert_eq(out.data[11], b'\x80')
  assert_eq(out.data[15], b'\x80')
  let _ = img
  let _ = out
}

///|
test "set_alpha_pure: non-RGBA raises" {
  // 2x2 RGB（channels=3）
  let img = cm_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let raised = try {
    let _ = set_alpha_pure(img, b'\x80')
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "fill_alpha_pure: fill alpha" {
  // 2x2 RGBA，像素 alpha 值 [200,50,200,50]（threshold=128）
  let img = cm_make_rgba_image(2, 2, [
    (10, 20, 30, 200), (40, 50, 60, 50), (70, 80, 90, 200), (100, 110, 120, 50),
  ])
  let out = fill_alpha_pure(img, 128, b'\x00', b'\x00', b'\x00')
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // alpha=200 >= 128，RGB 不变
  assert_eq(out.data[0], b'\x0A')
  assert_eq(out.data[1], b'\x14')
  assert_eq(out.data[2], b'\x1E')
  // alpha=50 < 128，RGB 设为 (0,0,0)
  assert_eq(out.data[4], b'\x00')
  assert_eq(out.data[5], b'\x00')
  assert_eq(out.data[6], b'\x00')
  // alpha=200 >= 128，RGB 不变
  assert_eq(out.data[8], b'\x46')
  assert_eq(out.data[9], b'\x50')
  assert_eq(out.data[10], b'\x5A')
  // alpha=50 < 128，RGB 设为 (0,0,0)
  assert_eq(out.data[12], b'\x00')
  assert_eq(out.data[13], b'\x00')
  assert_eq(out.data[14], b'\x00')
  // alpha 通道全部保留与原始一致
  assert_eq(out.data[3], img.data[3])
  assert_eq(out.data[7], img.data[7])
  assert_eq(out.data[11], img.data[11])
  assert_eq(out.data[15], img.data[15])
  let _ = img
  let _ = out
}
