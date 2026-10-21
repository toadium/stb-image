// CT 重建测试 — CT reconstruction tests
// Phase 14 v347: 医学影像大扩展 — CT 重建。

///|
fn make_ct_config() -> @cv_advanced.CTConfig {
  {
    image_size: 4,
    num_angles: 4,
    detector_count: 4,
    recon_method: @cv_advanced.ReconstructionMethod::FBP,
  }
}

///|
test "ct_radon_transform: 基本Radon变换" {
  let image = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0,
  ]
  let angles = [0.0, 1.5707963267948966]
  let proj = @cv_advanced.ct_radon_transform(image, 4, angles)
  assert_true(proj.angles.length() == 2)
  assert_true(proj.projection_data.length() == 8)
}

///|
test "ct_ramp_filter: 滤波器" {
  let filter = @cv_advanced.ct_ramp_filter(8, 5.0)
  assert_true(filter.length() == 8)
  assert_true(filter[4] == 0.0)
  assert_true(filter[0] == 4.0)
}

///|
test "ct_fbp_reconstruct: FBP重建" {
  let image = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0,
  ]
  let angles = [0.0, 1.5707963267948966]
  let proj = @cv_advanced.ct_radon_transform(image, 4, angles)
  let config = make_ct_config()
  let recon = @cv_advanced.ct_fbp_reconstruct(proj, config)
  assert_true(recon.length() == 16)
}

///|
test "ct_art_reconstruct: ART重建" {
  let image = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0,
  ]
  let angles = [0.0, 1.5707963267948966]
  let proj = @cv_advanced.ct_radon_transform(image, 4, angles)
  let config = make_ct_config()
  let recon = @cv_advanced.ct_art_reconstruct(proj, config, 2)
  assert_true(recon.length() == 16)
}

///|
test "ct_iterative_reconstruct: 迭代重建" {
  let image = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0,
  ]
  let angles = [0.0, 1.5707963267948966]
  let proj = @cv_advanced.ct_radon_transform(image, 4, angles)
  let config = make_ct_config()
  let recon = @cv_advanced.ct_iterative_reconstruct(proj, config, 1)
  assert_true(recon.length() == 16)
}

///|
test "ReconstructionMethod: enum 值" {
  let r1 = @cv_advanced.ReconstructionMethod::FBP
  let r2 = @cv_advanced.ReconstructionMethod::Iterative
  let r3 = @cv_advanced.ReconstructionMethod::ART
  let r4 = @cv_advanced.ReconstructionMethod::SART
  assert_true(r1 != r2)
  assert_true(r2 != r3)
  assert_true(r3 != r4)
}

///|
test "CTProjection: 构造" {
  let proj : @cv_advanced.CTProjection = {
    angles: [0.0, 1.0],
    detector_count: 4,
    projection_data: [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0],
  }
  assert_true(proj.detector_count == 4)
  assert_true(proj.projection_data.length() == 8)
}

///|
test "CTConfig: 构造与字段" {
  let config = make_ct_config()
  assert_true(config.image_size == 4)
  assert_true(config.num_angles == 4)
}

///|
test "ct_ramp_filter: 截止频率" {
  let filter = @cv_advanced.ct_ramp_filter(4, 2.0)
  assert_true(filter.length() == 4)
  assert_true(filter[2] == 0.0)
  assert_true(filter[1] == 1.0)
  assert_true(filter[3] == 1.0)
}
