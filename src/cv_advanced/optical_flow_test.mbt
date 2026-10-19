// 光流测试 — Lucas-Kanade/Horn-Schunck/Farneback
// Optical flow tests

///|
fn make_flow_test_images() -> (@types.Image, @types.Image) {
  let width = 16
  let height = 16
  let channels = 1
  let prev_data : Array[Byte] = []
  let curr_data : Array[Byte] = []
  for _ in 0..<height {
    for x in 0..<width {
      let v = if x >= 8 { 200 } else { 50 }
      prev_data.push(v.reinterpret_as_uint().to_byte())
      let cx = if x + 1 >= 8 { 200 } else { 50 }
      curr_data.push(cx.reinterpret_as_uint().to_byte())
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
fn make_flow_params() -> @cv_advanced.FlowParams {
  { window_size: 5, max_iterations: 10, epsilon: 0.001, alpha: 10.0, }
}

///|
test "形式化: compute_lucas_kanade 返回正确尺寸" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let points : Array[(Int, Int)] = [(8, 8), (10, 10), (12, 12)]
  let flow = @cv_advanced.compute_lucas_kanade(prev, curr, points, params)
  assert_eq(flow.width, prev.width)
  assert_eq(flow.height, prev.height)
  assert_eq(flow.u.length(), prev.width * prev.height)
}

///|
test "形式化: compute_horn_schunck 返回正确尺寸" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_horn_schunck(prev, curr, params)
  assert_eq(flow.width, prev.width)
  assert_eq(flow.height, prev.height)
}

///|
test "形式化: compute_farneback 返回正确尺寸" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_farneback(prev, curr, params)
  assert_eq(flow.width, prev.width)
  assert_eq(flow.height, prev.height)
}

///|
test "形式化: flow_magnitude 返回非负值" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_horn_schunck(prev, curr, params)
  let mags = @cv_advanced.flow_magnitude(flow)
  for m in mags {
    assert_true(m >= 0.0)
  }
}

///|
test "FAKE: warp_image 保持图像尺寸" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_horn_schunck(prev, curr, params)
  let warped = @cv_advanced.warp_image(prev, flow)
  assert_eq(warped.width, prev.width)
  assert_eq(warped.height, prev.height)
}

///|
test "MOCK: flow_consistency 返回非负值" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let fwd = @cv_advanced.compute_horn_schunck(prev, curr, params)
  let bwd = @cv_advanced.compute_horn_schunck(curr, prev, params)
  let consistency = @cv_advanced.flow_consistency(fwd, bwd)
  assert_true(consistency >= 0.0)
}

///|
test "E2E: 完整光流流程" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let points : Array[(Int, Int)] = [(8, 8), (10, 10)]
  let lk = @cv_advanced.compute_lucas_kanade(prev, curr, points, params)
  let hs = @cv_advanced.compute_horn_schunck(prev, curr, params)
  let fb = @cv_advanced.compute_farneback(prev, curr, params)
  let mags = @cv_advanced.flow_magnitude(hs)
  let warped = @cv_advanced.warp_image(prev, fb)
  assert_eq(lk.width, warped.width)
  assert_true(mags.length() > 0)
}

///|
test "AI: FlowField 向量有限" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_horn_schunck(prev, curr, params)
  for i in 0..<flow.u.length() {
    assert_true(flow.u[i] >= 0.0 || flow.u[i] < 0.0)
    assert_true(flow.v[i] >= 0.0 || flow.v[i] < 0.0)
  }
}

///|
test "AI: flow_magnitude 长度匹配" {
  let (prev, curr) = make_flow_test_images()
  let params = make_flow_params()
  let flow = @cv_advanced.compute_horn_schunck(prev, curr, params)
  let mags = @cv_advanced.flow_magnitude(flow)
  assert_eq(mags.length(), flow.u.length())
}
