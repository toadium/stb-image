// 纯 MoonBit 图像统计测试
// 纯逻辑断言测试（全目标可用：native/wasm/js），不依赖 @core
// 验证 compute_stats_pure / mean_value_pure 正确性

///|
fn is_make_rgb_image(
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
test "compute_stats_pure: basic stats" {
  // 2x2 RGB: (0,0,0)/(128,128,128)/(255,255,255)/(64,64,64)
  let img = is_make_rgb_image(2, 2, [
    (0, 0, 0),
    (128, 128, 128),
    (255, 255, 255),
    (64, 64, 64),
  ])
  let stats = compute_stats_pure(img)
  // 12 个通道值 [0,0,0,128,128,128,255,255,255,64,64,64]
  // mean = (0*3+128*3+255*3+64*3)/12 = (0+384+765+192)/12 = 1341/12 = 111.75
  // min_val=0, max_val=255
  assert_eq(stats.min_val, 0)
  assert_eq(stats.max_val, 255)
  let mean_diff = stats.mean - 111.75F
  let abs_diff = if mean_diff < 0.0F { -mean_diff } else { mean_diff }
  assert_true(abs_diff < 0.01F)
  let _ = img
  let _ = stats
}

///|
test "compute_stats_pure: uniform image" {
  // 2x2 全 128 RGB
  let img = is_make_rgb_image(2, 2, [
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
    (128, 128, 128),
  ])
  let stats = compute_stats_pure(img)
  // 12 个通道值全 128，mean=128.0, stddev=0.0, min=128, max=128
  assert_eq(stats.min_val, 128)
  assert_eq(stats.max_val, 128)
  let mean_diff = stats.mean - 128.0F
  let abs_mean_diff = if mean_diff < 0.0F { -mean_diff } else { mean_diff }
  assert_true(abs_mean_diff < 0.01F)
  let stddev_diff = stats.stddev - 0.0F
  let abs_stddev_diff = if stddev_diff < 0.0F {
    -stddev_diff
  } else {
    stddev_diff
  }
  assert_true(abs_stddev_diff < 0.01F)
  let _ = img
  let _ = stats
}

///|
test "mean_value_pure: basic mean" {
  // 2x2 RGB: (0,0,0)/(100,100,100)/(200,200,200)/(255,255,255)
  let img = is_make_rgb_image(2, 2, [
    (0, 0, 0),
    (100, 100, 100),
    (200, 200, 200),
    (255, 255, 255),
  ])
  let mean = mean_value_pure(img)
  // 12 个通道值均值 = (0*3+100*3+200*3+255*3)/12 = (0+300+600+765)/12 = 1665/12 = 138.75
  let diff = mean - 138.75F
  let abs_diff = if diff < 0.0F { -diff } else { diff }
  assert_true(abs_diff < 0.01F)
  let _ = img
  let _ = mean
}
