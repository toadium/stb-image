// AutoML 测试 — AutoML tests
// Phase 13 v344: 深度学习大扩展 — AutoML 扩展。

///|
fn make_automl_config() -> @cv_advanced.AutoMLConfig {
  {
    max_trials: 5,
    budget: 100,
    automl_type: @cv_advanced.AutoMLType::RandomSearch,
    minimize: true,
  }
}

///|
fn dummy_objective(params : Array[Double]) -> Double {
  let mut sum = 0.0
  for p in params {
    sum = sum + (p - 0.5) * (p - 0.5)
  }
  sum
}

///|
test "random_search: 基本随机搜索" {
  let config = make_automl_config()
  let space : Array[(Double, Double)] = [(0.0, 1.0), (0.0, 1.0)]
  let result = @cv_advanced.random_search(dummy_objective, space, config)
  assert_true(result.total_trials == 5)
  assert_true(result.best_params.length() == 2)
}

///|
test "bayesian_optimize: 贝叶斯优化" {
  let config = make_automl_config()
  let space : Array[(Double, Double)] = [(0.0, 1.0), (0.0, 1.0)]
  let result = @cv_advanced.bayesian_optimize(dummy_objective, space, config, 2)
  assert_true(result.total_trials == 5)
  assert_true(result.best_params.length() == 2)
}

///|
test "nas_search: NAS 搜索" {
  let config = make_automl_config()
  let result = @cv_advanced.nas_search(dummy_objective, 3, 32, config)
  assert_true(result.total_trials == 5)
  assert_true(result.best_params.length() >= 1)
}

///|
test "ensemble_select: 集成选择" {
  let m1 : @cv_advanced.TrialResult = {
    params: [1.0],
    score: 0.8,
    trial_id: 0,
  }
  let m2 : @cv_advanced.TrialResult = {
    params: [2.0],
    score: 0.9,
    trial_id: 1,
  }
  let m3 : @cv_advanced.TrialResult = {
    params: [3.0],
    score: 0.7,
    trial_id: 2,
  }
  let result = @cv_advanced.ensemble_select([m1, m2, m3], 2)
  assert_true(result.length() == 2)
  assert_true(result[0].score >= result[1].score)
}

///|
test "AutoMLType: enum 值" {
  let a1 = @cv_advanced.AutoMLType::NAS
  let a2 = @cv_advanced.AutoMLType::HPO
  let a3 = @cv_advanced.AutoMLType::RandomSearch
  let a4 = @cv_advanced.AutoMLType::BayesianOpt
  assert_true(a1 != a2)
  assert_true(a2 != a3)
  assert_true(a3 != a4)
}

///|
test "AutoMLConfig: 构造与字段" {
  let config = make_automl_config()
  assert_true(config.max_trials == 5)
  assert_true(config.minimize)
}

///|
test "TrialResult: 构造" {
  let t : @cv_advanced.TrialResult = {
    params: [1.0, 2.0],
    score: 0.5,
    trial_id: 3,
  }
  assert_true(t.trial_id == 3)
  assert_true(t.score == 0.5)
}

///|
test "AutoMLResult: 构造" {
  let r : @cv_advanced.AutoMLResult = {
    best_params: [1.0],
    best_score: 0.1,
    total_trials: 10,
  }
  assert_true(r.total_trials == 10)
  assert_true(r.best_score == 0.1)
}

///|
test "random_search: 单维搜索" {
  let config : @cv_advanced.AutoMLConfig = {
    max_trials: 3,
    budget: 50,
    automl_type: @cv_advanced.AutoMLType::RandomSearch,
    minimize: false,
  }
  let space : Array[(Double, Double)] = [(-1.0, 1.0)]
  let result = @cv_advanced.random_search(dummy_objective, space, config)
  assert_true(result.total_trials == 3)
  assert_true(result.best_params.length() == 1)
}
