// v187.0.0 robustness_enhancement.mbt 测试：自适应配置/倾斜/畸变/复杂版面/报告

///|
test "select_adaptive_config: 基本选择" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let quality = @ocr.evaluate_scan_quality(img)
    let config = @ocr.select_adaptive_config(quality)
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_skew_angle_robust: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let angle = @ocr.detect_skew_angle_robust(img)
    assert_true(angle >= -45.0 && angle <= 45.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_distortions: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let distortions = @ocr.detect_distortions(img)
    assert_true(distortions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_complex_layout: 基本分析" {
  let blocks : Array[@ocr.TextBlock] = []
  let result = @ocr.analyze_complex_layout(blocks, 100, 100)
  assert_true(result.num_columns >= 0)
}

///|
test "generate_robustness_report: 基本报告" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let quality = @ocr.evaluate_scan_quality(img)
    let distortions = @ocr.detect_distortions(img)
    let blocks : Array[@ocr.TextBlock] = []
    let layout = @ocr.analyze_complex_layout(blocks, 16, 16)
    let report = @ocr.generate_robustness_report(quality, distortions, layout)
    assert_true(report.overall_score >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "robustness_report_to_string: 基本输出" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let quality = @ocr.evaluate_scan_quality(img)
    let distortions = @ocr.detect_distortions(img)
    let blocks : Array[@ocr.TextBlock] = []
    let layout = @ocr.analyze_complex_layout(blocks, 16, 16)
    let report = @ocr.generate_robustness_report(quality, distortions, layout)
    let str = @ocr.robustness_report_to_string(report)
    assert_true(str.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}
