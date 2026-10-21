// self_evolve 高层 API — 完整演化流程
// High-level API: full evolution pipeline

///|
/// 全部 19 种 IROp 的代表实例。
/// Representative instances of all 19 IROp variants.
pub fn all_ops() -> Array[@imgir.IROp] {
  [
    @imgir.Resize(8, 8),
    @imgir.Rotate90,
    @imgir.FlipH,
    @imgir.FlipV,
    @imgir.Crop(0, 0, 4, 4),
    @imgir.ToGray,
    @imgir.Brightness(50),
    @imgir.GaussianBlur(3, 1.0F),
    @imgir.BoxBlur(3),
    @imgir.Sharpen(1.0F),
    @imgir.ToScalarField,
    @imgir.FieldGradient,
    @imgir.FieldLaplacian,
    @imgir.FieldIntegrate,
    @imgir.FieldClamp(0.0F, 255.0F),
    @imgir.FieldMask(128.0F),
    @imgir.ScalarFieldToImage,
    @imgir.STSnapshot(0.5F),
    @imgir.STInterpolate(0.5F),
  ]
}

///|
/// 完整演化：生成测试 + 扫描退化。
/// Full evolution: generate tests + scan degradations.
pub fn evolve(ops : Array[@imgir.IROp]) -> EvolveReport {
  let tests = evolve_test_suite(ops)
  let degradations = scan_degradations(ops)
  let summary = "生成 " +
    tests.length().to_string() +
    " 个测试用例，发现 " +
    degradations.length().to_string() +
    " 个退化场景"
  { generated_tests: tests, found_degradations: degradations, summary, }
}

///|
/// 对全部 19 种算子执行演化。
/// Run evolution on all 19 op variants.
pub fn evolve_all() -> EvolveReport {
  evolve(all_ops())
}

///|
/// 仅生成测试用例报告。
/// Generate test-only report.
pub fn evolve_tests_only(ops : Array[@imgir.IROp]) -> EvolveReport {
  let tests = evolve_test_suite(ops)
  let summary = "生成 " + tests.length().to_string() + " 个测试用例"
  { generated_tests: tests, found_degradations: [], summary, }
}

///|
/// 仅扫描退化场景报告。
/// Generate degradation-only report.
pub fn evolve_degradation_scan(ops : Array[@imgir.IROp]) -> EvolveReport {
  let degradations = scan_degradations(ops)
  let summary = "发现 " +
    degradations.length().to_string() +
    " 个退化场景"
  { generated_tests: [], found_degradations: degradations, summary, }
}

///|
/// 按类别统计测试用例。
/// Count test cases by category.
pub fn count_by_category(
  tests : Array[TestCase],
) -> Array[(TestCategory, Int32)] {
  let categories = [Boundary, Normal, EdgeCase, Degradation]
  let result : Array[(TestCategory, Int32)] = []
  for cat in categories {
    let mut count = 0
    for t in tests {
      if t.category == cat {
        count = count + 1
      }
    }
    if count > 0 {
      result.push((cat, count))
    }
  }
  result
}
