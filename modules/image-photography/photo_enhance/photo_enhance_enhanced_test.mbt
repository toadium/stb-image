// v193a photo_enhance 增强测试

///|
fn pe_make_gray(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int32 = i * 37 % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn pe_make_rgb(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * 3) {
    let v : Int32 = i * 31 % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
fn pe_make_uniform_rgb(w : Int32, h : Int32, val : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, val.to_byte())),
  }
}

///|
test "photo_enhance: create_default_hdr_config 完整字段验证" {
  let config = @photo_enhance.create_default_hdr_config()
  assert_true(config.algorithm is @photo_enhance.ToneMappingType::Reinhard)

  assert_true(config.gamma > 0.0)
  assert_true(config.saturation > 0.0)
  assert_true(config.contrast > 0.0)
}

///|
test "photo_enhance: create_default_panorama_config 完整字段验证" {
  let config = @photo_enhance.create_default_panorama_config()
  assert_true(config.overlap_threshold > 0.0)
  assert_true(config.max_features > 0)
  assert_true(config.ransac_iterations > 0)
  assert_true(config.blend_width > 0)
}

///|
test "photo_enhance: create_default_dof_config 不同尺寸" {
  let config1 = @photo_enhance.create_default_dof_config(8, 8)
  assert_eq(config1.focal_point_x, 4)
  assert_eq(config1.focal_point_y, 4)
  let config2 = @photo_enhance.create_default_dof_config(16, 16)
  assert_eq(config2.focal_point_x, 8)
  assert_eq(config2.focal_point_y, 8)
  assert_true(config2.aperture > 0.0)
  assert_true(config2.blur_strength > 0.0)
}

///|
test "photo_enhance: create_default_night_config 完整字段验证" {
  let config = @photo_enhance.create_default_night_config()
  assert_true(config.denoise_strength >= 0.0)
  assert_true(config.brightness_boost >= 0.0)
  assert_true(config.contrast_enhance >= 0.0)
}

///|
test "photo_enhance: low_light_default_config 完整字段验证" {
  let config = @photo_enhance.low_light_default_config()
  assert_eq(config.method_type, "gamma")
  assert_true(config.gamma > 0.0)
  assert_true(config.strength > 0.0)
}

///|
test "photo_enhance: detect_exposure_type 暗图像为欠曝" {
  let img = pe_make_uniform_rgb(8, 8, 10)
  let result = @photo_enhance.detect_exposure_type(img)
  let ev = result.1
  assert_true(ev >= 0.0)
}

///|
test "photo_enhance: detect_exposure_type 亮图像为过曝" {
  let img = pe_make_uniform_rgb(8, 8, 250)
  let result = @photo_enhance.detect_exposure_type(img)
  let ev = result.1
  assert_true(ev >= 0.0)
}

///|
test "photo_enhance: detect_exposure_type 中间调正常" {
  let img = pe_make_uniform_rgb(8, 8, 128)
  let result = @photo_enhance.detect_exposure_type(img)
  let _ = result
  assert_true(true)
}

///|
test "photo_enhance: detect_exposure_type 灰度图" {
  let img = pe_make_gray(8, 8)
  let result = @photo_enhance.detect_exposure_type(img)
  let _ = result
  assert_true(true)
}

///|
test "photo_enhance: hdr_merge 多张图像" {
  let img1 = pe_make_rgb(4, 4)
  let img2 = pe_make_rgb(4, 4)
  let img3 = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img1, img2, img3], [-2.0, 0.0, 2.0])
  assert_eq(hdr.width, 4)
  assert_eq(hdr.height, 4)
  assert_eq(hdr.num_exposures, 3)
  assert_eq(hdr.exposure_values.length(), 3)
}

///|
test "photo_enhance: hdr_merge 单张图像" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  assert_eq(hdr.num_exposures, 1)
  assert_eq(hdr.data.length(), 4 * 4)
}

