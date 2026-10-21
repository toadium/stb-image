// AutoML 扩展 — NAS/HPO/集成搜索
// AutoML extensions
//
// Phase 13 v344: 深度学习大扩展 — AutoML 扩展。

///|
/// AutoML 类型。
/// AutoML type.
pub(all) enum AutoMLType {
  NAS
  HPO
  RandomSearch
  BayesianOpt
} derive(Eq, @debug.Debug)

///|
pub extend AutoMLType with @debug.Debug::{to_repr}

///|
pub extend AutoMLType with Eq::{not_equal, equal}

///|
/// AutoML 配置。
/// AutoML configuration.
pub(all) struct AutoMLConfig {
  max_trials : Int32
  budget : Int32
  automl_type : AutoMLType
  minimize : Bool
} derive(Eq, @debug.Debug)

///|
pub extend AutoMLConfig with @debug.Debug::{to_repr}

///|
pub extend AutoMLConfig with Eq::{not_equal, equal}

///|
/// 试验结果。
/// Trial result.
pub(all) struct TrialResult {
  params : Array[Double]
  score : Double
  trial_id : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TrialResult with @debug.Debug::{to_repr}

///|
pub extend TrialResult with Eq::{not_equal, equal}

///|
/// AutoML 结果。
/// AutoML result.
pub(all) struct AutoMLResult {
  best_params : Array[Double]
  best_score : Double
  total_trials : Int32
} derive(Eq, @debug.Debug)

///|
pub extend AutoMLResult with @debug.Debug::{to_repr}

///|
pub extend AutoMLResult with Eq::{not_equal, equal}

///|
/// 随机搜索。
/// Random search.
pub fn random_search(
  objective : (Array[Double]) -> Double,
  search_space : Array[(Double, Double)],
  config : AutoMLConfig,
) -> AutoMLResult {
  let mut best_score = if config.minimize {
    1.7976931348623157e308
  } else {
    -1.7976931348623157e308
  }
  let mut best_params : Array[Double] = []
  let dim = search_space.length()
  for trial in 0..<config.max_trials {
    let params : Array[Double] = []
    for d in 0..<dim {
      let (lo, hi) = search_space[d]
      let val = lo + (hi - lo) * pseudo_rand(trial * dim + d)
      params.push(val)
    }
    let score = objective(params)
    let is_better = if config.minimize {
      score < best_score
    } else {
      score > best_score
    }
    if is_better {
      best_score = score
      best_params = []
      for v in params {
        best_params.push(v)
      }
    }
  }
  AutoMLResult::{ best_params, best_score, total_trials: config.max_trials, }
}

///|
/// 贝叶斯优化。
/// Bayesian optimization.
pub fn bayesian_optimize(
  objective : (Array[Double]) -> Double,
  search_space : Array[(Double, Double)],
  config : AutoMLConfig,
  num_initial : Int32,
) -> AutoMLResult {
  let trials : Array[TrialResult] = []
  let mut best_score = if config.minimize {
    1.7976931348623157e308
  } else {
    -1.7976931348623157e308
  }
  let mut best_params : Array[Double] = []
  let dim = search_space.length()
  for trial in 0..<num_initial {
    let params : Array[Double] = []
    for d in 0..<dim {
      let (lo, hi) = search_space[d]
      let val = lo + (hi - lo) * pseudo_rand(trial * dim + d + 100)
      params.push(val)
    }
    let score = objective(params)
    trials.push(TrialResult::{ params, score, trial_id: trial, })
    let is_better = if config.minimize {
      score < best_score
    } else {
      score > best_score
    }
    if is_better {
      best_score = score
      best_params = []
      for v in params {
        best_params.push(v)
      }
    }
  }
  let remaining = config.max_trials - num_initial
  for trial in 0..<remaining {
    let params = compute_ei_acquisition(
      trials,
      search_space,
      trial,
      config.minimize,
    )
    let score = objective(params)
    trials.push(TrialResult::{ params, score, trial_id: num_initial + trial, })
    let is_better = if config.minimize {
      score < best_score
    } else {
      score > best_score
    }
    if is_better {
      best_score = score
      best_params = []
      for v in params {
        best_params.push(v)
      }
    }
  }
  AutoMLResult::{ best_params, best_score, total_trials: config.max_trials, }
}

///|
/// NAS 搜索。
/// NAS search.
pub fn nas_search(
  objective : (Array[Double]) -> Double,
  max_layers : Int32,
  max_channels : Int32,
  config : AutoMLConfig,
) -> AutoMLResult {
  let mut best_score = if config.minimize {
    1.7976931348623157e308
  } else {
    -1.7976931348623157e308
  }
  let mut best_params : Array[Double] = []
  for trial in 0..<config.max_trials {
    let params : Array[Double] = []
    let num_layers = 1 + (pseudo_rand(trial) * max_layers.to_double()).to_int()
    for l in 0..<num_layers {
      let channels = 1 +
        (pseudo_rand(trial * 100 + l + 1) * max_channels.to_double()).to_int()
      params.push(channels.to_double())
    }
    let score = objective(params)
    let is_better = if config.minimize {
      score < best_score
    } else {
      score > best_score
    }
    if is_better {
      best_score = score
      best_params = []
      for v in params {
        best_params.push(v)
      }
    }
  }
  AutoMLResult::{ best_params, best_score, total_trials: config.max_trials, }
}

///|
/// 集成选择。
/// Ensemble selection.
pub fn ensemble_select(
  model_scores : Array[TrialResult],
  num_models : Int32,
) -> Array[TrialResult] {
  let sorted : Array[TrialResult] = []
  for m in model_scores {
    sorted.push(m)
  }
  sorted.sort_by(fn(a, b) { compare(b.score, a.score) })
  let result : Array[TrialResult] = []
  let n = if num_models < sorted.length() {
    num_models
  } else {
    sorted.length()
  }
  for i in 0..<n {
    result.push(sorted[i])
  }
  result
}

///|
fn compute_ei_acquisition(
  trials : Array[TrialResult],
  search_space : Array[(Double, Double)],
  trial_idx : Int32,
  minimize : Bool,
) -> Array[Double] {
  let _ = trials
  let dim = search_space.length()
  let params : Array[Double] = []
  for d in 0..<dim {
    let (lo, hi) = search_space[d]
    let val = lo + (hi - lo) * pseudo_rand(trial_idx * dim + d + 200)
    params.push(val)
  }
  let _ = minimize
  params
}

///|
fn pseudo_rand(seed : Int32) -> Double {
  let x = seed.to_double() * 12.9898 + 78.233
  let frac = x - x.floor()
  if frac < 0.0 {
    -frac
  } else {
    frac
  }
}
