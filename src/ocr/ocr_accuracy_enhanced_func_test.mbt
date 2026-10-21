// v231.0.0 ocr_accuracy_enhanced 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn oae_make_img(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn oae_make_config(
  zernike : Bool,
  gabor : Bool,
  directional : Bool,
  knn : Bool,
  calib : Bool,
  multi_scale : Bool,
) -> @ocr.OcrAccuracyEnhancedConfig {
  @ocr.OcrAccuracyEnhancedConfig::{
    use_zernike_moments: zernike,
    use_gabor_features: gabor,
    use_directional_features: directional,
    use_weighted_knn: knn,
    use_confidence_calibration: calib,
    use_multi_scale: multi_scale,
    knn_k: 3,
    scales: [16, 32],
  }
}

// ========== extract_zernike_moments 错误路径 ==========

///|
test "extract_zernike_moments: zero width raises" {
  try {
    let _ = @ocr.extract_zernike_moments(oae_make_img(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_zernike_moments: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let _ = @ocr.extract_zernike_moments(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_zernike_moments: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let _ = @ocr.extract_zernike_moments(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_zernike_moments: max_order <= 0 raises" {
  try {
    let _ = @ocr.extract_zernike_moments(oae_make_img(8, 8, 128), max_order=0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_zernike_moments 功能路径 ==========

///|
test "extract_zernike_moments: all white returns features" {
  try {
    let features = @ocr.extract_zernike_moments(oae_make_img(8, 8, 0))
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_zernike_moments: custom max_order" {
  try {
    let features = @ocr.extract_zernike_moments(
      oae_make_img(8, 8, 255),
      max_order=2,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_zernike_moments: larger image" {
  try {
    let features = @ocr.extract_zernike_moments(
      oae_make_img(16, 16, 200),
      max_order=6,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_gabor_ocr_features 功能路径 ==========

///|
test "extract_gabor_ocr_features: all white returns zeros" {
  let features = @ocr.extract_gabor_ocr_features(oae_make_img(8, 8, 0))
  assert_true(features.length() > 0)
  for f in features {
    assert_true(f == 0.0)
  }
}

///|
test "extract_gabor_ocr_features: custom orientations" {
  let features = @ocr.extract_gabor_ocr_features(
    oae_make_img(16, 16, 255),
    num_orientations=8,
  )
  assert_true(features.length() > 0)
}

///|
test "extract_gabor_ocr_features: custom frequencies" {
  let features = @ocr.extract_gabor_ocr_features(
    oae_make_img(16, 16, 255),
    num_frequencies=3,
  )
  assert_true(features.length() > 0)
}

///|
test "extract_gabor_ocr_features: small image no crash" {
  let features = @ocr.extract_gabor_ocr_features(oae_make_img(4, 4, 255))
  assert_true(features.length() > 0)
}

// ========== extract_directional_features 功能路径 ==========

///|
test "extract_directional_features: all white returns zeros" {
  let features = @ocr.extract_directional_features(oae_make_img(8, 8, 0))
  assert_eq(features.length(), 8)
  for f in features {
    assert_true(f == 0.0)
  }
}

///|
test "extract_directional_features: returns 8 features" {
  let features = @ocr.extract_directional_features(oae_make_img(16, 16, 255))
  assert_eq(features.length(), 8)
}

///|
test "extract_directional_features: small image no crash" {
  let features = @ocr.extract_directional_features(oae_make_img(4, 4, 255))
  assert_eq(features.length(), 8)
}

// ========== weighted_knn_classify 功能路径 ==========

///|
test "weighted_knn_classify: exact match" {
  let training : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0]),
    ("B", [0.0, 1.0]),
  ]
  let (label, conf, votes) = @ocr.weighted_knn_classify(
    [1.0, 0.0],
    training,
    k=1,
  )
  assert_eq(label, "A")
  assert_true(conf > 0.5)
  assert_eq(votes.length(), 1)
}

///|
test "weighted_knn_classify: manhattan distance" {
  let training : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0]),
    ("B", [0.0, 1.0]),
  ]
  let (label, _, _) = @ocr.weighted_knn_classify(
    [0.8, 0.2],
    training,
    k=2,
    distance_metric="manhattan",
  )
  assert_eq(label, "A")
}

///|
test "weighted_knn_classify: cosine distance" {
  let training : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0, 0.0]),
    ("B", [0.0, 1.0, 0.0]),
  ]
  let (label, _, _) = @ocr.weighted_knn_classify(
    [0.9, 0.1, 0.0],
    training,
    k=2,
    distance_metric="cosine",
  )
  assert_eq(label, "A")
}

///|
test "weighted_knn_classify: k larger than training set" {
  let training : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0]),
    ("B", [0.0, 1.0]),
  ]
  let (label, _, _) = @ocr.weighted_knn_classify([0.9, 0.1], training, k=10)
  assert_eq(label, "A")
}

///|
test "weighted_knn_classify: empty training returns unknown" {
  let training : Array[(String, Array[Double])] = []
  let (label, conf, _) = @ocr.weighted_knn_classify([1.0, 0.0], training, k=3)
  assert_eq(label, "?")
  assert_true(conf == 0.0)
}

///|
test "weighted_knn_classify: same label multiple samples" {
  let training : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0]),
    ("A", [0.9, 0.1]),
    ("B", [0.0, 1.0]),
  ]
  let (label, _, votes) = @ocr.weighted_knn_classify(
    [0.95, 0.05],
    training,
    k=3,
  )
  assert_eq(label, "A")
  assert_true(votes.length() <= 2)
}

