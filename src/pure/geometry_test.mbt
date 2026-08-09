// 纯 MoonBit 仿射变换 + 任意角度旋转测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 warp_affine_pure / rotate_pure 正确性

///|
fn geo_make_rgb_image(
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
fn geo_make_rgba_image(
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
/// 逐像素逐通道容差比较（用于浮点三角函数精度场景）
fn geo_assert_approx(a : @types.Image, b : @types.Image, tol : Int) -> Unit raise {
  assert_eq(a.width, b.width)
  assert_eq(a.height, b.height)
  assert_eq(a.channels, b.channels)
  let n = a.width * a.height * a.channels
  for i in 0..<n {
    let diff = (a.data[i].to_int() - b.data[i].to_int()).abs()
    if diff > tol {
      fail("pixel \{i} diff \{diff} > tol \{tol}")
    }
  }
}

///|
test "warp_affine_pure: identity matrix is identity" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // 单位矩阵：src_x = dst_x, src_y = dst_y
  let out = warp_affine_pure(img, (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F), 2, 2)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "warp_affine_pure: scale up 2x" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // 缩放矩阵 (0.5, 0, 0, 0, 0.5, 0)：src_x = 0.5*dst_x, src_y = 0.5*dst_y
  // 输出 4x4，四角 src 坐标：
  //   out[0,0]: src=(0,0) 整数位置精确采样 → orig[0,0]=(10,20,30)
  //   out[3,0]: src=(1.5,0) 双线性插值 + clamp → (40,50,60)
  //   out[0,3]: src=(0,1.5) 双线性插值 + clamp → (70,80,90)
  //   out[3,3]: src=(1.5,1.5) 双线性插值 + clamp → (100,110,120)
  let out = warp_affine_pure(img, (0.5F, 0.0F, 0.0F, 0.0F, 0.5F, 0.0F), 4, 4)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 3)
  // out[0,0] 通道 R/G/B 位于 data[0..3]
  assert_eq(out.data[0].to_int(), 10)
  assert_eq(out.data[1].to_int(), 20)
  assert_eq(out.data[2].to_int(), 30)
  // out[3,0] 位于 data[(0*4+3)*3 ..] = data[9..12]
  assert_eq(out.data[9].to_int(), 40)
  assert_eq(out.data[10].to_int(), 50)
  assert_eq(out.data[11].to_int(), 60)
  // out[0,3] 位于 data[(3*4+0)*3 ..] = data[36..39]
  assert_eq(out.data[36].to_int(), 70)
  assert_eq(out.data[37].to_int(), 80)
  assert_eq(out.data[38].to_int(), 90)
  // out[3,3] 位于 data[(3*4+3)*3 ..] = data[45..48]
  assert_eq(out.data[45].to_int(), 100)
  assert_eq(out.data[46].to_int(), 110)
  assert_eq(out.data[47].to_int(), 120)
  let _ = img
  let _ = out
}

///|
test "warp_affine_pure: translation" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // 平移矩阵 (1, 0, 1, 0, 1, 1)：src = dst + (1, 1)
  // 输出 [0,0] 采样 src [1,1]，输出 4 像素均采样 src (1,1)/(2,1)/(1,2)/(2,2)
  // 2x2 图像 src (2,1)/(1,2)/(2,2) clamp 到 (1,1) 即 orig[1,1]=(100,110,120)
  let out = warp_affine_pure(img, (1.0F, 0.0F, 1.0F, 0.0F, 1.0F, 1.0F), 2, 2)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  // 输出 4 像素均为 (100,110,120)
  for i in 0..<4 {
    let off = i * 3
    assert_eq(out.data[off].to_int(), 100)
    assert_eq(out.data[off + 1].to_int(), 110)
    assert_eq(out.data[off + 2].to_int(), 120)
  }
  let _ = img
  let _ = out
}

