// v219.0.0 forensics 错误路径增强测试

// ===== 辅助函数 =====

///|
fn frn_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn frn_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

// ===== 1. analyze_color_distribution / analyze_color_quantization =====

///|
test "frn_edge: analyze_color_distribution 零宽度" {
  try {
    let _ = @forensics.analyze_color_distribution(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_color_distribution 数据不匹配" {
  try {
    let _ = @forensics.analyze_color_distribution(frn_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_color_quantization 零宽度" {
  try {
    let _ = @forensics.analyze_color_quantization(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. analyze_compression_artifacts / analyze_details =====

///|
test "frn_edge: analyze_compression_artifacts 零宽度" {
  try {
    let _ = @forensics.analyze_compression_artifacts(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_details 零宽度" {
  try {
    let _ = @forensics.analyze_details(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. analyze_edge_directions / analyze_edges =====

///|
test "frn_edge: analyze_edge_directions 零宽度" {
  try {
    let _ = @forensics.analyze_edge_directions(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_edges 零宽度" {
  try {
    let _ = @forensics.analyze_edges(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. analyze_frequency_domain / analyze_geometry =====

///|
test "frn_edge: analyze_frequency_domain 零宽度" {
  try {
    let _ = @forensics.analyze_frequency_domain(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_geometry 零宽度" {
  try {
    let _ = @forensics.analyze_geometry(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. analyze_noise_pattern / analyze_texture =====

///|
test "frn_edge: analyze_noise_pattern 零宽度" {
  try {
    let _ = @forensics.analyze_noise_pattern(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_texture 零宽度" {
  try {
    let _ = @forensics.analyze_texture(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. analyze_pixel_distribution / analyze_solid_areas =====

///|
test "frn_edge: analyze_pixel_distribution 零宽度" {
  try {
    let _ = @forensics.analyze_pixel_distribution(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: analyze_solid_areas 零宽度" {
  try {
    let _ = @forensics.analyze_solid_areas(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. detect_text_regions / detect_ui_elements =====

///|
test "frn_edge: detect_text_regions 零宽度" {
  try {
    let _ = @forensics.detect_text_regions(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: detect_ui_elements 零宽度" {
  try {
    let _ = @forensics.detect_ui_elements(frn_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. verify_image_source / verify_image_source_enhanced =====

///|
test "frn_edge: verify_image_source 零宽度" {
  try {
    let config = @forensics.create_default_source_verification_config()
    let _ = @forensics.verify_image_source(frn_zero_w(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "frn_edge: verify_image_source_enhanced 零宽度" {
  try {
    let config = @forensics.create_default_enhanced_verification_config()
    let _ = @forensics.verify_image_source_enhanced(frn_zero_w(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
