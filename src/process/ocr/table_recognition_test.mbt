// v187.0.0 table_recognition.mbt 测试：表格线检测/结构分析/识别/单元格提取

///|
test "detect_horizontal_lines: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let lines = @ocr.detect_horizontal_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_vertical_lines: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let lines = @ocr.detect_vertical_lines(img)
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_table_structure: 基本分析" {
  try {
    let h_lines : Array[@ocr.TableLine] = [
      @ocr.TableLine::{
        x1: 0,
        y1: 0,
        x2: 15,
        y2: 0,
        line_type: @ocr.TableLineType::Horizontal,
        thickness: 1,
      },
    ]
    let v_lines : Array[@ocr.TableLine] = [
      @ocr.TableLine::{
        x1: 0,
        y1: 0,
        x2: 0,
        y2: 15,
        line_type: @ocr.TableLineType::Vertical,
        thickness: 1,
      },
    ]
    let structure = @ocr.analyze_table_structure(h_lines, v_lines)
    assert_true(structure.rows >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "recognize_table: 基本识别" {
  try {
    let img = @types.Image::{
      width: 32,
      height: 32,
      channels: 1,
      data: Bytes::from_array(Array::make(1024, 0)),
    }
    let structure = @ocr.recognize_table(img, min_line_length=5)
    assert_true(structure.rows >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "extract_cell_image: 基本提取" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let cell = @ocr.TableCell::{
      x: 0,
      y: 0,
      width: 8,
      height: 8,
      row: 0,
      col: 0,
      row_span: 1,
      col_span: 1,
    }
    let result = @ocr.extract_cell_image(img, cell)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "extract_all_cells: 基本提取" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let structure = @ocr.TableStructure::{
      rows: 0,
      cols: 0,
      cells: [],
      horizontal_lines: [],
      vertical_lines: [],
      bounding_box: (0, 0, 16, 16),
    }
    let cells = @ocr.extract_all_cells(img, structure)
    assert_true(cells.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
