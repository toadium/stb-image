// v46.0.0 图像降维测试

///|
test "create_default_dr_config: 基本测试" {
  let config = @image_dimensionality_reduction.create_default_dr_config()
  assert_true(
    config.task_type
    is @image_dimensionality_reduction.DimensionalityReductionTaskType::PCA,
  )
}

///|
test "pca_reduce: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @image_dimensionality_reduction.create_default_dr_config()
  let result = @image_dimensionality_reduction.pca_reduce(data, 2, config)
  assert_eq(result.num_samples, 4)
  assert_eq(result.num_components, 2)
}

///|
test "tsne_reduce: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @image_dimensionality_reduction.create_default_dr_config()
  let result = @image_dimensionality_reduction.tsne_reduce(data, 2, config)
  assert_eq(result.num_samples, 4)
  assert_eq(result.num_components, 2)
}

///|
test "umap_reduce: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @image_dimensionality_reduction.create_default_dr_config()
  let result = @image_dimensionality_reduction.umap_reduce(data, 2, config)
  assert_eq(result.num_samples, 4)
  assert_eq(result.num_components, 2)
}

///|
test "reduce_dimensionality: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @image_dimensionality_reduction.create_default_dr_config()
  let result = @image_dimensionality_reduction.reduce_dimensionality(
    data, config,
  )
  assert_eq(result.num_samples, 4)
  assert_true(result.reduced_dimension > 0)
}

///|
test "select_features: 基本测试" {
  let data = make_test_data(4, 8)
  let result = @image_dimensionality_reduction.select_features(data, 0.5)
  assert_true(result.num_selected >= 0)
  assert_eq(result.original_num_features, 8)
}

///|
test "dimensionality_reduction_report_to_string: 基本测试" {
  let config = @image_dimensionality_reduction.create_default_dr_config()
  let report = @image_dimensionality_reduction.dimensionality_reduction_report_to_string(
    @image_dimensionality_reduction.DimensionalityReductionTaskType::PCA,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_data(n : Int32, d : Int32) -> Array[Array[Double]] {
  let data : Array[Array[Double]] = []
  for i in 0..<n {
    let row : Array[Double] = []
    for j in 0..<d {
      row.push(((i * d + j) % 256).to_double())
    }
    data.push(row)
  }
  data
}
