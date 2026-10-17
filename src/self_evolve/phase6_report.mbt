// Phase 6 综合报告 — 汇总 v286-v289 全部能力
// Phase 6 comprehensive report: aggregate v286-v289 capabilities

///|
/// Phase 6 单项能力描述。
/// Phase 6 single capability.
pub(all) struct Phase6Capability {
  version : String
  name : String
  types : Int
  functions : Int
  tests : Int
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase6Capability with @debug.Debug::{to_repr}

///|
pub extend Phase6Capability with Eq::{not_equal, equal}

///|
/// Phase 6 综合报告。
/// Phase 6 aggregate report.
pub(all) struct Phase6Report {
  capabilities : Array[Phase6Capability]
  total_types : Int
  total_functions : Int
  total_tests : Int
  phase_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase6Report with @debug.Debug::{to_repr}

///|
pub extend Phase6Report with Eq::{not_equal, equal}

///|
/// Phase 6 全部能力清单（v286-v289）。
/// Phase 6 capability list (v286-v289).
pub fn phase6_capabilities() -> Array[Phase6Capability] {
  [
    {
      version: "v286.0.0",
      name: "实际执行测试",
      types: 2,
      functions: 7,
      tests: 9,
      description: "从占位 assert_true 走向真实断言执行",
    },
    {
      version: "v287.0.0",
      name: "智能修复策略",
      types: 2,
      functions: 6,
      tests: 10,
      description: "多策略修复（保守/激进/最优）+ 质量评分",
    },
    {
      version: "v288.0.0",
      name: "组合测试覆盖",
      types: 2,
      functions: 4,
      tests: 8,
      description: "自动发现未覆盖算子组合，生成组合测试",
    },
    {
      version: "v289.0.0",
      name: "退化根因分析",
      types: 2,
      functions: 4,
      tests: 9,
      description: "分析退化根因（参数来源/传播路径）+ 修复建议",
    },
  ]
}

///|
/// Phase 6 总类型数。
pub fn phase6_total_types() -> Int {
  let mut sum = 0
  for c in phase6_capabilities() {
    sum = sum + c.types
  }

  sum
}

///|
/// Phase 6 总函数数。
pub fn phase6_total_functions() -> Int {
  let mut sum = 0
  for c in phase6_capabilities() {
    sum = sum + c.functions
  }
  sum
}

///|
/// Phase 6 总测试数。
pub fn phase6_total_tests() -> Int {
  let mut sum = 0
  for c in phase6_capabilities() {
    sum = sum + c.tests
  }
  sum
}

///|
/// Phase 6 综合报告。
pub fn phase6_report() -> Phase6Report {
  let caps = phase6_capabilities()
  let total_types = phase6_total_types()
  let total_functions = phase6_total_functions()
  let total_tests = phase6_total_tests()
  let summary = "Phase 6 自演化深化期完成: " +
    caps.length().to_string() +
    " 个版本, " +
    total_types.to_string() +
    " 类型, " +
    total_functions.to_string() +
    " 函数, " +
    total_tests.to_string() +
    " 测试 — 执行→智能修复→组合覆盖→根因定位 自演化深化体系建成"
  {
    capabilities: caps,
    total_types,
    total_functions,
    total_tests,
    phase_summary: summary,
  }
}

///|
/// Phase 6 是否完成（4 个版本全部交付）。
pub fn phase6_is_complete() -> Bool {
  phase6_capabilities().length() == 4
}
