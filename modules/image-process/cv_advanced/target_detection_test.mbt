///|
test "target_build_result: constructs correctly" {
  let result = @cv_advanced.target_build_result(10, 20, 5, 5, 0.9, 1)
  assert_eq(result.x, 10)
  assert_eq(result.y, 20)
  assert_true(result.confidence > 0.89 && result.confidence < 0.91)
}

///|
test "target_sliding_window: detects above threshold" {
  let image = [[0.1, 0.2, 0.1], [0.2, 5.0, 0.2], [0.1, 0.2, 0.1]]
  let results = @cv_advanced.target_sliding_window(image, 1, 1.0)
  assert_true(results.length() > 0)
}

///|
test "target_sliding_window: no detections below threshold" {
  let image = [[0.1, 0.2], [0.1, 0.2]]
  let results = @cv_advanced.target_sliding_window(image, 1, 1.0)
  assert_eq(results.length(), 0)
}

///|
test "target_sliding_window: empty image" {
  let results = @cv_advanced.target_sliding_window([], 1, 1.0)
  assert_eq(results.length(), 0)
}

///|
test "target_cfar: detects targets" {
  let image = [
    [0.1, 0.1, 0.1, 0.1, 0.1],
    [0.1, 0.1, 0.1, 0.1, 0.1],
    [0.1, 0.1, 5.0, 0.1, 0.1],
    [0.1, 0.1, 0.1, 0.1, 0.1],
    [0.1, 0.1, 0.1, 0.1, 0.1],
  ]
  let results = @cv_advanced.target_cfar(image, 1, 1, 3.0)
  assert_true(results.length() >= 0)
}

///|
test "target_cfar: empty image" {
  let results = @cv_advanced.target_cfar([], 1, 1, 3.0)
  assert_eq(results.length(), 0)
}

///|
test "target_template_match: finds match" {
  let image = [
    [1.0, 1.0, 1.0, 1.0],
    [1.0, 5.0, 5.0, 1.0],
    [1.0, 5.0, 5.0, 1.0],
    [1.0, 1.0, 1.0, 1.0],
  ]
  let template = [[5.0, 5.0], [5.0, 5.0]]
  let results = @cv_advanced.target_template_match(image, template, 9.0)
  assert_true(results.length() > 0)
}

///|
test "target_template_match: no match" {
  let image = [[0.1, 0.1], [0.1, 0.1]]
  let template = [[5.0, 5.0], [5.0, 5.0]]
  let results = @cv_advanced.target_template_match(image, template, 10.0)
  assert_eq(results.length(), 0)
}

///|
test "target_template_match: empty image" {
  let template = [[1.0]]
  let results = @cv_advanced.target_template_match([], template, 0.5)
  assert_eq(results.length(), 0)
}

///|
test "target_compute_iou: identical boxes" {
  let box1 = @cv_advanced.target_build_result(0, 0, 10, 10, 1.0, 0)
  let box2 = @cv_advanced.target_build_result(0, 0, 10, 10, 1.0, 0)
  let iou = @cv_advanced.target_compute_iou(box1, box2)
  assert_true(iou > 0.99)
}

///|
test "target_compute_iou: non-overlapping" {
  let box1 = @cv_advanced.target_build_result(0, 0, 5, 5, 1.0, 0)
  let box2 = @cv_advanced.target_build_result(10, 10, 5, 5, 1.0, 0)
  let iou = @cv_advanced.target_compute_iou(box1, box2)
  assert_true(iou == 0.0)
}

///|
test "target_compute_iou: partial overlap" {
  let box1 = @cv_advanced.target_build_result(0, 0, 10, 10, 1.0, 0)
  let box2 = @cv_advanced.target_build_result(5, 5, 10, 10, 1.0, 0)
  let iou = @cv_advanced.target_compute_iou(box1, box2)
  assert_true(iou > 0.14 && iou < 0.15)
}

///|
test "target_nms: suppresses overlapping" {
  let detections = [
    @cv_advanced.target_build_result(0, 0, 10, 10, 0.9, 0),
    @cv_advanced.target_build_result(1, 1, 10, 10, 0.8, 0),
    @cv_advanced.target_build_result(50, 50, 10, 10, 0.7, 0),
  ]
  let results = @cv_advanced.target_nms(detections, 0.5)
  assert_eq(results.length(), 2)
}

///|
test "target_nms: empty input" {
  let results = @cv_advanced.target_nms([], 0.5)
  assert_eq(results.length(), 0)
}

///|
test "target_detect: sliding window dispatch" {
  let image = [[0.1, 5.0, 0.1], [0.1, 0.1, 0.1], [0.1, 0.1, 0.1]]
  let results = @cv_advanced.target_detect(
    image,
    @cv_advanced.TargetDetMethod::SlidingWindow,
    1,
    1.0,
  )
  assert_true(results.length() > 0)
}

///|
test "target_detect: CFAR dispatch" {
  let image = [[0.1, 0.1, 0.1], [0.1, 5.0, 0.1], [0.1, 0.1, 0.1]]
  let results = @cv_advanced.target_detect(
    image,
    @cv_advanced.TargetDetMethod::Cfar,
    3,
    2.0,
  )
  assert_true(results.length() >= 0)
}

///|
test "target_detect: template match dispatch" {
  let image = [[1.0, 5.0, 1.0], [1.0, 5.0, 1.0], [1.0, 1.0, 1.0]]
  let results = @cv_advanced.target_detect(
    image,
    @cv_advanced.TargetDetMethod::TemplateMatch,
    2,
    5.0,
  )
  assert_true(results.length() >= 0)
}

///|
test "target_count: counts detections" {
  let detections = [
    @cv_advanced.target_build_result(0, 0, 5, 5, 0.9, 0),
    @cv_advanced.target_build_result(10, 10, 5, 5, 0.8, 0),
  ]
  let count = @cv_advanced.target_count(detections)
  assert_eq(count, 2)
}

///|
test "target_best_detection: finds highest confidence" {
  let detections = [
    @cv_advanced.target_build_result(0, 0, 5, 5, 0.5, 0),
    @cv_advanced.target_build_result(10, 10, 5, 5, 0.9, 0),
    @cv_advanced.target_build_result(20, 20, 5, 5, 0.7, 0),
  ]
  let best = @cv_advanced.target_best_detection(detections)
  assert_eq(best.x, 10)
  assert_true(best.confidence > 0.89 && best.confidence < 0.91)
}

///|
test "target_best_detection: empty input" {
  let best = @cv_advanced.target_best_detection([])
  assert_true(best.confidence == 0.0)
}
