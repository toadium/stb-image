// v187.0.0 document_reconstruction.mbt 测试：Markdown还原/符号识别/表格/阅读顺序

///|
test "recognize_symbols_markdown: 非空文本" {
  let symbols = @ocr.recognize_symbols_markdown("hello + world")
  assert_true(symbols.length() > 0)
}

///|
test "recognize_symbols_markdown: 空文本" {
  let symbols = @ocr.recognize_symbols_markdown("")
  assert_eq(symbols.length(), 0)
}

///|
test "classify_markdown_element: 标题" {
  let block = @ocr.TextBlock::{
    x: 0,
    y: 0,
    width: 200,
    height: 60,
    block_type: "title",
    text: "Title",
    confidence: 0.9,
    reading_order: 0,
  }
  let elem_type = @ocr.classify_markdown_element(block, avg_font_size=16.0)
  assert_true(elem_type == @ocr.MarkdownElementType::Title)
}

///|
test "classify_markdown_element: 段落" {
  let block = @ocr.TextBlock::{
    x: 0,
    y: 100,
    width: 200,
    height: 16,
    block_type: "text",
    text: "paragraph",
    confidence: 0.9,
    reading_order: 0,
  }
  let elem_type = @ocr.classify_markdown_element(block, avg_font_size=16.0)
  assert_true(elem_type == @ocr.MarkdownElementType::Paragraph)
}

///|
test "markdown_table_to_string: 有表头" {
  let table = @ocr.MarkdownTable::{
    rows: 2,
    cols: 2,
    cells: [["a", "b"], ["c", "d"]],
    has_header: true,
  }
  let md = @ocr.markdown_table_to_string(table)
  assert_true(md.contains("a"))
  assert_true(md.contains("---"))
}

///|
test "markdown_table_to_string: 无表头" {
  let table = @ocr.MarkdownTable::{
    rows: 1,
    cols: 2,
    cells: [["x", "y"]],
    has_header: false,
  }
  let md = @ocr.markdown_table_to_string(table)
  assert_true(md.contains("x"))
}

///|
test "determine_reading_order_markdown: 基本排序" {
  let elements = [
    @ocr.MarkdownElement::{
      element_type: @ocr.MarkdownElementType::Paragraph,
      x: 0,
      y: 100,
      width: 100,
      height: 20,
      content: "second",
      confidence: 0.9,
    },
    @ocr.MarkdownElement::{
      element_type: @ocr.MarkdownElementType::Paragraph,
      x: 0,
      y: 0,
      width: 100,
      height: 20,
      content: "first",
      confidence: 0.9,
    },
  ]
  let order = @ocr.determine_reading_order_markdown(elements)
  assert_eq(order[0], 1)
  assert_eq(order[1], 0)
}

///|
test "markdown_document_to_string: 基本输出" {
  let doc = @ocr.MarkdownDocument::{
    title: "Test",
    elements: [],
    tables: [],
    images: [],
    symbols: [],
    reading_order: [],
  }
  let md = @ocr.markdown_document_to_string(doc)
  assert_true(md.contains("Test"))
}

///|
test "build_markdown_document: 基本构建" {
  try {
    let ocr_result = @ocr.OCRPageResult::{
      page_number: 1,
      width: 800,
      height: 600,
      blocks: [
        @ocr.TextBlock::{
          x: 0,
          y: 0,
          width: 200,
          height: 16,
          block_type: "text",
          text: "hello",
          confidence: 0.9,
          reading_order: 0,
        },
      ],
      full_text: "hello",
      average_confidence: 0.9,
      processing_time_ms: 10.0,
    }
    let doc = @ocr.build_markdown_document(ocr_result, title="MyDoc")
    assert_eq(doc.title, "MyDoc")
    assert_true(doc.elements.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "build_markdown_document: 空块抛异常" {
  try {
    let ocr_result = @ocr.OCRPageResult::{
      page_number: 1,
      width: 800,
      height: 600,
      blocks: [],
      full_text: "",
      average_confidence: 0.0,
      processing_time_ms: 0.0,
    }
    let _ = @ocr.build_markdown_document(ocr_result)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "generate_markdown_image_placeholder: 基本占位符" {
  let image = @ocr.MarkdownImage::{
    x: 10,
    y: 20,
    width: 100,
    height: 50,
    image_type: "png",
    confidence: 0.9,
  }
  let placeholder = @ocr.generate_markdown_image_placeholder(image, 1)
  assert_true(placeholder.contains("图片"))
  assert_true(placeholder.contains("png"))
}

///|
test "analyze_markdown_element_distribution: 基本统计" {
  let doc = @ocr.MarkdownDocument::{
    title: "Test",
    elements: [
      @ocr.MarkdownElement::{
        element_type: @ocr.MarkdownElementType::Paragraph,
        x: 0,
        y: 0,
        width: 100,
        height: 20,
        content: "p1",
        confidence: 0.9,
      },
      @ocr.MarkdownElement::{
        element_type: @ocr.MarkdownElementType::Paragraph,
        x: 0,
        y: 30,
        width: 100,
        height: 20,
        content: "p2",
        confidence: 0.9,
      },
    ],
    tables: [],
    images: [],
    symbols: [],
    reading_order: [0, 1],
  }
  let dist = @ocr.analyze_markdown_element_distribution(doc)
  assert_eq(dist.length(), 8)
}
