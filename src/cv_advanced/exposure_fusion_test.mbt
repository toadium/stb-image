///|
test "ExposureFusionMethod: 枚举值" {
  assert_true(
    @cv_advanced.ExposureFusionMethod::Mertens is @cv_advanced.Mertens,
  )
  assert_true(
    @cv_advanced.ExposureFusionMethod::Multiband is @cv_advanced.Multiband,
  )
  assert_true(
    @cv_advanced.ExposureFusionMethod::WeightedAverage
    is @cv_advanced.WeightedAverage,
  )
  assert_true(
    @cv_advanced.ExposureFusionMethod::ContrastWeighted
    is @cv_advanced.ContrastWeighted,
  )
}

///|
test "ExposureFusionParams: 构造与字段" {
  let p : @cv_advanced.ExposureFusionParams = {
    ef_method: @cv_advanced.Mertens,
    contrast_weight: 1.5,
    saturation_weight: 0.8,
    exposure_weight: 1.0,
    pyramid_levels: 4,
  }
  assert_eq(p.contrast_weight, 1.5)
  assert_eq(p.saturation_weight, 0.8)
  assert_eq(p.exposure_weight, 1.0)
  assert_eq(p.pyramid_levels, 4)
  assert_true(p.ef_method is @cv_advanced.Mertens)
}

///|
test "compute_mertens_weights: 基本测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 128, 255, 64, 192, 32, 224, 96, 160]),
  }
  let params = @cv_advanced.default_exposure_fusion_params(@cv_advanced.Mertens)
  let weights = @cv_advanced.compute_mertens_weights(img, params)
  assert_eq(weights.length(), 9)
  // 所有权重应为正
  for i in 0..<9 {
    assert_true(weights[i] > 0.0)
  }
}

///|
test "normalize_weights: 归一化后和为1" {
  let weight_maps = [[1.0, 2.0, 3.0], [3.0, 2.0, 1.0]]
  let normalized = @cv_advanced.normalize_weights(weight_maps, 3)
  assert_eq(normalized.length(), 2)
  // 每个像素的权重和应为 1.0
  for i in 0..<3 {
    let sum = normalized[0][i] + normalized[1][i]
    assert_true((sum - 1.0).abs() < 0.001)
  }
}

///|
test "exposure_fusion_mertens: 单图像返回原图" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([100, 150, 200, 50]),
  }
  let params = @cv_advanced.default_exposure_fusion_params(@cv_advanced.Mertens)
  let result = @cv_advanced.exposure_fusion_mertens([img], params)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  for i in 0..<4 {
    assert_eq(result.data[i], img.data[i])
  }
}

///|
test "exposure_fusion_mertens: 多图像融合" {
  let img1 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 64, 128, 32, 96, 160, 48, 112, 176]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([128, 192, 255, 160, 224, 240, 176, 208, 232]),
  }
  let params = @cv_advanced.default_exposure_fusion_params(@cv_advanced.Mertens)
  let result = @cv_advanced.exposure_fusion_mertens([img1, img2], params)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.channels, 1)
}

///|
test "exposure_fusion_weighted_average: 基本测试" {
  let img1 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let img2 : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([50, 150]),
  }
  let result = @cv_advanced.exposure_fusion_weighted_average([img1, img2], [
    1.0, 1.0,
  ])
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
  // 均值融合：(100+50)/2=75, (200+150)/2=175
  assert_eq(result.data[0], (75 : Byte))
  assert_eq(result.data[1], (175 : Byte))
}

///|
test "exposure_fusion_contrast_weighted: 基本测试" {
  let img1 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 64, 128, 32, 96, 160, 48, 112, 176]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([128, 192, 255, 160, 224, 240, 176, 208, 232]),
  }
  let result = @cv_advanced.exposure_fusion_contrast_weighted([img1, img2])
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
}

///|
test "exposure_fusion_multiband: 基本测试" {
  let img1 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 64, 128, 32, 96, 160, 48, 112, 176]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([128, 192, 255, 160, 224, 240, 176, 208, 232]),
  }
  let params = @cv_advanced.default_exposure_fusion_params(
    @cv_advanced.Multiband,
  )
  let result = @cv_advanced.exposure_fusion_multiband([img1, img2], params)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
}

///|
test "exposure_fusion_pipeline: 各方法" {
  let img1 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([0, 64, 128, 32, 96, 160, 48, 112, 176]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([128, 192, 255, 160, 224, 240, 176, 208, 232]),
  }
  for
    m in [
      @cv_advanced.ExposureFusionMethod::Mertens,
      @cv_advanced.ExposureFusionMethod::Multiband,
      @cv_advanced.ExposureFusionMethod::WeightedAverage,
      @cv_advanced.ExposureFusionMethod::ContrastWeighted,
    ] {
    let params = @cv_advanced.default_exposure_fusion_params(m)
    let result = @cv_advanced.exposure_fusion_pipeline([img1, img2], params)
    assert_eq(result.width, 3)
    assert_eq(result.height, 3)
    assert_eq(result.channels, 1)
  }
}

///|
test "default_exposure_fusion_params: 默认值" {
  let p = @cv_advanced.default_exposure_fusion_params(@cv_advanced.Mertens)
  assert_eq(p.contrast_weight, 1.0)
  assert_eq(p.saturation_weight, 1.0)
  assert_eq(p.exposure_weight, 1.0)
  assert_eq(p.pyramid_levels, 3)
  assert_true(p.ef_method is @cv_advanced.Mertens)
}
