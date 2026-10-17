// 自演化 CI 集成 — moon test 自动演化钩子 + 回归门禁
// CI integration: auto-evolution hooks + regression gate
//
// Phase 5 v284: 将自演化集成到 CI — 门禁检查（grill + repair + optimize）+ 回归检测。

///|
/// CI 门禁结果。
/// CI gate result.
pub(all) struct CIGateResult {
  passed : Bool
  total_checks : Int
  failed_checks : Int
  gate_summary : String
} derive(Eq, @debug.Debug)

///|
pub extend CIGateResult with @debug.Debug::{to_repr}

///|
pub extend CIGateResult with Eq::{not_equal, equal}

///|
/// CI 门禁检查：对管道执行 grill + repair + optimize 全套检查。
/// CI gate check: run grill + repair + optimize on a pipeline.
pub fn ci_gate_check(pipeline : @imgir.IRPipeline) -> CIGateResult {
  let grill_report = run_grill_check(pipeline)
  let repair_rep = repair_report(pipeline)
  let opt_verified = optimize_verified(pipeline)
  // 三项检查
  let checks : Array[(String, Bool)] = []
  checks.push(("grill_all_passed", grill_report.all_passed()))
  checks.push(("repair_fully_repaired", repair_rep.is_fully_repaired()))
  checks.push(("optimize_verified", opt_verified))
  let total = checks.length()
  let mut failed = 0
  for c in checks {
    if !c.1 {
      failed = failed + 1
    }
  }
  let passed = failed == 0
  let summary = "CI 门禁: " +
    (total - failed).to_string() +
    "/" +
    total.to_string() +
    " 通过, " +
    failed.to_string() +
    " 失败"
  { passed, total_checks: total, failed_checks: failed, gate_summary: summary, }
}

///|
/// 对全部 19 种算子执行 CI 门禁检查。
/// Run CI gate check on all 19 op variants.
pub fn ci_gate_all() -> Array[CIGateResult] {
  let results : Array[CIGateResult] = []
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    results.push(ci_gate_check(pipe))
  }
  results
}

///|
/// 回归门禁：优化后不劣化 + 修复后无退化。
/// Regression gate: optimization non-degrading + repair fully fixed.
pub fn ci_regression_gate(pipeline : @imgir.IRPipeline) -> Bool {
  let opt_ok = optimize_verified(pipeline)
  let repair_rep = repair_report(pipeline)
  opt_ok && repair_rep.is_fully_repaired()
}

///|
/// 全部 19 算子是否通过回归门禁。
/// Whether all 19 ops pass regression gate.
pub fn ci_regression_all_pass() -> Bool {
  let mut all_ok = true
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    if !ci_regression_gate(pipe) {
      all_ok = false
    }
  }
  all_ok
}

///|
/// CI 门禁通过率（0-100）。
/// CI gate pass rate (0-100).
pub fn CIGateResult::pass_rate(self : CIGateResult) -> Int {
  if self.total_checks == 0 {
    100
  } else {
    (self.total_checks - self.failed_checks) * 100 / self.total_checks
  }
}

///|
/// CI 门禁是否全通过。
/// Whether CI gate fully passed.
pub fn CIGateResult::is_green(self : CIGateResult) -> Bool {
  self.failed_checks == 0
}
