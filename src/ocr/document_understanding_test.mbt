// v187.0.0 document_understanding.mbt 测试：版面分析/阅读顺序/标题/段落/统计/列检测

///|
test "analyze_document_layout: 基本分析" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let structure = @ocr.analyze_document_layout(img)
    assert_true(structure.num_elements >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "compute_reading_order: 基本排序" {
  try {
    let elements : Array[@ocr.DocumentElement] = [
      @ocr.DocumentElement::{
        element_type: @ocr.DocumentElementType::Body,
        x: 0,
        y: 0,
        width: 100,
        height: 20,
        text: "first",
        confidence: 0.9,
        font_size: 12,
        font_weight: "normal",
        reading_order: 0,
      },
    ]
    let order = @ocr.compute_reading_order(elements)
    assert_eq(order.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "compute_reading_order: 空列表抛异常" {
  try {
    let _ = @ocr.compute_reading_order([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "extract_title: 基本提取" {
  let structure = @ocr.DocumentStructure::{
    elements: [
      @ocr.DocumentElement::{
        element_type: @ocr.DocumentElementType::Title,
        x: 0,
        y: 0,
        width: 100,
        height: 30,
        text: "MyTitle",
        confidence: 0.9,
        font_size: 24,
        font_weight: "bold",
        reading_order: 0,
      },
    ],
    num_elements: 1,
    title: "MyTitle",
    num_headings: 0,
    num_paragraphs: 0,
    reading_order: [0],
    bounding_box: (0, 0, 100, 100),
  }
  let title = @ocr.extract_title(structure)
  assert_eq(title, "MyTitle")
}

///|
test "extract_headings: 基本提取" {
  let structure = @ocr.DocumentStructure::{
    elements: [],
    num_elements: 0,
    title: "",
    num_headings: 0,
    num_paragraphs: 0,
    reading_order: [],
    bounding_box: (0, 0, 100, 100),
  }
  let headings = @ocr.extract_headings(structure)
  assert_eq(headings.length(), 0)
}

///|
test "extract_paragraphs: 基本提取" {
  let structure = @ocr.DocumentStructure::{
    elements: [],
    num_elements: 0,
    title: "",
    num_headings: 0,
    num_paragraphs: 0,
    reading_order: [],
    bounding_box: (0, 0, 100, 100),
  }
  let paragraphs = @ocr.extract_paragraphs(structure)
  assert_eq(paragraphs.length(), 0)
}

///|
test "get_elements_in_reading_order: 基本提取" {
  let structure = @ocr.DocumentStructure::{
    elements: [],
    num_elements: 0,
    title: "",
    num_headings: 0,
    num_paragraphs: 0,
    reading_order: [],
    bounding_box: (0, 0, 100, 100),
  }
  let ordered = @ocr.get_elements_in_reading_order(structure)
  assert_eq(ordered.length(), 0)
}

///|
test "document_structure_stats: 基本统计" {
  let structure = @ocr.DocumentStructure::{
    elements: [],
    num_elements: 0,
    title: "",
    num_headings: 0,
    num_paragraphs: 0,
    reading_order: [],
    bounding_box: (0, 0, 100, 100),
  }
  let (total, titles, headings, paragraphs, _) = @ocr.document_structure_stats(
    structure,
  )
  assert_eq(total, 0)
  assert_eq(titles, 0)
  assert_eq(headings, 0)
  assert_eq(paragraphs, 0)
}

///|
test "detect_document_columns: 基本检测" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let cols = @ocr.detect_document_columns(img)
    assert_true(cols >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "understand_document: 基本理解" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let structure = @ocr.understand_document(img)
    assert_true(structure.num_elements >= 0)
  } catch {
    _ => assert_true(false)
  }
}
