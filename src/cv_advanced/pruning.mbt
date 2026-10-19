// 模型剪枝 — 结构化/非结构化/通道剪枝
// Model pruning
//
// Phase 13 v335: 深度学习大扩展 — 模型剪枝。

///|
/// 剪枝类型。
/// Pruning type.
pub(all) enum PruningType {
  Unstructured
  Structured
  Channel
  Filter
} derive(Eq, @debug.Debug)

///|
pub extend PruningType with @debug.Debug::{to_repr}

///|
pub extend PruningType with Eq::{not_equal, equal}

///|
/// 剪枝配置。
/// Pruning configuration.
pub(all) struct PruningConfig {
  sparsity : Double
  pruning_type : PruningType
  threshold : Double
  min_channels : Int
} derive(Eq, @debug.Debug)

///|
pub extend PruningConfig with @debug.Debug::{to_repr}

///|
pub extend PruningConfig with Eq::{not_equal, equal}

///|
/// 剪枝结果。
/// Pruning result.
pub(all) struct PruningResult {
  mask : Array[Bool]
  pruned_indices : Array[Int]
  sparsity_achieved : Double
  original_size : Int
  pruned_size : Int
} derive(Eq, @debug.Debug)

///|
pub extend PruningResult with @debug.Debug::{to_repr}

///|
pub extend PruningResult with Eq::{not_equal, equal}

///|
/// 计算剪枝掩码。
/// Compute pruning mask.
pub fn compute_pruning_mask(
  weights : Array[Double],
  threshold : Double,
) -> Array[Bool] {
  let mask : Array[Bool] = []
  for w in weights {
    mask.push(w.abs() > threshold)
  }
  mask
}

///|
/// 非结构化剪枝。
/// Unstructured pruning.
pub fn prune_unstructured(
  weights : Array[Double],
  config : PruningConfig,
) -> PruningResult {
  let n = weights.length()
  let mut threshold = config.threshold
  if threshold == 0.0 {
    let sorted : Array[Double] = []
    for w in weights {
      sorted.push(w.abs())
    }
    sorted.sort_by(fn(a, b) { compare(a, b) })
    let k = (n.to_double() * config.sparsity).to_int()
    if k > 0 && k < n {
      threshold = sorted[k]
    }
  }
  let mask = compute_pruning_mask(weights, threshold)
  let pruned_indices : Array[Int] = []
  let mut pruned_count = 0
  for i in 0..<n {
    if !mask[i] {
      pruned_indices.push(i)
      pruned_count = pruned_count + 1
    }
  }
  let sparsity = if n > 0 {
    pruned_count.to_double() / n.to_double()
  } else {
    0.0
  }
  PruningResult::{
    mask,
    pruned_indices,
    sparsity_achieved: sparsity,
    original_size: n,
    pruned_size: n - pruned_count,
  }
}

///|
/// 结构化剪枝。
/// Structured pruning.
pub fn prune_structured(
  weights : Array[Double],
  block_size : Int,
  config : PruningConfig,
) -> PruningResult {
  let n = weights.length()
  let num_blocks = n / block_size
  let block_norms : Array[Double] = []
  for b in 0..<num_blocks {
    let mut norm = 0.0
    for i in 0..<block_size {
      let idx = b * block_size + i
      norm = norm + weights[idx] * weights[idx]
    }
    block_norms.push(norm.sqrt())
  }
  let sorted_norms : Array[Double] = []
  for v in block_norms {
    sorted_norms.push(v)
  }
  sorted_norms.sort_by(fn(a, b) { compare(a, b) })
  let k = (num_blocks.to_double() * config.sparsity).to_int()
  let threshold = if k > 0 && k < num_blocks { sorted_norms[k] } else { 0.0 }
  let mask : Array[Bool] = []
  let pruned_indices : Array[Int] = []
  let mut pruned_count = 0
  for b in 0..<num_blocks {
    let keep = block_norms[b] > threshold
    for i in 0..<block_size {
      let idx = b * block_size + i
      mask.push(keep)
      if !keep {
        pruned_indices.push(idx)
        pruned_count = pruned_count + 1
      }
    }
  }
  for _ in (num_blocks * block_size)..<n {
    mask.push(true)
  }
  let sparsity = if n > 0 {
    pruned_count.to_double() / n.to_double()
  } else {
    0.0
  }
  PruningResult::{
    mask,
    pruned_indices,
    sparsity_achieved: sparsity,
    original_size: n,
    pruned_size: n - pruned_count,
  }
}

///|
/// 通道剪枝。
/// Channel pruning.
pub fn prune_channels(
  weights : Array[Double],
  num_channels : Int,
  config : PruningConfig,
) -> PruningResult {
  let n = weights.length()
  let per_channel = n / num_channels
  let channel_norms : Array[Double] = []
  for c in 0..<num_channels {
    let mut norm = 0.0
    for i in 0..<per_channel {
      let idx = c * per_channel + i
      if idx < n {
        norm = norm + weights[idx] * weights[idx]
      }
    }
    channel_norms.push(norm.sqrt())
  }
  let sorted_norms : Array[Double] = []
  for v in channel_norms {
    sorted_norms.push(v)
  }
  sorted_norms.sort_by(fn(a, b) { compare(a, b) })
  let k = (num_channels.to_double() * config.sparsity).to_int()
  let max_prune = num_channels - config.min_channels
  let actual_k = if k > max_prune { max_prune } else { k }
  let threshold = if actual_k > 0 && actual_k < num_channels {
    sorted_norms[actual_k]
  } else {
    0.0
  }
  let mask : Array[Bool] = []
  let pruned_indices : Array[Int] = []
  let mut pruned_count = 0
  for c in 0..<num_channels {
    let keep = channel_norms[c] > threshold
    for i in 0..<per_channel {
      let idx = c * per_channel + i
      if idx < n {
        mask.push(keep)
        if !keep {
          pruned_indices.push(idx)
          pruned_count = pruned_count + 1
        }
      }
    }
  }
  let sparsity = if n > 0 {
    pruned_count.to_double() / n.to_double()
  } else {
    0.0
  }
  PruningResult::{
    mask,
    pruned_indices,
    sparsity_achieved: sparsity,
    original_size: n,
    pruned_size: n - pruned_count,
  }
}

///|
/// 应用剪枝掩码。
/// Apply pruning mask.
pub fn apply_pruning_mask(
  weights : Array[Double],
  mask : Array[Bool],
) -> Array[Double] {
  let result : Array[Double] = []
  let n = weights.length()
  let m = mask.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    if mask[i] {
      result.push(weights[i])
    } else {
      result.push(0.0)
    }
  }
  for i in len..<n {
    result.push(weights[i])
  }
  result
}

///|
/// 计算稀疏度。
/// Compute sparsity.
pub fn compute_sparsity(weights : Array[Double]) -> Double {
  let n = weights.length()
  if n == 0 {
    return 0.0
  }
  let mut zeros = 0
  for w in weights {
    if w == 0.0 {
      zeros = zeros + 1
    }
  }
  zeros.to_double() / n.to_double()
}
