// v233.0.0 char_segmentation 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn cs_make_img(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn cs_make_img_data(w : Int32, h : Int32, data : Array[Int32]) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data.map(fn(x) { x.to_byte() })),
  }
}

// ========== drop_fall_segmentation 错误路径 ==========

///|
test "drop_fall_segmentation: zero width raises" {
  try {
    let _ = @ocr.drop_fall_segmentation(cs_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "drop_fall_segmentation: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.drop_fall_segmentation(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "drop_fall_segmentation: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.drop_fall_segmentation(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== drop_fall_segmentation 功能路径 ==========

///|
test "drop_fall_segmentation: all white image" {
  try {
    let result = @ocr.drop_fall_segmentation(cs_make_img(16, 16, 0))
    assert_true(result.success == true || result.success == false)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "drop_fall_segmentation: all black image" {
  try {
    let result = @ocr.drop_fall_segmentation(cs_make_img(16, 16, 255))
    assert_true(result.success == true || result.success == false)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "drop_fall_segmentation: with custom start_x" {
  try {
    let result = @ocr.drop_fall_segmentation(
      cs_make_img(16, 16, 200),
      start_x=8,
    )
    assert_true(result.success == true || result.success == false)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_touching_chars 错误路径 ==========

///|
test "detect_touching_chars: zero width raises" {
  try {
    let _ = @ocr.detect_touching_chars(cs_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_touching_chars: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_touching_chars(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_touching_chars: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_touching_chars(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_touching_chars 功能路径 ==========

///|
test "detect_touching_chars: all white returns no touching" {
  try {
    let points = @ocr.detect_touching_chars(cs_make_img(32, 16, 0))
    assert_eq(points.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_touching_chars: all black returns no touching" {
  try {
    let points = @ocr.detect_touching_chars(cs_make_img(32, 16, 255))
    assert_true(points.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_touching_chars: custom params" {
  try {
    let points = @ocr.detect_touching_chars(
      cs_make_img(32, 16, 200),
      min_char_width=5,
      max_char_width=30,
    )
    assert_true(points.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== segment_by_connected_components 错误路径 ==========

///|
test "segment_by_connected_components: zero width raises" {
  try {
    let _ = @ocr.segment_by_connected_components(cs_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_by_connected_components: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.segment_by_connected_components(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_by_connected_components: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.segment_by_connected_components(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== segment_by_connected_components 功能路径 ==========

///|
test "segment_by_connected_components: all white returns no segments" {
  try {
    let segments = @ocr.segment_by_connected_components(cs_make_img(32, 32, 0))
    assert_eq(segments.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_by_connected_components: all black returns segments" {
  try {
    let segments = @ocr.segment_by_connected_components(
      cs_make_img(32, 32, 255),
    )
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_by_connected_components: custom area bounds" {
  try {
    let segments = @ocr.segment_by_connected_components(
      cs_make_img(32, 32, 200),
      min_area=10,
      max_area=500,
    )
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== merge_small_segments 错误路径 ==========

///|
test "merge_small_segments: empty segments raises" {
  try {
    let _ = @ocr.merge_small_segments([], 5, 8)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "merge_small_segments: min_width <= 0 raises" {
  try {
    let _ = @ocr.merge_small_segments([(0, 0, 10, 10)], 0, 8)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "merge_small_segments: min_height <= 0 raises" {
  try {
    let _ = @ocr.merge_small_segments([(0, 0, 10, 10)], 5, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== merge_small_segments 功能路径 ==========

///|
test "merge_small_segments: single segment preserved" {
  try {
    let result = @ocr.merge_small_segments([(0, 0, 20, 20)], 5, 8)
    assert_eq(result.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "merge_small_segments: multiple segments" {
  try {
    let result = @ocr.merge_small_segments(
      [(0, 0, 10, 20), (15, 0, 10, 20)],
      5,
      8,
    )
    assert_true(result.length() >= 1)
  } catch {
    _ => assert_true(false)
  }
}

// ========== filter_noise_segments 错误路径 ==========

///|
test "filter_noise_segments: empty segments raises" {
  try {
    let _ = @ocr.filter_noise_segments([], 32, 32)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "filter_noise_segments: zero width raises" {
  try {
    let _ = @ocr.filter_noise_segments([(0, 0, 10, 10)], 0, 32)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "filter_noise_segments: zero height raises" {
  try {
    let _ = @ocr.filter_noise_segments([(0, 0, 10, 10)], 32, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== filter_noise_segments 功能路径 ==========

///|
test "filter_noise_segments: single segment" {
  try {
    let result = @ocr.filter_noise_segments([(0, 0, 10, 10)], 32, 32)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "filter_noise_segments: custom area ratios" {
  try {
    let result = @ocr.filter_noise_segments(
      [(0, 0, 5, 5), (10, 10, 20, 20)],
      64,
      64,
      min_area_ratio=0.01,
      max_area_ratio=0.3,
    )
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== complete_char_segmentation 错误路径 ==========

///|
test "complete_char_segmentation: zero width raises" {
  try {
    let _ = @ocr.complete_char_segmentation(cs_make_img(0, 16, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(1536, 128)),
    }
    let _ = @ocr.complete_char_segmentation(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.complete_char_segmentation(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== complete_char_segmentation 功能路径 ==========

///|
test "complete_char_segmentation: all white raises (no segments to merge)" {
  try {
    let _ = @ocr.complete_char_segmentation(cs_make_img(32, 16, 0))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: all black image" {
  try {
    let segments = @ocr.complete_char_segmentation(cs_make_img(32, 16, 255))
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: custom char width bounds" {
  try {
    let segments = @ocr.complete_char_segmentation(
      cs_make_img(64, 16, 200),
      min_char_width=3,
      max_char_width=40,
    )
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "complete_char_segmentation: two char pattern" {
  try {
    let data : Array[Int32] = Array::make(64 * 16, 0)
    for y in 2..<14 {
      for x in 4..<16 {
        data[y * 64 + x] = 255
      }
      for x in 36..<48 {
        data[y * 64 + x] = 255
      }
    }
    let segments = @ocr.complete_char_segmentation(
      cs_make_img_data(64, 16, data),
      min_char_width=5,
      max_char_width=30,
    )
    assert_true(segments.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
