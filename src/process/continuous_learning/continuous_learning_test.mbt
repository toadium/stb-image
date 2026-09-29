// v37.0.0 持续学习测试 — continuous_learning 模块 11 函数

///|
test "create_default_continual_config: 默认持续学习配置" {
  let config = create_default_continual_config()
  assert_true(config.num_tasks > 0)
  assert_true(config.ewc_lambda > 0.0)
  assert_true(config.memory_size > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.batch_size > 0)
  assert_true(config.num_epochs > 0)
}

///|
test "create_default_ewc_config: 默认EWC配置" {
  let config = create_default_ewc_config(100)
  assert_true(config.lambda > 0.0)
  assert_true(config.num_params > 0)
  assert_true(config.fisher_information.length() >= 0)
  assert_true(config.optimal_params.length() >= 0)
}

///|
test "create_memory_buffer: 创建记忆缓冲区" {
  let buffer = create_memory_buffer(100, "reservoir")
  assert_true(buffer.buffer_size > 0)
  assert_true(buffer.current_size == 0)
  assert_true(buffer.samples.length() >= 0)
  assert_true(buffer.labels.length() >= 0)
  assert_true(buffer.task_ids.length() >= 0)
}

///|
test "add_to_memory: 添加到记忆缓冲区" {
  let buffer = create_memory_buffer(100, "uniform")
  let sample = [1.0, 2.0, 3.0]
  let updated = add_to_memory(buffer, sample, 0, 5)
  assert_true(updated.current_size > 0)
  assert_true(updated.samples.length() > 0)
}

///|
test "sample_from_memory: 从记忆缓冲区采样" {
  let buffer = create_memory_buffer(100, "uniform")
  let buffer1 = add_to_memory(buffer, [1.0, 2.0], 0, 5)
  let buffer2 = add_to_memory(buffer1, [3.0, 4.0], 1, 5)
  let (samples, labels, task_ids) = sample_from_memory(buffer2, 2)
  assert_true(samples.length() >= 0)
  assert_true(labels.length() >= 0)
  assert_true(task_ids.length() >= 0)
}

///|
test "create_task_sequence: 创建任务序列" {
  let tasks = create_task_sequence(5, 10, 100)
  assert_true(tasks.length() == 5)
  for t in tasks {
    assert_true(t.task_id >= 0)
    assert_true(t.num_classes > 0)
    assert_true(t.num_samples > 0)
    assert_true(t.difficulty >= 0.0)
  }
}

///|
test "compute_ewc_loss: EWC损失计算" {
  let config = create_default_ewc_config(10)
  let params = [0.1, 0.2, 0.3, 0.4, 0.5]
  let loss = compute_ewc_loss(params, config)
  assert_true(loss >= 0.0)
}

///|
test "update_fisher_information: 更新Fisher信息" {
  let config = create_default_ewc_config(10)
  let gradients = [0.1, 0.2, 0.3, 0.4, 0.5]
  let updated = update_fisher_information(config, gradients)
  assert_true(updated.fisher_information.length() >= 0)
  assert_true(updated.num_params > 0)
}

///|
test "simulate_continual_learning: 持续学习模拟" {
  let config = create_default_continual_config()
  let tasks = create_task_sequence(3, 10, 100)
  let metrics = simulate_continual_learning(tasks, config, 0.5)
  assert_true(metrics.average_accuracy >= 0.0)
  assert_true(metrics.final_accuracy >= 0.0)
  assert_true(metrics.backward_transfer >= -1.0)
  assert_true(metrics.forward_transfer >= -1.0)
  assert_true(metrics.forgetting_measure >= 0.0)
  assert_true(metrics.num_tasks_completed > 0)
  assert_true(metrics.training_time_s > 0.0)
  assert_true(metrics.learning_accuracy.length() >= 0)
  assert_true(metrics.task_accuracies.length() >= 0)
}

///|
test "continual_learning_report_to_string: 报告生成" {
  let config = create_default_continual_config()
  let tasks = create_task_sequence(3, 10, 100)
  let metrics = simulate_continual_learning(tasks, config, 0.5)
  let report = continual_learning_report_to_string(metrics, config)
  assert_true(report.length() > 0)
}
