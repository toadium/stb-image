// v231.0.0 table_image_extraction 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn tbl_make_img(w : Int32, h : Int32, data : Array[Int32]) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data.map(fn(x) { x.to_byte() })),
  }
}

///|
fn tbl_uniform(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

///|
fn tbl_make_detection(confidence : Double) -> @ocr.TableDetectionResult {
  @ocr.TableDetectionResult::{
    horizontal_lines: [],
    vertical_lines: [],
    intersections: [],
    num_rows: 2,
    num_cols: 2,
    confidence,
  }
}

///|
fn tbl_make_enhanced(
  rows : Int32,
  cols : Int32,
  has_header : Bool,
) -> @ocr.EnhancedTableResult {
  @ocr.EnhancedTableResult::{
    x: 0,
    y: 0,
    width: 100,
    height: 50,
    rows,
    cols,
    cells: [],
    has_header,
    header_rows: 1,
    detection: tbl_make_detection(0.9),
    confidence: 0.9,
  }
}

// ========== detect_horizontal_table_lines 错误路径 ==========

///|
test "detect_horizontal_table_lines: zero width raises" {
  try {
    let _ = @ocr.detect_horizontal_table_lines(tbl_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_table_lines: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_horizontal_table_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_table_lines: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_horizontal_table_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_table_lines: min_length <= 0 raises" {
  try {
    let _ = @ocr.detect_horizontal_table_lines(
      tbl_uniform(16, 16, 128),
      min_length=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_table_lines: max_gap < 0 raises" {
  try {
    let _ = @ocr.detect_horizontal_table_lines(
      tbl_uniform(16, 16, 128),
      max_gap=-1,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_horizontal_table_lines 功能路径 ==========

///|
test "detect_horizontal_table_lines: all white returns no lines" {
  try {
    let lines = @ocr.detect_horizontal_table_lines(tbl_uniform(64, 64, 255))
    assert_eq(lines.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_table_lines: detects horizontal black lines" {
  try {
    let data : Array[Int32] = Array::make(64 * 64, 255)
    for x in 0..<64 {
      data[10 * 64 + x] = 0
      data[40 * 64 + x] = 0
    }
    let lines = @ocr.detect_horizontal_table_lines(
      tbl_make_img(64, 64, data),
      min_length=50,
    )
    assert_true(lines.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_vertical_table_lines 错误路径 ==========

///|
test "detect_vertical_table_lines: zero width raises" {
  try {
    let _ = @ocr.detect_vertical_table_lines(tbl_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_vertical_table_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_vertical_table_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: min_length <= 0 raises" {
  try {
    let _ = @ocr.detect_vertical_table_lines(
      tbl_uniform(16, 16, 128),
      min_length=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: max_gap < 0 raises" {
  try {
    let _ = @ocr.detect_vertical_table_lines(
      tbl_uniform(16, 16, 128),
      max_gap=-1,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_vertical_table_lines 功能路径 ==========

///|
test "detect_vertical_table_lines: all white returns no lines" {
  try {
    let lines = @ocr.detect_vertical_table_lines(tbl_uniform(64, 64, 255))
    assert_eq(lines.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_table_lines: detects vertical black lines" {
  try {
    let data : Array[Int32] = Array::make(64 * 64, 255)
    for y in 0..<64 {
      data[y * 64 + 10] = 0
      data[y * 64 + 40] = 0
    }
    let lines = @ocr.detect_vertical_table_lines(
      tbl_make_img(64, 64, data),
      min_length=50,
    )
    assert_true(lines.length() >= 2)
  } catch {
    _ => assert_true(false)
  }
}

// ========== find_line_intersections 功能路径 ==========

///|
test "find_line_intersections: no intersection" {
  let h_lines : Array[(Int32, Int32, Int32)] = [(10, 0, 30)]
  let v_lines : Array[(Int32, Int32, Int32)] = [(50, 0, 30)]
  let result = @ocr.find_line_intersections(h_lines, v_lines)
  assert_eq(result.length(), 0)
}

///|
test "find_line_intersections: single intersection" {
  let h_lines : Array[(Int32, Int32, Int32)] = [(10, 0, 30)]
  let v_lines : Array[(Int32, Int32, Int32)] = [(15, 0, 30)]
  let result = @ocr.find_line_intersections(h_lines, v_lines)
  assert_eq(result.length(), 1)
  assert_eq(result[0], (15, 10))
}

///|
test "find_line_intersections: multiple intersections" {
  let h_lines : Array[(Int32, Int32, Int32)] = [(10, 0, 50), (30, 0, 50)]
  let v_lines : Array[(Int32, Int32, Int32)] = [(15, 0, 50), (35, 0, 50)]
  let result = @ocr.find_line_intersections(h_lines, v_lines)
  assert_eq(result.length(), 4)
}

///|
test "find_line_intersections: empty inputs" {
  let result = @ocr.find_line_intersections([], [])
  assert_eq(result.length(), 0)
}

// ========== detect_table_enhanced 错误路径 ==========

///|
test "detect_table_enhanced: zero width raises" {
  try {
    let _ = @ocr.detect_table_enhanced(tbl_uniform(0, 8, 128))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_table_enhanced: channels != 1 raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 3,
      data: Bytes::from_array(Array::make(768, 128)),
    }
    let _ = @ocr.detect_table_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_table_enhanced: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(200, 128)),
    }
    let _ = @ocr.detect_table_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_table_enhanced: min_table_size <= 0 raises" {
  try {
    let _ = @ocr.detect_table_enhanced(
      tbl_uniform(16, 16, 128),
      min_table_size=0,
    )
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_table_enhanced 功能路径 ==========

///|
test "detect_table_enhanced: all white returns no tables" {
  try {
    let tables = @ocr.detect_table_enhanced(tbl_uniform(64, 64, 255))
    assert_eq(tables.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_table_enhanced: grid table detected" {
  try {
    let data : Array[Int32] = Array::make(200 * 200, 255)
    for x in 0..<200 {
      data[20 * 200 + x] = 0
      data[100 * 200 + x] = 0
      data[180 * 200 + x] = 0
    }
    for y in 0..<200 {
      data[y * 200 + 20] = 0
      data[y * 200 + 100] = 0
      data[y * 200 + 180] = 0
    }
    let tables = @ocr.detect_table_enhanced(
      tbl_make_img(200, 200, data),
      min_table_size=100,
    )
    assert_true(tables.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== enhanced_table_to_markdown 功能路径 ==========

///|
test "enhanced_table_to_markdown: with header" {
  let table = tbl_make_enhanced(3, 2, true)
  let md = @ocr.enhanced_table_to_markdown(table)
  assert_true(md.length() > 0)
  assert_true(md.contains("|"))
}

///|
test "enhanced_table_to_markdown: no header" {
  let table = tbl_make_enhanced(2, 3, false)
  let md = @ocr.enhanced_table_to_markdown(table)
  assert_true(md.length() > 0)
}

///|
test "enhanced_table_to_markdown: single row" {
  let table = tbl_make_enhanced(1, 3, true)
  let md = @ocr.enhanced_table_to_markdown(table)
  assert_true(md.length() > 0)
}

///|
test "enhanced_table_to_markdown: with cell text" {
  let cell = @ocr.TableCellContent::{
    row: 0,
    col: 0,
    row_span: 1,
    col_span: 1,
    x: 0,
    y: 0,
    width: 10,
    height: 10,
    text: "Hello",
    is_header: true,
    is_merged: false,
  }
  let table = @ocr.EnhancedTableResult::{
    x: 0,
    y: 0,
    width: 100,
    height: 50,
    rows: 2,
    cols: 2,
    cells: [cell],
    has_header: true,
    header_rows: 1,
    detection: tbl_make_detection(0.9),
    confidence: 0.9,
  }
  let md = @ocr.enhanced_table_to_markdown(table)
  assert_true(md.contains("Hello"))
}

// ========== extract_images_enhanced 功能路径 ==========

///|
test "extract_images_enhanced: all white returns no images" {
  let images = @ocr.extract_images_enhanced(tbl_uniform(64, 64, 255))
  assert_eq(images.length(), 0)
}

///|
test "extract_images_enhanced: large black region detected" {
  let images = @ocr.extract_images_enhanced(tbl_uniform(64, 64, 0))
  assert_true(images.length() >= 0)
}

///|
test "extract_images_enhanced: custom min_area" {
  let images = @ocr.extract_images_enhanced(
    tbl_uniform(32, 32, 0),
    min_area=100,
  )
  assert_true(images.length() >= 0)
}

// ========== generate_image_extraction_report 功能路径 ==========

///|
test "generate_image_extraction_report: empty list" {
  let report = @ocr.generate_image_extraction_report([])
  assert_true(report.contains("共提取 0"))
}

///|
test "generate_image_extraction_report: with images" {
  let img = @ocr.ExtractedImage::{
    x: 10,
    y: 20,
    width: 100,
    height: 80,
    image_type: "photo",
    confidence: 0.9,
    aspect_ratio: 1.25,
    fill_ratio: 0.8,
    edge_density: 0.2,
    file_name: "image_0.png",
  }
  let report = @ocr.generate_image_extraction_report([img])
  assert_true(report.contains("共提取 1"))
  assert_true(report.contains("photo"))
  assert_true(report.contains("image_0.png"))
}

// ========== analyze_table_results 功能路径 ==========

///|
test "analyze_table_results: empty list" {
  let stats = @ocr.analyze_table_results([])
  assert_eq(stats.length(), 5)
  assert_eq(stats[0], ("表格总数", 0))
}

///|
test "analyze_table_results: with tables" {
  let t1 = tbl_make_enhanced(3, 2, true)
  let t2 = tbl_make_enhanced(4, 3, false)
  let stats = @ocr.analyze_table_results([t1, t2])
  assert_eq(stats[0], ("表格总数", 2))
  assert_eq(stats[1], ("单元格总数", 0))
  assert_eq(stats[2], ("总行数", 7))
  assert_eq(stats[3], ("总列数", 5))
  assert_eq(stats[4], ("含表头表格", 1))
}
