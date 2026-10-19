// 自监督学习 — 对比学习/掩码学习
// Self-supervised learning
//
// Phase 13 v341: 深度学习大扩展 — 自监督学习。

///|
/// SSL 类型。
/// SSL type.
pub(all) enum SSLType {
  Contrastive
  Masked
  Predictive
  NonContrastive
} derive(Eq, @debug.Debug)

///|
pub extend SSLType with @debug.Debug::{to_repr}

///|
pub extend SSLType with Eq::{not_equal, equal}

///|
/// SSL 配置。
/// SSL configuration.
pub(all) struct SSLConfig {
  temperature : Double
  projection_dim : Int
  num_negatives : Int
  ssl_type : SSLType
} derive(Eq, @debug.Debug)

///|
pub extend SSLConfig with @debug.Debug::{to_repr}

///|
pub extend SSLConfig with Eq::{not_equal, equal}

///|
/// SSL 结果。
/// SSL result.
pub(all) struct SSLResult {
  loss : Double
  embeddings : Array[Double]
  positive_sim : Double
  negative_sim : Double
} derive(Eq, @debug.Debug)

///|
pub extend SSLResult with @debug.Debug::{to_repr}

///|
pub extend SSLResult with Eq::{not_equal, equal}

///|
/// 计算余弦相似度。
/// Compute cosine similarity.
pub fn cosine_similarity(a : Array[Double], b : Array[Double]) -> Double {
  let n = a.length()
  let m = b.length()
  let len = if n < m { n } else { m }
  let mut dot = 0.0
  let mut norm_a = 0.0
  let mut norm_b = 0.0
  for i in 0..<len {
    dot = dot + a[i] * b[i]
    norm_a = norm_a + a[i] * a[i]
    norm_b = norm_b + b[i] * b[i]
  }
  let denom = norm_a.sqrt() * norm_b.sqrt()
  if denom > 0.0 {
    dot / denom
  } else {
    0.0
  }
}

///|
/// 对比损失（InfoNCE）。
/// Contrastive loss (InfoNCE).
pub fn contrastive_loss(
  anchor : Array[Double],
  positive : Array[Double],
  negatives : Array[Array[Double]],
  config : SSLConfig,
) -> SSLResult {
  let pos_sim = cosine_similarity(anchor, positive) / config.temperature
  let pos_exp = @math.exp(pos_sim)
  let mut neg_sum = 0.0
  let mut neg_sim_sum = 0.0
  let neg_count = negatives.length()
  for i in 0..<neg_count {
    let neg_sim = cosine_similarity(anchor, negatives[i]) / config.temperature
    neg_sum = neg_sum + @math.exp(neg_sim)
    neg_sim_sum = neg_sim_sum + cosine_similarity(anchor, negatives[i])
  }
  let denominator = pos_exp + neg_sum
  let loss = if denominator > 0.0 {
    -(@math.log2(pos_exp / denominator) * 0.6931471805599453)
  } else {
    0.0
  }
  let avg_neg_sim = if neg_count > 0 {
    neg_sim_sum / neg_count.to_double()
  } else {
    0.0
  }
  let embeddings : Array[Double] = []
  for v in anchor {
    embeddings.push(v)
  }
  SSLResult::{
    loss,
    embeddings,
    positive_sim: cosine_similarity(anchor, positive),
    negative_sim: avg_neg_sim,
  }
}

///|
/// 掩码建模。
/// Masked modeling.
pub fn masked_modeling(
  input : Array[Double],
  mask : Array[Bool],
  predictions : Array[Double],
  targets : Array[Double],
) -> Double {
  let _ = input
  let n = mask.length()
  let mut loss = 0.0
  let mut count = 0
  for i in 0..<n {
    if mask[i] {
      let pred = if i < predictions.length() { predictions[i] } else { 0.0 }
      let target = if i < targets.length() { targets[i] } else { 0.0 }
      let diff = pred - target
      loss = loss + diff * diff
      count = count + 1
    }
  }
  if count > 0 {
    loss / count.to_double()
  } else {
    0.0
  }
}

///|
/// SimCLR 前向传播。
/// SimCLR forward pass.
pub fn simclr_forward(
  z_i : Array[Double],
  z_j : Array[Double],
  config : SSLConfig,
) -> Double {
  let sim = cosine_similarity(z_i, z_j) / config.temperature
  -sim + @math.log2(2.0) * 0.6931471805599453
}

///|
/// MoCo 前向传播。
/// MoCo forward pass.
pub fn moco_forward(
  q : Array[Double],
  k_pos : Array[Double],
  k_neg_queue : Array[Array[Double]],
  config : SSLConfig,
) -> Double {
  let pos_logit = @math.exp(cosine_similarity(q, k_pos) / config.temperature)
  let mut neg_logits = 0.0
  for neg in k_neg_queue {
    neg_logits = neg_logits +
      @math.exp(cosine_similarity(q, neg) / config.temperature)
  }
  let denominator = pos_logit + neg_logits
  if denominator > 0.0 {
    -(@math.log2(pos_logit / denominator) * 0.6931471805599453)
  } else {
    0.0
  }
}

///|
/// 计算嵌入相似度矩阵。
/// Compute embedding similarity matrix.
pub fn compute_embeddings_sim(
  embeddings : Array[Array[Double]],
) -> Array[Double] {
  let n = embeddings.length()
  let result : Array[Double] = []
  for i in 0..<n {
    for j in 0..<n {
      result.push(cosine_similarity(embeddings[i], embeddings[j]))
    }
  }
  result
}
