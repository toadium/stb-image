// 智能修复策略 — 多策略修复（保守/激进/最优）+ 质量评分
// Smart repair: multi-strategy repair + quality scoring
//
// Phase 6 v287: 将退化修复从"单一策略"推向"多策略对比 + 最优选择"。

///|
/// 修复策略。
/// Repair strategy.
pub(all) enum RepairStrategy {
  Conservative // 保守：仅修复 Fatal 级退化
  Aggressive // 激进：修复全部退化
  Optimal // 最优：选择质量最高
} derive(Eq, @debug.Debug)

///|
pub extend RepairStrategy with @debug.Debug::{to_repr}

///|
pub extend RepairStrategy with Eq::{not_equal, equal}

///|
/// 单策略修复结果。
/// Single strategy repair result.
pub(all) struct StrategyRepairResult {
  strategy : RepairStrategy
  op_tag : String
  degs_before : Int32
  degs_after : Int32
  quality_score : Int32
  repair_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend StrategyRepairResult with @debug.Debug::{to_repr}

///|
pub extend StrategyRepairResult with Eq::{not_equal, equal}

// 保守修复：仅修复 Fatal 级退化（Resize/Crop 零尺寸、GaussianBlur sigma=0）

///|
fn repair_op_conservative(op : @imgir.IROp) -> @imgir.IROp {
  match op {
    Resize(w, h) => {
      let nw = if w == 0 { 1 } else { w }
      let nh = if h == 0 { 1 } else { h }
      @imgir.Resize(nw, nh)
    }
    Crop(x, y, w, h) => {
      let nw = if w == 0 { 1 } else { w }
      let nh = if h == 0 { 1 } else { h }
      @imgir.Crop(x, y, nw, nh)
    }
    GaussianBlur(r, sigma) => {
      let nsigma = if sigma == 0.0F { 1.0F } else { sigma }
      @imgir.GaussianBlur(r, nsigma)
    }
    _ => op
  }
}

// 质量评分：修复后退化越少分越高（0-100）

///|
fn quality_score(op : @imgir.IROp) -> Int32 {
  let degs = detect_degradation(op)
  let score = 100 - degs.length() * 20
  if score < 0 {
    0
  } else {
    score
  }
}

///|
/// 按策略修复算子。
/// Repair op with a given strategy.
pub fn repair_op_strategy(
  op : @imgir.IROp,
  strategy : RepairStrategy,
) -> @imgir.IROp {
  match strategy {
    Conservative => repair_op_conservative(op)
    Aggressive => repair_op(op)
    Optimal => repair_op(op)
  }
}

///|
/// 三策略对比修复。
/// Compare all three strategies.
pub fn repair_with_strategies(op : @imgir.IROp) -> Array[StrategyRepairResult] {
  let strategies = [Conservative, Aggressive, Optimal]
  let results : Array[StrategyRepairResult] = []
  let degs_before = detect_degradation(op).length()
  for s in strategies {
    let repaired = repair_op_strategy(op, s)
    let degs_after = detect_degradation(repaired).length()
    let score = quality_score(repaired)
    let desc = match s {
      Conservative =>
        "保守修复: " + degs_after.to_string() + " 退化剩余"
      Aggressive => "激进修复: " + degs_after.to_string() + " 退化剩余"
      Optimal => "最优修复: " + degs_after.to_string() + " 退化剩余"
    }
    results.push({
      strategy: s,
      op_tag: op.tag(),
      degs_before,
      degs_after,
      quality_score: score,
      repair_desc: desc,
    })
  }
  results
}

///|
/// 选择最优修复（质量分最高）。
/// Select best repair (highest quality score).
pub fn best_repair(op : @imgir.IROp) -> StrategyRepairResult {
  let results = repair_with_strategies(op)
  let mut best = results[0]
  for r in results {
    if r.quality_score > best.quality_score {
      best = r
    }
  }
  best
}

///|
/// 对全部 19 种算子选择最优修复。
/// Best repair for all 19 op variants.
pub fn best_repair_all() -> Array[StrategyRepairResult] {
  let results : Array[StrategyRepairResult] = []
  for op in all_ops() {
    results.push(best_repair(op))
  }
  results
}

///|
/// 修复是否完全（退化清零）。
/// Whether repair is complete (zero degradation).
pub fn StrategyRepairResult::is_complete(self : StrategyRepairResult) -> Bool {
  self.degs_after == 0
}

///|
/// 修复是否改善了质量。
/// Whether repair improved quality.
pub fn StrategyRepairResult::is_improvement(
  self : StrategyRepairResult,
) -> Bool {
  self.degs_after < self.degs_before
}
