// 自主决策引擎 — 根据预测结果自主决策演化方向
// Autonomous decision engine: decide evolution direction based on predictions
//
// Phase 10 v306: 将演化从"预测"推向"自主决策" — 根据预测结果自动决定演化动作。

///|
/// 决策动作类型。
/// Decision action type.
pub(all) enum DecisionAction {
  EvolveNow
  DeferEvolution
  SkipEvolution
  EscalateToManual
} derive(Eq, @debug.Debug)

///|
pub extend DecisionAction with @debug.Debug::{to_repr}

///|
pub extend DecisionAction with Eq::{not_equal, equal}

///|
/// 单算子自主决策。
/// Autonomous decision for a single op.
pub(all) struct AutoDecision {
  op_tag : String
  action : DecisionAction
  confidence : Int
  rationale : String
} derive(Eq, @debug.Debug)

///|
pub extend AutoDecision with @debug.Debug::{to_repr}

///|
pub extend AutoDecision with Eq::{not_equal, equal}

///|
/// 决策报告。
/// Decision report.
pub(all) struct DecisionReport {
  decisions : Array[AutoDecision]
  total : Int
  auto_count : Int
  deferred_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend DecisionReport with @debug.Debug::{to_repr}

///|
pub extend DecisionReport with Eq::{not_equal, equal}

///|
/// 为单个算子做自主决策。
/// Make autonomous decision for a single op.
pub fn decide_op(op : @imgir.IROp) -> AutoDecision {
  let tag = op.tag()
  let pred = predict_op(op)

  let action = match pred.kind {
    HighRisk => if pred.confidence >= 80 { EvolveNow } else { EscalateToManual }
    DegradationLikely =>
      if pred.confidence >= 60 {
        EvolveNow
      } else {
        DeferEvolution
      }
    TestGrowthExpected => DeferEvolution
    StableOp => SkipEvolution
  }
  let rationale = match action {
    EvolveNow =>
      tag + " 立即演化: 预测 " + pred.confidence.to_string() + "% 置信"
    DeferEvolution => tag + " 推迟演化: 预期改善，非紧急"
    SkipEvolution => tag + " 跳过演化: 稳定无风险"
    EscalateToManual =>
      tag +
      " 升级人工: 置信度不足 (" +
      pred.confidence.to_string() +
      "%)"
  }
  { op_tag: tag, action, confidence: pred.confidence, rationale, }
}

///|
/// 为所有算子做自主决策。
/// Make autonomous decisions for all ops.
pub fn decide_all() -> DecisionReport {
  let decisions : Array[AutoDecision] = []
  let mut auto_count = 0
  let mut deferred_count = 0
  for op in all_ops() {
    let d = decide_op(op)
    if d.action is EvolveNow {
      auto_count = auto_count + 1
    } else if d.action is DeferEvolution {
      deferred_count = deferred_count + 1
    }
    decisions.push(d)
  }
  let total = decisions.length()
  let summary = "自主决策: " +
    total.to_string() +
    " 算子, " +
    auto_count.to_string() +
    " 自主演化, " +
    deferred_count.to_string() +
    " 推迟"
  { decisions, total, auto_count, deferred_count, summary, }
}

///|
/// 决策报告是否可以全自主执行（无人工升级）。
/// Whether decision report can be fully auto-run (no manual escalation).
pub fn DecisionReport::can_auto_run(self : DecisionReport) -> Bool {
  for d in self.decisions {
    if d.action is EscalateToManual {
      return false
    }
  }
  true
}
