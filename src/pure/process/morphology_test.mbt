// 纯 MoonBit 形态学操作测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 erode_pure / dilate_pure / morph_open_pure / morph_close_pure 正确性

///|
fn morph_make_image(
  width : Int,
  height : Int,
  channels : Int,
  data : Array[Byte],
) -> @types.Image {
  @types.Image::{ width, height, channels, data: Bytes::from_array(data) }
}

///|
test "erode_pure: uniform image is unchanged" {
  // 3x3 灰度（channels=1）全 128，erode 后全 128
  let img = morph_make_image(3, 3, 1, Array::make(9, b'\x80'))
  let out = erode_pure(img)
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
test "dilate_pure: uniform image is unchanged" {
  // 3x3 灰度全 128，dilate 后全 128
  let img = morph_make_image(3, 3, 1, Array::make(9, b'\x80'))
  let out = dilate_pure(img)
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
test "erode_pure: shrinks bright region" {
  // 5x5 灰度中心 3x3 白（255）其余黑（0），erode 后仅中心 (2,2) 白，四角 (1,1)/(1,3)/(3,1)/(3,3) 黑
  let img = morph_make_image(5, 5, 1, [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF',
    b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let out = erode_pure(img)
  assert_eq(out.width, 5)
  assert_eq(out.height, 5)
  assert_eq(out.channels, 1)
  // 中心 (2,2) 白
  assert_eq(out.data[2 * 5 + 2].to_int(), 255)
  // 四角 (1,1)/(1,3)/(3,1)/(3,3) 黑
  assert_eq(out.data[1 * 5 + 1].to_int(), 0)
  assert_eq(out.data[1 * 5 + 3].to_int(), 0)
  assert_eq(out.data[3 * 5 + 1].to_int(), 0)
  assert_eq(out.data[3 * 5 + 3].to_int(), 0)
  let _ = img
  let _ = out
}

///|
test "dilate_pure: expands bright region" {
  // 5x5 灰度仅中心 (2,2) 白，dilate 后 3x3 邻域全白，远处 (0,0)/(4,4) 黑
  let img = morph_make_image(5, 5, 1, [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let out = dilate_pure(img)
  assert_eq(out.width, 5)
  assert_eq(out.height, 5)
  assert_eq(out.channels, 1)
  // 3x3 邻域 (1,1)-(3,3) 全白
  for y in 1..<=3 {
    for x in 1..<=3 {
      assert_eq(out.data[y * 5 + x].to_int(), 255)
    }
  }
  // 远处 (0,0)/(4,4) 黑
  assert_eq(out.data[0 * 5 + 0].to_int(), 0)
  assert_eq(out.data[4 * 5 + 4].to_int(), 0)
  let _ = img
  let _ = out
}

///|
test "morph_open_pure: removes isolated bright pixel" {
  // 5x5 全黑中心一白点，morph_open 后全黑
  let data : Array[Byte] = Array::make(25, b'\x00')
  data[2 * 5 + 2] = b'\xFF'
  let img = morph_make_image(5, 5, 1, data)
  let out = morph_open_pure(img)
  assert_eq(out.width, 5)
  assert_eq(out.height, 5)
  assert_eq(out.channels, 1)
  for i in 0..<25 {
    assert_eq(out.data[i].to_int(), 0)
  }
  let _ = img
  let _ = out
}

///|
test "morph_close_pure: fills isolated dark pixel" {
  // 5x5 全白中心一黑点，morph_close 后全白
  let data : Array[Byte] = Array::make(25, b'\xFF')
  data[2 * 5 + 2] = b'\x00'
  let img = morph_make_image(5, 5, 1, data)
  let out = morph_close_pure(img)
  assert_eq(out.width, 5)
  assert_eq(out.height, 5)
  assert_eq(out.channels, 1)
  for i in 0..<25 {
    assert_eq(out.data[i].to_int(), 255)
  }
  let _ = img
  let _ = out
}

///|
test "morph_open_pure: idempotent" {
  // 5x5 中心 3x3 白但中心 (2,2) 黑，morph_open(morph_open(img)) == morph_open(img)
  let img = morph_make_image(5, 5, 1, [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF',
    b'\x00', b'\x00', b'\xFF', b'\x00', b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF',
    b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let open1 = morph_open_pure(img)
  let open2 = morph_open_pure(open1)
  assert_eq(open2.width, open1.width)
  assert_eq(open2.height, open1.height)
  assert_eq(open2.channels, open1.channels)
  assert_eq(open2.data, open1.data)
  let _ = img
  let _ = open1
  let _ = open2
}

///|
test "morph_close_pure: idempotent" {
  // 5x5 全白中心 (2,2) 黑，morph_close(morph_close(img)) == morph_close(img)
  let data : Array[Byte] = Array::make(25, b'\xFF')
  data[2 * 5 + 2] = b'\x00'
  let img = morph_make_image(5, 5, 1, data)
  let close1 = morph_close_pure(img)
  let close2 = morph_close_pure(close1)
  assert_eq(close2.width, close1.width)
  assert_eq(close2.height, close1.height)
  assert_eq(close2.channels, close1.channels)
  assert_eq(close2.data, close1.data)
  let _ = img
  let _ = close1
  let _ = close2
}

///|
test "erode_pure: RGB multi-channel" {
  // 3x3 RGB（channels=3）中心 (1,1) 红 (255,0,0) 其余黑 (0,0,0)
  // erode 后各通道独立处理（R 通道中心 3x3 邻域全 0 → 0，G/B 通道全 0 → 0）
  let img = morph_make_image(3, 3, 3, [
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let out = erode_pure(img)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 3)
  // 所有像素各通道全 0
  for i in 0..<27 {
    assert_eq(out.data[i].to_int(), 0)
  }
  let _ = img
  let _ = out
}
