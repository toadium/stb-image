# self_evolve — 自演化层（GeoVerse Phase 4）

> **层级**：七层 · 自演化智能层
> **定位**：自动测试用例生成 + 退化场景发现，基于 4.7.4 领域规则集。

## 核心思想

self_evolve 为 ImgIR 的 19 种算子自动生成测试用例（边界/正常/边缘），并扫描退化场景（除零/奇异/场间断/溢出/NaN/Inf），形成"拷问→发现→生成测试→验证"自闭环。

```
all_ops() → gen_test_for_op(op) → TestCase[]
all_ops() → detect_degradation(op) → DegradationCase[]
evolve_all() → EvolveReport{ generated_tests, found_degradations }
```

## 模块结构

| 文件 | 内容 |
|------|------|
| `evolve_types.mbt` | TestCategory / DegradationKind / Severity / TestCase / DegradationCase / EvolveReport |
| `test_gen.mbt` | gen_test_for_op / gen_boundary_tests / gen_normal_tests / gen_edge_tests / evolve_test_suite |
| `degrade_detect.mbt` | detect_degradation / scan_degradations / filter_by_severity / count_by_kind |
| `evolve.mbt` | 高层 API：all_ops / evolve / evolve_all / evolve_tests_only / evolve_degradation_scan / count_by_category |
| `optimize_types.mbt` | OptimizationKind / OptimizationSuggestion / OptimizationReport |
| `equiv_check.mbt` | is_identity_op / check_inverse_pair / can_merge / merge_ops / rotate90_power_is_identity |
| `optimize.mbt` | optimize_pipeline / suggest_optimizations / optimize_all / optimized_op_count |
| `perf_types.mbt` | OpCost / PerfBaseline / PerfRegression |
| `perf_cost.mbt` | estimate_op_cost / estimate_pipeline_cost / check_regression / perf_optimize_check / compare_pipelines |
| `evolve_loop.mbt` | EvolveCycleReport / evolve_full_cycle / evolve_cycle_all / is_improved / has_degradation_risk / safety_score |
| `grill.mbt` | GrillRule / GrillResult / GrillReport / grill_rules / grill_rule_desc / run_grill_check / run_grill_all / all_passed / failed_count / passed_count |
| `phase4_report.mbt` | Phase4Capability / Phase4Report / phase4_capabilities / phase4_total_types / phase4_total_functions / phase4_total_tests / phase4_report / phase4_is_complete |
| `exec_test_gen.mbt` | ExecutableTest / ExecutableTestFile / gen_executable_test / gen_executable_suite / gen_test_file_content / gen_test_file_for_op / gen_test_file_for_all / test_count / is_non_empty |
| `auto_repair.mbt` | RepairAction / RepairReport / repair_op / repair_pipeline / repair_report / repair_all / is_fully_repaired / repair_count |
| `optimize_exec.mbt` | OptimizeExecResult / exec_optimize / exec_optimize_all / optimize_verified / is_significant / efficiency_pct |
| `ci_hook.mbt` | CIGateResult / ci_gate_check / ci_gate_all / ci_regression_gate / ci_regression_all_pass / pass_rate / is_green |
| `phase5_report.mbt` | Phase5Capability / Phase5Report / phase5_capabilities / phase5_total_types / phase5_total_functions / phase5_total_tests / phase5_report / phase5_is_complete |
| `exec_test_run.mbt` | TestRunResult / RunSummary / run_test_case / run_test_suite / run_tests_for_op / run_tests_for_all / run_summary / all_passed |
| `smart_repair.mbt` | RepairStrategy / StrategyRepairResult / repair_op_strategy / repair_with_strategies / best_repair / best_repair_all / is_complete / is_improvement |
| `combo_coverage.mbt` | OpCombo / ComboCoverageReport / gen_all_combos / gen_combo_tests / combo_coverage_report / unique_combo_count |
| `root_cause.mbt` | RootCause / RootCauseReport / analyze_root_cause / analyze_root_cause_all / analyze_pipeline_root_cause / filter_by_kind / is_clean |
| `phase6_report.mbt` | Phase6Capability / Phase6Report / phase6_capabilities / phase6_total_types / phase6_total_functions / phase6_total_tests / phase6_report / phase6_is_complete |

## 公共 API

### 类型

- `TestCategory`：Boundary / Normal / EdgeCase / Degradation
- `DegradationKind`：DivisionByZero / SingularMatrix / FieldDiscontinuity / Overflow / NaNValue / InfValue
- `Severity`：Warning / Critical / Fatal
- `TestCase`：name / op_tag / category / description / input_spec / expected_behavior
- `DegradationCase`：kind / op_tag / description / severity
- `EvolveReport`：generated_tests / found_degradations / summary

### 测试生成

- `gen_test_for_op(op)` → Array[TestCase] — 为算子生成全部测试（边界+正常+边缘）
- `gen_boundary_tests(op)` → Array[TestCase] — 边界条件
- `evolve_test_suite(ops)` → Array[TestCase] — 批量生成

