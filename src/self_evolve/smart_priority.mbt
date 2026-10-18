// 智能测试优先级 — 基于历史数据智能评分
// Smart test priority: intelligently score test priorities based on historical data
//
// Phase 9 v303: 将演化从"回归检测"推向"智能评分" — 多因子加权评分。

///|
/// 评分因子类型。
/// Score factor kind.
pub(all) enum ScoreFactor {
  DegradationRisk
  CoverageGap
  HistoryWeight
  PropagationRisk
} derive(Eq, @debug.Debug)

///|
pub extend ScoreFactor with @debug.Debug::{to_repr}

///|
pub extend ScoreFactor with Eq::{not_equal, equal}

///|
/// 单算子智能评分。
/// Smart score for a single op.
pub(all) struct SmartScore {
  op_tag : String
  score : Int
  factors : Array[ScoreFactor]
  recommendation : String
} derive(Eq, @debug.Debug)

///|
pub extend SmartScore with @debug.Debug::{to_repr}

///|
pub extend SmartScore with Eq::{not_equal, equal}

///|
/// 智能优先级报告。
/// Smart priority report.
pub(all) struct SmartPriorityReport {
  scores : Array[SmartScore]
  total_ops : Int
  high_priority_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend SmartPriorityReport with @debug.Debug::{to_repr}

///|
pub extend SmartPriorityReport with Eq::{not_equal, equal}

///|
/// 为单个算子计算智能评分 (0-100)。
/// Calculate smart score for a single op (0-100).
pub fn score_op(op : @imgir.IROp) -> SmartScore {
  let tag = op.tag()
  let factors : Array[ScoreFactor] = []
  let mut score = 0
  let degs = detect_degradation(op)
  let deg_count = degs.length()
  if deg_count > 0 {
    score = score + deg_count * 25
    factors.push(DegradationRisk)
  }
  let cov = coverage_percentage(op)
  if cov < 50 {
    score = score + (50 - cov)
    factors.push(CoverageGap)
  }
  let log = history_log()
  let mut has_history = false
  for e in log.entries {
    if e.degradation_count > 0 {
      has_history = true
    }
  }
  if has_history {
    score = score + 5
    factors.push(HistoryWeight)
  }
  let pipe = @imgir.IRPipeline::new().add(op)
  let prop = analyze_propagation(pipe)
  if prop.total_propagations > 0 {
    score = score + prop.total_propagations * 10
    factors.push(PropagationRisk)
  }
  if score > 100 {
    score = 100
  }
  let rec = if score >= 70 {
    "高优先级 — 立即处理"
  } else if score >= 40 {
    "中优先级 — 计划处理"
  } else {
    "低优先级 — 按需处理"
  }
  { op_tag: tag, score, factors, recommendation: rec, }
}

///|
/// 为所有算子计算智能评分。
/// Calculate smart scores for all ops.
pub fn score_all_ops() -> SmartPriorityReport {
  let scores : Array[SmartScore] = []
  let mut high_count = 0
  for op in all_ops() {
    let s = score_op(op)
    if s.score >= 70 {
      high_count = high_count + 1
    }
    scores.push(s)
  }
  let total = scores.length()
  let summary = "智能评分: " +
    total.to_string() +
    " 算子, " +
    high_count.to_string() +
    " 高优先级"
  { scores, total_ops: total, high_priority_count: high_count, summary, }
}

///|
/// 获取前 N 个最高优先级算子。
/// Get top N priority ops.
pub fn SmartPriorityReport::top_priority(
  self : SmartPriorityReport,
  n : Int,
) -> Array[SmartScore] {
  let sorted : Array[SmartScore] = []
  for s in self.scores {
    sorted.push(s)
  }
  let len = sorted.length()
  for i in 0..<len {
    for j in 0..<(len - 1 - i) {
      if sorted[j].score < sorted[j + 1].score {
        let tmp = sorted[j]
        sorted[j] = sorted[j + 1]
        sorted[j + 1] = tmp
      }
    }
  }
  let result : Array[SmartScore] = []
  let limit = if n < len { n } else { len }
  for i in 0..<limit {
    result.push(sorted[i])
  }
  result
}
