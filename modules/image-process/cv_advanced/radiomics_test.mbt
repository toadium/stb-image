// 影像组学测试
// Radiomics tests

///|
test "radiomics_first_order: 基本统计" {
  let image = [1.0, 2.0, 3.0, 4.0, 5.0]
  let mask = [1, 1, 1, 1, 1]
  let features = @cv_advanced.radiomics_first_order(image, mask)
  assert_true(features.length() >= 7)
  assert_eq(features[0].name, "mean")
  assert_true(features[0].value > 2.9 && features[0].value < 3.1)
}

///|
test "radiomics_first_order: 空掩码" {
  let image = [1.0, 2.0, 3.0]
  let mask = [0, 0, 0]
  let features = @cv_advanced.radiomics_first_order(image, mask)
  assert_eq(features.length(), 0)
}

///|
test "radiomics_shape_features: 基本形状" {
  let mask = [0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0]
  let features = @cv_advanced.radiomics_shape_features(mask, 4, 4)
  assert_true(features.length() >= 3)
  assert_eq(features[0].name, "volume")
  assert_eq(features[0].value, 4.0)
}

///|
test "radiomics_glcm_features: 基本纹理" {
  let image = [0.0, 0.5, 1.0, 0.0, 0.5, 1.0, 0.0, 0.5, 1.0]
  let features = @cv_advanced.radiomics_glcm_features(image, 3, 3, 4)
  assert_true(features.length() >= 4)
}

///|
test "radiomics_glcm_features: 常值图像" {
  let image = [0.5, 0.5, 0.5, 0.5]
  let features = @cv_advanced.radiomics_glcm_features(image, 2, 2, 4)
  assert_eq(features.length(), 0)
}

///|
test "radiomics_select_features: 方差选择" {
  let features : Array[Array[Double]] = []
  features.push([1.0, 5.0, 3.0])
  features.push([1.0, 5.0, 3.0])
  features.push([1.0, 5.0, 3.0])
  let result = @cv_advanced.radiomics_select_features(features, 0.1)
  assert_eq(result.num_selected, 0)
}

///|
test "radiomics_select_features: 有变异" {
  let features : Array[Array[Double]] = []
  features.push([1.0, 5.0])
  features.push([2.0, 5.0])
  features.push([3.0, 5.0])
  let result = @cv_advanced.radiomics_select_features(features, 0.1)
  assert_true(result.num_selected >= 1)
}

///|
test "radiomics_compute_icc: 基本计算" {
  let features : Array[Array[Double]] = []
  features.push([1.0, 2.0])
  features.push([2.0, 3.0])
  features.push([3.0, 4.0])
  let icc = @cv_advanced.radiomics_compute_icc(features, 0)
  assert_true(icc >= 0.0 && icc <= 1.0)
}

///|
test "radiomics_compute_icc: 单样本" {
  let features : Array[Array[Double]] = []
  features.push([1.0, 2.0])
  let icc = @cv_advanced.radiomics_compute_icc(features, 0)
  assert_eq(icc, 0.0)
}
