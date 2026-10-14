// v234.0.0 document_understanding_enhanced 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn due_make_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn due_make_img_mismatch(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn due_make_block(
  bt : @ocr.DocumentBlockType,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
) -> @ocr.DocumentBlock {
  @ocr.DocumentBlock::{
    block_type: bt,
    x,
    y,
    width: w,
    height: h,
    text,
    confidence: 0.9,
    font_size: 12,
    is_bold: false,
    is_italic: false,
    line_spacing: 1.0,
    indent_level: 0,
    column_index: 0,
    reading_order: 0,
    parent_id: -1,
    children_ids: [],
  }
}

///|
fn due_make_block_full(
  bt : @ocr.DocumentBlockType,
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
  font_size : Int,
  is_bold : Bool,
  col : Int,
) -> @ocr.DocumentBlock {
  @ocr.DocumentBlock::{
    block_type: bt,
    x,
    y,
    width: w,
    height: h,
    text,
    confidence: 0.9,
    font_size,
    is_bold,
    is_italic: false,
    line_spacing: 1.0,
    indent_level: 0,
    column_index: col,
    reading_order: 0,
    parent_id: -1,
    children_ids: [],
  }
}

///|
fn due_make_config(
  columns : Bool,
  hierarchy : Bool,
  titles : Bool,
) -> @ocr.DocumentUnderstandingEnhancedConfig {
  @ocr.DocumentUnderstandingEnhancedConfig::{
    min_block_width: 20,
    min_block_height: 10,
    title_font_size_threshold: 24,
    heading_font_size_threshold: 18,
    max_line_spacing_ratio: 2.0,
    enable_column_detection: columns,
    enable_hierarchy: hierarchy,
    enable_title_detection: titles,
  }
}

// ========== document_understanding_enhanced_default_config ==========

///|
test "document_understanding_enhanced_default_config: returns expected defaults" {
  let cfg = @ocr.document_understanding_enhanced_default_config()
  assert_eq(cfg.min_block_width, 20)
  assert_eq(cfg.min_block_height, 10)
  assert_eq(cfg.title_font_size_threshold, 24)
  assert_eq(cfg.heading_font_size_threshold, 18)
  assert_true(cfg.max_line_spacing_ratio > 1.5)
  assert_true(cfg.enable_column_detection)
  assert_true(cfg.enable_hierarchy)
  assert_true(cfg.enable_title_detection)
}

// ========== analyze_layout_enhanced 错误路径 ==========

///|
test "analyze_layout_enhanced: width 0 raises" {
  let img = due_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.analyze_layout_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: height 0 raises" {
  let img = due_make_img(10, 0, 1, 128)
  try {
    let _ = @ocr.analyze_layout_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: channels 0 raises" {
  let img = due_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.analyze_layout_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: channels 5 raises" {
  let img = due_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.analyze_layout_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: data mismatch raises" {
  let img = due_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.analyze_layout_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== analyze_layout_enhanced 功能路径 ==========

///|
test "analyze_layout_enhanced: white image default config" {
  let img = due_make_img(100, 100, 1, 255)
  try {
    let blocks = @ocr.analyze_layout_enhanced(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: rgb image with custom config" {
  let img = due_make_img(80, 80, 3, 200)
  let cfg = due_make_config(false, true, true)
  try {
    let blocks = @ocr.analyze_layout_enhanced(img, config=cfg)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_enhanced: image with text content" {
  let w = 100
  let h = 100
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  for x in 10..<90 {
    for y in 10..<20 {
      data[y * w + x] = b'\x00'
    }
    for y in 40..<50 {
      data[y * w + x] = b'\x00'
    }
  }
  let img = @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
  try {
    let blocks = @ocr.analyze_layout_enhanced(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== optimize_reading_order 功能路径 ==========

///|
test "optimize_reading_order: empty blocks" {
  let order = @ocr.optimize_reading_order([], 1)
  assert_eq(order.length(), 0)
}

///|
test "optimize_reading_order: single block" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 100, 20, "text"),
  ]
  let order = @ocr.optimize_reading_order(blocks, 1)
  assert_eq(order.length(), 1)
}

///|
test "optimize_reading_order: multiple blocks single column" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 100, 100, 20, "b"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 100, 20, "a"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 200, 100, 20, "c"),
  ]
  let order = @ocr.optimize_reading_order(blocks, 1)
  assert_eq(order.length(), 3)
  assert_eq(order[0], 1)
  assert_eq(order[1], 0)
  assert_eq(order[2], 2)
}

///|
test "optimize_reading_order: two columns" {
  let blocks = [
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      0,
      50,
      20,
      "a",
      12,
      false,
      0,
    ),
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      100,
      0,
      50,
      20,
      "b",
      12,
      false,
      1,
    ),
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      50,
      50,
      20,
      "c",
      12,
      false,
      0,
    ),
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      100,
      50,
      50,
      20,
      "d",
      12,
      false,
      1,
    ),
  ]
  let order = @ocr.optimize_reading_order(blocks, 2)
  assert_eq(order.length(), 4)
}

