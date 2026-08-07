// 连通域标记测试

///|
test "connected_components: 单个连通域" {
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\x00', b'\x00',
    b'\xFF', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let img = @core.Image::{ width: 4, height: 4, channels: 1, data }
  let (label_img, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 1)
  assert_eq(comps[0].label, 1)
  assert_eq(comps[0].area, 4)
  assert_eq(comps[0].bbox_x, 1)
  assert_eq(comps[0].bbox_y, 1)
  assert_eq(comps[0].bbox_w, 2)
  assert_eq(comps[0].bbox_h, 2)
  assert_eq(label_img.width, 4)
  assert_eq(label_img.height, 4)
}

///|
test "connected_components: 两个独立连通域" {
  let data = Bytes::from_array([
    b'\xFF', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\xFF', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
  ])
  let img = @core.Image::{ width: 4, height: 4, channels: 1, data }
  let (_, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 2)
  assert_eq(comps[0].area, 2)
  assert_eq(comps[1].area, 2)
}

///|
test "connected_components: 四连通 vs 八连通" {
  // 对角线连接的两个像素
  let data = Bytes::from_array([b'\xFF', b'\x00', b'\x00', b'\xFF'])
  let img = @core.Image::{ width: 2, height: 2, channels: 1, data }
  // 四连通：两个独立域
  let (_, comps4) = connected_components(img, 4)
  assert_eq(comps4.length(), 2)
  // 八连通：一个连通域
  let (_, comps8) = connected_components(img, 8)
  assert_eq(comps8.length(), 1)
  assert_eq(comps8[0].area, 2)
}

///|
test "connected_components: 全背景" {
  let data = Bytes::from_array(Array::make(16, b'\x00'))
  let img = @core.Image::{ width: 4, height: 4, channels: 1, data }
  let (_, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 0)
}

///|
test "connected_components: 全前景" {
  let data = Bytes::from_array(Array::make(16, b'\xFF'))
  let img = @core.Image::{ width: 4, height: 4, channels: 1, data }
  let (_, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 1)
  assert_eq(comps[0].area, 16)
}

///|
test "connected_components: 质心计算" {
  let data = Bytes::from_array([
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\xFF', b'\xFF', b'\x00', b'\x00', b'\x00',
  ])
  let img = @core.Image::{ width: 3, height: 3, channels: 1, data }
  let (_, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 1)
  // 质心 x = (0+1+2)/3 = 1.0
  assert_eq(comps[0].centroid_x, 1.0F)
  // 质心 y = (1+1+1)/3 = 1.0
  assert_eq(comps[0].centroid_y, 1.0F)
}

///|
test "connected_components: connectivity 验证" {
  let data = Bytes::from_array([b'\xFF'])
  let img = @core.Image::{ width: 1, height: 1, channels: 1, data }
  try {
    let _ = connected_components(img, 6)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "connected_components: 多个连通域" {
  // 4 个角各一个像素
  let data = Bytes::from_array([
    b'\xFF', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\x00', b'\x00', b'\x00',
    b'\x00', b'\x00', b'\x00', b'\xFF', b'\x00', b'\x00', b'\xFF',
  ])
  let img = @core.Image::{ width: 4, height: 4, channels: 1, data }
  let (_, comps) = connected_components(img, 4)
  assert_eq(comps.length(), 4)
  for i in 0..<4 {
    assert_eq(comps[i].area, 1)
  }
}
