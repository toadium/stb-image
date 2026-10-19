// 知识蒸馏 — 教师-学生/特征蒸馏
// Knowledge distillation
//
// Phase 13 v336: 深度学习大扩展 — 知识蒸馏。

///|
/// 蒸馏类型。
/// Distillation type.
pub(all) enum DistillationType {
  ResponseBased
  FeatureBased
  RelationBased
} derive(Eq, @debug.Debug)

///|
pub extend DistillationType with @debug.Debug::{to_repr}

///|
pub extend DistillationType with Eq::{not_equal, equal}

///|
/// 蒸馏配置。
/// Distillation configuration.
pub(all) struct DistillationConfig {
  temperature : Double
  alpha : Double
  beta : Double
  distill_type : DistillationType
} derive(Eq, @debug.Debug)

///|
pub extend DistillationConfig with @debug.Debug::{to_repr}

///|
pub extend DistillationConfig with Eq::{not_equal, equal}

///|
/// 蒸馏结果。
/// Distillation result.
pub(all) struct DistillationResult {
  teacher_loss : Double
  student_loss : Double
  distill_loss : Double
  total_loss : Double
} derive(Eq, @debug.Debug)

///|
pub extend DistillationResult with @debug.Debug::{to_repr}

///|
pub extend DistillationResult with Eq::{not_equal, equal}

///|
/// 软目标（温度缩放 softmax）。
/// Soft targets (temperature-scaled softmax).
pub fn soft_targets(
  logits : Array[Double],
  temperature : Double,
) -> Array[Double] {
  if temperature <= 0.0 {
    return softmax(logits)
  }
  let scaled : Array[Double] = []
  for v in logits {
    scaled.push(v / temperature)
  }
  softmax(scaled)
}

///|
/// KL 散度。
/// KL divergence.
pub fn compute_kl_divergence(p : Array[Double], q : Array[Double]) -> Double {
  let n = p.length()
  let m = q.length()
  let len = if n < m { n } else { m }
  let mut kl = 0.0
  for i in 0..<len {
    if p[i] > 0.0 && q[i] > 0.0 {
      kl = kl + p[i] * (@math.log2(p[i] / q[i]) * 0.6931471805599453)
    }
  }
  kl
}

///|
/// 交叉熵损失。
/// Cross-entropy loss.
pub fn cross_entropy_loss(
  predictions : Array[Double],
  targets : Array[Double],
) -> Double {
  let n = predictions.length()
  let m = targets.length()
  let len = if n < m { n } else { m }
  let mut loss = 0.0
  for i in 0..<len {
    if targets[i] > 0.0 {
      let p = if predictions[i] > 0.0 { predictions[i] } else { 0.000000000001 }
      loss = loss - targets[i] * (@math.log2(p) * 0.6931471805599453)
    }
  }
  loss
}

///|
/// 响应式知识蒸馏。
/// Response-based knowledge distillation.
pub fn knowledge_distill(
  teacher_logits : Array[Double],
  student_logits : Array[Double],
  hard_targets : Array[Double],
  config : DistillationConfig,
) -> DistillationResult {
  let teacher_soft = soft_targets(teacher_logits, config.temperature)
  let student_soft = soft_targets(student_logits, config.temperature)
  let distill_loss = compute_kl_divergence(teacher_soft, student_soft) *
    config.temperature *
    config.temperature
  let student_loss = cross_entropy_loss(student_logits, hard_targets)
  let total = config.alpha * distill_loss + config.beta * student_loss
  DistillationResult::{
    teacher_loss: 0.0,
    student_loss,
    distill_loss,
    total_loss: total,
  }
}

///|
/// 特征蒸馏。
/// Feature-based distillation.
pub fn feature_distill(
  teacher_features : Array[Double],
  student_features : Array[Double],
  config : DistillationConfig,
) -> DistillationResult {
  let n = teacher_features.length()
  let m = student_features.length()
  let len = if n < m { n } else { m }
  let mut feature_loss = 0.0
  for i in 0..<len {
    let diff = teacher_features[i] - student_features[i]
    feature_loss = feature_loss + diff * diff
  }
  feature_loss = feature_loss / len.to_double()
  let teacher_soft = soft_targets(teacher_features, config.temperature)
  let student_soft = soft_targets(student_features, config.temperature)
  let response_loss = compute_kl_divergence(teacher_soft, student_soft)
  let total = config.alpha * feature_loss + config.beta * response_loss
  DistillationResult::{
    teacher_loss: 0.0,
    student_loss: feature_loss,
    distill_loss: response_loss,
    total_loss: total,
  }
}

///|
/// 关系蒸馏。
/// Relation-based distillation.
pub fn relation_distill(
  teacher_features : Array[Double],
  student_features : Array[Double],
  config : DistillationConfig,
) -> DistillationResult {
  let n = teacher_features.length()
  let m = student_features.length()
  let len = if n < m { n } else { m }
  let mut rel_loss = 0.0
  for i in 0..<len {
    for j in 0..<len {
      let t_rel = teacher_features[i] - teacher_features[j]
      let s_rel = student_features[i] - student_features[j]
      let diff = t_rel - s_rel
      rel_loss = rel_loss + diff * diff
    }
  }
  rel_loss = rel_loss / (len.to_double() * len.to_double())
  let total = config.alpha * rel_loss
  DistillationResult::{
    teacher_loss: 0.0,
    student_loss: 0.0,
    distill_loss: rel_loss,
    total_loss: total,
  }
}
