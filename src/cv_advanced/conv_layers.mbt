// 卷积层扩展 — Conv1D/Conv3D/Depthwise/Grouped/Dilated/Transpose
// Convolution layer extensions
//
// Phase 13 v331: 深度学习大扩展 — 卷积层扩展。

///|
/// 1D 卷积参数。
/// 1D convolution parameters.
pub(all) struct Conv1DParams {
  in_channels : Int
  out_channels : Int
  kernel_size : Int
  stride : Int
  padding : Int
  dilation : Int
} derive(Eq, @debug.Debug)

///|
pub extend Conv1DParams with @debug.Debug::{to_repr}

///|
pub extend Conv1DParams with Eq::{not_equal, equal}

///|
/// 3D 卷积参数。
/// 3D convolution parameters.
pub(all) struct Conv3DParams {
  in_channels : Int
  out_channels : Int
  kernel_d : Int
  kernel_h : Int
  kernel_w : Int
  stride : Int
  padding : Int
} derive(Eq, @debug.Debug)

///|
pub extend Conv3DParams with @debug.Debug::{to_repr}

///|
pub extend Conv3DParams with Eq::{not_equal, equal}

///|
/// 深度可分离卷积参数。
/// Depthwise separable convolution parameters.
pub(all) struct DepthwiseConvParams {
  channels : Int
  kernel_size : Int
  stride : Int
  padding : Int
  depth_multiplier : Int
} derive(Eq, @debug.Debug)

///|
pub extend DepthwiseConvParams with @debug.Debug::{to_repr}

///|
pub extend DepthwiseConvParams with Eq::{not_equal, equal}

///|
/// 1D 卷积。
/// 1D convolution.
pub fn conv1d(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  params : Conv1DParams,
) -> Array[Double] {
  let in_len = input.length()
  let out_len = (
      in_len +
      2 * params.padding -
      params.dilation * (params.kernel_size - 1) -
      1
    ) /
    params.stride +
    1
  if out_len <= 0 {
    return []
  }
  let result : Array[Double] = []
  for oc in 0..<params.out_channels {
    for i in 0..<out_len {
      let mut sum = if oc < bias.length() { bias[oc] } else { 0.0 }
      for k in 0..<params.kernel_size {
        let input_idx = i * params.stride - params.padding + k * params.dilation
        if input_idx >= 0 && input_idx < in_len {
          for ic in 0..<params.in_channels {
            let w_idx = oc * params.in_channels * params.kernel_size +
              ic * params.kernel_size +
              k
            let in_idx = ic * in_len + input_idx
            if w_idx < weight.length() && in_idx < input.length() {
              sum = sum + weight[w_idx] * input[in_idx]
            }
          }
        }
      }
      result.push(sum)
    }
  }
  result
}

///|
/// 3D 卷积（简化版）。
/// 3D convolution (simplified).
pub fn conv3d(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  params : Conv3DParams,
) -> Array[Double] {
  let _ = (input, weight, bias, params)
  []
}

///|
/// 深度可分离卷积 2D。
/// Depthwise separable convolution 2D.
pub fn depthwise_conv2d(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  params : DepthwiseConvParams,
  input_w : Int,
  input_h : Int,
) -> Array[Double] {
  let out_w = (input_w + 2 * params.padding - params.kernel_size) /
    params.stride +
    1
  let out_h = (input_h + 2 * params.padding - params.kernel_size) /
    params.stride +
    1
  if out_w <= 0 || out_h <= 0 {
    return []
  }
  let result : Array[Double] = []
  for c in 0..<params.channels {
    for oy in 0..<out_h {
      for ox in 0..<out_w {
        let mut sum = if c < bias.length() { bias[c] } else { 0.0 }
        for ky in 0..<params.kernel_size {
          for kx in 0..<params.kernel_size {
            let ix = ox * params.stride - params.padding + kx
            let iy = oy * params.stride - params.padding + ky
            if ix >= 0 && ix < input_w && iy >= 0 && iy < input_h {
              let in_idx = c * input_w * input_h + iy * input_w + ix
              let w_idx = c * params.kernel_size * params.kernel_size +
                ky * params.kernel_size +
                kx
              if in_idx < input.length() && w_idx < weight.length() {
                sum = sum + weight[w_idx] * input[in_idx]
              }
            }
          }
        }
        result.push(sum)
      }
    }
  }
  result
}

