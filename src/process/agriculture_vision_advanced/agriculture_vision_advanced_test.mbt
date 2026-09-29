///|
test "create_default_agriculture_config: returns disease detection config" {
  let config = create_default_agriculture_config()
  assert_eq(config.detection_threshold, 0.5)
  assert_eq(config.disease_severity_threshold, 0.3)
  assert_eq(config.pest_infestation_threshold, 0.2)
  assert_eq(config.soil_ph_optimal_min, 6.0)
  assert_eq(config.soil_ph_optimal_max, 7.5)
  assert_true(config.use_multispectral)
  assert_true(config.use_ndvi)
  assert_false(config.use_thermal)
  assert_true(config.auto_recommendation)
  assert_true(config.task_type is AgricultureVisionTaskType::DiseaseDetection)
  assert_true(config.crop_type is CropType::Wheat)
}

///|
test "detect_crops: returns crop detections" {
  let config = create_default_agriculture_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let crops = detect_crops(image, 500, 500, config)
  assert_eq(crops.length(), 10)
  assert_true(crops[0].confidence >= 0.7 && crops[0].confidence <= 1.0)
  assert_eq(crops[0].bounding_box.length(), 4)
  assert_true(crops[0].crop_type is CropType::Wheat)
}

///|
test "detect_diseases: returns disease detections" {
  let config = create_default_agriculture_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let diseases = detect_diseases(image, 500, 500, config)
  assert_eq(diseases.length(), 5)
  for d in diseases {
    assert_eq(d.bounding_box.length(), 4)
  }
}

///|
test "detect_pests: returns pest detections" {
  let config = create_default_agriculture_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let pests = detect_pests(image, 500, 500, config)
  assert_eq(pests.length(), 5)
  for p in pests {
    assert_eq(p.bounding_box.length(), 4)
  }
}

///|
test "predict_yield: wheat yield prediction" {
  let config = create_default_agriculture_config()
  let result = predict_yield(CropType::Wheat, 10.0, "flowering", 0.9, config)
  assert_true(result.crop_type is CropType::Wheat)
  assert_eq(result.yield_unit, "tons")
  assert_true(result.predicted_yield > 0.0)
  assert_eq(result.num_factors, 4)
  assert_eq(result.factors_analysis.length(), 4)
  assert_true((result.confidence - 0.75).abs() < 0.0000000001)
}

///|
test "predict_yield: corn yield prediction" {
  let config = create_default_agriculture_config()
  let result = predict_yield(CropType::Corn, 5.0, "vegetative", 1.0, config)
  assert_true(result.crop_type is CropType::Corn)
  assert_true(result.predicted_yield > 0.0)
}

///|
test "analyze_soil: returns soil analysis" {
  let config = create_default_agriculture_config()
  let soil_image : Array[Double] = []
  for i in 0..<1000 {
    soil_image.push((i % 100).to_double())
  }
  let result = analyze_soil(soil_image, config)
  assert_true(result.soil_type is SoilType::Loam)
  assert_eq(result.recommendation.length() > 0, true)
}

///|
test "agriculture_vision_report_to_string: contains task info" {
  let config = create_default_agriculture_config()
  let report = agriculture_vision_report_to_string(
    AgricultureVisionTaskType::YieldPrediction,
    config,
    "Predicted 50 tons",
  )
  assert_true(report.contains("农业视觉高级报告"))
  assert_true(report.contains("产量预测"))
  assert_true(report.contains("小麦"))
  assert_true(report.contains("Predicted 50 tons"))
}

///|
test "agriculture_vision_report_to_string: pest detection task" {
  let config = create_default_agriculture_config()
  let report = agriculture_vision_report_to_string(
    AgricultureVisionTaskType::PestDetection,
    config,
    "Found 3 pests",
  )
  assert_true(report.contains("虫害检测"))
  assert_true(report.contains("Found 3 pests"))
}
