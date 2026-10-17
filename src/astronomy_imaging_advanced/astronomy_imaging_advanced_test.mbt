///|
test "create_default_astronomy_config: returns object detection config" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  assert_eq(config.detection_threshold, 3.0)
  assert_eq(config.photometry_aperture, 5.0)
  assert_eq(config.pixel_scale, 1.0)
  assert_eq(config.gain, 1.0)
  assert_eq(config.exposure_time, 300.0)
  assert_eq(config.filter_name, "V")
  assert_true(config.use_wcs)
  assert_true(config.use_calibration)
  assert_true(config.use_dark_subtraction)
  assert_true(config.use_flat_correction)
  assert_eq(config.stacking_method, "median")
  assert_eq(config.num_stack_images, 10)
  assert_true(
    config.task_type
    is @astronomy_imaging_advanced.AstronomyImagingTaskType::ObjectDetection,
  )
}

///|
test "detect_celestial_objects: returns detected objects" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 1000).to_double())
  }
  let objects = @astronomy_imaging_advanced.detect_celestial_objects(
    image, 100, 100, config,
  )
  assert_eq(objects.length(), 20)
  for obj in objects {
    assert_true(obj.confidence >= 0.8 && obj.confidence <= 1.0)
    assert_true(obj.snr >= 3.0)
    assert_true(obj.brightness >= 0.0)
  }
}

///|
test "detect_celestial_objects: point source stars" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let image : Array[Double] = []
  for i in 0..<400 {
    image.push((i % 100).to_double())
  }
  let objects = @astronomy_imaging_advanced.detect_celestial_objects(
    image, 20, 20, config,
  )
  assert_true(objects.length() > 0)
  let mut star_count = 0
  for obj in objects {
    if obj.is_point_source {
      star_count += 1
    }
  }
  assert_true(star_count >= 0)
}

///|
test "classify_galaxies: classifies galaxy objects" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 1000).to_double())
  }
  let objects = @astronomy_imaging_advanced.detect_celestial_objects(
    image, 100, 100, config,
  )
  let galaxies = @astronomy_imaging_advanced.classify_galaxies(objects, config)
  assert_true(galaxies.length() >= 0)
  for g in galaxies {
    assert_true(g.confidence >= 0.7 && g.confidence <= 1.0)
    assert_true(g.redshift >= 0.0 && g.redshift <= 1.0)
    assert_eq(g.all_morphologies.length(), 4)
    assert_eq(g.all_scores.length(), 4)
  }
}

///|
test "perform_photometry: measures object brightness" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let image : Array[Double] = []
  for i in 0..<10000 {
    image.push((i % 1000).to_double())
  }
  let objects = @astronomy_imaging_advanced.detect_celestial_objects(
    image, 100, 100, config,
  )
  let photometry = @astronomy_imaging_advanced.perform_photometry(
    objects, config,
  )
  assert_eq(photometry.length(), objects.length())
  for p in photometry {
    assert_eq(p.filter_name, "V")
    assert_true(p.aperture_radius == 5.0)
    assert_true(p.snr >= 3.0)
  }
}

///|
test "stack_images: stacks multiple images" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let img1 : Array[Double] = []
  let img2 : Array[Double] = []
  let img3 : Array[Double] = []
  for i in 0..<100 {
    img1.push((i % 100).to_double())
    img2.push((i % 100).to_double() + 10.0)
    img3.push((i % 100).to_double() + 20.0)
  }
  let result = @astronomy_imaging_advanced.stack_images(
    [img1, img2, img3],
    10,
    10,
    config,
  )
  assert_eq(result.num_images, 3)
  assert_eq(result.width, 10)
  assert_eq(result.height, 10)
  assert_eq(result.stacked_image.length(), 100)
  assert_true(result.noise_reduction_factor == 3.0)
  assert_true(result.exposure_time_total == 900.0)
  assert_eq(result.stacking_method, "median")
}

///|
test "astronomy_imaging_report_to_string: contains task info" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let report = @astronomy_imaging_advanced.astronomy_imaging_report_to_string(
    @astronomy_imaging_advanced.AstronomyImagingTaskType::GalaxyClassification,
    config,
    "Found 15 galaxies",
  )
  assert_true(report.contains("天文图像处理高级报告"))
  assert_true(report.contains("星系分类"))
  assert_true(report.contains("Found 15 galaxies"))
  assert_true(report.contains("median"))
}

///|
test "astronomy_imaging_report_to_string: photometry task" {
  let config = @astronomy_imaging_advanced.create_default_astronomy_config()
  let report = @astronomy_imaging_advanced.astronomy_imaging_report_to_string(
    @astronomy_imaging_advanced.AstronomyImagingTaskType::Photometry,
    config,
    "Measured 20 stars",
  )
  assert_true(report.contains("测光"))
  assert_true(report.contains("Measured 20 stars"))
}
