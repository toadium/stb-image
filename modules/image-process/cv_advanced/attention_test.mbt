// 注意力机制测试 — Attention mechanism tests
// Phase 13 v332: 深度学习大扩展 — 注意力机制。

///|
test "softmax: 基本归一化" {
  let input = [1.0, 2.0, 3.0]
  let result = @cv_advanced.softmax(input)
  let mut sum = 0.0
  for v in result {
    sum = sum + v
  }
  assert_true(sum > 0.99 && sum < 1.01)
  assert_true(result.length() == 3)
}

///|
test "softmax: 空数组" {
  let result = @cv_advanced.softmax([])
  assert_true(result.length() == 0)
}

///|
test "softmax: 单元素" {
  let result = @cv_advanced.softmax([5.0])
  assert_true(result.length() == 1)
  assert_true(result[0] > 0.99 && result[0] < 1.01)
}

///|
test "scaled_dot_product_attention: 基本注意力" {
  let query = [1.0, 0.0, 0.0]
  let key = [1.0, 0.0, 0.0]
  let value = [1.0, 2.0, 3.0]
  let result = @cv_advanced.scaled_dot_product_attention(query, key, value, 1.0)
  assert_true(result.length() == 3)
}

///|
test "scaled_dot_product_attention: 空key" {
  let result = @cv_advanced.scaled_dot_product_attention([1.0], [], [1.0], 1.0)
  assert_true(result.length() == 0)
}

///|
test "self_attention: 基本自注意力" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let w = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
  let params : @cv_advanced.AttentionParams = {
    d_model: 2,
    num_heads: 1,
    d_k: 2,
    d_v: 2,
    scale: 0.5,
  }
  let result = @cv_advanced.self_attention(input, w, w, w, params)
  assert_true(result.length() == 2)
}

///|
test "cross_attention: 基本交叉注意力" {
  let q_in = [1.0, 0.0]
  let k_in = [0.0, 1.0]
  let v_in = [1.0, 1.0]
  let w = [1.0, 0.0, 0.0, 1.0]
  let params : @cv_advanced.AttentionParams = {
    d_model: 2,
    num_heads: 1,
    d_k: 2,
    d_v: 2,
    scale: 1.0,
  }
  let result = @cv_advanced.cross_attention(q_in, k_in, v_in, w, w, w, params)
  assert_true(result.length() == 2)
}

///|
test "multi_head_attention: 多头注意力" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let w = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
  let w_o = [1.0, 0.0, 0.0, 1.0]
  let params : @cv_advanced.AttentionParams = {
    d_model: 2,
    num_heads: 2,
    d_k: 2,
    d_v: 2,
    scale: 0.5,
  }
  let result = @cv_advanced.multi_head_attention(input, w, w, w, w_o, params)
  assert_true(result.length() == 2)
}

///|
test "positional_encoding: 基本位置编码" {
  let result = @cv_advanced.positional_encoding(3, 4)
  assert_true(result.length() == 12)
  let mut has_nonzero = false
  for v in result {
    if v != 0.0 {
      has_nonzero = true
    }
  }
  assert_true(has_nonzero)
}
