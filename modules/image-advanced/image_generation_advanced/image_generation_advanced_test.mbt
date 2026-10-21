// v38.0.0 图像生成高级测试 — image_generation_advanced 模块 8 函数

///|
test "create_default_generation_config: 默认生成配置" {
  let config = @image_generation_advanced.create_default_generation_config()
  assert_true(config.width > 0)
  assert_true(config.height > 0)
  assert_true(config.num_inference_steps > 0)
  assert_true(config.guidance_scale > 0.0)
  assert_true(config.num_images > 0)
  assert_true(config.strength > 0.0)
  assert_true(config.beta_start > 0.0)
}

///|
test "generate_noise: 噪声生成" {
  let noise = @image_generation_advanced.generate_noise(4, 4, 3, 42)
  assert_true(noise.length() > 0)
}

///|
test "diffuse_sample: 扩散采样" {
  let latent = [0.1, 0.2, 0.3, 0.4]
  let result = @image_generation_advanced.diffuse_sample(latent, 10, 42)
  assert_true(result.length() > 0)
}

///|
test "text_to_image: 文生图" {
  let config = @image_generation_advanced.create_default_generation_config()
  let result = @image_generation_advanced.text_to_image(config)
  assert_true(result.num_images > 0)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_inference_steps > 0)
  assert_true(result.total_generation_time_ms > 0.0)
  assert_true(result.images.length() >= 0)
}

///|
test "image_to_image: 图生图" {
  let config = @image_generation_advanced.create_default_generation_config()
  let input = [0.5, 0.6, 0.7, 0.8]
  let result = @image_generation_advanced.image_to_image(input, config)
  assert_true(result.num_images > 0)
  assert_true(result.num_inference_steps > 0)
  assert_true(result.total_generation_time_ms > 0.0)
  assert_true(result.images.length() >= 0)
}

///|
test "inpaint_image: 图像修复" {
  let config = @image_generation_advanced.create_default_generation_config()
  let image = [0.5, 0.6, 0.7, 0.8]
  let mask = [true, false, true, false]
  let result = @image_generation_advanced.inpaint_image(
    image, mask, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_repaired_pixels >= 0)
  assert_true(result.repair_time_ms > 0.0)
  assert_true(result.repaired_image.length() > 0)
}

///|
test "transfer_style: 风格迁移" {
  let config = @image_generation_advanced.create_default_generation_config()
  let content = [0.1, 0.2, 0.3, 0.4]
  let style = [0.5, 0.6, 0.7, 0.8]
  let result = @image_generation_advanced.transfer_style(
    content, style, 2, 2, config,
  )
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_true(result.num_iterations > 0)
  assert_true(result.transfer_time_ms > 0.0)
  assert_true(result.stylized_image.length() > 0)
}

///|
test "image_generation_report_to_string: 报告生成" {
  let config = @image_generation_advanced.create_default_generation_config()
  let report = @image_generation_advanced.image_generation_report_to_string(
    @image_generation_advanced.ImageGenerationTaskType::TextToImage,
    config,
    "生成完成",
  )
  assert_true(report.length() > 0)
}
