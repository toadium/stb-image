// v37.0.0 联邦学习测试 — federated_learning 模块 12 函数

///|
test "create_default_federated_config: 默认联邦配置" {
  let config = create_default_federated_config()
  assert_true(config.num_clients > 0)
  assert_true(config.num_rounds > 0)
  assert_true(config.client_fraction > 0.0)
  assert_true(config.local_epochs > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.batch_size > 0)
}

///|
test "create_default_dp_config: 默认差分隐私配置" {
  let config = create_default_dp_config()
  assert_true(config.epsilon > 0.0)
  assert_true(config.delta > 0.0)
  assert_true(config.sensitivity > 0.0)
  assert_true(config.clipping_norm > 0.0)
}

///|
test "create_default_he_config: 默认同态加密配置" {
  let config = create_default_he_config()
  assert_true(config.key_size > 0)
  assert_true(config.polynomial_degree > 0)
  assert_true(config.plaintext_modulus > 0)
  assert_true(config.scale > 0.0)
}

///|
test "create_default_mpc_config: 默认MPC配置" {
  let config = create_default_mpc_config()
  assert_true(config.num_parties > 0)
  assert_true(config.threshold > 0)
  assert_true(config.communication_rounds > 0)
}

///|
test "create_federated_clients: 创建客户端" {
  let config = create_default_federated_config()
  let clients = create_federated_clients(10, 1000, config)
  assert_true(clients.length() == 10)
  for c in clients {
    assert_true(c.client_id >= 0)
    assert_true(c.data_size > 0)
    assert_true(c.local_epochs > 0)
    assert_true(c.learning_rate > 0.0)
    assert_true(c.batch_size > 0)
    assert_true(c.participation_rate > 0.0)
  }
}

///|
test "add_dp_noise: 差分隐私噪声" {
  let config = create_default_dp_config()
  let result = add_dp_noise(1.0, config)
  assert_true(result >= -100.0 && result <= 100.0)
}

///|
test "encrypt_data / decrypt_data: 加解密往返" {
  let config = create_default_he_config()
  let data = [1.0, 2.0, 3.0, 4.0, 5.0]
  let encrypted = encrypt_data(data, config)
  assert_true(encrypted.ciphertext.length() > 0)
  assert_true(encrypted.is_encrypted)
  let decrypted = decrypt_data(encrypted, config)
  assert_true(decrypted.length() == data.length())
}

///|
test "encrypted_add: 同态加密加法" {
  let config = create_default_he_config()
  let e1 = encrypt_data([1.0, 2.0, 3.0], config)
  let e2 = encrypt_data([4.0, 5.0, 6.0], config)
  let sum = encrypted_add(e1, e2, config)
  assert_true(sum.ciphertext.length() > 0)
  assert_true(sum.is_encrypted)
}

///|
test "evaluate_privacy_protection: 隐私保护评估" {
  let config = create_default_dp_config()
  let result = evaluate_privacy_protection(0.9, 0.85, config)
  assert_true(result.privacy_budget >= 0.0)
  assert_true(result.epsilon > 0.0)
  assert_true(result.accuracy_loss >= 0.0)
  assert_true(result.overhead_time_ms >= 0.0)
  assert_true(result.overhead_memory_mb >= 0.0)
}

///|
test "simulate_federated_training: 联邦训练模拟" {
  let config = create_default_federated_config()
  let clients = create_federated_clients(5, 500, config)
  let result = simulate_federated_training(clients, config, 0.5)
  assert_true(result.num_rounds_completed > 0)
  assert_true(result.final_accuracy >= 0.0)
  assert_true(result.final_loss >= 0.0)
  assert_true(result.num_clients_participated > 0)
  assert_true(result.communication_cost_mb >= 0.0)
  assert_true(result.training_time_s > 0.0)
  assert_true(result.convergence_round > 0)
  assert_true(result.privacy_budget_used >= 0.0)
}

///|
test "federated_learning_report_to_string: 报告生成" {
  let config = create_default_federated_config()
  let clients = create_federated_clients(3, 100, config)
  let train_result = simulate_federated_training(clients, config, 0.5)
  let dp_config = create_default_dp_config()
  let privacy = evaluate_privacy_protection(0.9, 0.85, dp_config)
  let report = federated_learning_report_to_string(
    train_result, privacy, config,
  )
  assert_true(report.length() > 0)
}
