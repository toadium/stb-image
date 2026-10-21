// 跨算子退化传播 — 分析 pipeline 中退化如何在算子间传播
// Cross-op degradation propagation: analyze how degradations propagate across pipeline
//
// Phase 7 v291: 将根因分析从"单算子"推向"跨算子传播链" — 退化如何在管道中传播。

///|
/// 单个退化传播步骤。
/// Single degradation propagation step.
pub(all) struct PropagationStep {
  from_op_tag : String
  to_op_tag : String
  degradation_kind : DegradationKind
  propagation_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend PropagationStep with @debug.Debug::{to_repr}

///|
pub extend PropagationStep with Eq::{not_equal, equal}

///|
/// 退化传播报告。
/// Degradation propagation report.
pub(all) struct PropagationReport {
  steps : Array[PropagationStep]
  total_propagations : Int32
  chain_length : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend PropagationReport with @debug.Debug::{to_repr}

///|
pub extend PropagationReport with Eq::{not_equal, equal}

///|
/// 分析管道中退化传播链。
/// Analyze degradation propagation chain in a pipeline.
pub fn analyze_propagation(pipeline : @imgir.IRPipeline) -> PropagationReport {
  let steps : Array[PropagationStep] = []
  let ops = pipeline.ops
  let n = ops.length()
  for i in 0..<n {
    let degs = detect_degradation(ops[i])
    if degs.length() > 0 && i + 1 < n {
      let from_tag = ops[i].tag()
      let to_tag = ops[i + 1].tag()
      for d in degs {
        let desc = match d.kind {
          DivisionByZero =>
            "除零退化从 " + from_tag + " 传播至 " + to_tag
          SingularMatrix =>
            "奇异矩阵从 " + from_tag + " 传播至 " + to_tag
          FieldDiscontinuity =>
            "场间断从 " + from_tag + " 传播至 " + to_tag
          Overflow => "溢出从 " + from_tag + " 传播至 " + to_tag
          NaNValue => "NaN 从 " + from_tag + " 传播至 " + to_tag
          InfValue => "Inf 从 " + from_tag + " 传播至 " + to_tag
        }
        steps.push({
          from_op_tag: from_tag,
          to_op_tag: to_tag,
          degradation_kind: d.kind,
          propagation_desc: desc,
        })
      }
    }
  }
  let total = steps.length()
  let chain_length = if total > 0 { n } else { 0 }
  let summary = "传播分析: " +
    total.to_string() +
    " 处退化传播, 链长 " +
    chain_length.to_string() +
    "（管道 " +
    @imgir.ir_describe(pipeline) +
    "）"
  { steps, total_propagations: total, chain_length, summary, }
}

///|
/// 对全部 19 种算子的相邻组合分析传播。
/// Analyze propagation for all adjacent op combinations.
pub fn analyze_propagation_all() -> PropagationReport {
  let ops = all_ops()
  let steps : Array[PropagationStep] = []
  let n = ops.length()
  for i in 0..<(n - 1) {
    let from_tag = ops[i].tag()
    let to_tag = ops[i + 1].tag()
    let degs = detect_degradation(ops[i])
    for d in degs {
      let desc = match d.kind {
        DivisionByZero => "除零退化从 " + from_tag + " 传播至 " + to_tag
        SingularMatrix => "奇异矩阵从 " + from_tag + " 传播至 " + to_tag
        FieldDiscontinuity =>
          "场间断从 " + from_tag + " 传播至 " + to_tag
        Overflow => "溢出从 " + from_tag + " 传播至 " + to_tag
        NaNValue => "NaN 从 " + from_tag + " 传播至 " + to_tag
        InfValue => "Inf 从 " + from_tag + " 传播至 " + to_tag
      }
      steps.push({
        from_op_tag: from_tag,
        to_op_tag: to_tag,
        degradation_kind: d.kind,
        propagation_desc: desc,
      })
    }
  }
  let total = steps.length()
  let summary = "全算子传播分析: " +
    total.to_string() +
    " 处退化传播"
  { steps, total_propagations: total, chain_length: n, summary, }
}

///|
/// 管道是否有传播风险。
/// Whether pipeline has propagation risk.
pub fn has_propagation_risk(pipeline : @imgir.IRPipeline) -> Bool {
  analyze_propagation(pipeline).total_propagations > 0
}

///|
/// 获取管道的传播链。
/// Get propagation chain of a pipeline.
pub fn propagation_chain(
  pipeline : @imgir.IRPipeline,
) -> Array[PropagationStep] {
  analyze_propagation(pipeline).steps
}

///|
/// 传播报告是否无风险。
/// Whether propagation report has no risk.
pub fn PropagationReport::is_safe(self : PropagationReport) -> Bool {
  self.total_propagations == 0
}
