// 模型量化 — INT8/INT4/混合精度
// Model quantization
//
// Phase 13 v334: 深度学习大扩展 — 模型量化。

///|
/// 量化类型。
/// Quantization type.
pub(all) enum QuantizationType {
  Int8
  Int4
  Int16
  MixedPrecision
} derive(Eq, @debug.Debug)

///|
pub extend QuantizationType with @debug.Debug::{to_repr}

///|
pub extend QuantizationType with Eq::{not_equal, equal}

///|
/// 量化配置。
/// Quantization configuration.
pub(all) struct QuantizationConfig {
  bits : Int
  per_channel : Bool
  symmetric : Bool
  calibration_min : Double
  calibration_max : Double
} derive(Eq, @debug.Debug)

///|
pub extend QuantizationConfig with @debug.Debug::{to_repr}

///|
pub extend QuantizationConfig with Eq::{not_equal, equal}

///|
/// 量化张量。
/// Quantized tensor.
pub(all) struct QuantizedTensor {
  data : Array[Int]
  scale : Double
  zero_point : Int
  bits : Int
} derive(Eq, @debug.Debug)

///|
pub extend QuantizedTensor with @debug.Debug::{to_repr}

///|
pub extend QuantizedTensor with Eq::{not_equal, equal}

///|
/// 计算量化参数。
/// Compute quantization parameters.
pub fn compute_quant_params(
  min_val : Double,
  max_val : Double,
  bits : Int,
) -> (Double, Int) {
  let q_min = if bits == 4 { -8 } else if bits == 8 { -128 } else { -32768 }
  let q_max = if bits == 4 { 7 } else if bits == 8 { 127 } else { 32767 }
  let range = max_val - min_val
  if range <= 0.0 {
    return (1.0, 0)
  }
  let q_range = (q_max - q_min).to_double()
  let scale = range / q_range
  let zero_point = q_min - (min_val / scale).round().to_int()
  let zp_clamped = if zero_point < q_min {
    q_min
  } else if zero_point > q_max {
    q_max
  } else {
    zero_point
  }
  (scale, zp_clamped)
}

///|
/// INT8 量化。
/// INT8 quantization.
pub fn quantize_int8(
  input : Array[Double],
  config : QuantizationConfig,
) -> QuantizedTensor {
  let mut min_val = config.calibration_min
  let mut max_val = config.calibration_max
  if !config.per_channel {
    for v in input {
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
  }
  let (scale, zero_point) = compute_quant_params(min_val, max_val, 8)
  let quantized : Array[Int] = []
  for v in input {
    let q = (v / scale).round().to_int() + zero_point
    let clamped = if q < -128 { -128 } else if q > 127 { 127 } else { q }
    quantized.push(clamped)
  }
  QuantizedTensor::{ data: quantized, scale, zero_point, bits: 8, }
}

///|
/// INT4 量化。
/// INT4 quantization.
pub fn quantize_int4(
  input : Array[Double],
  config : QuantizationConfig,
) -> QuantizedTensor {
  let mut min_val = config.calibration_min
  let mut max_val = config.calibration_max
  if !config.per_channel {
    for v in input {
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
  }
  let (scale, zero_point) = compute_quant_params(min_val, max_val, 4)
  let quantized : Array[Int] = []
  for v in input {
    let q = (v / scale).round().to_int() + zero_point
    let clamped = if q < -8 { -8 } else if q > 7 { 7 } else { q }
    quantized.push(clamped)
  }
  QuantizedTensor::{ data: quantized, scale, zero_point, bits: 4, }
}

///|
/// 反量化。
/// Dequantization.
pub fn dequantize(tensor : QuantizedTensor) -> Array[Double] {
  let result : Array[Double] = []
  for q in tensor.data {
    let val = (q - tensor.zero_point).to_double() * tensor.scale
    result.push(val)
  }
  result
}

///|
/// 逐通道量化。
/// Per-channel quantization.
pub fn quantize_per_channel(
  input : Array[Double],
  num_channels : Int,
  bits : Int,
) -> Array[QuantizedTensor] {
  let result : Array[QuantizedTensor] = []
  let per_channel = input.length() / num_channels
  for c in 0..<num_channels {
    let channel_data : Array[Double] = []
    for i in 0..<per_channel {
      let idx = c * per_channel + i
      if idx < input.length() {
        channel_data.push(input[idx])
      }
    }
    let mut min_val = 1.7976931348623157e308
    let mut max_val = -1.7976931348623157e308
    for v in channel_data {
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
    let (scale, zero_point) = compute_quant_params(min_val, max_val, bits)
    let q_min = if bits == 4 { -8 } else { -128 }
    let q_max = if bits == 4 { 7 } else { 127 }
    let quantized : Array[Int] = []
    for v in channel_data {
      let q = (v / scale).round().to_int() + zero_point
      let clamped = if q < q_min {
        q_min
      } else if q > q_max {
        q_max
      } else {
        q
      }
      quantized.push(clamped)
    }
    result.push(QuantizedTensor::{ data: quantized, scale, zero_point, bits, })
  }
  result
}

///|
/// 混合精度量化。
/// Mixed precision quantization.
pub fn mixed_precision_quantize(
  input : Array[Double],
  threshold : Double,
) -> Array[QuantizedTensor] {
  let int8_data : Array[Double] = []
  let int4_data : Array[Double] = []
  for v in input {
    if v.abs() > threshold {
      int8_data.push(v)
    } else {
      int4_data.push(v)
    }
  }
  let result : Array[QuantizedTensor] = []
  if int8_data.length() > 0 {
    let config : QuantizationConfig = {
      bits: 8,
      per_channel: false,
      symmetric: true,
      calibration_min: 0.0,
      calibration_max: 0.0,
    }
    result.push(quantize_int8(int8_data, config))
  }
  if int4_data.length() > 0 {
    let config : QuantizationConfig = {
      bits: 4,
      per_channel: false,
      symmetric: true,
      calibration_min: 0.0,
      calibration_max: 0.0,
    }
    result.push(quantize_int4(int4_data, config))
  }
  result
}

///|
/// 计算量化误差。
/// Compute quantization error.
pub fn compute_quantization_error(
  original : Array[Double],
  quantized : QuantizedTensor,
) -> Double {
  let dequant = dequantize(quantized)
  let mut error = 0.0
  let n = original.length()
  let m = dequant.length()
  let len = if n < m { n } else { m }
  if len == 0 {
    return 0.0
  }
  for i in 0..<len {
    let diff = original[i] - dequant[i]
    error = error + diff * diff
  }
  (error / len.to_double()).sqrt()
}
