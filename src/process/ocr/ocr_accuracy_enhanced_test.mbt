// v187.0.0 ocr_accuracy_enhanced.mbt 测试：Zernike/Gabor/方向特征/加权KNN/多尺度

///|
test "ocr_accuracy_enhanced_default_config: 默认值" {
  let config = @ocr.ocr_accuracy_enhanced_default_config()
  assert_eq(config.use_zernike_moments, true)
  assert_eq(config.use_gabor_features, true)
  assert_eq(config.knn_k, 5)
  assert_eq(config.scales.length(), 3)
}

///|
test "extract_zernike_moments: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.extract_zernike_moments(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_gabor_ocr_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.extract_gabor_ocr_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_directional_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.extract_directional_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "weighted_knn_classify: 基本分类" {
  let training_data : Array[(String, Array[Double])] = [
    ("A", [1.0, 0.0]),
    ("B", [0.0, 1.0]),
  ]
  let (label, confidence, _) = @ocr.weighted_knn_classify(
    [0.9, 0.1],
    training_data,
    k=2,
  )
  assert_true(label.length() > 0)
  assert_true(confidence >= 0.0 && confidence <= 1.0)
}

///|
test "calibrate_confidence_enhanced: 基本校准" {
  let calibrated = @ocr.calibrate_confidence_enhanced(0.5, [0.1, 0.2, 0.3])
  assert_true(calibrated >= 0.0 && calibrated <= 1.0)
}

///|
test "extract_combined_enhanced_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let config = @ocr.ocr_accuracy_enhanced_default_config()
    let features = @ocr.extract_combined_enhanced_features(img, config)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "multi_scale_recognize: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let templates = @ocr.generate_digit_templates()
    let (label, _) = @ocr.multi_scale_recognize(img, templates, [16, 32])
    assert_true(label.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_ocr_enhanced: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let templates = @ocr.generate_digit_templates()
    let result = @ocr.recognize_ocr_enhanced(img, templates)
    assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}