### 退化检测

- `detect_degradation(op)` → Array[DegradationCase] — 检测单算子退化
- `scan_degradations(ops)` → Array[DegradationCase] — 批量扫描
- `filter_by_severity(cases, min)` → Array[DegradationCase] — 按严重程度过滤
- `count_by_kind(cases)` → Array[(DegradationKind, Int)] — 按类型分组

### 高层 API

- `all_ops()` → Array[IROp] — 全部 19 种算子代表实例
- `evolve(ops)` → EvolveReport — 完整演化（生成测试+扫描退化）
- `evolve_all()` → EvolveReport — 对全部 19 种算子执行演化

## 领域规则（4.7.4）

| 规则 | 检测内容 |
|------|----------|
| 数值鲁棒性 | 除零 / 奇异矩阵 / NaN / Inf |
| 退化几何 | 除零 / 零面积 |
| 场间断 | 边界不连续 / 插值外推 |
| 时空拓扑 | 时间超出 [0,1] |
| 四目标兼容 | 纯 MoonBit（静态保证） |

## 测试

168 个多手段测试（AI + FAKE + MOCK + E2E + 形式化证明），四目标全绿。

## 自演化闭环（v278.0.0）

完整闭环串联四项能力：退化发现 → 测试生成 → 管道优化 → 性能回归 → 综合报告。

- `evolve_full_cycle(pipeline)` → EvolveCycleReport — 单管道完整闭环
- `evolve_cycle_all()` → Array[EvolveCycleReport] — 19 种算子全闭环
- `EvolveCycleReport::is_improved()` → Bool — 算子减少且成本降低
- `EvolveCycleReport::has_degradation_risk()` → Bool — 存在退化场景
- `EvolveCycleReport::safety_score()` → Int — 安全度 0-100（退化扣 10，严重扣 20）

## 管道优化

等价性规则：
- `FlipH ∘ FlipH = Identity`（两次水平翻转 = 恒等）
- `FlipV ∘ FlipV = Identity`
- `Brightness(0) = Identity`（零亮度调整 = 恒等）
- `GaussianBlur(0, _) = Identity` / `BoxBlur(0) = Identity` / `Sharpen(0.0) = Identity`
- `Brightness(a) ∘ Brightness(b) = Brightness(a+b)`（合并相邻）
- `Rotate90^4 = Identity`（四次旋转 = 恒等）

优化策略：
1. **消除恒等**：移除 Brightness(0) 等无效果算子
2. **消除互逆对**：移除 FlipH∘FlipH 等冗余对
3. **合并相邻**：Brightness(a)∘Brightness(b) → Brightness(a+b)
## grill-me 拷问引擎（v279.0.0）

4.7.4 五条领域规则可执行化，对管道/算子执行拷问检查。

| 规则 | 检测内容 |
|------|----------|
| NumericRobustness | 除零 / 奇异矩阵 / NaN / Inf / 溢出 |
| DegenerateGeometry | 除零 / 零面积 |
| FieldDiscontinuityRule | FieldClamp lo>hi / FieldMask 极端阈值 |
| SpatiotemporalTopology | STSnapshot/STInterpolate t 越界 [0,1] |
| MultiTargetCompat | 纯 MoonBit 无 C FFI（静态保证） |

API：
- `grill_rules()` → 5 条规则
- `grill_rule_desc(rule)` → 规则描述
- `run_grill_check(pipeline)` → GrillReport — 单管道 5 条规则检查
- `run_grill_all()` → GrillReport — 19 种算子全拷问
- `GrillReport::all_passed()` / `failed_count()` / `passed_count()` — 结果统计
## Phase 4 综合报告（v280.0.0）

汇总 v274-v279 全部能力，标记 Phase 4 完成。

- `phase4_capabilities()` → 6 项能力清单（v274-v279）
- `phase4_total_types()` / `phase4_total_functions()` / `phase4_total_tests()` — 汇总（16 类型 / 48 函数 / 76 测试）
- `phase4_report()` → Phase4Report — 综合报告
- `phase4_is_complete()` → Bool — Phase 4 完成判定

自演化体系：拷问 → 发现 → 生成测试 → 优化 → 性能 → 闭环。
## 可执行测试生成（v281.0.0）

Phase 5 起步：将 TestCase 描述转化为可执行 moon test 代码字符串，使自演化从"描述"走向"执行"。

- `gen_executable_test(tc)` → ExecutableTest — 单个 TestCase → moon test 代码块
- `gen_executable_suite(tests)` → Array[ExecutableTest] — 批量生成
- `gen_test_file_content(tests)` → String — 完整测试文件内容
- `gen_test_file_for_op(op)` → ExecutableTestFile — 单算子测试文件
- `gen_test_file_for_all()` → 19 个测试文件
- `ExecutableTestFile::test_count()` / `is_non_empty()` — 文件统计
## 退化自动修复（v282.0.0）

将退化检测从"发现"推向"修复" — 自动修正退化参数。

