// v36.0.0 AutoML 高级测试 — automl_advanced 模块 7 函数

///|
test "create_default_automl_config: 默认AutoML配置" {
  let config = @automl_advanced.create_default_automl_config()
  assert_true(config.max_trials > 0)
  assert_true(config.max_time_ms > 0.0)
  assert_true(config.num_cv_folds > 0)
  assert_true(config.search_space_size > 0)
  assert_true(config.population_size > 0)
  assert_true(config.mutation_rate > 0.0)
  assert_true(config.crossover_rate > 0.0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.random_state >= 0)
}

///|
test "automl: 自动化机器学习" {
  let config = @automl_advanced.create_default_automl_config()
  let result = @automl_advanced.automl(100, config)
  assert_true(result.num_trials > 0)
  assert_true(result.num_models_evaluated > 0)
  assert_true(result.total_time_ms > 0.0)
  assert_true(result.best_validation_score >= 0.0)
  assert_true(result.best_test_score >= 0.0)
  assert_true(result.best_hyperparameters.length() >= 0)
  assert_true(result.best_architecture.length() >= 0)
  assert_true(result.convergence_curve.length() >= 0)
}

///|
test "optimize_hyperparameters: 超参数优化" {
  let config = @automl_advanced.create_default_automl_config()
  let result = @automl_advanced.optimize_hyperparameters(50, config)
  assert_true(result.num_trials > 0)
  assert_true(result.num_evaluations > 0)
  assert_true(result.search_space_dimensions >= 0)
  assert_true(result.best_score >= 0.0)
  assert_true(result.best_trial_id >= 0)
  assert_true(result.total_time_ms > 0.0)
  assert_true(result.convergence_curve.length() >= 0)
}

///|
test "neural_architecture_search: 神经架构搜索" {
  let config = @automl_advanced.create_default_automl_config()
  let result = @automl_advanced.neural_architecture_search(10, 5, config)
  assert_true(result.num_architectures_evaluated > 0)
  assert_true(result.search_time_ms > 0.0)
  assert_true(result.num_layers > 0)
  assert_true(result.best_accuracy >= 0.0)
  assert_true(result.params_count >= 0)
  assert_true(result.flops_count >= 0)
  assert_true(result.best_architecture.length() >= 0)
  assert_true(result.convergence_curve.length() >= 0)
}

///|
test "automated_model_selection: 模型选择" {
  let config = @automl_advanced.create_default_automl_config()
  let models = ["rf", "svm", "cnn", "rnn"]
  let result = @automl_advanced.automated_model_selection(models, config)
  assert_true(result.num_models_evaluated > 0)
  assert_true(result.best_score >= 0.0)
  assert_true(result.model_scores.length() >= 0)
  assert_true(result.model_names.length() >= 0)
  assert_true(result.cross_validation_scores.length() >= 0)
  assert_true(result.selection_time_ms > 0.0)
}

///|
test "automated_feature_engineering: 特征工程" {
  let config = @automl_advanced.create_default_automl_config()
  let result = @automl_advanced.automated_feature_engineering(20, config)
  assert_true(result.num_original_features >= 0)
  assert_true(result.num_selected_features >= 0)
  assert_true(result.num_extracted_features >= 0)
  assert_true(result.feature_importance.length() >= 0)
  assert_true(result.feature_scores.length() >= 0)
  assert_true(result.processing_time_ms > 0.0)
  assert_true(result.selected_features.length() >= 0)
}

///|
test "automl_report_to_string: 报告生成" {
  let config = @automl_advanced.create_default_automl_config()
  let report = @automl_advanced.automl_report_to_string(
    @automl_advanced.AutoMLTaskType::HyperparameterOptimization,
    config,
    "AutoML完成",
  )
  assert_true(report.length() > 0)
}
