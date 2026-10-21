///|
test "ToneMappingMethod: 枚举值" {
  assert_true(@cv_advanced.ToneMappingMethod::Reinhard is @cv_advanced.Reinhard)
  assert_true(@cv_advanced.ToneMappingMethod::Drago is @cv_advanced.Drago)
  assert_true(@cv_advanced.ToneMappingMethod::Gamma is @cv_advanced.Gamma)
  assert_true(
    @cv_advanced.ToneMappingMethod::Logarithmic is @cv_advanced.Logarithmic,
  )
  assert_true(
    @cv_advanced.ToneMappingMethod::LocalLaplacian
    is @cv_advanced.LocalLaplacian,
  )
  assert_true(
    @cv_advanced.ToneMappingMethod::Bilateral is @cv_advanced.Bilateral,
  )
}

///|
test "ToneMappingParams: 构造与字段" {
  let p : @cv_advanced.ToneMappingParams = {
    tm_method: @cv_advanced.Reinhard,
    exposure: 1.0,
    gamma: 2.2,
    white_point: 1.5,
    saturation: 0.8,
  }
  assert_eq(p.exposure, 1.0)
  assert_eq(p.gamma, 2.2)
  assert_eq(p.white_point, 1.5)
  assert_eq(p.saturation, 0.8)
  assert_true(p.tm_method is @cv_advanced.Reinhard)
}

///|
test "tone_map_reinhard: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      0, 64, 128, 192, 32, 96, 160, 224, 48, 112, 176, 240, 16, 80, 144, 208,
    ]),
  }
  let result = @cv_advanced.tone_map_reinhard(img, 0.0, 1.0)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 1)
}

///|
test "tone_map_reinhard: 零曝光保持范围" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 255]),
  }
  let result = @cv_advanced.tone_map_reinhard(img, 0.0, 1.0)
  // 零像素映射到零
  assert_eq(result.data[0], (0 : Byte))
  // 最大像素映射到小于 255
  assert_true(result.data[1].to_int() > 0)
  assert_true(result.data[1].to_int() <= 255)
}

///|
test "tone_map_drago: 基本测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 128, 255, 64, 192, 32, 224, 96, 160]),
  }
  let result = @cv_advanced.tone_map_drago(img, 0.0, 0.85)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
}

///|
test "tone_map_gamma: 基本测试" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([0, 128, 192, 255]),
  }
  let result = @cv_advanced.tone_map_gamma(img, 0.0, 2.2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "tone_map_gamma: gamma=1 零曝光为恒等" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 128]),
  }
  let result = @cv_advanced.tone_map_gamma(img, 0.0, 1.0)
  // gamma=1, exposure=0 时应近似恒等
  assert_eq(result.data[0], (0 : Byte))
  assert_true((result.data[1].to_int() - 128).abs() <= 1)
}

///|
test "tone_map_logarithmic: 基本测试" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([0, 128, 192, 255]),
  }
  let result = @cv_advanced.tone_map_logarithmic(img, 0.0)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "tone_map_local_laplacian: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.tone_map_local_laplacian(img, 0.0, 0.3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "tone_map_bilateral: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
    ]),
  }
  let result = @cv_advanced.tone_map_bilateral(img, 0.0, 0.5)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "tone_mapping_pipeline: 各方法" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 64, 128, 192, 255, 32, 96, 160, 224]),
  }
  for
    m in [
      @cv_advanced.Reinhard,
      @cv_advanced.Drago,
      @cv_advanced.Gamma,
      @cv_advanced.Logarithmic,
      @cv_advanced.LocalLaplacian,
      @cv_advanced.Bilateral,
    ] {
    let params = @cv_advanced.default_tone_mapping_params(m)
    let result = @cv_advanced.tone_mapping_pipeline(img, params)
    assert_eq(result.width, 3)
    assert_eq(result.height, 3)
    assert_eq(result.channels, 1)
  }
}

///|
test "default_tone_mapping_params: 默认值" {
  let p = @cv_advanced.default_tone_mapping_params(@cv_advanced.Reinhard)
  assert_eq(p.exposure, 0.0)
  assert_eq(p.gamma, 2.2)
  assert_eq(p.white_point, 1.0)
  assert_eq(p.saturation, 1.0)
  assert_true(p.tm_method is @cv_advanced.Reinhard)
}

///|
test "estimate_dynamic_range: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0, 85, 170, 255]),
  }
  let (min_v, max_v, range) = @cv_advanced.estimate_dynamic_range(img)
  assert_eq(min_v, 0.0)
  assert_eq(max_v, 1.0)
  assert_eq(range, 1.0)
}

///|
test "estimate_dynamic_range: 常数图像" {
  let img : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128, 128, 128]),
  }
  let (min_v, max_v, range) = @cv_advanced.estimate_dynamic_range(img)
  let v = 128.0 / 255.0
  assert_true((min_v - v).abs() < 0.001)
  assert_true((max_v - v).abs() < 0.001)
  assert_true(range < 0.001)
}
