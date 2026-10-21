// MRI 处理测试 — MRI processing tests
// Phase 14 v348: 医学影像大扩展 — MRI 处理。

///|
test "mri_kspace_to_image: K空间转图像" {
  let kspace : @cv_advanced.KSpaceData = {
    data_real: [1.0, 2.0, 3.0, 4.0],
    data_imag: [0.0, 0.0, 0.0, 0.0],
    width: 2,
    height: 2,
  }
  let img = @cv_advanced.mri_kspace_to_image(kspace)
  assert_true(img.length() == 4)
  assert_true(img[0] == 1.0)
}

///|
test "mri_image_to_kspace: 图像转K空间" {
  let img = [1.0, 2.0, 3.0, 4.0]
  let kspace = @cv_advanced.mri_image_to_kspace(img, 2, 2)
  assert_true(kspace.width == 2)
  assert_true(kspace.height == 2)
  assert_true(kspace.data_real.length() == 4)
}

///|
test "mri_correct_bias_field: 偏置场校正" {
  let img = [10.0, 20.0, 30.0, 40.0]
  let bias = [2.0, 2.0, 2.0, 2.0]
  let result = @cv_advanced.mri_correct_bias_field(img, bias, 2, 2)
  assert_true(result.length() == 4)
  assert_true(result[0] == 5.0)
}

///|
test "mri_correct_bias_field: 零偏置场" {
  let img = [1.0, 2.0]
  let bias = [0.0, 1.0]
  let result = @cv_advanced.mri_correct_bias_field(img, bias, 2, 1)
  assert_true(result[0] == 1.0)
  assert_true(result[1] == 2.0)
}

///|
test "mri_correct_ghosting: 鬼影校正" {
  let img = [1.0, 2.0, 3.0, 4.0]
  let result = @cv_advanced.mri_correct_ghosting(img, 2, 2, 0.0)
  assert_true(result.length() == 4)
  assert_true(result[0] == 1.0)
}

///|
test "mri_compute_t1_map: T1映射" {
  let img1 = [0.5, 0.6]
  let img2 = [0.3, 0.4]
  let tis = [100.0, 500.0]
  let t1_map = @cv_advanced.mri_compute_t1_map([img1, img2], tis)
  assert_true(t1_map.length() == 2)
  assert_true(t1_map[0] > 0.0)
}

///|
test "mri_compute_t2_map: T2映射" {
  let img1 = [0.9, 0.8]
  let img2 = [0.5, 0.4]
  let tes = [10.0, 50.0]
  let t2_map = @cv_advanced.mri_compute_t2_map([img1, img2], tes)
  assert_true(t2_map.length() == 2)
  assert_true(t2_map[0] > 0.0)
}

///|
test "MRIPulseType: enum 值" {
  let p1 = @cv_advanced.MRIPulseType::SpinEcho
  let p2 = @cv_advanced.MRIPulseType::GradientEcho
  let p3 = @cv_advanced.MRIPulseType::InversionRecovery
  let p4 = @cv_advanced.MRIPulseType::EPI
  assert_true(p1 != p2)
  assert_true(p2 != p3)
  assert_true(p3 != p4)
}

///|
test "MRIConfig: 构造与字段" {
  let config : @cv_advanced.MRIConfig = {
    field_strength: 3.0,
    te: 30.0,
    tr: 2000.0,
    pulse_type: @cv_advanced.MRIPulseType::SpinEcho,
  }
  assert_true(config.field_strength == 3.0)
  assert_true(config.te == 30.0)
}