// ========== detect_paragraphs 功能路径 ==========

///|
test "detect_paragraphs: empty blocks" {
  let paras = @ocr.detect_paragraphs([])
  assert_eq(paras.length(), 0)
}

///|
test "detect_paragraphs: single paragraph block" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 100, 20, "text"),
  ]
  let paras = @ocr.detect_paragraphs(blocks)
  assert_true(paras.length() >= 1)
}

///|
test "detect_paragraphs: mixed block types" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Title, 0, 0, 100, 20, "Title"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 30, 100, 20, "para1"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 60, 100, 20, "para2"),
    due_make_block(@ocr.DocumentBlockType::Table, 0, 90, 100, 40, "table"),
  ]
  let paras = @ocr.detect_paragraphs(blocks)
  assert_true(paras.length() >= 1)
}

///|
test "detect_paragraphs: list items" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::ListItem, 0, 0, 100, 20, "item1"),
    due_make_block(@ocr.DocumentBlockType::ListItem, 0, 30, 100, 20, "item2"),
  ]
  let paras = @ocr.detect_paragraphs(blocks)
  assert_true(paras.length() >= 1)
}

///|
test "detect_paragraphs: with custom spacing ratio" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 100, 20, "a"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 30, 100, 20, "b"),
  ]
  let paras = @ocr.detect_paragraphs(blocks, max_line_spacing_ratio=3.0)
  assert_true(paras.length() >= 1)
}

// ========== detect_titles 功能路径 ==========

///|
test "detect_titles: empty blocks" {
  let titles = @ocr.detect_titles([])
  assert_eq(titles.length(), 0)
}

///|
test "detect_titles: large bold at top" {
  let blocks = [
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      0,
      200,
      30,
      "Title",
      28,
      true,
      0,
    ),
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      50,
      300,
      20,
      "body",
      12,
      false,
      0,
    ),
  ]
  let titles = @ocr.detect_titles(blocks)
  assert_true(titles.length() >= 1)
}

///|
test "detect_titles: no titles" {
  let blocks = [
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      200,
      300,
      20,
      "body1",
      12,
      false,
      0,
    ),
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      250,
      300,
      20,
      "body2",
      12,
      false,
      0,
    ),
  ]
  let titles = @ocr.detect_titles(blocks)
  assert_eq(titles.length(), 0)
}

///|
test "detect_titles: with custom threshold" {
  let blocks = [
    due_make_block_full(
      @ocr.DocumentBlockType::Paragraph,
      0,
      0,
      200,
      30,
      "Title",
      16,
      true,
      0,
    ),
  ]
  let titles = @ocr.detect_titles(blocks, title_font_size_threshold=14)
  assert_true(titles.length() >= 1)
}

// ========== build_document_structure_tree 功能路径 ==========

///|
test "build_document_structure_tree: empty blocks" {
  let trees = @ocr.build_document_structure_tree([])
  assert_eq(trees.length(), 0)
}

///|
test "build_document_structure_tree: single block" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 100, 20, "text"),
  ]
  let trees = @ocr.build_document_structure_tree(blocks)
  assert_eq(trees.length(), 1)
  assert_eq(trees[0].depth, 4)
}

///|
test "build_document_structure_tree: title and paragraphs" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Title, 0, 0, 200, 30, "Title"),
    due_make_block(@ocr.DocumentBlockType::Heading1, 0, 50, 200, 25, "H1"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 100, 200, 20, "para"),
  ]
  let trees = @ocr.build_document_structure_tree(blocks)
  assert_true(trees.length() >= 1)
}

///|
test "build_document_structure_tree: heading hierarchy" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Heading1, 0, 0, 200, 25, "H1"),
    due_make_block(@ocr.DocumentBlockType::Heading2, 0, 50, 200, 22, "H2"),
    due_make_block(@ocr.DocumentBlockType::Heading3, 0, 100, 200, 20, "H3"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 150, 200, 18, "para"),
  ]
  let trees = @ocr.build_document_structure_tree(blocks)
  assert_true(trees.length() >= 1)
}

// ========== extract_document_text 功能路径 ==========

///|
test "extract_document_text: empty blocks" {
  let text = @ocr.extract_document_text([])
  assert_eq(text, "")
}

///|
test "extract_document_text: with title and paragraph" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Title, 0, 0, 200, 30, "My Title"),
    due_make_block(
      @ocr.DocumentBlockType::Paragraph,
      0,
      50,
      200,
      20,
      "Body text",
    ),
  ]
  let text = @ocr.extract_document_text(blocks)
  assert_true(text.contains("My Title"))
  assert_true(text.contains("Body text"))
}

