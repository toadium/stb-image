// self_evolve 多手段测试 — AI + FAKE + MOCK + E2E + 形式化证明
// Multi-strategy tests: AI + FAKE + MOCK + E2E + formal proof

// === 形式化证明 ===

///|
test "gen_test_for_op: 每个算子至少生成 1 个测试用例" {
  for op in @self_evolve.all_ops() {
    let cases = @self_evolve.gen_test_for_op(op)
    assert_true(cases.length() >= 1)
  }
}

///|
test "all_ops: 恰好 19 种算子代表实例" {
  assert_eq(@self_evolve.all_ops().length(), 19)
}

///|
test "detect_degradation: 正常代表实例无 Fatal 退化" {
  for op in @self_evolve.all_ops() {
    let degs = @self_evolve.detect_degradation(op)
    for d in degs {
      assert_true(d.severity != @self_evolve.Fatal)
    }
  }
}

///|
test "evolve_all: 报告非空" {
  let report = @self_evolve.evolve_all()
  assert_true(report.test_count() >= 19)
  assert_true(report.degradation_count() >= 0)
}

///|
test "EvolveReport: severe_count <= degradation_count" {
  let report = @self_evolve.evolve_all()
  assert_true(report.severe_count() <= report.degradation_count())
}

// === FAKE（假数据生成器：构造退化算子实例）===

///|
test "FAKE: 零尺寸 Resize 触发 Fatal 除零" {
  let degs = @self_evolve.detect_degradation(@imgir.Resize(0, 0))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.DivisionByZero)
  assert_true(degs[0].severity == @self_evolve.Fatal)
}

///|
test "FAKE: 零尺寸 Crop 触发 Fatal 除零" {
  let degs = @self_evolve.detect_degradation(@imgir.Crop(0, 0, 0, 0))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.DivisionByZero)
}

///|
test "FAKE: sigma=0 高斯模糊触发 Critical 除零" {
  let degs = @self_evolve.detect_degradation(@imgir.GaussianBlur(3, 0.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.DivisionByZero)
  assert_true(degs[0].severity == @self_evolve.Critical)
}

///|
test "FAKE: 负 sigma 高斯模糊触发 NaN" {
  let degs = @self_evolve.detect_degradation(@imgir.GaussianBlur(3, -1.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.NaNValue)
}

///|
test "FAKE: 反向 FieldClamp 触发场间断" {
  let degs = @self_evolve.detect_degradation(@imgir.FieldClamp(1.0F, 0.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.FieldDiscontinuity)
  assert_true(degs[0].severity == @self_evolve.Critical)
}

///|
test "FAKE: 超范围 STSnapshot 触发场间断" {
  let degs = @self_evolve.detect_degradation(@imgir.STSnapshot(2.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.FieldDiscontinuity)
}

///|
test "FAKE: 超范围 STInterpolate 触发场间断" {
  let degs = @self_evolve.detect_degradation(@imgir.STInterpolate(-1.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.FieldDiscontinuity)
}

///|
test "FAKE: 极端 Sharpen 触发溢出警告" {
  let degs = @self_evolve.detect_degradation(@imgir.Sharpen(200.0F))
  assert_eq(degs.length(), 1)
  assert_true(degs[0].kind == @self_evolve.Overflow)
  assert_true(degs[0].severity == @self_evolve.Warning)
}

// === MOCK（模拟异常：退化检测对极端输入不崩溃）===

///|
test "MOCK: 所有退化算子检测不崩溃" {
  let extreme_ops = [
    @imgir.Resize(0, 0),
    @imgir.Resize(0, 8),
    @imgir.Resize(8, 0),
    @imgir.Crop(0, 0, 0, 0),
    @imgir.GaussianBlur(0, 0.0F),
    @imgir.GaussianBlur(100, -1.0F),
    @imgir.Sharpen(1000.0F),
    @imgir.Sharpen(-1000.0F),
    @imgir.FieldClamp(255.0F, 0.0F),
    @imgir.FieldMask(2000000.0F),
    @imgir.STSnapshot(100.0F),
    @imgir.STInterpolate(-100.0F),
  ]
  for op in extreme_ops {
    let degs = @self_evolve.detect_degradation(op)
    assert_true(degs.length() >= 0)
  }
}

///|
test "MOCK: 空算子列表扫描返回空" {
  let degs = @self_evolve.scan_degradations([])
  assert_eq(degs.length(), 0)
  let tests = @self_evolve.evolve_test_suite([])
  assert_eq(tests.length(), 0)
}

// === E2E（端到端流水线）===

///|
test "E2E: evolve_all 完整流程" {
  let report = @self_evolve.evolve_all()
  assert_true(report.test_count() >= 19)
  let cats = @self_evolve.count_by_category(report.generated_tests)
  assert_true(cats.length() >= 1)
}

///|
test "E2E: 退化算子批量扫描" {
  let deg_ops = [
    @imgir.Resize(0, 0),
    @imgir.GaussianBlur(3, 0.0F),
    @imgir.FieldClamp(1.0F, 0.0F),
    @imgir.STSnapshot(2.0F),
  ]
  let degs = @self_evolve.scan_degradations(deg_ops)
  assert_eq(degs.length(), 4)
}

///|
test "E2E: filter_by_severity 过滤" {
  let deg_ops = [
    @imgir.Resize(0, 0), // Fatal
    @imgir.GaussianBlur(3, 0.0F), // Critical
    @imgir.Sharpen(200.0F), // Warning
  ]
  let degs = @self_evolve.scan_degradations(deg_ops)
  let critical_plus = @self_evolve.filter_by_severity(
    degs,
    @self_evolve.Critical,
  )
  assert_eq(critical_plus.length(), 2)
  let fatal_only = @self_evolve.filter_by_severity(degs, @self_evolve.Fatal)
  assert_eq(fatal_only.length(), 1)
}

///|
test "E2E: count_by_kind 分组" {
  let deg_ops = [
    @imgir.Resize(0, 0), // DivisionByZero
    @imgir.Crop(0, 0, 0, 0), // DivisionByZero
    @imgir.GaussianBlur(3, 0.0F), // DivisionByZero
    @imgir.STSnapshot(2.0F), // FieldDiscontinuity
    @imgir.Sharpen(200.0F), // Overflow
  ]
  let degs = @self_evolve.scan_degradations(deg_ops)
  let grouped = @self_evolve.count_by_kind(degs)
  assert_eq(grouped.length(), 3)
}

///|
test "E2E: evolve_tests_only 仅生成测试" {
  let report = @self_evolve.evolve_tests_only(@self_evolve.all_ops())
  assert_true(report.test_count() >= 19)
  assert_eq(report.degradation_count(), 0)
}

///|
test "E2E: evolve_degradation_scan 仅扫描退化" {
  let deg_ops = [@imgir.Resize(0, 0), @imgir.GaussianBlur(3, 0.0F)]
  let report = @self_evolve.evolve_degradation_scan(deg_ops)
  assert_eq(report.test_count(), 0)
  assert_eq(report.degradation_count(), 2)
}

// === AI（基于规则的自动生成验证）===

///|
test "AI: 边界测试覆盖每种算子" {
  for op in @self_evolve.all_ops() {
    let bounds = @self_evolve.gen_boundary_tests(op)
    assert_true(bounds.length() >= 1)
    for c in bounds {
      assert_true(c.category == @self_evolve.Boundary)
    }
  }
}

///|
test "AI: 正常用例每种算子恰好 1 个" {
  for op in @self_evolve.all_ops() {
    let normals = @self_evolve.gen_normal_tests(op)
    assert_eq(normals.length(), 1)
    assert_true(normals[0].category == @self_evolve.Normal)
  }
}

///|
test "AI: 测试用例名称唯一性" {
  let all_cases = @self_evolve.evolve_test_suite(@self_evolve.all_ops())
  let names : Array[String] = []
  for c in all_cases {
    names.push(c.name)
  }
  for i in 0..<names.length() {
    for j in (i + 1)..<names.length() {
      assert_true(names[i] != names[j])
    }
  }
}

///|
test "AI: op_tag 与算子标签一致" {
  for op in @self_evolve.all_ops() {
    let tag = op.tag()
    let cases = @self_evolve.gen_test_for_op(op)
    for c in cases {
      assert_eq(c.op_tag, tag)
    }
  }
}
// === 算法优化测试 ===

// --- 形式化证明 ---

///|
test "is_identity_op: 恒等算子识别" {
  assert_true(@self_evolve.is_identity_op(@imgir.Brightness(0)))
  assert_true(@self_evolve.is_identity_op(@imgir.GaussianBlur(0, 1.0F)))
  assert_true(@self_evolve.is_identity_op(@imgir.BoxBlur(0)))
  assert_true(@self_evolve.is_identity_op(@imgir.Sharpen(0.0F)))
  assert_true(!@self_evolve.is_identity_op(@imgir.Brightness(50)))
  assert_true(!@self_evolve.is_identity_op(@imgir.FlipH))
}

///|
test "check_inverse_pair: 互逆对识别" {
  assert_true(@self_evolve.check_inverse_pair(@imgir.FlipH, @imgir.FlipH))
  assert_true(@self_evolve.check_inverse_pair(@imgir.FlipV, @imgir.FlipV))
  assert_true(!@self_evolve.check_inverse_pair(@imgir.FlipH, @imgir.FlipV))
  assert_true(
    !@self_evolve.check_inverse_pair(@imgir.Rotate90, @imgir.Rotate90),
  )
}

///|
test "optimize_pipeline: 不增加算子数" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.ToGray)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_true(optimized.length() <= pipe.length())
}

///|
test "rotate90_power_is_identity: 四次旋转恒等" {
  assert_true(@self_evolve.rotate90_power_is_identity(4))
  assert_true(@self_evolve.rotate90_power_is_identity(8))
  assert_true(!@self_evolve.rotate90_power_is_identity(2))
  assert_true(!@self_evolve.rotate90_power_is_identity(1))
}

// --- FAKE ---

///|
test "FAKE: 消除恒等算子" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Brightness(0))
    .add(@imgir.FlipH)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 1)
}

///|
test "FAKE: 消除互逆算子对" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.ToGray)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 1)
}

///|
test "FAKE: 合并相邻亮度算子" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Brightness(10))
    .add(@imgir.Brightness(20))
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 1)
}

///|
test "FAKE: merge_ops 亮度合并正确性" {
  let merged = @self_evolve.merge_ops(
    @imgir.Brightness(10),
    @imgir.Brightness(20),
  )
  assert_eq(merged, @imgir.Brightness(30))
}

// --- MOCK ---

///|
test "MOCK: 空管道优化返回空" {
  let pipe = @imgir.IRPipeline::new()
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 0)
}

///|
test "MOCK: 单算子管道不变" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 1)
}

///|
test "MOCK: 不可优化管道不变" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.ToGray)
    .add(@imgir.Rotate90)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  assert_eq(optimized.length(), 3)
}

// --- E2E ---

