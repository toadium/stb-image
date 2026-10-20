// 高光谱分析测试
// Hyperspectral analysis tests

///|
test "hyperspectral_sam: 相同光谱" {
  let s = [1.0, 2.0, 3.0, 4.0]
  let angle = @cv_advanced.hyperspectral_sam(s, s)
  assert_true(angle < 0.001)
}

///|
test "hyperspectral_sam: 不同光谱" {
  let s1 = [1.0, 0.0, 0.0]
  let s2 = [0.0, 1.0, 0.0]
  let angle = @cv_advanced.hyperspectral_sam(s1, s2)
  assert_true(angle > 1.0)
}

///|
test "hyperspectral_euclidean: 相同光谱" {
  let s = [1.0, 2.0, 3.0]
  let dist = @cv_advanced.hyperspectral_euclidean(s, s)
  assert_eq(dist, 0.0)
}

///|
test "hyperspectral_euclidean: 不同光谱" {
  let s1 = [1.0, 2.0, 3.0]
  let s2 = [4.0, 5.0, 6.0]
  let dist = @cv_advanced.hyperspectral_euclidean(s1, s2)
  assert_true(dist > 0.0)
}

///|
test "hyperspectral_correlation: 完全相关" {
  let s = [1.0, 2.0, 3.0, 4.0]
  let corr = @cv_advanced.hyperspectral_correlation(s, s)
  assert_true(corr > 0.99)
}

///|
test "hyperspectral_correlation: 反相关" {
  let s1 = [1.0, 2.0, 3.0, 4.0]
  let s2 = [4.0, 3.0, 2.0, 1.0]
  let corr = @cv_advanced.hyperspectral_correlation(s1, s2)
  assert_true(corr < 0.0)
}

///|
test "hyperspectral_ppi: 基本计算" {
  let data : Array[Array[Double]] = []
  data.push([0.1, 0.5, 0.9])
  data.push([0.9, 0.5, 0.1])
  data.push([0.5, 0.5, 0.5])
  let scores = @cv_advanced.hyperspectral_ppi(data, 3, 10)
  assert_eq(scores.length(), 3)
  for i in 0..<3 {
    assert_true(scores[i] >= 0)
  }
}

///|
test "hyperspectral_extract_endmembers: 提取端元" {
  let data : Array[Array[Double]] = []
  data.push([0.1, 0.2, 0.3])
  data.push([0.9, 0.8, 0.7])
  data.push([0.5, 0.5, 0.5])
  data.push([0.2, 0.3, 0.4])
  let endmembers = @cv_advanced.hyperspectral_extract_endmembers(data, 3, 2, 20)
  assert_true(endmembers.length() <= 2)
}

///|
test "hyperspectral_abundance_inversion: 基本反演" {
  let pixel = [0.5, 0.5, 0.5]
  let endmembers : Array[Array[Double]] = []
  endmembers.push([1.0, 0.0, 0.0])
  endmembers.push([0.0, 1.0, 0.0])
  endmembers.push([0.0, 0.0, 1.0])
  let abundances = @cv_advanced.hyperspectral_abundance_inversion(
    pixel, endmembers,
  )
  assert_eq(abundances.length(), 3)
  let mut sum = 0.0
  for a in abundances {
    sum = sum + a
  }
  assert_true(sum > 0.99 && sum < 1.01)
}

///|
test "hyperspectral_match: 光谱匹配" {
  let pixel = [0.9, 0.1, 0.0]
  let refs : Array[Array[Double]] = []
  refs.push([1.0, 0.0, 0.0])
  refs.push([0.0, 1.0, 0.0])
  refs.push([0.0, 0.0, 1.0])
  let idx = @cv_advanced.hyperspectral_match(
    pixel,
    refs,
    @cv_advanced.SpectralMatchMethod::SpectralAngleMapper,
  )
  assert_eq(idx, 0)
}

///|
test "hyperspectral_build_endmember_result: 完整结果" {
  let data : Array[Array[Double]] = []
  data.push([0.1, 0.2, 0.3])
  data.push([0.9, 0.8, 0.7])
  data.push([0.5, 0.5, 0.5])
  let result = @cv_advanced.hyperspectral_build_endmember_result(data, 3, 2, 20)
  assert_true(result.num_endmembers <= 2)
  assert_eq(result.abundance_maps.length(), result.num_endmembers)
}
