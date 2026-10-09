// v187.0.0 scan_document_ocr.mbt 测试：扫描OCR配置/质量评估/预处理/版面/识别/输出

///|
test "scan_ocr_default_config: 默认值" {
  let config = @ocr.scan_ocr_default_config()
  assert_eq(config.language, "english")
  assert_eq(config.dpi, 300)
  assert_eq(config.deskew, true)
  assert_eq(config.denoise, true)
  assert_eq(config.binarization_method, "otsu")
}

///|
test "evaluate_scan_quality: 基本评估" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let quality = @ocr.evaluate_scan_quality(img)
    assert_true(quality.overall_score >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "scan_document_preprocess: 基本预处理" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let config = @ocr.scan_ocr_default_config()
    let result = @ocr.scan_document_preprocess(img, config)
    assert_true(result.width > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "analyze_layout_scan: 基本分析" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let blocks = @ocr.analyze_layout_scan(img)
    assert_true(blocks.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "scan_ocr_recognize: 基本识别" {
  try {
    let img = @types.Image::{
      width: 16,
      height: 16,
      channels: 1,
      data: Bytes::from_array(Array::make(256, 255)),
    }
    let config = @ocr.scan_ocr_default_config()
    let result = @ocr.scan_ocr_recognize(img, config)
    assert_true(result.page_number >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "batch_scan_ocr: 基本批量" {
  try {
    let img = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let config = @ocr.scan_ocr_default_config()
    let results = @ocr.batch_scan_ocr([img, img], config)
    assert_eq(results.length(), 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_result_to_text: 基本输出" {
  let result = @ocr.OCRPageResult::{
    page_number: 1,
    width: 100,
    height: 100,
    blocks: [],
    full_text: "hello",
    average_confidence: 0.9,
    processing_time_ms: 10.0,
  }
  let text = @ocr.ocr_result_to_text(result)
  assert_true(text.length() > 0)
}

///|
test "ocr_result_to_hocr: 基本输出" {
  let result = @ocr.OCRPageResult::{
    page_number: 1,
    width: 100,
    height: 100,
    blocks: [],
    full_text: "hello",
    average_confidence: 0.9,
    processing_time_ms: 10.0,
  }
  let hocr = @ocr.ocr_result_to_hocr(result)
  assert_true(hocr.length() > 0)
}

///|
test "ocr_result_to_json: 基本输出" {
  let result = @ocr.OCRPageResult::{
    page_number: 1,
    width: 100,
    height: 100,
    blocks: [],
    full_text: "hello",
    average_confidence: 0.9,
    processing_time_ms: 10.0,
  }
  let json = @ocr.ocr_result_to_json(result)
  assert_true(json.length() > 0)
}
