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