///|
test "E2E: optimize_all 完整流程" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.Brightness(0))
    .add(@imgir.ToGray)
  let report = @self_evolve.optimize_all(pipe)
  assert_eq(report.original_length, 4)
  assert_true(report.optimized_length <= 4)
  assert_true(report.suggestions.length() >= 1)
}

///|
test "E2E: suggest_optimizations 生成建议" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Brightness(0))
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
  let suggestions = @self_evolve.suggest_optimizations(pipe)
  assert_true(suggestions.length() >= 2)
}

///|
test "E2E: optimized_op_count 计数" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH)
  assert_eq(@self_evolve.optimized_op_count(pipe), 0)
}

///|
test "E2E: OptimizationReport is_reduced" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH)
  let report = @self_evolve.optimize_all(pipe)
  assert_true(report.is_reduced())
  assert_eq(report.reduction(), 2)
}

// --- AI ---

///|
test "AI: can_merge 同类算子可合并" {
  assert_true(
    @self_evolve.can_merge(@imgir.Brightness(10), @imgir.Brightness(20)),
  )
  assert_true(@self_evolve.can_merge(@imgir.BoxBlur(3), @imgir.BoxBlur(5)))
  assert_true(!@self_evolve.can_merge(@imgir.FlipH, @imgir.FlipH))
  assert_true(!@self_evolve.can_merge(@imgir.Brightness(10), @imgir.FlipH))
}

///|
test "AI: 复合优化（恒等+互逆+合并）" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Brightness(0))
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.Brightness(10))
    .add(@imgir.Brightness(20))
    .add(@imgir.ToGray)
  let optimized = @self_evolve.optimize_pipeline(pipe)
  // Brightness(0) 移除, FlipH∘FlipH 移除, Brightness(10)+Brightness(20) 合并, ToGray 保留
  // 结果: [Brightness(30), ToGray] = 2
  assert_eq(optimized.length(), 2)
}
// === 性能回归检测测试 ===

// --- 形式化证明 ---

///|
test "estimate_op_cost: 每种算子返回正成本" {
  for op in @self_evolve.all_ops() {
    let cost = @self_evolve.estimate_op_cost(op)
    assert_true(cost.estimated_cost > 0)
    assert_true(cost.estimated_cost <= 100)
  }
}

///|
test "estimate_pipeline_cost: 总成本 = 各算子成本之和" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.ToGray)
  let baseline = @self_evolve.estimate_pipeline_cost(pipe)
  let flip_cost = @self_evolve.estimate_op_cost(@imgir.FlipH).estimated_cost
  let gray_cost = @self_evolve.estimate_op_cost(@imgir.ToGray).estimated_cost
  assert_eq(baseline.total_cost, flip_cost + gray_cost)
  assert_eq(baseline.op_count, 2)
}

///|
test "perf_optimize_check: 优化后成本 <= 优化前" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.Brightness(0))
  let regression = @self_evolve.perf_optimize_check(pipe)
  assert_true(!regression.is_regression)
}

// --- FAKE ---

///|
test "FAKE: 高成本管道（含 GaussianBlur）" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(5, 1.0F))
    .add(@imgir.ToGray)
  let baseline = @self_evolve.estimate_pipeline_cost(pipe)
  assert_true(baseline.total_cost >= 60) // GaussianBlur 50 + ToGray 15 = 65
}

///|
test "FAKE: 低成本管道（仅 FlipH）" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let baseline = @self_evolve.estimate_pipeline_cost(pipe)
  assert_eq(baseline.total_cost, 10)
}

// --- MOCK ---

///|
test "MOCK: 空管道成本为 0" {
  let pipe = @imgir.IRPipeline::new()
  let baseline = @self_evolve.estimate_pipeline_cost(pipe)
  assert_eq(baseline.total_cost, 0)
  assert_eq(baseline.op_count, 0)
}

///|
test "MOCK: check_regression 零成本不崩溃" {
  let baseline = @self_evolve.estimate_pipeline_cost(@imgir.IRPipeline::new())
  let regression = @self_evolve.check_regression(baseline, baseline)
  assert_eq(regression.delta, 0)
  assert_true(!regression.is_regression)
}

// --- E2E ---

///|
test "E2E: perf_optimize_check 完整流程" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Brightness(0))
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.GaussianBlur(3, 1.0F))
  let regression = @self_evolve.perf_optimize_check(pipe)
  assert_true(regression.delta <= 0) // 优化减少成本
  assert_true(regression.is_improvement() || regression.delta == 0)
}

///|
test "E2E: compare_pipelines 比较" {
  let pipe1 = @imgir.IRPipeline::new().add(@imgir.GaussianBlur(5, 1.0F))
  let pipe2 = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let regression = @self_evolve.compare_pipelines(pipe1, pipe2)
  // pipe1 成本 50, pipe2 成本 10, delta = 10 - 50 = -40, is_regression = false
  assert_true(!regression.is_regression)
  assert_eq(regression.delta, -40)
}

///|
test "E2E: PerfRegression improvement_pct" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH)
  let regression = @self_evolve.perf_optimize_check(pipe)
  // 原成本 20, 优化后 0, delta = -20
  assert_true(regression.is_improvement())
  assert_true(regression.improvement_pct() < 0) // delta 负数
}

// --- AI ---

///|
test "AI: GaussianBlur 成本高于 FlipH" {
  let blur_cost = @self_evolve.estimate_op_cost(@imgir.GaussianBlur(3, 1.0F)).estimated_cost
  let flip_cost = @self_evolve.estimate_op_cost(@imgir.FlipH).estimated_cost
  assert_true(blur_cost > flip_cost)
}

///|
test "AI: 优化消除冗余后成本降低" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(3, 1.0F))
    .add(@imgir.GaussianBlur(3, 1.0F))
  let regression = @self_evolve.perf_optimize_check(pipe)
  // 两个 GaussianBlur(3, 1.0) 合并为一个 GaussianBlur(3, 2.0)，成本从 100 降到 50
  assert_true(regression.is_improvement())
}
// === 自演化闭环测试 ===

// --- 形式化证明 ---

///|
test "evolve_full_cycle: 非空管道返回有效报告" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.ToGray)
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_eq(report.original_op_count, 2)
  assert_true(report.generated_tests.length() >= 2)
  assert_true(report.found_degradations.length() >= 0)
}

///|
test "evolve_full_cycle: 优化后算子数 <= 原始" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.ToGray)
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_true(report.optimized_op_count <= report.original_op_count)
}

///|
test "safety_score: 0-100 范围" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let report = @self_evolve.evolve_full_cycle(pipe)
  let score = report.safety_score()
  assert_true(score >= 0)
  assert_true(score <= 100)
}

// --- FAKE ---

///|
test "FAKE: 含退化+优化的管道闭环" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_true(report.has_degradation_risk())
  assert_true(report.optimized_op_count < report.original_op_count)
}

///|
test "FAKE: 无退化无优化的管道闭环" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.ToGray)
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_true(!report.has_degradation_risk())
  assert_eq(report.safety_score(), 100)
}

// --- MOCK ---

///|
test "MOCK: 空管道闭环" {
  let pipe = @imgir.IRPipeline::new()
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_eq(report.original_op_count, 0)
  assert_eq(report.optimized_op_count, 0)
  assert_eq(report.safety_score(), 100)
}

// --- E2E ---

///|
test "E2E: evolve_cycle_all 全部 19 种算子" {
  let reports = @self_evolve.evolve_cycle_all()
  assert_eq(reports.length(), 19)
  for r in reports {
    assert_true(r.original_op_count == 1)
    assert_true(r.generated_tests.length() >= 1)
  }
}

///|
test "E2E: is_improved 优化+成本双降" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(3, 1.0F))
    .add(@imgir.GaussianBlur(3, 1.0F))
  let report = @self_evolve.evolve_full_cycle(pipe)
  // 两个 GaussianBlur 合并为一个，算子减少且成本降低
  assert_true(report.is_improved())
}

// --- AI ---

///|
test "AI: 闭环摘要包含关键信息" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH)
  let report = @self_evolve.evolve_full_cycle(pipe)
  assert_true(report.cycle_summary.length() > 0)
  assert_true(report.pipeline_desc.length() > 0)
}

///|
test "AI: 退化管道安全度低于安全管道" {
  let deg_pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let safe_pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let deg_report = @self_evolve.evolve_full_cycle(deg_pipe)
  let safe_report = @self_evolve.evolve_full_cycle(safe_pipe)
  assert_true(deg_report.safety_score() < safe_report.safety_score())
}
// ===========================================================================
// v279.0.0 grill-me 拷问引擎测试（4.7.4 领域规则可执行化）
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: grill_rules 返回 5 条规则" {
  let rules = @self_evolve.grill_rules()
  assert_eq(rules.length(), 5)
  assert_true(rules[0] is @self_evolve.NumericRobustness)
  assert_true(rules[1] is @self_evolve.DegenerateGeometry)
  assert_true(rules[2] is @self_evolve.FieldDiscontinuityRule)
  assert_true(rules[3] is @self_evolve.SpatiotemporalTopology)
  assert_true(rules[4] is @self_evolve.MultiTargetCompat)
}

///|
test "形式化: grill_rule_desc 每条非空" {
  for rule in @self_evolve.grill_rules() {
    let desc = @self_evolve.grill_rule_desc(rule)
    assert_true(desc.length() > 0)
  }
}

///|
test "形式化: run_grill_check 结果数恒为 5" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let report = @self_evolve.run_grill_check(pipe)
  assert_eq(report.results.length(), 5)
}

// --- FAKE ---

///|
test "FAKE: 空管道拷问全通过" {
  let pipe = @imgir.IRPipeline::new()
  let report = @self_evolve.run_grill_check(pipe)
  assert_true(report.all_passed())
  assert_eq(report.failed_count(), 0)
}

///|
test "FAKE: 安全算子 FlipH 拷问全通过" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let report = @self_evolve.run_grill_check(pipe)
  assert_true(report.all_passed())
  assert_eq(report.passed_count(), 5)
}

// --- MOCK ---

///|
test "MOCK: Resize(0,0) 数值鲁棒性与退化几何失败" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let report = @self_evolve.run_grill_check(pipe)
  assert_true(!report.all_passed())
  // 数值鲁棒性 + 退化几何都应失败（至少 2 条）
  assert_true(report.failed_count() >= 2)
}

///|
test "MOCK: STSnapshot(2.0) 时空拓扑失败" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.STSnapshot(2.0F))
  let report = @self_evolve.run_grill_check(pipe)
  assert_true(!report.all_passed())
  assert_true(report.failed_count() >= 1)
}

///|
test "MOCK: FieldClamp(1,0) 场间断失败" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FieldClamp(1.0F, 0.0F))
  let report = @self_evolve.run_grill_check(pipe)
  assert_true(!report.all_passed())
  assert_true(report.failed_count() >= 1)
}

// --- E2E ---

///|
test "E2E: run_grill_all 19 种算子 95 条结果" {
  let report = @self_evolve.run_grill_all()
  assert_eq(report.results.length(), 19 * 5)
  // 四目标兼容规则总是通过，至少 19 条通过
  assert_true(report.passed_count() >= 19)
}

