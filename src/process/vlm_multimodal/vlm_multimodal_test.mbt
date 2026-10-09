///|
test "create_default_vlm_config: returns CLIP config" {
  let config = @vlm_multimodal.create_default_vlm_config()
  assert_eq(config.image_encoder_size, 768)
  assert_eq(config.text_encoder_size, 768)
  assert_eq(config.projection_dim, 512)
  assert_true(config.use_contrastive_loss)
  assert_true(config.use_matching_loss)
  assert_false(config.use_captioning_loss)
  assert_true(
    config.model_type is @vlm_multimodal.VisionLanguageModelType::CLIP,
  )
}

///|
test "create_default_fusion_config: returns cross attention config" {
  let config = @vlm_multimodal.create_default_fusion_config()
  assert_eq(config.num_modalities, 2)
  assert_eq(config.hidden_dim, 768)
  assert_eq(config.num_attention_heads, 12)
  assert_eq(config.num_layers, 6)
  assert_true(config.use_gating)
  assert_true(
    config.strategy is @vlm_multimodal.MultimodalFusionStrategy::CrossAttention,
  )
}

///|
test "create_default_diffusion_config: returns stable diffusion config" {
  let config = @vlm_multimodal.create_default_diffusion_config()
  assert_eq(config.num_timesteps, 1000)
  assert_eq(config.num_inference_steps, 50)
  assert_eq(config.image_size, 512)
  assert_true(config.use_ddim)
  assert_false(config.use_clip_guidance)
  assert_true(
    config.model_type is @vlm_multimodal.DiffusionModelType::StableDiffusion,
  )
  assert_eq(config.beta_schedule, "scaled_linear")
}

///|
test "create_default_genai_config: returns text to image config" {
  let config = @vlm_multimodal.create_default_genai_config()
  assert_eq(config.max_length, 77)
  assert_eq(config.num_beams, 1)
  assert_eq(config.top_k, 50)
  assert_true(
    config.task_type is @vlm_multimodal.GenerativeAITaskType::TextToImage,
  )
  assert_eq(config.vlm_config.projection_dim, 512)
  assert_eq(config.diffusion_config.image_size, 512)
  assert_eq(config.fusion_config.hidden_dim, 768)
}

///|
test "compute_image_text_similarity: returns embeddings" {
  let img_data : Array[Byte] = []
  for i in 0..<64 {
    img_data.push((i * 4).to_byte())
  }
  let image = @types.Image::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(img_data),
  }
  let config = @vlm_multimodal.create_default_vlm_config()
  let result = @vlm_multimodal.compute_image_text_similarity(
    image, "a cat sitting on a mat", config,
  )
  assert_eq(result.projection_dim, 512)
  assert_eq(result.image_embedding.length(), 512)
  assert_eq(result.text_embedding.length(), 512)
  assert_true(result.similarity >= -1.0 && result.similarity <= 1.0)
}

///|
test "fuse_modalities: cross attention fusion" {
  let img_features = [1.0, 2.0, 3.0, 4.0]
  let txt_features = [0.5, 1.0, 1.5, 2.0]
  let config = @vlm_multimodal.create_default_fusion_config()
  let result = @vlm_multimodal.fuse_modalities(
    img_features, txt_features, config,
  )
  assert_eq(result.fused_representation.length(), 4)
  assert_eq(result.modality_weights.length(), 4)
  assert_eq(result.hidden_dim, 4)
  assert_true(
    result.fusion_strategy
    is @vlm_multimodal.MultimodalFusionStrategy::CrossAttention,
  )
}

///|
test "fuse_modalities: tensor fusion multiplies features" {
  let img_features = [2.0, 3.0]
  let txt_features = [4.0, 5.0]
  let config = @vlm_multimodal.FusionConfig::{
    strategy: @vlm_multimodal.MultimodalFusionStrategy::TensorFusion,
    num_modalities: 2,
    hidden_dim: 4,
    num_attention_heads: 4,
    num_layers: 2,
    dropout_rate: 0.1,
    use_gating: false,
  }
  let result = @vlm_multimodal.fuse_modalities(
    img_features, txt_features, config,
  )
  assert_true((result.fused_representation[0] - 8.0).abs() < 0.0000000001)
  assert_true((result.fused_representation[1] - 15.0).abs() < 0.0000000001)
}

