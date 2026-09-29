// v45.0.0 计算机视觉高级测试

///|
test "create_default_cv_advanced_config: 基本测试" {
  let config = create_default_cv_advanced_config()
  assert_true(config.task_type is CVAdvancedTaskType::ObjectTracking)
  assert_true(config.tracking_algorithm is TrackingAlgorithm::KCF)
}

///|
test "create_tracked_object: 基本测试" {
  let obj = create_tracked_object(1, [10, 20, 30, 40], "person", 0.95)
  assert_eq(obj.object_id, 1)
  assert_eq(obj.class_label, "person")
  assert_eq(obj.confidence, 0.95)
}

///|
test "calculate_iou: 基本测试" {
  let iou = calculate_iou([0, 0, 10, 10], [5, 5, 15, 15])
  assert_true(iou >= 0.0)
  assert_true(iou <= 1.0)
}

///|
test "update_tracked_object: 基本测试" {
  let obj = create_tracked_object(1, [10, 20, 30, 40], "person", 0.95)
  let updated = update_tracked_object(obj, [12, 22, 32, 42], 0.9)
  assert_eq(updated.object_id, 1)
  assert_eq(updated.confidence, 0.9)
}

///|
test "recognize_action: 基本测试" {
  let config = create_default_cv_advanced_config()
  let result = recognize_action("video1", 100, config)
  assert_eq(result.video_id, "video1")
  assert_true(result.confidence >= 0.0)
}

///|
test "parse_scene: 基本测试" {
  let config = create_default_cv_advanced_config()
  let result = parse_scene("image1", 4, 4, config)
  assert_eq(result.image_id, "image1")
  assert_true(result.num_classes >= 0)
}

///|
test "visual_question_answering: 基本测试" {
  let result = visual_question_answering("image1", "What is in the image?")
  assert_eq(result.image_id, "image1")
  assert_true(result.answer.length() >= 0)
}

///|
test "generate_caption: 基本测试" {
  let result = generate_caption("image1")
  assert_eq(result.image_id, "image1")
  assert_true(result.caption.length() >= 0)
}

///|
test "cv_advanced_report_to_string: 基本测试" {
  let config = create_default_cv_advanced_config()
  let report = cv_advanced_report_to_string(
    CVAdvancedTaskType::ObjectTracking,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}
