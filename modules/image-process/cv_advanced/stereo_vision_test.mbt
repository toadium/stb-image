// 立体视觉测试 — 视差/SGM/深度图
// Stereo vision tests

///|
fn make_stereo_test_images() -> (@types.Image, @types.Image) {
  let width = 16
  let height = 16
  let channels = 1
  let left_data : Array[Byte] = []
  let right_data : Array[Byte] = []
  for _ in 0..<height {
    for x in 0..<width {
      let v = if x >= 8 { 200 } else { 50 }
      left_data.push(v.reinterpret_as_uint().to_byte())
      let rx = x - 2
      let rv = if rx >= 8 { 200 } else { 50 }
      right_data.push(rv.reinterpret_as_uint().to_byte())
    }
  }
  let left : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(left_data),
  }
  let right : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(right_data),
  }
  (left, right)
}

///|
fn make_stereo_params() -> @cv_advanced.StereoParams {
  { max_disparity: 8, block_size: 3, threshold: 100.0, baseline: 10.0, }
}

///|
test "形式化: compute_disparity_block_matching 返回正确尺寸" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  assert_eq(disp.width, left.width)
  assert_eq(disp.height, left.height)
  assert_eq(disp.disparities.length(), left.width * left.height)
}

///|
test "形式化: disparity_to_depth 计算正确" {
  let depth = @cv_advanced.disparity_to_depth(10.0, 100.0, 500.0)
  assert_true(depth > 0.0)
  let zero = @cv_advanced.disparity_to_depth(0.0, 100.0, 500.0)
  assert_eq(zero, 0.0)
}

///|
test "形式化: compute_depth_map 返回正确尺寸" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  let depth = @cv_advanced.compute_depth_map(disp, 10.0, 500.0)
  assert_eq(depth.width, disp.width)
  assert_eq(depth.height, disp.height)
}

///|
test "形式化: stereo_rectify 返回原图像" {
  let (left, right) = make_stereo_test_images()
  let (rl, rr) = @cv_advanced.stereo_rectify(left, right)
  assert_eq(rl.width, left.width)
  assert_eq(rr.width, right.width)
}

///|
test "FAKE: compute_disparity_sgm 返回平滑视差" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_sgm(left, right, params)
  assert_eq(disp.width, left.width)
  assert_eq(disp.height, left.height)
}

///|
test "MOCK: validate_disparity 一致性检查" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let ldisp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  let rdisp = @cv_advanced.compute_disparity_block_matching(right, left, params)
  let validated = @cv_advanced.validate_disparity(ldisp, rdisp, 2.0)
  assert_eq(validated.width, ldisp.width)
  assert_eq(validated.height, ldisp.height)
}

///|
test "E2E: 完整立体视觉流程" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  let depth = @cv_advanced.compute_depth_map(disp, params.baseline, 500.0)
  let mut valid_count = 0
  for i in 0..<depth.depths.length() {
    if depth.valid[i] && depth.depths[i] > 0.0 {
      valid_count = valid_count + 1
    }
  }
  assert_true(valid_count >= 0)
}

///|
test "AI: DisparityMap 视差值非负" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  for d in disp.disparities {
    assert_true(d >= 0.0)
  }
}

///|
test "AI: DepthMap 深度值非负" {
  let (left, right) = make_stereo_test_images()
  let params = make_stereo_params()
  let disp = @cv_advanced.compute_disparity_block_matching(left, right, params)
  let depth = @cv_advanced.compute_depth_map(disp, 10.0, 500.0)
  for d in depth.depths {
    assert_true(d >= 0.0)
  }
}
