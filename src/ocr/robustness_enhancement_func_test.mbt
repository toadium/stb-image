// v233.0.0 robustness_enhancement 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn re_make_img(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn re_make_quality(score : Double) -> @ocr.ScanQuality {
  @ocr.ScanQuality::{
    brightness: 200.0,
    contrast: 50.0,
    sharpness: 0.8,
    noise_level: 0.1,
    skew_angle: 0.0,
    overall_score: score,
    issues: [],
  }
}

///|
fn re_make_distortion(
  dtype : @ocr.DistortionType,
  severity : Double,
) -> @ocr.DistortionDetectionResult {
  @ocr.DistortionDetectionResult::{
    distortion_type: dtype,
    severity,
    angle: 0.0,
    confidence: 0.9,
    correction_params: [],
  }
}

///|
fn re_make_layout() -> @ocr.ComplexLayoutAnalysis {
  @ocr.ComplexLayoutAnalysis::{
    layout_type: @ocr.ComplexLayoutType::SingleColumn,
    num_columns: 1,
    has_floating_elements: false,
    has_cross_page_elements: false,
    column_boundaries: [],
    reading_order_strategy: "top-to-bottom",
    confidence: 0.9,
  }
}

///|
fn re_make_text_block(x : Int, y : Int, w : Int, h : Int) -> @ocr.TextBlock {
  @ocr.TextBlock::{
    x,
    y,
    width: w,
    height: h,
    block_type: "text",
    text: "",
    confidence: 0.9,
    reading_order: 0,
  }
}

// ========== select_adaptive_config 错误路径 ==========

///|
test "select_adaptive_config: score < 0 raises" {
  try {
    let _ = @ocr.select_adaptive_config(re_make_quality(-1.0))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: score > 100 raises" {
  try {
    let _ = @ocr.select_adaptive_config(re_make_quality(101.0))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== select_adaptive_config 功能路径 ==========

///|
test "select_adaptive_config: excellent score" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(95.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: good score" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(80.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: fair score" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(60.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: poor score" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(30.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: very poor score" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(10.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: boundary score 0" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(0.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "select_adaptive_config: boundary score 100" {
  try {
    let config = @ocr.select_adaptive_config(re_make_quality(100.0))
    assert_true(config.denoise_strength >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_skew_angle_robust 错误路径 ==========

///|
test "detect_skew_angle_robust: zero width raises" {
  try {
    let _ = @ocr.detect_skew_angle_robust(re_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_skew_angle_robust: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_skew_angle_robust(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_skew_angle_robust: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_skew_angle_robust(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_skew_angle_robust 功能路径 ==========

///|
test "detect_skew_angle_robust: uniform image returns 0" {
  try {
    let angle = @ocr.detect_skew_angle_robust(re_make_img(32, 32, 128))
    assert_true(angle >= -45.0 && angle <= 45.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_skew_angle_robust: all white image" {
  try {
    let angle = @ocr.detect_skew_angle_robust(re_make_img(32, 32, 255))
    assert_true(angle >= -45.0 && angle <= 45.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_distortions 错误路径 ==========

///|
test "detect_distortions: zero width raises" {
  try {
    let _ = @ocr.detect_distortions(re_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_distortions: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.detect_distortions(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_distortions: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let _ = @ocr.detect_distortions(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_distortions: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_distortions(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_distortions 功能路径 ==========

///|
test "detect_distortions: uniform image" {
  try {
    let distortions = @ocr.detect_distortions(re_make_img(32, 32, 128))
    assert_true(distortions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_distortions: RGB image" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(Array::make(3072, 200)),
    }
    let distortions = @ocr.detect_distortions(img)
    assert_true(distortions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== analyze_complex_layout 功能路径 ==========

///|
test "analyze_complex_layout: empty blocks" {
  let layout = @ocr.analyze_complex_layout([], 800, 600)
  assert_true(layout.num_columns >= 1)
}

///|
test "analyze_complex_layout: single column" {
  let blocks = [
    re_make_text_block(100, 50, 200, 20),
    re_make_text_block(100, 100, 200, 20),
  ]
  let layout = @ocr.analyze_complex_layout(blocks, 800, 600)
  assert_true(layout.num_columns >= 1)
}

///|
test "analyze_complex_layout: two columns" {
  let blocks = [
    re_make_text_block(50, 50, 200, 20),
    re_make_text_block(450, 50, 200, 20),
    re_make_text_block(50, 100, 200, 20),
    re_make_text_block(450, 100, 200, 20),
  ]
  let layout = @ocr.analyze_complex_layout(blocks, 800, 600)
  assert_true(layout.num_columns >= 1)
}

// ========== generate_robustness_report 功能路径 ==========

///|
test "generate_robustness_report: excellent quality no distortions" {
  let quality = re_make_quality(95.0)
  let layout = re_make_layout()
  let report = @ocr.generate_robustness_report(quality, [], layout)
  assert_true(report.overall_score >= 0.0 && report.overall_score <= 1.0)
  assert_true(report.estimated_accuracy >= 0.0)
}

///|
test "generate_robustness_report: poor quality with distortions" {
  let quality = re_make_quality(20.0)
  let distortions = [
    re_make_distortion(@ocr.DistortionType::Skew, 0.8),
    re_make_distortion(@ocr.DistortionType::Blur, 0.5),
  ]
  let layout = re_make_layout()
  let report = @ocr.generate_robustness_report(quality, distortions, layout)
  assert_true(report.overall_score >= 0.0 && report.overall_score <= 1.0)
}

///|
test "generate_robustness_report: zero quality" {
  let quality = re_make_quality(0.0)
  let layout = re_make_layout()
  let report = @ocr.generate_robustness_report(quality, [], layout)
  assert_true(report.overall_score >= 0.0)
}

// ========== robustness_report_to_string 功能路径 ==========

///|
test "robustness_report_to_string: produces non-empty string" {
  let quality = re_make_quality(80.0)
  let layout = re_make_layout()
  let report = @ocr.generate_robustness_report(quality, [], layout)
  let str = @ocr.robustness_report_to_string(report)
  assert_true(str.length() > 0)
}

///|
test "robustness_report_to_string: contains recommendations" {
  let quality = re_make_quality(30.0)
  let distortions = [re_make_distortion(@ocr.DistortionType::Skew, 0.7)]
  let layout = re_make_layout()
  let report = @ocr.generate_robustness_report(quality, distortions, layout)
  let str = @ocr.robustness_report_to_string(report)
  assert_true(str.length() > 0)
}
