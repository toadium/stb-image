// self_evolve 类型定义 — 自动测试用例生成 + 退化场景发现
// Type definitions for self-evolution: auto test generation + degradation detection

///|
/// 测试用例类别。
/// Test case category.
pub(all) enum TestCategory {
  Boundary // 边界条件（零尺寸/最小尺寸/最大尺寸）
  Normal // 正常用例
  EdgeCase // 边缘用例（极端参数）
  Degradation // 退化用例（数值退化场景）
} derive(Eq, @debug.Debug)

///|
pub extend TestCategory with @debug.Debug::{to_repr}

///|
pub extend TestCategory with Eq::{not_equal, equal}

///|
/// 退化类型（对应 4.7.4 领域规则）。
/// Degradation kind (corresponds to 4.7.4 domain rules).
pub(all) enum DegradationKind {
  DivisionByZero // 除零
  SingularMatrix // 奇异矩阵（行列式 ≈ 0）
  FieldDiscontinuity // 场间断（边界不连续）
  Overflow // 整数/浮点溢出
  NaNValue // NaN 传播
  InfValue // Inf 传播
} derive(Eq, @debug.Debug)

///|
pub extend DegradationKind with @debug.Debug::{to_repr}

///|
pub extend DegradationKind with Eq::{not_equal, equal}

///|
/// 严重程度。
/// Severity level.
pub(all) enum Severity {
  Warning // 警告：结果可能不精确但可用
  Critical // 严重：结果不可靠
  Fatal // 致命：会崩溃或抛异常
} derive(Eq, @debug.Debug)

///|
pub extend Severity with @debug.Debug::{to_repr}

///|
pub extend Severity with Eq::{not_equal, equal}

///|
/// 自动生成的测试用例描述。
/// Auto-generated test case description.
pub(all) struct TestCase {
  name : String
  op_tag : String
  category : TestCategory
  description : String
  input_spec : String
  expected_behavior : String
} derive(Eq, @debug.Debug)

///|
pub extend TestCase with @debug.Debug::{to_repr}

///|
pub extend TestCase with Eq::{not_equal, equal}

///|
/// 退化场景描述。
/// Degradation case description.
pub(all) struct DegradationCase {
  kind : DegradationKind
  op_tag : String
  description : String
  severity : Severity
} derive(Eq, @debug.Debug)

///|
pub extend DegradationCase with @debug.Debug::{to_repr}

///|
pub extend DegradationCase with Eq::{not_equal, equal}

///|
/// 演化报告：生成的测试 + 发现的退化。
/// Evolution report: generated tests + found degradations.
pub(all) struct EvolveReport {
  generated_tests : Array[TestCase]
  found_degradations : Array[DegradationCase]
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend EvolveReport with @debug.Debug::{to_repr}

///|
pub extend EvolveReport with Eq::{not_equal, equal}

///|
/// 测试用例数量。
/// Number of test cases.
pub fn EvolveReport::test_count(self : EvolveReport) -> Int {
  self.generated_tests.length()
}

///|
/// 退化场景数量。
/// Number of degradation cases.
pub fn EvolveReport::degradation_count(self : EvolveReport) -> Int {
  self.found_degradations.length()
}

///|
/// 严重退化数量（Critical + Fatal）。
/// Number of severe degradations.
pub fn EvolveReport::severe_count(self : EvolveReport) -> Int {
  let mut count = 0
  for d in self.found_degradations {
    match d.severity {
      Warning => ()
      Critical => count = count + 1
      Fatal => count = count + 1
    }
  }
  count
}
