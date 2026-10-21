// 联邦学习扩展 — FedAvg/FedProx/差分隐私
// Federated learning extensions
//
// Phase 13 v343: 深度学习大扩展 — 联邦学习扩展。

///|
/// 联邦学习类型。
/// Federated learning type.
pub(all) enum FederatedType {
  FedAvg
  FedProx
  DifferentialPrivacy
  FedNova
} derive(Eq, @debug.Debug)

///|
pub extend FederatedType with @debug.Debug::{to_repr}

///|
pub extend FederatedType with Eq::{not_equal, equal}

///|
/// 联邦学习配置。
/// Federated learning configuration.
pub(all) struct FederatedConfig {
  num_clients : Int32
  num_rounds : Int32
  client_fraction : Double
  prox_mu : Double
  dp_epsilon : Double
  fed_type : FederatedType
} derive(Eq, @debug.Debug)

///|
pub extend FederatedConfig with @debug.Debug::{to_repr}

///|
pub extend FederatedConfig with Eq::{not_equal, equal}

///|
/// 客户端更新。
/// Client update.
pub(all) struct ClientUpdate {
  params : Array[Double]
  num_samples : Int32
  loss : Double
} derive(Eq, @debug.Debug)

///|
pub extend ClientUpdate with @debug.Debug::{to_repr}

///|
pub extend ClientUpdate with Eq::{not_equal, equal}

///|
/// 联邦学习状态。
/// Federated learning state.
pub(all) struct FederatedState {
  global_params : Array[Double]
  round : Int32
  converged : Bool
} derive(Eq, @debug.Debug)

///|
pub extend FederatedState with @debug.Debug::{to_repr}

///|
pub extend FederatedState with Eq::{not_equal, equal}

///|
/// FedAvg 聚合。
/// FedAvg aggregation.
pub fn fedavg_aggregate(client_updates : Array[ClientUpdate]) -> Array[Double] {
  let total_samples : Array[Int32] = []
  let _ = total_samples
  let n = client_updates.length()
  if n == 0 {
    return []
  }
  let param_len = client_updates[0].params.length()
  let result : Array[Double] = []
  for _ in 0..<param_len {
    result.push(0.0)
  }
  let mut total_n = 0
  for i in 0..<n {
    total_n = total_n + client_updates[i].num_samples
  }
  if total_n == 0 {
    return result
  }
  for i in 0..<n {
    let weight = client_updates[i].num_samples.to_double() / total_n.to_double()
    for j in 0..<param_len {
      if j < client_updates[i].params.length() {
        result[j] = result[j] + weight * client_updates[i].params[j]
      }
    }
  }
  result
}

///|
/// FedProx 更新。
/// FedProx update.
pub fn fedprox_update(
  local_params : Array[Double],
  global_params : Array[Double],
  gradients : Array[Double],
  config : FederatedConfig,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = local_params.length()
  let m = global_params.length()
  let g_len = gradients.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let g = if i < g_len { gradients[i] } else { 0.0 }
    let prox_term = config.prox_mu * (local_params[i] - global_params[i])
    result.push(local_params[i] - 0.01 * (g + prox_term))
  }
  for i in len..<n {
    result.push(local_params[i])
  }
  result
}

///|
/// 添加差分隐私噪声。
/// Add differential privacy noise.
pub fn add_dp_noise(
  params : Array[Double],
  sensitivity : Double,
  epsilon : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  let scale = if epsilon > 0.0 { sensitivity / epsilon } else { 0.0 }
  for i in 0..<params.length() {
    let noise = laplace_noise(i, scale)
    result.push(params[i] + noise)
  }
  result
}

///|
/// 联邦学习轮。
/// Federated learning round.
pub fn federated_round(
  global_params : Array[Double],
  client_updates : Array[ClientUpdate],
  config : FederatedConfig,
  current_round : Int32,
) -> FederatedState {
  let new_params = match config.fed_type {
    FederatedType::FedAvg => fedavg_aggregate(client_updates)
    FederatedType::FedProx => fedavg_aggregate(client_updates)
    FederatedType::DifferentialPrivacy => {
      let aggregated = fedavg_aggregate(client_updates)
      add_dp_noise(aggregated, 1.0, config.dp_epsilon)
    }
    FederatedType::FedNova => fedavg_aggregate(client_updates)
  }
  let mut loss_diff = 0.0
  let n = global_params.length()
  let m = new_params.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let diff = global_params[i] - new_params[i]
    loss_diff = loss_diff + diff * diff
  }
  let converged = loss_diff < 0.000001
  FederatedState::{
    global_params: new_params,
    round: current_round + 1,
    converged,
  }
}

///|
/// 计算客户端漂移。
/// Compute client drift.
pub fn compute_client_drift(
  client_params : Array[Double],
  global_params : Array[Double],
) -> Double {
  let n = client_params.length()
  let m = global_params.length()
  let len = if n < m { n } else { m }
  let mut drift = 0.0
  for i in 0..<len {
    let diff = client_params[i] - global_params[i]
    drift = drift + diff * diff
  }
  drift.sqrt()
}

///|
fn laplace_noise(seed : Int32, scale : Double) -> Double {
  let x = seed.to_double() * 4.12345 + 1.23456
  let frac = x - x.floor()
  let u = frac * 2.0 - 1.0
  if u == 0.0 {
    0.0
  } else if u > 0.0 {
    -scale * (@math.log2(u) * 0.6931471805599453)
  } else {
    scale * (@math.log2(-u) * 0.6931471805599453)
  }
}
