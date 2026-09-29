// v44.0.0 高级成像技术测试

///|
test "create_default_advanced_imaging_config: 基本测试" {
  let config = create_default_advanced_imaging_config(ImagingModality::Quantum)
  assert_eq(config.image_width, 512)
  assert_true(config.modality is ImagingModality::Quantum)
}

///|
test "quantum_ghost_imaging: 基本测试" {
  let result = quantum_ghost_imaging(
    10,
    4,
    4,
    QuantumImagingAlgorithm::GhostImaging,
  )
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "infrared_pseudocolor: 基本测试" {
  let img = make_test_image(4, 4)
  let result = infrared_pseudocolor(img, InfraredImagingType::MWIR)
  assert_eq(result.width, 4)
  assert_eq(result.channels, 3)
}

///|
test "generate_hyperspectral_cube: 基本测试" {
  let img = make_test_image(4, 4)
  let cube = generate_hyperspectral_cube(img, 5, 400.0, 800.0)
  assert_eq(cube.num_bands, 5)
  assert_eq(cube.image_cube.length(), 5)
  assert_eq(cube.spatial_width, 4)
}

///|
test "analyze_polarization: 基本测试" {
  let img = make_test_image(4, 4)
  let pol = analyze_polarization(img, img, img, img)
  assert_eq(pol.num_stokes, 4)
  assert_eq(pol.intensity.width, 4)
}

///|
test "thermal_to_temperature: 基本测试" {
  let img = make_test_image(4, 4)
  let thermal = thermal_to_temperature(img, 0.95, 20.0, 100.0)
  assert_eq(thermal.temperature_map.width, 4)
  assert_eq(thermal.units, "Celsius")
}

///|
test "xray_enhance: 基本测试" {
  let img = make_test_image(4, 4)
  let xray = xray_enhance(img, 80.0)
  assert_eq(xray.projection.width, 4)
  assert_eq(xray.energy_kev, 80.0)
}

///|
test "ultrasound_synthesize: 基本测试" {
  let us = ultrasound_synthesize(4, 4, 5.0, 10.0)
  assert_eq(us.b_mode.width, 4)
  assert_eq(us.frequency_mhz, 5.0)
}

///|
test "mri_synthesize: 基本测试" {
  let mri = mri_synthesize(4, 4, 1.5)
  assert_eq(mri.t1_weighted.width, 4)
  assert_eq(mri.field_strength_t, 1.5)
}

///|
test "pet_synthesize: 基本测试" {
  let pet = pet_synthesize(4, 4, "FDG")
  assert_eq(pet.activity_map.width, 4)
  assert_eq(pet.radiotracer, "FDG")
}

///|
test "advanced_imaging_report_to_string: 基本测试" {
  let img = make_test_image(4, 4)
  let config = create_default_advanced_imaging_config(ImagingModality::MRI)
  let report = advanced_imaging_report_to_string(
    ImagingModality::MRI,
    img,
    config,
  )
  assert_true(report.length() > 0)
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
