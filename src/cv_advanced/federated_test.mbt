// 联邦学习测试 — Federated learning tests
// Phase 13 v343: 深度学习大扩展 — 联邦学习扩展。

///|
fn make_fed_config() -> @cv_advanced.FederatedConfig {
  {
    num_clients: 3,
    num_rounds: 10,
    client_fraction: 1.0,
    prox_mu: 0.01,
    dp_epsilon: 1.0,
    fed_type: @cv_advanced.FederatedType::FedAvg,
  }
}

///|
test "fedavg_aggregate: 基本聚合" {
  let c1 : @cv_advanced.ClientUpdate = {
    params: [1.0, 2.0],
    num_samples: 10,
    loss: 0.5,
  }
  let c2 : @cv_advanced.ClientUpdate = {
    params: [3.0, 4.0],
    num_samples: 20,
    loss: 0.3,
  }
  let result = @cv_advanced.fedavg_aggregate([c1, c2])
  assert_true(result.length() == 2)
  assert_true(result[0] > 1.0 && result[0] < 3.0)
}

///|
test "fedavg_aggregate: 空客户端" {
  let result = @cv_advanced.fedavg_aggregate([])
  assert_true(result.length() == 0)
}

///|
test "fedprox_update: FedProx 更新" {
  let local_params = [1.0, 2.0, 3.0]
  let global_p = [0.5, 1.5, 2.5]
  let grads = [0.1, 0.2, 0.3]
  let config = make_fed_config()
  let result = @cv_advanced.fedprox_update(
    local_params, global_p, grads, config,
  )
  assert_true(result.length() == 3)
}

///|
test "add_dp_noise: 差分隐私噪声" {
  let params = [1.0, 2.0, 3.0]
  let result = @cv_advanced.add_dp_noise(params, 1.0, 1.0)
  assert_true(result.length() == 3)
}

///|
test "federated_round: 联邦轮" {
  let global_p = [1.0, 2.0]
  let c1 : @cv_advanced.ClientUpdate = {
    params: [1.1, 2.1],
    num_samples: 10,
    loss: 0.5,
  }
  let c2 : @cv_advanced.ClientUpdate = {
    params: [0.9, 1.9],
    num_samples: 10,
    loss: 0.4,
  }
  let config = make_fed_config()
  let state = @cv_advanced.federated_round(global_p, [c1, c2], config, 0)
  assert_true(state.round == 1)
  assert_true(state.global_params.length() == 2)
}

///|
test "compute_client_drift: 客户端漂移" {
  let client = [1.0, 2.0, 3.0]
  let global_p = [0.5, 1.5, 2.5]
  let drift = @cv_advanced.compute_client_drift(client, global_p)
  assert_true(drift > 0.0)
}

///|
test "FederatedType: enum 值" {
  let f1 = @cv_advanced.FederatedType::FedAvg
  let f2 = @cv_advanced.FederatedType::FedProx
  let f3 = @cv_advanced.FederatedType::DifferentialPrivacy
  let f4 = @cv_advanced.FederatedType::FedNova
  assert_true(f1 != f2)
  assert_true(f2 != f3)
  assert_true(f3 != f4)
}

///|
test "FederatedConfig: 构造与字段" {
  let config = make_fed_config()
  assert_true(config.num_clients == 3)
  assert_true(config.prox_mu == 0.01)
}

///|
test "ClientUpdate: 构造" {
  let c : @cv_advanced.ClientUpdate = {
    params: [1.0, 2.0],
    num_samples: 5,
    loss: 0.3,
  }
  assert_true(c.num_samples == 5)
  assert_true(c.loss == 0.3)
}
