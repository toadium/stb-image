// v37.0.0 迁移学习高级测试 — transfer_learning_advanced 模块 9 函数

///|
test "create_default_transfer_learning_config: 默认配置" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  assert_true(config.num_frozen_layers >= 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.num_epochs > 0)
  assert_true(config.batch_size > 0)
  assert_true(config.temperature > 0.0)
  assert_true(config.alpha > 0.0)
  assert_true(config.num_way > 0)
  assert_true(config.num_shot > 0)
  assert_true(config.random_state >= 0)
}

///|
test "load_pretrained_model: 加载预训练模型" {
  let result = @transfer_learning_advanced.load_pretrained_model(
    @transfer_learning_advanced.PretrainedModelType::ResNet,
    50,
    1000,
  )
  assert_true(result.num_layers > 0)
  assert_true(result.num_parameters > 0)
  assert_true(result.pretraining_accuracy >= 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.batch_size > 0)
  assert_true(result.learning_rate > 0.0)
  assert_true(result.pretraining_time_ms > 0.0)
  assert_true(result.pretrained_weights.length() >= 0)
}

///|
test "fine_tune_model: 微调模型" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let weights = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
  let result = @transfer_learning_advanced.fine_tune_model(weights, 1, config)
  assert_true(result.num_layers > 0)
  assert_true(result.num_frozen_layers >= 0)
  assert_true(result.num_trainable_layers >= 0)
  assert_true(result.training_loss >= 0.0)
  assert_true(result.validation_loss >= 0.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.fine_tuning_time_ms > 0.0)
  assert_true(result.fine_tuned_weights.length() >= 0)
}

///|
test "transfer_learning: 迁移学习" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let source = [[0.1, 0.2], [0.3, 0.4]]
  let target = [[0.5, 0.6], [0.7, 0.8]]
  let result = @transfer_learning_advanced.transfer_learning(
    source, target, config,
  )
  assert_true(result.num_layers > 0)
  assert_true(result.training_loss >= 0.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.source_accuracy >= 0.0)
  assert_true(result.target_accuracy >= 0.0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.transferred_model_weights.length() >= 0)
}

///|
test "domain_adaptation: 域适应" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let data = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
  let result = @transfer_learning_advanced.domain_adaptation(data, config)
  assert_true(result.source_accuracy >= 0.0)
  assert_true(result.target_accuracy >= 0.0)
  assert_true(result.source_loss >= 0.0)
  assert_true(result.target_loss >= 0.0)
  assert_true(result.domain_gap >= 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.learning_rate > 0.0)
  assert_true(result.adaptation_time_ms > 0.0)
  assert_true(result.adapted_weights.length() >= 0)
}

///|
test "few_shot_learning: 少样本学习" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let support = [[0.1, 0.2], [0.3, 0.4]]
  let query = [[0.5, 0.6], [0.7, 0.8]]
  let result = @transfer_learning_advanced.few_shot_learning(
    support, query, config,
  )
  assert_true(result.num_way > 0)
  assert_true(result.num_shot > 0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.num_episodes > 0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.learned_representations.length() >= 0)
}

///|
test "multi_task_learning: 多任务学习" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let result = @transfer_learning_advanced.multi_task_learning(
    3, 100, 50, config,
  )
  assert_true(result.num_tasks > 0)
  assert_true(result.task_accuracies.length() >= 0)
  assert_true(result.task_losses.length() >= 0)
  assert_true(result.average_accuracy >= 0.0)
  assert_true(result.average_loss >= 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.learning_time_ms > 0.0)
}

///|
test "knowledge_distillation: 知识蒸馏" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let teacher = [[0.1, 0.2], [0.3, 0.4], [0.5, 0.6]]
  let result = @transfer_learning_advanced.knowledge_distillation(
    teacher, 2, 10, config,
  )
  assert_true(result.student_accuracy >= 0.0)
  assert_true(result.teacher_accuracy >= 0.0)
  assert_true(result.student_loss >= 0.0)
  assert_true(result.distillation_loss >= 0.0)
  assert_true(result.temperature > 0.0)
  assert_true(result.num_epochs > 0)
  assert_true(result.distillation_time_ms > 0.0)
  assert_true(result.student_weights.length() >= 0)
}

///|
test "transfer_learning_report_to_string: 报告生成" {
  let config = @transfer_learning_advanced.create_default_transfer_learning_config()
  let report = @transfer_learning_advanced.transfer_learning_report_to_string(
    @transfer_learning_advanced.TransferLearningTaskType::FineTuning,
    config,
    "迁移学习完成",
  )
  assert_true(report.length() > 0)
}
