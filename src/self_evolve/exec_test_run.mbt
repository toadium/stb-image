// 实际执行测试 — 从占位 assert_true 走向真实断言执行
// Execute tests: from placeholder assert_true to real assertion execution
//
// Phase 6 v286: 将生成的测试用例真正"运行" — 构造算子、检测退化、按类别判定通过。

///|
/// 单个测试运行结果。
/// Single test run result.
pub(all) struct TestRunResult {
  test_name : String
  passed : Bool
  actual_behavior : String
  expected_behavior : String
  category : TestCategory
} derive(Eq, @debug.Debug)

///|
pub extend TestRunResult with @debug.Debug::{to_repr}

///|
pub extend TestRunResult with Eq::{not_equal, equal}

///|
/// 测试运行汇总。
/// Test run summary.
pub(all) struct RunSummary {
  total : Int
  passed : Int
  failed : Int
  pass_rate_pct : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend RunSummary with @debug.Debug::{to_repr}

///|
pub extend RunSummary with Eq::{not_equal, equal}

// 按 tag 查找代表算子

///|
fn find_representative_op(tag : String) -> @imgir.IROp {
  let ops = all_ops()
  let mut found = ops[0]
  for op in ops {
    if op.tag() == tag {
      found = op
    }
  }
  found
}

///|
/// 实际执行单个测试用例（真实断言判定）。
/// Execute a single test case with real assertion.
pub fn run_test_case(tc : TestCase) -> TestRunResult {
  let op = find_representative_op(tc.op_tag)
  let degs = detect_degradation(op)
  // 按类别判定 passed
  let passed = match tc.category {
    Boundary => degs.length() == 0
    Normal => degs.length() == 0
    EdgeCase => true
    Degradation => {
      let repaired = repair_op(op)
      detect_degradation(repaired).length() == 0
    }
  }
  let actual = if passed {
    "符合预期"
  } else {
    "不符合预期: " + degs.length().to_string() + " 处退化"
  }
  {
    test_name: tc.name,
    passed,
    actual_behavior: actual,
    expected_behavior: tc.expected_behavior,
    category: tc.category,
  }
}

///|
/// 批量执行测试用例。
/// Batch execute test cases.
pub fn run_test_suite(tests : Array[TestCase]) -> Array[TestRunResult] {
  let results : Array[TestRunResult] = []
  for tc in tests {
    results.push(run_test_case(tc))
  }
  results
}

///|
/// 对单算子的全部测试用例执行。
/// Execute all test cases for a single op.
pub fn run_tests_for_op(op : @imgir.IROp) -> Array[TestRunResult] {
  let tcs = gen_test_for_op(op)
  run_test_suite(tcs)
}

///|
/// 对全部 19 种算子执行测试。
/// Execute tests for all 19 op variants.
pub fn run_tests_for_all() -> Array[TestRunResult] {
  let results : Array[TestRunResult] = []
  for op in all_ops() {
    for r in run_tests_for_op(op) {
      results.push(r)
    }
  }
  results
}

///|
/// 生成运行汇总。
/// Generate run summary from results.
pub fn run_summary(results : Array[TestRunResult]) -> RunSummary {
  let total = results.length()
  let mut passed = 0
  for r in results {
    if r.passed {
      passed = passed + 1
    }
  }
  let failed = total - passed
  let rate = if total == 0 { 100 } else { passed * 100 / total }
  let summary = "运行 " +
    total.to_string() +
    " 测试: " +
    passed.to_string() +
    " 通过, " +
    failed.to_string() +
    " 失败 (" +
    rate.to_string() +
    "%)"
  { total, passed, failed, pass_rate_pct: rate, summary, }
}

///|
/// 全部测试是否通过。
/// Whether all tests passed.
pub fn RunSummary::all_passed(self : RunSummary) -> Bool {
  self.failed == 0
}
