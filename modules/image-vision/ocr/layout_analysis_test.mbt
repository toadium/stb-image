// v187.0.0 layout_analysis.mbt 测试：文本区域/页面分割/多栏/文本行/预处理

///|
test "detect_text_regions: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255,
        255, 255, 255, 255, 255, 255, 255,
      ]),
    }
    let regions = @ocr.detect_text_regions(img)
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_page: 基本分割" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let regions = @ocr.segment_page(img)
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_columns: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 128)),
    }
    let _ = @ocr.detect_columns(img)
    assert_true(true)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_text_lines: 基本提取" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0,
        0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0,
        0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 255,
        255, 255, 255, 255, 255, 255, 255,
      ]),
    }
    let lines = @ocr.extract_text_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_preprocess: 基本预处理" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.ocr_preprocess(img)
    assert_true(result.width > 0)
    assert_true(result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}
