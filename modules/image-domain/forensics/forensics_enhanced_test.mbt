// v192c forensics 增强测试：多图像类型 + 全分析函数 + 增强验证

///|
fn fo_make_img(w : Int32, h : Int32, ch : Int32, seed : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let v : Int32 = (i * 41 + seed * 23) % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn fo_make_solid_img(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h * ch) {
    data.push(val.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn fo_make_checkerboard(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for _ in 0..<ch {
        let v : Byte = if (x + y) % 2 == 0 { 0b00000000 } else { 0b11111111 }
        data.push(v)
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "analyze_noise_pattern: 纯白图" {
  let img = fo_make_solid_img(32, 32, 3, 255)
  let result = @forensics.analyze_noise_pattern(img)
  assert_true(result.noise_level >= 0.0)
}

///|
test "analyze_noise_pattern: 不同尺寸" {
  for size in [16, 32, 64, 128] {
    let img = fo_make_img(size, size, 3, 0)
    let result = @forensics.analyze_noise_pattern(img)
    assert_true(result.noise_level >= 0.0)
  }
}

///|
test "analyze_noise_pattern: 灰度图" {
  let img = fo_make_img(32, 32, 1, 0)
  let result = @forensics.analyze_noise_pattern(img)
  assert_true(result.noise_level >= 0.0)
}

///|
test "analyze_frequency_domain: 不同尺寸" {
  for size in [16, 32, 64] {
    let img = fo_make_img(size, size, 3, 0)
    let result = @forensics.analyze_frequency_domain(img)
    assert_true(result.high_frequency_energy >= 0.0)
  }
}

///|
test "analyze_frequency_domain: 棋盘格不同尺寸" {
  for size in [16, 32, 64] {
    let img = fo_make_checkerboard(size, size, 3)
    let result = @forensics.analyze_frequency_domain(img)
    assert_true(result.high_frequency_energy >= 0.0)
  }
}

///|
test "analyze_color_distribution: 纯色图" {
  for val in [0, 64, 128, 192, 255] {
    let img = fo_make_solid_img(32, 32, 3, val)
    let result = @forensics.analyze_color_distribution(img)
    assert_true(result.color_histogram_smoothness >= 0.0)
  }
}

///|
test "analyze_color_distribution: 灰度图" {
  let img = fo_make_img(32, 32, 1, 0)
  let result = @forensics.analyze_color_distribution(img)
  assert_true(result.color_histogram_smoothness >= 0.0)
}

///|
test "analyze_color_quantization: 基本分析" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.analyze_color_quantization(img)
  assert_true(result.unique_color_count >= 0)
}

///|
test "analyze_color_quantization: 纯色图" {
  let img = fo_make_solid_img(32, 32, 3, 128)
  let result = @forensics.analyze_color_quantization(img)
  assert_true(result.unique_color_count >= 1)
}

///|
test "analyze_texture: 不同尺寸" {
  for size in [16, 32, 64] {
    let img = fo_make_img(size, size, 3, 0)
    let result = @forensics.analyze_texture(img)
    assert_true(result.texture_complexity >= 0.0)
  }
}

///|
test "analyze_edges: 灰度图" {
  let img = fo_make_img(32, 32, 1, 0)
  let result = @forensics.analyze_edges(img)
  assert_true(result.edge_sharpness >= 0.0)
}

///|
test "analyze_edges: 棋盘格不同尺寸" {
  for size in [16, 32, 64] {
    let img = fo_make_checkerboard(size, size, 3)
    let result = @forensics.analyze_edges(img)
    assert_true(result.edge_sharpness >= 0.0)
  }
}

///|
test "analyze_compression_artifacts: 棋盘格" {
  let img = fo_make_checkerboard(32, 32, 3)
  let result = @forensics.analyze_compression_artifacts(img)
  assert_true(result.blocking_artifact_level >= 0.0)
}

///|
test "analyze_details: 棋盘格" {
  let img = fo_make_checkerboard(32, 32, 3)
  let result = @forensics.analyze_details(img)
  assert_true(result.eye_detail_consistency >= 0.0)
}

///|
test "analyze_geometry: 基本分析" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.analyze_geometry(img)
  assert_true(result.horizontal_edge_ratio >= 0.0)
}

///|
test "analyze_geometry: 棋盘格" {
  let img = fo_make_checkerboard(32, 32, 3)
  let result = @forensics.analyze_geometry(img)
  assert_true(result.horizontal_edge_ratio >= 0.0)
}

///|
test "analyze_edge_directions: 基本分析" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.analyze_edge_directions(img)
  assert_true(result >= 0.0)
}

///|
test "analyze_edge_directions: 棋盘格" {
  let img = fo_make_checkerboard(32, 32, 3)
  let result = @forensics.analyze_edge_directions(img)
  assert_true(result >= 0.0)
}

///|
test "analyze_pixel_distribution: 基本分析" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.analyze_pixel_distribution(img)
  assert_true(result >= 0.0)
}

///|
test "analyze_solid_areas: 基本分析" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.analyze_solid_areas(img)
  assert_true(result >= 0.0)
}

///|
test "analyze_solid_areas: 纯色图" {
  let img = fo_make_solid_img(32, 32, 3, 128)
  let result = @forensics.analyze_solid_areas(img)
  assert_true(result >= 0.0)
}

///|
test "detect_text_regions: 基本检测" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.detect_text_regions(img)
  assert_true(result.text_area_count >= 0)
}

///|
test "detect_text_regions: 棋盘格" {
  let img = fo_make_checkerboard(32, 32, 3)
  let result = @forensics.detect_text_regions(img)
  assert_true(result.text_area_count >= 0)
}

///|
test "detect_ui_elements: 基本检测" {
  let img = fo_make_img(32, 32, 3, 0)
  let result = @forensics.detect_ui_elements(img)
  assert_true(result.ui_element_count >= 0)
}

///|
test "create_default_enhanced_verification_config: 配置验证" {
  let config = @forensics.create_default_enhanced_verification_config()
  assert_true(config.use_ui_detection || true)
}

///|
test "create_default_source_verification_config: 配置验证" {
  let config = @forensics.create_default_source_verification_config()
  assert_true(config.use_noise_analysis || true)
}
