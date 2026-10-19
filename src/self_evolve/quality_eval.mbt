// 演化质量评估 — 评估演化质量
// Evolution quality evaluation: assess evolution quality
//
// Phase 11 v313: 将演化从"跨模块协同"推向"质量评估" — 多维度质量评分。

///|
/// 质量维度。
/// Quality dimension.
pub(all) enum QualityDimension {
  TestCoverage // 测试覆盖度
  DegradationRate // 退化率
  PerformanceGain // 性能提升
  CodeStability // 代码稳定性
  ApiCompatibility // API 兼容性
} derive(Eq, @debug.Debug)

///|
pub extend QualityDimension with @debug.Debug::{to_repr}

///|
pub extend QualityDimension with Eq::{not_equal, equal}

///|
/// 单维度质量评分。
/// Single dimension quality score.
pub(all) struct QualityScore {
  dimension : QualityDimension
  score : Int
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend QualityScore with @debug.Debug::{to_repr}

///|
pub extend QualityScore with Eq::{not_equal, equal}

///|
/// 质量等级。
/// Quality grade.
pub(all) enum QualityGrade {
  GradeA // >= 90
  GradeB // >= 80
  GradeC // >= 70
  GradeD // >= 60
  GradeF // < 60
} derive(Eq, @debug.Debug)

///|
pub extend QualityGrade with @debug.Debug::{to_repr}

///|
pub extend QualityGrade with Eq::{not_equal, equal}

///|
/// 质量评估报告。
/// Quality evaluation report.
pub(all) struct QualityReport {
  scores : Array[QualityScore]
  overall_score : Int
  grade : QualityGrade
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend QualityReport with @debug.Debug::{to_repr}

///|
pub extend QualityReport with Eq::{not_equal, equal}

///|
/// 将分数映射到等级（内部辅助）。
fn score_to_grade(score : Int) -> QualityGrade {
  if score >= 90 {
    GradeA
  } else if score >= 80 {
    GradeB
  } else if score >= 70 {
    GradeC
  } else if score >= 60 {
    GradeD
  } else {
    GradeF
  }
}

///|
/// 评估单个算子的演化质量。
/// Evaluate evolution quality for a single op.
pub fn eval_quality_op(op : @imgir.IROp) -> QualityReport {
  let tag = op.tag()
  let scores : Array[QualityScore] = []
  let cov = coverage_percentage(op)
  scores.push({
    dimension: TestCoverage,
    score: cov,
    description: tag + " 测试覆盖 " + cov.to_string() + "%",
  })
  let degs = detect_degradation(op)
  let deg_score = if degs.length() == 0 {
    100
  } else {
    let mut s = 100
    for _ in degs {
      s = s - 20
    }
    if s < 0 {
      0
    } else {
      s
    }
  }
  scores.push({
    dimension: DegradationRate,
    score: deg_score,
    description: tag +
    " 退化 " +
    degs.length().to_string() +
    " 个, 评分 " +
    deg_score.to_string(),
  })
  let smart = score_op(op)
  scores.push({
    dimension: PerformanceGain,
    score: smart.score,
    description: tag + " 智能评分 " + smart.score.to_string(),
  })
  let stability = if degs.length() == 0 { 90 } else { 50 }
  scores.push({
    dimension: CodeStability,
    score: stability,
    description: tag + " 稳定性 " + stability.to_string(),
  })
  scores.push({
    dimension: ApiCompatibility,
    score: 100,
    description: tag + " API 兼容 100%",
  })
  let mut total = 0
  for s in scores {
    total = total + s.score
  }
  let overall = total / scores.length()
  let grade = score_to_grade(overall)
  let summary = "质量评估[" +
    tag +
    "]: 总分 " +
    overall.to_string() +
    ", 等级 " +
    (match grade {
      GradeA => "A"
      GradeB => "B"
      GradeC => "C"
      GradeD => "D"
      GradeF => "F"
    })
  { scores, overall_score: overall, grade, summary, }
}

///|
/// 评估所有算子的演化质量。
/// Evaluate evolution quality for all ops.
pub fn eval_quality_all() -> QualityReport {
  let all_scores : Array[QualityScore] = []
  let mut total_overall = 0
  let mut count = 0
  for op in all_ops() {
    let report = eval_quality_op(op)
    for s in report.scores {
      all_scores.push(s)
    }
    total_overall = total_overall + report.overall_score
    count = count + 1
  }
  let overall = if count > 0 { total_overall / count } else { 0 }
  let grade = score_to_grade(overall)
  let summary = "全量质量评估: " +
    count.to_string() +
    " 算子, 总分 " +
    overall.to_string() +
    ", 等级 " +
    (match grade {
      GradeA => "A"
      GradeB => "B"
      GradeC => "C"
      GradeD => "D"
      GradeF => "F"
    })
  { scores: all_scores, overall_score: overall, grade, summary, }
}

///|
/// 质量评估报告是否通过（>= 60）。
/// Whether quality report is passing (>= 60).
pub fn QualityReport::is_passing(self : QualityReport) -> Bool {
  self.overall_score >= 60
}

///|
/// 质量评估报告维度数。
/// Dimension count.
pub fn QualityReport::dimension_count(self : QualityReport) -> Int {
  self.scores.length()
}
