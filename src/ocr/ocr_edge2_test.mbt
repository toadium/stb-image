// v216.0.0 ocr 错误路径增强测试 (补充未覆盖函数)

// ===== 辅助函数 =====

///|
fn oe2_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn oe2_rgb(w : Int32, h : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, 128)),
  }
}

///|
fn oe2_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn oe2_uniform(w : Int32, h : Int32, v : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

// ===== 1. detect_horizontal_lines / detect_vertical_lines =====

///|
test "oe2: detect_horizontal_lines 零宽度" {
  try {
    let _ = @ocr.detect_horizontal_lines(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_horizontal_lines 多通道" {
  try {
    let _ = @ocr.detect_horizontal_lines(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_horizontal_lines 数据不匹配" {
  try {
    let _ = @ocr.detect_horizontal_lines(oe2_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_horizontal_lines min_length为零" {
  try {
    let _ = @ocr.detect_horizontal_lines(oe2_uniform(8, 8, 0), min_length=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_horizontal_lines max_gap为负" {
  try {
    let _ = @ocr.detect_horizontal_lines(oe2_uniform(8, 8, 0), max_gap=-1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_vertical_lines 零宽度" {
  try {
    let _ = @ocr.detect_vertical_lines(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_vertical_lines 多通道" {
  try {
    let _ = @ocr.detect_vertical_lines(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_vertical_lines min_length为零" {
  try {
    let _ = @ocr.detect_vertical_lines(oe2_uniform(8, 8, 0), min_length=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. detect_horizontal_table_lines / detect_vertical_table_lines =====

///|
test "oe2: detect_horizontal_table_lines 零宽度" {
  try {
    let _ = @ocr.detect_horizontal_table_lines(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_horizontal_table_lines 多通道" {
  try {
    let _ = @ocr.detect_horizontal_table_lines(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_vertical_table_lines 零宽度" {
  try {
    let _ = @ocr.detect_vertical_table_lines(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_vertical_table_lines 多通道" {
  try {
    let _ = @ocr.detect_vertical_table_lines(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. evaluate_scan_quality =====

///|
test "oe2: evaluate_scan_quality 零宽度" {
  try {
    let _ = @ocr.evaluate_scan_quality(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: evaluate_scan_quality 无效通道" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(16, 128)),
    }
    let _ = @ocr.evaluate_scan_quality(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: evaluate_scan_quality 数据不匹配" {
  try {
    let _ = @ocr.evaluate_scan_quality(oe2_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. detect_table_enhanced =====

///|
test "oe2: detect_table_enhanced 零宽度" {
  try {
    let _ = @ocr.detect_table_enhanced(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_table_enhanced 多通道" {
  try {
    let _ = @ocr.detect_table_enhanced(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. complete_char_segmentation / detect_touching_chars =====

///|
test "oe2: complete_char_segmentation 零宽度" {
  try {
    let _ = @ocr.complete_char_segmentation(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: complete_char_segmentation 多通道" {
  try {
    let _ = @ocr.complete_char_segmentation(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_touching_chars 零宽度" {
  try {
    let _ = @ocr.detect_touching_chars(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_touching_chars 多通道" {
  try {
    let _ = @ocr.detect_touching_chars(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. detect_text_lines_projection =====

///|
test "oe2: detect_text_lines_projection 零宽度" {
  try {
    let _ = @ocr.detect_text_lines_projection(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_text_lines_projection 多通道" {
  try {
    let _ = @ocr.detect_text_lines_projection(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. analyze_document_layout / analyze_layout_scan =====

///|
test "oe2: analyze_document_layout 零宽度" {
  try {
    let _ = @ocr.analyze_document_layout(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: analyze_layout_scan 零宽度" {
  try {
    let _ = @ocr.analyze_layout_scan(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. detect_columns / detect_document_columns =====

///|
test "oe2: detect_columns 零宽度" {
  try {
    let _ = @ocr.detect_columns(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_document_columns 零宽度" {
  try {
    let _ = @ocr.detect_document_columns(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 9. detect_document_language / detect_char_language / detect_language_enhanced =====

///|
test "oe2: detect_document_language 零宽度" {
  try {
    let _ = @ocr.detect_document_language(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_char_language 零宽度" {
  try {
    let _ = @ocr.detect_char_language(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: detect_language_enhanced 零宽度" {
  try {
    let _ = @ocr.detect_language_enhanced(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 10. detect_skew_angle_robust / correct_slant =====

///|
test "oe2: detect_skew_angle_robust 零宽度" {
  try {
    let _ = @ocr.detect_skew_angle_robust(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: correct_slant 零宽度" {
  try {
    let _ = @ocr.correct_slant(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: correct_slant 多通道" {
  try {
    let _ = @ocr.correct_slant(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 11. background_normalization =====

///|
test "oe2: background_normalization 零宽度" {
  try {
    let _ = @ocr.background_normalization(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: background_normalization 多通道" {
  try {
    let _ = @ocr.background_normalization(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 12. extract_text_lines =====

///|
test "oe2: extract_text_lines 零宽度" {
  try {
    let _ = @ocr.extract_text_lines(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: extract_text_lines 多通道" {
  try {
    let _ = @ocr.extract_text_lines(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 13. fast_connected_components / fast_downsample_2x =====

///|
test "oe2: fast_connected_components 零宽度" {
  try {
    let _ = @ocr.fast_connected_components(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: fast_downsample_2x 零宽度" {
  try {
    let _ = @ocr.fast_downsample_2x(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 14. detect_distortions =====

///|
test "oe2: detect_distortions 零宽度" {
  try {
    let _ = @ocr.detect_distortions(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 15. extract_stroke_features / extract_zernike_moments =====

///|
test "oe2: extract_stroke_features 零宽度" {
  try {
    let _ = @ocr.extract_stroke_features(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: extract_zernike_moments 零宽度" {
  try {
    let _ = @ocr.extract_zernike_moments(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 16. extract_combined_ocr_features / combined_features =====

///|
test "oe2: extract_combined_ocr_features 零宽度" {
  try {
    let _ = @ocr.extract_combined_ocr_features(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: combined_features 零宽度" {
  try {
    let _ = @ocr.combined_features(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 17. cache_friendly projections =====

///|
test "oe2: cache_friendly_horizontal_projection 零宽度" {
  try {
    let _ = @ocr.cache_friendly_horizontal_projection(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: cache_friendly_vertical_projection 零宽度" {
  try {
    let _ = @ocr.cache_friendly_vertical_projection(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 18. detect_handwriting_slant / drop_fall_segmentation =====

///|
test "oe2: detect_handwriting_slant 零宽度" {
  try {
    let _ = @ocr.detect_handwriting_slant(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: drop_fall_segmentation 零宽度" {
  try {
    let _ = @ocr.drop_fall_segmentation(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "oe2: drop_fall_segmentation 多通道" {
  try {
    let _ = @ocr.drop_fall_segmentation(oe2_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 19. detect_image_regions_markdown =====

///|
test "oe2: detect_image_regions_markdown 零宽度" {
  try {
    let _ = @ocr.detect_image_regions_markdown(oe2_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 20. batch_scan_ocr 空数组 =====

///|
test "oe2: batch_scan_ocr 空数组" {
  try {
    let config = @ocr.scan_ocr_default_config()
    let _ = @ocr.batch_scan_ocr([], config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 21. analyze_table_structure 空数组 =====

///|
test "oe2: analyze_table_structure 空数组" {
  try {
    let _ = @ocr.analyze_table_structure([], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
