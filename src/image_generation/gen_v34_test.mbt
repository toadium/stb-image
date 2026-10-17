// v34.0.0 图像生成与编辑测试 — image_generation 模块 13 函数

///|
fn create_solid_ig(w : Int, h : Int, v : Int) -> @types.Image {
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
fn create_gradient_ig(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) * 255 / (w + h) % 256).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn create_small_gen_config() -> @image_generation.GenerationConfig {
  @image_generation.GenerationConfig::{
    algorithm: @image_generation.ImageGenerationAlgorithm::StyleGAN,
    width: 16,
    height: 16,
    channels: 1,
    seed: 42,
    num_steps: 10,
    guidance_scale: 7.5,
    temperature: 1.0,
    use_pretrained: true,
  }
}

///|
test "create_default_generation_config: 默认配置" {
  let config = @image_generation.create_default_generation_config()
  assert_true(config.width > 0)
  assert_true(config.height > 0)
  assert_true(config.channels > 0)
  assert_true(config.num_steps > 0)
  assert_true(config.guidance_scale > 0.0)
  assert_true(config.use_pretrained)
}

///|
test "create_default_editing_config: 默认配置" {
  let config = @image_generation.create_default_editing_config()
  assert_true(config.strength > 0.0 && config.strength <= 1.0)
  assert_true(config.num_steps > 0)
  assert_true(config.guidance_scale > 0.0)
  assert_true(config.preserve_background)
  assert_true(config.edge_aware)
}

///|
test "generate_random_latent: 生成潜向量" {
  let latent = @image_generation.generate_random_latent(64, 42)
  assert_true(latent.dimension == 64)
  assert_true(latent.vector.length() == 64)
  assert_true(latent.norm > 0.0)
}

///|
test "generate_from_latent: 从潜向量生成图像" {
  let latent = @image_generation.generate_random_latent(64, 42)
  let config = create_small_gen_config()
  let result = @image_generation.generate_from_latent(latent, config)
  assert_true(result.image.width == 16)
  assert_true(result.image.height == 16)
  assert_true(result.seed == 42)
  assert_true(result.latent_vector.length() == 64)
}

///|
test "generate_random_image: 生成随机图像" {
  let config = create_small_gen_config()
  let result = @image_generation.generate_random_image(config)
  assert_true(result.image.width == 16)
  assert_true(result.image.height == 16)
  assert_true(result.quality_score >= 0.0 && result.quality_score <= 1.0)
  assert_true(result.diversity_score >= 0.0 && result.diversity_score <= 1.0)
}

///|
test "inpaint_image: 图像修复" {
  let img = create_gradient_ig(32, 32)
  let mask = create_solid_ig(32, 32, 0)
  let config = @image_generation.create_default_editing_config()
  let result = @image_generation.inpaint_image(img, mask, config)
  assert_true(result.image.width == 32)
  assert_true(result.image.height == 32)
  assert_true(result.quality_score >= 0.0)
}

///|
test "outpaint_image: 图像外扩" {
  let img = create_gradient_ig(16, 16)
  let config = @image_generation.create_default_editing_config()
  let result = @image_generation.outpaint_image(img, 32, 32, config)
  assert_true(result.image.width == 32)
  assert_true(result.image.height == 32)
}

///|
test "colorize_image: 图像上色" {
  let img = create_gradient_ig(32, 32)
  let config = @image_generation.create_default_editing_config()
  let result = @image_generation.colorize_image(img, config)
  assert_true(result.image.width == 32)
  assert_true(result.image.height == 32)
  assert_true(result.image.channels == 3)
}

///|
test "compose_images: 图像合成" {
  let bg = create_solid_ig(32, 32, 100)
  let fg = create_solid_ig(32, 32, 200)
  let mask = create_solid_ig(32, 32, 128)
  let config = @image_generation.CompositionConfig::{
    blend_mode: "normal",
    opacity: 0.5,
    feather_radius: 0,
    use_mask: true,
    color_match: false,
    perspective_correct: false,
  }
  let result = @image_generation.compose_images(bg, fg, mask, config)
  assert_true(result.width == 32)
  assert_true(result.height == 32)
}

///|
test "remove_background: 背景移除" {
  let img = create_gradient_ig(32, 32)
  let config = @image_generation.create_default_editing_config()
  let result = @image_generation.remove_background(img, config)
  assert_true(result.image.width == 32)
  assert_true(result.image.height == 32)
  assert_true(result.mask.width == 32)
  assert_true(result.mask.height == 32)
}

///|
test "edit_image: 编辑主入口-修复" {
  let img = create_gradient_ig(32, 32)
  let mask = create_solid_ig(32, 32, 0)
  let config = @image_generation.EditingConfig::{
    algorithm: @image_generation.ImageEditingAlgorithm::Inpainting,
    strength: 0.75,
    num_steps: 10,
    guidance_scale: 7.5,
    preserve_background: true,
    edge_aware: true,
    use_reference: false,
  }
  let result = @image_generation.edit_image(img, mask, config)
  assert_true(result.image.width == 32)
  assert_true(result.image.height == 32)
}

///|
test "edit_image: 编辑主入口-上色" {
  let img = create_gradient_ig(32, 32)
  let mask = create_solid_ig(32, 32, 0)
  let config = @image_generation.EditingConfig::{
    algorithm: @image_generation.ImageEditingAlgorithm::Colorization,
    strength: 0.75,
    num_steps: 10,
    guidance_scale: 7.5,
    preserve_background: true,
    edge_aware: true,
    use_reference: false,
  }
  let result = @image_generation.edit_image(img, mask, config)
  assert_true(result.image.channels == 3)
}

///|
test "generation_report_to_string: 报告非空" {
  let config = create_small_gen_config()
  let result = @image_generation.generate_random_image(config)
  let report = @image_generation.generation_report_to_string(result)
  assert_true(report.length() > 0)
}

///|
test "editing_report_to_string: 报告非空" {
  let img = create_gradient_ig(32, 32)
  let mask = create_solid_ig(32, 32, 0)
  let config = @image_generation.create_default_editing_config()
  let result = @image_generation.inpaint_image(img, mask, config)
  let report = @image_generation.editing_report_to_string(result)
  assert_true(report.length() > 0)
}
