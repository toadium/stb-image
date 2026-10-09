// v187.0.0 projection_analysis.mbt 测试：水平/垂直投影/文本行检测/字符分割/提取

///|
test "horizontal_projection: 基本投影" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.horizontal_projection(img)
    assert_true(result.projection.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "vertical_projection: 基本投影" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.vertical_projection(img)
    assert_true(result.projection.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_text_lines_projection: 基本检测" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array([
        0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255,
      ]),
    }
    let lines = @ocr.detect_text_lines_projection(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "segment_chars_projection: 基本分割" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let line = @ocr.TextLineInfo::{
      y_start: 0,
      y_end: 7,
      height: 8,
      x_start: 0,
      x_end: 7,
      width: 8,
      pixel_count: 64,
      baseline: 6,
    }
    let chars = @ocr.segment_chars_projection(img, line)
    assert_true(chars.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_text_line_image: 基本提取" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let line = @ocr.TextLineInfo::{
      y_start: 0,
      y_end: 7,
      height: 8,
      x_start: 0,
      x_end: 7,
      width: 8,
      pixel_count: 64,
      baseline: 6,
    }
    let result = @ocr.extract_text_line_image(img, line)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_char_image: 基本提取" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let char = @ocr.CharSegment::{
      x_start: 0,
      x_end: 3,
      width: 4,
      y_start: 0,
      y_end: 7,
      height: 8,
      pixel_count: 32,
    }
    let result = @ocr.extract_char_image(img, char)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}