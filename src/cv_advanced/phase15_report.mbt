// Phase 15 综合报告 — 遥感与地理空间大扩展汇总
// Phase 15 comprehensive report
//
// Phase 15 v375: 遥感与地理空间大扩展完成 — 综合报告。

///|
/// Phase 15 能力描述。
/// Phase 15 capability description.
pub(all) struct Phase15Capability {
  version : String
  name : String
  description : String
  num_types : Int
  num_functions : Int
  num_tests : Int
} derive(Eq, @debug.Debug)

///|
pub extend Phase15Capability with @debug.Debug::{to_repr}

///|
pub extend Phase15Capability with Eq::{not_equal, equal}

///|
/// Phase 15 综合报告。
/// Phase 15 comprehensive report.
pub(all) struct Phase15Report {
  capabilities : Array[Phase15Capability]
  total_versions : Int
  total_types : Int
  total_functions : Int
  total_tests : Int
  is_complete : Bool
} derive(Eq, @debug.Debug)

///|
pub extend Phase15Report with @debug.Debug::{to_repr}

///|
pub extend Phase15Report with Eq::{not_equal, equal}

///|
/// 构建 Phase 15 能力描述。
/// Build Phase 15 capability.
pub fn phase15_build_capability(
  version : String,
  name : String,
  description : String,
  num_types : Int,
  num_functions : Int,
  num_tests : Int,
) -> Phase15Capability {
  { version, name, description, num_types, num_functions, num_tests, }
}

///|
/// 获取 Phase 15 全部能力。
/// Get all Phase 15 capabilities.
pub fn phase15_capabilities() -> Array[Phase15Capability] {
  [
    phase15_build_capability(
      "v361", "多光谱分析", "波段运算/指数/分类/PCA", 2, 6, 12,
    ),
    phase15_build_capability(
      "v362", "高光谱分析", "端元提取/丰度反演/光谱匹配", 2, 8,
      12,
    ),
    phase15_build_capability(
      "v363", "SAR 成像", "RDA/CSA/ωKA 聚焦算法", 3, 14, 19,
    ),
    phase15_build_capability(
      "v364", "InSAR 处理", "干涉/相位解缠/DEM 生成", 2, 10, 17,
    ),
    phase15_build_capability(
      "v365", "变化检测", "差值/比值/变化向量/Otsu", 2, 11, 19,
    ),
    phase15_build_capability(
      "v366", "土地覆盖", "监督/非监督分类/精度评估", 3, 11, 20,
    ),
    phase15_build_capability(
      "v367", "植被指数", "NDVI/EVI/SAVI/MSAVI/GNDVI", 0, 11, 20,
    ),
    phase15_build_capability(
      "v368", "大气校正", "辐射定标/DOS/瑞利/经验线", 2, 9, 16,
    ),
    phase15_build_capability(
      "v369", "几何校正", "RPC/多项式/GCP/重采样", 4, 11, 15,
    ),
    phase15_build_capability(
      "v370", "正射校正", "DEM/镶嵌/匀色/拼接线", 1, 7, 13,
    ),
    phase15_build_capability(
      "v371", "影像融合", "IHS/PCA/小波/Gram-Schmidt", 1, 8, 18,
    ),
    phase15_build_capability(
      "v372", "目标检测", "滑窗/CFAR/模板匹配/NMS", 2, 10, 20,
    ),
    phase15_build_capability(
      "v373", "云检测", "阈值/多光谱/渐进精化/阴影", 2, 9, 18,
    ),
    phase15_build_capability(
      "v374", "时间序列", "趋势/季节/异常/变点/预测", 1, 9, 21,
    ),
  ]
}

///|
/// 计算 Phase 15 总类型数。
/// Compute total types in Phase 15.
pub fn phase15_total_types() -> Int {
  let caps = phase15_capabilities()
  let mut total = 0
  for i in 0..<caps.length() {
    total += caps[i].num_types
  }
  total
}

///|
/// 计算 Phase 15 总函数数。
/// Compute total functions in Phase 15.
pub fn phase15_total_functions() -> Int {
  let caps = phase15_capabilities()
  let mut total = 0
  for i in 0..<caps.length() {
    total += caps[i].num_functions
  }
  total
}

///|
/// 计算 Phase 15 总测试数。
/// Compute total tests in Phase 15.
pub fn phase15_total_tests() -> Int {
  let caps = phase15_capabilities()
  let mut total = 0
  for i in 0..<caps.length() {
    total += caps[i].num_tests
  }
  total
}

///|
/// 生成 Phase 15 综合报告。
/// Generate Phase 15 comprehensive report.
pub fn phase15_report() -> Phase15Report {
  let caps = phase15_capabilities()
  {
    capabilities: caps,
    total_versions: caps.length(),
    total_types: phase15_total_types(),
    total_functions: phase15_total_functions(),
    total_tests: phase15_total_tests(),
    is_complete: true,
  }
}

///|
/// 检查 Phase 15 是否完成。
/// Check if Phase 15 is complete.
pub fn phase15_is_complete() -> Bool {
  let caps = phase15_capabilities()
  caps.length() == 14
}
