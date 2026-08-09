// 纯 MoonBit 图像几何变换测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 crop_pure / rotate_90_pure / rotate_180_pure / rotate_270_pure / flip_horizontal_pure 正确性

///|
fn tr_make_rgb_image(
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
test "crop_pure: basic" {
  // 4x4 RGB，每像素 (r, g, b) = (x*4+y, 0, 0)，便于追踪位置
  let pixels : Array[(Int, Int, Int)] = []
  for y in 0..<4 {
    for x in 0..<4 {
      pixels.push((x * 4 + y, 0, 0))
    }
  }
  let img = tr_make_rgb_image(4, 4, pixels)
  // 裁剪中心 2x2：x=1, y=1, w=2, h=2
  let cropped = crop_pure(img, 1, 1, 2, 2)
  assert_eq(cropped.width, 2)
  assert_eq(cropped.height, 2)
  assert_eq(cropped.channels, 3)
  // 预期像素按行主序: 第一行 (x=1,y=1)=5, (x=2,y=1)=9; 第二行 (x=1,y=2)=6, (x=2,y=2)=10
  let expected : Array[Byte] = []
  expected.push(b'\x05')
  expected.push(b'\x00')
  expected.push(b'\x00')
  expected.push(b'\x09')
  expected.push(b'\x00')
  expected.push(b'\x00')
  expected.push(b'\x06')
  expected.push(b'\x00')
  expected.push(b'\x00')
  expected.push(b'\x0A')
  expected.push(b'\x00')
  expected.push(b'\x00')
  assert_eq(cropped.data, Bytes::from_array(expected))
  let _ = img
  let _ = cropped
}

///|
test "crop_pure: out of bounds raises" {
  // 2x2 RGB
  let img = tr_make_rgb_image(2, 2, [
    (1, 0, 0), (2, 0, 0), (3, 0, 0), (4, 0, 0),
  ])
  // x+w > width: x=1, w=2 → 1+2=3 > 2
  let raised = try {
    let _ = crop_pure(img, 1, 0, 2, 2)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = img
}

///|
test "rotate_90_pure: 2x3 -> 3x2" {
  // 2x3 RGB（width=2, height=3），像素值 = (x*10+y, 0, 0)
  let pixels : Array[(Int, Int, Int)] = []
  for y in 0..<3 {
    for x in 0..<2 {
      pixels.push((x * 10 + y, 0, 0))
    }
  }
  let img = tr_make_rgb_image(2, 3, pixels)
  let rotated = rotate_90_pure(img)
  assert_eq(rotated.width, 3)
  assert_eq(rotated.height, 2)
  // 顺时针 90: (x, y) → (height-1-y, x)，新尺寸 (height=3, width=2)
  // 原像素 (x=0,y=0)=0 → 新 (nx=2, ny=0)，新图位置 (0, 2)
  // 原像素 (x=1,y=2)=12 → 新 (nx=0, ny=1)，新图位置 (1, 0)
  // 新图 data 按行主序：位置 (ny=0, nx=0..2), (ny=1, nx=0..2)
  // (0,0)=原(0,2)=2, (0,1)=原(0,1)=1, (0,2)=原(0,0)=0
  // (1,0)=原(1,2)=12, (1,1)=原(1,1)=11, (1,2)=原(1,0)=10
  assert_eq(rotated.data[0].to_int(), 2)
  assert_eq(rotated.data[3].to_int(), 1)
  assert_eq(rotated.data[6].to_int(), 0)
  assert_eq(rotated.data[9].to_int(), 12)
  assert_eq(rotated.data[12].to_int(), 11)
  assert_eq(rotated.data[15].to_int(), 10)
  let _ = img
  let _ = rotated
}

///|
test "rotate_180_pure: 2x2" {
  // 2x2 RGB，像素值 = (x*10+y, 0, 0)
  let img = tr_make_rgb_image(2, 2, [
    (0, 0, 0), (10, 0, 0), (1, 0, 0), (11, 0, 0),
  ])
  let rotated = rotate_180_pure(img)
  assert_eq(rotated.width, 2)
  assert_eq(rotated.height, 2)
  // 旋转 180: (x, y) → (width-1-x, height-1-y)
  // data 按行主序 [(0,0),(1,0),(0,1),(1,1)]: 新(0,0)=原(1,1)=11, 新(1,0)=原(0,1)=1, 新(0,1)=原(1,0)=10, 新(1,1)=原(0,0)=0
  assert_eq(rotated.data[0].to_int(), 11)
  assert_eq(rotated.data[3].to_int(), 1)
  assert_eq(rotated.data[6].to_int(), 10)
  assert_eq(rotated.data[9].to_int(), 0)
  let _ = img
  let _ = rotated
}

///|
test "rotate_270_pure: 2x3 -> 3x2" {
  // 2x3 RGB（width=2, height=3），像素值 = (x*10+y, 0, 0)
  let pixels : Array[(Int, Int, Int)] = []
  for y in 0..<3 {
    for x in 0..<2 {
      pixels.push((x * 10 + y, 0, 0))
    }
  }
  let img = tr_make_rgb_image(2, 3, pixels)
  let rotated = rotate_270_pure(img)
  assert_eq(rotated.width, 3)
  assert_eq(rotated.height, 2)
  // 顺时针 270 = 逆时针 90: (x, y) → (y, width-1-x)，新尺寸 (height=3, width=2)
  // 新 (0,0)=原(1,0)=10, (0,1)=原(1,1)=11, (0,2)=原(1,2)=12
  // 新 (1,0)=原(0,0)=0, (1,1)=原(0,1)=1, (1,2)=原(0,2)=2
  assert_eq(rotated.data[0].to_int(), 10)
  assert_eq(rotated.data[3].to_int(), 11)
  assert_eq(rotated.data[6].to_int(), 12)
  assert_eq(rotated.data[9].to_int(), 0)
  assert_eq(rotated.data[12].to_int(), 1)
  assert_eq(rotated.data[15].to_int(), 2)
  let _ = img
  let _ = rotated
}

///|
test "flip_horizontal_pure: 3x1" {
  // 3x1 RGB，像素值 = (x, 0, 0)
  let img = tr_make_rgb_image(3, 1, [
    (0, 0, 0), (1, 0, 0), (2, 0, 0),
  ])
  let flipped = flip_horizontal_pure(img)
  assert_eq(flipped.width, 3)
  assert_eq(flipped.height, 1)
  // 水平翻转: (x, y) → (width-1-x, y)
  // 新 (0,0)=原(2,0)=2, (1,0)=原(1,0)=1, (2,0)=原(0,0)=0
  assert_eq(flipped.data[0].to_int(), 2)
  assert_eq(flipped.data[3].to_int(), 1)
  assert_eq(flipped.data[6].to_int(), 0)
  let _ = img
  let _ = flipped
}

///|
test "1x1 identity" {
  // 1x1 RGB
  let img = tr_make_rgb_image(1, 1, [(42, 0, 0)])
  let r90 = rotate_90_pure(img)
  let r180 = rotate_180_pure(img)
  let r270 = rotate_270_pure(img)
  let fh = flip_horizontal_pure(img)
  assert_eq(r90.width, 1)
  assert_eq(r90.height, 1)
  assert_eq(r180.width, 1)
  assert_eq(r180.height, 1)
  assert_eq(r270.width, 1)
  assert_eq(r270.height, 1)
  assert_eq(fh.width, 1)
  assert_eq(fh.height, 1)
  assert_eq(r90.data, img.data)
  assert_eq(r180.data, img.data)
  assert_eq(r270.data, img.data)
  assert_eq(fh.data, img.data)
  let _ = img
  let _ = r90
  let _ = r180
  let _ = r270
  let _ = fh
}

///|
test "crop_pure: full image" {
  // 3x2 RGB，像素值 = (x*10+y, 0, 0)
  let pixels : Array[(Int, Int, Int)] = []
  for y in 0..<2 {
    for x in 0..<3 {
      pixels.push((x * 10 + y, 0, 0))
    }
  }
  let img = tr_make_rgb_image(3, 2, pixels)
  // 裁剪整幅图像
  let cropped = crop_pure(img, 0, 0, 3, 2)
  assert_eq(cropped.width, 3)
  assert_eq(cropped.height, 2)
  assert_eq(cropped.channels, 3)
  assert_eq(cropped.data, img.data)
  let _ = img
  let _ = cropped
}
