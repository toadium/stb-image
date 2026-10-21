// 元学习测试 — Meta-learning tests
// Phase 13 v342: 深度学习大扩展 — 元学习。

///|
fn make_meta_config() -> @cv_advanced.MetaLearningConfig {
  {
    inner_lr: 0.01,
    meta_lr: 0.001,
    num_inner_steps: 5,
    num_support: 5,
    num_query: 15,
    ml_type: @cv_advanced.MetaLearningType::MAML,
  }
}

///|
test "maml_inner_update: 内循环更新" {
  let params = [1.0, 2.0, 3.0]
  let grads = [0.1, 0.2, 0.3]
  let config = make_meta_config()
  let result = @cv_advanced.maml_inner_update(params, grads, config)
  assert_true(result.length() == 3)
  assert_true(result[0] < params[0])
}

///|
test "maml_meta_update: 外循环更新" {
  let meta_params = [1.0, 2.0, 3.0]
  let g1 = [0.1, 0.2, 0.3]
  let g2 = [0.2, 0.1, 0.2]
  let config = make_meta_config()
  let result = @cv_advanced.maml_meta_update(meta_params, [g1, g2], config)
  assert_true(result.length() == 3)
}

///|
test "reptile_update: Reptile 更新" {
  let meta = [1.0, 2.0, 3.0]
  let adapted = [1.1, 2.1, 2.9]
  let config = make_meta_config()
  let result = @cv_advanced.reptile_update(meta, adapted, config)
  assert_true(result.length() == 3)
  assert_true(result[0] > meta[0])
}

///|
test "compute_prototypes: 计算原型" {
  let features = [[1.0, 2.0], [1.5, 2.5], [5.0, 6.0], [5.5, 6.5]]
  let labels = [0, 0, 1, 1]
  let protos = @cv_advanced.compute_prototypes(features, labels, 2)
  assert_true(protos.length() == 2)
  assert_true(protos[0].length() == 2)
}

///|
test "prototypical_loss: 原型损失" {
  let query = [1.2, 2.3]
  let protos = [[1.0, 2.0], [5.0, 6.0]]
  let (cls, dist) = @cv_advanced.prototypical_loss(query, protos)
  assert_true(cls == 0)
  assert_true(dist >= 0.0)
}

///|
test "meta_train_step: 训练步" {
  let meta = [1.0, 2.0, 3.0]
  let s_grad = [0.1, 0.2, 0.3]
  let q_grad = [0.2, 0.1, 0.2]
  let config = make_meta_config()
  let result = @cv_advanced.meta_train_step(meta, s_grad, q_grad, config)
  assert_true(result.adapted_params.length() == 3)
  assert_true(result.meta_loss >= 0.0)
}

///|
test "MetaLearningType: enum 值" {
  let m1 = @cv_advanced.MetaLearningType::MAML
  let m2 = @cv_advanced.MetaLearningType::Reptile
  let m3 = @cv_advanced.MetaLearningType::Prototypical
  let m4 = @cv_advanced.MetaLearningType::ANIL
  assert_true(m1 != m2)
  assert_true(m2 != m3)
  assert_true(m3 != m4)
}

///|
test "MetaLearningConfig: 构造与字段" {
  let config = make_meta_config()
  assert_true(config.inner_lr == 0.01)
  assert_true(config.num_inner_steps == 5)
}

///|
test "MetaLearningResult: 构造" {
  let result : @cv_advanced.MetaLearningResult = {
    meta_loss: 0.5,
    adapted_params: [1.0, 2.0],
    support_loss: 0.2,
    query_loss: 0.3,
  }
  assert_true(result.meta_loss == 0.5)
  assert_true(result.support_loss == 0.2)
}
