// 自演化闭环 — 串联 test_gen + degrade + optimize + perf
// Evolution loop: full cycle connecting all self_evolve capabilities

///|
/// 自演化闭环报告。
/// Evolution cycle report.
pub(all) struct EvolveCycleReport {
  pipeline_desc : String
  original_op_count : Int32
  optimized_op_count : Int32
  generated_tests : Array[TestCase]
  found_degradations : Array[DegradationCase]
  optimization_report : OptimizationReport
  perf_regression : PerfRegression
  cycle_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend EvolveCycleReport with @debug.Debug::{to_repr}

///|
pub extend EvolveCycleReport with Eq::{not_equal, equal}

///|
/// 完整自演化闭环：退化发现 → 测试生成 → 管道优化 → 性能回归 → 综合报告。
/// Full evolution cycle: degradation → test gen → optimize → perf → report.
pub fn evolve_full_cycle(pipeline : @imgir.IRPipeline) -> EvolveCycleReport {
  let ops = pipeline.ops
  // 1. 退化发现
  let degradations = scan_degradations(ops)
  // 2. 测试生成
  let tests = evolve_test_suite(ops)
  // 3. 管道优化
  let opt_report = optimize_all(pipeline)
  // 4. 性能回归
  let perf = perf_optimize_check(pipeline)
  // 5. 综合报告
  let summary = "管道 '" +
    @imgir.ir_describe(pipeline) +
    "': " +
    ops.length().to_string() +
    " 算子 → " +
    opt_report.optimized_length.to_string() +
    " 优化后, " +
    tests.length().to_string() +
    " 测试, " +
    degradations.length().to_string() +
    " 退化, 成本变化 " +
    perf.delta.to_string()
  {
    pipeline_desc: @imgir.ir_describe(pipeline),
    original_op_count: ops.length(),
    optimized_op_count: opt_report.optimized_length,
    generated_tests: tests,
    found_degradations: degradations,
    optimization_report: opt_report,
    perf_regression: perf,
    cycle_summary: summary,
  }
}

///|
/// 对全部 19 种算子执行自演化闭环。
/// Run evolution cycle on all 19 op variants.
pub fn evolve_cycle_all() -> Array[EvolveCycleReport] {
  let reports : Array[EvolveCycleReport] = []
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    reports.push(evolve_full_cycle(pipe))
  }
  reports
}

///|
/// 闭环是否改善了管道（算子减少且成本降低）。
/// Whether cycle improved the pipeline (fewer ops and lower cost).
pub fn EvolveCycleReport::is_improved(self : EvolveCycleReport) -> Bool {
  self.optimized_op_count < self.original_op_count &&
  self.perf_regression.is_improvement()
}

///|
/// 闭环是否有退化风险。
/// Whether cycle has degradation risk.
pub fn EvolveCycleReport::has_degradation_risk(
  self : EvolveCycleReport,
) -> Bool {
  self.found_degradations.length() > 0
}

///|
/// 闭环安全度（0-100，越高越安全）。
/// Cycle safety score (0-100, higher is safer).
pub fn EvolveCycleReport::safety_score(self : EvolveCycleReport) -> Int32 {
  let deg_penalty = self.found_degradations.length() * 10

  let mut severe_count = 0
  for d in self.found_degradations {
    match d.severity {
      Warning => ()
      Critical => severe_count = severe_count + 1
      Fatal => severe_count = severe_count + 1
    }
  }
  let severe_penalty = severe_count * 20
  let score = 100 - deg_penalty - severe_penalty
  if score < 0 {
    0
  } else {
    score
  }
}
