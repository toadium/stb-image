// 自演化闭环 — 完整的自主演化闭环
// Evolution loop: complete autonomous evolution loop
//
// Phase 10 v309: 将演化从"参数调优"推向"闭环" — 预测→决策→策略→调优→执行→验证。

///|
/// 闭环阶段。
/// Loop phase.
pub(all) enum LoopPhase {
  Predict
  Decide
  Strategize
  Tune
  Execute
  Verify
  Done
} derive(Eq, @debug.Debug)

///|
pub extend LoopPhase with @debug.Debug::{to_repr}

///|
pub extend LoopPhase with Eq::{not_equal, equal}

///|
/// 单个闭环步骤。
/// Single loop step.
pub(all) struct LoopStep {
  phase : LoopPhase
  result_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend LoopStep with @debug.Debug::{to_repr}

///|
pub extend LoopStep with Eq::{not_equal, equal}

///|
/// 闭环执行结果。
/// Loop execution result.
pub(all) struct LoopResult {
  steps : Array[LoopStep]
  total_phases : Int
  success : Bool
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend LoopResult with @debug.Debug::{to_repr}

///|
pub extend LoopResult with Eq::{not_equal, equal}

///|
/// 为单个算子运行完整演化闭环。
/// Run complete evolution loop for a single op.
pub fn run_evolve_loop(op : @imgir.IROp) -> LoopResult {
  let tag = op.tag()
  let steps : Array[LoopStep] = []
  let pred = predict_op(op)
  steps.push({
    phase: Predict,
    result_desc: tag + " 预测: " + pred.description,
  })
  let decision = decide_op(op)
  steps.push({
    phase: Decide,
    result_desc: tag + " 决策: " + decision.rationale,
  })
  let combo = combine_strategies(op)
  steps.push({
    phase: Strategize,
    result_desc: tag + " 策略: " + combo.description,
  })
  let params = tune_params(op)
  steps.push({
    phase: Tune,
    result_desc: tag + " 调优: " + params.length().to_string() + " 参数",
  })
  let sched = create_schedule([op])
  let result = run_schedule(sched)
  steps.push({
    phase: Execute,
    result_desc: tag + " 执行: " + result.summary,
  })
  let degs = detect_degradation(op)
  let verify_desc = if degs.length() == 0 {
    tag + " 验证: 无退化"
  } else {
    tag + " 验证: " + degs.length().to_string() + " 退化残留"
  }
  steps.push({ phase: Verify, result_desc: verify_desc, })
  steps.push({ phase: Done, result_desc: tag + " 闭环完成", })
  let total = steps.length()
  let success = decision.action is EvolveNow || decision.action is SkipEvolution
  let summary = "演化闭环[" +
    tag +
    "]: " +
    total.to_string() +
    " 阶段, " +
    (if success { "成功" } else { "需关注" })
  { steps, total_phases: total, success, summary, }
}

///|
/// 为所有算子运行完整演化闭环。
/// Run complete evolution loop for all ops.
pub fn run_evolve_loop_all() -> LoopResult {
  let all_steps : Array[LoopStep] = []
  let mut all_success = true
  let mut total_ops = 0
  for op in all_ops() {
    let result = run_evolve_loop(op)
    for s in result.steps {
      all_steps.push(s)
    }
    if !result.success {
      all_success = false
    }
    total_ops = total_ops + 1
  }
  let total = all_steps.length()
  let summary = "全量演化闭环: " +
    total_ops.to_string() +
    " 算子, " +
    total.to_string() +
    " 阶段, " +
    (if all_success { "全部成功" } else { "部分需关注" })
  { steps: all_steps, total_phases: total, success: all_success, summary, }
}

///|
/// 闭环结果是否完整完成。
/// Whether loop result is complete.
pub fn LoopResult::is_complete(self : LoopResult) -> Bool {
  self.total_phases > 0
}
