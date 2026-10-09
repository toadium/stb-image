// v187.0.0 accuracy_testing.mbt 测试：准确率计算/编辑距离/统计/报告/阈值检查

///|
test "calculate_char_accuracy: 完全匹配" {
  let acc = @ocr.calculate_char_accuracy("hello", "hello")
  assert_true((acc - 1.0).abs() < 0.01)
}

///|
test "calculate_char_accuracy: 部分匹配" {
  let acc = @ocr.calculate_char_accuracy("hello", "hallo")
  assert_true((acc - 0.8).abs() < 0.01)
}

///|
test "calculate_char_accuracy: 空字符串" {
  let acc = @ocr.calculate_char_accuracy("", "")
  assert_true((acc - 1.0).abs() < 0.01)
}

///|
test "calculate_word_accuracy: 完全匹配" {
  let acc = @ocr.calculate_word_accuracy("hello world", "hello world")
  assert_true((acc - 1.0).abs() < 0.01)
}

///|
test "calculate_word_accuracy: 部分匹配" {
  let acc = @ocr.calculate_word_accuracy("hello world", "hallo world")
  assert_true((acc - 0.5).abs() < 0.01)
}

///|
test "calculate_edit_distance: 相同字符串" {
  let dist = @ocr.calculate_edit_distance("abc", "abc")
  assert_eq(dist, 0)
}

///|
test "calculate_edit_distance: 替换" {
  let dist = @ocr.calculate_edit_distance("cat", "bat")
  assert_eq(dist, 1)
}

///|
test "calculate_edit_distance: 插入" {
  let dist = @ocr.calculate_edit_distance("cat", "cats")
  assert_eq(dist, 1)
}

///|
test "calculate_edit_distance: 空字符串" {
  let dist = @ocr.calculate_edit_distance("", "abc")
  assert_eq(dist, 3)
}

///|
test "calculate_accuracy_stats: 基本统计" {
  try {
    let stats = @ocr.calculate_accuracy_stats(["hello world", "foo bar"], [
      "hello world", "foo bar",
    ])
    assert_true((stats.char_accuracy - 1.0).abs() < 0.01)
    assert_eq(stats.correct_lines, 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "calculate_accuracy_stats: 空列表抛异常" {
  try {
    let _ = @ocr.calculate_accuracy_stats([], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "generate_accuracy_report: 基本报告" {
  try {
    let stats = @ocr.calculate_accuracy_stats(["hello"], ["hello"])
    let report = @ocr.generate_accuracy_report(stats, "test_dataset")
    assert_true(report.length() > 0)
    assert_true(report.contains("OCR"))
  } catch {
    _ => assert_true(false)
  }
}

///|
test "generate_performance_report: 基本报告" {
  let benchmark = @ocr.PerformanceBenchmark::{
    total_time_ms: 100.0,
    preprocess_time_ms: 20.0,
    layout_time_ms: 10.0,
    recognition_time_ms: 50.0,
    postprocess_time_ms: 20.0,
    pages_per_second: 10.0,
    chars_per_second: 1000.0,
    memory_usage_mb: 50.0,
    cpu_usage_percent: 80.0,
  }
  let report = @ocr.generate_performance_report(benchmark, "bench")
  assert_true(report.length() > 0)
  assert_true(report.contains("OCR"))
}

///|
test "check_accuracy_threshold: 达标" {
  try {
    let stats = @ocr.calculate_accuracy_stats(["hello"], ["hello"])
    let (passed, issues) = @ocr.check_accuracy_threshold(stats)
    assert_true(passed)
    assert_eq(issues.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "check_accuracy_threshold: 未达标" {
  try {
    let stats = @ocr.calculate_accuracy_stats(["hello world"], ["hallo wor1d"])
    let (passed, _) = @ocr.check_accuracy_threshold(
      stats,
      min_char_accuracy=0.99,
    )
    assert_true(!passed)
  } catch {
    _ => assert_true(false)
  }
}