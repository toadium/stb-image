// 退化根因分析 — 分析退化根因（参数来源/传播路径）
// Root cause analysis: analyze degradation root cause
//
// Phase 6 v289: 将退化检测从"发现"推向"根因定位" — 指出根因参数 + 修复建议。

///|
/// 单个退化根因。
/// Single degradation root cause.
pub(all) struct RootCause {
  op_tag : String
  degradation_kind : DegradationKind
  root_param : String
  cause_desc : String
  fix_suggestion : String
} derive(Eq, @debug.Debug)

///|
pub extend RootCause with @debug.Debug::{to_repr}

///|
pub extend RootCause with Eq::{not_equal, equal}

///|
/// 根因分析报告。
/// Root cause analysis report.
pub(all) struct RootCauseReport {
  causes : Array[RootCause]
  total : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend RootCauseReport with @debug.Debug::{to_repr}

///|
pub extend RootCauseReport with Eq::{not_equal, equal}

///|
/// 分析单算子退化根因（根因参数 + 修复建议）。
/// Analyze root cause of a single op's degradations.
pub fn analyze_root_cause(op : @imgir.IROp) -> Array[RootCause] {
  let degs = detect_degradation(op)
  let causes : Array[RootCause] = []
  for d in degs {
    let root_param = match op {
      Resize(w, _h) => if w == 0 { "w=0" } else { "h=0" }
      Crop(_x, _y, w, _h) => if w == 0 { "w=0" } else { "h=0" }
      GaussianBlur(_r, sigma) =>
        if sigma == 0.0F {
          "sigma=0"
        } else {
          "sigma<0"
        }
      Sharpen(amount) => "amount=" + amount.to_string()
      FieldClamp(lo, hi) => "lo=" + lo.to_string() + ">hi=" + hi.to_string()
      FieldMask(t) => "threshold=" + t.to_string()
      STSnapshot(t) => "t=" + t.to_string()
      STInterpolate(t) => "t=" + t.to_string()
      _ => "unknown"
    }
    let fix = match op {
      Resize(_, _) => "尺寸→1"
      Crop(_, _, _, _) => "尺寸→1"
      GaussianBlur(_, _) => "sigma→1.0"
      Sharpen(_) => "clamp[-100,100]"
      FieldClamp(_, _) => "swap(lo,hi)"
      FieldMask(_) => "threshold→0.0"
      STSnapshot(_) => "clamp[0,1]"
      STInterpolate(_) => "clamp[0,1]"
      _ => "review"
    }
    causes.push({
      op_tag: op.tag(),
      degradation_kind: d.kind,
      root_param,
      cause_desc: d.description,
      fix_suggestion: fix,
    })
  }
  causes
}

///|
/// 对全部 19 种算子分析根因。
/// Analyze root cause for all 19 op variants.
pub fn analyze_root_cause_all() -> RootCauseReport {
  let causes : Array[RootCause] = []
  for op in all_ops() {
    for c in analyze_root_cause(op) {
      causes.push(c)
    }
  }
  let total = causes.length()
  let summary = "根因分析: " + total.to_string() + " 处退化根因定位"
  { causes, total, summary, }
}

///|
/// 对管道分析根因。
/// Analyze root cause for a pipeline.
pub fn analyze_pipeline_root_cause(
  pipeline : @imgir.IRPipeline,
) -> RootCauseReport {
  let causes : Array[RootCause] = []
  for op in pipeline.ops {
    for c in analyze_root_cause(op) {
      causes.push(c)
    }
  }
  let total = causes.length()
  let summary = "管道根因分析: " +
    total.to_string() +
    " 处退化根因（管道 " +
    @imgir.ir_describe(pipeline) +
    "）"
  { causes, total, summary, }
}

///|
/// 根因报告是否无退化。
/// Whether root cause report has no degradation.
pub fn RootCauseReport::is_clean(self : RootCauseReport) -> Bool {
  self.total == 0
}

///|
/// 按退化类型过滤根因。
/// Filter root causes by degradation kind.
pub fn filter_by_kind(
  causes : Array[RootCause],
  kind : DegradationKind,
) -> Array[RootCause] {
  let result : Array[RootCause] = []
  for c in causes {
    if c.degradation_kind == kind {
      result.push(c)
    }
  }
  result
}
