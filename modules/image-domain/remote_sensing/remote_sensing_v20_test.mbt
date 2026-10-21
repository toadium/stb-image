// v20.0.0 遥感图像增强测试 - remote_sensing 模块
// 植被指数、地物分类、变化检测、纹理特征、光谱分析、质量评估

///|
fn make_band(w : Int32, h : Int32, value : Byte) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, value)),
  }
}

///|
fn make_rs_image(
  w : Int32,
  h : Int32,
  bands : Int32,
) -> @remote_sensing.RemoteSensingImage {
  @remote_sensing.create_default_remote_sensing_image(w, h, bands)
}

///|
test "multispectral_new: 基本创建" {
  let band = make_band(4, 4, b'\x80')
  let ms = @remote_sensing.multispectral_new(4, 4, [band, band, band])
  assert_eq(ms.width, 4)
  assert_eq(ms.height, 4)
  assert_eq(ms.bands.length(), 3)
}

///|
test "compute_ndvi: 基本计算" {
  let nir = make_band(4, 4, b'\xC0')
  let red = make_band(4, 4, b'\x40')
  let ndvi = @remote_sensing.compute_ndvi(nir, red)
  assert_eq(ndvi.width, 4)
  assert_eq(ndvi.height, 4)
  assert_eq(ndvi.channels, 1)
}

///|
test "compute_ndvi: 相同图像" {
  let img = make_band(4, 4, b'\x80')
  let ndvi = @remote_sensing.compute_ndvi(img, img)
  assert_eq(ndvi.width, 4)
  assert_eq(ndvi.height, 4)
}

///|
test "compute_ndwi: 基本计算" {
  let green = make_band(4, 4, b'\xC0')
  let nir = make_band(4, 4, b'\x40')
  let ndwi = @remote_sensing.compute_ndwi(green, nir)
  assert_eq(ndwi.width, 4)
  assert_eq(ndwi.height, 4)
}

///|
test "compute_ndbi: 基本计算" {
  let swir = make_band(4, 4, b'\xC0')
  let nir = make_band(4, 4, b'\x40')
  let ndbi = @remote_sensing.compute_ndbi(swir, nir)
  assert_eq(ndbi.width, 4)
  assert_eq(ndbi.height, 4)
}

///|
test "compute_evi: 基本计算" {
  let nir = make_band(4, 4, b'\xC0')
  let red = make_band(4, 4, b'\x40')
  let blue = make_band(4, 4, b'\x20')
  let evi = @remote_sensing.compute_evi(nir, red, blue)
  assert_eq(evi.width, 4)
  assert_eq(evi.height, 4)
}

///|
test "false_color_composite: 基本合成" {
  let band = make_band(4, 4, b'\x80')
  let result = @remote_sensing.false_color_composite(band, band, band)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
}

///|
test "true_color_composite: 基本合成" {
  let band = make_band(4, 4, b'\x80')
  let result = @remote_sensing.true_color_composite(band, band, band)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
}

///|
test "vegetation_coverage: 基本计算" {
  let ndvi = make_band(4, 4, b'\x80')
  let vc = @remote_sensing.vegetation_coverage(ndvi)
  assert_eq(vc.width, 4)
  assert_eq(vc.height, 4)
}

///|
test "land_cover_classification: 基本分类" {
  let band = make_band(4, 4, b'\x80')
  let result = @remote_sensing.land_cover_classification(band, band, band)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "classification_colormap: 基本着色" {
  let cls = make_band(4, 4, b'\x02')
  let result = @remote_sensing.classification_colormap(cls)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
}

///|
test "create_default_remote_sensing_image: 基本创建" {
  let img = make_rs_image(8, 8, 4)
  assert_eq(img.width, 8)
  assert_eq(img.height, 8)
  assert_eq(img.bands, 4)
  assert_eq(img.data.length(), 256)
}

///|
test "calculate_ndvi: 基本计算" {
  let img = make_rs_image(4, 4, 4)
  let ndvi = @remote_sensing.calculate_ndvi(img, 3, 2)
  assert_eq(ndvi.length(), 16)
}

///|
test "calculate_ndwi: 基本计算" {
  let img = make_rs_image(4, 4, 4)
  let ndwi = @remote_sensing.calculate_ndwi(img, 1, 3)
  assert_eq(ndwi.length(), 16)
}

///|
test "calculate_ndbi: 基本计算" {
  let img = make_rs_image(4, 4, 4)
  let ndbi = @remote_sensing.calculate_ndbi(img, 3, 2)
  assert_eq(ndbi.length(), 16)
}

///|
test "calculate_all_vegetation_indices: 基本计算" {
  let img = make_rs_image(4, 4, 6)
  let indices = @remote_sensing.calculate_all_vegetation_indices(img)
  assert_eq(indices.ndvi.length(), 16)
  assert_eq(indices.ndwi.length(), 16)
  assert_eq(indices.ndbi.length(), 16)
}

///|
test "classify_land_cover_simple: 基本分类" {
  let img = make_rs_image(8, 8, 4)
  let result = @remote_sensing.classify_land_cover_simple(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_true(result.num_classes > 0)
}

///|
test "detect_changes_simple: 基本变化检测" {
  let img1 = make_rs_image(4, 4, 4)
  let img2 = make_rs_image(4, 4, 4)
  let result = @remote_sensing.detect_changes_simple(img1, img2, 0.1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_true(result.change_percentage >= 0.0)
}

///|
test "calculate_texture_features: 基本计算" {
  let img = make_band(4, 4, b'\x80')
  let features = @remote_sensing.calculate_texture_features(img, 2, 2, 3)
  assert_true(features.contrast >= 0.0)
  assert_true(features.energy >= 0.0)
}

///|
test "calculate_spectral_signature: 基本计算" {
  let img = make_rs_image(4, 4, 4)
  let sig = @remote_sensing.calculate_spectral_signature(img, 0, 0)
  assert_true(sig.num_bands > 0)
}

///|
test "calculate_remote_sensing_quality: 基本评估" {
  let img = make_rs_image(8, 8, 4)
  let quality = @remote_sensing.calculate_remote_sensing_quality(img)
  assert_true(quality.overall_quality >= 0.0)
}

///|
test "remote_sensing_report_to_string: 报告生成" {
  let img = make_rs_image(8, 8, 4)
  let classification = @remote_sensing.classify_land_cover_simple(img)
  let changes = @remote_sensing.detect_changes_simple(img, img, 0.1)
  let quality = @remote_sensing.calculate_remote_sensing_quality(img)
  let report = @remote_sensing.remote_sensing_report_to_string(
    img, classification, changes, quality,
  )
  assert_true(report.length() > 0)
}
