// v36.0.0 AutoML NAS 测试 — automl_nas 模块 8 函数

///|
test "create_default_nas_config: 默认NAS配置" {
  let config = @automl_nas.create_default_nas_config()
  assert_true(config.num_trials > 0)
  assert_true(config.max_layers > 0)
  assert_true(config.max_channels > 0)
  assert_true(config.population_size > 0)
  assert_true(config.mutation_rate > 0.0)
  assert_true(config.crossover_rate > 0.0)
  assert_true(config.time_budget_s > 0.0)
  assert_true(config.resource_constraint_mb > 0.0)
}

///|
test "create_default_hpo_config: 默认HPO配置" {
  let config = @automl_nas.create_default_hpo_config()
  assert_true(config.num_trials > 0)
  assert_true(config.num_epochs_per_trial > 0)
  assert_true(config.search_space.length() >= 0)
  assert_true(config.early_stopping_patience > 0)
  assert_true(config.num_workers > 0)
}

///|
test "generate_random_architecture: 随机架构生成" {
  let arch = @automl_nas.generate_random_architecture(5, 32)
  assert_true(arch.num_layers > 0)
  assert_true(arch.layers.length() > 0)
  assert_true(arch.num_parameters >= 0)
  assert_true(arch.flops >= 0)
  assert_true(arch.memory_mb >= 0.0)
  assert_true(arch.inference_time_ms >= 0.0)
  assert_true(arch.architecture_id >= 0)
}

///|
test "generate_random_hyperparameters: 随机超参数生成" {
  let hp = @automl_nas.generate_random_hyperparameters()
  assert_true(hp.learning_rate > 0.0)
  assert_true(hp.batch_size > 0)
  assert_true(hp.num_epochs > 0)
  assert_true(hp.hidden_dim > 0)
  assert_true(hp.num_layers > 0)
  assert_true(hp.dropout_rate >= 0.0)
  assert_true(hp.weight_decay >= 0.0)
}

///|
test "evaluate_model: 模型评估" {
  let arch = @automl_nas.generate_random_architecture(3, 16)
  let hp = @automl_nas.generate_random_hyperparameters()
  let metrics = @automl_nas.evaluate_model(arch, hp)
  assert_true(metrics.accuracy >= 0.0 && metrics.accuracy <= 1.0)
  assert_true(metrics.loss >= 0.0)
  assert_true(metrics.precision >= 0.0)
  assert_true(metrics.recall >= 0.0)
  assert_true(metrics.f1_score >= 0.0)
  assert_true(metrics.inference_time_ms >= 0.0)
  assert_true(metrics.num_parameters >= 0)
  assert_true(metrics.flops >= 0)
}

///|
test "perform_nas: 神经架构搜索" {
  let config = @automl_nas.create_default_nas_config()
  let result = @automl_nas.perform_nas(config)
  assert_true(result.best_accuracy >= 0.0 && result.best_accuracy <= 1.0)
  assert_true(result.best_loss >= 0.0)
  assert_true(result.num_trials_completed > 0)
  assert_true(result.search_time_s > 0.0)
  assert_true(result.all_accuracies.length() >= 0)
  assert_true(result.convergence_curve.length() >= 0)
  assert_true(result.best_architecture.num_layers > 0)
}

///|
test "perform_hpo: 超参数优化" {
  let config = @automl_nas.create_default_hpo_config()
  let arch = @automl_nas.generate_random_architecture(3, 16)
  let result = @automl_nas.perform_hpo(config, arch)
  assert_true(result.best_accuracy >= 0.0 && result.best_accuracy <= 1.0)
  assert_true(result.best_loss >= 0.0)
  assert_true(result.num_trials_completed > 0)
  assert_true(result.search_time_s > 0.0)
  assert_true(result.all_accuracies.length() >= 0)
  assert_true(result.convergence_curve.length() >= 0)
}

///|
test "automl_report_to_string: NAS报告" {
  let config = @automl_nas.create_default_nas_config()
  let arch = @automl_nas.generate_random_architecture(3, 16)
  let hp = @automl_nas.generate_random_hyperparameters()
  let metrics = @automl_nas.evaluate_model(arch, hp)
  let result = @automl_nas.perform_nas(config)
  let report = @automl_nas.automl_report_to_string(result, config, metrics)
  assert_true(report.length() > 0)
}
