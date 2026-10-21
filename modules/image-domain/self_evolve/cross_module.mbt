// 跨模块演化协同 — 跨模块协同演化
// Cross-module evolution coordination: coordinate evolution across modules
//
// Phase 11 v312: 将演化从"知识图谱"推向"跨模块协同" — 多模块协同演化。

///|
/// 模块依赖类型。
/// Module dependency kind.
pub(all) enum ModuleDepKind {
  Uses // 使用
  Extends // 扩展
  Composes // 组合
} derive(Eq, @debug.Debug)

///|
pub extend ModuleDepKind with @debug.Debug::{to_repr}

///|
pub extend ModuleDepKind with Eq::{not_equal, equal}

///|
/// 模块依赖关系。
/// Module dependency.
pub(all) struct ModuleDep {
  source : String
  target : String
  kind : ModuleDepKind
} derive(Eq, @debug.Debug)

///|
pub extend ModuleDep with @debug.Debug::{to_repr}

///|
pub extend ModuleDep with Eq::{not_equal, equal}

///|
/// 协同演化动作类型。
/// Co-evolution action kind.
pub(all) enum CoEvolveActionKind {
  SyncEvolve // 同步演化
  CascadeEvolve // 级联演化
  IndependentEvolve // 独立演化
} derive(Eq, @debug.Debug)

///|
pub extend CoEvolveActionKind with @debug.Debug::{to_repr}

///|
pub extend CoEvolveActionKind with Eq::{not_equal, equal}

///|
/// 协同演化动作。
/// Co-evolution action.
pub(all) struct CoEvolveAction {
  action_kind : CoEvolveActionKind
  source_module : String
  target_module : String
  description : String
} derive(Eq, @debug.Debug)

///|
pub extend CoEvolveAction with @debug.Debug::{to_repr}

///|
pub extend CoEvolveAction with Eq::{not_equal, equal}

///|
/// 协同演化报告。
/// Co-evolution report.
pub(all) struct CoEvolveReport {
  actions : Array[CoEvolveAction]
  total_modules : Int32
  sync_count : Int32
  cascade_count : Int32
  summary : String
} derive(Eq, @debug.Debug)

///|
pub extend CoEvolveReport with @debug.Debug::{to_repr}

///|
pub extend CoEvolveReport with Eq::{not_equal, equal}

///|
/// 构建 self_evolve 内部模块依赖图。
/// Build module dependency graph for self_evolve internal modules.
pub fn build_module_deps() -> Array[ModuleDep] {
  [
    { source: "degrade_detect", target: "evolve_types", kind: Uses, },
    { source: "test_gen", target: "evolve_types", kind: Uses, },
    { source: "optimize", target: "equiv_check", kind: Uses, },
    { source: "optimize", target: "evolve_types", kind: Uses, },
    { source: "equiv_check", target: "evolve_types", kind: Uses, },
    { source: "evolve", target: "degrade_detect", kind: Composes, },
    { source: "evolve", target: "test_gen", kind: Composes, },
    { source: "evolve", target: "optimize", kind: Composes, },
    { source: "schedule", target: "evolve", kind: Extends, },
    { source: "auto_decide", target: "predict", kind: Uses, },
    { source: "strategy_combo", target: "degrade_detect", kind: Uses, },
    { source: "param_tune", target: "evolve_types", kind: Uses, },
    { source: "evolve_loop_full", target: "auto_decide", kind: Composes, },
    { source: "evolve_loop_full", target: "strategy_combo", kind: Composes, },
    { source: "evolve_loop_full", target: "param_tune", kind: Composes, },
    { source: "knowledge_graph", target: "degrade_detect", kind: Uses, },
    { source: "knowledge_graph", target: "smart_priority", kind: Uses, },
  ]
}

///|
/// 为单个算子分析跨模块协同演化。
/// Analyze cross-module co-evolution for a single op.
pub fn co_evolve_op(op : @imgir.IROp) -> CoEvolveReport {
  let tag = op.tag()
  let actions : Array[CoEvolveAction] = []
  let mut sync_count = 0
  let mut cascade_count = 0
  let degs = detect_degradation(op)
  if degs.length() > 0 {
    actions.push({
      action_kind: SyncEvolve,
      source_module: "degrade_detect",
      target_module: "test_gen",
      description: tag + ": 退化检测→测试生成 同步演化",
    })
    sync_count = sync_count + 1
    actions.push({
      action_kind: CascadeEvolve,
      source_module: "equiv_check",
      target_module: "optimize",
      description: tag + ": 等价性→优化 级联演化",
    })
    cascade_count = cascade_count + 1
    actions.push({
      action_kind: SyncEvolve,
      source_module: "degrade_detect",
      target_module: "knowledge_graph",
      description: tag + ": 退化→知识图谱 同步更新",
    })
    sync_count = sync_count + 1
  }
  let cov = coverage_percentage(op)
  if cov < 80 {
    actions.push({
      action_kind: IndependentEvolve,
      source_module: "test_gen",
      target_module: "test_gen",
      description: tag + ": 覆盖率 " + cov.to_string() + "% → 补充测试",
    })
  }
  let score = score_op(op)
  if score.score > 50 {
    actions.push({
      action_kind: CascadeEvolve,
      source_module: "optimize",
      target_module: "equiv_check",
      description: tag + ": 优化→等价性验证 级联演化",
    })
    cascade_count = cascade_count + 1
  }
  if actions.length() == 0 {
    actions.push({
      action_kind: IndependentEvolve,
      source_module: "optimize",
      target_module: "optimize",
      description: tag + ": 无需协同，独立优化",
    })
  }
  let total_modules = 5
  let summary = "跨模块协同[" +
    tag +
    "]: " +
    actions.length().to_string() +
    " 动作, " +
    sync_count.to_string() +
    " 同步, " +
    cascade_count.to_string() +
    " 级联"
  { actions, total_modules, sync_count, cascade_count, summary, }
}

///|
/// 为所有算子分析跨模块协同演化。
/// Analyze cross-module co-evolution for all ops.
pub fn co_evolve_all() -> CoEvolveReport {
  let all_actions : Array[CoEvolveAction] = []
  let mut total_sync = 0
  let mut total_cascade = 0
  let mut total_modules = 0
  for op in all_ops() {
    let report = co_evolve_op(op)
    for a in report.actions {
      all_actions.push(a)
    }
    total_sync = total_sync + report.sync_count
    total_cascade = total_cascade + report.cascade_count
    total_modules = total_modules + report.total_modules
  }
  let summary = "全量跨模块协同: " +
    all_actions.length().to_string() +
    " 动作, " +
    total_sync.to_string() +
    " 同步, " +
    total_cascade.to_string() +
    " 级联"
  {
    actions: all_actions,
    total_modules,
    sync_count: total_sync,
    cascade_count: total_cascade,
    summary,
  }
}

///|
/// 协同演化报告是否有级联演化。
/// Whether co-evolution report has cascade actions.
pub fn CoEvolveReport::has_cascade(self : CoEvolveReport) -> Bool {
  self.cascade_count > 0
}

///|
/// 协同演化报告总动作数。
/// Total action count.
pub fn CoEvolveReport::total_actions(self : CoEvolveReport) -> Int32 {
  self.actions.length()
}
