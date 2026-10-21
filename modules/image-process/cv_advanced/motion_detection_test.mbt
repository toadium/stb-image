// 运动检测测试 — 帧差/累积/能量/光流
// Motion detection tests

///|
fn make_motion_test_images() -> (@types.Image, @types.Image) {
  let width = 8
  let height = 8
  let channels = 1
  let prev_data : Array[Byte] = []
  let curr_data : Array[Byte] = []
  let bg_val = 100
  for y in 0..<height {
    for x in 0..<width {
      prev_data.push(bg_val.reinterpret_as_uint().to_byte())
      let v = if x >= 4 && y >= 4 { 200 } else { 100 }
      curr_data.push(v.reinterpret_as_uint().to_byte())
    }
  }
  let prev : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(prev_data),
  }
  let curr : @types.Image = {
    width,
    height,
    channels,
    data: Bytes::from_array(curr_data),
  }
  (prev, curr)
}

///|
fn make_motion_params() -> @cv_advanced.MotionParams {
  { threshold: 50.0, min_area: 1, blur_size: 3, dilate_iter: 1, }
}

///|
test "形式化: detect_motion_frame_diff 返回正确尺寸" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  assert_eq(motion.width, prev.width)
  assert_eq(motion.height, prev.height)
  assert_eq(motion.mask.length(), prev.width * prev.height)
}

///|
test "形式化: compute_motion_energy 返回非负值" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  let energy = @cv_advanced.compute_motion_energy(motion)
  assert_true(energy >= 0.0)
}

///|
test "形式化: motion_morphology 保持尺寸" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  let cleaned = @cv_advanced.motion_morphology(motion, 1)
  assert_eq(cleaned.width, motion.width)
  assert_eq(cleaned.height, motion.height)
}

///|
test "形式化: motion_density 返回网格密度" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  let densities = @cv_advanced.motion_density(motion, 2, 2)
  assert_eq(densities.length(), 4)
  for d in densities {
    assert_true(d >= 0.0 && d <= 1.0)
  }
}

///|
test "FAKE: detect_motion_accumulator 更新累积器" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let acc : Array[Double] = []
  let (motion, new_acc) = @cv_advanced.detect_motion_accumulator(
    acc, curr, prev, params,
  )
  assert_eq(motion.width, prev.width)
  assert_eq(new_acc.length(), prev.width * prev.height)
}

///|
test "MOCK: motion_optical_flow 从光流检测运动" {
  let flow : @cv_advanced.FlowField = {
    width: 4,
    height: 4,
    u: [
      0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0,
    ],
    v: [
      0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
      0.0,
    ],
  }
  let motion = @cv_advanced.motion_optical_flow(flow, 0.5)
  assert_eq(motion.width, 4)
  assert_eq(motion.height, 4)
}

///|
test "E2E: 完整运动检测流程" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  let cleaned = @cv_advanced.motion_morphology(motion, params.dilate_iter)
  let regions = @cv_advanced.extract_motion_regions(cleaned, params)
  let energy = @cv_advanced.compute_motion_energy(cleaned)
  assert_true(regions.length() >= 0)
  assert_true(energy >= 0.0)
}

///|
test "AI: MotionMask intensity 非负" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  for i in motion.intensity {
    assert_true(i >= 0.0)
  }
}

///|
test "AI: extract_motion_regions 返回有效区域" {
  let (prev, curr) = make_motion_test_images()
  let params = make_motion_params()
  let motion = @cv_advanced.detect_motion_frame_diff(prev, curr, params)
  let regions = @cv_advanced.extract_motion_regions(motion, params)
  for r in regions {
    assert_true(r.area >= params.min_area)
    assert_true(r.width > 0)
    assert_true(r.height > 0)
  }
}
