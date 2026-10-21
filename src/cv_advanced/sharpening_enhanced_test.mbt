///|
test "SharpeningMethod: 枚举值" {
  assert_true(
    @cv_advanced.SharpeningMethod::UnsharpMask is @cv_advanced.UnsharpMask,
  )
  assert_true(
    @cv_advanced.SharpeningMethod::Laplacian is @cv_advanced.Laplacian,
  )
  assert_true(
    @cv_advanced.SharpeningMethod::WienerDeconv is @cv_advanced.WienerDeconv,
  )
  assert_true(@cv_advanced.SharpeningMethod::Adaptive is @cv_advanced.Adaptive)
  assert_true(
    @cv_advanced.SharpeningMethod::DepthAware is @cv_advanced.DepthAware,
  )
}

///|
test "SharpeningParams: 构造与字段" {
  let p : @cv_advanced.SharpeningParams = {
    sharpen_method: @cv_advanced.Laplacian,
    strength: 0.8,
    radius: 2,
    threshold: 15.0,
    noise_level: 0.05,
  }
  assert_eq(p.strength, 0.8)
  assert_eq(p.radius, 2)
  assert_eq(p.threshold, 15.0)
  assert_eq(p.noise_level, 0.05)
  assert_true(p.sharpen_method is @cv_advanced.Laplacian)
}

///|
test "sharpen_unsharp_mask: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.sharpen_unsharp_mask(img, 0.5, 1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 1)
}

///|
test "sharpen_unsharp_mask: 零强度返回原图" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 50, 75, 125, 25, 175, 225]),
  }
  let result = @cv_advanced.sharpen_unsharp_mask(img, 0.0, 1)
  // 零强度应近似返回原图
  for i in 0..<img.data.length() {
    assert_eq(result.data[i], img.data[i])
  }
}

///|
test "sharpen_laplacian: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.sharpen_laplacian(img, 0.3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "sharpen_laplacian: 零强度返回原图" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 50, 75, 125, 25, 175, 225]),
  }
  let result = @cv_advanced.sharpen_laplacian(img, 0.0)
  for i in 0..<img.data.length() {
    assert_eq(result.data[i], img.data[i])
  }
}

///|
test "sharpen_wiener_deconv: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.sharpen_wiener_deconv(img, 0.5, 0.01)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "sharpen_adaptive: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.sharpen_adaptive(img, 1.0, 1, 5.0)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "sharpen_depth_aware: 基本测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 50, 75, 125, 25, 175, 225]),
  }
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [1.0, 5.0, 10.0, 2.0, 6.0, 8.0, 3.0, 4.0, 9.0],
    valid: [true, true, true, true, true, true, true, true, true],
  }
  let result = @cv_advanced.sharpen_depth_aware(img, depth, 0.5, 1.0, 10.0)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
}

///|
test "sharpen_pipeline: 各方法" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  for
    m in [
      @cv_advanced.UnsharpMask,
      @cv_advanced.Laplacian,
      @cv_advanced.WienerDeconv,
      @cv_advanced.Adaptive,
      @cv_advanced.DepthAware,
    ] {
    let params = @cv_advanced.default_sharpening_params(m)
    let result = @cv_advanced.sharpen_pipeline(img, params)
    assert_eq(result.width, 4)
    assert_eq(result.height, 4)
    assert_eq(result.channels, 1)
  }
}

///|
test "default_sharpening_params: 默认值" {
  let p = @cv_advanced.default_sharpening_params(@cv_advanced.UnsharpMask)
  assert_eq(p.strength, 0.5)
  assert_eq(p.radius, 1)
  assert_eq(p.threshold, 10.0)
  assert_eq(p.noise_level, 0.01)
  assert_true(p.sharpen_method is @cv_advanced.UnsharpMask)
}

///|
test "estimate_sharpness: 常数图像锐度为0" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
      128,
    ]),
  }
  let sharpness = @cv_advanced.estimate_sharpness(img)
  // 常数图像 Laplacian 为 0，方差为 0
  assert_true(sharpness.abs() < 0.001)
}

///|
test "estimate_sharpness: 有边缘图像锐度大于常数图像" {
  let constant_img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128, 128,
      128,
    ]),
  }
  let edge_img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255,
    ]),
  }
  let constant_sharpness = @cv_advanced.estimate_sharpness(constant_img)
  let edge_sharpness = @cv_advanced.estimate_sharpness(edge_img)
  // 有边缘的图像锐度应大于常数图像
  assert_true(edge_sharpness > constant_sharpness)
}
