// Transformer 模型 — Encoder/Decoder/Positional
// Transformer model
//
// Phase 13 v333: 深度学习大扩展 — Transformer。

///|
/// Transformer 层类型。
/// Transformer layer type.
pub(all) enum TransformerLayerKind {
  EncoderLayer
  DecoderLayer
} derive(Eq, @debug.Debug)

///|
pub extend TransformerLayerKind with @debug.Debug::{to_repr}

///|
pub extend TransformerLayerKind with Eq::{not_equal, equal}

///|
/// Transformer 配置。
/// Transformer configuration.
pub(all) struct TransformerConfig {
  d_model : Int32
  num_heads : Int32
  d_ff : Int32
  num_encoder_layers : Int32
  num_decoder_layers : Int32
  dropout : Double
  scale : Double
} derive(Eq, @debug.Debug)

///|
pub extend TransformerConfig with @debug.Debug::{to_repr}

///|
pub extend TransformerConfig with Eq::{not_equal, equal}

///|
/// Transformer 编码器状态。
/// Transformer encoder state.
pub(all) struct TransformerEncoder {
  hidden : Array[Double]
  attention_weights : Array[Double]
  layer_output : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend TransformerEncoder with @debug.Debug::{to_repr}

///|
pub extend TransformerEncoder with Eq::{not_equal, equal}

///|
/// Transformer 解码器状态。
/// Transformer decoder state.
pub(all) struct TransformerDecoder {
  hidden : Array[Double]
  cross_attention_weights : Array[Double]
  self_attention_weights : Array[Double]
  output : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend TransformerDecoder with @debug.Debug::{to_repr}

///|
pub extend TransformerDecoder with Eq::{not_equal, equal}

///|
/// 层归一化。
/// Layer normalization.
pub fn layer_norm(
  input : Array[Double],
  gamma : Array[Double],
  beta : Array[Double],
  eps : Double,
) -> Array[Double] {
  let n = input.length()
  if n == 0 {
    return []
  }
  let mut mean = 0.0
  for v in input {
    mean = mean + v
  }
  mean = mean / n.to_double()
  let mut variance = 0.0
  for v in input {
    let diff = v - mean
    variance = variance + diff * diff
  }
  variance = variance / n.to_double()
  let std_dev = (variance + eps).sqrt()
  let result : Array[Double] = []
  for i in 0..<n {
    let normalized = (input[i] - mean) / std_dev
    let g = if i < gamma.length() { gamma[i] } else { 1.0 }
    let b = if i < beta.length() { beta[i] } else { 0.0 }
    result.push(g * normalized + b)
  }
  result
}

///|
/// 前馈网络。
/// Feed-forward network.
pub fn feed_forward(
  input : Array[Double],
  w1 : Array[Double],
  b1 : Array[Double],
  w2 : Array[Double],
  b2 : Array[Double],
  d_model : Int32,
  d_ff : Int32,
) -> Array[Double] {
  let hidden = linear(input, w1, b1, d_model, d_ff)
  let activated : Array[Double] = []
  for v in hidden {
    if v > 0.0 {
      activated.push(v)
    } else {
      activated.push(0.0)
    }
  }
  linear(activated, w2, b2, d_ff, d_model)
}

///|
/// 残差连接。
/// Residual connection.
pub fn residual_add(
  input : Array[Double],
  sublayer_output : Array[Double],
) -> Array[Double] {
  let result : Array[Double] = []
  let n = input.length()
  let m = sublayer_output.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    result.push(input[i] + sublayer_output[i])
  }
  result
}

///|
/// Transformer 编码器层。
/// Transformer encoder layer.
pub fn transformer_encoder_layer(
  input : Array[Double],
  weight_q : Array[Double],
  weight_k : Array[Double],
  weight_v : Array[Double],
  gamma1 : Array[Double],
  beta1 : Array[Double],
  gamma2 : Array[Double],
  beta2 : Array[Double],
  w1 : Array[Double],
  b1 : Array[Double],
  w2 : Array[Double],
  b2 : Array[Double],
  config : TransformerConfig,
) -> Array[Double] {
  let attn_params : AttentionParams = {
    d_model: config.d_model,
    num_heads: config.num_heads,
    d_k: config.d_model,
    d_v: config.d_model,
    scale: config.scale,
  }
  let attn_out = self_attention(
    input, weight_q, weight_k, weight_v, attn_params,
  )
  let x1 = residual_add(input, attn_out)
  let x1_norm = layer_norm(x1, gamma1, beta1, 0.000000000001)
  let ffn_out = feed_forward(
    x1_norm,
    w1,
    b1,
    w2,
    b2,
    config.d_model,
    config.d_ff,
  )
  let x2 = residual_add(x1_norm, ffn_out)
  layer_norm(x2, gamma2, beta2, 0.000000000001)
}

///|
/// Transformer 解码器层。
/// Transformer decoder layer.
pub fn transformer_decoder_layer(
  decoder_input : Array[Double],
  encoder_output : Array[Double],
  weight_q_self : Array[Double],
  weight_k_self : Array[Double],
  weight_v_self : Array[Double],
  weight_q_cross : Array[Double],
  weight_k_cross : Array[Double],
  weight_v_cross : Array[Double],
  gamma1 : Array[Double],
  beta1 : Array[Double],
  gamma2 : Array[Double],
  beta2 : Array[Double],
  gamma3 : Array[Double],
  beta3 : Array[Double],
  w1 : Array[Double],
  b1 : Array[Double],
  w2 : Array[Double],
  b2 : Array[Double],
  config : TransformerConfig,
) -> Array[Double] {
  let attn_params : AttentionParams = {
    d_model: config.d_model,
    num_heads: config.num_heads,
    d_k: config.d_model,
    d_v: config.d_model,
    scale: config.scale,
  }
  let self_attn_out = self_attention(
    decoder_input, weight_q_self, weight_k_self, weight_v_self, attn_params,
  )
  let x1 = residual_add(decoder_input, self_attn_out)
  let x1_norm = layer_norm(x1, gamma1, beta1, 0.000000000001)
  let cross_attn_out = cross_attention(
    x1_norm, encoder_output, encoder_output, weight_q_cross, weight_k_cross, weight_v_cross,
    attn_params,
  )
  let x2 = residual_add(x1_norm, cross_attn_out)
  let x2_norm = layer_norm(x2, gamma2, beta2, 0.000000000001)
  let ffn_out = feed_forward(
    x2_norm,
    w1,
    b1,
    w2,
    b2,
    config.d_model,
    config.d_ff,
  )
  let x3 = residual_add(x2_norm, ffn_out)
  layer_norm(x3, gamma3, beta3, 0.000000000001)
}

///|
/// Transformer 编码器（多层堆叠）。
/// Transformer encoder (multi-layer stack).
pub fn transformer_encode(
  input : Array[Double],
  weight_q : Array[Double],
  weight_k : Array[Double],
  weight_v : Array[Double],
  gamma1 : Array[Double],
  beta1 : Array[Double],
  gamma2 : Array[Double],
  beta2 : Array[Double],
  w1 : Array[Double],
  b1 : Array[Double],
  w2 : Array[Double],
  b2 : Array[Double],
  config : TransformerConfig,
) -> TransformerEncoder {
  let mut hidden = input
  let attention_weights : Array[Double] = []
  let layer_output : Array[Double] = []
  for _ in 0..<config.num_encoder_layers {
    hidden = transformer_encoder_layer(
      hidden, weight_q, weight_k, weight_v, gamma1, beta1, gamma2, beta2, w1, b1,
      w2, b2, config,
    )
    for v in hidden {
      layer_output.push(v)
    }
  }
  TransformerEncoder::{ hidden, attention_weights, layer_output, }
}

///|
/// Transformer 解码器（多层堆叠）。
/// Transformer decoder (multi-layer stack).
pub fn transformer_decode(
  decoder_input : Array[Double],
  encoder_output : Array[Double],
  weight_q_self : Array[Double],
  weight_k_self : Array[Double],
  weight_v_self : Array[Double],
  weight_q_cross : Array[Double],
  weight_k_cross : Array[Double],
  weight_v_cross : Array[Double],
  gamma1 : Array[Double],
  beta1 : Array[Double],
  gamma2 : Array[Double],
  beta2 : Array[Double],
  gamma3 : Array[Double],
  beta3 : Array[Double],
  w1 : Array[Double],
  b1 : Array[Double],
  w2 : Array[Double],
  b2 : Array[Double],
  config : TransformerConfig,
) -> TransformerDecoder {
  let mut hidden = decoder_input
  let cross_attn_weights : Array[Double] = []
  let self_attn_weights : Array[Double] = []
  for _ in 0..<config.num_decoder_layers {
    hidden = transformer_decoder_layer(
      hidden, encoder_output, weight_q_self, weight_k_self, weight_v_self, weight_q_cross,
      weight_k_cross, weight_v_cross, gamma1, beta1, gamma2, beta2, gamma3, beta3,
      w1, b1, w2, b2, config,
    )
  }
  TransformerDecoder::{
    hidden,
    cross_attention_weights: cross_attn_weights,
    self_attention_weights: self_attn_weights,
    output: hidden,
  }
}

///|
/// Transformer 前向传播（编码器-解码器）。
/// Transformer forward pass (encoder-decoder).
pub fn transformer_forward(
  src_input : Array[Double],
  tgt_input : Array[Double],
  enc_weight_q : Array[Double],
  enc_weight_k : Array[Double],
  enc_weight_v : Array[Double],
  enc_gamma1 : Array[Double],
  enc_beta1 : Array[Double],
  enc_gamma2 : Array[Double],
  enc_beta2 : Array[Double],
  enc_w1 : Array[Double],
  enc_b1 : Array[Double],
  enc_w2 : Array[Double],
  enc_b2 : Array[Double],
  dec_weight_q_self : Array[Double],
  dec_weight_k_self : Array[Double],
  dec_weight_v_self : Array[Double],
  dec_weight_q_cross : Array[Double],
  dec_weight_k_cross : Array[Double],
  dec_weight_v_cross : Array[Double],
  dec_gamma1 : Array[Double],
  dec_beta1 : Array[Double],
  dec_gamma2 : Array[Double],
  dec_beta2 : Array[Double],
  dec_gamma3 : Array[Double],
  dec_beta3 : Array[Double],
  dec_w1 : Array[Double],
  dec_b1 : Array[Double],
  dec_w2 : Array[Double],
  dec_b2 : Array[Double],
  config : TransformerConfig,
) -> TransformerDecoder {
  let encoder = transformer_encode(
    src_input, enc_weight_q, enc_weight_k, enc_weight_v, enc_gamma1, enc_beta1, enc_gamma2,
    enc_beta2, enc_w1, enc_b1, enc_w2, enc_b2, config,
  )
  transformer_decode(
    tgt_input,
    encoder.hidden,
    dec_weight_q_self,
    dec_weight_k_self,
    dec_weight_v_self,
    dec_weight_q_cross,
    dec_weight_k_cross,
    dec_weight_v_cross,
    dec_gamma1,
    dec_beta1,
    dec_gamma2,
    dec_beta2,
    dec_gamma3,
    dec_beta3,
    dec_w1,
    dec_b1,
    dec_w2,
    dec_b2,
    config,
  )
}

///|
/// 线性层。
/// Linear layer.
fn linear(
  input : Array[Double],
  weight : Array[Double],
  bias : Array[Double],
  in_dim : Int32,
  out_dim : Int32,
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
    let b = if o < bias.length() { bias[o] } else { 0.0 }
    result.push(sum + b)
  }
  result
}
