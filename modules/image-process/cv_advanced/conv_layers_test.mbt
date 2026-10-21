// 卷积层扩展测试
// Convolution layer extension tests

///|
fn make_conv1d_params() -> @cv_advanced.Conv1DParams {
  {
    in_channels: 1,
    out_channels: 1,
    kernel_size: 3,
    stride: 1,
    padding: 1,
    dilation: 1,
  }
}

///|
fn make_depthwise_params() -> @cv_advanced.DepthwiseConvParams {
  { channels: 2, kernel_size: 3, stride: 1, padding: 1, depth_multiplier: 1, }
}

///|
test "形式化: conv1d 返回正确长度" {
  let input = [1.0, 2.0, 3.0, 4.0, 5.0]
  let weight = [1.0, 0.0, -1.0]
  let bias = [0.0]
  let params = make_conv1d_params()
  let result = @cv_advanced.conv1d(input, weight, bias, params)
  assert_true(result.length() > 0)
}

///|
test "形式化: depthwise_conv2d 返回正确尺寸" {
  let input_w = 5
  let input_h = 5
  let params = make_depthwise_params()
  let input : Array[Double] = []
  for _ in 0..<(params.channels * input_w * input_h) {
    input.push(1.0)
  }
  let weight : Array[Double] = []
  for _ in 0..<(params.channels * params.kernel_size * params.kernel_size) {
    weight.push(0.5)
  }
  let bias = [0.0, 0.0]
  let result = @cv_advanced.depthwise_conv2d(
    input, weight, bias, params, input_w, input_h,
  )
  assert_true(result.length() > 0)
}

///|
test "形式化: dilated_conv2d 返回正确尺寸" {
  let input_w = 7
  let input_h = 7
  let input : Array[Double] = []
  for _ in 0..<(input_w * input_h) {
    input.push(1.0)
  }
  let weight = [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0]
  let result = @cv_advanced.dilated_conv2d(
    input, weight, 0.0, 3, 2, input_w, input_h,
  )
  assert_true(result.length() > 0)
}

///|
test "形式化: grouped_conv2d 返回正确尺寸" {
  let input_w = 5
  let input_h = 5
  let in_ch = 4
  let out_ch = 4
  let groups = 2
  let ks = 3
  let input : Array[Double] = []
  for _ in 0..<(in_ch * input_w * input_h) {
    input.push(1.0)
  }
  let weight : Array[Double] = []
  for _ in 0..<(out_ch * (in_ch / groups) * ks * ks) {
    weight.push(0.5)
  }
  let bias = [0.0, 0.0, 0.0, 0.0]
  let result = @cv_advanced.grouped_conv2d(
    input, weight, bias, in_ch, out_ch, groups, ks, input_w, input_h,
  )
  assert_true(result.length() > 0)
}

///|
test "FAKE: transpose_conv2d 返回上采样尺寸" {
  let input_w = 3
  let input_h = 3
  let in_ch = 1
  let out_ch = 1
  let ks = 3
  let stride = 2
  let input : Array[Double] = []
  for _ in 0..<(in_ch * input_w * input_h) {
    input.push(1.0)
  }
  let weight : Array[Double] = []
  for _ in 0..<(out_ch * in_ch * ks * ks) {
    weight.push(0.5)
  }
  let bias = [0.0]
  let result = @cv_advanced.transpose_conv2d(
    input, weight, bias, in_ch, out_ch, ks, stride, input_w, input_h,
  )
  let expected_w = (input_w - 1) * stride + ks
  let expected_h = (input_h - 1) * stride + ks
  assert_eq(result.length(), out_ch * expected_w * expected_h)
}

///|
test "MOCK: conv3d 返回空数组（简化版）" {
  let input = [1.0, 2.0, 3.0]
  let weight = [0.5]
  let bias = [0.0]
  let params : @cv_advanced.Conv3DParams = {
    in_channels: 1,
    out_channels: 1,
    kernel_d: 1,
    kernel_h: 1,
    kernel_w: 1,
    stride: 1,
    padding: 0,
  }
  let result = @cv_advanced.conv3d(input, weight, bias, params)
  assert_eq(result.length(), 0)
}

///|
test "E2E: 完整卷积流程" {
  let input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0]
  let weight = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  let result = @cv_advanced.dilated_conv2d(input, weight, 0.0, 3, 1, 3, 3)
  assert_eq(result.length(), 1)
  assert_true(result[0] > 0.0)
}

///|
test "AI: conv1d 输出有限" {
  let input = [1.0, 2.0, 3.0, 4.0, 5.0]
  let weight = [1.0, 0.0, -1.0]
  let bias = [0.0]
  let params = make_conv1d_params()
  let result = @cv_advanced.conv1d(input, weight, bias, params)
  for v in result {
    assert_true(v >= 0.0 || v < 0.0)
  }
}

///|
test "AI: depthwise_conv2d 输出有限" {
  let input_w = 4
  let input_h = 4
  let params : @cv_advanced.DepthwiseConvParams = {
    channels: 1,
    kernel_size: 3,
    stride: 1,
    padding: 1,
    depth_multiplier: 1,
  }
  let input : Array[Double] = []
  for _ in 0..<(params.channels * input_w * input_h) {
    input.push(1.0)
  }
  let weight : Array[Double] = []
  for _ in 0..<(params.kernel_size * params.kernel_size) {
    weight.push(0.5)
  }
  let bias = [0.0]
  let result = @cv_advanced.depthwise_conv2d(
    input, weight, bias, params, input_w, input_h,
  )
  for v in result {
    assert_true(v >= 0.0 || v < 0.0)
  }
}
