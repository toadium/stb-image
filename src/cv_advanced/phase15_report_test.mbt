///|
test "phase15_build_capability: constructs correctly" {
  let cap = @cv_advanced.phase15_build_capability(
    "v361", "多光谱分析", "波段运算", 2, 6, 12,
  )
  assert_eq(cap.num_types, 2)
  assert_eq(cap.num_functions, 6)
  assert_eq(cap.num_tests, 12)
}

///|
test "phase15_capabilities: returns 14 capabilities" {
  let caps = @cv_advanced.phase15_capabilities()
  assert_eq(caps.length(), 14)
}

///|
test "phase15_capabilities: first is v361" {
  let caps = @cv_advanced.phase15_capabilities()
  assert_eq(caps[0].version, "v361")
  assert_eq(caps[0].name, "多光谱分析")
}

///|
test "phase15_capabilities: last is v374" {
  let caps = @cv_advanced.phase15_capabilities()
  assert_eq(caps[13].version, "v374")
  assert_eq(caps[13].name, "时间序列")
}

///|
test "phase15_total_types: computes total" {
  let total = @cv_advanced.phase15_total_types()
  assert_true(total > 20)
}

///|
test "phase15_total_functions: computes total" {
  let total = @cv_advanced.phase15_total_functions()
  assert_true(total > 100)
}

///|
test "phase15_total_tests: computes total" {
  let total = @cv_advanced.phase15_total_tests()
  assert_true(total > 200)
}

///|
test "phase15_report: generates complete report" {
  let report = @cv_advanced.phase15_report()
  assert_eq(report.total_versions, 14)
  assert_true(report.is_complete)
  assert_true(report.total_types > 20)
  assert_true(report.total_functions > 100)
  assert_true(report.total_tests > 200)
}

///|
test "phase15_is_complete: returns true" {
  let complete = @cv_advanced.phase15_is_complete()
  assert_true(complete)
}
