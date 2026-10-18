// 算子等价性验证 — 验证两个算子序列是否等价
// Op equivalence verification: verify whether two op sequences are equivalent
//
// Phase 7 v294: 将演化从"独立"推向"等价验证" — 证明两个管道产生相同结果。

///|
/// 单次等价性检查结果。
/// Single equivalence check result.
pub(all) struct EquivalenceCheck {
  pipeline_a_desc : String
  pipeline_b_desc : String
  is_equivalent : Bool
  reason : String
} derive(Eq, @debug.Debug)

///|
pub extend EquivalenceCheck with @debug.Debug::{to_repr}

///|
pub extend EquivalenceCheck with Eq::{not_equal, equal}

///|
/// 等价性验证报告。
/// Equivalence verification report.
pub(all) struct EquivalenceReport {
  checks : Array[EquivalenceCheck]
  total_equivalent : Int
  total_not_equivalent : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend EquivalenceReport with @debug.Debug::{to_repr}

///|
pub extend EquivalenceReport with Eq::{not_equal, equal}

///|
/// 检查两个管道是否等价（相同算子序列）。
/// Check whether two pipelines are equivalent (same op sequence).
pub fn check_equivalence(
  pipe_a : @imgir.IRPipeline,
  pipe_b : @imgir.IRPipeline,
) -> EquivalenceCheck {
  let desc_a = @imgir.ir_describe(pipe_a)
  let desc_b = @imgir.ir_describe(pipe_b)
  let ops_a = pipe_a.ops
  let ops_b = pipe_b.ops
  let len_a = ops_a.length()
  let len_b = ops_b.length()
  let mut is_equiv = true
  let mut reason = ""
  if len_a != len_b {
    is_equiv = false
    reason = "长度不同: " + len_a.to_string() + " vs " + len_b.to_string()
  } else {
    for i in 0..<len_a {
      let tag_a = ops_a[i].tag()
      let tag_b = ops_b[i].tag()
      if tag_a != tag_b {
        is_equiv = false
        reason = "位置 " + i.to_string() + ": " + tag_a + " vs " + tag_b
        break
      }
    }
    if is_equiv {
      reason = "算子序列完全相同"
    }
  }
  {
    pipeline_a_desc: desc_a,
    pipeline_b_desc: desc_b,
    is_equivalent: is_equiv,
    reason,
  }
}

///|
/// 简化等价判断。
/// Simplified equivalence check.
pub fn are_equivalent(
  pipe_a : @imgir.IRPipeline,
  pipe_b : @imgir.IRPipeline,
) -> Bool {
  check_equivalence(pipe_a, pipe_b).is_equivalent
}

///|
/// 检查所有算子的自等价性（每个算子与自己等价）。
/// Check self-equivalence for all ops.
pub fn check_equivalence_all() -> EquivalenceReport {
  let checks : Array[EquivalenceCheck] = []
  let ops = all_ops()
  for op in ops {
    let pipe_a = @imgir.IRPipeline::new().add(op)
    let pipe_b = @imgir.IRPipeline::new().add(op)
    checks.push(check_equivalence(pipe_a, pipe_b))
  }
  let mut equiv_count = 0
  let mut non_equiv_count = 0
  for c in checks {
    if c.is_equivalent {
      equiv_count = equiv_count + 1
    } else {
      non_equiv_count = non_equiv_count + 1
    }
  }
  let summary = "等价性验证: " +
    equiv_count.to_string() +
    " 等价, " +
    non_equiv_count.to_string() +
    " 不等价"
  {
    checks,
    total_equivalent: equiv_count,
    total_not_equivalent: non_equiv_count,
    summary,
  }
}

///|
/// 获取与指定算子等价的算子标签（相同 tag 的算子）。
/// Get equivalent op tags (ops with same tag).
pub fn equivalence_class(op : @imgir.IROp) -> Array[String] {
  let target_tag = op.tag()
  let result : Array[String] = []
  for other in all_ops() {
    if other.tag() == target_tag {
      result.push(other.tag())
    }
  }
  result
}

///|
/// 等价性报告是否全部等价。
/// Whether all checks are equivalent.
pub fn EquivalenceReport::all_equivalent(self : EquivalenceReport) -> Bool {
  self.total_not_equivalent == 0
}
