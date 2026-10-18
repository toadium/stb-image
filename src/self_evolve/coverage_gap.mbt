// 测试覆盖盲区分析 — 分析测试覆盖盲区，找出未覆盖的算子/退化场景
// Coverage gap analysis: find untested or under-tested ops and degradation scenarios
//
// Phase 8 v297: 将覆盖分析从"自适应"推向"盲区发现" — 找出测试覆盖空白。

///|
/// 覆盖盲区类型。
/// Coverage gap type.
pub(all) enum GapKind {
  UntestedOp
  UnderTestedOp
  NoDegradationTest
} derive(Eq, @debug.Debug)

///|
pub extend GapKind with @debug.Debug::{to_repr}

///|
pub extend GapKind with Eq::{not_equal, equal}

///|
/// 单个覆盖盲区。
/// Single coverage gap.
pub(all) struct CoverageGap {
  op_tag : String
  gap_kind : GapKind
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend CoverageGap with @debug.Debug::{to_repr}

///|
pub extend CoverageGap with Eq::{not_equal, equal}

///|
/// 覆盖盲区报告。
/// Coverage gap report.
pub(all) struct CoverageGapReport {
  gaps : Array[CoverageGap]
  total_gaps : Int
  untested_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend CoverageGapReport with @debug.Debug::{to_repr}

///|
pub extend CoverageGapReport with Eq::{not_equal, equal}

///|
/// 计算单算子覆盖百分比。
/// Calculate coverage percentage for a single op.
pub fn coverage_percentage(op : @imgir.IROp) -> Int {
  let degs = detect_degradation(op)
  let tests = evolve_test_suite([op])
  let base_coverage = if tests.length() >= 4 {
    100
  } else if tests.length() >= 2 {
    50
  } else if tests.length() >= 1 {
    25
  } else {
    0
  }
  if degs.length() > 0 {
    let penalty = degs.length() * 10
    let result = base_coverage - penalty
    if result < 0 {
      0
    } else {
      result
    }
  } else {
    base_coverage
  }
}

///|
/// 找出完全未测试的算子标签。
/// Find completely untested op tags.
pub fn find_untested_ops() -> Array[String] {
  let result : Array[String] = []
  for op in all_ops() {
    let tests = evolve_test_suite([op])
    if tests.length() == 0 {
      result.push(op.tag())
    }
  }
  result
}

///|
/// 找出测试不足的算子标签（覆盖 < 50%）。
/// Find under-tested op tags (coverage < 50%).
pub fn find_under_tested_ops() -> Array[String] {
  let result : Array[String] = []
  for op in all_ops() {
    let cov = coverage_percentage(op)
    if cov < 50 {
      result.push(op.tag())
    }
  }
  result
}

///|
/// 分析全算子测试覆盖盲区。
/// Analyze coverage gaps for all ops.
pub fn analyze_coverage_gaps() -> CoverageGapReport {
  let gaps : Array[CoverageGap] = []
  let mut untested_count = 0
  for op in all_ops() {
    let tests = evolve_test_suite([op])
    if tests.length() == 0 {
      gaps.push({
        op_tag: op.tag(),
        gap_kind: UntestedOp,
        description: op.tag() + " 完全未测试",
      })
      untested_count = untested_count + 1
    } else {
      let cov = coverage_percentage(op)
      if cov < 50 {
        gaps.push({
          op_tag: op.tag(),
          gap_kind: UnderTestedOp,
          description: op.tag() +
          " 测试不足 (覆盖 " +
          cov.to_string() +
          "%)",
        })
      }
      let degs = detect_degradation(op)
      if degs.length() > 0 {
        let has_deg_test = false
        if !has_deg_test {
          gaps.push({
            op_tag: op.tag(),
            gap_kind: NoDegradationTest,
            description: op.tag() + " 有退化但无退化测试",
          })
        }
      }
    }
  }
  let total = gaps.length()
  let summary = "覆盖盲区: " +
    total.to_string() +
    " 处盲区, " +
    untested_count.to_string() +
    " 个未测试算子"
  { gaps, total_gaps: total, untested_count, summary, }
}

///|
/// 覆盖盲区报告是否有盲区。
/// Whether coverage gap report has gaps.
pub fn CoverageGapReport::has_gaps(self : CoverageGapReport) -> Bool {
  self.total_gaps > 0
}
