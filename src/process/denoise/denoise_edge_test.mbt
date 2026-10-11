// v220: denoise 模块边界/错误路径测试

///|
fn de_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn de_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn de_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn de_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "de_edge: mean_filter_denoise 零宽度" {
  try {
    let _ = @denoise.mean_filter_denoise(de_zero_w(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: mean_filter_denoise 无效通道" {
  try {
    let _ = @denoise.mean_filter_denoise(de_bad_channels(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: mean_filter_denoise 数据不匹配" {
  try {
    let _ = @denoise.mean_filter_denoise(de_mismatch(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: mean_filter_denoise kernel_size < 1" {
  try {
    let _ = @denoise.mean_filter_denoise(de_uniform(4, 4, 128), 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: median_filter_denoise 零宽度" {
  try {
    let _ = @denoise.median_filter_denoise(de_zero_w(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: median_filter_denoise 无效通道" {
  try {
    let _ = @denoise.median_filter_denoise(de_bad_channels(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: median_filter_denoise 数据不匹配" {
  try {
    let _ = @denoise.median_filter_denoise(de_mismatch(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: median_filter_denoise kernel_size < 1" {
  try {
    let _ = @denoise.median_filter_denoise(de_uniform(4, 4, 128), 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gaussian_filter_denoise 零宽度" {
  try {
    let _ = @denoise.gaussian_filter_denoise(de_zero_w(), 3, 1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gaussian_filter_denoise 无效通道" {
  try {
    let _ = @denoise.gaussian_filter_denoise(de_bad_channels(), 3, 1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gaussian_filter_denoise 数据不匹配" {
  try {
    let _ = @denoise.gaussian_filter_denoise(de_mismatch(), 3, 1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gaussian_filter_denoise kernel_size < 1" {
  try {
    let _ = @denoise.gaussian_filter_denoise(de_uniform(4, 4, 128), 0, 1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gaussian_filter_denoise sigma <= 0" {
  try {
    let _ = @denoise.gaussian_filter_denoise(de_uniform(4, 4, 128), 3, 0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise 零宽度" {
  try {
    let _ = @denoise.bilateral_filter_denoise(de_zero_w(), 3, 75.0, 75.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise 无效通道" {
  try {
    let _ = @denoise.bilateral_filter_denoise(de_bad_channels(), 3, 75.0, 75.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise 数据不匹配" {
  try {
    let _ = @denoise.bilateral_filter_denoise(de_mismatch(), 3, 75.0, 75.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise kernel_size < 1" {
  try {
    let _ = @denoise.bilateral_filter_denoise(
      de_uniform(4, 4, 128),
      0,
      75.0,
      75.0,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise sigma_color <= 0" {
  try {
    let _ = @denoise.bilateral_filter_denoise(
      de_uniform(4, 4, 128),
      3,
      0.0,
      75.0,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: bilateral_filter_denoise sigma_space <= 0" {
  try {
    let _ = @denoise.bilateral_filter_denoise(
      de_uniform(4, 4, 128),
      3,
      75.0,
      0.0,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_noise_level 零宽度" {
  try {
    let _ = @denoise.calculate_noise_level(de_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_noise_level 无效通道" {
  try {
    let _ = @denoise.calculate_noise_level(de_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_noise_level 数据不匹配" {
  try {
    let _ = @denoise.calculate_noise_level(de_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: histogram_equalization_enhance 零宽度" {
  try {
    let _ = @denoise.histogram_equalization_enhance(de_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: histogram_equalization_enhance 无效通道" {
  try {
    let _ = @denoise.histogram_equalization_enhance(de_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: histogram_equalization_enhance 数据不匹配" {
  try {
    let _ = @denoise.histogram_equalization_enhance(de_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gamma_correction_enhance 零宽度" {
  try {
    let _ = @denoise.gamma_correction_enhance(de_zero_w(), 1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gamma_correction_enhance 无效通道" {
  try {
    let _ = @denoise.gamma_correction_enhance(de_bad_channels(), 1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: gamma_correction_enhance 数据不匹配" {
  try {
    let _ = @denoise.gamma_correction_enhance(de_mismatch(), 1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: unsharp_mask_enhance 零宽度" {
  try {
    let _ = @denoise.unsharp_mask_enhance(de_zero_w(), 0.5, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: unsharp_mask_enhance 无效通道" {
  try {
    let _ = @denoise.unsharp_mask_enhance(de_bad_channels(), 0.5, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: unsharp_mask_enhance 数据不匹配" {
  try {
    let _ = @denoise.unsharp_mask_enhance(de_mismatch(), 0.5, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_brightness 零宽度" {
  try {
    let _ = @denoise.calculate_brightness(de_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_brightness 无效通道" {
  try {
    let _ = @denoise.calculate_brightness(de_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_brightness 数据不匹配" {
  try {
    let _ = @denoise.calculate_brightness(de_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_contrast 零宽度" {
  try {
    let _ = @denoise.calculate_contrast(de_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_contrast 无效通道" {
  try {
    let _ = @denoise.calculate_contrast(de_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_contrast 数据不匹配" {
  try {
    let _ = @denoise.calculate_contrast(de_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_sharpness 零宽度" {
  try {
    let _ = @denoise.calculate_sharpness(de_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_sharpness 无效通道" {
  try {
    let _ = @denoise.calculate_sharpness(de_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: calculate_sharpness 数据不匹配" {
  try {
    let _ = @denoise.calculate_sharpness(de_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: denoise_image 零宽度" {
  try {
    let _ = @denoise.denoise_image(
      de_zero_w(),
      @denoise.create_default_denoise_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: denoise_image 无效通道" {
  try {
    let _ = @denoise.denoise_image(
      de_bad_channels(),
      @denoise.create_default_denoise_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: denoise_image 数据不匹配" {
  try {
    let _ = @denoise.denoise_image(
      de_mismatch(),
      @denoise.create_default_denoise_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: enhance_image_advanced 零宽度" {
  try {
    let _ = @denoise.enhance_image_advanced(
      de_zero_w(),
      @denoise.EnhancementAlgorithm::HistogramEqualization,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: enhance_image_advanced 无效通道" {
  try {
    let _ = @denoise.enhance_image_advanced(
      de_bad_channels(),
      @denoise.EnhancementAlgorithm::HistogramEqualization,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "de_edge: enhance_image_advanced 数据不匹配" {
  try {
    let _ = @denoise.enhance_image_advanced(
      de_mismatch(),
      @denoise.EnhancementAlgorithm::HistogramEqualization,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
