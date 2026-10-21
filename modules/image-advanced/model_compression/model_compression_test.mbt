// v36.0.0 模型压缩测试 — model_compression 模块 13 函数

///|
test "create_default_quantization_config: 默认量化配置" {
  let config = @model_compression.create_default_quantization_config()
  assert_true(config.num_bits > 0)
  assert_true(config.calibration_samples >= 0)
}

///|
test "create_default_pruning_config: 默认剪枝配置" {
  let config = @model_compression.create_default_pruning_config()
  assert_true(config.pruning_ratio > 0.0)
  assert_true(config.threshold >= 0.0)
  assert_true(config.num_iterations > 0)
  assert_true(config.fine_tune_epochs >= 0)
}

///|
test "create_default_distillation_config: 默认蒸馏配置" {
  let config = @model_compression.create_default_distillation_config()
  assert_true(config.temperature > 0.0)
  assert_true(config.alpha > 0.0)
  assert_true(config.beta > 0.0)
  assert_true(config.teacher_layers.length() >= 0)
  assert_true(config.student_layers.length() >= 0)
}

///|
test "create_default_lowrank_config: 默认低秩配置" {
  let config = @model_compression.create_default_lowrank_config()
  assert_true(config.rank_ratio > 0.0)
  assert_true(config.min_rank > 0)
  assert_true(config.max_rank >= config.min_rank)
  assert_true(config.threshold >= 0.0)
}

///|
test "create_default_optimization_config: 默认优化配置" {
  let config = @model_compression.create_default_optimization_config()
  assert_true(config.optimization_level >= 0)
  assert_true(config.target_device.length() > 0)
}

///|
test "create_default_deployment_config: 默认部署配置" {
  let config = @model_compression.create_default_deployment_config()
  assert_true(config.batch_size > 0)
  assert_true(config.opset_version > 0)
  assert_true(config.input_shape.length() >= 0)
  assert_true(config.output_names.length() >= 0)
}

///|
test "quantize_model: 模型量化" {
  let config = @model_compression.create_default_quantization_config()
  let result = @model_compression.quantize_model(10.0, 1000000, 1000000, config)
  assert_true(result.original_size_mb > 0.0)
  assert_true(result.compressed_size_mb >= 0.0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.original_parameters > 0)
  assert_true(result.compressed_parameters >= 0)
  assert_true(result.parameter_reduction >= 0.0)
  assert_true(result.original_flops > 0)
  assert_true(result.compressed_flops >= 0)
  assert_true(result.flops_reduction >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
}

///|
test "prune_model: 模型剪枝" {
  let config = @model_compression.create_default_pruning_config()
  let result = @model_compression.prune_model(10.0, 1000000, 1000000, config)
  assert_true(result.original_size_mb > 0.0)
  assert_true(result.compressed_size_mb >= 0.0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.original_parameters > 0)
  assert_true(result.compressed_parameters >= 0)
  assert_true(result.parameter_reduction >= 0.0)
  assert_true(result.accuracy_drop >= 0.0)
}

///|
test "knowledge_distillation: 知识蒸馏" {
  let config = @model_compression.create_default_distillation_config()
  let result = @model_compression.knowledge_distillation(
    0.9, 0.95, 1000000, 100000, config,
  )
  assert_true(result.original_size_mb > 0.0)
  assert_true(result.compressed_size_mb >= 0.0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.original_parameters > 0)
  assert_true(result.compressed_parameters >= 0)
  assert_true(result.accuracy_drop >= 0.0)
}

///|
test "low_rank_factorization: 低秩分解" {
  let config = @model_compression.create_default_lowrank_config()
  let result = @model_compression.low_rank_factorization(
    10.0, 1000000, 100, config,
  )
  assert_true(result.original_size_mb > 0.0)
  assert_true(result.compressed_size_mb >= 0.0)
  assert_true(result.compression_ratio > 0.0)
  assert_true(result.original_parameters > 0)
  assert_true(result.compressed_parameters >= 0)
  assert_true(result.flops_reduction >= 0.0)
}

///|
test "optimize_model_inference: 推理优化" {
  let config = @model_compression.create_default_optimization_config()
  let (optimized_time, optimized_memory, speedup) = @model_compression.optimize_model_inference(
    100.0, 500.0, config,
  )
  assert_true(optimized_time >= 0.0)
  assert_true(optimized_memory >= 0.0)
  assert_true(speedup >= 0.0)
}

///|
test "deploy_model: 模型部署" {
  let config = @model_compression.create_default_deployment_config()
  let result = @model_compression.deploy_model(10.0, 100.0, config)
  assert_true(result.model_size_mb >= 0.0)
  assert_true(result.inference_time_ms >= 0.0)
  assert_true(result.memory_usage_mb >= 0.0)
  assert_true(result.throughput_fps >= 0.0)
}

///|
test "model_compression_report_to_string: 报告生成" {
  let config = @model_compression.create_default_quantization_config()
  let result = @model_compression.quantize_model(10.0, 1000000, 1000000, config)
  let report = @model_compression.model_compression_report_to_string(
    result, "量化完成",
  )
  assert_true(report.length() > 0)
}
