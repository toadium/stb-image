// Phase 14 综合报告测试
// Phase 14 report tests

///|
test "phase14_capabilities: 全部能力" {
  let caps = @cv_advanced.phase14_capabilities()
  assert_eq(caps.length(), 14)
  assert_eq(caps[0].version, "v346")
  assert_eq(caps[13].version, "v359")
}

///|
test "phase14_total_types: 类型计数" {
  let total = @cv_advanced.phase14_total_types()
  assert_true(total >= 40)
}

///|
test "phase14_total_functions: 函数计数" {
  let total = @cv_advanced.phase14_total_functions()
  assert_true(total >= 80)
}

///|
test "phase14_total_tests: 测试计数" {
  let total = @cv_advanced.phase14_total_tests()
  assert_true(total >= 120)
}

///|
test "phase14_report: 综合报告" {
  let report = @cv_advanced.phase14_report()
  assert_eq(report.total_versions, 15)
  assert_eq(report.is_complete, true)
  assert_true(report.total_types >= 40)
  assert_true(report.total_functions >= 80)
  assert_true(report.total_tests >= 120)
}

///|
test "phase14_is_complete: 完成检查" {
  let complete = @cv_advanced.phase14_is_complete()
  assert_eq(complete, true)
}
