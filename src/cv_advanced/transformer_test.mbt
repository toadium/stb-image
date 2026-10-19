// Transformer 模型测试 — Transformer model tests
// Phase 13 v333: 深度学习大扩展 — Transformer。

///|
fn make_transformer_config() -> @cv_advanced.TransformerConfig {
  {
    d_model: 4,
    num_heads: 2,
    d_ff: 8,
    num_encoder_layers: 1,
    num_decoder_layers: 1,
    dropout: 0.1,
    scale: 0.5,
  }
}

///|
test "layer_norm: 基本归一化" {
  let input = [1.0, 2.0, 3.0, 4.0]
  let gamma = [1.0, 1.0, 1.0, 1.0]
  let beta = [0.0, 0.0, 0.0, 0.0]
  let result = @cv_advanced.layer_norm(input, gamma, beta, 0.000000000001)
  assert_true(result.length() == 4)
  let mut sum = 0.0
  for v in result {
    sum = sum + v
  }
  assert_true(sum > -0.01 && sum < 0.01)
}

///|
test "layer_norm: 空数组" {
  let result = @cv_advanced.layer_norm([], [], [], 0.000000000001)
  assert_true(result.length() == 0)
}

///|
test "feed_forward: 基本前馈" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let w1 = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
    1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
  ]
  let b1 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let w2 = [
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,
  ]
  let b2 = [0.0, 0.0, 0.0, 0.0]
  let result = @cv_advanced.feed_forward(input, w1, b1, w2, b2, 4, 8)
  assert_true(result.length() == 4)
}

///|
test "residual_add: 基本残差" {
  let input = [1.0, 2.0, 3.0]
  let sub = [0.1, 0.2, 0.3]
  let result = @cv_advanced.residual_add(input, sub)
  assert_true(result.length() == 3)
  assert_true(result[0] > 1.09 && result[0] < 1.11)
  assert_true(result[1] > 2.19 && result[1] < 2.21)
  assert_true(result[2] > 3.29 && result[2] < 3.31)
}

///|
test "residual_add: 不同长度" {
  let result = @cv_advanced.residual_add([1.0, 2.0], [1.0])
  assert_true(result.length() == 1)
  assert_true(result[0] > 1.99 && result[0] < 2.01)
}

///|
test "transformer_encode: 基本编码" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let w = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0,
  ]
  let gamma = [1.0, 1.0, 1.0, 1.0]
  let beta = [0.0, 0.0, 0.0, 0.0]
  let w1 = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
    1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
  ]
  let b1 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let w2 = [
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,
  ]
  let b2 = [0.0, 0.0, 0.0, 0.0]
  let config = make_transformer_config()
  let encoder = @cv_advanced.transformer_encode(
    input, w, w, w, gamma, beta, gamma, beta, w1, b1, w2, b2, config,
  )
  assert_true(encoder.hidden.length() == 4)
}

///|
test "transformer_decode: 基本解码" {
  let dec_in = [0.0, 1.0, 0.0, 1.0]
  let enc_out = [1.0, 1.0, 0.0, 0.0]
  let w = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0,
  ]
  let gamma = [1.0, 1.0, 1.0, 1.0]
  let beta = [0.0, 0.0, 0.0, 0.0]
  let w1 = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
    1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0,
  ]
  let b1 = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let w2 = [
    1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0,
  ]
  let b2 = [0.0, 0.0, 0.0, 0.0]
  let config = make_transformer_config()
  let decoder = @cv_advanced.transformer_decode(
    dec_in, enc_out, w, w, w, w, w, w, gamma, beta, gamma, beta, gamma, beta, w1,
    b1, w2, b2, config,
  )
  assert_true(decoder.output.length() == 4)
}

///|
test "TransformerConfig: 构造与字段" {
  let config = make_transformer_config()
  assert_true(config.d_model == 4)
  assert_true(config.num_heads == 2)
  assert_true(config.d_ff == 8)
}

///|
test "TransformerLayerKind: enum 值" {
  let kind1 = @cv_advanced.TransformerLayerKind::EncoderLayer
  let kind2 = @cv_advanced.TransformerLayerKind::DecoderLayer
  assert_true(kind1 != kind2)
}
