// 自演化 Meta — 元演化（演化演化本身）
// Meta evolution: evolve the evolution process itself
//
// Phase 11 v314: 将演化从"质量评估"推向"元演化" — 演化演化本身。

///|
/// 元演化策略。
/// Meta evolution strategy.
pub(all) enum MetaStrategy {
  TightenThresholds // 收紧阈值
  LoosenThresholds // 放宽阈值
  AddTestCategory // 增加测试类别
  RemoveRedundancy // 消除冗余
  IncreaseCoverage // 提升覆盖
} derive(Eq, @debug.Debug)

///|
pub extend MetaStrategy with @debug.Debug::{to_repr}

///|
pub extend MetaStrategy with Eq::{not_equal, equal}

///|
/// 元演化动作。
/// Meta evolution action.
pub(all) struct MetaAction {
  strategy : MetaStrategy
  target_param : String
  current_value : Int32
  new_value : Int32
  rationale : String
} derive(Eq, @debug.Debug)

///|
pub extend MetaAction with @debug.Debug::{to_repr}

///|
pub extend MetaAction with Eq::{not_equal, equal}

///|
/// 元演化报告。
/// Meta evolution report.
pub(all) struct MetaReport {
  actions : Array[MetaAction]
  total_strategies : Int32
  applied_count : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend MetaReport with @debug.Debug::{to_repr}

///|
pub extend MetaReport with Eq::{not_equal, equal}

///|
/// 对单个算子进行元演化。
/// Perform meta evolution for a single op.
pub fn meta_evolve_op(op : @imgir.IROp) -> MetaReport {
  let tag = op.tag()
  let quality = eval_quality_op(op)
  let actions : Array[MetaAction] = []
  for qs in quality.scores {
    match qs.dimension {
      TestCoverage =>
        if qs.score < 80 {
          actions.push({
            strategy: IncreaseCoverage,
            target_param: "coverage_threshold",
            current_value: 80,
            new_value: 70,
            rationale: tag +
            " 覆盖 " +
            qs.score.to_string() +
            "% → 降低阈值加速演化",
          })
        }
      DegradationRate =>
        if qs.score < 100 {
          actions.push({
            strategy: TightenThresholds,
            target_param: "degradation_tolerance",
            current_value: 3,
            new_value: 2,
            rationale: tag +
            " 退化评分 " +
            qs.score.to_string() +
            " → 收紧容忍",
          })
        }
      PerformanceGain =>
        if qs.score > 80 {
          actions.push({
            strategy: RemoveRedundancy,
            target_param: "redundant_tests",
            current_value: 5,
            new_value: 3,
            rationale: tag +
            " 评分 " +
            qs.score.to_string() +
            " → 消除冗余测试",
          })
        }
      CodeStability =>
        if qs.score < 70 {
          actions.push({
            strategy: AddTestCategory,
            target_param: "test_categories",
            current_value: 3,
            new_value: 4,
            rationale: tag +
            " 稳定性 " +
            qs.score.to_string() +
            " → 增加边界测试",
          })
        }
      ApiCompatibility =>
        if quality.overall_score > 90 {
          actions.push({
            strategy: LoosenThresholds,
            target_param: "evolve_threshold",
            current_value: 60,
            new_value: 50,
            rationale: tag +
            " 总分 " +
            quality.overall_score.to_string() +
            " → 放宽阈值加速",
          })
        }
    }
  }
  let applied = actions.length()
  let total_strategies = 5
  let summary = "元演化[" +
    tag +
    "]: " +
    applied.to_string() +
    " 动作, 总分 " +
    quality.overall_score.to_string()
  { actions, total_strategies, applied_count: applied, summary, }
}

///|
/// 对所有算子进行元演化。
/// Perform meta evolution for all ops.
pub fn meta_evolve_all() -> MetaReport {
  let all_actions : Array[MetaAction] = []
  let mut total_applied = 0
  for op in all_ops() {
    let report = meta_evolve_op(op)
    for a in report.actions {
      all_actions.push(a)
    }
    total_applied = total_applied + report.applied_count
  }
  let summary = "全量元演化: " +
    all_actions.length().to_string() +
    " 动作, " +
    total_applied.to_string() +
    " 已应用"
  {
    actions: all_actions,
    total_strategies: 5,
    applied_count: total_applied,
    summary,
  }
}

///|
/// 元演化报告是否有变更。
/// Whether meta report has changes.
pub fn MetaReport::has_changes(self : MetaReport) -> Bool {
  self.applied_count > 0
}

///|
/// 元演化报告策略数。
/// Strategy count.
pub fn MetaReport::strategy_count(self : MetaReport) -> Int32 {
  self.total_strategies
}
