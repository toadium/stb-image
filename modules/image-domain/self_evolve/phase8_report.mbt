// Phase 8 综合报告 — 汇总 v296-v299 全部能力
// Phase 8 comprehensive report: aggregate v296-v299 capabilities

///|
/// Phase 8 单项能力描述。
/// Phase 8 single capability.
pub(all) struct Phase8Capability {
  version : String
  name : String
  types : Int32
  functions : Int32
  tests : Int32
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase8Capability with @debug.Debug::{to_repr}

///|
pub extend Phase8Capability with Eq::{not_equal, equal}

///|
/// Phase 8 综合报告。
/// Phase 8 aggregate report.
pub(all) struct Phase8Report {
  capabilities : Array[Phase8Capability]
  total_types : Int32
  total_functions : Int32
  total_tests : Int32
  phase_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase8Report with @debug.Debug::{to_repr}

///|
pub extend Phase8Report with Eq::{not_equal, equal}

///|
/// Phase 8 全部能力清单（v296-v299）。
/// Phase 8 capability list (v296-v299).
pub fn phase8_capabilities() -> Array[Phase8Capability] {
  [
    {
      version: "v296.0.0",
      name: "退化传播可视化",
      types: 2,
      functions: 4,
      tests: 9,
      description: "生成传播链的可视化描述 (ASCII/Mermaid/Text)",
    },
    {
      version: "v297.0.0",
      name: "测试覆盖盲区分析",
      types: 3,
      functions: 4,
      tests: 9,
      description: "找出未覆盖的算子/退化场景",
    },
    {
      version: "v298.0.0",
      name: "演化推荐引擎",
      types: 3,
      functions: 3,
      tests: 9,
      description: "根据当前状态推荐下一步演化",
    },
    {
      version: "v299.0.0",
      name: "管道优化建议",
      types: 3,
      functions: 3,
      tests: 9,
      description: "基于等价性推荐管道优化",
    },
  ]
}

///|
/// Phase 8 总类型数。
pub fn phase8_total_types() -> Int32 {
  let mut sum = 0
  for c in phase8_capabilities() {
    sum = sum + c.types
  }
  sum
}

///|
/// Phase 8 总函数数。
pub fn phase8_total_functions() -> Int32 {
  let mut sum = 0
  for c in phase8_capabilities() {
    sum = sum + c.functions
  }
  sum
}

///|
/// Phase 8 总测试数。
pub fn phase8_total_tests() -> Int32 {
  let mut sum = 0
  for c in phase8_capabilities() {
    sum = sum + c.tests
  }
  sum
}

///|
/// Phase 8 综合报告。
pub fn phase8_report() -> Phase8Report {
  let caps = phase8_capabilities()
  let total_types = phase8_total_types()
  let total_functions = phase8_total_functions()
  let total_tests = phase8_total_tests()
  let summary = "Phase 8 自演化生产期完成: " +
    caps.length().to_string() +
    " 个版本, " +
    total_types.to_string() +
    " 类型, " +
    total_functions.to_string() +
    " 函数, " +
    total_tests.to_string() +
    " 测试 — 可视化→盲区→推荐→优化 自演化生产体系建成"
  {
    capabilities: caps,
    total_types,
    total_functions,
    total_tests,
    phase_summary: summary,
  }
}

///|
/// Phase 8 是否完成（4 个版本全部交付）。
pub fn phase8_is_complete() -> Bool {
  phase8_capabilities().length() == 4
}
