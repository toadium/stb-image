// 演化策略组合 — 组合多种演化策略
// Evolution strategy combination: combine multiple evolution strategies
//
// Phase 10 v307: 将演化从"自主决策"推向"策略组合" — 多策略协同演化。

///|
/// 策略类型。
/// Strategy kind.
pub(all) enum StrategyKind {
  FixFirst
  TestFirst
  OptimizeFirst
  ParallelFix
  SequentialFix
} derive(Eq, @debug.Debug)

///|
pub extend StrategyKind with @debug.Debug::{to_repr}

///|
pub extend StrategyKind with Eq::{not_equal, equal}

///|
/// 策略组合。
/// Strategy combination.
pub(all) struct StrategyCombo {
  strategies : Array[StrategyKind]
  op_tag : String
  estimated_time : Int32
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend StrategyCombo with @debug.Debug::{to_repr}

///|
pub extend StrategyCombo with Eq::{not_equal, equal}

///|
/// 策略组合报告。
/// Strategy combination report.
pub(all) struct ComboReport {
  combos : Array[StrategyCombo]
  total : Int32
  parallel_count : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend ComboReport with @debug.Debug::{to_repr}

///|
pub extend ComboReport with Eq::{not_equal, equal}

///|
/// 为单个算子组合演化策略。
/// Combine evolution strategies for a single op.
pub fn combine_strategies(op : @imgir.IROp) -> StrategyCombo {
  let tag = op.tag()
  let degs = detect_degradation(op)
  let strategies : Array[StrategyKind] = []
  let mut est_time = 0
  if degs.length() > 0 {
    strategies.push(FixFirst)
    est_time = est_time + 10
    if degs.length() > 1 {
      strategies.push(ParallelFix)
      est_time = est_time + 5
    } else {
      strategies.push(SequentialFix)
      est_time = est_time + 3
    }
  }
  let cov = coverage_percentage(op)
  if cov < 80 {
    strategies.push(TestFirst)
    est_time = est_time + 8
  }
  let score = score_op(op)
  if score.score > 50 {
    strategies.push(OptimizeFirst)
    est_time = est_time + 6
  }
  if strategies.length() == 0 {
    strategies.push(OptimizeFirst)
    est_time = 2
  }
  let desc = tag +
    ": " +
    strategies.length().to_string() +
    " 策略, 预计 " +
    est_time.to_string() +
    " 单位时间"
  { strategies, op_tag: tag, estimated_time: est_time, description: desc, }
}

///|
/// 为所有算子组合演化策略。
/// Combine evolution strategies for all ops.
pub fn combine_all_strategies() -> ComboReport {
  let combos : Array[StrategyCombo] = []
  let mut parallel_count = 0
  for op in all_ops() {
    let combo = combine_strategies(op)
    for s in combo.strategies {
      if s is ParallelFix {
        parallel_count = parallel_count + 1
      }
    }
    combos.push(combo)
  }
  let total = combos.length()
  let summary = "策略组合: " +
    total.to_string() +
    " 算子, " +
    parallel_count.to_string() +
    " 可并行"
  { combos, total, parallel_count, summary, }
}

///|
/// 策略组合报告是否有可并行策略。
/// Whether combo report has parallel strategies.
pub fn ComboReport::has_parallel(self : ComboReport) -> Bool {
  self.parallel_count > 0
}
