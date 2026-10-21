// 演化知识图谱 — 将演化经验构建为知识图谱
// Evolution knowledge graph: build knowledge graph from evolution experience
//
// Phase 11 v311: 将演化从"闭环"推向"知识图谱" — 结构化存储演化经验。

///|
/// 知识节点类型。
/// Knowledge node kind.
pub(all) enum KnowledgeNodeKind {
  OpNode // 算子节点
  DegradationNode // 退化模式节点
  FixNode // 修复策略节点
  TestNode // 测试模式节点
  PerfNode // 性能特征节点
} derive(Eq, @debug.Debug)

///|
pub extend KnowledgeNodeKind with @debug.Debug::{to_repr}

///|
pub extend KnowledgeNodeKind with Eq::{not_equal, equal}

///|
/// 知识节点。
/// Knowledge node.
pub(all) struct KnowledgeNode {
  id : String
  kind : KnowledgeNodeKind
  label : String
  confidence : Int32
  occurrence : Int32
} derive(Eq, @debug.Debug)

///|
pub extend KnowledgeNode with @debug.Debug::{to_repr}

///|
pub extend KnowledgeNode with Eq::{not_equal, equal}

///|
/// 知识边类型。
/// Knowledge edge kind.
pub(all) enum KnowledgeEdgeKind {
  Causes // 导致
  Fixes // 修复
  Prevents // 预防
  Depends // 依赖
  Equivalent // 等价
} derive(Eq, @debug.Debug)

///|
pub extend KnowledgeEdgeKind with @debug.Debug::{to_repr}

///|
pub extend KnowledgeEdgeKind with Eq::{not_equal, equal}

///|
/// 知识边。
/// Knowledge edge.
pub(all) struct KnowledgeEdge {
  source : String
  target : String
  kind : KnowledgeEdgeKind
  weight : Int32
} derive(Eq, @debug.Debug)

///|
pub extend KnowledgeEdge with @debug.Debug::{to_repr}

///|
pub extend KnowledgeEdge with Eq::{not_equal, equal}

///|
/// 知识图谱。
/// Knowledge graph.
pub(all) struct KnowledgeGraph {
  nodes : Array[KnowledgeNode]
  edges : Array[KnowledgeEdge]
} derive(Eq, @debug.Debug)

///|
pub extend KnowledgeGraph with @debug.Debug::{to_repr}

///|
pub extend KnowledgeGraph with Eq::{not_equal, equal}

///|
/// 退化类型转字符串（内部辅助）。
fn degradation_kind_label(kind : DegradationKind) -> String {
  match kind {
    DivisionByZero => "DivisionByZero"
    SingularMatrix => "SingularMatrix"
    FieldDiscontinuity => "FieldDiscontinuity"
    Overflow => "Overflow"
    NaNValue => "NaNValue"
    InfValue => "InfValue"
  }
}

///|
/// 严重程度转置信度（内部辅助）。
fn severity_to_confidence(sev : Severity) -> Int32 {
  match sev {
    Fatal => 100
    Critical => 80
    Warning => 50
  }
}

///|
/// 为单个算子构建知识图谱。
/// Build knowledge graph for a single op.
pub fn build_knowledge_graph_for_op(op : @imgir.IROp) -> KnowledgeGraph {
  let tag = op.tag()
  let nodes : Array[KnowledgeNode] = []
  let edges : Array[KnowledgeEdge] = []
  let op_id = "op:" + tag
  nodes.push({
    id: op_id,
    kind: OpNode,
    label: tag,
    confidence: 100,
    occurrence: 1,
  })
  let degs = detect_degradation(op)
  for deg in degs {
    let deg_label = degradation_kind_label(deg.kind)
    let deg_id = "deg:" + deg.op_tag + ":" + deg_label
    nodes.push({
      id: deg_id,
      kind: DegradationNode,
      label: deg.description,
      confidence: severity_to_confidence(deg.severity),
      occurrence: 1,
    })
    edges.push({ source: op_id, target: deg_id, kind: Causes, weight: 10, })
    let fix_id = "fix:" + deg_label
    nodes.push({
      id: fix_id,
      kind: FixNode,
      label: "修复 " + deg_label,
      confidence: 90,
      occurrence: 1,
    })
    edges.push({ source: deg_id, target: fix_id, kind: Fixes, weight: 8, })
    edges.push({ source: op_id, target: fix_id, kind: Prevents, weight: 6, })
  }
  let cov = coverage_percentage(op)
  let test_id = "test:" + tag
  nodes.push({
    id: test_id,
    kind: TestNode,
    label: tag + " 测试覆盖 " + cov.to_string() + "%",
    confidence: cov,
    occurrence: 1,
  })
  edges.push({
    source: op_id,
    target: test_id,
    kind: Prevents,
    weight: cov / 10,
  })
  let score = score_op(op)
  let perf_id = "perf:" + tag
  nodes.push({
    id: perf_id,
    kind: PerfNode,
    label: tag + " 评分 " + score.score.to_string(),
    confidence: score.score,
    occurrence: 1,
  })
  edges.push({ source: op_id, target: perf_id, kind: Depends, weight: 5, })
  { nodes, edges, }
}

