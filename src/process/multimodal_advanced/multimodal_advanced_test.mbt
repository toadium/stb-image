///|
test "create_default_multimodal_config: returns attention fusion config" {
  let config = create_default_multimodal_config()
  assert_eq(config.feature_dim, 512)
  assert_eq(config.hidden_dim, 768)
  assert_eq(config.num_attention_heads, 8)
  assert_eq(config.num_fusion_layers, 4)
  assert_eq(config.similarity_metric, "cosine")
  assert_true(config.use_cross_attention)
  assert_true(config.use_modality_specific_encoders)
  assert_false(config.use_shared_encoder)
  assert_true(config.fusion_strategy is FusionStrategy::AttentionFusion)
  assert_true(config.task_type is MultimodalTaskType::MultimodalFusion)
  assert_eq(config.modalities.length(), 2)
}

///|
test "create_multimodal_data: creates data with correct dimensions" {
  let data = create_multimodal_data("sample_001", 64, [
    ModalityType::Image,
    ModalityType::Text,
  ])
  assert_eq(data.sample_id, "sample_001")
  assert_eq(data.feature_dim, 64)
  assert_eq(data.num_modalities, 2)
  assert_eq(data.image_features.length(), 64)
  assert_eq(data.text_features.length(), 64)
  assert_eq(data.audio_features.length(), 64)
  assert_eq(data.video_features.length(), 64)
}

///|
test "create_multimodal_data: single modality" {
  let data = create_multimodal_data("s1", 8, [ModalityType::Audio])
  assert_eq(data.num_modalities, 1)
  assert_eq(data.feature_dim, 8)
  assert_eq(data.audio_features.length(), 8)
}

///|
test "cosine_similarity: identical vectors" {
  let v = [1.0, 2.0, 3.0]
  let sim = cosine_similarity(v, v)
  assert_true(sim > 0.0)
}

///|
test "cosine_similarity: orthogonal vectors" {
  let v1 = [1.0, 0.0]
  let v2 = [0.0, 1.0]
  let sim = cosine_similarity(v1, v2)
  assert_true(sim.abs() < 0.0000000001)
}

///|
test "cosine_similarity: different lengths" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [1.0, 2.0]
  let sim = cosine_similarity(v1, v2)
  assert_true(sim >= -1.0 && sim <= 1.0)
}

///|
test "cosine_similarity: empty vectors" {
  let sim = cosine_similarity([], [])
  assert_eq(sim, 0.0)
}

///|
test "fuse_multimodal: attention fusion produces correct dim" {
  let config = create_default_multimodal_config()
  let data = create_multimodal_data("fused_1", 32, config.modalities)
  let result = fuse_multimodal(data, config)
  assert_eq(result.feature_dim, 512)
  assert_eq(result.fused_features.length(), 512)
  assert_eq(result.num_modalities, 2)
  assert_eq(result.modality_weights.length(), 4)
  assert_true((result.confidence - 0.85).abs() < 0.0000000001)
  assert_true(result.fusion_strategy is FusionStrategy::AttentionFusion)
}

///|
test "fuse_multimodal: early fusion strategy" {
  let config = MultimodalConfig::{
    task_type: MultimodalTaskType::MultimodalFusion,
    fusion_strategy: FusionStrategy::EarlyFusion,
    modalities: [ModalityType::Image, ModalityType::Text],
    feature_dim: 16,
    hidden_dim: 32,
    num_attention_heads: 4,
    num_fusion_layers: 2,
    dropout_rate: 0.1,
    temperature: 0.07,
    similarity_metric: "cosine",
    use_cross_attention: false,
    use_modality_specific_encoders: false,
    use_shared_encoder: true,
  }
  let data = create_multimodal_data("ef_1", 16, config.modalities)
  let result = fuse_multimodal(data, config)
  assert_eq(result.feature_dim, 16)
  assert_eq(result.fused_features.length(), 16)
  assert_true(result.fusion_strategy is FusionStrategy::EarlyFusion)
}

///|
test "cross_modal_retrieval: retrieves from database" {
  let query = create_multimodal_data("query_1", 16, [ModalityType::Image])
  let db_item1 = create_multimodal_data("db_1", 16, [ModalityType::Text])
  let db_item2 = create_multimodal_data("db_2", 16, [ModalityType::Text])
  let db_item3 = create_multimodal_data("db_3", 16, [ModalityType::Text])
  let result = cross_modal_retrieval(
    query,
    [db_item1, db_item2, db_item3],
    ModalityType::Image,
    ModalityType::Text,
    2,
  )
  assert_eq(result.query_id, "query_1")
  assert_eq(result.num_retrieved, 2)
  assert_eq(result.retrieved_ids.length(), 2)
  assert_eq(result.retrieved_scores.length(), 2)
  assert_eq(result.similarity_metric, "cosine")
  assert_true(result.query_modality is ModalityType::Image)
  assert_true(result.target_modality is ModalityType::Text)
}

///|
test "cross_modal_retrieval: top_k exceeds database size" {
  let query = create_multimodal_data("q", 8, [ModalityType::Text])
  let item = create_multimodal_data("item", 8, [ModalityType::Image])
  let result = cross_modal_retrieval(
    query,
    [item],
    ModalityType::Text,
    ModalityType::Image,
    10,
  )
  assert_eq(result.num_retrieved, 1)
  assert_eq(result.retrieved_ids.length(), 1)
}

///|
test "cross_modal_retrieval: empty database" {
  let query = create_multimodal_data("q", 4, [ModalityType::Image])
  let result = cross_modal_retrieval(
    query,
    [],
    ModalityType::Image,
    ModalityType::Text,
    5,
  )
  assert_eq(result.num_retrieved, 0)
  assert_eq(result.retrieved_ids.length(), 0)
}

///|
test "multimodal_report_to_string: contains task and config info" {
  let config = create_default_multimodal_config()
  let report = multimodal_report_to_string(
    MultimodalTaskType::CrossModalRetrieval,
    config,
    "Retrieval accuracy: 85%",
  )
  assert_true(report.contains("多模态高级报告"))
  assert_true(report.contains("跨模态检索"))
  assert_true(report.contains("注意力融合"))
  assert_true(report.contains("Retrieval accuracy: 85%"))
  assert_true(report.contains("512"))
}

///|
test "multimodal_report_to_string: video understanding task" {
  let config = create_default_multimodal_config()
  let report = multimodal_report_to_string(
    MultimodalTaskType::VideoUnderstanding,
    config,
    "Detected 3 actions",
  )
  assert_true(report.contains("视频理解"))
  assert_true(report.contains("Detected 3 actions"))
}