| 退化 | 修复 |
|------|------|
| Resize(0, h) | Resize(1, h) |
| GaussianBlur(r, 0.0) | GaussianBlur(r, 1.0) |
| GaussianBlur(r, σ<0) | GaussianBlur(r, -σ) |
| Sharpen(极端) | Sharpen(clamp[-100,100]) |
| FieldClamp(lo>hi) | FieldClamp(hi, lo) |
| STSnapshot(t∉[0,1]) | STSnapshot(clamp[0,1]) |

- `repair_op(op)` → IROp — 修复单算子
- `repair_pipeline(pipeline)` → IRPipeline — 修复管道
- `repair_report(pipeline)` → RepairReport — 修复报告
- `RepairReport::is_fully_repaired()` / `repair_count()` — 结果统计
## 管道优化执行（v283.0.0）

将管道优化从"建议"推向"执行" — 实际应用优化 + 成本验证。

- `exec_optimize(pipeline)` → OptimizeExecResult — 执行优化 + 计算前后成本
- `exec_optimize_all()` → 19 个优化结果
- `optimize_verified(pipeline)` → Bool — 验证优化不劣化（算子数和成本不增加）
- `OptimizeExecResult::is_significant()` / `efficiency_pct()` — 优化显著性 + 效率
## 自演化 CI 集成（v284.0.0）

将自演化集成到 CI — 门禁检查 + 回归检测。

- `ci_gate_check(pipeline)` → CIGateResult — 三项门禁（grill + repair + optimize）
- `ci_gate_all()` → 19 个门禁结果
- `ci_regression_gate(pipeline)` → Bool — 回归门禁（优化不劣化 + 修复后无退化）
- `ci_regression_all_pass()` → Bool — 全部 19 算子回归门禁
- `CIGateResult::pass_rate()` / `is_green()` — 通过率 + 全通过判定
## Phase 5 综合报告（v285.0.0）

汇总 v281-v284 全部能力，标记 Phase 5 完成。

- `phase5_capabilities()` → 4 项能力清单（v281-v284）
- `phase5_total_types()` / `phase5_total_functions()` / `phase5_total_tests()` — 汇总（6 类型 / 24 函数 / 36 测试）
- `phase5_report()` → Phase5Report — 综合报告
- `phase5_is_complete()` → Bool — Phase 5 完成判定

自演化实用体系：描述 → 执行 → 修复 → 优化 → CI。Phase 0-5 全部交付。
## 实际执行测试（v286.0.0）

Phase 6 起步：从占位 assert_true 走向真实断言执行 — 构造算子、检测退化、按类别判定通过。

- `run_test_case(tc)` → TestRunResult — 真实执行（Boundary/Normal 期望无退化，Degradation 期望修复后无退化）
- `run_test_suite(tests)` → 批量执行
- `run_tests_for_op(op)` / `run_tests_for_all()` — 单算子/全算子执行
- `run_summary(results)` → RunSummary — 运行汇总（total/passed/failed/pass_rate）
- `RunSummary::all_passed()` — 全通过判定
## 智能修复策略（v287.0.0）

多策略修复 + 质量评分 — 将退化修复从"单一策略"推向"多策略对比 + 最优选择"。

| 策略 | 行为 |
|------|------|
| Conservative | 仅修复 Fatal 级退化（Resize/Crop 零尺寸、GaussianBlur sigma=0） |
| Aggressive | 修复全部退化 |
| Optimal | 选择质量最高（退化最少） |

- `repair_op_strategy(op, strategy)` → IROp — 按策略修复
- `repair_with_strategies(op)` → 3 策略对比结果
- `best_repair(op)` → StrategyRepairResult — 最优选择
- `StrategyRepairResult::is_complete()` / `is_improvement()` — 结果判定
## 组合测试覆盖（v288.0.0）

将测试覆盖从"单算子"推向"二元组合" — 19×19 = 361 组合。

- `gen_all_combos()` → 361 个二元组合
- `gen_combo_tests()` → 361 个组合测试用例
- `combo_coverage_report()` → ComboCoverageReport — 覆盖报告
- `unique_combo_count()` → 独特组合数## 退化根因分析（v289.0.0）

将退化检测从"发现"推向"根因定位" — 指出根因参数 + 修复建议。

- `analyze_root_cause(op)` → Array[RootCause] — 单算子根因定位
- `analyze_root_cause_all()` → RootCauseReport — 全算子根因报告
- `analyze_pipeline_root_cause(pipeline)` → RootCauseReport — 管道根因分析
- `filter_by_kind(causes, kind)` → 按退化类型过滤
- `RootCauseReport::is_clean()` → 无退化## Phase 6 综合报告（v290.0.0）

Phase 6 自演化深化期完成：执行→智能修复→组合覆盖→根因定位。

- `phase6_capabilities()` → 4 个版本能力清单（v286-v289）
- `phase6_report()` → Phase6Report — 综合报告
- `phase6_is_complete()` → Bool — Phase 6 是否完成