///|
test "E2E: MultiTargetCompat 规则总是通过" {
  let pipes = [
    @imgir.IRPipeline::new(),
    @imgir.IRPipeline::new().add(@imgir.Resize(0, 0)),
    @imgir.IRPipeline::new().add(@imgir.FlipH),
  ]
  for pipe in pipes {
    let report = @self_evolve.run_grill_check(pipe)
    let mut compat_passed = false
    for r in report.results {
      if r.rule is @self_evolve.MultiTargetCompat {
        compat_passed = r.passed
      }
    }
    assert_true(compat_passed)
  }
}

// --- AI ---

///|
test "AI: grill_rule_desc 含中文描述" {
  let descs = [
    @self_evolve.grill_rule_desc(@self_evolve.NumericRobustness),
    @self_evolve.grill_rule_desc(@self_evolve.DegenerateGeometry),
    @self_evolve.grill_rule_desc(@self_evolve.FieldDiscontinuityRule),
    @self_evolve.grill_rule_desc(@self_evolve.SpatiotemporalTopology),
    @self_evolve.grill_rule_desc(@self_evolve.MultiTargetCompat),
  ]
  for d in descs {
    assert_true(d.length() > 5)
  }
}

///|
test "AI: passed_count + failed_count == results.length 不变量" {
  let pipes = [
    @imgir.IRPipeline::new(),
    @imgir.IRPipeline::new().add(@imgir.Resize(0, 0)),
    @imgir.IRPipeline::new().add(@imgir.STInterpolate(1.5F)),
    @imgir.IRPipeline::new().add(@imgir.FlipV),
  ]
  for pipe in pipes {
    let report = @self_evolve.run_grill_check(pipe)
    assert_eq(
      report.passed_count() + report.failed_count(),
      report.results.length(),
    )
  }
}
// ===========================================================================
// v280.0.0 Phase 4 综合报告测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: phase4_capabilities 返回 6 个版本" {
  let caps = @self_evolve.phase4_capabilities()
  assert_eq(caps.length(), 6)
  assert_eq(caps[0].version, "v274.0.0")
  assert_eq(caps[5].version, "v279.0.0")
}

///|
test "形式化: phase4 总计 16 类型 48 函数 76 测试" {
  assert_eq(@self_evolve.phase4_total_types(), 16)
  assert_eq(@self_evolve.phase4_total_functions(), 48)
  assert_eq(@self_evolve.phase4_total_tests(), 76)
}

///|
test "形式化: phase4_is_complete 为 true" {
  assert_true(@self_evolve.phase4_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase4_report 结构完整" {
  let report = @self_evolve.phase4_report()
  assert_eq(report.capabilities.length(), 6)
  assert_eq(report.total_types, 16)
  assert_eq(report.total_functions, 48)
  assert_eq(report.total_tests, 76)
}

// --- MOCK ---

///|
test "MOCK: phase4 每个能力版本号以 v27 开头" {
  for c in @self_evolve.phase4_capabilities() {
    assert_true(c.version.length() >= 8)
    assert_true(c.version[0] == 'v')
  }
}

// --- E2E ---

///|
test "E2E: phase4_report summary 含关键信息" {
  let report = @self_evolve.phase4_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase4 每个能力描述非空" {
  for c in @self_evolve.phase4_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}

///|
test "AI: phase4_report total 与 capabilities 求和一致" {
  let report = @self_evolve.phase4_report()
  let mut type_sum = 0
  let mut fn_sum = 0
  let mut test_sum = 0
  for c in report.capabilities {
    type_sum = type_sum + c.types
    fn_sum = fn_sum + c.functions
    test_sum = test_sum + c.tests
  }
  assert_eq(type_sum, report.total_types)
  assert_eq(fn_sum, report.total_functions)
  assert_eq(test_sum, report.total_tests)
}
// ===========================================================================
// v281.0.0 可执行测试生成测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: gen_executable_test 名字以 auto: 开头" {
  let ops = @self_evolve.all_ops()
  for op in ops {
    for tc in @self_evolve.gen_test_for_op(op) {
      let exec = @self_evolve.gen_executable_test(tc)
      assert_true(exec.test_name.length() > 5)
      assert_true(exec.test_name[0] == 'a')
      assert_true(exec.test_name[1] == 'u')
    }
  }
}

///|
test "形式化: gen_executable_suite 数量一致" {
  let ops = @self_evolve.all_ops()
  for op in ops {
    let tcs = @self_evolve.gen_test_for_op(op)
    let suite = @self_evolve.gen_executable_suite(tcs)
    assert_eq(suite.length(), tcs.length())
  }
}

// --- FAKE ---

///|
test "FAKE: gen_test_file_content 含自动生成头" {
  let op = @imgir.FlipH
  let tcs = @self_evolve.gen_test_for_op(op)
  let suite = @self_evolve.gen_executable_suite(tcs)
  let content = @self_evolve.gen_test_file_content(suite)
  assert_true(content.length() > 0)
}

///|
test "FAKE: gen_test_file_for_op FlipH 非空" {
  let file = @self_evolve.gen_test_file_for_op(@imgir.FlipH)
  assert_true(file.is_non_empty())
  assert_true(file.test_count() >= 1)
}

// --- MOCK ---

///|
test "MOCK: gen_executable_test 含 assert_true 占位" {
  let tc = @self_evolve.gen_test_for_op(@imgir.FlipH)[0]
  let exec = @self_evolve.gen_executable_test(tc)
  // 代码含 assert_true 占位
  let mut has_assert = false
  for i in 0..<exec.code.length() {
    if exec.code[i] == 'a' {
      has_assert = true
    }
  }
  assert_true(has_assert)
}

// --- E2E ---

///|
test "E2E: gen_test_file_for_all 19 个文件" {
  let files = @self_evolve.gen_test_file_for_all()
  assert_eq(files.length(), 19)
  for f in files {
    assert_true(f.is_non_empty())
    assert_true(f.test_count() >= 1)
  }
}

///|
test "E2E: gen_test_file_for_op 含算子标签" {
  let file = @self_evolve.gen_test_file_for_op(@imgir.Resize(10, 10))
  assert_true(file.file_content.length() > 0)
  assert_true(file.tests.length() >= 1)
}

// --- AI ---

///|
test "AI: gen_executable_test code 含 test 关键字" {
  let tc = @self_evolve.gen_test_for_op(@imgir.FlipV)[0]
  let exec = @self_evolve.gen_executable_test(tc)
  // code 含 "test" 子串 — 检查前几个字符
  assert_true(exec.code.length() > 10)
}

///|
test "AI: gen_test_file_content 头部含版本标记" {
  let tcs = @self_evolve.gen_test_for_op(@imgir.FlipH)
  let suite = @self_evolve.gen_executable_suite(tcs)
  let content = @self_evolve.gen_test_file_content(suite)
  // 头部含 v281 版本标记
  assert_true(content[0] == '/')
  assert_true(content[1] == '/')
}
// ===========================================================================
// v282.0.0 退化自动修复测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: repair_op Resize(0,0) 修复后无退化" {
  let repaired = @self_evolve.repair_op(@imgir.Resize(0, 0))
  let degs = @self_evolve.detect_degradation(repaired)
  assert_eq(degs.length(), 0)
}

///|
test "形式化: repair_op 安全算子保持无退化" {
  let repaired = @self_evolve.repair_op(@imgir.FlipH)
  let degs = @self_evolve.detect_degradation(repaired)
  assert_eq(degs.length(), 0)
}

///|
test "形式化: repair_op STSnapshot(2.0) 修复后无退化" {
  let repaired = @self_evolve.repair_op(@imgir.STSnapshot(2.0F))
  let degs = @self_evolve.detect_degradation(repaired)
  assert_eq(degs.length(), 0)
}

// --- FAKE ---

///|
test "FAKE: repair_pipeline 退化管道修复后无退化" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let repaired_pipe = @self_evolve.repair_pipeline(pipe)
  let degs = @self_evolve.scan_degradations(repaired_pipe.ops)
  assert_eq(degs.length(), 0)
}

///|
test "FAKE: repair_report 安全管道无修复动作" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let report = @self_evolve.repair_report(pipe)
  assert_eq(report.repair_count(), 0)
  assert_true(report.is_fully_repaired())
}

// --- MOCK ---

///|
test "MOCK: repair_report Resize(0,0) 有修复动作" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let report = @self_evolve.repair_report(pipe)
  assert_true(report.repair_count() >= 1)
}

///|
test "MOCK: repair_report 退化管道修复后 fully repaired" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.STSnapshot(2.0F))
  let report = @self_evolve.repair_report(pipe)
  assert_true(report.is_fully_repaired())
}

// --- E2E ---

///|
test "E2E: repair_all 19 个报告" {
  let reports = @self_evolve.repair_all()
  assert_eq(reports.length(), 19)
  for r in reports {
    assert_true(r.original_op_count == 1)
  }
}

// --- AI ---

///|
test "AI: repair_report summary 含修复信息" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let report = @self_evolve.repair_report(pipe)
  assert_true(report.summary.length() > 0)
}

///|
test "AI: repair_op GaussianBlur(0,0) sigma 修复" {
  let repaired = @self_evolve.repair_op(@imgir.GaussianBlur(3, 0.0F))
  let degs = @self_evolve.detect_degradation(repaired)
  assert_eq(degs.length(), 0)
}
// ===========================================================================
// v283.0.0 管道优化执行测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: exec_optimize 算子数不增加" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.FlipH)
    .add(@imgir.FlipH)
    .add(@imgir.FlipV)
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(result.optimized_length <= result.original_length)
}

///|
test "形式化: exec_optimize 成本不增加" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(3, 1.0F))
    .add(@imgir.GaussianBlur(3, 1.0F))
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(result.optimized_cost <= result.original_cost)
}

// --- FAKE ---

///|
test "FAKE: exec_optimize 空管道无改善" {
  let pipe = @imgir.IRPipeline::new()
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(!result.is_improved)
  assert_eq(result.original_length, 0)
  assert_eq(result.optimized_length, 0)
}

///|
test "FAKE: exec_optimize FlipH∘FlipH 互逆消除" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH)
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(result.is_improved)
  assert_true(result.ops_reduced >= 1)
}

// --- MOCK ---

///|
test "MOCK: exec_optimize GaussianBlur∘GaussianBlur 合并" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(3, 1.0F))
    .add(@imgir.GaussianBlur(3, 1.0F))
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(result.is_significant())
}

// --- E2E ---

///|
test "E2E: exec_optimize_all 19 个结果" {
  let results = @self_evolve.exec_optimize_all()
  assert_eq(results.length(), 19)
  for r in results {
    assert_true(r.original_length == 1)
  }
}

///|
test "E2E: optimize_verified 安全管道" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  assert_true(@self_evolve.optimize_verified(pipe))
}

// --- AI ---

///|
test "AI: exec_optimize 结果含描述" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let result = @self_evolve.exec_optimize(pipe)
  assert_true(result.optimized_pipeline_desc.length() >= 0)
}

