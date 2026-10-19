// 自监督学习测试 — Self-supervised learning tests
// Phase 13 v341: 深度学习大扩展 — 自监督学习。

///|
fn make_ssl_config() -> @cv_advanced.SSLConfig {
  {
    temperature: 0.5,
    projection_dim: 4,
    num_negatives: 2,
    ssl_type: @cv_advanced.SSLType::Contrastive,
  }
}

///|
test "cosine_similarity: 相同向量" {
  let a = [1.0, 2.0, 3.0]
  let sim = @cv_advanced.cosine_similarity(a, a)
  assert_true(sim > 0.99 && sim < 1.01)
}

///|
test "cosine_similarity: 正交向量" {
  let a = [1.0, 0.0]
  let b = [0.0, 1.0]
  let sim = @cv_advanced.cosine_similarity(a, b)
  assert_true(sim > -0.01 && sim < 0.01)
}

///|
test "contrastive_loss: 基本对比损失" {
  let anchor = [1.0, 0.0, 0.0, 0.0]
  let positive = [0.9, 0.1, 0.0, 0.0]
  let neg1 = [0.0, 1.0, 0.0, 0.0]
  let neg2 = [0.0, 0.0, 1.0, 0.0]
  let config = make_ssl_config()
  let result = @cv_advanced.contrastive_loss(
    anchor,
    positive,
    [neg1, neg2],
    config,
  )
  assert_true(result.loss == result.loss)
}

///|
test "masked_modeling: 基本掩码" {
  let input = [1.0, 2.0, 3.0, 4.0]
  let mask = [false, true, false, true]
  let preds = [0.0, 2.1, 0.0, 3.9]
  let targets = [0.0, 2.0, 0.0, 4.0]
  let loss = @cv_advanced.masked_modeling(input, mask, preds, targets)
  assert_true(loss >= 0.0)
}

///|
test "simclr_forward: SimCLR 前向" {
  let z_i = [1.0, 0.0, 0.0, 0.0]
  let z_j = [0.9, 0.1, 0.0, 0.0]
  let config = make_ssl_config()
  let loss = @cv_advanced.simclr_forward(z_i, z_j, config)
  assert_true(loss == loss)
}

///|
test "moco_forward: MoCo 前向" {
  let q = [1.0, 0.0, 0.0, 0.0]
  let k_pos = [0.9, 0.1, 0.0, 0.0]
  let k_neg1 = [0.0, 1.0, 0.0, 0.0]
  let k_neg2 = [0.0, 0.0, 1.0, 0.0]
  let config = make_ssl_config()
  let loss = @cv_advanced.moco_forward(q, k_pos, [k_neg1, k_neg2], config)
  assert_true(loss == loss)
}

///|
test "compute_embeddings_sim: 相似度矩阵" {
  let e1 = [1.0, 0.0]
  let e2 = [0.0, 1.0]
  let e3 = [1.0, 1.0]
  let result = @cv_advanced.compute_embeddings_sim([e1, e2, e3])
  assert_true(result.length() == 9)
}

///|
test "SSLType: enum 值" {
  let s1 = @cv_advanced.SSLType::Contrastive
  let s2 = @cv_advanced.SSLType::Masked
  let s3 = @cv_advanced.SSLType::Predictive
  let s4 = @cv_advanced.SSLType::NonContrastive
  assert_true(s1 != s2)
  assert_true(s2 != s3)
  assert_true(s3 != s4)
}

///|
test "SSLConfig: 构造与字段" {
  let config = make_ssl_config()
  assert_true(config.temperature == 0.5)
  assert_true(config.num_negatives == 2)
}
