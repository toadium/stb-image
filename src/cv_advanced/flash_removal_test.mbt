///|
test "FlashDetectionMethod: 枚举值" {
  assert_true(
    @cv_advanced.FlashDetectionMethod::Threshold is @cv_advanced.Threshold,
  )
  assert_true(
    @cv_advanced.FlashDetectionMethod::LocalPeak is @cv_advanced.LocalPeak,
  )
  assert_true(
    @cv_advanced.FlashDetectionMethod::Gradient is @cv_advanced.Gradient,
  )
  assert_true(
    @cv_advanced.FlashDetectionMethod::MultiFrame is @cv_advanced.MultiFrame,
  )
}

///|
test "FlashRemovalParams: 构造与字段" {
  let p : @cv_advanced.FlashRemovalParams = {
    detection_method: @cv_advanced.Threshold,
    threshold: 0.9,
    min_flash_size: 20,
    correction_strength: 0.7,
    dilation_radius: 3,
  }
  assert_eq(p.threshold, 0.9)
  assert_eq(p.min_flash_size, 20)
  assert_eq(p.correction_strength, 0.7)
  assert_eq(p.dilation_radius, 3)
  assert_true(p.detection_method is @cv_advanced.Threshold)
}

///|
test "detect_flash_threshold: 高亮像素检测" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 255, 100, 100, 255, 100, 100, 100, 100]),
  }
  let result = @cv_advanced.detect_flash_threshold(img, 0.85)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.flash_mask.length(), 9)
  // 255 的像素应被检测为闪光
  assert_true(result.flash_mask[1])
  assert_true(result.flash_mask[4])
  // 100 的像素不应被检测为闪光
  assert_true(!result.flash_mask[0])
  assert_true(result.flash_ratio > 0.0)
}

///|
test "detect_flash_threshold: 无闪光图像" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 120, 110, 130, 100, 120, 110, 130, 100]),
  }
  let result = @cv_advanced.detect_flash_threshold(img, 0.85)
  assert_eq(result.flash_ratio, 0.0)
  assert_eq(result.num_flash_regions, 0)
}

///|
test "detect_flash_local_peak: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 255, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50,
    ]),
  }
  let result = @cv_advanced.detect_flash_local_peak(img, 0.8, 1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "detect_flash_gradient: 基本测试" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      50, 50, 50, 50, 50, 255, 255, 50, 50, 255, 255, 50, 50, 50, 50, 50,
    ]),
  }
  let result = @cv_advanced.detect_flash_gradient(img, 0.5)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "detect_flash_multi_frame: 基本测试" {
  let img1 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100, 100]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 255, 100]),
  }
  let result = @cv_advanced.detect_flash_multi_frame([img1, img2], 0.5)
  assert_eq(result.width, 3)
  assert_eq(result.height, 1)
  // 像素1在img2中远高于img1 → 闪光
  assert_true(result.flash_mask[1])
}

///|
test "dilate_flash_mask: 膨胀测试" {
  let mask = [false, false, false, false, true, false, false, false, false]
  let dilated = @cv_advanced.dilate_flash_mask(mask, 3, 3, 1)
  assert_eq(dilated.length(), 9)
  // 中心 true 膨胀后邻居也变 true
  assert_true(dilated[4])
}

///|
test "correct_flash: 基本测试" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([100, 255, 100, 100, 255, 100, 100, 100, 100]),
  }
  let mask = [false, true, false, false, true, false, false, false, false]
  let result = @cv_advanced.correct_flash(img, mask, 1.0)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  // 非闪光像素不变
  assert_eq(result.data[0], (100 : Byte))
}

///|
test "remove_flash_multi_frame: 基本测试" {
  let img1 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 100, 100]),
  }
  let img2 : @types.Image = {
    width: 3,
    height: 1,
    channels: 1,
    data: Bytes::from_array([100, 255, 100]),
  }
  let params = @cv_advanced.default_flash_removal_params(
    @cv_advanced.MultiFrame,
  )
  let results = @cv_advanced.remove_flash_multi_frame([img1, img2], params)
  assert_eq(results.length(), 2)
  assert_eq(results[0].width, 3)
  assert_eq(results[1].width, 3)
}

///|
test "flash_removal_pipeline: 基本测试" {
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
      @cv_advanced.FlashDetectionMethod::Threshold,
      @cv_advanced.FlashDetectionMethod::LocalPeak,
      @cv_advanced.FlashDetectionMethod::Gradient,
      @cv_advanced.FlashDetectionMethod::MultiFrame,
    ] {
    let params = @cv_advanced.default_flash_removal_params(m)
    let result = @cv_advanced.flash_removal_pipeline(img, params)
    assert_eq(result.width, 4)
    assert_eq(result.height, 4)
    assert_eq(result.channels, 1)
  }
}

///|
test "default_flash_removal_params: 默认值" {
  let p = @cv_advanced.default_flash_removal_params(@cv_advanced.Threshold)
  assert_eq(p.threshold, 0.85)
  assert_eq(p.min_flash_size, 10)
  assert_eq(p.correction_strength, 0.8)
  assert_eq(p.dilation_radius, 2)
  assert_true(p.detection_method is @cv_advanced.Threshold)
}

///|
test "FlashDetectionResult: 构造与字段" {
  let r : @cv_advanced.FlashDetectionResult = {
    flash_mask: [true, false, true],
    flash_ratio: 0.667,
    num_flash_regions: 2,
    width: 3,
    height: 1,
  }
  assert_eq(r.flash_mask.length(), 3)
  assert_eq(r.num_flash_regions, 2)
  assert_eq(r.width, 3)
  assert_eq(r.height, 1)
}