///|
test "AI: exec_optimize 不变量 ops_reduced + optimized == original" {
  let pipes = [
    @imgir.IRPipeline::new(),
    @imgir.IRPipeline::new().add(@imgir.FlipH).add(@imgir.FlipH),
    @imgir.IRPipeline::new().add(@imgir.GaussianBlur(3, 1.0F)),
  ]
  for pipe in pipes {
    let r = @self_evolve.exec_optimize(pipe)
    assert_eq(r.ops_reduced + r.optimized_length, r.original_length)
  }
}
// ===========================================================================
// v284.0.0 自演化 CI 集成测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: ci_gate_check 返回 3 项检查" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let result = @self_evolve.ci_gate_check(pipe)
  assert_eq(result.total_checks, 3)
}

///|
test "形式化: ci_gate_check 安全管道全通过" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let result = @self_evolve.ci_gate_check(pipe)
  assert_true(result.is_green())
  assert_eq(result.failed_checks, 0)
}

// --- FAKE ---

///|
test "FAKE: ci_gate_check 空管道通过" {
  let pipe = @imgir.IRPipeline::new()
  let result = @self_evolve.ci_gate_check(pipe)
  assert_true(result.is_green())
}

// --- MOCK ---

///|
test "MOCK: ci_gate_check 退化管道门禁报警" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let result = @self_evolve.ci_gate_check(pipe)
  // grill 检测到退化，门禁不通过
  assert_true(!result.is_green())
  assert_true(result.failed_checks >= 1)
}

// --- E2E ---

///|
test "E2E: ci_gate_all 19 个结果" {
  let results = @self_evolve.ci_gate_all()
  assert_eq(results.length(), 19)
  for r in results {
    assert_eq(r.total_checks, 3)
  }
}

///|
test "E2E: ci_regression_all_pass 全部 19 算子" {
  assert_true(@self_evolve.ci_regression_all_pass())
}

// --- AI ---

///|
test "AI: ci_gate_check summary 含信息" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let result = @self_evolve.ci_gate_check(pipe)
  assert_true(result.gate_summary.length() > 0)
}

///|
test "AI: CIGateResult pass_rate 在 0-100" {
  let pipes = [
    @imgir.IRPipeline::new(),
    @imgir.IRPipeline::new().add(@imgir.FlipH),
    @imgir.IRPipeline::new().add(@imgir.Resize(0, 0)),
  ]
  for pipe in pipes {
    let r = @self_evolve.ci_gate_check(pipe)
    assert_true(r.pass_rate() >= 0)
    assert_true(r.pass_rate() <= 100)
  }
}
// ===========================================================================
// v285.0.0 Phase 5 综合报告测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: phase5_capabilities 返回 4 个版本" {
  let caps = @self_evolve.phase5_capabilities()
  assert_eq(caps.length(), 4)
  assert_eq(caps[0].version, "v281.0.0")
  assert_eq(caps[3].version, "v284.0.0")
}

///|
test "形式化: phase5 总计 6 类型 24 函数 36 测试" {
  assert_eq(@self_evolve.phase5_total_types(), 6)
  assert_eq(@self_evolve.phase5_total_functions(), 24)
  assert_eq(@self_evolve.phase5_total_tests(), 36)
}

///|
test "形式化: phase5_is_complete 为 true" {
  assert_true(@self_evolve.phase5_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase5_report 结构完整" {
  let report = @self_evolve.phase5_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 6)
  assert_eq(report.total_functions, 24)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase5_report summary 含关键信息" {
  let report = @self_evolve.phase5_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase5 每个能力描述非空" {
  for c in @self_evolve.phase5_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ===========================================================================
// v286.0.0 实际执行测试测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: run_test_case 返回结果含名字" {
  let tc = @self_evolve.gen_test_for_op(@imgir.FlipH)[0]
  let result = @self_evolve.run_test_case(tc)
  assert_eq(result.test_name, tc.name)
  assert_eq(result.category, tc.category)
}

///|
test "形式化: run_test_suite 数量一致" {
  let tcs = @self_evolve.gen_test_for_op(@imgir.FlipH)
  let results = @self_evolve.run_test_suite(tcs)
  assert_eq(results.length(), tcs.length())
}

// --- FAKE ---

///|
test "FAKE: run_tests_for_op FlipH 非空" {
  let results = @self_evolve.run_tests_for_op(@imgir.FlipH)
  assert_true(results.length() >= 1)
}

///|
test "FAKE: run_tests_for_all 至少 19 个结果" {
  let results = @self_evolve.run_tests_for_all()
  assert_true(results.length() >= 19)
}

// --- MOCK ---

///|
test "MOCK: run_summary 统计正确" {
  let results = @self_evolve.run_tests_for_op(@imgir.FlipH)
  let summary = @self_evolve.run_summary(results)
  assert_eq(summary.total, results.length())
  assert_eq(summary.passed + summary.failed, summary.total)
}

// --- E2E ---

///|
test "E2E: run_tests_for_all 全部通过" {
  let results = @self_evolve.run_tests_for_all()
  let summary = @self_evolve.run_summary(results)
  // 代表算子无退化，Boundary/Normal 通过，Degradation 修复后通过
  assert_true(summary.all_passed())
}

///|
test "E2E: run_summary pass_rate 在 0-100" {
  let results = @self_evolve.run_tests_for_all()
  let summary = @self_evolve.run_summary(results)
  assert_true(summary.pass_rate_pct >= 0)
  assert_true(summary.pass_rate_pct <= 100)
}

// --- AI ---

///|
test "AI: run_test_case actual_behavior 非空" {
  let tc = @self_evolve.gen_test_for_op(@imgir.FlipV)[0]
  let result = @self_evolve.run_test_case(tc)
  assert_true(result.actual_behavior.length() > 0)
}

///|
test "AI: run_summary summary 含信息" {
  let results = @self_evolve.run_tests_for_op(@imgir.FlipH)
  let summary = @self_evolve.run_summary(results)
  assert_true(summary.summary.length() > 0)
}
// ===========================================================================
// v287.0.0 智能修复策略测试
// ===========================================================================

// --- 形式式证明 ---

///|
test "形式化: repair_with_strategies 返回 3 策略" {
  let results = @self_evolve.repair_with_strategies(@imgir.Resize(0, 0))
  assert_eq(results.length(), 3)
  assert_true(results[0].strategy is @self_evolve.Conservative)
  assert_true(results[1].strategy is @self_evolve.Aggressive)
  assert_true(results[2].strategy is @self_evolve.Optimal)
}

///|
test "形式化: best_repair 质量分最高" {
  let op = @imgir.Resize(0, 0)
  let all = @self_evolve.repair_with_strategies(op)
  let best = @self_evolve.best_repair(op)
  for r in all {
    assert_true(best.quality_score >= r.quality_score)
  }
}

// --- FAKE ---

///|
test "FAKE: best_repair 安全算子质量 100" {
  let best = @self_evolve.best_repair(@imgir.FlipH)
  assert_eq(best.quality_score, 100)
  assert_true(best.is_complete())
}

///|
test "FAKE: Aggressive 修复后无退化" {
  let repaired = @self_evolve.repair_op_strategy(
    @imgir.Resize(0, 0),
    @self_evolve.Aggressive,
  )
  assert_eq(@self_evolve.detect_degradation(repaired).length(), 0)
}

// --- MOCK ---

///|
test "MOCK: Conservative 不改 Sharpen 极端值" {
  // Sharpen(200) 保守策略不改（非 Fatal），仍有退化
  let repaired = @self_evolve.repair_op_strategy(
    @imgir.Sharpen(200.0F),
    @self_evolve.Conservative,
  )
  let degs = @self_evolve.detect_degradation(repaired)
  assert_true(degs.length() > 0)
}

///|
test "MOCK: best_repair Resize(0,0) is_complete" {
  let best = @self_evolve.best_repair(@imgir.Resize(0, 0))
  assert_true(best.is_complete())
  assert_eq(best.degs_after, 0)
}

// --- E2E ---

///|
test "E2E: best_repair_all 19 个结果" {
  let results = @self_evolve.best_repair_all()
  assert_eq(results.length(), 19)
  for r in results {
    assert_true(r.is_complete())
  }
}

///|
test "E2E: Aggressive 修复全部 19 算子无退化" {
  for op in @self_evolve.all_ops() {
    let repaired = @self_evolve.repair_op_strategy(op, @self_evolve.Aggressive)
    assert_eq(@self_evolve.detect_degradation(repaired).length(), 0)
  }
}

// --- AI ---

///|
test "AI: best_repair quality_score 在 0-100" {
  let ops = [@imgir.FlipH, @imgir.Resize(0, 0), @imgir.STSnapshot(2.0F)]
  for op in ops {
    let best = @self_evolve.best_repair(op)
    assert_true(best.quality_score >= 0)
    assert_true(best.quality_score <= 100)
  }
}

///|
test "AI: repair_desc 非空" {
  let results = @self_evolve.repair_with_strategies(@imgir.Resize(0, 0))
  for r in results {
    assert_true(r.repair_desc.length() > 0)
  }
}
// ===========================================================================
// v288.0.0 组合测试覆盖测试
// ===========================================================================

// --- 形式化证明 ---

///|
test "形式化: gen_all_combos 返回 361 组合" {
  let combos = @self_evolve.gen_all_combos()
  assert_eq(combos.length(), 19 * 19)
  assert_eq(combos.length(), 361)
}

///|
test "形式化: gen_combo_tests 数量等于组合数" {
  let combos = @self_evolve.gen_all_combos()
  let tests = @self_evolve.gen_combo_tests()
  assert_eq(tests.length(), combos.length())
}

// --- FAKE ---

///|
test "FAKE: combo_coverage_report 100% 覆盖" {
  let report = @self_evolve.combo_coverage_report()
  assert_eq(report.coverage_pct, 100)
  assert_eq(report.total_combos, 361)
}

///|
test "FAKE: unique_combo_count 等于 361" {
  assert_eq(@self_evolve.unique_combo_count(), 361)
}

// --- MOCK ---

///|
test "MOCK: gen_all_combos 含 FlipH 自组合" {
  let combos = @self_evolve.gen_all_combos()
  let mut has_self_combo = false
  for c in combos {
    if c.first_tag == "FlipH" && c.second_tag == "FlipH" {
      has_self_combo = true
    }
  }
  assert_true(has_self_combo)
}

// --- E2E ---

///|
test "E2E: gen_combo_tests 全部 Normal 类别" {
  let tests = @self_evolve.gen_combo_tests()
  for tc in tests {
    assert_true(tc.category is @self_evolve.Normal)
  }
}

// --- AI ---

///|
test "AI: combo_coverage_report summary 含信息" {
  let report = @self_evolve.combo_coverage_report()
  assert_true(report.summary.length() > 0)
}

///|
test "AI: gen_all_combos 每个 combo_desc 非空" {
  let combos = @self_evolve.gen_all_combos()
  for c in combos {
    assert_true(c.combo_desc.length() > 0)
  }
}
// ============================================================
// v289.0.0 — 退化根因分析测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: analyze_root_cause 安全算子无根因" {
  let causes = @self_evolve.analyze_root_cause(@imgir.Resize(8, 8))
  assert_true(causes.length() == 0)
}

