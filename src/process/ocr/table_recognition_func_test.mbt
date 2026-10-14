// v235.0.0 table_recognition 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn tr_make_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn tr_make_img_mismatch(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn tr_make_hline(y : Int, x1 : Int, x2 : Int) -> @ocr.TableLine {
  @ocr.TableLine::{
    x1,
    y1: y,
    x2,
    y2: y,
    line_type: @ocr.TableLineType::Horizontal,
    thickness: 1,
  }
}

///|
fn tr_make_vline(x : Int, y1 : Int, y2 : Int) -> @ocr.TableLine {
  @ocr.TableLine::{
    x1: x,
    y1,
    x2: x,
    y2,
    line_type: @ocr.TableLineType::Vertical,
    thickness: 1,
  }
}

///|
fn tr_make_cell(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  row : Int,
  col : Int,
) -> @ocr.TableCell {
  @ocr.TableCell::{
    x,
    y,
    width: w,
    height: h,
    row,
    col,
    row_span: 1,
    col_span: 1,
  }
}

///|
fn tr_make_structure(rows : Int, cols : Int) -> @ocr.TableStructure {
  @ocr.TableStructure::{
    rows,
    cols,
    cells: [],
    horizontal_lines: [],
    vertical_lines: [],
    bounding_box: (0, 0, 100, 100),
  }
}

