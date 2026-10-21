// v46.0.0 可解释AI测试

///|
test "create_default_explainable_ai_config: 基本测试" {
  let config = @explainable_ai.create_default_explainable_ai_config()
  assert_true(
    config.method_type is @explainable_ai.ExplainabilityMethod::GradCAM,
  )
}

///|
test "compute_feature_importance: 基本测试" {
  let img = make_test_image(32, 32)
  let config = @explainable_ai.create_default_explainable_ai_config()
  let result = @explainable_ai.compute_feature_importance(img, config)
  assert_true(result.num_features > 0)
  assert_true(result.importance_scores.length() > 0)
}

///|
test "generate_saliency_map: 基本测试" {
  let img = make_test_image(32, 32)
  let config = @explainable_ai.create_default_explainable_ai_config()
  let result = @explainable_ai.generate_saliency_map(img, config)
  assert_eq(result.saliency_map.width, 32)
  assert_eq(result.saliency_map.height, 32)
}

///|
test "generate_confusion_matrix: 基本测试" {
  let predictions = [0, 1, 0, 1, 0]
  let ground_truth = [0, 1, 1, 1, 0]
  let result = @explainable_ai.generate_confusion_matrix(
    predictions,
    ground_truth,
    2,
    ["class0", "class1"],
  )
  assert_eq(result.num_classes, 2)
  assert_true(result.accuracy >= 0.0)
}

///|
test "generate_roc_curve: 基本测试" {
  let scores = [0.9, 0.8, 0.7, 0.6, 0.5]
  let labels = [1, 1, 0, 1, 0]
  let result = @explainable_ai.generate_roc_curve(scores, labels, 10)
  assert_true(result.num_points > 0)
}

///|
test "visualize_feature_maps: 基本测试" {
  let img = make_test_image(4, 4)
  let result = @explainable_ai.visualize_feature_maps(img, 3, "conv1")
  assert_eq(result.num_maps, 3)
  assert_eq(result.layer_name, "conv1")
}

///|
test "explainable_ai_report_to_string: 基本测试" {
  let img = make_test_image(32, 32)
  let config = @explainable_ai.create_default_explainable_ai_config()
  let importance = @explainable_ai.compute_feature_importance(img, config)
  let saliency = @explainable_ai.generate_saliency_map(img, config)
  let metrics = @explainable_ai.ModelPerformanceMetrics::{
    accuracy: 0.9,
    precision: 0.85,
    recall: 0.88,
    f1_score: 0.86,
    auc_roc: 0.92,
    auc_pr: 0.90,
    loss: 0.3,
    inference_time_ms: 10.0,
    memory_mb: 100.0,
    model_size_mb: 50.0,
    num_parameters: 1000000,
    flops: 5000000,
  }
  let report = @explainable_ai.explainable_ai_report_to_string(
    importance, saliency, metrics,
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_image(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int32 = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}
