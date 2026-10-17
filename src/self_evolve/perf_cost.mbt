// 算子静态成本估算 — 基于复杂度模型
// Op static cost estimation: based on complexity model

///|
/// 估算单个算子的静态成本。
/// Estimate static cost of a single op.
pub fn estimate_op_cost(op : @imgir.IROp) -> OpCost {
  let tag = op.tag()
  match op {
    @imgir.FlipH =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 10, }
    @imgir.FlipV =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 10, }
    @imgir.Rotate90 =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 10, }
    @imgir.ToGray =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 15, }
    @imgir.Brightness(_) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 5, }
    @imgir.Resize(_, _) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 30, }
    @imgir.Crop(_, _, _, _) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 8, }
    @imgir.GaussianBlur(_, _) =>
      { op_tag: tag, time_complexity: "O(n*r^2)", estimated_cost: 50, }
    @imgir.BoxBlur(_) =>
      { op_tag: tag, time_complexity: "O(n*r)", estimated_cost: 40, }
    @imgir.Sharpen(_) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 20, }
    @imgir.ToScalarField =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 12, }
    @imgir.ScalarFieldToImage =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 12, }
    @imgir.FieldGradient =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 25, }
    @imgir.FieldLaplacian =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 25, }
    @imgir.FieldIntegrate =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 18, }
    @imgir.FieldClamp(_, _) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 10, }
    @imgir.FieldMask(_) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 10, }
    @imgir.STSnapshot(_) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 35, }
    @imgir.STInterpolate(_) =>
      { op_tag: tag, time_complexity: "O(n)", estimated_cost: 35, }
  }
}

///|
/// 估算管道总成本。
/// Estimate total cost of a pipeline.
pub fn estimate_pipeline_cost(pipeline : @imgir.IRPipeline) -> PerfBaseline {
  let ops = pipeline.ops
  let op_costs : Array[OpCost] = []
  let mut total = 0
  for op in ops {
    let cost = estimate_op_cost(op)
    op_costs.push(cost)
    total = total + cost.estimated_cost
  }
  {
    pipeline_desc: @imgir.ir_describe(pipeline),
    total_cost: total,
    op_count: ops.length(),
    op_costs,
  }
}

///|
/// 检测优化前后是否性能回归。
/// Check for performance regression between original and optimized.
pub fn check_regression(
  original : PerfBaseline,
  optimized : PerfBaseline,
) -> PerfRegression {
  let delta = optimized.total_cost - original.total_cost
  {
    original_cost: original.total_cost,
    optimized_cost: optimized.total_cost,
    delta,
    is_regression: delta > 0,
  }
}

///|
/// 对管道执行优化并检测性能回归。
/// Optimize pipeline and check for performance regression.
pub fn perf_optimize_check(pipeline : @imgir.IRPipeline) -> PerfRegression {
  let original = estimate_pipeline_cost(pipeline)
  let optimized_pipe = optimize_pipeline(pipeline)
  let optimized = estimate_pipeline_cost(optimized_pipe)
  check_regression(original, optimized)
}

///|
/// 比较两个管道的成本。
/// Compare cost of two pipelines.
pub fn compare_pipelines(
  pipe1 : @imgir.IRPipeline,
  pipe2 : @imgir.IRPipeline,
) -> PerfRegression {
  let baseline1 = estimate_pipeline_cost(pipe1)
  let baseline2 = estimate_pipeline_cost(pipe2)
  check_regression(baseline1, baseline2)
}
