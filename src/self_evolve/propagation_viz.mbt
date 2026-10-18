// 退化传播可视化 — 生成传播链的可视化描述
// Degradation propagation visualization: generate visual description of propagation chain
//
// Phase 8 v296: 将传播分析从"数据"推向"可视化" — ASCII/Mermaid/Text 三格式。

///|
/// 可视化格式。
/// Visualization format.
pub(all) enum VizFormat {
  AsciiViz
  MermaidViz
  TextViz
} derive(Eq, @debug.Debug)

///|
pub extend VizFormat with @debug.Debug::{to_repr}

///|
pub extend VizFormat with Eq::{not_equal, equal}

///|
/// 传播可视化结果。
/// Propagation visualization result.
pub(all) struct PropagationViz {
  format : VizFormat
  content : String
  node_count : Int
  edge_count : Int
} derive(Eq, @debug.Debug)

///|
pub extend PropagationViz with @debug.Debug::{to_repr}

///|
pub extend PropagationViz with Eq::{not_equal, equal}

///|
/// 生成 ASCII 格式传播链可视化。
/// Generate ASCII format propagation chain visualization.
pub fn visualize_propagation_ascii(pipeline : @imgir.IRPipeline) -> String {
  let ops = pipeline.ops
  let n = ops.length()
  let mut result = "=== 退化传播链（ASCII）===\n"
  for i in 0..<n {
    let tag = ops[i].tag()
    let degs = detect_degradation(ops[i])
    let mut line = "[" + i.to_string() + "] " + tag
    if degs.length() > 0 {
      line = line + " ⚠️"
      for d in degs {
        line = line + " (" + d.description + ")"
      }
    } else {
      line = line + " ✅"
    }
    result = result + line + "\n"
    if i + 1 < n {
      let has_prop = degs.length() > 0
      result = result + (if has_prop { "  |⚠️ 传播\n" } else { "  |\n" })
    }
  }
  result
}

///|
/// 生成 Mermaid 格式传播链可视化。
/// Generate Mermaid format propagation chain visualization.
pub fn visualize_propagation_mermaid(pipeline : @imgir.IRPipeline) -> String {
  let ops = pipeline.ops
  let n = ops.length()
  let mut result = "graph LR\n"
  for i in 0..<n {
    let tag = ops[i].tag()
    let degs = detect_degradation(ops[i])
    let label = if degs.length() > 0 { tag + "⚠️" } else { tag }
    result = result + "  N" + i.to_string() + "[" + label + "]\n"
    if i + 1 < n {
      let has_prop = degs.length() > 0
      result = result +
        "  N" +
        i.to_string() +
        " -->" +
        (if has_prop { "|传播|" } else { "" }) +
        " N" +
        (i + 1).to_string() +
        "\n"
    }
  }
  result
}

///|
/// 生成文本格式传播链可视化。
/// Generate text format propagation chain visualization.
pub fn visualize_propagation_text(pipeline : @imgir.IRPipeline) -> String {
  let report = analyze_propagation(pipeline)
  let ops = pipeline.ops
  let mut result = "退化传播分析报告\n"
  result = result + "管道: " + @imgir.ir_describe(pipeline) + "\n"
  result = result + "算子数: " + ops.length().to_string() + "\n"
  result = result + "传播数: " + report.total_propagations.to_string() + "\n"
  result = result + "链长: " + report.chain_length.to_string() + "\n"
  if report.steps.length() > 0 {
    result = result + "传播步骤:\n"
    for s in report.steps {
      result = result + "  " + s.propagation_desc + "\n"
    }
  }
  result
}

///|
/// 按指定格式生成传播链可视化。
/// Generate propagation chain visualization in specified format.
pub fn visualize_propagation(
  pipeline : @imgir.IRPipeline,
  format : VizFormat,
) -> PropagationViz {
  let content = match format {
    AsciiViz => visualize_propagation_ascii(pipeline)
    MermaidViz => visualize_propagation_mermaid(pipeline)
    TextViz => visualize_propagation_text(pipeline)
  }
  let nodes = pipeline.ops.length()
  let report = analyze_propagation(pipeline)
  { format, content, node_count: nodes, edge_count: report.total_propagations, }
}

///|
/// 可视化内容是否非空。
/// Whether visualization content is non-empty.
pub fn PropagationViz::is_valid(self : PropagationViz) -> Bool {
  self.content.length() > 0
}