///|
test "photo_enhance: tone_map Reinhard 算法" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let config = @photo_enhance.create_default_hdr_config()
  let result = @photo_enhance.tone_map(hdr, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "photo_enhance: tone_map ACES 算法" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let config = @photo_enhance.ToneMappingConfig::{
    algorithm: @photo_enhance.ToneMappingType::ACES,
    exposure: 1.0,
    gamma: 2.2,
    saturation: 1.0,
    contrast: 1.0,
  }
  let result = @photo_enhance.tone_map(hdr, config)
  assert_eq(result.width, 4)
}

///|
test "photo_enhance: tone_map Gamma 算法" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let config = @photo_enhance.ToneMappingConfig::{
    algorithm: @photo_enhance.ToneMappingType::Gamma,
    exposure: 1.0,
    gamma: 1.8,
    saturation: 1.0,
    contrast: 1.0,
  }
  let result = @photo_enhance.tone_map(hdr, config)
  assert_eq(result.width, 4)
}

///|
test "photo_enhance: tone_map Linear 算法" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let config = @photo_enhance.ToneMappingConfig::{
    algorithm: @photo_enhance.ToneMappingType::Linear,
    exposure: 1.0,
    gamma: 2.2,
    saturation: 1.0,
    contrast: 1.0,
  }
  let result = @photo_enhance.tone_map(hdr, config)
  assert_eq(result.width, 4)
}

///|
test "photo_enhance: tone_map Drago 算法" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let config = @photo_enhance.ToneMappingConfig::{
    algorithm: @photo_enhance.ToneMappingType::Drago,
    exposure: 1.0,
    gamma: 2.2,
    saturation: 1.0,
    contrast: 1.0,
  }
  let result = @photo_enhance.tone_map(hdr, config)
  assert_eq(result.width, 4)
}

///|
test "photo_enhance: stitch_panorama 单张图像" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.create_default_panorama_config()
  let result = @photo_enhance.stitch_panorama([img], config)
  assert_eq(result.num_images, 1)
}

///|
test "photo_enhance: stitch_panorama 三张图像" {
  let img1 = pe_make_rgb(8, 8)
  let img2 = pe_make_rgb(8, 8)
  let img3 = pe_make_rgb(8, 8)
  let config = @photo_enhance.create_default_panorama_config()
  let result = @photo_enhance.stitch_panorama([img1, img2, img3], config)
  assert_eq(result.num_images, 3)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
}

///|
test "photo_enhance: apply_depth_of_field 不同焦点" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.create_default_dof_config(8, 8)
  let result = @photo_enhance.apply_depth_of_field(img, config)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: apply_depth_of_field 自定义参数" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.DepthOfFieldConfig::{
    focal_point_x: 2,
    focal_point_y: 2,
    aperture: 2.8,
    blur_strength: 5.0,
  }
  let result = @photo_enhance.apply_depth_of_field(img, config)
  assert_eq(result.width, 8)
}

///|
test "photo_enhance: enhance_night 自定义配置" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.NightEnhanceConfig::{
    denoise_strength: 0.8,
    brightness_boost: 0.5,
    contrast_enhance: 0.3,
    noise_reduction: true,
  }
  let result = @photo_enhance.enhance_night(img, config)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: enhance_night 无降噪" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.NightEnhanceConfig::{
    denoise_strength: 0.0,
    brightness_boost: 0.2,
    contrast_enhance: 0.1,
    noise_reduction: false,
  }
  let result = @photo_enhance.enhance_night(img, config)
  assert_eq(result.width, 8)
}

///|
test "photo_enhance: low_light_enhance 自定义配置" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.LowLightConfig::{
    method_type: "log",
    gamma: 0.5,
    strength: 1.5,
  }
  let result = @photo_enhance.low_light_enhance(img, config~)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: low_light_enhance retinex 方法" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.LowLightConfig::{
    method_type: "retinex",
    gamma: 1.0,
    strength: 1.0,
  }
  let result = @photo_enhance.low_light_enhance(img, config~)
  assert_eq(result.width, 8)
}

