// v39.0.0 图像修复高级测试 — image_restoration_advanced 模块 7 函数

///|
test "create_default_restoration_config: 默认修复配置" {
  let config = create_default_restoration_config()
  assert_true(config.noise_level >= 0.0)
  assert_true(config.kernel_size > 0)
  assert_true(config.scale_factor > 0.0)
}

///|
test "denoise_image: 图像去噪" {
  let config = create_default_restoration_config()
  let noisy = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2]
  let result = denoise_image(noisy, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.psnr >= 0.0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.denoised_image.length() > 0)
}

///|
test "deblur_image: 图像去模糊" {
  let config = create_default_restoration_config()
  let blurry = [0.2, 0.4, 0.6, 0.8, 0.3, 0.5]
  let result = deblur_image(blurry, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.kernel_size > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.deblurred_image.length() > 0)
}

///|
test "dehaze_image: 图像去雾" {
  let config = create_default_restoration_config()
  let hazy = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = dehaze_image(hazy, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.haze_density >= 0.0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.dehazed_image.length() > 0)
}

///|
test "super_resolution: 超分辨率" {
  let config = create_default_restoration_config()
  let low_res = [0.2, 0.4, 0.6, 0.8]
  let result = super_resolution(low_res, 2, 2, config)
  assert_true(result.original_width > 0)
  assert_true(result.original_height > 0)
  assert_true(result.sr_width >= result.original_width)
  assert_true(result.sr_height >= result.original_height)
  assert_true(result.scale_factor > 0.0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.sr_image.length() > 0)
}

///|
test "restore_old_photo: 老照片修复" {
  let config = create_default_restoration_config()
  let old_photo = [0.2, 0.4, 0.6, 0.8, 0.3, 0.5]
  let result = restore_old_photo(old_photo, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.restored_image.length() > 0)
}

///|
test "image_restoration_report_to_string: 报告生成" {
  let config = create_default_restoration_config()
  let report = image_restoration_report_to_string(
    ImageRestorationTaskType::Denoising,
    config,
    "修复完成",
  )
  assert_true(report.length() > 0)
}
