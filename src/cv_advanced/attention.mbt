// 注意力机制 — SelfAttention/CrossAttention/MultiHead
// Attention mechanisms
//
// Phase 13 v332: 深度学习大扩展 — 注意力机制。

///|
/// 注意力类型。
/// Attention type.
pub(all) enum AttentionType {
  SelfAttention
  CrossAttention
  MultiHead
} derive(Eq, @debug.Debug)

///|
pub extend AttentionType with @debug.Debug::{to_repr}

///|
pub extend AttentionType with Eq::{not_equal, equal}

///|
/// 注意力参数。
/// Attention parameters.
pub(all) struct AttentionParams {
  d_model : Int
  num_heads : Int
  d_k : Int
  d_v : Int
  scale : Double
} derive(Eq, @debug.Debug)

///|
pub extend AttentionParams with @debug.Debug::{to_repr}

///|
pub extend AttentionParams with Eq::{not_equal, equal}

///|
/// softmax 函数。
/// Softmax function.
pub fn softmax(input : Array[Double]) -> Array[Double] {
  let mut max_val = -1.7976931348623157e308
  for v in input {
    if v > max_val {
      max_val = v
    }
  }
  let result : Array[Double] = []
  let mut sum = 0.0
  for v in input {
    let e = @math.exp(v - max_val)
    result.push(e)
    sum = sum + e
  }
  if sum > 0.0 {
    for i in 0..<result.length() {
      result[i] = result[i] / sum
    }
  }
  result
}

///|
/// 缩放点积注意力。
/// Scaled dot-product attention.
pub fn scaled_dot_product_attention(
  query : Array[Double],
  key : Array[Double],
  value : Array[Double],
  scale : Double,
) -> Array[Double] {
  let q_len = query.length()
  let k_len = key.length()
  let v_len = value.length()
  if k_len == 0 || v_len == 0 {
    return []
  }
  let scores : Array[Double] = []
  for i in 0..<q_len {
    let k_idx = if i < k_len { i } else { k_len - 1 }
    let score = query[i] * key[k_idx] * scale
    scores.push(score)
  }
  let attn_weights = softmax(scores)
  let result : Array[Double] = []
  for i in 0..<q_len {
    let v_idx = if i < v_len { i } else { v_len - 1 }
    result.push(attn_weights[i] * value[v_idx])
  }
  result
}

///|
/// 自注意力。
/// Self-attention.
pub fn self_attention(
  input : Array[Double],
  weight_q : Array[Double],
  weight_k : Array[Double],
  weight_v : Array[Double],
  params : AttentionParams,
) -> Array[Double] {
  let q = matmul(input, weight_q, params.d_model, params.d_k)
  let k = matmul(input, weight_k, params.d_model, params.d_k)
  let v = matmul(input, weight_v, params.d_model, params.d_v)
  scaled_dot_product_attention(q, k, v, params.scale)
}

///|
/// 交叉注意力。
/// Cross-attention.
pub fn cross_attention(
  query_input : Array[Double],
  key_input : Array[Double],
  value_input : Array[Double],
  weight_q : Array[Double],
  weight_k : Array[Double],
  weight_v : Array[Double],
  params : AttentionParams,
) -> Array[Double] {
  let q = matmul(query_input, weight_q, params.d_model, params.d_k)
  let k = matmul(key_input, weight_k, params.d_model, params.d_k)
  let v = matmul(value_input, weight_v, params.d_model, params.d_v)
  scaled_dot_product_attention(q, k, v, params.scale)
}

///|
/// 多头注意力。
/// Multi-head attention.
pub fn multi_head_attention(
  input : Array[Double],
  weight_q : Array[Double],
  weight_k : Array[Double],
  weight_v : Array[Double],
  weight_o : Array[Double],
  params : AttentionParams,
) -> Array[Double] {
  let head_dim = params.d_k / params.num_heads
  let head_results : Array[Double] = []
  for h in 0..<params.num_heads {
    let offset_q = h * head_dim * params.d_model
    let offset_k = h * head_dim * params.d_model
    let offset_v = h * head_dim * params.d_model
    let q = matmul_offset(input, weight_q, params.d_model, head_dim, offset_q)
    let k = matmul_offset(input, weight_k, params.d_model, head_dim, offset_k)
    let v = matmul_offset(input, weight_v, params.d_model, head_dim, offset_v)
    let head_out = scaled_dot_product_attention(q, k, v, params.scale)
    for val in head_out {
      head_results.push(val)
    }
  }
  matmul(head_results, weight_o, params.d_k, params.d_model)
}

///|
/// 正弦位置编码。
/// Sinusoidal positional encoding.
pub fn positional_encoding(seq_len : Int, d_model : Int) -> Array[Double] {
  let result : Array[Double] = []
  for pos in 0..<seq_len {
    let mut i = 0
    while i < d_model {
      let angle = pos.to_double() /
        @math.pow(10000.0, i.to_double() / d_model.to_double())
      result.push(@math.sin(angle))
      if i + 1 < d_model {
        result.push(@math.cos(angle))
      }
      i = i + 2
    }
  }
  result
}

///|
/// 矩阵乘法（简化版）。
/// Matrix multiplication (simplified).
fn matmul(
  input : Array[Double],
  weight : Array[Double],
  in_dim : Int,
  out_dim : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  for o in 0..<out_dim {
    let mut sum = 0.0
    for i in 0..<in_dim {
      let w_idx = o * in_dim + i
      if i < input.length() && w_idx < weight.length() {
        sum = sum + input[i] * weight[w_idx]
      }
    }
    result.push(sum)
  }
  result
}

///|
/// 带偏移的矩阵乘法。
/// Matrix multiplication with offset.
fn matmul_offset(
  input : Array[Double],
  weight : Array[Double],
  in_dim : Int,
  out_dim : Int,
  offset : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  for o in 0..<out_dim {
    let mut sum = 0.0
    for i in 0..<in_dim {
      let w_idx = offset + o * in_dim + i
      if i < input.length() && w_idx < weight.length() {
        sum = sum + input[i] * weight[w_idx]
      }
    }
    result.push(sum)
  }
  result
}
