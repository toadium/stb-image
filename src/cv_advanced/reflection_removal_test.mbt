///|
test "ReflectionRemovalMethod: 枚举值" {
  assert_true(
    @cv_advanced.ReflectionRemovalMethod::Polarization
    is @cv_advanced.Polarization,
  )
  assert_true(
    @cv_advanced.ReflectionRemovalMethod::MultiFrame is @cv_advanced.MultiFrame,
  )
  assert_true(
    @cv_advanced.ReflectionRemovalMethod::DepthAware is @cv_advanced.DepthAware,
  )
  assert_true(
    @cv_advanced.ReflectionRemovalMethod::Gradient is @cv_advanced.Gradient,
  )
}

///|
test "ReflectionRemovalParams: 构造与字段" {
  let p : @cv_advanced.ReflectionRemovalParams = {
    rr_method: @cv_advanced.Polarization,
    threshold: 0.85,
    strength: 0.6,
    num_polarization_angles: 4,
    smoothing_radius: 3,
  }
  assert_eq(p.threshold, 0.85)
  assert_eq(p.strength, 0.6)
  assert_eq(p.num_polarization_angles, 4)
  assert_eq(p.smoothing_radius, 3)
  assert_true(p.rr_method is @cv_advanced.Polarization)
}

///|
test "detect_reflection: 高亮低饱和度检测" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 3,
    data: Bytes::from_array([
      100, 50, 50, 250, 248, 252, 100, 50, 50, 100, 50, 50, 255, 255, 255, 100, 50,
      50, 100, 50, 50, 100, 50, 50, 100, 50, 50,
    ]),
  }
  let result = @cv_advanced.detect_reflection(img, 0.8)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.reflection_mask.length(), 9)
  // 高亮白色像素应被检测为反射
  assert_true(result.reflection_mask[1])
  assert_true(result.reflection_mask[4])
  // 暗像素不应被检测为反射
  assert_true(!result.reflection_mask[0])
  assert_true(result.reflection_ratio > 0.0)
}

///|
test "detect_reflection: 无反射图像" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 3,
    data: Bytes::from_array([
      100, 50, 50, 80, 40, 40, 100, 50, 50, 80, 40, 40, 60, 30, 30, 80, 40, 40, 100,
      50, 50, 80, 40, 40, 100, 50, 50,
    ]),
  }
  let result = @cv_advanced.detect_reflection(img, 0.8)
  assert_eq(result.reflection_ratio, 0.0)
}

///|
test "remove_reflection_polarization: 基本测试" {
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
    data: Bytes::from_array([150, 180]),
  }
  let result = @cv_advanced.remove_reflection_polarization([img1, img2], 0.5)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
}

///|
test "remove_reflection_polarization: 单图像" {
  let img : @types.Image = {
    width: 2,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200]),
  }
  let result = @cv_advanced.remove_reflection_polarization([img], 0.5)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
}

///|
test "remove_reflection_multi_frame: 基本测试" {
  let img1 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 200, 100]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 150, 100]),
  }
  let img3 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 180, 100]),
  }
  let result = @cv_advanced.remove_reflection_multi_frame(
    [img1, img2, img3],
    0.5,
    0.7,
  )
  assert_eq(result.width, 3)
  assert_eq(result.height, 1)
}

///|
test "remove_reflection_depth_aware: 基本测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([50, 255, 50, 50, 255, 50, 50, 50, 50]),
  }
  let depth : @cv_advanced.DepthMap = {
    width: 3,
    height: 3,
    depths: [1.0, 5.0, 1.0, 2.0, 6.0, 2.0, 1.0, 1.0, 1.0],
    valid: [true, true, true, true, true, true, true, true, true],
  }
  let result = @cv_advanced.remove_reflection_depth_aware(img, depth, 0.8, 0.7)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
}

///|
test "remove_reflection_gradient: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 255, 255, 50, 50, 255, 255, 50, 50, 50, 50, 50,
    ]),
  }
  let result = @cv_advanced.remove_reflection_gradient(img, 0.8, 0.7)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "reflection_removal_pipeline: 各方法" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 255, 255, 50, 50, 255, 255, 50, 50, 50, 50, 50,
    ]),
  }
  for
    m in [
      @cv_advanced.ReflectionRemovalMethod::Polarization,
      @cv_advanced.ReflectionRemovalMethod::MultiFrame,
      @cv_advanced.ReflectionRemovalMethod::DepthAware,
      @cv_advanced.ReflectionRemovalMethod::Gradient,
    ] {
    let params = @cv_advanced.default_reflection_removal_params(m)
    let result = @cv_advanced.reflection_removal_pipeline(img, params)
    assert_eq(result.width, 4)
    assert_eq(result.height, 4)
    assert_eq(result.channels, 1)
  }
}

///|
test "default_reflection_removal_params: 默认值" {
  let p = @cv_advanced.default_reflection_removal_params(
    @cv_advanced.Polarization,
  )
  assert_eq(p.threshold, 0.8)
  assert_eq(p.strength, 0.7)
  assert_eq(p.num_polarization_angles, 4)
  assert_eq(p.smoothing_radius, 2)
  assert_true(p.rr_method is @cv_advanced.Polarization)
}

///|
test "ReflectionDetectionResult: 构造与字段" {
  let r : @cv_advanced.ReflectionDetectionResult = {
    reflection_mask: [true, false],
    reflection_ratio: 0.5,
    confidence: [0.9, 0.0],
    width: 2,
    height: 1,
  }
  assert_eq(r.reflection_mask.length(), 2)
  assert_eq(r.reflection_ratio, 0.5)
  assert_eq(r.confidence[0], 0.9)
  assert_eq(r.width, 2)
}
