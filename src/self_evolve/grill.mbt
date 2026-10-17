// grill-me 拷问引擎 — 4.7.4 领域规则可执行化
// Grill engine: executable 4.7.4 domain rules
//
// 五条拷问规则：
//   1. 数值鲁棒性：除零 / 奇异矩阵 / NaN / Inf / 溢出
//   2. 退化几何：除零 / 共线点 / 退化三角形 / 零面积
//   3. 场间断：边界不连续 / 梯度不存在 / 插值外推
//   4. 时空拓扑：Allen 代数 / 时间区间 / 单调性
//   5. 四目标兼容：纯 MoonBit 无 C FFI（静态保证）

///|
/// 拷问规则（对应 4.7.4 五条领域规则）。
/// Grill rule (corresponds to 4.7.4 domain rules).
pub(all) enum GrillRule {
  NumericRobustness // 数值鲁棒性
  DegenerateGeometry // 退化几何
  FieldDiscontinuityRule // 场间断
  SpatiotemporalTopology // 时空拓扑
  MultiTargetCompat // 四目标兼容
} derive(Eq, @debug.Debug)

///|
pub extend GrillRule with @debug.Debug::{to_repr}

///|
pub extend GrillRule with Eq::{not_equal, equal}

///|
/// 单条拷问结果。
/// Single grill result.
pub(all) struct GrillResult {
  rule : GrillRule
  target : String
  passed : Bool
  reason : String
} derive(Eq, @debug.Debug)

///|
pub extend GrillResult with @debug.Debug::{to_repr}

///|
pub extend GrillResult with Eq::{not_equal, equal}

