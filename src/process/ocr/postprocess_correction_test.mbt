// v187.0.0 postprocess_correction.mbt 测试：语言模型/相似字符纠错/常见模式/批量纠错/报告

///|
test "create_default_language_model: 基本创建" {
  let model = @ocr.create_default_language_model()
  assert_true(model.common_errors.length() > 0)
  assert_true(model.similar_chars.length() > 0)
}

///|
test "correct_similar_chars: 数字上下文" {
  try {
    let result = @ocr.correct_similar_chars("OIlS", "number")
    assert_true(result.is_corrected)
    assert_eq(result.corrected, "0115")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "correct_similar_chars: 英文上下文无纠错" {
  try {
    let result = @ocr.correct_similar_chars("hello", "english")
    assert_true(!result.is_corrected)
    assert_eq(result.corrected, "hello")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "correct_similar_chars: 无效上下文抛异常" {
  try {
    let _ = @ocr.correct_similar_chars("test", "invalid")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "correct_common_patterns: 基本纠错" {
  let result = @ocr.correct_common_patterns("hello")
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
}

///|
test "full_postprocess_correction: 数字纠错" {
  try {
    let result = @ocr.full_postprocess_correction("OIlS", context_type="number")
    assert_true(result.is_corrected)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "full_postprocess_correction: 无效上下文抛异常" {
  try {
    let _ = @ocr.full_postprocess_correction("test", context_type="invalid")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "batch_correct_texts: 基本批量" {
  try {
    let results = @ocr.batch_correct_texts(["OIl", "hello"], context_type="number")
    assert_eq(results.length(), 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "batch_correct_texts: 空列表抛异常" {
  try {
    let _ = @ocr.batch_correct_texts([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "generate_correction_report: 基本报告" {
  let results = [
    @ocr.CorrectionResult::{
      original: "OIl",
      corrected: "011",
      is_corrected: true,
      confidence: 0.85,
      corrections: [],
    },
  ]
  let report = @ocr.generate_correction_report(results)
  assert_true(report.contains("OCR"))
  assert_true(report.contains("纠错"))
}

///|
test "calculate_accuracy_improvement: 基本计算" {
  let results = [
    @ocr.CorrectionResult::{
      original: "helo",
      corrected: "hello",
      is_corrected: true,
      confidence: 0.9,
      corrections: [],
    },
  ]
  let (before, after, improvement) = @ocr.calculate_accuracy_improvement(
    results,
    ["hello"],
  )
  assert_true(before >= 0.0 && before <= 1.0)
  assert_true(after >= 0.0 && after <= 1.0)
  assert_true(improvement >= -1.0 && improvement <= 1.0)
}