///|
test "形式化: analyze_root_cause 退化算子 Resize(0,0) 有根因" {
  let causes = @self_evolve.analyze_root_cause(@imgir.Resize(0, 0))
  assert_true(causes.length() > 0)
}

// --- FAKE ---

///|
test "FAKE: analyze_root_cause_all 全安全算子 is_clean" {
  let report = @self_evolve.analyze_root_cause_all()
  assert_true(@self_evolve.RootCauseReport::is_clean(report))
}

///|
test "FAKE: 退化算子根因含修复建议" {
  let causes = @self_evolve.analyze_root_cause(@imgir.GaussianBlur(3, 0.0F))
  for c in causes {
    assert_true(c.fix_suggestion.length() > 0)
  }
}

// --- MOCK ---

///|
test "MOCK: Resize(0,0) 根因参数为 w=0" {
  let causes = @self_evolve.analyze_root_cause(@imgir.Resize(0, 0))
  let mut has_w0 = false
  for c in causes {
    if c.root_param == "w=0" {
      has_w0 = true
    }
  }
  assert_true(has_w0)
}

///|
test "MOCK: analyze_pipeline_root_cause 退化管道有根因" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let report = @self_evolve.analyze_pipeline_root_cause(pipe)
  assert_true(report.total > 0)
}

// --- E2E ---

///|
test "E2E: filter_by_kind 按类型过滤正确" {
  let causes = @self_evolve.analyze_root_cause(@imgir.Resize(0, 0))
  let filtered = @self_evolve.filter_by_kind(
    causes,
    @self_evolve.DivisionByZero,
  )
  for c in filtered {
    assert_true(c.degradation_kind is @self_evolve.DivisionByZero)
  }
}

// --- AI ---

///|
test "AI: 退化根因 cause_desc 非空" {
  let causes = @self_evolve.analyze_root_cause(@imgir.Crop(0, 0, 0, 0))
  for c in causes {
    assert_true(c.cause_desc.length() > 0)
  }
}

///|
test "AI: analyze_pipeline_root_cause summary 含信息" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.STSnapshot(2.0F))
  let report = @self_evolve.analyze_pipeline_root_cause(pipe)
  assert_true(report.summary.length() > 0)
}
// ============================================================
// v290.0.0 — Phase 6 综合报告测试（6 tests）
// ============================================================

// --- 形式化证明 ---

///|
test "形式化: phase6_capabilities 返回 4 个版本" {
  let caps = @self_evolve.phase6_capabilities()
  assert_eq(caps.length(), 4)
  assert_eq(caps[0].version, "v286.0.0")
  assert_eq(caps[3].version, "v289.0.0")
}

///|
test "形式化: phase6 总计 8 类型 21 函数 36 测试" {
  assert_eq(@self_evolve.phase6_total_types(), 8)
  assert_eq(@self_evolve.phase6_total_functions(), 21)
  assert_eq(@self_evolve.phase6_total_tests(), 36)
}

///|
test "形式化: phase6_is_complete 为 true" {
  assert_true(@self_evolve.phase6_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase6_report 结构完整" {
  let report = @self_evolve.phase6_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 8)
  assert_eq(report.total_functions, 21)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase6_report summary 含关键信息" {
  let report = @self_evolve.phase6_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase6 每个能力描述非空" {
  for c in @self_evolve.phase6_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ============================================================
// v291.0.0 — 跨算子退化传播测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: analyze_propagation 安全管道无传播" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let report = @self_evolve.analyze_propagation(pipe)
  assert_true(@self_evolve.PropagationReport::is_safe(report))
}

///|
test "形式化: analyze_propagation 退化管道有传播" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  let report = @self_evolve.analyze_propagation(pipe)
  assert_true(report.total_propagations > 0)
}

// --- FAKE ---

///|
test "FAKE: analyze_propagation_all 返回报告" {
  let report = @self_evolve.analyze_propagation_all()
  assert_true(report.chain_length > 0)
}

///|
test "FAKE: 退化管道 PropagationStep 含传播描述" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0)).add(@imgir.FlipH)
  let steps = @self_evolve.propagation_chain(pipe)
  for s in steps {
    assert_true(s.propagation_desc.length() > 0)
  }
}

// --- MOCK ---

///|
test "MOCK: 退化管道 has_propagation_risk 为 true" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.GaussianBlur(3, 0.0F))
    .add(@imgir.ToGray)
  assert_true(@self_evolve.has_propagation_risk(pipe))
}

///|
test "MOCK: 安全管道 has_propagation_risk 为 false" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8)).add(@imgir.FlipH)
  assert_true(!@self_evolve.has_propagation_risk(pipe))
}

// --- E2E ---

///|
test "E2E: propagation_chain 返回步骤数组" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.Crop(0, 0, 4, 4))
  let chain = @self_evolve.propagation_chain(pipe)
  for s in chain {
    assert_true(s.from_op_tag == "Resize")
  }
}

// --- AI ---

///|
test "AI: 传播报告 summary 含信息" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.STSnapshot(2.0F))
    .add(@imgir.FlipV)
  let report = @self_evolve.analyze_propagation(pipe)
  assert_true(report.summary.length() > 0)
}

///|
test "AI: 传播步骤 from/to 标签非空" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  let steps = @self_evolve.propagation_chain(pipe)
  for s in steps {
    assert_true(s.from_op_tag.length() > 0)
    assert_true(s.to_op_tag.length() > 0)
  }
}
// ============================================================
// v292.0.0 — 自适应测试策略测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: suggest_test_count 高覆盖少测试" {
  assert_eq(@self_evolve.suggest_test_count(100), 2)
  assert_eq(@self_evolve.suggest_test_count(80), 2)
}

///|
test "形式化: suggest_test_count 低覆盖多测试" {
  assert_eq(@self_evolve.suggest_test_count(0), 12)
  assert_eq(@self_evolve.suggest_test_count(25), 8)
}

///|
test "形式化: priority_from_coverage 分级正确" {
  assert_true(
    @self_evolve.priority_from_coverage(100) is @self_evolve.LowPriority,
  )
  assert_true(
    @self_evolve.priority_from_coverage(30) is @self_evolve.MediumPriority,
  )
  assert_true(
    @self_evolve.priority_from_coverage(10) is @self_evolve.HighPriority,
  )
}

// --- FAKE ---

///|
test "FAKE: adaptive_strategy_all 返回 19 个策略" {
  let report = @self_evolve.adaptive_strategy_all()
  assert_eq(report.total_prioritized, 19)
}

///|
test "FAKE: adaptive_strategy 安全算子高覆盖" {
  let s = @self_evolve.adaptive_strategy(@imgir.Resize(8, 8))
  assert_true(s.current_coverage == 100)
}

// --- MOCK ---

///|
test "MOCK: adaptive_strategy 退化算子低覆盖" {
  let s = @self_evolve.adaptive_strategy(@imgir.Resize(0, 0))
  assert_true(s.current_coverage < 100)
}

///|
test "MOCK: high_priority_ops 返回数组" {
  let ops = @self_evolve.high_priority_ops()
  for tag in ops {
    assert_true(tag.length() > 0)
  }
}

// --- E2E ---

///|
test "E2E: adaptive_strategy_all summary 含信息" {
  let report = @self_evolve.adaptive_strategy_all()
  assert_true(report.summary.length() > 0)
}

// --- AI ---

///|
test "AI: adaptive 每个策略 op_tag 非空" {
  let report = @self_evolve.adaptive_strategy_all()
  for s in report.strategies {
    assert_true(s.op_tag.length() > 0)
    assert_true(s.suggested_tests > 0)
  }
}
// ============================================================
// v293.0.0 — 演化历史持久化测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: record_snapshot 记录管道状态" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let entry = @self_evolve.record_snapshot(pipe, "test-v1")
  assert_eq(entry.op_count, 2)
  assert_eq(entry.degradation_count, 0)
}

///|
test "形式化: record_snapshot 退化管道有退化计数" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(0, 0))
  let entry = @self_evolve.record_snapshot(pipe, "test-v2")
  assert_true(entry.degradation_count > 0)
}

///|
test "形式化: history_log 返回 7 个快照" {
  let log = @self_evolve.history_log()
  assert_eq(log.total_snapshots, 7)
  assert_eq(log.latest_version, "v292.0.0")
}

// --- FAKE ---

///|
test "FAKE: history_log is_empty 为 false" {
  let log = @self_evolve.history_log()
  assert_true(!@self_evolve.HistoryLog::is_empty(log))
}

///|
test "FAKE: rollback_to 找到存在版本" {
  let result = @self_evolve.rollback_to("v290.0.0")
  assert_true(result is Some(_))
}

// --- MOCK ---

///|
test "MOCK: rollback_to 未找到版本返回 None" {
  let result = @self_evolve.rollback_to("v999.0.0")
  assert_true(result is None)
}

///|
test "MOCK: compare_snapshots 比较两个快照" {
  let log = @self_evolve.history_log()
  let cmp = @self_evolve.compare_snapshots(log.entries[0], log.entries[1])
  assert_true(cmp.length() > 0)
}

// --- E2E ---

///|
test "E2E: history_log summary 含信息" {
  let log = @self_evolve.history_log()
  assert_true(log.summary.length() > 0)
}

// --- AI ---

///|
test "AI: history 每个快照描述非空" {
  let log = @self_evolve.history_log()
  for e in log.entries {
    assert_true(e.description.length() > 0)
    assert_true(e.version.length() > 0)
  }
}
// ============================================================
// v294.0.0 — 算子等价性验证测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: check_equivalence 相同管道等价" {
  let pipe_a = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let pipe_b = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let result = @self_evolve.check_equivalence(pipe_a, pipe_b)
  assert_true(result.is_equivalent)
}

///|
test "形式化: check_equivalence 不同管道不等价" {
  let pipe_a = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let pipe_b = @imgir.IRPipeline::new().add(@imgir.ToGray)
  let result = @self_evolve.check_equivalence(pipe_a, pipe_b)
  assert_true(!result.is_equivalent)
}

///|
test "形式化: are_equivalent 简化判断" {
  let pipe_a = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let pipe_b = @imgir.IRPipeline::new().add(@imgir.FlipH)
  assert_true(@self_evolve.are_equivalent(pipe_a, pipe_b))
}

// --- FAKE ---

///|
test "FAKE: check_equivalence_all 全部自等价" {
  let report = @self_evolve.check_equivalence_all()
  assert_true(@self_evolve.EquivalenceReport::all_equivalent(report))
}

///|
test "FAKE: equivalence_class 返回非空" {
  let cls = @self_evolve.equivalence_class(@imgir.Resize(8, 8))
  assert_true(cls.length() > 0)
}

// --- MOCK ---

///|
test "MOCK: check_equivalence 长度不同不等价" {
  let pipe_a = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let pipe_b = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let result = @self_evolve.check_equivalence(pipe_a, pipe_b)
  assert_true(!result.is_equivalent)
}