///|
test "warp_affine_pure: RGBA alpha interpolated" {
  // 2x2 RGBA，alpha 全 255
  let img = geo_make_rgba_image(2, 2, [
    (10, 20, 30, 255), (40, 50, 60, 255), (70, 80, 90, 255), (100, 110, 120, 255),
  ])
  // 缩放矩阵输出 4x4，alpha 通道双线性插值 (255*w1+255*w2)=255
  let out = warp_affine_pure(img, (0.5F, 0.0F, 0.0F, 0.0F, 0.5F, 0.0F), 4, 4)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 4)
  // alpha 通道全 255
  for i in 0..<(4 * 4) {
    assert_eq(out.data[i * 4 + 3].to_int(), 255)
  }
  let _ = img
  let _ = out
}

///|
test "warp_affine_pure: 1x1 image" {
  // 1x1 RGB
  let img = geo_make_rgb_image(1, 1, [(128, 128, 128)])
  let out = warp_affine_pure(img, (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F), 1, 1)
  assert_eq(out.width, 1)
  assert_eq(out.height, 1)
  assert_eq(out.channels, 3)
  assert_eq(out.data[0].to_int(), 128)
  assert_eq(out.data[1].to_int(), 128)
  assert_eq(out.data[2].to_int(), 128)
  let _ = img
  let _ = out
}

///|
test "rotate_pure: 0 degrees is identity" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  // cos(0)=1, sin(0)=0，无超出边界，采样到整数位置
  let out = rotate_pure(img, 0.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 3)
  assert_eq(out.data, img.data)
  let _ = img
  let _ = out
}

///|
test "rotate_pure: 180 degrees approx matches rotate_180_pure" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let pure_rot = rotate_pure(img, 180.0F)
  let ref_rot = rotate_180_pure(img)
  // 180 度经 @math.cosf(π)/@math.sinf(π) 浮点计算，与精确整数变换存在微量误差
  // 统一采用容差比较（与 360 度同属浮点三角函数精度问题）
  geo_assert_approx(pure_rot, ref_rot, 1)
  let _ = img
  let _ = pure_rot
  let _ = ref_rot
}

///|
test "rotate_pure: 360 degrees approx identity" {
  // 2x2 RGB
  let img = geo_make_rgb_image(2, 2, [
    (10, 20, 30), (40, 50, 60), (70, 80, 90), (100, 110, 120),
  ])
  let out = rotate_pure(img, 360.0F)
  // 360 度经 @math.cosf(2π)/@math.sinf(2π) 浮点计算，存在微量误差
  // 用容差比较（与 180 度统一标准）
  geo_assert_approx(out, img, 1)
  let _ = img
  let _ = out
}

///|
test "rotate_pure: RGBA alpha interpolated" {
  // 2x2 RGBA，alpha 全 255
  let img = geo_make_rgba_image(2, 2, [
    (10, 20, 30, 255), (40, 50, 60, 255), (70, 80, 90, 255), (100, 110, 120, 255),
  ])
  let out = rotate_pure(img, 45.0F)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 4)
  // 非超出边界区域 alpha 通道双线性插值 (255*w1+255*w2)=255
  // 超出边界区域填黑 alpha=0
  // 断言每个 alpha 通道值为 0 或 255
  for i in 0..<(2 * 2) {
    let a = out.data[i * 4 + 3].to_int()
    if a != 0 && a != 255 {
      fail("alpha at pixel \{i} = \{a}, expected 0 or 255")
    }
  }
  let _ = img
  let _ = out
}

///|
test "rotate_pure: 1x1 image" {
  // 1x1 RGB
  let img = geo_make_rgb_image(1, 1, [(128, 128, 128)])
  // 1x1 旋转中心即自身，采样到 (0,0) 精确
  let out = rotate_pure(img, 45.0F)
  assert_eq(out.width, 1)
  assert_eq(out.height, 1)
  assert_eq(out.channels, 3)
  assert_eq(out.data[0].to_int(), 128)
  assert_eq(out.data[1].to_int(), 128)
  assert_eq(out.data[2].to_int(), 128)
  let _ = img
  let _ = out
}
