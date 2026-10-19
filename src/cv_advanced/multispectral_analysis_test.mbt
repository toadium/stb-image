// 多光谱分析测试
// Multispectral analysis tests

///|
test "multispectral_band_arithmetic: 加法" {
  let b1 = [1.0, 2.0, 3.0, 4.0]
  let b2 = [5.0, 6.0, 7.0, 8.0]
  let result = @cv_advanced.multispectral_band_arithmetic(b1, b2, 0)
  assert_eq(result.length(), 4)
  assert_eq(result[0], 6.0)
  assert_eq(result[3], 12.0)
}

///|
test "multispectral_band_arithmetic: 减法" {
  let b1 = [5.0, 6.0, 7.0, 8.0]
  let b2 = [1.0, 2.0, 3.0, 4.0]
  let result = @cv_advanced.multispectral_band_arithmetic(b1, b2, 1)
  assert_eq(result[0], 4.0)
}

///|
test "multispectral_band_arithmetic: 乘法" {
  let b1 = [2.0, 3.0]
  let b2 = [4.0, 5.0]
  let result = @cv_advanced.multispectral_band_arithmetic(b1, b2, 2)
  assert_eq(result[0], 8.0)
  assert_eq(result[1], 15.0)
}

///|
test "multispectral_band_arithmetic: 除法" {
  let b1 = [10.0, 20.0]
  let b2 = [2.0, 4.0]
  let result = @cv_advanced.multispectral_band_arithmetic(b1, b2, 3)
  assert_eq(result[0], 5.0)
  assert_eq(result[1], 5.0)
}

///|
test "multispectral_normalized_difference: 基本" {
  let b1 = [5.0, 10.0]
  let b2 = [3.0, 2.0]
  let result = @cv_advanced.multispectral_normalized_difference(b1, b2)
  assert_eq(result.length(), 2)
  assert_true(result[0] > 0.0)
  assert_true(result[1] > 0.0)
}

///|
test "multispectral_band_ratio: 基本比值" {
  let num = [10.0, 20.0]
  let den = [2.0, 4.0]
  let result = @cv_advanced.multispectral_band_ratio(num, den)
  assert_eq(result[0], 5.0)
  assert_eq(result[1], 5.0)
}

///|
test "multispectral_band_stats: 基本统计" {
  let band = [1.0, 2.0, 3.0, 4.0, 5.0]
  let (mean, std, min_val, max_val) = @cv_advanced.multispectral_band_stats(
    band,
  )
  assert_eq(mean, 3.0)
  assert_eq(min_val, 1.0)
  assert_eq(max_val, 5.0)
  assert_true(std > 0.0)
}

///|
test "multispectral_classify: 基本分类" {
  let bands : Array[Array[Double]] = []
  bands.push([0.1, 0.5, 0.9])
  bands.push([0.2, 0.6, 0.8])
  let image = @cv_advanced.MultispecImage::{
    bands,
    width: 3,
    height: 1,
    num_bands: 2,
  }
  let labels = @cv_advanced.multispectral_classify(image, 2, 5)
  assert_eq(labels.length(), 3)
  for i in 0..<3 {
    assert_true(labels[i] >= 0 && labels[i] < 2)
  }
}

///|
test "multispectral_pca: 基本降维" {
  let bands : Array[Array[Double]] = []
  bands.push([1.0, 2.0, 3.0])
  bands.push([4.0, 5.0, 6.0])
  let image = @cv_advanced.MultispecImage::{
    bands,
    width: 3,
    height: 1,
    num_bands: 2,
  }
  let components = @cv_advanced.multispectral_pca(image, 1)
  assert_eq(components.length(), 1)
  assert_eq(components[0].length(), 3)
}
