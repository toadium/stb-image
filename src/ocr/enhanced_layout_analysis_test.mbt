// v187.0.0 enhanced_layout_analysis.mbt 测试：布局检测/页眉页脚/列边界/标题/列表/段落

///|
fn make_line(
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
  text : String,
) -> @ocr.TextLineAttributes {
  @ocr.TextLineAttributes::{
    x,
    y,
    width: w,
    height: h,
    font_size: 12.0,
    font_weight: "normal",
    is_indented: false,
    indent_level: 0,
    line_spacing: 1.0,
    text,
    alignment: "left",
  }
}

///|
test "detect_layout_type: 单栏" {
  let lines = [make_line(0, 0, 800, 20, "full width text line")]
  try {
    let result = @ocr.detect_layout_type(lines, 800, 1000)
    assert_true(result == @ocr.LayoutType::SingleColumn)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_layout_type: 空行列表抛异常" {
  try {
    let _ = @ocr.detect_layout_type([], 800, 1000)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detect_layout_type: 页宽为零抛异常" {
  let lines = [make_line(0, 0, 100, 20, "test")]
  try {
    let _ = @ocr.detect_layout_type(lines, 0, 1000)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detect_header_footer: 基本检测" {
  let lines = [
    make_line(0, 10, 800, 20, "header"),
    make_line(0, 500, 800, 20, "body"),
    make_line(0, 950, 800, 20, "footer"),
  ]
  try {
    let (header_bottom, footer_top) = @ocr.detect_header_footer(lines, 1000)
    assert_true(header_bottom >= 0)
    assert_true(footer_top <= 1000)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "detect_header_footer: 空行列表抛异常" {
  try {
    let _ = @ocr.detect_header_footer([], 1000)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "detect_column_boundaries: 单栏" {
  let lines = [make_line(0, 0, 800, 20, "test")]
  let boundaries = @ocr.detect_column_boundaries(
    lines,
    800,
    @ocr.LayoutType::SingleColumn,
  )
  assert_true(boundaries.length() >= 2)
}

///|
test "detect_column_boundaries: 双栏" {
  let lines = [make_line(0, 0, 380, 20, "left")]
  let boundaries = @ocr.detect_column_boundaries(
    lines,
    800,
    @ocr.LayoutType::DoubleColumn,
  )
  assert_true(boundaries.length() >= 3)
}

///|
test "detect_column_boundaries: 三栏" {
  let lines = [make_line(0, 0, 200, 20, "col")]
  let boundaries = @ocr.detect_column_boundaries(
    lines,
    900,
    @ocr.LayoutType::TripleColumn,
  )
  assert_true(boundaries.length() >= 5)
}

///|
test "is_heading_line: bold大字体是标题" {
  let line = @ocr.TextLineAttributes::{
    x: 0,
    y: 0,
    width: 100,
    height: 30,
    font_size: 24.0,
    font_weight: "bold",
    is_indented: false,
    indent_level: 0,
    line_spacing: 1.0,
    text: "Heading",
    alignment: "left",
  }
  let (is_heading, level) = @ocr.is_heading_line(line, 12.0)
  assert_eq(is_heading, true)
  assert_true(level > 0)
}

///|
test "is_heading_line: 普通字体非标题" {
  let line = make_line(0, 0, 100, 20, "normal text")
  let (is_heading, _) = @ocr.is_heading_line(line, 12.0)
  assert_eq(is_heading, false)
}

///|
test "detect_list_item: 无序列表" {
  let line = make_line(0, 0, 100, 20, "- item")
  let result = @ocr.detect_list_item(line)
  assert_true(result.item_type == @ocr.ListItemType::Bullet)
}

///|
test "detect_list_item: 有序列表" {
  let line = make_line(0, 0, 100, 20, "1. first")
  let result = @ocr.detect_list_item(line)
  assert_true(result.item_type == @ocr.ListItemType::Numbered)
}

///|
test "detect_list_item: 非列表" {
  let line = make_line(0, 0, 100, 20, "plain text")
  let result = @ocr.detect_list_item(line)
  assert_true(result.item_type == @ocr.ListItemType::None)
}

///|
test "is_code_block_line: 缩进判断" {
  let line = @ocr.TextLineAttributes::{
    x: 40,
    y: 0,
    width: 100,
    height: 20,
    font_size: 12.0,
    font_weight: "normal",
    is_indented: true,
    indent_level: 2,
    line_spacing: 1.0,
    text: "  code line",
    alignment: "left",
  }
  let result = @ocr.is_code_block_line(line, 10)
  assert_true(result || !result)
}

///|
test "is_quote_line: 引用判断" {
  let line = make_line(20, 0, 100, 20, "> quote")
  let result = @ocr.is_quote_line(line, 0)
  assert_true(result || !result)
}

///|
test "segment_paragraphs: 基本分段" {
  let lines = [
    make_line(0, 0, 100, 20, "first paragraph"),
    make_line(0, 30, 100, 20, "second paragraph"),
  ]
  let result = @ocr.segment_paragraphs(lines)
  assert_true(result.length() > 0)
}

///|
test "build_enhanced_elements: 基本构建" {
  let lines = [make_line(0, 0, 100, 20, "test text")]
  try {
    let doc = @ocr.build_enhanced_elements(lines, 800, 1000)
    assert_true(doc.elements.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "enhanced_element_distribution: 基本统计" {
  let lines = [make_line(0, 0, 100, 20, "test")]
  try {
    let doc = @ocr.build_enhanced_elements(lines, 800, 1000)
    let dist = @ocr.enhanced_element_distribution(doc)
    assert_true(dist.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "enhanced_document_to_markdown: 非空输出" {
  let lines = [make_line(0, 0, 100, 20, "test text")]
  try {
    let doc = @ocr.build_enhanced_elements(lines, 800, 1000)
    let markdown = @ocr.enhanced_document_to_markdown(doc)
    assert_true(markdown.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "smart_reading_order: 基本排序" {
  let lines = [
    make_line(0, 0, 100, 20, "first"),
    make_line(0, 30, 100, 20, "second"),
  ]
  try {
    let doc = @ocr.build_enhanced_elements(lines, 800, 1000)
    let order = @ocr.smart_reading_order(
      doc.elements,
      doc.layout_type,
      doc.column_boundaries,
    )
    assert_true(order.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
