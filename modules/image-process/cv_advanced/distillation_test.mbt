// 知识蒸馏测试 — Knowledge distillation tests
// Phase 13 v336: 深度学习大扩展 — 知识蒸馏。

///|
fn make_distill_config() -> @cv_advanced.DistillationConfig {
  {
    temperature: 2.0,
    alpha: 0.7,
    beta: 0.3,
    distill_type: @cv_advanced.DistillationType::ResponseBased,
  }
}

///|
test "soft_targets: 基本软目标" {
  let logits = [1.0, 2.0, 3.0]
  let result = @cv_advanced.soft_targets(logits, 2.0)
  let mut sum = 0.0
  for v in result {
    sum = sum + v
  }
  assert_true(sum > 0.99 && sum < 1.01)
  assert_true(result.length() == 3)
}

///|
test "soft_targets: 零温度" {
  let logits = [1.0, 2.0, 3.0]
  let result = @cv_advanced.soft_targets(logits, 0.0)
  assert_true(result.length() == 3)
}

///|
test "compute_kl_divergence: 相同分布" {
  let p = [0.5, 0.5]
  let kl = @cv_advanced.compute_kl_divergence(p, p)
  assert_true(kl >= -0.0001 && kl < 0.0001)
}

///|
test "compute_kl_divergence: 不同分布" {
  let p = [0.9, 0.1]
  let q = [0.5, 0.5]
  let kl = @cv_advanced.compute_kl_divergence(p, q)
  assert_true(kl > 0.0)
}

///|
test "knowledge_distill: 基本蒸馏" {
  let teacher = [2.0, 1.0, 0.5, 0.1]
  let student = [1.5, 1.2, 0.8, 0.2]
  let hard = [1.0, 0.0, 0.0, 0.0]
  let config = make_distill_config()
  let result = @cv_advanced.knowledge_distill(teacher, student, hard, config)
  assert_true(result.total_loss == result.total_loss)
}

///|
test "feature_distill: 特征蒸馏" {
  let teacher = [1.0, 2.0, 3.0, 4.0]
  let student = [0.9, 2.1, 2.9, 4.1]
  let config = make_distill_config()
  let result = @cv_advanced.feature_distill(teacher, student, config)
  assert_true(result.total_loss >= 0.0)
}

///|
test "relation_distill: 关系蒸馏" {
  let teacher = [1.0, 2.0, 3.0]
  let student = [1.1, 2.1, 2.9]
  let config = make_distill_config()
  let result = @cv_advanced.relation_distill(teacher, student, config)
  assert_true(result.total_loss >= 0.0)
}

///|
test "DistillationType: enum 值" {
  let d1 = @cv_advanced.DistillationType::ResponseBased
  let d2 = @cv_advanced.DistillationType::FeatureBased
  let d3 = @cv_advanced.DistillationType::RelationBased
  assert_true(d1 != d2)
  assert_true(d2 != d3)
}

///|
test "cross_entropy_loss: 基本交叉熵" {
  let pred = [0.7, 0.2, 0.1]
  let target = [1.0, 0.0, 0.0]
  let loss = @cv_advanced.cross_entropy_loss(pred, target)
  assert_true(loss > 0.0)
}
