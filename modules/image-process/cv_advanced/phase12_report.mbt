// Phase 12 综合报告 — 汇总 v316-v329 全部能力
// Phase 12 summary report
//
// Phase 12 v330: CV算法大扩展完成总结。

///|
/// Phase 12 能力项。
/// Phase 12 capability item.
pub(all) struct Phase12Capability {
  version : String
  name : String
  types : Int32
  functions : Int32
  tests : Int32
} derive(Eq, @debug.Debug)

///|
pub extend Phase12Capability with @debug.Debug::{to_repr}

///|
pub extend Phase12Capability with Eq::{not_equal, equal}

///|
/// Phase 12 综合报告。
/// Phase 12 summary report.
pub(all) struct Phase12Report {
  total_versions : Int32
  total_types : Int32
  total_functions : Int32
  total_tests : Int32
  capabilities : Array[Phase12Capability]
  is_complete : Bool
} derive(Eq, @debug.Debug)

///|
pub extend Phase12Report with @debug.Debug::{to_repr}

///|
pub extend Phase12Report with Eq::{not_equal, equal}

///|
/// Phase 12 全部能力列表。
/// Phase 12 all capabilities.
pub fn phase12_capabilities() -> Array[Phase12Capability] {
  [
    {
      version: "v316",
      name: "特征检测扩展",
      types: 3,
      functions: 8,
      tests: 9,
    },
    {
      version: "v317",
      name: "描述子匹配",
      types: 2,
      functions: 7,
      tests: 9,
    },
    { version: "v318", name: "相机标定", types: 3, functions: 4, tests: 9, },
    { version: "v319", name: "极线几何", types: 5, functions: 7, tests: 9, },
    {
      version: "v320",
      name: "立体视觉扩展",
      types: 3,
      functions: 6,
      tests: 9,
    },
    { version: "v321", name: "光流扩展", types: 2, functions: 6, tests: 9, },
    { version: "v322", name: "目标跟踪", types: 4, functions: 7, tests: 9, },
    { version: "v323", name: "背景建模", types: 4, functions: 7, tests: 9, },
    {
      version: "v324",
      name: "运动检测扩展",
      types: 3,
      functions: 7,
      tests: 9,
    },
    {
      version: "v325",
      name: "图像配准扩展",
      types: 4,
      functions: 8,
      tests: 9,
    },
    { version: "v326", name: "SLAM 前端", types: 4, functions: 9, tests: 9, },
    { version: "v327", name: "SLAM 后端", types: 4, functions: 8, tests: 9, },
    {
      version: "v328",
      name: "ORB-SLAM 核心",
      types: 4,
      functions: 8,
      tests: 9,
    },
    { version: "v329", name: "VINS", types: 4, functions: 8, tests: 9, },
  ]
}

///|
/// Phase 12 总类型数。
/// Phase 12 total types.
pub fn phase12_total_types() -> Int32 {
  let caps = phase12_capabilities()
  let mut total = 0
  for c in caps {
    total = total + c.types
  }
  total
}

///|
/// Phase 12 总函数数。
/// Phase 12 total functions.
pub fn phase12_total_functions() -> Int32 {
  let caps = phase12_capabilities()
  let mut total = 0
  for c in caps {
    total = total + c.functions
  }
  total
}

///|
/// Phase 12 总测试数。
/// Phase 12 total tests.
pub fn phase12_total_tests() -> Int32 {
  let caps = phase12_capabilities()
  let mut total = 0
  for c in caps {
    total = total + c.tests
  }
  total
}

///|
/// Phase 12 综合报告。
/// Phase 12 summary report.
pub fn phase12_report() -> Phase12Report {
  let caps = phase12_capabilities()
  {
    total_versions: caps.length(),
    total_types: phase12_total_types(),
    total_functions: phase12_total_functions(),
    total_tests: phase12_total_tests(),
    capabilities: caps,
    is_complete: caps.length() == 14,
  }
}

///|
/// Phase 12 是否完成。
/// Phase 12 is complete.
pub fn phase12_is_complete() -> Bool {
  phase12_report().is_complete
}
