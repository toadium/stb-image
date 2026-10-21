// 演化预测模型 — 基于历史预测演化结果
// Evolution prediction model: predict evolution outcomes based on history
//
// Phase 9 v304: 将演化从"评分"推向"预测" — 基于历史数据预测未来演化结果。

///|
/// 预测类型。
/// Prediction kind.
pub(all) enum PredictionKind {
  DegradationLikely
  TestGrowthExpected
  StableOp
  HighRisk
} derive(Eq, @debug.Debug)

///|
pub extend PredictionKind with @debug.Debug::{to_repr}

///|
pub extend PredictionKind with Eq::{not_equal, equal}

///|
/// 单算子演化预测。
/// Evolution prediction for a single op.
pub(all) struct EvolutionPrediction {
  op_tag : String
  kind : PredictionKind
  confidence : Int32
  predicted_value : Int32
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend EvolutionPrediction with @debug.Debug::{to_repr}

///|
pub extend EvolutionPrediction with Eq::{not_equal, equal}

///|
/// 预测报告。
/// Prediction report.
pub(all) struct PredictionReport {
  predictions : Array[EvolutionPrediction]
  total : Int32
  high_risk_count : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend PredictionReport with @debug.Debug::{to_repr}

///|
pub extend PredictionReport with Eq::{not_equal, equal}

///|
/// 预测单个算子的演化结果。
/// Predict evolution outcome for a single op.
pub fn predict_op(op : @imgir.IROp) -> EvolutionPrediction {
  let tag = op.tag()
  let degs = detect_degradation(op)
  let deg_count = degs.length()
  let score = score_op(op)
  let log = history_log()
  let mut avg_test_growth = 0
  let entries = log.entries
  let n = entries.length()
  if n >= 2 {
    let total_growth = entries[n - 1].test_count - entries[0].test_count
    avg_test_growth = total_growth / (n - 1)
  }
  if deg_count > 0 && score.score >= 70 {
    {
      op_tag: tag,
      kind: HighRisk,
      confidence: 90,
      predicted_value: deg_count,
      description: tag +
      " 高风险: " +
      deg_count.to_string() +
      " 个退化, 评分 " +
      score.score.to_string(),
    }
  } else if deg_count > 0 {
    {
      op_tag: tag,
      kind: DegradationLikely,
      confidence: 70,
      predicted_value: deg_count,
      description: tag +
      " 可能退化: " +
      deg_count.to_string() +
      " 个退化",
    }
  } else if avg_test_growth > 0 {
    {
      op_tag: tag,
      kind: TestGrowthExpected,
      confidence: 60,
      predicted_value: avg_test_growth,
      description: tag +
      " 预期测试增长 " +
      avg_test_growth.to_string() +
      " 个",
    }
  } else {
    {
      op_tag: tag,
      kind: StableOp,
      confidence: 80,
      predicted_value: 0,
      description: tag + " 稳定: 无退化风险",
    }
  }
}

///|
/// 预测所有算子的演化结果。
/// Predict evolution outcomes for all ops.
pub fn predict_all() -> PredictionReport {
  let predictions : Array[EvolutionPrediction] = []
  let mut high_risk = 0
  for op in all_ops() {
    let p = predict_op(op)
    if p.kind is HighRisk {
      high_risk = high_risk + 1
    }
    predictions.push(p)
  }
  let total = predictions.length()
  let summary = "演化预测: " +
    total.to_string() +
    " 算子, " +
    high_risk.to_string() +
    " 高风险"
  { predictions, total, high_risk_count: high_risk, summary, }
}

///|
/// 预测报告是否有高风险。
/// Whether prediction report has high-risk items.
pub fn PredictionReport::has_high_risk(self : PredictionReport) -> Bool {
  self.high_risk_count > 0
}