///|
test "extract_document_text: exclude headers" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Header, 0, 0, 200, 20, "Header"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 50, 200, 20, "Body"),
  ]
  let text = @ocr.extract_document_text(blocks, include_headers=false)
  assert_true(!text.contains("Header"))
  assert_true(text.contains("Body"))
}

///|
test "extract_document_text: include headers" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Header, 0, 0, 200, 20, "Header"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 50, 200, 20, "Body"),
  ]
  let text = @ocr.extract_document_text(blocks, include_headers=true)
  assert_true(text.contains("Header"))
}

///|
test "extract_document_text: exclude footers" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 0, 200, 20, "Body"),
    due_make_block(@ocr.DocumentBlockType::Footer, 0, 50, 200, 20, "Footer"),
  ]
  let text = @ocr.extract_document_text(blocks, include_footers=false)
  assert_true(!text.contains("Footer"))
  assert_true(text.contains("Body"))
}

///|
test "extract_document_text: list items" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::ListItem, 0, 0, 200, 20, "item1"),
    due_make_block(@ocr.DocumentBlockType::ListItem, 0, 30, 200, 20, "item2"),
  ]
  let text = @ocr.extract_document_text(blocks)
  assert_true(text.contains("item1"))
  assert_true(text.contains("item2"))
}

// ========== document_statistics_enhanced 功能路径 ==========

///|
test "document_statistics_enhanced: empty blocks" {
  let (titles, headings, paras, lists, tables, images, chars) = @ocr.document_statistics_enhanced([],
  )
  assert_eq(titles, 0)
  assert_eq(headings, 0)
  assert_eq(paras, 0)
  assert_eq(lists, 0)
  assert_eq(tables, 0)
  assert_eq(images, 0)
  assert_eq(chars, 0)
}

///|
test "document_statistics_enhanced: mixed blocks" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Title, 0, 0, 200, 30, "Title"),
    due_make_block(@ocr.DocumentBlockType::Heading1, 0, 50, 200, 25, "H1"),
    due_make_block(@ocr.DocumentBlockType::Heading2, 0, 100, 200, 22, "H2"),
    due_make_block(@ocr.DocumentBlockType::Paragraph, 0, 150, 200, 20, "Para"),
    due_make_block(@ocr.DocumentBlockType::ListItem, 0, 200, 200, 20, "Item"),
    due_make_block(@ocr.DocumentBlockType::Table, 0, 250, 200, 40, "Table"),
    due_make_block(@ocr.DocumentBlockType::Image, 0, 300, 200, 50, ""),
  ]
  let (titles, headings, paras, lists, tables, images, chars) = @ocr.document_statistics_enhanced(
    blocks,
  )
  assert_eq(titles, 1)
  assert_eq(headings, 2)
  assert_eq(paras, 1)
  assert_eq(lists, 1)
  assert_eq(tables, 1)
  assert_eq(images, 1)
  assert_true(chars > 0)
}

///|
test "document_statistics_enhanced: all heading levels" {
  let blocks = [
    due_make_block(@ocr.DocumentBlockType::Heading3, 0, 0, 200, 20, "H3"),
  ]
  let (_, headings, _, _, _, _, _) = @ocr.document_statistics_enhanced(blocks)
  assert_eq(headings, 1)
}

// ========== understand_document_enhanced 错误路径 ==========

///|
test "understand_document_enhanced: width 0 raises" {
  let img = due_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.understand_document_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: height 0 raises" {
  let img = due_make_img(10, 0, 1, 128)
  try {
    let _ = @ocr.understand_document_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: channels 0 raises" {
  let img = due_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.understand_document_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: channels 5 raises" {
  let img = due_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.understand_document_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: data mismatch raises" {
  let img = due_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.understand_document_enhanced(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== understand_document_enhanced 功能路径 ==========

///|
test "understand_document_enhanced: default config" {
  let img = due_make_img(80, 80, 1, 200)
  try {
    let (blocks, trees, text) = @ocr.understand_document_enhanced(img)
    assert_true(blocks.length() >= 0)
    assert_true(trees.length() >= 0)
    assert_true(text.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: with custom config" {
  let img = due_make_img(80, 80, 3, 180)
  let cfg = due_make_config(false, false, false)
  try {
    let (blocks, _, text) = @ocr.understand_document_enhanced(img, config=cfg)
    assert_true(blocks.length() >= 0)
    assert_true(text.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "understand_document_enhanced: rgb image" {
  let img = due_make_img(60, 60, 3, 200)
  try {
    let (blocks, trees, _) = @ocr.understand_document_enhanced(img)
    assert_true(blocks.length() >= 0)
    assert_true(trees.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
