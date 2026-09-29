// v44.0.0 计算摄影增强 + 照片增强测试

///|
test "create_default_hdr_config: 基本测试" {
  let config = create_default_hdr_config()
  assert_true(config.algorithm is ToneMappingType::Reinhard)
  assert_eq(config.gamma, 2.2)
}

///|
test "create_default_panorama_config: 基本测试" {
  let config = create_default_panorama_config()
  assert_eq(config.max_features, 500)
  assert_eq(config.blend_width, 50)
}

///|
test "create_default_dof_config: 基本测试" {
  let config = create_default_dof_config(8, 8)
  assert_eq(config.focal_point_x, 4)
  assert_eq(config.focal_point_y, 4)
}

///|
test "create_default_night_config: 基本测试" {
  let config = create_default_night_config()
  assert_eq(config.denoise_strength, 0.5)
  assert_eq(config.brightness_boost, 0.3)
}

///|
test "detect_exposure_type: 基本测试" {
  let img = make_test_image(4, 4)
  let result = detect_exposure_type(img)
  let ev = result.1
  assert_true(ev >= 0.0)
}

///|
test "hdr_merge: 基本测试" {
  let img1 = make_test_image(4, 4)
  let img2 = make_test_image(4, 4)
  let hdr = hdr_merge([img1, img2], [0.0, 1.0])
  assert_eq(hdr.width, 4)
  assert_eq(hdr.num_exposures, 2)
}

///|
test "tone_map: 基本测试" {
  let img = make_test_image(4, 4)
  let hdr = hdr_merge([img], [0.0])
  let config = create_default_hdr_config()
  let result = tone_map(hdr, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "stitch_panorama : 基本测试" {
  let img1 = make_test_image(4, 4)
  let img2 = make_test_image(4, 4)
  let config = create_default_panorama_config()
  let result = stitch_panorama([img1, img2], config)
  assert_eq(result.num_images, 2)
  assert_eq(result.width, 8)
}

///|
test "apply_depth_of_field: 基本测试" {
  let img = make_test_image(4, 4)
  let config = create_default_dof_config(4, 4)
  let result = apply_depth_of_field(img, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "enhance_night: 基本测试" {
  let img = make_test_image(4, 4)
  let config = create_default_night_config()
  let result = enhance_night(img, config)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "computational_photography_report: 基本测试" {
  let img = make_test_image(4, 4)
  let hdr = hdr_merge([img], [0.0])
  let pano_config = create_default_panorama_config()
  let pano = stitch_panorama([img], pano_config)
  let report = computational_photography_report(hdr, pano)
  assert_true(report.length() > 0)
}

///|
test "low_light_default_config: 基本测试" {
  let config = low_light_default_config()
  assert_eq(config.method_type, "gamma")
}

///|
test "low_light_enhance: 基本测试" {
  let img = make_test_image(4, 4)
  let result = low_light_enhance(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "deblur_motion: 基本测试" {
  let img = make_test_image(4, 4)
  let result = deblur_motion(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "color_enhance: 基本测试" {
  let img = make_rgb_test_image(4, 4)
  let result = color_enhance(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "clahe_enhance: 基本测试" {
  let img = make_test_image(4, 4)
  let result = clahe_enhance(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "white_balance: 基本测试" {
  let img = make_rgb_test_image(4, 4)
  let result = white_balance(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "batch_photo_enhance: 基本测试" {
  let img = make_test_image(4, 4)
  let results = batch_photo_enhance([img, img], "low_light")
  assert_eq(results.length(), 2)
}

///|
fn make_test_image(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int = i % 256
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
fn make_rgb_test_image(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * 3) {
    let v : Int = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}