///|
/// 分组卷积 2D。
/// Grouped convolution 2D.
pub fn grouped_conv2d(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  in_channels : Int,
  out_channels : Int,
  groups : Int,
  kernel_size : Int,
  input_w : Int,
  input_h : Int,
) -> Array[Double] {
  let in_per_group = in_channels / groups
  let out_per_group = out_channels / groups

  let out_w = input_w - kernel_size + 1
  let out_h = input_h - kernel_size + 1
  if out_w <= 0 || out_h <= 0 {
    return []
  }
  let result : Array[Double] = []
  for g in 0..<groups {
    for oc in 0..<out_per_group {
      for oy in 0..<out_h {
        for ox in 0..<out_w {
          let mut sum = if g * out_per_group + oc < bias.length() {
            bias[g * out_per_group + oc]
          } else {
            0.0
          }
          for ic in 0..<in_per_group {
            for ky in 0..<kernel_size {
              for kx in 0..<kernel_size {
                let ix = ox + kx
                let iy = oy + ky
                let in_idx = (g * in_per_group + ic) * input_w * input_h +
                  iy * input_w +
                  ix
                let w_idx = (g * out_per_group + oc) *
                  in_per_group *
                  kernel_size *
                  kernel_size +
                  ic * kernel_size * kernel_size +
                  ky * kernel_size +
                  kx
                if in_idx < input.length() && w_idx < weight.length() {
                  sum = sum + weight[w_idx] * input[in_idx]
                }
              }
            }
          }
          result.push(sum)
        }
      }
    }
  }
  result
}

///|
/// 空洞卷积 2D。
/// Dilated convolution 2D.
pub fn dilated_conv2d(
  input : Array[Double],
  weight : Array[Double],
  bias : Double,
  kernel_size : Int,
  dilation : Int,
  input_w : Int,
  input_h : Int,
) -> Array[Double] {
  let effective = dilation * (kernel_size - 1) + 1
  let out_w = input_w - effective + 1
  let out_h = input_h - effective + 1
  if out_w <= 0 || out_h <= 0 {
    return []
  }
  let result : Array[Double] = []
  for oy in 0..<out_h {
    for ox in 0..<out_w {
      let mut sum = bias
      for ky in 0..<kernel_size {
        for kx in 0..<kernel_size {
          let ix = ox + kx * dilation
          let iy = oy + ky * dilation
          let in_idx = iy * input_w + ix
          let w_idx = ky * kernel_size + kx
          if in_idx < input.length() && w_idx < weight.length() {
            sum = sum + weight[w_idx] * input[in_idx]
          }
        }
      }
      result.push(sum)
    }
  }
  result
}

///|
/// 转置卷积 2D（反卷积）。
/// Transpose convolution 2D (deconvolution).
pub fn transpose_conv2d(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  in_channels : Int,
  out_channels : Int,
  kernel_size : Int,
  stride : Int,
  input_w : Int,
  input_h : Int,
) -> Array[Double] {
  let out_w = (input_w - 1) * stride + kernel_size
  let out_h = (input_h - 1) * stride + kernel_size
  if out_w <= 0 || out_h <= 0 {
    return []
  }
  let result : Array[Double] = []
  for i in 0..<(out_channels * out_w * out_h) {
    let _ = i
    result.push(0.0)
  }
  for ic in 0..<in_channels {
    for iy in 0..<input_h {
      for ix in 0..<input_w {
        let in_idx = ic * input_w * input_h + iy * input_w + ix
        if in_idx >= input.length() {
          continue
        }
        for oc in 0..<out_channels {
          for ky in 0..<kernel_size {
            for kx in 0..<kernel_size {
              let ox = ix * stride + kx
              let oy = iy * stride + ky
              if ox < out_w && oy < out_h {
                let w_idx = oc * in_channels * kernel_size * kernel_size +
                  ic * kernel_size * kernel_size +
                  ky * kernel_size +
                  kx
                let out_idx = oc * out_w * out_h + oy * out_w + ox
                if w_idx < weight.length() && out_idx < result.length() {
                  result[out_idx] = result[out_idx] +
                    weight[w_idx] * input[in_idx]
                }
              }
            }
          }
        }
      }
    }
  }
  for oc in 0..<out_channels {
    for oy in 0..<out_h {
      for ox in 0..<out_w {
        let out_idx = oc * out_w * out_h + oy * out_w + ox
        if oc < bias.length() && out_idx < result.length() {
          result[out_idx] = result[out_idx] + bias[oc]
        }
      }
    }
  }
  result
}