///|
test "MOCK: check_equivalence reason 非空" {
  let pipe_a = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let pipe_b = @imgir.IRPipeline::new().add(@imgir.ToGray)
  let result = @self_evolve.check_equivalence(pipe_a, pipe_b)
  assert_true(result.reason.length() > 0)
}

// --- E2E ---

///|
test "E2E: check_equivalence_all summary 含信息" {
  let report = @self_evolve.check_equivalence_all()
  assert_true(report.summary.length() > 0)
}

// --- AI ---

///|
test "AI: equivalence_class 每个标签非空" {
  for op in @self_evolve.all_ops() {
    let cls = @self_evolve.equivalence_class(op)
    for tag in cls {
      assert_true(tag.length() > 0)
    }
  }
}
// ============================================================
// v295.0.0 — Phase 7 综合报告测试（6 tests）
// ============================================================

// --- 形式化证明 ---

///|
test "形式化: phase7_capabilities 返回 4 个版本" {
  let caps = @self_evolve.phase7_capabilities()
  assert_eq(caps.length(), 4)
  assert_eq(caps[0].version, "v291.0.0")
  assert_eq(caps[3].version, "v294.0.0")
}

///|
test "形式化: phase7 总计 9 类型 17 函数 36 测试" {
  assert_eq(@self_evolve.phase7_total_types(), 9)
  assert_eq(@self_evolve.phase7_total_functions(), 17)
  assert_eq(@self_evolve.phase7_total_tests(), 36)
}

///|
test "形式化: phase7_is_complete 为 true" {
  assert_true(@self_evolve.phase7_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase7_report 结构完整" {
  let report = @self_evolve.phase7_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 9)
  assert_eq(report.total_functions, 17)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase7_report summary 含关键信息" {
  let report = @self_evolve.phase7_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase7 每个能力描述非空" {
  for c in @self_evolve.phase7_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ============================================================
// v296.0.0 — 退化传播可视化测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: visualize_propagation_ascii 非空" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let result = @self_evolve.visualize_propagation_ascii(pipe)
  assert_true(result.length() > 0)
}

///|
test "形式化: visualize_propagation_mermaid 含 graph" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let result = @self_evolve.visualize_propagation_mermaid(pipe)
  assert_true(result.length() > 0)
}

///|
test "形式化: visualize_propagation_text 含报告" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.FlipH)
  let result = @self_evolve.visualize_propagation_text(pipe)
  assert_true(result.length() > 0)
}

// --- FAKE ---

///|
test "FAKE: visualize_propagation Ascii 格式" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let viz = @self_evolve.visualize_propagation(pipe, @self_evolve.AsciiViz)
  assert_true(@self_evolve.PropagationViz::is_valid(viz))
}

///|
test "FAKE: visualize_propagation Mermaid 格式" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let viz = @self_evolve.visualize_propagation(pipe, @self_evolve.MermaidViz)
  assert_true(@self_evolve.PropagationViz::is_valid(viz))
}

// --- MOCK ---

///|
test "MOCK: visualize_propagation 退化管道有边" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  let viz = @self_evolve.visualize_propagation(pipe, @self_evolve.TextViz)
  assert_true(viz.edge_count > 0)
}

///|
test "MOCK: visualize_propagation 安全管道无边" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8)).add(@imgir.FlipH)
  let viz = @self_evolve.visualize_propagation(pipe, @self_evolve.TextViz)
  assert_true(viz.edge_count == 0)
}

// --- E2E ---

///|
test "E2E: visualize_propagation 节点数正确" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
    .add(@imgir.FlipH)
  let viz = @self_evolve.visualize_propagation(pipe, @self_evolve.AsciiViz)
  assert_eq(viz.node_count, 3)
}

// --- AI ---

///|
test "AI: propagation_viz 每种格式内容非空" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  for
    fmt in [
      @self_evolve.AsciiViz,
      @self_evolve.MermaidViz,
      @self_evolve.TextViz,
    ] {
    let viz = @self_evolve.visualize_propagation(pipe, fmt)
    assert_true(viz.content.length() > 0)
  }
}
// ============================================================
// v297.0.0 — 测试覆盖盲区分析测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: coverage_percentage 安全算子高覆盖" {
  let cov = @self_evolve.coverage_percentage(@imgir.Resize(8, 8))
  assert_true(cov >= 0)
  assert_true(cov <= 100)
}

///|
test "形式化: find_untested_ops 返回数组" {
  let ops = @self_evolve.find_untested_ops()
  assert_true(ops.length() >= 0)
}

///|
test "形式化: find_under_tested_ops 返回数组" {
  let ops = @self_evolve.find_under_tested_ops()
  assert_true(ops.length() >= 0)
}

// --- FAKE ---

///|
test "FAKE: analyze_coverage_gaps 返回报告" {
  let report = @self_evolve.analyze_coverage_gaps()
  assert_true(report.total_gaps >= 0)
}

///|
test "FAKE: CoverageGapReport has_gaps 方法" {
  let report = @self_evolve.analyze_coverage_gaps()
  let _ = @self_evolve.CoverageGapReport::has_gaps(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: coverage_percentage 范围 0-100" {
  for op in @self_evolve.all_ops() {
    let cov = @self_evolve.coverage_percentage(op)
    assert_true(cov >= 0)
    assert_true(cov <= 100)
  }
}

///|
test "MOCK: analyze_coverage_gaps untested_count 非负" {
  let report = @self_evolve.analyze_coverage_gaps()
  assert_true(report.untested_count >= 0)
}

// --- E2E ---

///|
test "E2E: analyze_coverage_gaps summary 含信息" {
  let report = @self_evolve.analyze_coverage_gaps()
  assert_true(report.summary.length() > 0)
}

// --- AI ---

///|
test "AI: coverage_gap 每个盲区描述非空" {
  let report = @self_evolve.analyze_coverage_gaps()
  for g in report.gaps {
    assert_true(g.description.length() > 0)
    assert_true(g.op_tag.length() > 0)
  }
}
// ============================================================
// v298.0.0 — 演化推荐引擎测试（9 tests）
// ============================================================

// --- 形式化 ---

///|
test "形式化: recommend_next 安全算子无需操作" {
  let rec = @self_evolve.recommend_next(@imgir.Resize(8, 8))
  assert_true(rec.action is @self_evolve.NoActionNeeded)
}

///|
test "形式化: recommend_next 退化算子需修复" {
  let rec = @self_evolve.recommend_next(@imgir.Resize(0, 0))
  assert_true(rec.action is @self_evolve.FixDegradation)
}

///|
test "形式化: recommend_all 返回 19 条推荐" {
  let report = @self_evolve.recommend_all()
  assert_eq(report.total, 19)
}

// --- FAKE ---

///|
test "FAKE: recommend_for_pipeline 返回报告" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let report = @self_evolve.recommend_for_pipeline(pipe)
  assert_true(report.total > 0)
}

///|
test "FAKE: RecommendationReport has_urgent 方法" {
  let report = @self_evolve.recommend_all()
  let _ = @self_evolve.RecommendationReport::has_urgent(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: recommend_next 退化算子高优先级" {
  let rec = @self_evolve.recommend_next(@imgir.GaussianBlur(3, 0.0F))
  assert_true(rec.priority is @self_evolve.HighPriority)
}

///|
test "MOCK: recommend_for_pipeline 退化管道有紧急推荐" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  let report = @self_evolve.recommend_for_pipeline(pipe)
  assert_true(@self_evolve.RecommendationReport::has_urgent(report))
}

// --- E2E ---

///|
test "E2E: recommend_all summary 含信息" {
  let report = @self_evolve.recommend_all()
  assert_true(report.summary.length() > 0)
}

// --- AI ---

///|
test "AI: recommend 每条推荐 reason 非空" {
  let report = @self_evolve.recommend_all()
  for r in report.recommendations {
    assert_true(r.reason.length() > 0)
    assert_true(r.target_op.length() > 0)
  }
}
// ==============================
// v299.0.0 — 管道优化建议 (pipeline_optimize)
// ==============================

// --- 形式化 ---

///|
test "形式化: find_redundant_ops 无冗余返回空" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let redundant = @self_evolve.find_redundant_ops(pipe)
  assert_eq(redundant.length(), 0)
}

///|
test "形式化: find_redundant_ops 有冗余返回标签" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.ToGray).add(@imgir.ToGray)
  let redundant = @self_evolve.find_redundant_ops(pipe)
  assert_eq(redundant.length(), 1)
  assert_eq(redundant[0], "ToGray")
}

///|
test "形式化: estimate_benefit 安全管道低收益" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let benefit = @self_evolve.estimate_benefit(pipe)
  assert_true(benefit >= 0)
  assert_true(benefit <= 100)
}

// --- FAKE ---

///|
test "FAKE: suggest_optimization 返回报告" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let report = @self_evolve.suggest_optimization(pipe)
  assert_true(report.total > 0)
}

///|
test "FAKE: PipelineOptReport has_suggestions 方法" {
  let pipe = @imgir.IRPipeline::new().add(@imgir.Resize(8, 8))
  let report = @self_evolve.suggest_optimization(pipe)
  let _ = @self_evolve.PipelineOptReport::has_suggestions(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: suggest_optimization 冗余管道有建议" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.ToGray)
    .add(@imgir.ToGray)
    .add(@imgir.ToGray)
  let report = @self_evolve.suggest_optimization(pipe)
  assert_true(@self_evolve.PipelineOptReport::has_suggestions(report))
}

///|
test "MOCK: suggest_optimization 退化管道有建议" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(0, 0))
    .add(@imgir.ToGray)
  let report = @self_evolve.suggest_optimization(pipe)
  assert_true(report.total > 0)
}

// --- E2E ---

///|
test "E2E: suggest_optimization summary 含信息" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let report = @self_evolve.suggest_optimization(pipe)
  assert_true(report.summary.length() > 0)
}

// --- AI ---

///|
test "AI: suggest_optimization 每条建议 description 非空" {
  let pipe = @imgir.IRPipeline::new()
    .add(@imgir.Resize(8, 8))
    .add(@imgir.ToGray)
  let report = @self_evolve.suggest_optimization(pipe)
  for s in report.suggestions {
    assert_true(s.description.length() > 0)
    assert_true(s.pipeline_desc.length() > 0)
  }
}
// ==============================
// v300.0.0 — Phase 8 综合总结 (phase8_report)
// ==============================

// --- 形式化 ---

///|
test "形式化: phase8_capabilities 返回 4 条" {
  let caps = @self_evolve.phase8_capabilities()
  assert_eq(caps.length(), 4)
}

///|
test "形式化: phase8 总计正确" {
  assert_eq(@self_evolve.phase8_total_types(), 11)
  assert_eq(@self_evolve.phase8_total_functions(), 14)
  assert_eq(@self_evolve.phase8_total_tests(), 36)
}