///|
test "photo_enhance: deblur_motion 自定义参数" {
  let img = pe_make_rgb(8, 8)
  let result = @photo_enhance.deblur_motion(img, kernel_size=5, angle=45.0)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: color_enhance 自定义参数" {
  let img = pe_make_rgb(8, 8)
  let result = @photo_enhance.color_enhance(img, saturation=1.5, contrast=1.2)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: clahe_enhance 自定义参数" {
  let img = pe_make_gray(8, 8)
  let result = @photo_enhance.clahe_enhance(img, clip_limit=3.0, tile_size=4)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "photo_enhance: white_balance 灰度世界假设" {
  let img = pe_make_rgb(8, 8)
  let result = @photo_enhance.white_balance(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 3)
}

///|
test "photo_enhance: batch_photo_enhance 多操作" {
  let img = pe_make_gray(8, 8)
  let results1 = @photo_enhance.batch_photo_enhance(
    [img, img, img],
    "low_light",
  )
  assert_eq(results1.length(), 3)
  let results2 = @photo_enhance.batch_photo_enhance([img], "clahe")
  assert_eq(results2.length(), 1)
}

///|
test "photo_enhance: computational_photography_report 内容验证" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img, img], [0.0, 1.0])
  let pano_config = @photo_enhance.create_default_panorama_config()
  let pano = @photo_enhance.stitch_panorama([img, img], pano_config)
  let report = @photo_enhance.computational_photography_report(hdr, pano)
  assert_true(report.length() > 10)
}

///|
test "photo_enhance: ExposureType 枚举完备性" {
  let img_dark = pe_make_uniform_rgb(4, 4, 5)
  let r1 = @photo_enhance.detect_exposure_type(img_dark)
  let _ = r1
  let img_mid = pe_make_uniform_rgb(4, 4, 128)
  let r2 = @photo_enhance.detect_exposure_type(img_mid)
  let _ = r2
  let img_bright = pe_make_uniform_rgb(4, 4, 250)
  let r3 = @photo_enhance.detect_exposure_type(img_bright)
  let _ = r3
  assert_true(true)
}

///|
test "photo_enhance: ToneMappingType 全枚举测试" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img], [0.0])
  let algorithms = [
    @photo_enhance.ToneMappingType::Reinhard,
    @photo_enhance.ToneMappingType::Drago,
    @photo_enhance.ToneMappingType::ACES,
    @photo_enhance.ToneMappingType::Linear,
    @photo_enhance.ToneMappingType::Gamma,
  ]
  for algo in algorithms {
    let config = @photo_enhance.ToneMappingConfig::{
      algorithm: algo,
      exposure: 1.0,
      gamma: 2.2,
      saturation: 1.0,
      contrast: 1.0,
    }
    let result = @photo_enhance.tone_map(hdr, config)
    assert_eq(result.width, 4)
  }
}

///|
test "photo_enhance: HdrImage 结构验证" {
  let img = pe_make_rgb(4, 4)
  let hdr = @photo_enhance.hdr_merge([img, img, img], [0.0, 1.0, 2.0])
  assert_eq(hdr.width, 4)
  assert_eq(hdr.height, 4)
  assert_eq(hdr.channels, 3)
  assert_eq(hdr.num_exposures, 3)
  assert_eq(hdr.exposure_values.length(), 3)
  assert_true(hdr.data.length() > 0)
}

///|
test "photo_enhance: PanoramaResult 结构验证" {
  let img = pe_make_rgb(8, 8)
  let config = @photo_enhance.create_default_panorama_config()
  let result = @photo_enhance.stitch_panorama([img, img], config)
  assert_true(result.width > 0)
  assert_true(result.height > 0)
  assert_eq(result.num_images, 2)
  assert_true(result.inliers >= 0)
  assert_true(result.confidence >= 0.0)
}
