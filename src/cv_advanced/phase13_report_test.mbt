// Phase 13 报告测试 — Phase 13 report tests
// Phase 13 v345: 深度学习大扩展 — Phase 13 总结。

///|
test "phase13_capabilities: 能力清单" {
  let caps = @cv_advanced.phase13_capabilities()
  assert_true(caps.length() == 14)
}

///|
test "phase13_total_types: 总类型数" {
  let total = @cv_advanced.phase13_total_types()
  assert_true(total > 0)
  assert_true(total >= 40)
}

///|
test "phase13_total_functions: 总函数数" {
  let total = @cv_advanced.phase13_total_functions()
  assert_true(total > 0)
  assert_true(total >= 70)
}

///|
test "phase13_total_tests: 总测试数" {
  let total = @cv_advanced.phase13_total_tests()
  assert_true(total == 126)
}

///|
test "phase13_report: 综合报告" {
  let report = @cv_advanced.phase13_report()
  assert_true(report.is_complete)
  assert_true(report.capabilities.length() == 14)
  assert_true(report.total_types > 0)
  assert_true(report.total_functions > 0)
  assert_true(report.total_tests > 0)
}

///|
test "phase13_is_complete: 完成状态" {
  let complete = @cv_advanced.phase13_is_complete()
  assert_true(complete)
}

///|
test "Phase13Capability: 构造" {
  let cap : @cv_advanced.Phase13Capability = {
    name: "test",
    version: "v999",
    types_count: 1,
    functions_count: 2,
    tests_count: 3,
  }
  assert_true(cap.types_count == 1)
  assert_true(cap.functions_count == 2)
}

///|
test "Phase13Report: 构造" {
  let report : @cv_advanced.Phase13Report = {
    capabilities: [],
    total_types: 0,
    total_functions: 0,
    total_tests: 0,
    is_complete: false,
  }
  assert_true(!report.is_complete)
}

///|
test "phase13_capabilities: 包含卷积层" {
  let caps = @cv_advanced.phase13_capabilities()
  let mut has_conv = false
  for c in caps {
    if c.name == "卷积层扩展" {
      has_conv = true
    }
  }
  assert_true(has_conv)
}
