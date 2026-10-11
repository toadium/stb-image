// v231.0.0 projection_analysis 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn proj_make_img(w : Int, h : Int, data : Array[Int]) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data.map(fn(x) { x.to_byte() })),
  }
}

///|
fn proj_uniform(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn proj_make_text_line(
  y_start : Int,
  y_end : Int,
  x_start : Int,
  x_end : Int,
) -> @ocr.TextLineInfo {
  @ocr.TextLineInfo::{
    y_start,
    y_end,
    height: y_end - y_start + 1,
    x_start,
    x_end,
    width: x_end - x_start + 1,
    pixel_count: (y_end - y_start + 1) * (x_end - x_start + 1),
    baseline: y_end - 1,
  }
}

///|
fn proj_make_char_segment(
  x_start : Int,
  x_end : Int,
  y_start : Int,
  y_end : Int,
) -> @ocr.CharSegment {
  @ocr.CharSegment::{
    x_start,
    x_end,
    width: x_end - x_start + 1,
    y_start,
    y_end,
    height: y_end - y_start + 1,
    pixel_count: (x_end - x_start + 1) * (y_end - y_start + 1),
  }
}

// ========== horizontal_projection 错误路径 ==========

///|
test "horizontal_projection: zero width raises" {
  try {
    let _ = @ocr.horizontal_projection(proj_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "horizontal_projection: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let _ = @ocr.horizontal_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "horizontal_projection: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let _ = @ocr.horizontal_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== horizontal_projection 功能路径 ==========

///|
test "horizontal_projection: all white returns zero projection" {
  try {
    let result = @ocr.horizontal_projection(proj_uniform(8, 8, 0))
    assert_eq(result.projection.length(), 8)
    for v in result.projection {
      assert_eq(v, 0)
    }
    assert_true(result.mean == 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "horizontal_projection: all black returns full projection" {
  try {
    let result = @ocr.horizontal_projection(proj_uniform(8, 8, 255))
    assert_eq(result.projection.length(), 8)
    for v in result.projection {
      assert_eq(v, 8)
    }
  } catch {
    _ => assert_true(false)
  }
}

///|
test "horizontal_projection: alternating rows produce peaks and valleys" {
  try {
    let data : Array[Int] = []
    for y in 0..<8 {
      for _ in 0..<8 {
        if y % 2 == 0 {
          data.push(255)
        } else {
          data.push(0)
        }
      }
    }
    let result = @ocr.horizontal_projection(proj_make_img(8, 8, data))
    assert_eq(result.projection.length(), 8)
    for i in 0..<8 {
      if i % 2 == 0 {
        assert_eq(result.projection[i], 8)
      } else {
        assert_eq(result.projection[i], 0)
      }
    }
  } catch {
    _ => assert_true(false)
  }
}

// ========== vertical_projection 错误路径 ==========

///|
test "vertical_projection: zero width raises" {
  try {
    let _ = @ocr.vertical_projection(proj_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "vertical_projection: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let _ = @ocr.vertical_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "vertical_projection: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let _ = @ocr.vertical_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "vertical_projection: all black returns full projection" {
  try {
    let result = @ocr.vertical_projection(proj_uniform(8, 8, 255))
    assert_eq(result.projection.length(), 8)
    for v in result.projection {
      assert_eq(v, 8)
    }
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_text_lines_projection 错误路径 ==========

///|
test "detect_text_lines_projection: zero width raises" {
  try {
    let _ = @ocr.detect_text_lines_projection(proj_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let _ = @ocr.detect_text_lines_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let _ = @ocr.detect_text_lines_projection(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: min_height <= 0 raises" {
  try {
    let _ = @ocr.detect_text_lines_projection(
      proj_uniform(8, 8, 128),
      min_height=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: max_gap < 0 raises" {
  try {
    let _ = @ocr.detect_text_lines_projection(
      proj_uniform(8, 8, 128),
      max_gap=-1,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_text_lines_projection 功能路径 ==========

///|
test "detect_text_lines_projection: all white returns no lines" {
  try {
    let lines = @ocr.detect_text_lines_projection(proj_uniform(16, 16, 0))
    assert_eq(lines.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: single text row detected" {
  try {
    let data : Array[Int] = Array::make(16 * 16, 0)
    for x in 0..<16 {
      data[5 * 16 + x] = 255
      data[6 * 16 + x] = 255
      data[7 * 16 + x] = 255
    }
    let lines = @ocr.detect_text_lines_projection(
      proj_make_img(16, 16, data),
      min_height=2,
    )
    assert_true(lines.length() >= 1)
    if lines.length() > 0 {
      assert_true(lines[0].y_start <= 5)
      assert_true(lines[0].y_end >= 7)
    }
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: two text rows with gap" {
  try {
    let data : Array[Int] = Array::make(20 * 20, 0)
    for x in 0..<20 {
      for y in [2, 3, 4, 5] {
        data[y * 20 + x] = 255
      }
      for y in [12, 13, 14, 15] {
        data[y * 20 + x] = 255
      }
    }
    let lines = @ocr.detect_text_lines_projection(
      proj_make_img(20, 20, data),
      min_height=2,
      max_gap=3,
    )
    assert_true(lines.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== segment_chars_projection 错误路径 ==========

///|
test "segment_chars_projection: zero width raises" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.segment_chars_projection(proj_uniform(0, 8, 128), line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 3,
      data: Bytes::from_array(Array::make(192, 128)),
    }
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.segment_chars_projection(img, line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.segment_chars_projection(img, line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: line width <= 0 raises" {
  try {
    let line = @ocr.TextLineInfo::{
      y_start: 0,
      y_end: 7,
      height: 8,
      x_start: 0,
      x_end: 0,
      width: 0,
      pixel_count: 0,
      baseline: 6,
    }
    let _ = @ocr.segment_chars_projection(proj_uniform(8, 8, 128), line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: min_width <= 0 raises" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.segment_chars_projection(
      proj_uniform(8, 8, 128),
      line,
      min_width=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: max_gap < 0 raises" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.segment_chars_projection(
      proj_uniform(8, 8, 128),
      line,
      max_gap=-1,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== segment_chars_projection 功能路径 ==========

///|
test "segment_chars_projection: all white returns no chars" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let chars = @ocr.segment_chars_projection(proj_uniform(8, 8, 0), line)
    assert_eq(chars.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: two chars with gap" {
  try {
    let data : Array[Int] = Array::make(16 * 8, 0)
    for y in 0..<8 {
      for x in 1..<5 {
        data[y * 16 + x] = 255
      }
      for x in 10..<14 {
        data[y * 16 + x] = 255
      }
    }
    let line = proj_make_text_line(0, 7, 0, 15)
    let chars = @ocr.segment_chars_projection(
      proj_make_img(16, 8, data),
      line,
      min_width=2,
      max_gap=2,
    )
    assert_true(chars.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_text_line_image 错误路径 ==========

///|
test "extract_text_line_image: zero width raises" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.extract_text_line_image(proj_uniform(0, 8, 128), line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.extract_text_line_image(img, line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.extract_text_line_image(img, line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: line width <= 0 raises" {
  try {
    let line = @ocr.TextLineInfo::{
      y_start: 0,
      y_end: 7,
      height: 8,
      x_start: 0,
      x_end: 0,
      width: 0,
      pixel_count: 0,
      baseline: 6,
    }
    let _ = @ocr.extract_text_line_image(proj_uniform(8, 8, 128), line)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: padding < 0 raises" {
  try {
    let line = proj_make_text_line(0, 7, 0, 7)
    let _ = @ocr.extract_text_line_image(
      proj_uniform(8, 8, 128),
      line,
      padding=-1,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_text_line_image 功能路径 ==========

///|
test "extract_text_line_image: correct output dimensions" {
  try {
    let line = proj_make_text_line(2, 5, 2, 5)
    let result = @ocr.extract_text_line_image(
      proj_uniform(10, 10, 200),
      line,
      padding=1,
    )
    assert_true(result.width > 0)
    assert_true(result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: RGB image supported" {
  try {
    let img = @types.Image::{
      width: 10,
      height: 10,
      channels: 3,
      data: Bytes::from_array(Array::make(300, 200)),
    }
    let line = proj_make_text_line(2, 5, 2, 5)
    let result = @ocr.extract_text_line_image(img, line, padding=1)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_char_image 错误路径 ==========

///|
test "extract_char_image: zero width raises" {
  try {
    let char = proj_make_char_segment(0, 3, 0, 7)
    let _ = @ocr.extract_char_image(proj_uniform(0, 8, 128), char)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: channels 0 raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let char = proj_make_char_segment(0, 3, 0, 7)
    let _ = @ocr.extract_char_image(img, char)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(60, 128)),
    }
    let char = proj_make_char_segment(0, 3, 0, 7)
    let _ = @ocr.extract_char_image(img, char)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: char width <= 0 raises" {
  try {
    let char = @ocr.CharSegment::{
      x_start: 0,
      x_end: 0,
      width: 0,
      y_start: 0,
      y_end: 7,
      height: 8,
      pixel_count: 0,
    }
    let _ = @ocr.extract_char_image(proj_uniform(8, 8, 128), char)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: target_size <= 0 raises" {
  try {
    let char = proj_make_char_segment(0, 3, 0, 7)
    let _ = @ocr.extract_char_image(
      proj_uniform(8, 8, 128),
      char,
      target_size=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: padding < 0 raises" {
  try {
    let char = proj_make_char_segment(0, 3, 0, 7)
    let _ = @ocr.extract_char_image(proj_uniform(8, 8, 128), char, padding=-1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_char_image 功能路径 ==========

///|
test "extract_char_image: returns target_size x target_size" {
  try {
    let char = proj_make_char_segment(1, 4, 1, 6)
    let result = @ocr.extract_char_image(
      proj_uniform(10, 10, 255),
      char,
      target_size=32,
    )
    assert_eq(result.width, 32)
    assert_eq(result.height, 32)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: custom target_size" {
  try {
    let char = proj_make_char_segment(1, 4, 1, 6)
    let result = @ocr.extract_char_image(
      proj_uniform(10, 10, 255),
      char,
      target_size=48,
    )
    assert_eq(result.width, 48)
    assert_eq(result.height, 48)
  } catch {
    _ => assert_true(false)
  }
}
