// 自适应测试策略 — 根据覆盖率自动调整测试优先级
// Adaptive test strategy: auto-adjust test priority based on coverage
//
// Phase 7 v292: 将测试生成从"均匀"推向"自适应" — 低覆盖算子优先。

///|
/// 测试优先级。
/// Test priority level.
pub(all) enum TestPriority {
  HighPriority
  MediumPriority
  LowPriority
} derive(Eq, @debug.Debug)

///|
pub extend TestPriority with @debug.Debug::{to_repr}

///|
pub extend TestPriority with Eq::{not_equal, equal}

///|
/// 单算子自适应策略。
/// Adaptive strategy for a single op.
pub(all) struct AdaptiveStrategy {
  op_tag : String
  current_coverage : Int
  priority : TestPriority
  suggested_tests : Int
} derive(Eq, @debug.Debug)

///|
pub extend AdaptiveStrategy with @debug.Debug::{to_repr}

///|
pub extend AdaptiveStrategy with Eq::{not_equal, equal}

///|
/// 自适应报告。
/// Adaptive report.
pub(all) struct AdaptiveReport {
  strategies : Array[AdaptiveStrategy]
  total_prioritized : Int
  high_priority_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend AdaptiveReport with @debug.Debug::{to_repr}

///|
pub extend AdaptiveReport with Eq::{not_equal, equal}

///|
/// 根据覆盖度建议测试数量。
/// Suggest test count based on coverage (0-100).
pub fn suggest_test_count(coverage : Int) -> Int {
  if coverage >= 80 {
    2
  } else if coverage >= 50 {
    5
  } else if coverage >= 25 {
    8
  } else {
    12
  }
}

///|
/// 根据覆盖度判定优先级。
/// Determine priority based on coverage.
pub fn priority_from_coverage(coverage : Int) -> TestPriority {
  if coverage >= 50 {
    LowPriority
  } else if coverage >= 25 {
    MediumPriority
  } else {
    HighPriority
  }
}

///|
/// 分析单算子自适应策略。
/// Analyze adaptive strategy for a single op.
pub fn adaptive_strategy(op : @imgir.IROp) -> AdaptiveStrategy {
  let degs = detect_degradation(op)
  let coverage = if degs.length() == 0 {
    100
  } else {
    100 / (degs.length() + 1)
  }
  let priority = priority_from_coverage(coverage)
  let suggested = suggest_test_count(coverage)
  {
    op_tag: op.tag(),
    current_coverage: coverage,
    priority,
    suggested_tests: suggested,
  }
}

///|
/// 对全部 19 种算子分析自适应策略。
/// Analyze adaptive strategy for all 19 ops.
pub fn adaptive_strategy_all() -> AdaptiveReport {
  let strategies : Array[AdaptiveStrategy] = []
  let mut high_count = 0
  for op in all_ops() {
    let s = adaptive_strategy(op)
    if s.priority is HighPriority {
      high_count = high_count + 1
    }
    strategies.push(s)
  }
  let total = strategies.length()
  let summary = "自适应策略: " +
    total.to_string() +
    " 个算子, " +
    high_count.to_string() +
    " 个高优先级"
  {
    strategies,
    total_prioritized: total,
    high_priority_count: high_count,
    summary,
  }
}

///|
/// 获取高优先级算子标签。
/// Get high-priority op tags.
pub fn high_priority_ops() -> Array[String] {
  let result : Array[String] = []
  for s in adaptive_strategy_all().strategies {
    if s.priority is HighPriority {
      result.push(s.op_tag)
    }
  }
  result
}

///|
/// 自适应报告是否全部高覆盖。
/// Whether adaptive report is all high coverage.
pub fn AdaptiveReport::is_well_covered(self : AdaptiveReport) -> Bool {
  self.high_priority_count == 0
}