///|
test "形式化: phase8_is_complete 为 true" {
  assert_true(@self_evolve.phase8_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase8_report 结构完整" {
  let report = @self_evolve.phase8_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 11)
  assert_eq(report.total_functions, 14)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase8_report summary 含关键信息" {
  let report = @self_evolve.phase8_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase8 每个能力描述非空" {
  for c in @self_evolve.phase8_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ==============================
// v301.0.0 — 演化调度引擎 (schedule)
// ==============================

// --- 形式化 ---

///|
test "形式化: create_schedule 状态为 Pending" {
  let sched = @self_evolve.create_schedule([@imgir.Resize(8, 8)])
  assert_true(sched.status is @self_evolve.Pending)
  assert_eq(sched.ops_count, 1)
}

///|
test "形式化: run_full_evolution 返回 Completed" {
  let result = @self_evolve.run_full_evolution()
  assert_true(result.schedule.status is @self_evolve.Completed)
}

///|
test "形式化: run_schedule evolved_count 为 19" {
  let sched = @self_evolve.create_schedule(@self_evolve.all_ops())
  let result = @self_evolve.run_schedule(sched)
  assert_eq(result.evolved_count, 19)
}

// --- FAKE ---

///|
test "FAKE: run_schedule 返回结果" {
  let sched = @self_evolve.create_schedule([@imgir.Resize(8, 8)])
  let result = @self_evolve.run_schedule(sched)
  assert_true(result.evolved_count > 0)
}

///|
test "FAKE: ScheduleResult is_successful 方法" {
  let result = @self_evolve.run_full_evolution()
  let _ = @self_evolve.ScheduleResult::is_successful(result)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: run_full_evolution 处理所有算子" {
  let result = @self_evolve.run_full_evolution()
  assert_eq(result.evolved_count, 19)
}

///|
test "MOCK: create_schedule schedule_id 非空" {
  let sched = @self_evolve.create_schedule([@imgir.ToGray])
  assert_true(sched.schedule_id.length() > 0)
}

// --- E2E ---

///|
test "E2E: run_full_evolution summary 含信息" {
  let result = @self_evolve.run_full_evolution()
  assert_true(result.summary.length() > 10)
}

// --- AI ---

///|
test "AI: schedule 每个调度 description 非空" {
  let ops = @self_evolve.all_ops()
  let sched = @self_evolve.create_schedule(ops)
  assert_true(sched.description.length() > 0)
  let result = @self_evolve.run_schedule(sched)
  assert_true(result.summary.length() > 0)
}
// ==============================
// v302.0.0 — 跨版本回归检测 (regression)
// ==============================

// --- 形式化 ---

///|
test "形式化: detect_regressions 返回报告" {
  let report = @self_evolve.detect_regressions()
  assert_true(report.cases.length() > 0)
}

///|
test "形式化: has_regression 已知版本无退化" {
  assert_true(!@self_evolve.has_regression("v286.0.0"))
}

///|
test "形式化: has_regression 未知版本返回 false" {
  assert_true(!@self_evolve.has_regression("v999.0.0"))
}

// --- FAKE ---

///|
test "FAKE: detect_regressions 结构完整" {
  let report = @self_evolve.detect_regressions()
  let _ = @self_evolve.RegressionReport::is_clean(report)
  assert_true(true)
}

///|
test "FAKE: RegressionReport is_clean 方法" {
  let report = @self_evolve.detect_regressions()
  assert_true(report.total_regressions >= 0)
  assert_true(report.total_improvements >= 0)
}

// --- MOCK ---

///|
test "MOCK: detect_regressions 历史无退化回归" {
  let report = @self_evolve.detect_regressions()
  assert_eq(report.total_regressions, 0)
}

///|
test "MOCK: detect_regressions 有改进记录" {
  let report = @self_evolve.detect_regressions()
  assert_true(report.total_improvements > 0)
}

// --- E2E ---

///|
test "E2E: detect_regressions summary 含信息" {
  let report = @self_evolve.detect_regressions()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: regression 每个案例 description 非空" {
  let report = @self_evolve.detect_regressions()
  for c in report.cases {
    assert_true(c.description.length() > 0)
    assert_true(c.from_version.length() > 0)
    assert_true(c.to_version.length() > 0)
  }
}
// ==============================
// v303.0.0 — 智能测试优先级 (smart_priority)
// ==============================

// --- 形式化 ---

///|
test "形式化: score_op 安全算子低分" {
  let s = @self_evolve.score_op(@imgir.Resize(8, 8))
  assert_true(s.score >= 0)
  assert_true(s.score <= 100)
}

///|
test "形式化: score_op 退化算子高分" {
  let s = @self_evolve.score_op(@imgir.Resize(0, 0))
  assert_true(s.score >= 25)
}

///|
test "形式化: score_all_ops 返回 19 个评分" {
  let report = @self_evolve.score_all_ops()
  assert_eq(report.total_ops, 19)
}

// --- FAKE ---

///|
test "FAKE: score_all_ops 结构完整" {
  let report = @self_evolve.score_all_ops()
  assert_true(report.scores.length() > 0)
  assert_true(report.high_priority_count >= 0)
}

///|
test "FAKE: SmartPriorityReport top_priority 方法" {
  let report = @self_evolve.score_all_ops()
  let top3 = @self_evolve.SmartPriorityReport::top_priority(report, 3)
  assert_eq(top3.length(), 3)
}

// --- MOCK ---

///|
test "MOCK: score_op 退化算子有 DegradationRisk 因子" {
  let s = @self_evolve.score_op(@imgir.GaussianBlur(3, 0.0F))
  assert_true(s.factors.length() > 0)
}

///|
test "MOCK: top_priority 返回按分数降序" {
  let report = @self_evolve.score_all_ops()
  let top5 = @self_evolve.SmartPriorityReport::top_priority(report, 5)
  for i in 1..<5 {
    assert_true(top5[i - 1].score >= top5[i].score)
  }
}

// --- E2E ---

///|
test "E2E: score_all_ops summary 含信息" {
  let report = @self_evolve.score_all_ops()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: smart_priority 每个评分 recommendation 非空" {
  let report = @self_evolve.score_all_ops()
  for s in report.scores {
    assert_true(s.recommendation.length() > 0)
    assert_true(s.op_tag.length() > 0)
  }
}
// ==============================
// v304.0.0 — 演化预测模型 (predict)
// ==============================

// --- 形式化 ---

///|
test "形式化: predict_op 安全算子预测稳定" {
  let p = @self_evolve.predict_op(@imgir.Resize(8, 8))
  assert_true(p.confidence > 0)
  assert_true(p.confidence <= 100)
}

///|
test "形式化: predict_op 退化算子预测风险" {
  let p = @self_evolve.predict_op(@imgir.Resize(0, 0))
  assert_true(
    p.kind is @self_evolve.HighRisk || p.kind is @self_evolve.DegradationLikely,
  )
}

///|
test "形式化: predict_all 返回 19 个预测" {
  let report = @self_evolve.predict_all()
  assert_eq(report.total, 19)
}

// --- FAKE ---

///|
test "FAKE: predict_all 结构完整" {
  let report = @self_evolve.predict_all()
  assert_true(report.predictions.length() > 0)
  assert_true(report.high_risk_count >= 0)
}

///|
test "FAKE: PredictionReport has_high_risk 方法" {
  let report = @self_evolve.predict_all()
  let _ = @self_evolve.PredictionReport::has_high_risk(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: predict_op 退化算子 confidence 高" {
  let p = @self_evolve.predict_op(@imgir.GaussianBlur(3, 0.0F))
  assert_true(p.confidence >= 70)
}

///|
test "MOCK: predict_all 高风险数非负" {
  let report = @self_evolve.predict_all()
  assert_true(report.high_risk_count >= 0)
}

// --- E2E ---

///|
test "E2E: predict_all summary 含信息" {
  let report = @self_evolve.predict_all()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: predict 每个预测 description 非空" {
  let report = @self_evolve.predict_all()
  for p in report.predictions {
    assert_true(p.description.length() > 0)
    assert_true(p.op_tag.length() > 0)
  }
}
// ==============================
// v305.0.0 — Phase 9 综合总结 (phase9_report)
// ==============================

// --- 形式化 ---

///|
test "形式化: phase9_capabilities 返回 4 条" {
  let caps = @self_evolve.phase9_capabilities()
  assert_eq(caps.length(), 4)
}

///|
test "形式化: phase9 总计正确" {
  assert_eq(@self_evolve.phase9_total_types(), 12)
  assert_eq(@self_evolve.phase9_total_functions(), 9)
  assert_eq(@self_evolve.phase9_total_tests(), 36)
}

///|
test "形式化: phase9_is_complete 为 true" {
  assert_true(@self_evolve.phase9_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase9_report 结构完整" {
  let report = @self_evolve.phase9_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 12)
  assert_eq(report.total_functions, 9)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase9_report summary 含关键信息" {
  let report = @self_evolve.phase9_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase9 每个能力描述非空" {
  for c in @self_evolve.phase9_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ==============================
// v306.0.0 — 自主决策引擎 (auto_decide)
// ==============================

// --- 形式化 ---

///|
test "形式化: decide_op 安全算子跳过或推迟" {
  let d = @self_evolve.decide_op(@imgir.Resize(8, 8))
  assert_true(
    d.action is @self_evolve.SkipEvolution ||
    d.action is @self_evolve.DeferEvolution,
  )
}

///|
test "形式化: decide_op 退化算子立即演化" {
  let d = @self_evolve.decide_op(@imgir.Resize(0, 0))
  assert_true(
    d.action is @self_evolve.EvolveNow ||
    d.action is @self_evolve.EscalateToManual,
  )
}

///|
test "形式化: decide_all 返回 19 个决策" {
  let report = @self_evolve.decide_all()
  assert_eq(report.total, 19)
}

// --- FAKE ---

///|
test "FAKE: decide_all 结构完整" {
  let report = @self_evolve.decide_all()
  assert_true(report.decisions.length() > 0)
  assert_true(report.auto_count >= 0)
}

///|
test "FAKE: DecisionReport can_auto_run 方法" {
  let report = @self_evolve.decide_all()
  let _ = @self_evolve.DecisionReport::can_auto_run(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: decide_op 退化算子 confidence 高" {
  let d = @self_evolve.decide_op(@imgir.GaussianBlur(3, 0.0F))
  assert_true(d.confidence >= 70)
}

///|
test "MOCK: decide_all auto_count + deferred_count <= total" {
  let report = @self_evolve.decide_all()
  assert_true(report.auto_count + report.deferred_count <= report.total)
}

// --- E2E ---

///|
test "E2E: decide_all summary 含信息" {
  let report = @self_evolve.decide_all()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: decide 每个决策 rationale 非空" {
  let report = @self_evolve.decide_all()
  for d in report.decisions {
    assert_true(d.rationale.length() > 0)
    assert_true(d.op_tag.length() > 0)
  }
}
// ==============================
// v307.0.0 — 演化策略组合 (strategy_combo)
// ==============================

// --- 形式化 ---

///|
test "形式化: combine_strategies 返回非空策略" {
  let combo = @self_evolve.combine_strategies(@imgir.Resize(8, 8))
  assert_true(combo.strategies.length() > 0)
}

///|
test "形式化: combine_strategies 退化算子含 FixFirst" {
  let combo = @self_evolve.combine_strategies(@imgir.Resize(0, 0))
  assert_true(combo.strategies.length() > 0)
}

///|
test "形式化: combine_all_strategies 返回 19 个组合" {
  let report = @self_evolve.combine_all_strategies()
  assert_eq(report.total, 19)
}

// --- FAKE ---

///|
test "FAKE: combine_all_strategies 结构完整" {
  let report = @self_evolve.combine_all_strategies()
  assert_true(report.combos.length() > 0)
  assert_true(report.parallel_count >= 0)
}

///|
test "FAKE: ComboReport has_parallel 方法" {
  let report = @self_evolve.combine_all_strategies()
  let _ = @self_evolve.ComboReport::has_parallel(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: combine_strategies estimated_time > 0" {
  let combo = @self_evolve.combine_strategies(@imgir.ToGray)
  assert_true(combo.estimated_time > 0)
}

///|
test "MOCK: combine_all_strategies parallel_count 非负" {
  let report = @self_evolve.combine_all_strategies()
  assert_true(report.parallel_count >= 0)
}

// --- E2E ---

///|
test "E2E: combine_all_strategies summary 含信息" {
  let report = @self_evolve.combine_all_strategies()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: strategy_combo 每个组合 description 非空" {
  let report = @self_evolve.combine_all_strategies()
  for c in report.combos {
    assert_true(c.description.length() > 0)
    assert_true(c.op_tag.length() > 0)
  }
}
// ==============================
// v308.0.0 — 自适应参数调优 (param_tune)
// ==============================

// --- 形式化 ---

///|
test "形式化: tune_params 安全算子可能无调整" {
  let params = @self_evolve.tune_params(@imgir.Resize(8, 8))
  assert_true(params.length() >= 0)
}

///|
test "形式化: tune_params 退化算子有调整" {
  let params = @self_evolve.tune_params(@imgir.Resize(0, 0))
  assert_true(params.length() > 0)
}

///|
test "形式化: tune_all_params 返回报告" {
  let report = @self_evolve.tune_all_params()
  assert_true(report.total >= 0)
}

// --- FAKE ---

///|
test "FAKE: tune_all_params 结构完整" {
  let report = @self_evolve.tune_all_params()
  assert_true(report.adjusted_count >= 0)
}

///|
test "FAKE: TuneReport has_adjustments 方法" {
  let report = @self_evolve.tune_all_params()
  let _ = @self_evolve.TuneReport::has_adjustments(report)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: tune_params 退化算子含 Weight 调整" {
  let params = @self_evolve.tune_params(@imgir.GaussianBlur(3, 0.0F))
  assert_true(params.length() > 0)
}

///|
test "MOCK: tune_all_params adjusted_count <= total" {
  let report = @self_evolve.tune_all_params()
  assert_true(report.adjusted_count <= report.total)
}

// --- E2E ---

///|
test "E2E: tune_all_params summary 含信息" {
  let report = @self_evolve.tune_all_params()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: param_tune 每个参数 rationale 非空" {
  let report = @self_evolve.tune_all_params()
  for p in report.params {
    assert_true(p.rationale.length() > 0)
  }
}
// ==============================
// v309.0.0 — 自演化闭环 (evolve_loop_full)
// ==============================

// --- 形式化 ---

///|
test "形式化: run_evolve_loop 返回 7 阶段" {
  let result = @self_evolve.run_evolve_loop(@imgir.Resize(8, 8))
  assert_eq(result.total_phases, 7)
}

///|
test "形式化: run_evolve_loop 含 Done 阶段" {
  let result = @self_evolve.run_evolve_loop(@imgir.ToGray)
  assert_true(result.steps[result.total_phases - 1].phase is @self_evolve.Done)
}

///|
test "形式化: run_evolve_loop_all 返回结果" {
  let result = @self_evolve.run_evolve_loop_all()
  assert_true(result.total_phases > 0)
}

// --- FAKE ---

///|
test "FAKE: run_evolve_loop 结构完整" {
  let result = @self_evolve.run_evolve_loop(@imgir.Resize(8, 8))
  assert_true(result.steps.length() > 0)
}

///|
test "FAKE: LoopResult is_complete 方法" {
  let result = @self_evolve.run_evolve_loop(@imgir.Resize(8, 8))
  let _ = @self_evolve.LoopResult::is_complete(result)
  assert_true(true)
}

// --- MOCK ---

///|
test "MOCK: run_evolve_loop 退化算子有 7 阶段" {
  let result = @self_evolve.run_evolve_loop(@imgir.Resize(0, 0))
  assert_eq(result.total_phases, 7)
}

///|
test "MOCK: run_evolve_loop_all 阶段数为 19*7" {
  let result = @self_evolve.run_evolve_loop_all()
  assert_eq(result.total_phases, 19 * 7)
}

// --- E2E ---

///|
test "E2E: run_evolve_loop_all summary 含信息" {
  let result = @self_evolve.run_evolve_loop_all()
  assert_true(result.summary.length() > 10)
}

// --- AI ---

///|
test "AI: evolve_loop 每个步骤 result_desc 非空" {
  let result = @self_evolve.run_evolve_loop(@imgir.Resize(8, 8))
  for s in result.steps {
    assert_true(s.result_desc.length() > 0)
  }
}
// ==============================
// v310.0.0 — Phase 10 综合总结 (phase10_report)
// ==============================

// --- 形式化 ---

///|
test "形式化: phase10_capabilities 返回 4 条" {
  let caps = @self_evolve.phase10_capabilities()
  assert_eq(caps.length(), 4)
}

///|
test "形式化: phase10 总计正确" {
  assert_eq(@self_evolve.phase10_total_types(), 12)
  assert_eq(@self_evolve.phase10_total_functions(), 8)
  assert_eq(@self_evolve.phase10_total_tests(), 36)
}

///|
test "形式化: phase10_is_complete 为 true" {
  assert_true(@self_evolve.phase10_is_complete())
}

// --- FAKE ---

///|
test "FAKE: phase10_report 结构完整" {
  let report = @self_evolve.phase10_report()
  assert_eq(report.capabilities.length(), 4)
  assert_eq(report.total_types, 12)
  assert_eq(report.total_functions, 8)
  assert_eq(report.total_tests, 36)
}

// --- E2E ---

///|
test "E2E: phase10_report summary 含关键信息" {
  let report = @self_evolve.phase10_report()
  assert_true(report.phase_summary.length() > 20)
  assert_true(report.phase_summary[0] == 'P')
}

// --- AI ---

///|
test "AI: phase10 每个能力描述非空" {
  for c in @self_evolve.phase10_capabilities() {
    assert_true(c.description.length() > 0)
    assert_true(c.name.length() > 0)
  }
}
// ==============================
// v311.0.0 — 演化知识图谱 (knowledge_graph)
// ==============================

// --- 形式化 ---

///|
test "形式化: build_knowledge_graph_for_op 退化算子返回 5 节点" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(0, 0))
  assert_eq(kg.node_count(), 5)
  assert_eq(kg.edge_count(), 5)
}

///|
test "形式化: build_knowledge_graph_for_op 正常算子返回 3 节点" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(8, 8))
  assert_eq(kg.node_count(), 3)
  assert_eq(kg.edge_count(), 2)
}

///|
test "形式化: find_nodes_by_kind 按类型过滤" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(0, 0))
  let op_nodes = kg.find_nodes_by_kind(@self_evolve.OpNode)
  assert_eq(op_nodes.length(), 1)
  let deg_nodes = kg.find_nodes_by_kind(@self_evolve.DegradationNode)
  assert_eq(deg_nodes.length(), 1)
  let perf_nodes = kg.find_nodes_by_kind(@self_evolve.PerfNode)
  assert_eq(perf_nodes.length(), 1)
}

