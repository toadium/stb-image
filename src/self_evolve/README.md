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

76 个多手段测试（AI + FAKE + MOCK + E2E + 形式化证明），四目标全绿。

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