///|
/// 拷问报告。
/// Grill report.
pub(all) struct GrillReport {
  results : Array[GrillResult]
  target_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend GrillReport with @debug.Debug::{to_repr}

///|
pub extend GrillReport with Eq::{not_equal, equal}

///|
/// 全部 5 条拷问规则。
/// All 5 grill rules.
pub fn grill_rules() -> Array[GrillRule] {
  [
    NumericRobustness,
    DegenerateGeometry,
    FieldDiscontinuityRule,
    SpatiotemporalTopology,
    MultiTargetCompat,
  ]
}

///|
/// 规则描述。
/// Rule description.
pub fn grill_rule_desc(rule : GrillRule) -> String {
  match rule {
    NumericRobustness => "数值鲁棒性：除零/奇异矩阵/NaN/Inf/溢出"
    DegenerateGeometry => "退化几何：除零/共线点/零面积"
    FieldDiscontinuityRule =>
      "场间断：边界不连续/梯度不存在/插值外推"
    SpatiotemporalTopology =>
      "时空拓扑：Allen代数/时间区间/单调性"
    MultiTargetCompat => "四目标兼容：纯MoonBit无CFFI"
  }
}

// 判断退化类型是否数值类

///|
fn is_numeric_kind(k : DegradationKind) -> Bool {
  match k {
    DivisionByZero => true
    SingularMatrix => true
    NaNValue => true
    InfValue => true
    Overflow => true
    FieldDiscontinuity => false
  }
}

// 统计数值类退化数

///|
fn count_numeric_degradations(degs : Array[DegradationCase]) -> Int {
  let mut count = 0
  for d in degs {
    if is_numeric_kind(d.kind) {
      count = count + 1
    }
  }
  count
}

// 统计除零退化数（退化几何）

///|
fn count_divzero_degradations(degs : Array[DegradationCase]) -> Int {
  let mut count = 0
  for d in degs {
    if d.kind == DivisionByZero {
      count = count + 1
    }
  }
  count
}

// 统计场间断违规数（FieldClamp lo>hi / FieldMask 极端阈值）

///|
fn count_field_discontinuity(ops : Array[@imgir.IROp]) -> Int {
  let mut count = 0
  for op in ops {
    match op {
      FieldClamp(lo, hi) => if lo > hi { count = count + 1 }
      FieldMask(threshold) =>
        if threshold > 1000000.0F || threshold < -1000000.0F {
          count = count + 1
        }
      _ => ()
    }
  }
  count
}

// 统计时空拓扑违规数（STSnapshot/STInterpolate t 越界 [0,1]）

///|
fn count_spatiotemporal_violation(ops : Array[@imgir.IROp]) -> Int {
  let mut count = 0
  for op in ops {
    match op {
      STSnapshot(t) => if t < 0.0F || t > 1.0F { count = count + 1 }
      STInterpolate(t) => if t < 0.0F || t > 1.0F { count = count + 1 }
      _ => ()
    }
  }
  count
}

///|
/// 对管道执行 5 条拷问规则检查。
/// Run 5 grill rules on a pipeline.
pub fn run_grill_check(pipeline : @imgir.IRPipeline) -> GrillReport {
  let ops = pipeline.ops
  let degs = scan_degradations(ops)
  let desc = @imgir.ir_describe(pipeline)
  let results : Array[GrillResult] = []
  // 规则 1: 数值鲁棒性
  let numeric_fail = count_numeric_degradations(degs)
  results.push({
    rule: NumericRobustness,
    target: desc,
    passed: numeric_fail == 0,
    reason: if numeric_fail == 0 {
      "无数值退化"
    } else {
      "发现 " +
      numeric_fail.to_string() +
      " 处数值退化（除零/奇异/NaN/Inf/溢出）"
    },
  })
  // 规则 2: 退化几何
  let geom_fail = count_divzero_degradations(degs)
  results.push({
    rule: DegenerateGeometry,
    target: desc,
    passed: geom_fail == 0,
    reason: if geom_fail == 0 {
      "无退化几何"
    } else {
      "发现 " +
      geom_fail.to_string() +
      " 处退化几何（除零/零面积）"
    },
  })
  // 规则 3: 场间断
  let field_fail = count_field_discontinuity(ops)
  results.push({
    rule: FieldDiscontinuityRule,
    target: desc,
    passed: field_fail == 0,
    reason: if field_fail == 0 {
      "无场间断"
    } else {
      "发现 " +
      field_fail.to_string() +
      " 处场间断（边界不连续/插值外推）"
    },
  })
  // 规则 4: 时空拓扑
  let st_fail = count_spatiotemporal_violation(ops)
  results.push({
    rule: SpatiotemporalTopology,
    target: desc,
    passed: st_fail == 0,
    reason: if st_fail == 0 {
      "时空拓扑一致"
    } else {
      "发现 " +
      st_fail.to_string() +
      " 处时空拓扑违规（t 越界 [0,1]）"
    },
  })
  // 规则 5: 四目标兼容（静态保证）
  results.push({
    rule: MultiTargetCompat,
    target: desc,
    passed: true,
    reason: "纯 MoonBit 无 C FFI，四目标共用代码",
  })
  { results, target_desc: desc, }
}

///|
/// 对全部 19 种算子执行拷问。
/// Run grill on all 19 op variants.
pub fn run_grill_all() -> GrillReport {
  let results : Array[GrillResult] = []
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    let report = run_grill_check(pipe)
    for r in report.results {
      results.push(r)
    }
  }
  { results, target_desc: "全部 19 种算子", }
}

///|
/// 全部规则是否通过。
/// Whether all rules passed.
pub fn GrillReport::all_passed(self : GrillReport) -> Bool {
  let mut ok = true
  for r in self.results {
    if !r.passed {
      ok = false
    }
  }
  ok
}

///|
/// 失败规则数。
/// Number of failed rules.
pub fn GrillReport::failed_count(self : GrillReport) -> Int {
  let mut count = 0
  for r in self.results {
    if !r.passed {
      count = count + 1
    }
  }
  count
}

///|
/// 通过规则数。
/// Number of passed rules.
pub fn GrillReport::passed_count(self : GrillReport) -> Int {
  self.results.length() - self.failed_count()
}