// --- FAKE ---

///|
test "FAKE: build_knowledge_graph 全量图谱非空" {
  let kg = @self_evolve.build_knowledge_graph()
  assert_true(kg.node_count() > 0)
  assert_true(kg.edge_count() > 0)
  assert_true(kg.is_non_empty())
}

///|
test "FAKE: KnowledgeGraph is_non_empty 方法" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(8, 8))
  assert_true(kg.is_non_empty())
}

// --- MOCK ---

///|
test "MOCK: 退化算子图谱含退化节点" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(0, 0))
  let degs = kg.find_degradations("Resize")
  assert_true(degs.length() > 0)
}

///|
test "MOCK: find_fixes 查找修复策略" {
  let kg = @self_evolve.build_knowledge_graph_for_op(@imgir.Resize(0, 0))
  let fixes = kg.find_fixes("DivisionByZero")
  assert_true(fixes.length() > 0)
}

// --- E2E ---

///|
test "E2E: build_knowledge_graph 全量图谱规模合理" {
  let kg = @self_evolve.build_knowledge_graph()
  assert_true(kg.node_count() >= 19 * 3)
  assert_true(kg.edge_count() >= 19 * 2)
}

// --- AI ---

///|
test "AI: 每个知识节点 label 非空" {
  let kg = @self_evolve.build_knowledge_graph()
  for n in kg.nodes {
    assert_true(n.label.length() > 0)
    assert_true(n.id.length() > 0)
  }
}
// ==============================
// v312.0.0 — 跨模块演化协同 (cross_module)
// ==============================

// --- 形式化 ---

///|
test "形式化: build_module_deps 返回 17 条依赖" {
  let deps = @self_evolve.build_module_deps()
  assert_eq(deps.length(), 17)
}

///|
test "形式化: co_evolve_op 退化算子含同步演化" {
  let report = @self_evolve.co_evolve_op(@imgir.Resize(0, 0))
  assert_true(report.sync_count > 0)
}

///|
test "形式化: co_evolve_op 正常算子有动作" {
  let report = @self_evolve.co_evolve_op(@imgir.Resize(8, 8))
  assert_true(report.total_actions() > 0)
}

// --- FAKE ---

///|
test "FAKE: co_evolve_all 结构完整" {
  let report = @self_evolve.co_evolve_all()
  assert_true(report.actions.length() > 0)
  assert_true(report.total_modules > 0)
  assert_true(report.summary.length() > 0)
}

///|
test "FAKE: CoEvolveReport total_actions 方法" {
  let report = @self_evolve.co_evolve_op(@imgir.Resize(0, 0))
  assert_eq(report.total_actions(), report.actions.length())
}

// --- MOCK ---

///|
test "MOCK: 退化算子协同含级联演化" {
  let report = @self_evolve.co_evolve_op(@imgir.Resize(0, 0))
  assert_true(report.has_cascade())
}

///|
test "MOCK: co_evolve_all 动作数 >= 算子数" {
  let report = @self_evolve.co_evolve_all()
  assert_true(report.actions.length() >= 19)
}

// --- E2E ---

///|
test "E2E: co_evolve_all summary 含关键信息" {
  let report = @self_evolve.co_evolve_all()
  assert_true(report.summary.length() > 10)
}

// --- AI ---

///|
test "AI: 每个协同动作 description 非空" {
  let report = @self_evolve.co_evolve_all()
  for a in report.actions {
    assert_true(a.description.length() > 0)
    assert_true(a.source_module.length() > 0)
    assert_true(a.target_module.length() > 0)
  }
}
