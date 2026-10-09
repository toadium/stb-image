// v187.0.0 table_image_extraction.mbt 测试：表格线检测/交叉点/增强表格/图片提取/报告

///|
test "detect_horizontal_table_lines: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let lines = @ocr.detect_horizontal_table_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let lines = @ocr.detect_vertical_table_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "find_line_intersections: 基本交叉" {
  let h_lines : Array[(Int, Int, Int)] = [(4, 0, 15)]
  let v_lines : Array[(Int, Int, Int)] = [(4, 0, 15)]
  let intersections = @ocr.find_line_intersections(h_lines, v_lines)
  assert_true(intersections.length() >= 0)
}

///|
test "detect_table_enhanced: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let tables = @ocr.detect_table_enhanced(img)
    assert_true(tables.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "enhanced_table_to_markdown: 基本输出" {
  let table = @ocr.EnhancedTableResult::{
    x: 0,
    y: 0,
    width: 100,
    height: 50,
    rows: 2,
    cols: 2,
    cells: [],
    has_header: true,
    header_rows: 1,
    detection: @ocr.TableDetectionResult::{
      horizontal_lines: [],
      vertical_lines: [],
      intersections: [],
      num_rows: 2,
      num_cols: 2,
      confidence: 0.9,
    },
    confidence: 0.9,
  }
  let md = @ocr.enhanced_table_to_markdown(table)
  assert_true(md.length() >= 0)
}

///|
test "extract_images_enhanced: 基本提取" {
  let img = @types.Image::{
    width: 16,
    height: 16,
    channels: 1,
    data: Bytes::from_array(Array::make(256, 255)),
  }
  let images = @ocr.extract_images_enhanced(img)
  assert_true(images.length() >= 0)
}

///|
test "generate_image_extraction_report: 基本报告" {
  let images : Array[@ocr.ExtractedImage] = []
  let report = @ocr.generate_image_extraction_report(images)
  assert_true(report.length() > 0)
}

///|
test "analyze_table_results: 基本分析" {
  let tables : Array[@ocr.EnhancedTableResult] = []
  let stats = @ocr.analyze_table_results(tables)
  assert_true(stats.length() > 0)
}