// v39.0.0 图像上色高级测试 — image_colorization_advanced 模块 7 函数

///|
test "create_default_colorization_config: 默认上色配置" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  assert_true(config.colorization_strength >= 0.0)
  assert_true(config.saturation_boost >= 0.0)
  assert_true(config.contrast_boost >= 0.0)
}

///|
test "automatic_colorization: 自动上色" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let gray = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2]
  let result = @image_colorization_advanced.automatic_colorization(
    gray, 2, 3, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_colors >= 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.colorized_image.length() > 0)
}

///|
test "reference_based_colorization: 参考图上色" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let gray = [0.1, 0.3, 0.5, 0.7]
  let ref_colors = [0.9, 0.8, 0.7, 0.6]
  let result = @image_colorization_advanced.reference_based_colorization(
    gray, ref_colors, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.matched_regions >= 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.colorized_image.length() > 0)
}

///|
test "old_photo_colorization: 老照片上色" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let old_photo = [0.2, 0.4, 0.6, 0.8, 0.3, 0.5]
  let result = @image_colorization_advanced.old_photo_colorization(
    old_photo, 2, 3, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.colorized_image.length() > 0)
}

///|
test "enhance_colors: 色彩增强" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let image = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = @image_colorization_advanced.enhance_colors(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.enhanced_image.length() > 0)
}

///|
test "transfer_colors: 色彩迁移" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let source = [0.2, 0.4, 0.6, 0.8]
  let reference = [0.9, 0.7, 0.5, 0.3]
  let result = @image_colorization_advanced.transfer_colors(
    source, reference, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.transferred_image.length() > 0)
}

///|
test "image_colorization_report_to_string: 报告生成" {
  let config = @image_colorization_advanced.create_default_colorization_config()
  let report = @image_colorization_advanced.image_colorization_report_to_string(
    @image_colorization_advanced.ColorizationTaskType::AutomaticColorization,
    config,
    "上色完成",
  )
  assert_true(report.length() > 0)
}
