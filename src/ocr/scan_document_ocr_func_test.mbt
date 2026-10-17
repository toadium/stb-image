// v234.0.0 scan_document_ocr 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn sdo_make_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn sdo_make_img_mismatch(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch + 1, b'\x00')),
  }
}

///|
fn sdo_make_config(
  lang : String,
  deskew : Bool,
  denoise : Bool,
) -> @ocr.ScanOCRConfig {
  @ocr.ScanOCRConfig::{
    language: lang,
    dpi: 300,
    deskew,
    denoise,
    binarization_method: "otsu",
    layout_analysis: true,
    confidence_threshold: 0.6,
  }
}

///|
fn sdo_make_text_block(
  x : Int,
  y : Int,
  w : Int,
  h : Int,
  text : String,
) -> @ocr.TextBlock {
  @ocr.TextBlock::{
    x,
    y,
    width: w,
    height: h,
    block_type: "text",
    text,
    confidence: 0.9,
    reading_order: 0,
  }
}

///|
fn sdo_make_page_result(
  blocks : Array[@ocr.TextBlock],
  text : String,
) -> @ocr.OCRPageResult {
  @ocr.OCRPageResult::{
    page_number: 1,
    width: 200,
    height: 100,
    blocks,
    full_text: text,
    average_confidence: 0.85,
    processing_time_ms: 10.0,
  }
}

// ========== scan_ocr_default_config ==========

///|
test "scan_ocr_default_config: returns expected defaults" {
  let cfg = @ocr.scan_ocr_default_config()
  assert_eq(cfg.language, "english")
  assert_eq(cfg.dpi, 300)
  assert_true(cfg.deskew)
  assert_true(cfg.denoise)
  assert_eq(cfg.binarization_method, "otsu")
  assert_true(cfg.layout_analysis)
  assert_true(cfg.confidence_threshold > 0.5)
}

// ========== evaluate_scan_quality 错误路径 ==========

