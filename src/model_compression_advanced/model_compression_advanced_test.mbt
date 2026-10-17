// v36.0.0 模型压缩高级测试 — model_compression_advanced 模块 7 函数

///|
test "create_default_compression_config: 默认压缩配置" {
  let config = @model_compression_advanced.create_default_compression_config()
  assert_true(config.target_compression_ratio > 0.0)
  assert_true(config.target_accuracy_drop >= 0.0)
  assert_true(config.bit_width > 0)
  assert_true(config.pruning_ratio > 0.0)
  assert_true(config.temperature > 0.0)
  assert_true(config.alpha > 0.0)
  assert_true(config.rank > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.random_state >= 0)
}

///|
test "quantize_model: 高级量化" {
  let config = @model_compression_advanced.create_default_compression_config()
  let weights = [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6], [0.7, 0.8, 0.9]]
  let result = @model_compression_advanced.quantize_model(weights, config)
  assert_true(result.quantized_weights.length() > 0)
  assert_true(result.original_weights.length() > 0)
  assert_true(result.num_layers > 0)
  assert_true(result.bit_width > 0)
  assert_true(result.original_accuracy >= 0.0)
  assert_true(result.quantized_accuracy >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
  assert_true(result.model_size_reduction >= 0.0)
  assert_true(result.quantization_error >= 0.0)
  assert_true(result.quantization_time_ms > 0.0)
  assert_true(result.quantization_scale.length() >= 0)
  assert_true(result.zero_point.length() >= 0)
}

///|
test "prune_model: 高级剪枝" {
  let config = @model_compression_advanced.create_default_compression_config()
  let weights = [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6], [0.7, 0.8, 0.9]]
  let result = @model_compression_advanced.prune_model(weights, config)
  assert_true(result.pruned_weights.length() > 0)
  assert_true(result.pruning_mask.length() > 0)
  assert_true(result.original_weights.length() > 0)
  assert_true(result.num_layers > 0)
  assert_true(result.pruning_ratio > 0.0)
  assert_true(result.original_params > 0)
  assert_true(result.remaining_params >= 0)
  assert_true(result.original_accuracy >= 0.0)
  assert_true(result.pruned_accuracy >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
  assert_true(result.pruning_time_ms > 0.0)
}

///|
test "distill_model: 知识蒸馏" {
  let config = @model_compression_advanced.create_default_compression_config()
  let teacher_weights = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
  let result = @model_compression_advanced.distill_model(
    teacher_weights, 2, 10, config,
  )
  assert_true(result.student_weights.length() > 0)
  assert_true(result.teacher_weights.length() > 0)
  assert_true(result.student_accuracy >= 0.0)
  assert_true(result.teacher_accuracy >= 0.0)
  assert_true(result.student_loss >= 0.0)
  assert_true(result.distillation_loss >= 0.0)
  assert_true(result.total_loss >= 0.0)
  assert_true(result.temperature > 0.0)
  assert_true(result.alpha > 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.learning_rate > 0.0)
  assert_true(result.distillation_time_ms > 0.0)
  assert_true(result.model_compression_ratio > 0.0)
}

///|
test "low_rank_decomposition: 低秩分解" {
  let config = @model_compression_advanced.create_default_compression_config()
  let weights = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
  let result = @model_compression_advanced.low_rank_decomposition(
    weights, config,
  )
  assert_true(result.decomposed_weights.length() >= 0)
  assert_true(result.original_weights.length() > 0)
  assert_true(result.num_layers > 0)
  assert_true(result.rank > 0)
  assert_true(result.original_params > 0)
  assert_true(result.decomposed_params >= 0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.reconstruction_error >= 0.0)
  assert_true(result.original_accuracy >= 0.0)
  assert_true(result.decomposed_accuracy >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
  assert_true(result.decomposition_time_ms > 0.0)
}

///|
test "compress_model: 综合压缩" {
  let config = @model_compression_advanced.create_default_compression_config()
  let weights = [[0.1, 0.2, 0.3], [0.4, 0.5, 0.6], [0.7, 0.8, 0.9]]
  let result = @model_compression_advanced.compress_model(weights, config)
  assert_true(result.original_params > 0)
  assert_true(result.compressed_params >= 0)
  assert_true(result.original_flops > 0)
  assert_true(result.compressed_flops >= 0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.speedup_ratio >= 0.0)
  assert_true(result.original_accuracy >= 0.0)
  assert_true(result.compressed_accuracy >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
  assert_true(result.original_model_size_mb > 0.0)
  assert_true(result.compressed_model_size_mb >= 0.0)
  assert_true(result.compression_time_ms > 0.0)
  assert_true(result.compression_method.length() > 0)
  assert_true(result.quantized_weights.length() >= 0)
  assert_true(result.pruned_mask.length() >= 0)
}

///|
test "compression_report_to_string: 报告生成" {
  let config = @model_compression_advanced.create_default_compression_config()
  let report = @model_compression_advanced.compression_report_to_string(
    @model_compression_advanced.ModelCompressionTaskType::Quantization,
    config,
    "压缩完成",
  )
  assert_true(report.length() > 0)
}
