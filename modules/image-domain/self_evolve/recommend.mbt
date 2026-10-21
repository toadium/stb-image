// 演化推荐引擎 — 根据当前状态推荐下一步演化
// Evolution recommendation engine: recommend next evolution step based on current state
//
// Phase 8 v298: 将演化从"被动"推向"主动推荐" — 根据覆盖/退化/传播推荐下一步。

///|
/// 推荐动作类型。
/// Recommendation action type.
pub(all) enum RecommendAction {
  AddTests
  FixDegradation
  AddPropagationTest
  OptimizePipeline
  NoActionNeeded
} derive(Eq, @debug.Debug)

///|
pub extend RecommendAction with @debug.Debug::{to_repr}

///|
pub extend RecommendAction with Eq::{not_equal, equal}

///|
/// 单条演化推荐。
/// Single evolution recommendation.
pub(all) struct Recommendation {
  action : RecommendAction
  target_op : String
  priority : TestPriority
  reason : String
} derive(Eq, @debug.Debug)

///|
pub extend Recommendation with @debug.Debug::{to_repr}

///|
pub extend Recommendation with Eq::{not_equal, equal}

///|
/// 推荐报告。
/// Recommendation report.
pub(all) struct RecommendationReport {
  recommendations : Array[Recommendation]
  total : Int32
  high_priority_count : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend RecommendationReport with @debug.Debug::{to_repr}

///|
pub extend RecommendationReport with Eq::{not_equal, equal}

///|
/// 推荐单算子下一步演化。
/// Recommend next evolution step for a single op.
pub fn recommend_next(op : @imgir.IROp) -> Recommendation {
  let tag = op.tag()
  let degs = detect_degradation(op)
  let cov = coverage_percentage(op)
  if degs.length() > 0 {
    {
      action: FixDegradation,
      target_op: tag,
      priority: HighPriority,
      reason: tag + " 有 " + degs.length().to_string() + " 个退化需修复",
    }
  } else if cov < 50 {
    {
      action: AddTests,
      target_op: tag,
      priority: MediumPriority,
      reason: tag + " 覆盖率仅 " + cov.to_string() + "%，需增加测试",
    }
  } else {
    {
      action: NoActionNeeded,
      target_op: tag,
      priority: LowPriority,
      reason: tag + " 状态良好，无需操作",
    }
  }
}

///|
/// 推荐全算子演化。
/// Recommend evolution for all ops.
pub fn recommend_all() -> RecommendationReport {
  let recs : Array[Recommendation] = []
  let mut high_count = 0
  for op in all_ops() {
    let rec = recommend_next(op)
    if rec.priority is HighPriority {
      high_count = high_count + 1
    }
    recs.push(rec)
  }
  let total = recs.length()
  let summary = "演化推荐: " +
    total.to_string() +
    " 条推荐, " +
    high_count.to_string() +
    " 条高优先级"
  { recommendations: recs, total, high_priority_count: high_count, summary, }
}

///|
/// 推荐管道演化。
/// Recommend evolution for a pipeline.
pub fn recommend_for_pipeline(
  pipeline : @imgir.IRPipeline,
) -> RecommendationReport {
  let recs : Array[Recommendation] = []
  let mut high_count = 0
  let has_prop = has_propagation_risk(pipeline)
  if has_prop {
    recs.push({
      action: AddPropagationTest,
      target_op: "pipeline",
      priority: HighPriority,
      reason: "管道有传播风险，需添加传播测试",
    })
    high_count = high_count + 1
  }
  for op in pipeline.ops {
    let rec = recommend_next(op)
    if rec.priority is HighPriority {
      high_count = high_count + 1
    }
    recs.push(rec)
  }
  let total = recs.length()
  let summary = "管道推荐: " +
    total.to_string() +
    " 条推荐, " +
    high_count.to_string() +
    " 条高优先级（管道 " +
    @imgir.ir_describe(pipeline) +
    "）"
  { recommendations: recs, total, high_priority_count: high_count, summary, }
}

///|
/// 推荐报告是否有紧急推荐。
/// Whether recommendation report has urgent items.
pub fn RecommendationReport::has_urgent(self : RecommendationReport) -> Bool {
  self.high_priority_count > 0
}
