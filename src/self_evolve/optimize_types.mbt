// 算法优化类型 — 优化建议 + 优化报告
// Optimization types: suggestion + report

///|
/// 优化类型。
/// Optimization kind.
pub(all) enum OptimizationKind {
  RemoveRedundant // 消除冗余算子对（如 FlipH ∘ FlipH）
  RemoveIdentity // 消除恒等算子（如 Brightness(0)）
  MergeAdjacent // 合并相邻同类算子（如 Brightness(a) ∘ Brightness(b) → Brightness(a+b)）
} derive(Eq, @debug.Debug)

///|
pub extend OptimizationKind with @debug.Debug::{to_repr}

///|
pub extend OptimizationKind with Eq::{not_equal, equal}

///|
/// 优化建议。
/// Optimization suggestion.
pub(all) struct OptimizationSuggestion {
  kind : OptimizationKind
  op_indices : Array[Int]
  description : String
  before_count : Int
  after_count : Int
} derive(Eq, @debug.Debug)

///|
pub extend OptimizationSuggestion with @debug.Debug::{to_repr}

///|
pub extend OptimizationSuggestion with Eq::{not_equal, equal}

///|
/// 优化报告。
/// Optimization report.
pub(all) struct OptimizationReport {
  original_length : Int
  optimized_length : Int
  suggestions : Array[OptimizationSuggestion]
  optimized_pipeline : @imgir.IRPipeline
} derive(Eq, @debug.Debug)

///|
pub extend OptimizationReport with @debug.Debug::{to_repr}

///|
pub extend OptimizationReport with Eq::{not_equal, equal}

///|
/// 优化是否减少了算子数。
/// Whether optimization reduced op count.
pub fn OptimizationReport::is_reduced(self : OptimizationReport) -> Bool {
  self.optimized_length < self.original_length
}

///|
/// 减少的算子数。
/// Number of ops removed.
pub fn OptimizationReport::reduction(self : OptimizationReport) -> Int {
  self.original_length - self.optimized_length
}
