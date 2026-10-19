// 模型剪枝测试 — Model pruning tests
// Phase 13 v335: 深度学习大扩展 — 模型剪枝。

///|
fn make_pruning_config() -> @cv_advanced.PruningConfig {
  {
    sparsity: 0.5,
    pruning_type: @cv_advanced.PruningType::Unstructured,
    threshold: 0.0,
    min_channels: 1,
  }
}

///|
test "compute_pruning_mask: 基本掩码" {
  let weights = [0.1, 0.0, 0.5, 0.0, 0.3]
  let mask = @cv_advanced.compute_pruning_mask(weights, 0.05)
  assert_true(mask.length() == 5)
  assert_true(mask[0])
  assert_true(!mask[1])
  assert_true(mask[2])
}

///|
test "prune_unstructured: 基本剪枝" {
  let weights = [0.1, 0.3, 0.5, 0.7, 0.2, 0.4, 0.6, 0.8]
  let config = make_pruning_config()
  let result = @cv_advanced.prune_unstructured(weights, config)
  assert_true(result.mask.length() == 8)
  assert_true(
    result.sparsity_achieved >= 0.0 && result.sparsity_achieved <= 1.0,
  )
  assert_true(result.original_size == 8)
}

///|
test "prune_unstructured: 阈值剪枝" {
  let weights = [0.1, 0.01, 0.5, 0.001, 0.3]
  let config : @cv_advanced.PruningConfig = {
    sparsity: 0.0,
    pruning_type: @cv_advanced.PruningType::Unstructured,
    threshold: 0.05,
    min_channels: 1,
  }
  let result = @cv_advanced.prune_unstructured(weights, config)
  assert_true(result.pruned_size < result.original_size)
}

///|
test "prune_structured: 块剪枝" {
  let weights = [0.1, 0.1, 0.5, 0.5, 0.2, 0.2, 0.8, 0.8]
  let config = make_pruning_config()
  let result = @cv_advanced.prune_structured(weights, 2, config)
  assert_true(result.mask.length() == 8)
  assert_true(result.sparsity_achieved >= 0.0)
}

///|
test "prune_channels: 通道剪枝" {
  let weights = [0.1, 0.1, 0.5, 0.5, 0.2, 0.2, 0.8, 0.8]
  let config = make_pruning_config()
  let result = @cv_advanced.prune_channels(weights, 4, config)
  assert_true(result.mask.length() == 8)
  assert_true(result.pruned_size <= result.original_size)
}

///|
test "apply_pruning_mask: 应用掩码" {
  let weights = [1.0, 2.0, 3.0, 4.0]
  let mask = [true, false, true, false]
  let result = @cv_advanced.apply_pruning_mask(weights, mask)
  assert_true(result[0] == 1.0)
  assert_true(result[1] == 0.0)
  assert_true(result[2] == 3.0)
  assert_true(result[3] == 0.0)
}

///|
test "compute_sparsity: 稀疏度计算" {
  let weights = [1.0, 0.0, 3.0, 0.0, 0.0]
  let sparsity = @cv_advanced.compute_sparsity(weights)
  assert_true(sparsity > 0.59 && sparsity < 0.61)
}

///|
test "compute_sparsity: 空数组" {
  let sparsity = @cv_advanced.compute_sparsity([])
  assert_true(sparsity == 0.0)
}

///|
test "PruningType: enum 值" {
  let p1 = @cv_advanced.PruningType::Unstructured
  let p2 = @cv_advanced.PruningType::Structured
  let p3 = @cv_advanced.PruningType::Channel
  let p4 = @cv_advanced.PruningType::Filter
  assert_true(p1 != p2)
  assert_true(p2 != p3)
  assert_true(p3 != p4)
}
