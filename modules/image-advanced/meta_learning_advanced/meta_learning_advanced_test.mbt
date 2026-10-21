// v37.0.0 元学习高级测试 — meta_learning_advanced 模块 8 函数

///|
test "create_default_meta_learning_config: 默认元学习配置" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  assert_true(config.num_way > 0)
  assert_true(config.num_shot > 0)
  assert_true(config.num_query > 0)
  assert_true(config.num_meta_iterations > 0)
  assert_true(config.inner_learning_rate > 0.0)
  assert_true(config.meta_learning_rate > 0.0)
  assert_true(config.num_inner_steps > 0)
  assert_true(config.random_state >= 0)
}

///|
test "meta_learn: 元学习" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let result = @meta_learning_advanced.meta_learn(10, config)
  assert_true(result.num_tasks > 0)
  assert_true(result.num_way > 0)
  assert_true(result.num_shot > 0)
  assert_true(result.meta_training_loss >= 0.0)
  assert_true(result.meta_training_accuracy >= 0.0)
  assert_true(result.meta_validation_accuracy >= 0.0)
  assert_true(result.meta_test_accuracy >= 0.0)
  assert_true(result.num_meta_iterations > 0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.meta_learned_parameters.length() >= 0)
}

///|
test "train_maml: MAML训练" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let result = @meta_learning_advanced.train_maml(20, config)
  assert_true(result.num_tasks > 0)
  assert_true(result.num_way > 0)
  assert_true(result.num_shot > 0)
  assert_true(result.meta_loss >= 0.0)
  assert_true(result.meta_accuracy >= 0.0)
  assert_true(result.num_inner_steps > 0)
  assert_true(result.inner_learning_rate > 0.0)
  assert_true(result.meta_learning_rate > 0.0)
  assert_true(result.num_meta_iterations > 0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.initial_parameters.length() >= 0)
  assert_true(result.meta_learned_parameters.length() >= 0)
}

///|
test "train_reptile: Reptile训练" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let result = @meta_learning_advanced.train_reptile(15, config)
  assert_true(result.num_tasks > 0)
  assert_true(result.meta_loss >= 0.0)
  assert_true(result.meta_accuracy >= 0.0)
  assert_true(result.num_meta_iterations > 0)
  assert_true(result.learning_time_ms > 0.0)
}

///|
test "train_matching_net: 匹配网络训练" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let support = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
  let query = [[1.5, 2.5], [3.5, 4.5]]
  let result = @meta_learning_advanced.train_matching_net(
    support, query, config,
  )
  assert_true(result.num_classes > 0)
  assert_true(result.num_support > 0)
  assert_true(result.num_query > 0)
  assert_true(result.training_loss >= 0.0)
  assert_true(result.test_loss >= 0.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.num_episodes > 0)
  assert_true(result.learning_time_ms > 0.0)
}

///|
test "train_protonet: 原型网络训练" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let support = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
  let query = [[1.5, 2.5], [3.5, 4.5]]
  let result = @meta_learning_advanced.train_protonet(support, query, config)
  assert_true(result.num_classes > 0)
  assert_true(result.feature_dimension > 0)
  assert_true(result.training_loss >= 0.0)

  assert_true(result.test_loss >= 0.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.num_episodes > 0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.prototypes.length() >= 0)
}

///|
test "train_relation_net: 关系网络训练" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let support = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
  let query = [1.5, 3.5, 5.5]
  let result = @meta_learning_advanced.train_relation_net(
    support, query, config,
  )
  assert_true(result.num_classes > 0)
  assert_true(result.num_support > 0)
  assert_true(result.num_query > 0)
  assert_true(result.training_loss >= 0.0)
  assert_true(result.test_loss >= 0.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.num_episodes > 0)
  assert_true(result.learning_time_ms > 0.0)
  assert_true(result.relation_module_layers > 0)
}

///|
test "meta_learning_report_to_string: 报告生成" {
  let config = @meta_learning_advanced.create_default_meta_learning_config()
  let report = @meta_learning_advanced.meta_learning_report_to_string(
    @meta_learning_advanced.MetaLearningTaskType::FewShotClassification,
    config,
    "元学习完成",
  )
  assert_true(report.length() > 0)
}
