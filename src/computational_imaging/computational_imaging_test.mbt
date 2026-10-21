// v44.0.0 计算成像测试

///|
test "create_default_lightfield_camera: 基本测试" {
  let params = @computational_imaging.create_default_lightfield_camera()
  assert_eq(params.num_views_x, 9)
  assert_eq(params.num_views_y, 9)
  assert_eq(params.num_aperture_samples, 64)
}

///|
test "create_default_phase_config: 基本测试" {
  let config = @computational_imaging.create_default_phase_config()
  assert_eq(config.num_iterations, 100)
  assert_eq(config.algorithm, "Gerchberg-Saxton")
}

///|
test "create_default_coded_aperture: 基本测试" {
  let pattern = @computational_imaging.create_default_coded_aperture(8)
  assert_eq(pattern.pattern_size, 8)
  assert_eq(pattern.num_elements, 64)
  assert_eq(pattern.code_type, "random")
}

///|
test "generate_sample_lightfield: 基本测试" {
  let img = make_test_image(4, 4)
  let params = @computational_imaging.create_default_lightfield_camera()
  let lf = @computational_imaging.generate_sample_lightfield(img, params)
  assert_eq(lf.total_views, 81)
  assert_eq(lf.views.length(), 81)
  assert_eq(lf.num_views_x, 9)
}

///|
test "lightfield_refocus: 基本测试" {
  let img = make_test_image(4, 4)
  let params = @computational_imaging.create_default_lightfield_camera()
  let lf = @computational_imaging.generate_sample_lightfield(img, params)
  let result = @computational_imaging.lightfield_refocus(lf, 1.0, 2.0)
  assert_eq(result.image.width, 4)
  assert_eq(result.image.height, 4)
  assert_true(result.num_views_used > 0)
}

///|
test "synthesize_view: 基本测试" {
  let img = make_test_image(4, 4)
  let params = @computational_imaging.create_default_lightfield_camera()
  let lf = @computational_imaging.generate_sample_lightfield(img, params)
  let result = @computational_imaging.synthesize_view(lf, 0.5, 0.5)
  assert_eq(result.image.width, 4)
  assert_eq(result.num_source_views, 4)
  assert_eq(result.interpolation_method, "bilinear")
}

///|
test "generate_hologram: 基本测试" {
  let img = make_test_image(4, 4)
  let holo = @computational_imaging.generate_hologram(img, 632.8, 1.0, 0.001)
  assert_eq(holo.intensity.width, 4)
  assert_eq(holo.phase.width, 4)
  assert_eq(holo.wavelength, 632.8)
}

///|
test "reconstruct_hologram: 基本测试" {
  let img = make_test_image(4, 4)
  let holo = @computational_imaging.generate_hologram(img, 632.8, 1.0, 0.001)
  let result = @computational_imaging.reconstruct_hologram(holo)
  assert_eq(result.image.width, 4)
  assert_true(
    result.algorithm
    is @computational_imaging.ComputationalImagingAlgorithm::Holography,
  )
}

///|
test "ct_reconstruct_fbp: 基本测试" {
  let proj_img = make_test_image(8, 1)
  let projections = @computational_imaging.CTProjectionData::{
    projections: [proj_img, proj_img, proj_img, proj_img],
    num_angles: 4,
    num_detectors: 8,
    angular_range: 3.14159,
    source_distance: 100.0,
    detector_distance: 100.0,
  }
  let result = @computational_imaging.ct_reconstruct_fbp(projections, 8)
  assert_eq(result.image.width, 8)
  assert_eq(result.image.height, 8)
  assert_true(
    result.algorithm
    is @computational_imaging.ComputationalImagingAlgorithm::ComputedTomography,
  )
}

///|
test "phase_retrieval: 基本测试" {
  let img = make_test_image(4, 4)
  let config = @computational_imaging.PhaseRetrievalConfig::{
    num_iterations: 5,
    algorithm: "test",
    support_threshold: 0.1,
    use_hybrid_input_output: true,
    beta: 0.9,
  }
  let result = @computational_imaging.phase_retrieval(img, config)
  assert_eq(result.image.width, 4)
  assert_true(
    result.algorithm
    is @computational_imaging.ComputationalImagingAlgorithm::PhaseRetrieval,
  )
  assert_eq(result.num_iterations, 5)
}

///|
test "coded_aperture_reconstruct: 基本测试" {
  let img = make_test_image(8, 8)
  let pattern = @computational_imaging.create_default_coded_aperture(8)
  let result = @computational_imaging.coded_aperture_reconstruct(img, pattern)
  assert_eq(result.image.width, 8)
  assert_true(
    result.algorithm
    is @computational_imaging.ComputationalImagingAlgorithm::CodedAperture,
  )
}

///|
test "computational_imaging_report_to_string: 基本测试" {
  let img = make_test_image(4, 4)
  let holo = @computational_imaging.generate_hologram(img, 632.8, 1.0, 0.001)
  let result = @computational_imaging.reconstruct_hologram(holo)
  let report = @computational_imaging.computational_imaging_report_to_string(
    result, "全息重建",
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_image(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int32 = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}
