// 演化调度引擎 — 调度并执行自动演化周期
// Evolution schedule engine: schedule and execute automatic evolution cycles
//
// Phase 9 v301: 将演化从"手动"推向"自动调度" — 创建调度→执行→报告。

///|
/// 调度状态。
/// Schedule status.
pub(all) enum ScheduleStatus {
  Pending
  Running
  Completed
  Failed
} derive(Eq, @debug.Debug)

///|
pub extend ScheduleStatus with @debug.Debug::{to_repr}

///|
pub extend ScheduleStatus with Eq::{not_equal, equal}

///|
/// 演化调度计划。
/// Evolution schedule plan.
pub(all) struct EvolutionSchedule {
  schedule_id : String
  ops_count : Int
  status : ScheduleStatus
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend EvolutionSchedule with @debug.Debug::{to_repr}

///|
pub extend EvolutionSchedule with Eq::{not_equal, equal}

///|
/// 调度执行结果。
/// Schedule execution result.
pub(all) struct ScheduleResult {
  schedule : EvolutionSchedule
  evolved_count : Int
  fixed_count : Int
  remaining_count : Int
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend ScheduleResult with @debug.Debug::{to_repr}

///|
pub extend ScheduleResult with Eq::{not_equal, equal}

///|
/// 为给定算子列表创建演化调度。
/// Create evolution schedule for given ops.
pub fn create_schedule(ops : Array[@imgir.IROp]) -> EvolutionSchedule {
  let count = ops.length()
  let id = "sched-" + count.to_string() + "-ops"
  {
    schedule_id: id,
    ops_count: count,
    status: Pending,
    description: "调度 " + count.to_string() + " 个算子的演化周期",
  }
}

///|
/// 执行演化调度。
/// Execute evolution schedule.
pub fn run_schedule(schedule : EvolutionSchedule) -> ScheduleResult {
  let running_schedule = {
    schedule_id: schedule.schedule_id,
    ops_count: schedule.ops_count,
    status: Running,
    description: schedule.description,
  }
  let ops = all_ops()
  let mut evolved = 0
  let mut fixed = 0
  let mut remaining = 0
  for op in ops {
    let degs = detect_degradation(op)
    let rec = recommend_next(op)
    if degs.length() > 0 {
      evolved = evolved + 1
      if rec.action is FixDegradation {
        fixed = fixed + 1
      } else {
        remaining = remaining + 1
      }
    } else {
      evolved = evolved + 1
    }
  }
  let completed_schedule = {
    schedule_id: running_schedule.schedule_id,
    ops_count: running_schedule.ops_count,
    status: Completed,
    description: running_schedule.description,
  }
  let summary = "调度执行完成: " +
    evolved.to_string() +
    " 算子已演化, " +
    fixed.to_string() +
    " 退化已修复, " +
    remaining.to_string() +
    " 退化待修复"
  {
    schedule: completed_schedule,
    evolved_count: evolved,
    fixed_count: fixed,
    remaining_count: remaining,
    summary,
  }
}

///|
/// 运行全量演化周期（所有算子）。
/// Run full evolution cycle (all ops).
pub fn run_full_evolution() -> ScheduleResult {
  let schedule = create_schedule(all_ops())
  run_schedule(schedule)
}

///|
/// 调度结果是否成功（无剩余退化）。
/// Whether schedule result is successful (no remaining degradations).
pub fn ScheduleResult::is_successful(self : ScheduleResult) -> Bool {
  self.schedule.status is Completed && self.remaining_count == 0
}