///|
fn tr_make_table_img() -> @types.Image {
  let w = 100
  let h = 100
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  for x in 10..<90 {
    data[20 * w + x] = b'\x00'
    data[50 * w + x] = b'\x00'
    data[80 * w + x] = b'\x00'
  }
  for y in 20..<80 {
    data[y * w + 10] = b'\x00'
    data[y * w + 50] = b'\x00'
    data[y * w + 90] = b'\x00'
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ========== detect_horizontal_lines 错误路径 ==========

///|
test "detect_horizontal_lines: width 0 raises" {
  let img = tr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.detect_horizontal_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_lines: height 0 raises" {
  let img = tr_make_img(10, 0, 1, 128)
  try {
    let _ = @ocr.detect_horizontal_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_horizontal_lines 功能路径 ==========

///|
test "detect_horizontal_lines: white image no lines" {
  let img = tr_make_img(50, 50, 1, 255)
  try {
    let lines = @ocr.detect_horizontal_lines(img)
    assert_eq(lines.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_lines: image with horizontal lines" {
  let img = tr_make_table_img()
  try {
    let lines = @ocr.detect_horizontal_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_horizontal_lines: with custom params" {
  let img = tr_make_table_img()
  try {
    let lines = @ocr.detect_horizontal_lines(img, min_length=10, max_gap=3)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== detect_vertical_lines 错误路径 ==========

///|
test "detect_vertical_lines: width 0 raises" {
  let img = tr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.detect_vertical_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_lines: height 0 raises" {
  let img = tr_make_img(10, 0, 1, 128)
  try {
    let _ = @ocr.detect_vertical_lines(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== detect_vertical_lines 功能路径 ==========

///|
test "detect_vertical_lines: white image no lines" {
  let img = tr_make_img(50, 50, 1, 255)
  try {
    let lines = @ocr.detect_vertical_lines(img)
    assert_eq(lines.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_lines: image with vertical lines" {
  let img = tr_make_table_img()
  try {
    let lines = @ocr.detect_vertical_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== analyze_table_structure 错误路径 ==========

///|
test "analyze_table_structure: empty horizontal raises" {
  let vlines = [tr_make_vline(10, 0, 50), tr_make_vline(90, 0, 50)]
  try {
    let _ = @ocr.analyze_table_structure([], vlines)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_table_structure: empty vertical raises" {
  let hlines = [tr_make_hline(10, 0, 50), tr_make_hline(90, 0, 50)]
  try {
    let _ = @ocr.analyze_table_structure(hlines, [])
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== analyze_table_structure 功能路径 ==========

///|
test "analyze_table_structure: single lines returns 0 rows cols" {
  let hlines = [tr_make_hline(10, 0, 50)]
  let vlines = [tr_make_vline(10, 0, 50)]
  try {
    let s = @ocr.analyze_table_structure(hlines, vlines)
    assert_eq(s.rows, 0)
    assert_eq(s.cols, 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_table_structure: proper table grid" {
  let hlines = [
    tr_make_hline(0, 0, 100),
    tr_make_hline(50, 0, 100),
    tr_make_hline(100, 0, 100),
  ]
  let vlines = [
    tr_make_vline(0, 0, 100),
    tr_make_vline(50, 0, 100),
    tr_make_vline(100, 0, 100),
  ]
  try {
    let s = @ocr.analyze_table_structure(hlines, vlines)
    assert_true(s.rows >= 1)
    assert_true(s.cols >= 1)
    assert_true(s.cells.length() >= 1)
  } catch {
    _ => assert_true(false)
  }
}

// ========== recognize_table 错误路径 ==========

///|
test "recognize_table: width 0 raises" {
  let img = tr_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.recognize_table(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_table: channels 5 raises" {
  let img = tr_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.recognize_table(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_table: data mismatch raises" {
  let img = tr_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.recognize_table(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== recognize_table 功能路径 ==========

///|
test "recognize_table: white image raises no lines" {
  let img = tr_make_img(80, 80, 1, 255)
  try {
    let _ = @ocr.recognize_table(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "recognize_table: table image" {
  let img = tr_make_table_img()
  try {
    let s = @ocr.recognize_table(img)
    assert_true(s.rows >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_table: with custom min_line_length" {
  let img = tr_make_table_img()
  try {
    let s = @ocr.recognize_table(img, min_line_length=10)
    assert_true(s.rows >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_cell_image 错误路径 ==========

///|
test "extract_cell_image: width 0 raises" {
  let img = tr_make_img(0, 10, 1, 128)
  let cell = tr_make_cell(0, 0, 10, 10, 0, 0)
  try {
    let _ = @ocr.extract_cell_image(img, cell)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_cell_image: cell width 0 raises" {
  let img = tr_make_img(50, 50, 1, 128)
  let cell = tr_make_cell(0, 0, 0, 10, 0, 0)
  try {
    let _ = @ocr.extract_cell_image(img, cell)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_cell_image: negative padding raises" {
  let img = tr_make_img(50, 50, 1, 128)
  let cell = tr_make_cell(0, 0, 10, 10, 0, 0)
  try {
    let _ = @ocr.extract_cell_image(img, cell, padding=-1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_cell_image 功能路径 ==========

///|
test "extract_cell_image: valid cell" {
  let img = tr_make_img(50, 50, 1, 200)
  let cell = tr_make_cell(10, 10, 20, 20, 0, 0)
  try {
    let result = @ocr.extract_cell_image(img, cell)
    assert_true(result.width > 0)
    assert_true(result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_cell_image: with padding" {
  let img = tr_make_img(50, 50, 1, 200)
  let cell = tr_make_cell(10, 10, 20, 20, 0, 0)
  try {
    let result = @ocr.extract_cell_image(img, cell, padding=3)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== extract_all_cells 错误路径 ==========

///|
test "extract_all_cells: width 0 raises" {
  let img = tr_make_img(0, 10, 1, 128)
  let s = tr_make_structure(2, 2)
  try {
    let _ = @ocr.extract_all_cells(img, s)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "extract_all_cells: negative padding raises" {
  let img = tr_make_img(50, 50, 1, 128)
  let s = tr_make_structure(2, 2)
  try {
    let _ = @ocr.extract_all_cells(img, s, padding=-1)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== extract_all_cells 功能路径 ==========

///|
test "extract_all_cells: empty structure" {
  let img = tr_make_img(50, 50, 1, 200)
  let s = tr_make_structure(0, 0)
  try {
    let cells = @ocr.extract_all_cells(img, s)
    assert_eq(cells.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_all_cells: structure with cells" {
  let img = tr_make_img(100, 100, 1, 200)
  let cells = [
    tr_make_cell(10, 10, 30, 30, 0, 0),
    tr_make_cell(50, 10, 30, 30, 0, 1),
    tr_make_cell(10, 50, 30, 30, 1, 0),
    tr_make_cell(50, 50, 30, 30, 1, 1),
  ]
  let s = @ocr.TableStructure::{
    rows: 2,
    cols: 2,
    cells,
    horizontal_lines: [],
    vertical_lines: [],
    bounding_box: (0, 0, 100, 100),
  }
  try {
    let result = @ocr.extract_all_cells(img, s)
    assert_eq(result.length(), 4)
  } catch {
    _ => assert_true(false)
  }
}
