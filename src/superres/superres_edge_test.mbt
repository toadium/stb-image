// v239 superres 错误路径+缺失函数测试

///|
fn sr_edge_mk_img(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, (val & 0xFF).to_byte())),
  }
}

///|
fn sr_edge_mk_varied(w : Int32, h : Int32) -> @types.Image {
  let arr : Array[Byte] = []
  for i in 0..<(w * h) {
    arr.push((i % 256).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(arr),
  }
}

// ==================== calculate_image_quality_metrics ====================

///|
test "sr_edge: calculate_image_quality_metrics 相同图像" {
  let img = sr_edge_mk_varied(4, 4)
  let m = @superres.calculate_image_quality_metrics(img, img)
  assert_true(m.psnr >= 0.0)
  assert_true(m.ssim >= 0.0)
  assert_true(m.mse >= 0.0)
  assert_true(m.mae >= 0.0)
}

///|
test "sr_edge: calculate_image_quality_metrics 不同图像" {
  let img1 = sr_edge_mk_img(4, 4, 1, 100)
  let img2 = sr_edge_mk_img(4, 4, 1, 200)
  let m = @superres.calculate_image_quality_metrics(img1, img2)
  assert_true(m.mse > 0.0)
  assert_true(m.mae > 0.0)
}

///|
test "sr_edge: calculate_image_quality_metrics 单像素" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let m = @superres.calculate_image_quality_metrics(img, img)
  assert_true(m.psnr >= 0.0)
}

// ==================== enhance_image ====================

///|
test "sr_edge: enhance_image 默认配置" {
  let img = sr_edge_mk_varied(4, 4)
  let config = @superres.create_default_enhancement_config()
  let result = @superres.enhance_image(img, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 1)
}

///|
test "sr_edge: enhance_image 自定义配置" {
  let img = sr_edge_mk_varied(4, 4)
  let config = @superres.EnhancementConfig::{
    brightness: 1.2,
    contrast: 1.1,
    saturation: 1.0,
    sharpness: 0.5,
    denoise: 0.1,
    gamma: 1.0,
    use_clahe: false,
    clahe_clip_limit: 2.0,
    clahe_tile_size: 8,
  }
  let result = @superres.enhance_image(img, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "sr_edge: enhance_image 单像素" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let config = @superres.create_default_enhancement_config()
  let result = @superres.enhance_image(img, config)
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
}

// ==================== super_resolution_report_to_string ====================

///|
test "sr_edge: super_resolution_report_to_string 报告生成" {
  let img = sr_edge_mk_varied(4, 4)
  let config = @superres.create_default_interpolation_config()
  let result = @superres.super_resolve(img, config)
  let metrics = @superres.calculate_image_quality_metrics(img, result.image)
  let report = @superres.super_resolution_report_to_string(result, metrics)
  assert_true(report.length() > 0)
}

// ==================== 错误路径: 零宽度/高度 ====================

///|
test "sr_edge: super_resolution_bicubic 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.super_resolution_bicubic(img, 2.0)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: bilinear_interpolate 零高度" {
  let img = sr_edge_mk_img(4, 0, 1, 128)
  let result = @superres.bilinear_interpolate(img, 2.0)
  assert_eq(result.height, 0)
}

///|
test "sr_edge: nearest_neighbor_interpolate 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.nearest_neighbor_interpolate(img, 2.0)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: bicubic_interpolate 零高度" {
  let img = sr_edge_mk_img(4, 0, 1, 128)
  let result = @superres.bicubic_interpolate(img, 2.0)
  assert_eq(result.height, 0)
}

///|
test "sr_edge: upscale_2x 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.upscale_2x(img)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: upscale_4x 零高度" {
  let img = sr_edge_mk_img(4, 0, 1, 128)
  let result = @superres.upscale_4x(img)
  assert_eq(result.height, 0)
}

///|
test "sr_edge: super_resolution 零宽度默认配置" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.super_resolution(img)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: super_resolution_lanczos 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.super_resolution_lanczos(img, 2.0)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: super_resolution_edge_preserving 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.super_resolution_edge_preserving(img, 2.0)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: sharpen_image 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.sharpen_image(img, 0.5)
  assert_eq(result.width, 0)
}

///|
test "sr_edge: denoise_image 零宽度" {
  let img = sr_edge_mk_img(0, 4, 1, 128)
  let result = @superres.denoise_image(img, 0.5)
  assert_eq(result.width, 0)
}

// ==================== 边界条件: 单像素 ====================

///|
test "sr_edge: super_resolution_bicubic 单像素" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let result = @superres.super_resolution_bicubic(img, 2.0)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "sr_edge: upscale_2x 单像素" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let result = @superres.upscale_2x(img)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}

///|
test "sr_edge: super_resolve 单像素最近邻" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let config = @superres.InterpolationConfig::{
    algorithm: @superres.SuperResolutionAlgorithm::NearestNeighbor,
    scale_factor: 2.0,
    use_edge_preservation: false,
    sharpening_strength: 0.0,
    denoise_strength: 0.0,
  }
  let result = @superres.super_resolve(img, config)
  assert_eq(result.output_width, 2)
  assert_eq(result.output_height, 2)
}

///|
test "sr_edge: super_resolve 单像素双三次" {
  let img = sr_edge_mk_img(1, 1, 1, 128)
  let config = @superres.InterpolationConfig::{
    algorithm: @superres.SuperResolutionAlgorithm::Bicubic,
    scale_factor: 3.0,
    use_edge_preservation: false,
    sharpening_strength: 0.0,
    denoise_strength: 0.0,
  }
  let result = @superres.super_resolve(img, config)
  assert_eq(result.output_width, 3)
  assert_eq(result.output_height, 3)
}

// ==================== 多通道 ====================

///|
test "sr_edge: super_resolution_bicubic 多通道" {
  let img = sr_edge_mk_img(4, 4, 3, 128)
  let result = @superres.super_resolution_bicubic(img, 2.0)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 3)
}

///|
test "sr_edge: upscale_2x 多通道" {
  let img = sr_edge_mk_img(4, 4, 3, 128)
  let result = @superres.upscale_2x(img)
  assert_eq(result.width, 8)
  assert_eq(result.channels, 3)
}

///|
test "sr_edge: enhance_image 多通道" {
  let img = sr_edge_mk_img(4, 4, 3, 128)
  let config = @superres.create_default_enhancement_config()
  let result = @superres.enhance_image(img, config)
  assert_eq(result.width, 4)
  assert_eq(result.channels, 3)
}
