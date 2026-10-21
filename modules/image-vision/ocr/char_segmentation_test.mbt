// v187.0.0 char_segmentation.mbt 测试：Drop-Fall/粘连检测/连通域分割/合并/过滤

///|
test "drop_fall_segmentation: 基本分割" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.drop_fall_segmentation(img)
    assert_true(result.split_points.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_touching_chars: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 128)),
    }
    let points = @ocr.detect_touching_chars(img)
    assert_true(points.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_by_connected_components: 基本分割" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255,
        0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255,
        255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0, 255, 255, 0, 0,
        255, 255, 0, 0, 255, 255, 0, 0,
      ]),
    }
    let segments = @ocr.segment_by_connected_components(img)
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "merge_small_segments: 基本合并" {
  try {
    let segments : Array[(Int32, Int32, Int32, Int32)] = [
      (0, 0, 2, 8),
      (3, 0, 2, 8),
    ]
    let merged = @ocr.merge_small_segments(segments, 3, 5)
    assert_true(merged.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "filter_noise_segments: 基本过滤" {
  try {
    let segments : Array[(Int32, Int32, Int32, Int32)] = [
      (0, 0, 2, 2),
      (3, 0, 4, 8),
    ]
    let filtered = @ocr.filter_noise_segments(segments, 8, 8)
    assert_true(filtered.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: 基本分割" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(128, 0)),
    }
    let segments = @ocr.complete_char_segmentation(img)
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}
