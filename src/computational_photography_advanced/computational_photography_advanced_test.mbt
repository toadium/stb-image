// v44.0.0 计算摄影高级测试

///|
test "create_default_computational_photography_config: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  assert_true(
    config.task_type
    is @computational_photography_advanced.ComputationalPhotographyTaskType::HDRImaging,
  )
  assert_eq(config.gamma, 2.2)
}

///|
test "create_hdr_image: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let exposures = [make_double_image(4, 4), make_double_image(4, 4)]
  let exposure_values = [0.0, 1.0]
  let hdr = @computational_photography_advanced.create_hdr_image(
    exposures, exposure_values, 4, 4, config,
  )
  assert_eq(hdr.width, 4)
  assert_eq(hdr.height, 4)
  assert_eq(hdr.num_exposures, 2)
}

///|
test "tone_map_hdr: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let exposures = [make_double_image(4, 4)]
  let exposure_values = [0.0]
  let hdr = @computational_photography_advanced.create_hdr_image(
    exposures, exposure_values, 4, 4, config,
  )
  let ldr = @computational_photography_advanced.tone_map_hdr(hdr, config)
  assert_true(ldr.length() > 0)
}

///|
test "stitch_panorama : 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let images = [make_double_image(4, 4), make_double_image(4, 4)]
  let pano = @computational_photography_advanced.stitch_panorama(
    images, 4, 4, config,
  )
  assert_eq(pano.width, 8)
  assert_eq(pano.num_input_images, 2)
}

///|
test "focus_stack: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let images = [make_double_image(4, 4), make_double_image(4, 4)]
  let result = @computational_photography_advanced.focus_stack(
    images, 4, 4, config,
  )
  assert_eq(result.width, 4)
  assert_eq(result.num_input_images, 2)
}

///|
test "multi_frame_denoise: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let frames = [make_double_image(4, 4), make_double_image(4, 4)]
  let result = @computational_photography_advanced.multi_frame_denoise(
    frames, 4, 4, config,
  )
  assert_eq(result.width, 4)
  assert_eq(result.num_input_frames, 2)
}

///|
test "deblur_image: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let image = make_double_image(4, 4)
  let result = @computational_photography_advanced.deblur_image(
    image, 4, 4, config,
  )
  assert_eq(result.width, 4)
  assert_eq(result.kernel_size, 5)
}

///|
test "dehaze_image: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let image = make_double_image(4, 4)
  let result = @computational_photography_advanced.dehaze_image(
    image, 4, 4, config,
  )
  assert_eq(result.width, 4)
  assert_true(
    result.dehazing_method
    is @computational_photography_advanced.DehazingMethod::DarkChannelPrior,
  )
}

///|
test "computational_photography_report_to_string: 基本测试" {
  let config = @computational_photography_advanced.create_default_computational_photography_config()
  let report = @computational_photography_advanced.computational_photography_report_to_string(
    @computational_photography_advanced.ComputationalPhotographyTaskType::HDRImaging,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}

///|
fn make_double_image(w : Int32, h : Int32) -> Array[Double] {
  let data : Array[Double] = []
  for i in 0..<(w * h * 3) {
    data.push((i % 256).to_double())
  }
  data
}
