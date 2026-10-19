// 模型量化测试 — Model quantization tests
// Phase 13 v334: 深度学习大扩展 — 模型量化。

///|
fn make_quant_config() -> @cv_advanced.QuantizationConfig {
  {
    bits: 8,
    per_channel: false,
    symmetric: true,
    calibration_min: 0.0,
    calibration_max: 0.0,
  }
}

///|
test "compute_quant_params: 基本参数" {
  let (scale, zp) = @cv_advanced.compute_quant_params(-1.0, 1.0, 8)
  assert_true(scale > 0.0)
  assert_true(zp >= -128 && zp <= 127)
}

///|
test "compute_quant_params: 零范围" {
  let (scale, _) = @cv_advanced.compute_quant_params(0.5, 0.5, 8)
  assert_true(scale == 1.0)
}

///|
test "quantize_int8: 基本量化" {
  let input = [-1.0, -0.5, 0.0, 0.5, 1.0]
  let config = make_quant_config()
  let tensor = @cv_advanced.quantize_int8(input, config)
  assert_true(tensor.data.length() == 5)
  assert_true(tensor.bits == 8)
  for q in tensor.data {
    assert_true(q >= -128 && q <= 127)
  }
}

///|
test "quantize_int4: 基本量化" {
  let input = [-1.0, -0.5, 0.0, 0.5, 1.0]
  let config : @cv_advanced.QuantizationConfig = {
    bits: 4,
    per_channel: false,
    symmetric: true,
    calibration_min: 0.0,
    calibration_max: 0.0,
  }
  let tensor = @cv_advanced.quantize_int4(input, config)
  assert_true(tensor.data.length() == 5)
  assert_true(tensor.bits == 4)
  for q in tensor.data {
    assert_true(q >= -8 && q <= 7)
  }
}

///|
test "dequantize: 基本反量化" {
  let input = [0.1, 0.2, 0.3]
  let config = make_quant_config()
  let tensor = @cv_advanced.quantize_int8(input, config)
  let recovered = @cv_advanced.dequantize(tensor)
  assert_true(recovered.length() == 3)
}

///|
test "quantize_per_channel: 逐通道量化" {
  let input = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0]
  let result = @cv_advanced.quantize_per_channel(input, 2, 8)
  assert_true(result.length() == 2)
}

///|
test "mixed_precision_quantize: 混合精度" {
  let input = [0.01, 0.02, 1.0, 2.0, 0.03, 3.0]
  let result = @cv_advanced.mixed_precision_quantize(input, 0.5)
  assert_true(result.length() >= 1)
  assert_true(result.length() <= 2)
}

///|
test "compute_quantization_error: 误差计算" {
  let input = [0.1, 0.2, 0.3, 0.4, 0.5]
  let config = make_quant_config()
  let tensor = @cv_advanced.quantize_int8(input, config)
  let error = @cv_advanced.compute_quantization_error(input, tensor)
  assert_true(error >= 0.0)
}

///|
test "QuantizationType: enum 值" {
  let q1 = @cv_advanced.QuantizationType::Int8
  let q2 = @cv_advanced.QuantizationType::Int4
  let q3 = @cv_advanced.QuantizationType::Int16
  let q4 = @cv_advanced.QuantizationType::MixedPrecision
  assert_true(q1 != q2)
  assert_true(q2 != q3)
  assert_true(q3 != q4)
}
