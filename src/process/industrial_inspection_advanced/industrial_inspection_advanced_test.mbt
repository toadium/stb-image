///|
test "create_default_industrial_config: returns defect detection config" {
  let config = create_default_industrial_config()
  assert_eq(config.detection_threshold, 0.5)
  assert_eq(config.severity_threshold, 0.7)
  assert_eq(config.measurement_unit, "mm")
  assert_eq(config.tolerance_default, 0.1)
  assert_eq(config.anomaly_threshold, 0.5)
  assert_true(config.use_ai_detection)
  assert_true(config.use_hybrid)
  assert_false(config.use_traditional_vision)
  assert_true(config.reject_on_critical)
  assert_true(config.auto_calibration)
  assert_eq(config.defect_types.length(), 4)
  assert_true(config.task_type is IndustrialInspectionTaskType::DefectDetection)
}

///|
test "detect_defects: returns defect detections" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let defects = detect_defects(image, 200, 200, config)
  assert_eq(defects.length(), 5)
  for d in defects {
    assert_eq(d.bounding_box.length(), 4)
    assert_eq(d.position.length(), 2)
  }
}

///|
test "measure_dimensions: returns measurement results" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let measurements = measure_dimensions(image, 200, 200, 1.0, config)
  assert_eq(measurements.length(), 5)
  for m in measurements {
    assert_eq(m.unit, "mm")
    assert_eq(m.measurement_method, "vision")
  }
}

///|
test "evaluate_surface_quality: evaluates quality with defects" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 256).to_double())
  }
  let defects = detect_defects(image, 200, 200, config)
  let quality = evaluate_surface_quality(image, 200, 200, defects, config)
  assert_eq(quality.num_defects, 5)
}

///|
test "evaluate_surface_quality: no defects gives excellent grade" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push(128.0)
  }
  let quality = evaluate_surface_quality(image, 100, 100, [], config)
  assert_eq(quality.num_defects, 0)
  assert_eq(quality.critical_defects, 0)
  assert_true(quality.overall_score == 1.0)
  assert_true(quality.overall_grade is SurfaceQualityGrade::Excellent)
}

///|
test "detect_anomalies: detects difference from reference" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  let reference : Array[Double] = []
  for i in 0..<1000 {
    image.push(100.0)
    reference.push(100.0)
  }
  let result = detect_anomalies(image, reference, 100, 100, config)
  assert_false(result.is_anomaly)
  assert_true(result.anomaly_score == 0.0)
}

///|
test "detect_anomalies: detects anomaly" {
  let config = create_default_industrial_config()
  let image : Array[Double] = []
  let reference : Array[Double] = []
  for i in 0..<1000 {
    image.push(200.0)
    reference.push(100.0)
  }
  let result = detect_anomalies(image, reference, 100, 100, config)
  assert_true(result.is_anomaly)
  assert_true(result.anomaly_score > config.anomaly_threshold)
}

///|
test "industrial_inspection_report_to_string: contains task info" {
  let config = create_default_industrial_config()
  let report = industrial_inspection_report_to_string(
    IndustrialInspectionTaskType::SurfaceQualityInspection,
    config,
    "Grade: Good",
  )
  assert_true(report.contains("工业检测高级报告"))
  assert_true(report.contains("表面质量检测"))
  assert_true(report.contains("Grade: Good"))
  assert_true(report.contains("mm"))
}

///|
test "industrial_inspection_report_to_string: anomaly detection task" {
  let config = create_default_industrial_config()
  let report = industrial_inspection_report_to_string(
    IndustrialInspectionTaskType::AnomalyDetection,
    config,
    "Found 2 anomalies",
  )
  assert_true(report.contains("异常检测"))
  assert_true(report.contains("Found 2 anomalies"))
}
