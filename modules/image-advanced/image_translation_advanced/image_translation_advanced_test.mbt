// v39.0.0 图像翻译高级测试 — image_translation_advanced 模块 7 函数

///|
test "create_default_translation_config: 默认翻译配置" {
  let config = @image_translation_advanced.create_default_translation_config()
  assert_true(config.translation_strength >= 0.0)
  assert_true(config.content_weight >= 0.0)
  assert_true(config.style_weight >= 0.0)
  assert_true(config.num_iterations > 0)
  assert_true(config.learning_rate > 0.0)
}

///|
test "translate_image: 图像翻译" {
  let config = @image_translation_advanced.create_default_translation_config()
  let image = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = @image_translation_advanced.translate_image(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.translation_strength >= 0.0)
  assert_true(result.content_preservation >= 0.0)
  assert_true(result.num_iterations > 0)
  assert_true(result.translation_time_ms >= 0.0)
  assert_true(result.translated_image.length() > 0)
}

///|
test "advanced_style_transfer: 高级风格迁移" {
  let config = @image_translation_advanced.create_default_translation_config()
  let content = [0.2, 0.4, 0.6, 0.8]
  let style = [0.9, 0.7, 0.5, 0.3]
  let result = @image_translation_advanced.advanced_style_transfer(
    content, style, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_iterations > 0)
  assert_true(result.transfer_time_ms >= 0.0)
  assert_true(result.stylized_image.length() > 0)
}

///|
test "transfer_season: 季节迁移" {
  let config = @image_translation_advanced.create_default_translation_config()
  let image = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = @image_translation_advanced.transfer_season(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.translation_strength >= 0.0)
  assert_true(result.content_preservation >= 0.0)
  assert_true(result.translation_time_ms >= 0.0)
  assert_true(result.translated_image.length() > 0)
}

///|
test "transfer_weather: 天气迁移" {
  let config = @image_translation_advanced.create_default_translation_config()
  let image = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = @image_translation_advanced.transfer_weather(image, 2, 3, config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.translation_strength >= 0.0)
  assert_true(result.content_preservation >= 0.0)
  assert_true(result.translation_time_ms >= 0.0)
  assert_true(result.translated_image.length() > 0)
}

///|
test "transfer_day_night: 昼夜迁移" {
  let config = @image_translation_advanced.create_default_translation_config()
  let image = [0.3, 0.5, 0.7, 0.9, 0.2, 0.4]
  let result = @image_translation_advanced.transfer_day_night(
    image, 2, 3, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.translation_strength >= 0.0)
  assert_true(result.content_preservation >= 0.0)
  assert_true(result.translation_time_ms >= 0.0)
  assert_true(result.translated_image.length() > 0)
}

///|
test "image_translation_report_to_string: 报告生成" {
  let config = @image_translation_advanced.create_default_translation_config()
  let report = @image_translation_advanced.image_translation_report_to_string(
    @image_translation_advanced.ImageTranslationTaskType::StyleTransfer,
    config,
    "翻译完成",
  )
  assert_true(report.length() > 0)
}
