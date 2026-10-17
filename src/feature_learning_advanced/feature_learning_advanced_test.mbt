// v46.0.0 特征学习高级测试

///|
test "create_default_feature_learning_config: 基本测试" {
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  assert_true(
    config.task_type
    is @feature_learning_advanced.FeatureLearningTaskType::FeatureExtraction,
  )
}

///|
test "extract_features_fl: 基本测试" {
  let images = make_test_data(4, 16)
  let widths = [4, 4, 4, 4]
  let heights = [4, 4, 4, 4]
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let result = @feature_learning_advanced.extract_features_fl(
    images, widths, heights, config,
  )
  assert_eq(result.num_samples, 4)
  assert_true(result.feature_dimension > 0)
}

///|
test "select_features_fl: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let result = @feature_learning_advanced.select_features_fl(data, 3, config)
  assert_eq(result.num_selected, 3)
  assert_true(result.selected_features.length() > 0)
}

///|
test "transform_features_fl: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let result = @feature_learning_advanced.transform_features_fl(data, config)
  assert_eq(result.num_samples, 4)
  assert_true(result.transformed_dimension > 0)
}

///|
test "fuse_features_fl: 基本测试" {
  let features1 = make_test_data(4, 8)
  let features2 = make_test_data(4, 6)
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let result = @feature_learning_advanced.fuse_features_fl(
    [features1, features2],
    config,
  )
  assert_eq(result.num_samples, 4)
  assert_true(result.fused_dimension > 0)
}

///|
test "learn_features: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let result = @feature_learning_advanced.learn_features(data, config)
  assert_eq(result.num_samples, 4)
  assert_true(result.learned_dimension > 0)
}

///|
test "feature_learning_report_to_string: 基本测试" {
  let config = @feature_learning_advanced.create_default_feature_learning_config()
  let report = @feature_learning_advanced.feature_learning_report_to_string(
    @feature_learning_advanced.FeatureLearningTaskType::FeatureExtraction,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_data(n : Int, d : Int) -> Array[Array[Double]] {
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
