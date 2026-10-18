// 管道优化建议 — 基于等价性与退化分析推荐管道优化
// Pipeline optimization suggestion: recommend optimizations based on equivalence and degradation
//
// Phase 8 v299: 将演化从"推荐"推向"管道优化" — 主动建议如何优化管道结构。

///|
/// 优化建议类型。
/// Optimization suggestion kind.
pub(all) enum SuggestionKind {
  RemoveRedundant
  ReorderOps
  MergeAdjacent
  SplitPipeline
  NoOptimization
} derive(Eq, @debug.Debug)

///|
pub extend SuggestionKind with @debug.Debug::{to_repr}

///|
pub extend SuggestionKind with Eq::{not_equal, equal}

///|
/// 单条管道优化建议。
/// Single pipeline optimization suggestion.
pub(all) struct PipelineOptSuggestion {
  pipeline_desc : String
  suggestion_kind : SuggestionKind
  estimated_benefit : Int
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend PipelineOptSuggestion with @debug.Debug::{to_repr}

///|
pub extend PipelineOptSuggestion with Eq::{not_equal, equal}

///|
/// 管道优化报告。
/// Pipeline optimization report.
pub(all) struct PipelineOptReport {
  suggestions : Array[PipelineOptSuggestion]
  total : Int
  best_benefit : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend PipelineOptReport with @debug.Debug::{to_repr}

///|
pub extend PipelineOptReport with Eq::{not_equal, equal}

///|
/// 找出管道中的冗余算子标签（连续相同标签）。
/// Find redundant op tags in pipeline (consecutive same tags).
pub fn find_redundant_ops(pipeline : @imgir.IRPipeline) -> Array[String] {
  let result : Array[String] = []
  let ops = pipeline.ops
  let n = ops.length()
  for i in 1..<n {
    let prev_tag = ops[i - 1].tag()
    let curr_tag = ops[i].tag()
    if prev_tag == curr_tag {
      result.push(curr_tag)
    }
  }
  result
}

///|
/// 估算管道优化收益（0-100）。
/// Estimate pipeline optimization benefit (0-100).
pub fn estimate_benefit(pipeline : @imgir.IRPipeline) -> Int {
  let ops = pipeline.ops
  let n = ops.length()
  let redundant = find_redundant_ops(pipeline)
  let redundant_count = redundant.length()
  let degs = analyze_propagation(pipeline)
  let deg_count = degs.total_propagations
  let benefit = redundant_count * 20 + deg_count * 5
  if benefit > 100 {
    100
  } else if benefit == 0 && n > 5 {
    10
  } else {
    benefit
  }
}

///|
/// 为管道生成优化建议。
/// Generate optimization suggestions for a pipeline.
pub fn suggest_optimization(pipeline : @imgir.IRPipeline) -> PipelineOptReport {
  let suggestions : Array[PipelineOptSuggestion] = []
  let desc = @imgir.ir_describe(pipeline)
  let ops = pipeline.ops
  let n = ops.length()
  let redundant = find_redundant_ops(pipeline)
  let mut best_benefit = 0
  if redundant.length() > 0 {
    let benefit = redundant.length() * 20
    if benefit > best_benefit {
      best_benefit = benefit
    }
    suggestions.push({
      pipeline_desc: desc,
      suggestion_kind: RemoveRedundant,
      estimated_benefit: benefit,
      description: "移除 " +
      redundant.length().to_string() +
      " 个冗余算子 (" +
      redundant[0] +
      " 等)",
    })
  }
  let prop_report = analyze_propagation(pipeline)
  if prop_report.total_propagations > 0 {
    let benefit = prop_report.total_propagations * 5
    if benefit > best_benefit {
      best_benefit = benefit
    }
    suggestions.push({
      pipeline_desc: desc,
      suggestion_kind: ReorderOps,
      estimated_benefit: benefit,
      description: "重排算子以消除 " +
      prop_report.total_propagations.to_string() +
      " 处退化传播",
    })
  }
  if n >= 2 {
    let mut mergeable = 0
    for i in 1..<n {
      if ops[i - 1].tag() == ops[i].tag() {
        mergeable = mergeable + 1
      }
    }
    if mergeable > 0 {
      let benefit = mergeable * 15
      if benefit > best_benefit {
        best_benefit = benefit
      }
      suggestions.push({
        pipeline_desc: desc,
        suggestion_kind: MergeAdjacent,
        estimated_benefit: benefit,
        description: "合并 " +
        mergeable.to_string() +
        " 对相邻同类算子",
      })
    }
  }
  if n > 6 {
    let benefit = 10
    if benefit > best_benefit {
      best_benefit = benefit
    }
    suggestions.push({
      pipeline_desc: desc,
      suggestion_kind: SplitPipeline,
      estimated_benefit: benefit,
      description: "管道过长 (" +
      n.to_string() +
      " 步)，建议拆分为子管道",
    })
  }
  if suggestions.length() == 0 {
    suggestions.push({
      pipeline_desc: desc,
      suggestion_kind: NoOptimization,
      estimated_benefit: 0,
      description: "管道结构良好，无需优化",
    })
  }
  let total = suggestions.length()
  let summary = "管道优化: " +
    total.to_string() +
    " 条建议, 最高收益 " +
    best_benefit.to_string() +
    "（管道 " +
    desc +
    "）"
  { suggestions, total, best_benefit, summary, }
}

///|
/// 优化报告是否有优化建议。
/// Whether optimization report has suggestions.
pub fn PipelineOptReport::has_suggestions(self : PipelineOptReport) -> Bool {
  self.best_benefit > 0
}
