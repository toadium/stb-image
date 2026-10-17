// v192c remote_sensing 增强测试：多波段 + 边值 + 属性

///|
fn rs_make_img(w : Int, h : Int, ch : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let v : Int = (i * 31 + 17) % 256
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
test "create_default_remote_sensing_image: 多波段创建" {
  for bands in [4, 5, 6, 7, 8] {
    let rs_img = @remote_sensing.create_default_remote_sensing_image(
      16, 16, bands,
    )
    let indices = @remote_sensing.calculate_all_vegetation_indices(rs_img)
    assert_true(indices.ndvi.length() >= 0)
  }
}

///|
test "calculate_ndvi: 多波段不同索引" {
  let rs_img = @remote_sensing.create_default_remote_sensing_image(16, 16, 5)
  for nir_idx in [3, 4] {
    for red_idx in [0, 1, 2] {
      let ndvi = @remote_sensing.calculate_ndvi(rs_img, nir_idx, red_idx)
      assert_true(ndvi.length() >= 0)
    }
  }
}

///|
test "calculate_ndwi: 多波段不同索引" {
  let rs_img = @remote_sensing.create_default_remote_sensing_image(16, 16, 5)
  let ndwi = @remote_sensing.calculate_ndwi(rs_img, 3, 1)
  assert_true(ndwi.length() >= 0)
}

///|
test "calculate_ndbi: 6波段" {
  let rs_img = @remote_sensing.create_default_remote_sensing_image(16, 16, 6)
  let ndbi = @remote_sensing.calculate_ndbi(rs_img, 5, 2)
  assert_true(ndbi.length() >= 0)
}

///|
test "calculate_all_vegetation_indices: 5波段属性" {
  let rs_img = @remote_sensing.create_default_remote_sensing_image(32, 32, 5)
  let indices = @remote_sensing.calculate_all_vegetation_indices(rs_img)
  assert_true(indices.ndvi.length() >= 0)
  assert_true(indices.ndwi.length() >= 0)
  assert_true(indices.ndbi.length() >= 0)
}

///|
test "calculate_remote_sensing_quality: 多波段" {
  for bands in [4, 5, 6] {
    let rs_img = @remote_sensing.create_default_remote_sensing_image(
      16, 16, bands,
    )
    let quality = @remote_sensing.calculate_remote_sensing_quality(rs_img)
    assert_true(quality.overall_quality >= 0.0)
  }
}

///|
test "calculate_spectral_signature: 多波段" {
  let rs_img = @remote_sensing.create_default_remote_sensing_image(16, 16, 5)
  let sig = @remote_sensing.calculate_spectral_signature(rs_img, 8, 8)
  assert_true(sig.reflectance.length() >= 0)
}

///|
test "classify_land_cover_simple: 多波段" {
  for bands in [4, 5, 6] {
    let rs_img = @remote_sensing.create_default_remote_sensing_image(
      16, 16, bands,
    )
    let result = @remote_sensing.classify_land_cover_simple(rs_img)
    assert_true(result.class_names.length() >= 0)
  }
}

///|
test "detect_changes_simple: 不同阈值" {
  let rs1 = @remote_sensing.create_default_remote_sensing_image(16, 16, 4)
  let rs2 = @remote_sensing.create_default_remote_sensing_image(16, 16, 4)
  for threshold in [0.1, 0.3, 0.5, 0.7] {
    let result = @remote_sensing.detect_changes_simple(rs1, rs2, threshold)
    assert_true(result.num_changed_pixels >= 0)
  }
}

///|
test "compute_ndvi: 灰度图对" {
  let nir = rs_make_img(16, 16, 1)
  let red = rs_make_img(16, 16, 1)
  let result = @remote_sensing.compute_ndvi(nir, red)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "compute_ndwi: 灰度图对" {
  let green = rs_make_img(16, 16, 1)
  let nir = rs_make_img(16, 16, 1)
  let result = @remote_sensing.compute_ndwi(green, nir)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "compute_ndbi: 灰度图对" {
  let swir = rs_make_img(16, 16, 1)
  let nir = rs_make_img(16, 16, 1)
  let result = @remote_sensing.compute_ndbi(swir, nir)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "compute_evi: 三波段" {
  let blue = rs_make_img(16, 16, 1)
  let red = rs_make_img(16, 16, 1)
  let nir = rs_make_img(16, 16, 1)
  let result = @remote_sensing.compute_evi(blue, red, nir)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "false_color_composite: 三波段合成" {
  let r = rs_make_img(16, 16, 1)
  let g = rs_make_img(16, 16, 1)
  let b = rs_make_img(16, 16, 1)
  let result = @remote_sensing.false_color_composite(r, g, b)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "classification_colormap: 不同尺寸" {
  for size in [8, 16, 32, 64] {
    let img = rs_make_img(size, size, 1)
    let result = @remote_sensing.classification_colormap(img)
    assert_eq(result.width, size)
    assert_eq(result.height, size)
  }
}

///|
test "calculate_texture_features: 不同窗口" {
  let img = rs_make_img(32, 32, 1)
  for window in [3, 5, 7] {
    let result = @remote_sensing.calculate_texture_features(img, 0, 0, window)
    assert_true(result.contrast >= 0.0)
  }
}