///|
test "fuse_modalities: different length features" {
  let img_features = [1.0, 2.0, 3.0]
  let txt_features = [1.0]
  let config = @vlm_multimodal.create_default_fusion_config()
  let result = @vlm_multimodal.fuse_modalities(
    img_features, txt_features, config,
  )
  assert_eq(result.fused_representation.length(), 3)
  assert_eq(result.hidden_dim, 3)
}

///|
test "diffusion_generate: produces image with correct size" {
  let config = @vlm_multimodal.DiffusionConfig::{
    model_type: @vlm_multimodal.DiffusionModelType::StableDiffusion,
    num_timesteps: 100,
    beta_start: 0.00085,
    beta_end: 0.012,
    beta_schedule: "scaled_linear",
    guidance_scale: 7.5,
    num_inference_steps: 10,
    image_size: 8,
    use_ddim: true,
    use_clip_guidance: false,
  }
  let result = @vlm_multimodal.diffusion_generate(
    "a red circle", "", config, 42,
  )
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
  assert_eq(result.image.channels, 3)
  assert_eq(result.num_steps, 10)
  assert_eq(result.prompt, "a red circle")
  assert_eq(result.seed, 42)
}

///|
test "text_to_image: generates image from prompt" {
  let config = @vlm_multimodal.create_default_genai_config()
  let result = @vlm_multimodal.text_to_image(
    "a beautiful landscape", config, 123,
  )
  assert_true(
    result.task_type is @vlm_multimodal.GenerativeAITaskType::TextToImage,
  )
  assert_eq(result.text, "a beautiful landscape")
  assert_eq(result.image.width, 512)
  assert_eq(result.image.height, 512)
  assert_eq(result.num_iterations, 50)
  assert_true((result.confidence - 0.7).abs() < 0.0000000001)
}

///|
test "image_to_text: generates caption from image" {
  let img_data : Array[Byte] = []
  let bright_val : Byte = 200
  for _ in 0..<64 {
    img_data.push(bright_val)
  }
  let image = @types.Image::{
    width: 8,
    height: 8,
    channels: 1,
    data: Bytes::from_array(img_data),
  }
  let config = @vlm_multimodal.create_default_genai_config()
  let result = @vlm_multimodal.image_to_text(image, config)
  assert_true(result.text.contains("bright"))
  assert_true(result.text.contains("8x8"))
  assert_eq(result.num_iterations, 1)
}

///|
test "image_to_text: dark image caption" {
  let img_data : Array[Byte] = []
  let dark_val : Byte = 20
  for _ in 0..<16 {
    img_data.push(dark_val)
  }
  let image = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(img_data),
  }
  let config = @vlm_multimodal.create_default_genai_config()
  let result = @vlm_multimodal.image_to_text(image, config)
  assert_true(result.text.contains("dark"))
}

///|
test "vlm_report_to_string: contains model info" {
  let embedding = @vlm_multimodal.VisionTextEmbedding::{
    image_embedding: [1.0, 2.0],
    text_embedding: [0.5, 1.0],
    similarity: 0.85,
    projection_dim: 512,
  }
  let report = @vlm_multimodal.vlm_report_to_string(
    embedding,
    @vlm_multimodal.VisionLanguageModelType::CLIP,
  )
  assert_true(report.contains("视觉语言模型报告"))
  assert_true(report.contains("CLIP"))
  assert_true(report.contains("512"))
}

///|
test "vlm_report_to_string: LLaVA model" {
  let embedding = @vlm_multimodal.VisionTextEmbedding::{
    image_embedding: [],
    text_embedding: [],
    similarity: 0.0,
    projection_dim: 768,
  }
  let report = @vlm_multimodal.vlm_report_to_string(
    embedding,
    @vlm_multimodal.VisionLanguageModelType::LLaVA,
  )
  assert_true(report.contains("LLaVA"))
  assert_true(report.contains("768"))
}

///|
test "fusion_report_to_string: contains fusion info" {
  let result = @vlm_multimodal.FusionResult::{
    fused_representation: [1.0, 2.0, 3.0],
    modality_weights: [0.5, 0.5, 0.5],
    fusion_strategy: @vlm_multimodal.MultimodalFusionStrategy::CrossAttention,
    hidden_dim: 3,
  }
  let report = @vlm_multimodal.fusion_report_to_string(result)
  assert_true(report.contains("多模态融合报告"))
  assert_true(report.contains("交叉注意力"))
  assert_true(report.contains("3"))
}
