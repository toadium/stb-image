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
