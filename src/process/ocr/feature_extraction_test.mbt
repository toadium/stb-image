// v187.0.0 feature_extraction.mbt 测试：HOG/LBP/投影/网格/统计/组合特征

///|
test "hog_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.hog_features(img)
    assert_true(result.features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "lbp_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.lbp_features(img)
    assert_true(result.features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "projection_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.projection_features(img)
    assert_true(result.horizontal.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "grid_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.grid_features(img)
    assert_true(result.features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "statistical_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.statistical_features(img)
    assert_true(result.mean >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "combined_features: 基本特征" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let features = @ocr.combined_features(img)
    assert_true(features.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}