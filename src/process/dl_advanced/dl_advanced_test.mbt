// v35.0.0 深度学习高级测试 — dl_advanced 模块 7 函数

///|
test "create_default_transformer_config: 默认Transformer配置" {
  let config = create_default_transformer_config()
  assert_true(config.num_layers > 0)
  assert_true(config.hidden_dim > 0)
  assert_true(config.num_heads > 0)
  assert_true(config.intermediate_dim > 0)
  assert_true(config.max_position_embeddings > 0)
  assert_true(config.vocab_size > 0)
  assert_true(config.use_layer_norm)
  assert_true(config.use_residual)
  assert_true(!config.use_gradient_checkpointing)
  assert_true(config.architecture == TransformerArchitecture::EncoderOnly)
  assert_true(config.attention_type == AttentionType::MultiHeadAttention)
}

///|
test "create_default_pretrained_config: 默认预训练模型配置" {
  let config = create_default_pretrained_config()
  assert_true(config.num_parameters > 0)
  assert_true(config.hidden_dim > 0)
  assert_true(config.num_layers > 0)
  assert_true(config.vocab_size > 0)
  assert_true(config.max_seq_length > 0)
  assert_true(config.pretraining_steps > 0)
  assert_true(config.batch_size > 0)
  assert_true(config.training_time_hours > 0.0)
}

///|
test "create_default_finetuning_config: 默认微调配置" {
  let config = create_default_finetuning_config()
  assert_true(config.num_classes > 0)
  assert_true(config.num_epochs > 0)
  assert_true(config.batch_size > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.warmup_ratio > 0.0)
  assert_true(config.weight_decay > 0.0)
  assert_true(config.max_grad_norm > 0.0)
  assert_true(config.use_mixed_precision)
  assert_true(!config.use_lora)
  assert_true(config.freeze_layers == 0)
}

///|
test "compute_self_attention: 注意力权重计算" {
  let query = [[1.0, 0.0], [0.0, 1.0]]
  let key = [[1.0, 0.0], [0.0, 1.0]]
  let value = [[1.0, 0.0], [0.0, 1.0]]
  let result = compute_self_attention(query, key, value, 2, 2)
  assert_true(result.seq_length == 2)
  assert_true(result.head_dim == 2)
  assert_true(result.num_heads == 1)
  assert_true(result.attention_type == AttentionType::SelfAttention)
  assert_true(result.weights.length() == 2)
  // 每行权重和应为1（归一化）
  for row in result.weights {
    let mut sum = 0.0
    for w in row {
      sum += w
    }
    assert_true(sum > 0.99 && sum < 1.01)
  }
}

///|
test "compute_self_attention: 零输入" {
  let zero = [[0.0, 0.0], [0.0, 0.0]]
  let result = compute_self_attention(zero, zero, zero, 2, 2)
  assert_true(result.weights.length() == 2)
  assert_true(result.seq_length == 2)
}

///|
test "transformer_forward: 前向传播" {
  let config = create_default_transformer_config()
  let input = [[0.5, 0.3], [0.1, 0.8], [0.2, 0.4]]
  let output = transformer_forward(input, config)
  assert_true(output.seq_length == 3)
  assert_true(output.hidden_dim == config.hidden_dim)
  assert_true(output.hidden_states.length() == 3)
  assert_true(output.layer_norm_output.length() == 3)
  assert_true(output.attention_weights.seq_length == 3)
}

///|
test "simulate_finetuning: 微调模拟" {
  let config = create_default_finetuning_config()
  let result = simulate_finetuning(config, 0.5)
  assert_true(result.source_accuracy == 0.5)
  assert_true(result.target_accuracy >= 0.5)
  assert_true(result.transfer_gain >= 0.0)
  assert_true(result.convergence_epoch > 0)
  assert_true(result.convergence_epoch <= config.num_epochs)
  assert_true(result.num_trainable_params > 0)
  assert_true(result.training_time_s > 0.0)
}

///|
test "simulate_finetuning: 高初始准确率" {
  let config = create_default_finetuning_config()
  let result = simulate_finetuning(config, 0.9)
  assert_true(result.target_accuracy >= 0.9)
  assert_true(result.transfer_gain >= 0.0)
}

///|
test "dl_advanced_report_to_string: 报告生成" {
  let config = create_default_transformer_config()
  let report = dl_advanced_report_to_string(
    DLAdvancedTaskType::Transformer,
    config,
    "测试结果",
  )
  assert_true(report.contains("深度学习高级报告"))
  assert_true(report.contains("任务信息"))
  assert_true(report.contains("Transformer"))
  assert_true(report.contains("测试结果"))
}

///|
test "dl_advanced_report_to_string: 不同任务类型" {
  let config = create_default_transformer_config()
  let report = dl_advanced_report_to_string(
    DLAdvancedTaskType::FineTuning,
    config,
    "微调结果",
  )
  assert_true(report.contains("微调"))
  assert_true(report.contains("微调结果"))
}
