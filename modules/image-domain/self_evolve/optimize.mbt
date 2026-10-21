// 管道优化 — 消除冗余 + 合并相邻
// Pipeline optimization: remove redundant + merge adjacent

///|
/// 优化管道：消除恒等算子 + 互逆算子对 + 合并相邻同类算子。
/// Optimize pipeline: remove identity + inverse pairs + merge adjacent.
pub fn optimize_pipeline(pipeline : @imgir.IRPipeline) -> @imgir.IRPipeline {
  let ops = pipeline.ops
  let result : Array[@imgir.IROp] = []
  for op in ops {
    if is_identity_op(op) {
      ()
    } else if result.length() > 0 &&
      check_inverse_pair(result[result.length() - 1], op) {
      ignore(result.pop())
    } else if result.length() > 0 && can_merge(result[result.length() - 1], op) {
      let last = result[result.length() - 1]
      ignore(result.pop())
      result.push(merge_ops(last, op))
    } else {
      result.push(op)
    }
  }
  let mut pipe = @imgir.IRPipeline::new()
  for op in result {
    pipe = pipe.add(op)
  }
  pipe
}

///|
/// 生成优化建议（不实际优化，仅报告可优化点）。
/// Generate optimization suggestions (report only, no actual optimization).
pub fn suggest_optimizations(
  pipeline : @imgir.IRPipeline,
) -> Array[OptimizationSuggestion] {
  let ops = pipeline.ops
  let suggestions : Array[OptimizationSuggestion] = []
  // 检查恒等算子
  for i in 0..<ops.length() {
    if is_identity_op(ops[i]) {
      suggestions.push({
        kind: RemoveIdentity,
        op_indices: [i],
        description: "位置 " + i.to_string() + " 是恒等算子，可移除",
        before_count: 1,
        after_count: 0,
      })
    }
  }
  // 检查互逆算子对
  for i in 0..<(ops.length() - 1) {
    if check_inverse_pair(ops[i], ops[i + 1]) {
      suggestions.push({
        kind: RemoveRedundant,
        op_indices: [i, i + 1],
        description: "位置 " +
        i.to_string() +
        " 和 " +
        (i + 1).to_string() +
        " 互逆，可移除",
        before_count: 2,
        after_count: 0,
      })
    }
  }
  // 检查可合并的相邻算子
  for i in 0..<(ops.length() - 1) {
    if can_merge(ops[i], ops[i + 1]) {
      suggestions.push({
        kind: MergeAdjacent,
        op_indices: [i, i + 1],
        description: "位置 " +
        i.to_string() +
        " 和 " +
        (i + 1).to_string() +
        " 可合并",
        before_count: 2,
        after_count: 1,
      })
    }
  }
  suggestions
}

///|
/// 完整优化：返回优化报告。
/// Full optimization: return optimization report.
pub fn optimize_all(pipeline : @imgir.IRPipeline) -> OptimizationReport {
  let optimized = optimize_pipeline(pipeline)
  let suggestions = suggest_optimizations(pipeline)
  {
    original_length: pipeline.length(),
    optimized_length: optimized.length(),
    suggestions,
    optimized_pipeline: optimized,
  }
}

///|
/// 计算优化后的算子数（不实际构建管道）。
/// Count ops after optimization (without building pipeline).
pub fn optimized_op_count(pipeline : @imgir.IRPipeline) -> Int32 {
  optimize_pipeline(pipeline).length()
}