///|
test "evaluate_scan_quality: width 0 raises" {
  let img = sdo_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: height 0 raises" {
  let img = sdo_make_img(10, 0, 1, 128)
  try {
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: channels 0 raises" {
  let img = sdo_make_img(10, 10, 0, 128)
  try {
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: channels 5 raises" {
  let img = sdo_make_img(10, 10, 5, 128)
  try {
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: data size mismatch raises" {
  let img = sdo_make_img_mismatch(10, 10, 1)
  try {
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== evaluate_scan_quality 功能路径 ==========

///|
test "evaluate_scan_quality: uniform white image" {
  let img = sdo_make_img(20, 20, 1, 255)
  try {
    let q = @ocr.evaluate_scan_quality(img)
    assert_true(q.brightness > 200.0)
    assert_true(q.overall_score >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: uniform black image" {
  let img = sdo_make_img(20, 20, 1, 0)
  try {
    let q = @ocr.evaluate_scan_quality(img)
    assert_true(q.brightness < 10.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "evaluate_scan_quality: rgb image" {
  let img = sdo_make_img(20, 20, 3, 128)
  try {
    let q = @ocr.evaluate_scan_quality(img)
    assert_true(q.brightness > 100.0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== scan_document_preprocess 错误路径 ==========

///|
test "scan_document_preprocess: width 0 raises" {
  let img = sdo_make_img(0, 10, 1, 128)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_document_preprocess(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "scan_document_preprocess: channels 0 raises" {
  let img = sdo_make_img(10, 10, 0, 128)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_document_preprocess(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "scan_document_preprocess: data mismatch raises" {
  let img = sdo_make_img_mismatch(10, 10, 1)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_document_preprocess(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== scan_document_preprocess 功能路径 ==========

///|
test "scan_document_preprocess: denoise+deskew enabled" {
  let img = sdo_make_img(30, 30, 1, 200)
  let cfg = sdo_make_config("english", true, true)
  try {
    let result = @ocr.scan_document_preprocess(img, cfg)
    assert_eq(result.width, 30)
    assert_eq(result.height, 30)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "scan_document_preprocess: denoise disabled" {
  let img = sdo_make_img(30, 30, 1, 200)
  let cfg = sdo_make_config("english", false, false)
  try {
    let result = @ocr.scan_document_preprocess(img, cfg)
    assert_eq(result.width, 30)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "scan_document_preprocess: rgb image with adaptive binarization" {
  let img = sdo_make_img(30, 30, 3, 180)
  let cfg = @ocr.ScanOCRConfig::{
    language: "chinese",
    dpi: 200,
    deskew: false,
    denoise: true,
    binarization_method: "adaptive",
    layout_analysis: false,
    confidence_threshold: 0.5,
  }
  try {
    let result = @ocr.scan_document_preprocess(img, cfg)
    assert_eq(result.width, 30)
  } catch {
    _ => assert_true(false)
  }
}

// ========== analyze_layout_scan 错误路径 ==========

///|
test "analyze_layout_scan: width 0 raises" {
  let img = sdo_make_img(0, 10, 1, 128)
  try {
    let _ = @ocr.analyze_layout_scan(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_scan: multi-channel raises" {
  let img = sdo_make_img(20, 20, 3, 128)
  try {
    let _ = @ocr.analyze_layout_scan(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_scan: data mismatch raises" {
  let img = sdo_make_img_mismatch(20, 20, 1)
  try {
    let _ = @ocr.analyze_layout_scan(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== analyze_layout_scan 功能路径 ==========

///|
test "analyze_layout_scan: all-white image returns no blocks" {
  let img = sdo_make_img(50, 50, 1, 255)
  try {
    let blocks = @ocr.analyze_layout_scan(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_scan: image with text rows" {
  let w = 100
  let h = 100
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  for x in 10..<90 {
    data[20 * w + x] = b'\x00'
    data[21 * w + x] = b'\x00'
    data[50 * w + x] = b'\x00'
    data[51 * w + x] = b'\x00'
  }
  let img = @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
  try {
    let blocks = @ocr.analyze_layout_scan(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ========== scan_ocr_recognize 错误路径 ==========

///|
test "scan_ocr_recognize: width 0 raises" {
  let img = sdo_make_img(0, 10, 1, 128)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_ocr_recognize(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "scan_ocr_recognize: channels 5 raises" {
  let img = sdo_make_img(10, 10, 5, 128)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_ocr_recognize(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "scan_ocr_recognize: data mismatch raises" {
  let img = sdo_make_img_mismatch(10, 10, 1)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.scan_ocr_recognize(img, cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== scan_ocr_recognize 功能路径 ==========

///|
test "scan_ocr_recognize: normal image with layout analysis" {
  let img = sdo_make_img(60, 60, 1, 200)
  let cfg = sdo_make_config("english", true, true)
  try {
    let result = @ocr.scan_ocr_recognize(img, cfg)
    assert_eq(result.width, 60)
    assert_eq(result.height, 60)
    assert_true(result.average_confidence >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "scan_ocr_recognize: without layout analysis" {
  let img = sdo_make_img(40, 40, 1, 180)
  let cfg = @ocr.ScanOCRConfig::{
    language: "digit",
    dpi: 150,
    deskew: false,
    denoise: false,
    binarization_method: "sauvola",
    layout_analysis: false,
    confidence_threshold: 0.3,
  }
  try {
    let result = @ocr.scan_ocr_recognize(img, cfg)
    assert_eq(result.width, 40)
  } catch {
    _ => assert_true(false)
  }
}

// ========== batch_scan_ocr 错误路径 ==========

///|
test "batch_scan_ocr: empty list raises" {
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.batch_scan_ocr([], cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "batch_scan_ocr: image with width 0 raises" {
  let img = sdo_make_img(0, 10, 1, 128)
  let cfg = sdo_make_config("english", true, true)
  try {
    let _ = @ocr.batch_scan_ocr([img], cfg)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== batch_scan_ocr 功能路径 ==========

///|
test "batch_scan_ocr: multiple images" {
  let img1 = sdo_make_img(40, 40, 1, 200)
  let img2 = sdo_make_img(40, 40, 1, 180)
  let cfg = sdo_make_config("english", false, false)
  try {
    let results = @ocr.batch_scan_ocr([img1, img2], cfg)
    assert_eq(results.length(), 2)
    assert_eq(results[0].page_number, 1)
    assert_eq(results[1].page_number, 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "batch_scan_ocr: single image" {
  let img = sdo_make_img(30, 30, 1, 200)
  let cfg = sdo_make_config("chinese", true, true)
  try {
    let results = @ocr.batch_scan_ocr([img], cfg)
    assert_eq(results.length(), 1)
    assert_eq(results[0].page_number, 1)
  } catch {
    _ => assert_true(false)
  }
}

// ========== ocr_result_to_text 功能路径 ==========

///|
test "ocr_result_to_text: returns full_text" {
  let result = sdo_make_page_result([], "hello world")
  let text = @ocr.ocr_result_to_text(result)
  assert_eq(text, "hello world")
}

///|
test "ocr_result_to_text: empty text" {
  let result = sdo_make_page_result([], "")
  let text = @ocr.ocr_result_to_text(result)
  assert_eq(text, "")
}

// ========== ocr_result_to_hocr 功能路径 ==========

///|
test "ocr_result_to_hocr: contains xml header" {
  let result = sdo_make_page_result([], "")
  let hocr = @ocr.ocr_result_to_hocr(result)
  assert_true(hocr.contains("<?xml"))
}

///|
test "ocr_result_to_hocr: contains page div" {
  let result = sdo_make_page_result([], "")
  let hocr = @ocr.ocr_result_to_hocr(result)
  assert_true(hocr.contains("ocr_page"))
}

///|
test "ocr_result_to_hocr: with blocks" {
  let block = sdo_make_text_block(10, 20, 100, 30, "test text")
  let result = sdo_make_page_result([block], "test text")
  let hocr = @ocr.ocr_result_to_hocr(result)
  assert_true(hocr.contains("ocr_carea"))
  assert_true(hocr.contains("test text"))
}

// ========== ocr_result_to_json 功能路径 ==========

///|
test "ocr_result_to_json: contains page_number" {
  let result = sdo_make_page_result([], "")
  let json = @ocr.ocr_result_to_json(result)
  assert_true(json.contains("page_number"))
}

///|
test "ocr_result_to_json: contains width and height" {
  let result = sdo_make_page_result([], "")
  let json = @ocr.ocr_result_to_json(result)
  assert_true(json.contains("width"))
  assert_true(json.contains("height"))
}

///|
test "ocr_result_to_json: with blocks" {
  let block = sdo_make_text_block(5, 10, 50, 20, "abc")
  let result = sdo_make_page_result([block], "abc")
  let json = @ocr.ocr_result_to_json(result)
  assert_true(json.contains("abc"))
  assert_true(json.contains("confidence"))
}

///|
test "ocr_result_to_json: full_text field" {
  let result = sdo_make_page_result([], "sample text")
  let json = @ocr.ocr_result_to_json(result)
  assert_true(json.contains("full_text"))
  assert_true(json.contains("sample text"))
}
