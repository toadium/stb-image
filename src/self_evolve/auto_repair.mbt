// 退化自动修复 — 检测退化后自动修正参数
// Auto repair: detect degradation and auto-fix parameters
//
// Phase 5 v282: 将退化检测从"发现"推向"修复" — Resize(0,0)→Resize(1,1) 等。

///|
/// 单项修复动作。
/// Single repair action.
pub(all) struct RepairAction {
  op_tag : String
  repaired_op_tag : String
  repair_desc : String
} derive(Eq, @debug.Debug)

///|
pub extend RepairAction with @debug.Debug::{to_repr}

///|
pub extend RepairAction with Eq::{not_equal, equal}

///|
/// 修复报告。
/// Repair report.
pub(all) struct RepairReport {
  original_op_count : Int
  repaired_op_count : Int
  repairs : Array[RepairAction]
  remaining_degradations : Array[DegradationCase]
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend RepairReport with @debug.Debug::{to_repr}

///|
pub extend RepairReport with Eq::{not_equal, equal}

///|
/// 修复单个算子的退化参数。
/// Repair a single op's degraded parameters.
pub fn repair_op(op : @imgir.IROp) -> @imgir.IROp {
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
      let nsigma = if sigma == 0.0F {
        1.0F
      } else if sigma < 0.0F {
        0.0F - sigma
      } else {
        sigma
      }
      @imgir.GaussianBlur(r, nsigma)
    }
    Sharpen(amount) => {
      let na = if amount > 100.0F {
        100.0F
      } else if amount < -100.0F {
        -100.0F
      } else {
        amount
      }
      @imgir.Sharpen(na)
    }
    FieldClamp(lo, hi) => if lo > hi { @imgir.FieldClamp(hi, lo) } else { op }
    FieldMask(threshold) =>
      if threshold > 1000000.0F || threshold < -1000000.0F {
        @imgir.FieldMask(0.0F)
      } else {
        op
      }
    STSnapshot(t) => {
      let nt = if t < 0.0F { 0.0F } else if t > 1.0F { 1.0F } else { t }
      @imgir.STSnapshot(nt)
    }
    STInterpolate(t) => {
      let nt = if t < 0.0F { 0.0F } else if t > 1.0F { 1.0F } else { t }
      @imgir.STInterpolate(nt)
    }
    _ => op
  }
}

///|
/// 修复管道中所有算子的退化。
/// Repair all ops in a pipeline.
pub fn repair_pipeline(pipeline : @imgir.IRPipeline) -> @imgir.IRPipeline {
  let mut pipe = @imgir.IRPipeline::new()
  for op in pipeline.ops {
    pipe = pipe.add(repair_op(op))
  }
  pipe
}

///|
/// 生成修复报告。
/// Generate repair report for a pipeline.
pub fn repair_report(pipeline : @imgir.IRPipeline) -> RepairReport {
  let ops = pipeline.ops
  let original_degs = scan_degradations(ops)
  let repaired_pipe = repair_pipeline(pipeline)
  let repaired_degs = scan_degradations(repaired_pipe.ops)
  let repairs : Array[RepairAction] = []
  for op in ops {
    let degs = detect_degradation(op)
    if degs.length() > 0 {
      let repaired = repair_op(op)
      repairs.push({
        op_tag: op.tag(),
        repaired_op_tag: repaired.tag(),
        repair_desc: "修复 " + degs.length().to_string() + " 处退化",
      })
    }
  }
  let repaired_count = original_degs.length() - repaired_degs.length()
  let summary = "修复 " +
    repaired_count.to_string() +
    " 处退化，剩余 " +
    repaired_degs.length().to_string() +
    " 处"
  {
    original_op_count: ops.length(),
    repaired_op_count: repaired_pipe.ops.length(),
    repairs,
    remaining_degradations: repaired_degs,
    summary,
  }
}

///|
/// 对全部 19 种算子生成修复报告。
/// Generate repair report for all 19 op variants.
pub fn repair_all() -> Array[RepairReport] {
  let reports : Array[RepairReport] = []
  for op in all_ops() {
    let pipe = @imgir.IRPipeline::new().add(op)
    reports.push(repair_report(pipe))
  }
  reports
}

///|
/// 修复后退化是否清零。
/// Whether all degradations are fixed.
pub fn RepairReport::is_fully_repaired(self : RepairReport) -> Bool {
  self.remaining_degradations.length() == 0
}

///|
/// 修复动作数。
/// Number of repair actions.
pub fn RepairReport::repair_count(self : RepairReport) -> Int {
  self.repairs.length()
}
