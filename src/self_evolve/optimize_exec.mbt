// 管道优化执行 — 应用 OptimizationSuggestion 到实际 IRPipeline
// Optimize execution: apply suggestions to actual pipeline and verify
//
// Phase 5 v283: 将管道优化从"建议"推向"执行" — 实际应用优化 + 成本验证。

///|
/// 优化执行结果。
/// Optimization execution result.
pub(all) struct OptimizeExecResult {
  original_length : Int
  optimized_length : Int
  ops_reduced : Int
  original_cost : Int
  optimized_cost : Int
  cost_reduced : Int
  is_improved : Bool
  optimized_pipeline_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend OptimizeExecResult with @debug.Debug::{to_repr}

///|
pub extend OptimizeExecResult with Eq::{not_equal, equal}

///|
/// 执行管道优化并返回结果（含成本变化）。
/// Execute pipeline optimization and return result with cost delta.
pub fn exec_optimize(pipeline : @imgir.IRPipeline) -> OptimizeExecResult {
  let report = optimize_all(pipeline)
  let original_baseline = estimate_pipeline_cost(pipeline)
  let optimized_baseline = estimate_pipeline_cost(report.optimized_pipeline)
  let ops_reduced = report.original_length - report.optimized_length
  let cost_reduced = original_baseline.total_cost -
    optimized_baseline.total_cost
  let is_improved = ops_reduced > 0 || cost_reduced > 0
  {
    original_length: report.original_length,
    optimized_length: report.optimized_length,
    ops_reduced,
    original_cost: original_baseline.total_cost,
    optimized_cost: optimized_baseline.total_cost,
    cost_reduced,
    is_improved,
    optimized_pipeline_desc: @imgir.ir_describe(report.optimized_pipeline),
  }
}

///|
/// 对全部 19 种算子执行优化。
/// Execute optimization on all 19 op variants.
pub fn exec_optimize_all() -> Array[OptimizeExecResult] {
  let results : Array[OptimizeExecResult] = []
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    results.push(exec_optimize(pipe))
  }
  results
}

///|
/// 验证优化后管道不劣化（算子数不增加且成本不增加）。
/// Verify optimization does not degrade (ops and cost non-increasing).
pub fn optimize_verified(pipeline : @imgir.IRPipeline) -> Bool {
  let result = exec_optimize(pipeline)
  result.optimized_length <= result.original_length &&
  result.optimized_cost <= result.original_cost
}

///|
/// 优化是否显著（算子减少或成本降低）。
/// Whether optimization is significant.
pub fn OptimizeExecResult::is_significant(self : OptimizeExecResult) -> Bool {
  self.ops_reduced > 0 || self.cost_reduced > 0
}

///|
/// 优化效率（成本降低百分比，0-100）。
/// Optimization efficiency (cost reduction percentage, 0-100).
pub fn OptimizeExecResult::efficiency_pct(self : OptimizeExecResult) -> Int {
  if self.original_cost == 0 {
    0
  } else {
    self.cost_reduced * 100 / self.original_cost
  }
}
