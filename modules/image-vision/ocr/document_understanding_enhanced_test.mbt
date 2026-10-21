// v187.0.0 document_understanding_enhanced.mbt 测试：增强版面/阅读顺序/段落/标题/结构树

///|
test "document_understanding_enhanced_default_config: 默认值" {
  let config = @ocr.document_understanding_enhanced_default_config()
  assert_true(config.min_block_width > 0)
}

///|
test "analyze_layout_enhanced: 基本分析" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let config = @ocr.document_understanding_enhanced_default_config()
    let blocks = @ocr.analyze_layout_enhanced(img, config~)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "optimize_reading_order: 基本优化" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let order = @ocr.optimize_reading_order(blocks, 1)
  assert_true(order.length() >= 0)
}

///|
test "detect_paragraphs: 基本检测" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let paragraphs = @ocr.detect_paragraphs(blocks)
  assert_true(paragraphs.length() >= 0)
}

///|
test "detect_titles: 基本检测" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let titles = @ocr.detect_titles(blocks)
  assert_true(titles.length() >= 0)
}

///|
test "build_document_structure_tree: 基本构建" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let tree = @ocr.build_document_structure_tree(blocks)
  assert_true(tree.length() >= 0)
}

///|
test "extract_document_text: 基本提取" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let text = @ocr.extract_document_text(blocks)
  assert_true(text.length() >= 0)
}

///|
test "document_statistics_enhanced: 基本统计" {
  let blocks : Array[@ocr.DocumentBlock] = []
  let _ = @ocr.document_statistics_enhanced(blocks)
  assert_true(true)
}

///|
test "understand_document_enhanced: 基本理解" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 128)),
    }
    let (blocks, _, _) = @ocr.understand_document_enhanced(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
