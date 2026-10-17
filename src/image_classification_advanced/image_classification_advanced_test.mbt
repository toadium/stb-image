// v35.0.0 图像分类高级测试 — image_classification_advanced 模块 6 函数

///|
test "create_default_classification_config: 默认分类配置" {
  let config = @image_classification_advanced.create_default_classification_config()
  assert_true(config.num_classes > 0)
  assert_true(config.num_epochs > 0)
  assert_true(config.batch_size > 0)
  assert_true(config.learning_rate > 0.0)
  assert_true(config.num_classifiers > 0)
  assert_true(config.use_transfer_learning)
  assert_true(config.use_data_augmentation)
  assert_true(!config.use_ensemble)
  assert_true(
    config.classifier_type == @image_classification_advanced.ClassifierType::CNN,
  )
  assert_true(
    config.feature_extraction_method ==
    @image_classification_advanced.FeatureExtractionMethod::DeepFeature,
  )
}

///|
test "classify_image: 基本分类" {
  let config = @image_classification_advanced.create_default_classification_config()
  let image = [100.0, 150.0, 200.0, 50.0, 80.0, 120.0, 180.0, 30.0]
  let result = @image_classification_advanced.classify_image(
    image, 4, 2, config,
  )
  assert_true(result.num_classes == config.num_classes)
  assert_true(result.predicted_class >= 0)
  assert_true(result.predicted_class < config.num_classes)
  assert_true(result.confidence > 0.0)
  assert_true(result.class_probabilities.length() == config.num_classes)
  assert_true(result.top_k_predictions.length() > 0)
  assert_true(result.top_k_confidences.length() > 0)
  assert_true(result.classification_time_ms > 0.0)
}

///|
test "classify_image: 空图像" {
  let config = @image_classification_advanced.create_default_classification_config()
  let result = @image_classification_advanced.classify_image([], 0, 0, config)
  assert_true(result.num_classes == config.num_classes)
  assert_true(result.predicted_class >= 0)
}

///|
test "classify_multi_label: 多标签分类" {
  let config = @image_classification_advanced.create_default_classification_config()
  let image = [100.0, 150.0, 200.0, 50.0, 80.0]
  let result = @image_classification_advanced.classify_multi_label(
    image, 5, 1, 3, 0.1, config,
  )
  assert_true(result.num_labels == 3)
  assert_true(result.label_probabilities.length() == 3)
  assert_true(result.threshold == 0.1)
  assert_true(result.confidence_scores.length() == 3)
  assert_true(result.hamming_loss >= 0.0)
  assert_true(result.subset_accuracy >= 0.0)
}

///|
test "classify_ensemble: 集成分类" {
  let config = @image_classification_advanced.create_default_classification_config()
  let image = [100.0, 150.0, 200.0, 50.0, 80.0, 120.0]
  let result = @image_classification_advanced.classify_ensemble(
    image, 3, 2, config,
  )
  assert_true(result.num_classifiers == config.num_classifiers)
  assert_true(result.individual_predictions.length() == config.num_classifiers)
  assert_true(result.individual_confidences.length() == config.num_classifiers)
  assert_true(result.final_prediction >= 0)
  assert_true(result.final_confidence >= 0.0)
  assert_true(result.diversity_score >= 0.0)
  assert_true(result.ensemble_method == config.ensemble_method)
}

///|
test "train_classifier: 训练分类器" {
  let config = @image_classification_advanced.create_default_classification_config()
  let images = [
    [100.0, 150.0, 200.0],
    [50.0, 80.0, 120.0],
    [180.0, 30.0, 90.0],
    [200.0, 100.0, 50.0],
  ]
  let labels = [0, 1, 2, 0]
  let result = @image_classification_advanced.train_classifier(
    images, labels, config,
  )
  assert_true(result.num_epochs == config.num_epochs)
  assert_true(result.final_accuracy >= 0.0 && result.final_accuracy <= 1.0)
  assert_true(result.training_accuracy >= 0.0)
  assert_true(result.validation_accuracy >= 0.0)
  assert_true(result.test_accuracy >= 0.0)
  assert_true(result.precision >= 0.0 && result.precision <= 1.0)
  assert_true(result.recall >= 0.0 && result.recall <= 1.0)
  assert_true(result.f1_score >= 0.0 && result.f1_score <= 1.0)
  assert_true(result.confusion_matrix.length() == config.num_classes)
  assert_true(result.training_time_ms > 0.0)
  assert_true(result.model_size_bytes > 0)
  assert_true(result.num_parameters > 0)
  assert_true(result.classifier_type == config.classifier_type)
}

///|
test "train_classifier: 空训练集" {
  let config = @image_classification_advanced.create_default_classification_config()
  let result = @image_classification_advanced.train_classifier([], [], config)
  assert_true(result.final_accuracy == 0.0)
  assert_true(result.training_accuracy == 0.0)
}

///|
test "image_classification_report_to_string: 报告生成" {
  let config = @image_classification_advanced.create_default_classification_config()
  let report = @image_classification_advanced.image_classification_report_to_string(
    @image_classification_advanced.ImageClassificationTaskType::MultiClassClassification,
    config,
    "分类完成",
  )
  assert_true(report.contains("图像分类高级报告"))
  assert_true(report.contains("任务信息"))
  assert_true(report.contains("多分类"))
  assert_true(report.contains("分类完成"))
}

///|
test "image_classification_report_to_string: 二分类报告" {
  let config = @image_classification_advanced.create_default_classification_config()
  let report = @image_classification_advanced.image_classification_report_to_string(
    @image_classification_advanced.ImageClassificationTaskType::BinaryClassification,
    config,
    "二分类结果",
  )
  assert_true(report.contains("二分类"))
  assert_true(report.contains("二分类结果"))
}
