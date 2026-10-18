// 自适应参数调优 — 根据历史自动调优参数
// Adaptive parameter tuning: auto-tune parameters based on history
//
// Phase 10 v308: 将演化从"策略组合"推向"参数调优" — 根据历史数据自动调整参数。

///|
/// 参数类型。
/// Parameter kind.
pub(all) enum ParamKind {
  Threshold
  Weight
  StepSize
  MaxIter
} derive(Eq, @debug.Debug)

///|
pub extend ParamKind with @debug.Debug::{to_repr}

///|
pub extend ParamKind with Eq::{not_equal, equal}

///|
/// 单个调优参数。
/// Single tuned parameter.
pub(all) struct TunedParam {
  param_kind : ParamKind
  old_value : Int
  new_value : Int
  adjustment : Int
  rationale : String
} derive(Eq, @debug.Debug)

///|
pub extend TunedParam with @debug.Debug::{to_repr}

///|
pub extend TunedParam with Eq::{not_equal, equal}

///|
/// 参数调优报告。
/// Parameter tuning report.
pub(all) struct TuneReport {
  params : Array[TunedParam]
  total : Int
  adjusted_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend TuneReport with @debug.Debug::{to_repr}

///|
pub extend TuneReport with Eq::{not_equal, equal}

///|
/// 为单个算子调优参数。
/// Tune parameters for a single op.
pub fn tune_params(op : @imgir.IROp) -> Array[TunedParam] {
  let tag = op.tag()
  let params : Array[TunedParam] = []
  let degs = detect_degradation(op)
  let cov = coverage_percentage(op)
  let score = score_op(op)
  let old_threshold = 50
  let new_threshold = if cov < 50 {
    30
  } else if cov > 80 {
    60
  } else {
    old_threshold
  }
  if new_threshold != old_threshold {
    params.push({
      param_kind: Threshold,
      old_value: old_threshold,
      new_value: new_threshold,
      adjustment: new_threshold - old_threshold,
      rationale: tag + " 覆盖 " + cov.to_string() + "%, 调整阈值",
    })
  }
  let old_weight = 10
  let new_weight = if degs.length() > 0 {
    old_weight + degs.length() * 2
  } else {
    old_weight
  }
  if new_weight != old_weight {
    params.push({
      param_kind: Weight,
      old_value: old_weight,
      new_value: new_weight,
      adjustment: new_weight - old_weight,
      rationale: tag +
      " 退化 " +
      degs.length().to_string() +
      " 个, 调整权重",
    })
  }
  let old_step = 1
  let new_step = if score.score > 70 { 2 } else { old_step }
  if new_step != old_step {
    params.push({
      param_kind: StepSize,
      old_value: old_step,
      new_value: new_step,
      adjustment: new_step - old_step,
      rationale: tag + " 评分 " + score.score.to_string() + ", 加大步长",
    })
  }
  let old_max_iter = 100
  let new_max_iter = if degs.length() > 1 { 200 } else { old_max_iter }
  if new_max_iter != old_max_iter {
    params.push({
      param_kind: MaxIter,
      old_value: old_max_iter,
      new_value: new_max_iter,
      adjustment: new_max_iter - old_max_iter,
      rationale: tag + " 多退化, 增加最大迭代",
    })
  }
  params
}

///|
/// 为所有算子调优参数。
/// Tune parameters for all ops.
pub fn tune_all_params() -> TuneReport {
  let params : Array[TunedParam] = []
  for op in all_ops() {
    for p in tune_params(op) {
      params.push(p)
    }
  }
  let total = params.length()
  let mut adjusted = 0
  for p in params {
    if p.adjustment != 0 {
      adjusted = adjusted + 1
    }
  }
  let summary = "参数调优: " +
    total.to_string() +
    " 参数, " +
    adjusted.to_string() +
    " 已调整"
  { params, total, adjusted_count: adjusted, summary, }
}

///|
/// 调优报告是否有参数调整。
/// Whether tune report has adjustments.
pub fn TuneReport::has_adjustments(self : TuneReport) -> Bool {
  self.adjusted_count > 0
}
