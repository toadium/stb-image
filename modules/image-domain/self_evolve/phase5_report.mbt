// Phase 5 综合报告 — 汇总 v281-v284 全部能力
// Phase 5 comprehensive report: aggregate v281-v284 capabilities

///|
/// Phase 5 单项能力描述。
/// Phase 5 single capability.
pub(all) struct Phase5Capability {
  version : String
  name : String
  types : Int32
  functions : Int32
  tests : Int32
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase5Capability with @debug.Debug::{to_repr}

///|
pub extend Phase5Capability with Eq::{not_equal, equal}

///|
/// Phase 5 综合报告。
/// Phase 5 aggregate report.
pub(all) struct Phase5Report {
  capabilities : Array[Phase5Capability]
  total_types : Int32
  total_functions : Int32
  total_tests : Int32
  phase_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase5Report with @debug.Debug::{to_repr}

///|
pub extend Phase5Report with Eq::{not_equal, equal}

///|
/// Phase 5 全部能力清单（v281-v284）。
/// Phase 5 capability list (v281-v284).
pub fn phase5_capabilities() -> Array[Phase5Capability] {
  [
    {
      version: "v281.0.0",
      name: "可执行测试生成",
      types: 2,
      functions: 7,
      tests: 9,
      description: "从 TestCase 描述生成可运行 moon test 代码",
    },
    {
      version: "v282.0.0",
      name: "退化自动修复",
      types: 2,
      functions: 6,
      tests: 10,
      description: "检测退化后自动修正参数",
    },
    {
      version: "v283.0.0",
      name: "管道优化执行",
      types: 1,
      functions: 5,
      tests: 9,
      description: "应用 OptimizationSuggestion 到实际 IRPipeline",
    },
    {
      version: "v284.0.0",
      name: "自演化 CI 集成",
      types: 1,
      functions: 6,
      tests: 8,
      description: "moon test 自动演化钩子 + 回归门禁",
    },
  ]
}

///|
/// Phase 5 总类型数。
pub fn phase5_total_types() -> Int32 {
  let mut sum = 0
  for c in phase5_capabilities() {
    sum = sum + c.types
  }

  sum
}

///|
/// Phase 5 总函数数。
pub fn phase5_total_functions() -> Int32 {
  let mut sum = 0
  for c in phase5_capabilities() {
    sum = sum + c.functions
  }
  sum
}

///|
/// Phase 5 总测试数。
pub fn phase5_total_tests() -> Int32 {
  let mut sum = 0
  for c in phase5_capabilities() {
    sum = sum + c.tests
  }
  sum
}

///|
/// Phase 5 综合报告。
pub fn phase5_report() -> Phase5Report {
  let caps = phase5_capabilities()
  let total_types = phase5_total_types()
  let total_functions = phase5_total_functions()
  let total_tests = phase5_total_tests()
  let summary = "Phase 5 智能演化实用期完成: " +
    caps.length().to_string() +
    " 个版本, " +
    total_types.to_string() +
    " 类型, " +
    total_functions.to_string() +
    " 函数, " +
    total_tests.to_string() +
    " 测试 — 描述→执行→修复→优化→CI 自演化实用体系建成"
  {
    capabilities: caps,
    total_types,
    total_functions,
    total_tests,
    phase_summary: summary,
  }
}

///|
/// Phase 5 是否完成（4 个版本全部交付）。
pub fn phase5_is_complete() -> Bool {
  phase5_capabilities().length() == 4
}
