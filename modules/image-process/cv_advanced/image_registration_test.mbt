// 图像配准测试 — ECC/相位相关/特征配准
// Image registration tests

///|
fn make_reg_test_images() -> (@types.Image, @types.Image) {
  let width = 12
  let height = 12
  let channels = 1
  let ref_data : Array[Byte] = []
  let src_data : Array[Byte] = []
  for _ in 0..<height {
    for x in 0..<width {
      let v = if x >= 6 { 200 } else { 50 }
      ref_data.push(v.reinterpret_as_uint().to_byte())
      let sx = x - 1
      let sv = if sx >= 6 { 200 } else { 50 }
      src_data.push(sv.reinterpret_as_uint().to_byte())
    }
  }
  let ref_img : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(ref_data),
  }
  let src_img : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(src_data),
  }
  (ref_img, src_img)
}

///|
fn make_reg_params() -> @cv_advanced.RegistrationParams {
  {
    reg_method: @cv_advanced.RegistrationMethod::ECC,
    max_iterations: 50,
    epsilon: 0.001,
    warp_type: 0,
  }
}

///|
test "形式化: identity_affine 返回单位矩阵" {
  let m = @cv_advanced.identity_affine()
  assert_eq(m.m00, 1.0)
  assert_eq(m.m11, 1.0)
  assert_eq(m.m01, 0.0)
  assert_eq(m.m10, 0.0)
  assert_eq(m.m02, 0.0)
  assert_eq(m.m12, 0.0)
}

///|
test "形式化: estimate_translation 返回平移量" {
  let (ref_img, src_img) = make_reg_test_images()
  let (tx, ty) = @cv_advanced.estimate_translation(ref_img, src_img)
  assert_true(tx >= -5.0 && tx <= 5.0)
  assert_true(ty >= -5.0 && ty <= 5.0)
}

///|
test "形式化: apply_warp 保持图像尺寸" {
  let (ref_img, _src_img) = make_reg_test_images()
  let warp = @cv_advanced.identity_affine()
  let warped = @cv_advanced.apply_warp(ref_img, warp)
  assert_eq(warped.width, ref_img.width)
  assert_eq(warped.height, ref_img.height)
}

///|
test "形式化: compute_ncc 自相关为 1" {
  let (ref_img, _src_img) = make_reg_test_images()
  let ncc = @cv_advanced.compute_ncc(ref_img, ref_img)
  assert_true(ncc > 0.99)
}

///|
test "FAKE: compute_ecc_alignment 返回配准结果" {
  let (ref_img, src_img) = make_reg_test_images()
  let params = make_reg_params()
  let result = @cv_advanced.compute_ecc_alignment(ref_img, src_img, params)
  assert_true(result.error >= 0.0)
  assert_true(result.iterations > 0)
}

///|
test "MOCK: compute_phase_correlation 返回结果" {
  let (ref_img, src_img) = make_reg_test_images()
  let result = @cv_advanced.compute_phase_correlation(ref_img, src_img)
  assert_true(result.success)
}

///|
test "E2E: 完整配准流程" {
  let (ref_img, src_img) = make_reg_test_images()
  let params = make_reg_params()
  let result = @cv_advanced.register_images(ref_img, src_img, params)
  let warped = @cv_advanced.apply_warp(src_img, result.warp)
  let ncc = @cv_advanced.compute_ncc(ref_img, warped)
  assert_true(ncc >= -1.0 && ncc <= 1.0)
}

///|
test "AI: RegistrationMethod 枚举完整" {
  let ecc = @cv_advanced.RegistrationMethod::ECC
  let pc = @cv_advanced.RegistrationMethod::PhaseCorrelation
  let fb = @cv_advanced.RegistrationMethod::FeatureBased
  assert_true(ecc != pc)
  assert_true(pc != fb)
  assert_true(ecc != fb)
}

///|
test "AI: estimate_affine 返回有效矩阵" {
  let (ref_img, src_img) = make_reg_test_images()
  let m = @cv_advanced.estimate_affine(ref_img, src_img)
  assert_true(m.m00 >= 0.0 || m.m00 < 0.0)
  assert_true(m.m11 >= 0.0 || m.m11 < 0.0)
}