// ========== calibrate_confidence_enhanced 功能路径 ==========

///|
test "calibrate_confidence_enhanced: empty distribution returns raw" {
  let result = @ocr.calibrate_confidence_enhanced(0.7, [])
  assert_true((result - 0.7).abs() < 0.001)
}

///|
test "calibrate_confidence_enhanced: high confidence boosted" {
  let result = @ocr.calibrate_confidence_enhanced(0.5, [0.1, 0.15, 0.12])
  assert_true(result >= 0.5)
}

///|
test "calibrate_confidence_enhanced: calibrated capped at 1.0" {
  let result = @ocr.calibrate_confidence_enhanced(0.95, [0.01, 0.02])
  assert_true(result <= 1.0)
}

///|
test "calibrate_confidence_enhanced: zero confidence stays zero" {
  let result = @ocr.calibrate_confidence_enhanced(0.0, [0.1, 0.2])
  assert_true(result == 0.0)
}

///|
test "calibrate_confidence_enhanced: uniform distances" {
  let result = @ocr.calibrate_confidence_enhanced(0.5, [0.3, 0.3, 0.3])
  assert_true(result >= 0.0 && result <= 1.0)
}

// ========== extract_combined_enhanced_features 错误路径 ==========

///|
test "extract_combined_enhanced_features: zero width raises" {
  try {
    let config = @ocr.ocr_accuracy_enhanced_default_config()
    let _ = @ocr.extract_combined_enhanced_features(
      oae_make_img(0, 8, 128),
      config,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let config = @ocr.ocr_accuracy_enhanced_default_config()
    let _ = @ocr.extract_combined_enhanced_features(img, config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let config = @ocr.ocr_accuracy_enhanced_default_config()
    let _ = @ocr.extract_combined_enhanced_features(img, config)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_combined_enhanced_features 功能路径 ==========

///|
test "extract_combined_enhanced_features: all features enabled" {
  try {
    let config = oae_make_config(true, true, true, true, true, false)
    let features = @ocr.extract_combined_enhanced_features(
      oae_make_img(16, 16, 255),
      config,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: only grid features" {
  try {
    let config = oae_make_config(false, false, false, false, false, false)
    let features = @ocr.extract_combined_enhanced_features(
      oae_make_img(16, 16, 255),
      config,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: zernike only" {
  try {
    let config = oae_make_config(true, false, false, false, false, false)
    let features = @ocr.extract_combined_enhanced_features(
      oae_make_img(16, 16, 255),
      config,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: gabor only" {
  try {
    let config = oae_make_config(false, true, false, false, false, false)
    let features = @ocr.extract_combined_enhanced_features(
      oae_make_img(16, 16, 255),
      config,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_combined_enhanced_features: directional only" {
  try {
    let config = oae_make_config(false, false, true, false, false, false)
    let features = @ocr.extract_combined_enhanced_features(
      oae_make_img(16, 16, 255),
      config,
    )
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== multi_scale_recognize 功能路径 ==========

///|
test "multi_scale_recognize: basic recognition" {
  try {
    let templates = @ocr.generate_digit_templates()
    let (label, conf) = @ocr.multi_scale_recognize(
      oae_make_img(16, 16, 200),
      templates,
      [16, 32],
    )
    assert_true(label.length() >= 0)
    assert_true(conf >= 0.0 && conf <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "multi_scale_recognize: manhattan distance" {
  try {
    let templates = @ocr.generate_digit_templates()
    let (label, _) = @ocr.multi_scale_recognize(
      oae_make_img(16, 16, 200),
      templates,
      [24],
      distance_metric="manhattan",
    )
    assert_true(label.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "multi_scale_recognize: cosine distance" {
  try {
    let templates = @ocr.generate_digit_templates()
    let (label, _) = @ocr.multi_scale_recognize(
      oae_make_img(16, 16, 200),
      templates,
      [16, 24, 32],
      distance_metric="cosine",
    )
    assert_true(label.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "multi_scale_recognize: empty templates returns unknown" {
  let (label, _) = @ocr.multi_scale_recognize(oae_make_img(16, 16, 200), [], [
    16,
  ])
  assert_eq(label, "?")
}

// ========== recognize_ocr_enhanced 错误路径 ==========

///|
test "recognize_ocr_enhanced: zero width raises" {
  try {
    let templates = @ocr.generate_digit_templates()
    let _ = @ocr.recognize_ocr_enhanced(oae_make_img(0, 8, 128), templates)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let templates = @ocr.generate_digit_templates()
    let _ = @ocr.recognize_ocr_enhanced(img, templates)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 5,
      data: Bytes::from_array(Array::make(1280, 128)),
    }
    let templates = @ocr.generate_digit_templates()
    let _ = @ocr.recognize_ocr_enhanced(img, templates)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let templates = @ocr.generate_digit_templates()
    let _ = @ocr.recognize_ocr_enhanced(img, templates)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: empty templates raises" {
  try {
    let templates : Array[(String, Array[Double])] = []
    let _ = @ocr.recognize_ocr_enhanced(oae_make_img(16, 16, 128), templates)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_ocr_enhanced 功能路径 ==========

///|
test "recognize_ocr_enhanced: with custom config (multi_scale)" {
  try {
    let templates = @ocr.generate_digit_templates()
    let config = oae_make_config(true, true, true, true, true, true)
    let result = @ocr.recognize_ocr_enhanced(
      oae_make_img(16, 16, 200),
      templates,
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: with custom config (no knn)" {
  try {
    let templates = @ocr.generate_digit_templates()
    let config = oae_make_config(true, true, true, false, false, false)
    let result = @ocr.recognize_ocr_enhanced(
      oae_make_img(16, 16, 200),
      templates,
      config~,
    )
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: RGB image with text-like pattern" {
  try {
    let data : Array[Int32] = Array::make(32 * 32 * 3, 255)
    for y in 5..<27 {
      for x in 5..<12 {
        data[(y * 32 + x) * 3] = 0
        data[(y * 32 + x) * 3 + 1] = 0
        data[(y * 32 + x) * 3 + 2] = 0
      }
      for x in 20..<27 {
        data[(y * 32 + x) * 3] = 0
        data[(y * 32 + x) * 3 + 1] = 0
        data[(y * 32 + x) * 3 + 2] = 0
      }
    }
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 3,
      data: Bytes::from_array(data.map(fn(x) { x.to_byte() })),
    }
    let templates = @ocr.generate_digit_templates()
    let result = @ocr.recognize_ocr_enhanced(img, templates)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: all white image" {
  try {
    let templates = @ocr.generate_digit_templates()
    let result = @ocr.recognize_ocr_enhanced(
      oae_make_img(32, 32, 255),
      templates,
    )
    assert_true(result.confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== ocr_accuracy_enhanced_default_config 功能路径 ==========

///|
test "ocr_accuracy_enhanced_default_config: all fields verified" {
  let config = @ocr.ocr_accuracy_enhanced_default_config()
  assert_eq(config.use_zernike_moments, true)
  assert_eq(config.use_gabor_features, true)
  assert_eq(config.use_directional_features, true)
  assert_eq(config.use_weighted_knn, true)
  assert_eq(config.use_confidence_calibration, true)
  assert_eq(config.use_multi_scale, false)
  assert_eq(config.knn_k, 5)
  assert_eq(config.scales.length(), 3)
  assert_eq(config.scales[0], 24)
  assert_eq(config.scales[1], 32)
  assert_eq(config.scales[2], 48)
}
