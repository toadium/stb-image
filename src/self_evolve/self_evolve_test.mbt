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
