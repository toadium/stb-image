// v39.0.0 图像编辑高级测试 — image_editing_advanced 模块 6 函数

///|
test "create_default_editing_config: 默认编辑配置" {
  let config = @image_editing_advanced.create_default_editing_config()
  assert_true(config.edge_feathering >= 0.0)
  assert_true(config.beauty_strength >= 0.0)
  assert_true(config.skin_smoothing >= 0.0)
  assert_true(config.target_age >= 0)
  assert_true(config.expression_strength >= 0.0)
}

///|
test "smart_cutout: 智能抠图" {
  let config = @image_editing_advanced.create_default_editing_config()
  let image = [0.5, 0.6, 0.7, 0.8, 0.9, 0.4]
  let result = @image_editing_advanced.smart_cutout(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.foreground_pixels >= 0)
  assert_true(result.background_pixels >= 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.foreground.length() > 0)
  assert_true(result.alpha_mask.length() > 0)
}

///|
test "remove_objects: 物体移除" {
  let config = @image_editing_advanced.create_default_editing_config()
  let image = [0.5, 0.6, 0.7, 0.8]
  let mask = [true, false, true, false]
  let result = @image_editing_advanced.remove_objects(image, mask, 2, 2, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_removed_objects >= 0)
  assert_true(result.num_repaired_pixels >= 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.repaired_image.length() > 0)
}

///|
test "replace_background: 背景替换" {
  let config = @image_editing_advanced.create_default_editing_config()
  let subject = [0.5, 0.6, 0.7, 0.8]
  let bg_old = [0.1, 0.1, 0.1, 0.1]
  let bg_new = [0.9, 0.9, 0.9, 0.9]
  let result = @image_editing_advanced.replace_background(
    subject, bg_old, bg_new, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.composited_image.length() > 0)
}

///|
test "beauty_retouch: 美颜修图" {
  let config = @image_editing_advanced.create_default_editing_config()
  let image = [0.5, 0.6, 0.7, 0.8, 0.9, 0.4]
  let result = @image_editing_advanced.beauty_retouch(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.skin_smoothness >= 0.0)
  assert_true(result.processing_time_ms >= 0.0)
  assert_true(result.retouched_image.length() > 0)
}

///|
test "image_editing_report_to_string: 报告生成" {
  let config = @image_editing_advanced.create_default_editing_config()
  let report = @image_editing_advanced.image_editing_report_to_string(
    @image_editing_advanced.ImageEditingTaskType::SmartCutout,
    config,
    "编辑完成",
  )
  assert_true(report.length() > 0)
}
