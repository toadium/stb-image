// 纯 MoonBit 图像拼接测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 hstack_pure / vstack_pure / tile_pure / flip_vertical_pure / transpose_pure 正确性

///|
fn ic_make_rgb_image(
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
test "hstack_pure: basic horizontal stack" {
  // left 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let left = ic_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // right 2x2 RGB: (1,2,3)/(4,5,6)/(7,8,9)/(10,11,12)
  let right = ic_make_rgb_image(2, 2, [
    (1, 2, 3), (4, 5, 6), (7, 8, 9), (10, 11, 12),
  ])
  let out = hstack_pure(left, right)
  assert_eq(out.width, 4)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 行 0: left[0,0]=(10,20,30) left[0,1]=(40,50,60) right[0,0]=(1,2,3) right[0,1]=(4,5,6)
  // 行 1: left[1,0]=(70,80,90) left[1,1]=(100,110,120) right[1,0]=(7,8,9) right[1,1]=(10,11,12)
  let expected : Array[Byte] = [
    10, 20, 30, 40, 50, 60, 1, 2, 3, 4, 5, 6, 70, 80, 90, 100, 110, 120, 7,
    8, 9, 10, 11, 12,
  ].map(fn(v) { v.to_byte() })
  assert_eq(out.data, Bytes::from_array(expected))
  let _ = left
  let _ = right
  let _ = out
}

///|
test "hstack_pure: dimension mismatch raises" {
  // left 2x2 RGB, right 2x3 RGB（高度不同）
  let left = ic_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let right = ic_make_rgb_image(2, 3, [
    (1, 2, 3), (4, 5, 6), (7, 8, 9), (10, 11, 12), (13, 14, 15), (16, 17, 18),
  ])
  let raised = try {
    let _ = hstack_pure(left, right)
    false
  } catch {
    @types.LoadError::DecodeFailed(_) => true
    _ => false
  }
  assert_true(raised)
  let _ = left
  let _ = right
}

///|
test "vstack_pure: basic vertical stack" {
  // top 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let top = ic_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // bottom 2x2 RGB: (1,2,3)/(4,5,6)/(7,8,9)/(10,11,12)
  let bottom = ic_make_rgb_image(2, 2, [
    (1, 2, 3), (4, 5, 6), (7, 8, 9), (10, 11, 12),
  ])
  let out = vstack_pure(top, bottom)
  assert_eq(out.width, 2)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // top 12 字节 + bottom 12 字节顺序拼接
  let expected : Array[Byte] = [
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 1, 2, 3, 4, 5, 6, 7,
    8, 9, 10, 11, 12,
  ].map(fn(v) { v.to_byte() })
  assert_eq(out.data, Bytes::from_array(expected))
  let _ = top
  let _ = bottom
  let _ = out
}

///|
test "tile_pure: basic tile" {
  // 2x2 RGB: (10,20,30)/(40,50,60)/(70,80,90)/(100,110,120)
  let img = ic_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let out = tile_pure(img, 2, 3)
  assert_eq(out.width, 4)
  assert_eq(out.height, 6)
  // 验证平铺后 data 正确（每个位置 src_x=x%2, src_y=y%2）
  for y in 0..<6 {
    for x in 0..<4 {
      let src_x = x % 2
      let src_y = y % 2
      let src_off = (src_y * 2 + src_x) * 3
      let dst_off = (y * 4 + x) * 3
      for c in 0..<3 {
        assert_eq(out.data[dst_off + c], img.data[src_off + c])
      }
    }
  }
  let _ = img
  let _ = out
}

///|
test "flip_vertical_pure: basic flip" {
  // 2x3 RGB（width=2, height=3），像素逐行递增
  let img = ic_make_rgb_image(2, 3, [
    (0, 0, 0), (1, 1, 1), (2, 2, 2), (3, 3, 3), (4, 4, 4), (5, 5, 5),
  ])
  let out = flip_vertical_pure(img)
  assert_eq(out.width, 2)
  assert_eq(out.height, 3)
  // 行序翻转：第 0 行↔第 2 行，第 1 行不变
  // 原行 2 (4,4,4)/(5,5,5) → 新行 0
  // 原行 1 (2,2,2)/(3,3,3) → 新行 1
  // 原行 0 (0,0,0)/(1,1,1) → 新行 2
  let expected : Array[Byte] = [
    4, 4, 4, 5, 5, 5, 2, 2, 2, 3, 3, 3, 0, 0, 0, 1, 1, 1,
  ].map(fn(v) { v.to_byte() })
  assert_eq(out.data, Bytes::from_array(expected))
  let _ = img
  let _ = out
}

///|
test "transpose_pure: basic transpose" {
  // 2x3 RGB（width=2, height=3）→ 3x2 RGB（width=3, height=2）
  let img = ic_make_rgb_image(2, 3, [
    (0, 0, 0), (1, 1, 1), (2, 2, 2), (3, 3, 3), (4, 4, 4), (5, 5, 5),
  ])
  let out = transpose_pure(img)
  assert_eq(out.width, 3)
  assert_eq(out.height, 2)
  // 转置公式：dst[x*new_w+y] = src[y*w+x]，new_w=3, w=2
  for y in 0..<3 {
    for x in 0..<2 {
      let src_off = (y * 2 + x) * 3
      let dst_off = (x * 3 + y) * 3
      for c in 0..<3 {
        assert_eq(out.data[dst_off + c], img.data[src_off + c])
      }
    }
  }
  let _ = img
  let _ = out
}
