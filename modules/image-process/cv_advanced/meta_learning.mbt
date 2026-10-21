// 元学习 — MAML/Reptile/Prototypical
// Meta-learning
//
// Phase 13 v342: 深度学习大扩展 — 元学习。

///|
/// 元学习类型。
/// Meta-learning type.
pub(all) enum MetaLearningType {
  MAML
  Reptile
  Prototypical
  ANIL
} derive(Eq, @debug.Debug)

///|
pub extend MetaLearningType with @debug.Debug::{to_repr}

///|
pub extend MetaLearningType with Eq::{not_equal, equal}

///|
/// 元学习配置。
/// Meta-learning configuration.
pub(all) struct MetaLearningConfig {
  inner_lr : Double
  meta_lr : Double
  num_inner_steps : Int32
  num_support : Int32
  num_query : Int32
  ml_type : MetaLearningType
} derive(Eq, @debug.Debug)

///|
pub extend MetaLearningConfig with @debug.Debug::{to_repr}

///|
pub extend MetaLearningConfig with Eq::{not_equal, equal}

///|
/// 元学习结果。
/// Meta-learning result.
pub(all) struct MetaLearningResult {
  meta_loss : Double
  adapted_params : Array[Double]
  support_loss : Double
  query_loss : Double
} derive(Eq, @debug.Debug)

///|
pub extend MetaLearningResult with @debug.Debug::{to_repr}

///|
pub extend MetaLearningResult with Eq::{not_equal, equal}

///|
/// MAML 内循环更新。
/// MAML inner loop update.
pub fn maml_inner_update(
  params : Array[Double],
  gradients : Array[Double],
  config : MetaLearningConfig,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = params.length()
  let m = gradients.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    result.push(params[i] - config.inner_lr * gradients[i])
  }
  for i in len..<n {
    result.push(params[i])
  }
  result
}

///|
/// MAML 外循环更新。
/// MAML outer loop update.
pub fn maml_meta_update(
  meta_params : Array[Double],
  task_gradients : Array[Array[Double]],
  config : MetaLearningConfig,
) -> Array[Double] {
  let n = meta_params.length()
  let num_tasks = task_gradients.length()
  let result : Array[Double] = []
  for i in 0..<n {
    let mut grad_sum = 0.0
    for t in 0..<num_tasks {
      let task_grad = task_gradients[t]
      if i < task_grad.length() {
        grad_sum = grad_sum + task_grad[i]
      }
    }
    let avg_grad = if num_tasks > 0 {
      grad_sum / num_tasks.to_double()
    } else {
      0.0
    }
    result.push(meta_params[i] - config.meta_lr * avg_grad)
  }
  result
}

///|
/// Reptile 更新。
/// Reptile update.
pub fn reptile_update(
  meta_params : Array[Double],
  adapted_params : Array[Double],
  config : MetaLearningConfig,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = meta_params.length()
  let m = adapted_params.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let diff = adapted_params[i] - meta_params[i]
    result.push(meta_params[i] + config.meta_lr * diff)
  }
  for i in len..<n {
    result.push(meta_params[i])
  }
  result
}

///|
/// 计算原型。
/// Compute prototypes.
pub fn compute_prototypes(
  support_features : Array[Array[Double]],
  support_labels : Array[Int32],
  num_classes : Int32,
) -> Array[Array[Double]] {
  let prototypes : Array[Array[Double]] = []
  let feature_dim = if support_features.length() > 0 {
    support_features[0].length()
  } else {
    0
  }
  for c in 0..<num_classes {
    let proto : Array[Double] = []
    for f in 0..<feature_dim {
      let mut sum = 0.0
      let mut count = 0
      for i in 0..<support_features.length() {
        if i < support_labels.length() && support_labels[i] == c {
          if f < support_features[i].length() {
            sum = sum + support_features[i][f]
          }
          count = count + 1
        }
      }
      proto.push(if count > 0 { sum / count.to_double() } else { 0.0 })
    }
    prototypes.push(proto)
  }
  prototypes
}

///|
/// 原型网络损失。
/// Prototypical network loss.
pub fn prototypical_loss(
  query_features : Array[Double],
  prototypes : Array[Array[Double]],
) -> (Int32, Double) {
  let mut best_class = 0
  let mut best_dist = 1.7976931348623157e308
  for c in 0..<prototypes.length() {
    let proto = prototypes[c]
    let mut dist = 0.0
    let n = query_features.length()
    let m = proto.length()
    let len = if n < m { n } else { m }
    for f in 0..<len {
      let diff = query_features[f] - proto[f]
      dist = dist + diff * diff
    }
    if dist < best_dist {
      best_dist = dist
      best_class = c
    }
  }
  (best_class, best_dist)
}

///|
/// 元学习训练步。
/// Meta-learning training step.
pub fn meta_train_step(
  meta_params : Array[Double],
  support_gradients : Array[Double],
  query_gradients : Array[Double],
  config : MetaLearningConfig,
) -> MetaLearningResult {
  let adapted = maml_inner_update(meta_params, support_gradients, config)
  let support_loss = compute_gradient_norm(support_gradients)
  let query_loss = compute_gradient_norm(query_gradients)
  let meta_loss = support_loss + query_loss
  MetaLearningResult::{
    meta_loss,
    adapted_params: adapted,
    support_loss,
    query_loss,
  }
}

///|
fn compute_gradient_norm(gradients : Array[Double]) -> Double {
  let mut sum = 0.0
  for g in gradients {
    sum = sum + g * g
  }
  sum.sqrt()
}
