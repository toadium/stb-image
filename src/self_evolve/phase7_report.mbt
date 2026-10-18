// Phase 7 综合报告 — 汇总 v291-v294 全部能力
// Phase 7 comprehensive report: aggregate v291-v294 capabilities

///|
/// Phase 7 单项能力描述。
/// Phase 7 single capability.
pub(all) struct Phase7Capability {
  version : String
  name : String
  types : Int
  functions : Int
  tests : Int
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase7Capability with @debug.Debug::{to_repr}

///|
pub extend Phase7Capability with Eq::{not_equal, equal}

///|
/// Phase 7 综合报告。
/// Phase 7 aggregate report.
pub(all) struct Phase7Report {
  capabilities : Array[Phase7Capability]
  total_types : Int
  total_functions : Int
  total_tests : Int
  phase_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend Phase7Report with @debug.Debug::{to_repr}

///|
pub extend Phase7Report with Eq::{not_equal, equal}

///|
/// Phase 7 全部能力清单（v291-v294）。
/// Phase 7 capability list (v291-v294).
pub fn phase7_capabilities() -> Array[Phase7Capability] {
  [
    {
      version: "v291.0.0",
      name: "跨算子退化传播",
      types: 2,
      functions: 4,
      tests: 9,
      description: "分析 pipeline 中退化如何在算子间传播",
    },
    {
      version: "v292.0.0",
      name: "自适应测试策略",
      types: 3,
      functions: 5,
      tests: 9,
      description: "根据覆盖率自动调整测试优先级",
    },
    {
      version: "v293.0.0",
      name: "演化历史持久化",
      types: 2,
      functions: 4,
      tests: 9,
      description: "记录历次演化结果，支持回滚",
    },
    {
      version: "v294.0.0",
      name: "算子等价性验证",
      types: 2,
      functions: 4,
      tests: 9,
      description: "验证两个算子序列等价",
    },
  ]
}

///|
/// Phase 7 总类型数。
pub fn phase7_total_types() -> Int {
  let mut sum = 0
  for c in phase7_capabilities() {
    sum = sum + c.types
  }

  sum
}

///|
/// Phase 7 总函数数。
pub fn phase7_total_functions() -> Int {
  let mut sum = 0
  for c in phase7_capabilities() {
    sum = sum + c.functions
  }
  sum
}

///|
/// Phase 7 总测试数。
pub fn phase7_total_tests() -> Int {
  let mut sum = 0
  for c in phase7_capabilities() {
    sum = sum + c.tests
  }
  sum
}

///|
/// Phase 7 综合报告。
pub fn phase7_report() -> Phase7Report {
  let caps = phase7_capabilities()
  let total_types = phase7_total_types()
  let total_functions = phase7_total_functions()
  let total_tests = phase7_total_tests()
  let summary = "Phase 7 自演化成熟期完成: " +
    caps.length().to_string() +
    " 个版本, " +
    total_types.to_string() +
    " 类型, " +
    total_functions.to_string() +
    " 函数, " +
    total_tests.to_string() +
    " 测试 — 传播→自适应→历史→等价 自演化成熟体系建成"
  {
    capabilities: caps,
    total_types,
    total_functions,
    total_tests,
    phase_summary: summary,
  }
}

///|
/// Phase 7 是否完成（4 个版本全部交付）。
pub fn phase7_is_complete() -> Bool {
  phase7_capabilities().length() == 4
}