///|
/// 为所有算子构建知识图谱。
/// Build knowledge graph for all ops.
pub fn build_knowledge_graph() -> KnowledgeGraph {
  let all_nodes : Array[KnowledgeNode] = []
  let all_edges : Array[KnowledgeEdge] = []
  for op in all_ops() {
    let sub = build_knowledge_graph_for_op(op)
    for n in sub.nodes {
      all_nodes.push(n)
    }
    for e in sub.edges {
      all_edges.push(e)
    }
  }
  { nodes: all_nodes, edges: all_edges, }
}

///|
/// 按类型查找节点。
/// Find nodes by kind.
pub fn KnowledgeGraph::find_nodes_by_kind(
  self : KnowledgeGraph,
  kind : KnowledgeNodeKind,
) -> Array[KnowledgeNode] {
  let result : Array[KnowledgeNode] = []
  for n in self.nodes {
    if n.kind is OpNode && kind is OpNode {
      result.push(n)
    } else if n.kind is DegradationNode && kind is DegradationNode {
      result.push(n)
    } else if n.kind is FixNode && kind is FixNode {
      result.push(n)
    } else if n.kind is TestNode && kind is TestNode {
      result.push(n)
    } else if n.kind is PerfNode && kind is PerfNode {
      result.push(n)
    }
  }
  result
}

///|
/// 查找算子的退化模式节点。
/// Find degradation nodes for an op.
pub fn KnowledgeGraph::find_degradations(
  self : KnowledgeGraph,
  op_tag : String,
) -> Array[KnowledgeNode] {
  let result : Array[KnowledgeNode] = []
  let prefix = "deg:" + op_tag + ":"
  for n in self.nodes {
    if n.kind is DegradationNode {
      let id = n.id
      if id.length() >= prefix.length() {
        let mut match_prefix = true
        for i in 0..<prefix.length() {
          if id[i] != prefix[i] {
            match_prefix = false
          }
        }
        if match_prefix {
          result.push(n)
        }
      }
    }
  }
  result
}

///|
/// 查找退化模式的修复策略节点。
/// Find fix nodes for a degradation.
pub fn KnowledgeGraph::find_fixes(
  self : KnowledgeGraph,
  degradation_label : String,
) -> Array[KnowledgeNode] {
  let fix_id = "fix:" + degradation_label
  let result : Array[KnowledgeNode] = []
  for n in self.nodes {
    if n.kind is FixNode && n.id == fix_id {
      result.push(n)
    }
  }
  result
}

///|
/// 知识图谱节点数。
/// Knowledge graph node count.
pub fn KnowledgeGraph::node_count(self : KnowledgeGraph) -> Int32 {
  self.nodes.length()
}

///|
/// 知识图谱边数。
/// Knowledge graph edge count.
pub fn KnowledgeGraph::edge_count(self : KnowledgeGraph) -> Int32 {
  self.edges.length()
}

///|
/// 知识图谱是否非空。
/// Whether knowledge graph is non-empty.
pub fn KnowledgeGraph::is_non_empty(self : KnowledgeGraph) -> Bool {
  self.nodes.length() > 0
}
