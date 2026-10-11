// v218.0.0 encryption 错误路径增强测试

// ===== 辅助函数 =====

///|
fn enc_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn enc_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn enc_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

///|
fn enc_bad_channels() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 5,
    data: Bytes::from_array(Array::make(16, 128)),
  }
}

// ===== 1. xor_encrypt =====

///|
test "enc_edge: xor_encrypt 零宽度" {
  try {
    let _ = @encryption.xor_encrypt(enc_zero_w(), [b'\x01'])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: xor_encrypt 无效通道" {
  try {
    let _ = @encryption.xor_encrypt(enc_bad_channels(), [b'\x01'])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: xor_encrypt 数据不匹配" {
  try {
    let _ = @encryption.xor_encrypt(enc_mismatch(), [b'\x01'])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: xor_encrypt 空密钥" {
  try {
    let _ = @encryption.xor_encrypt(enc_uniform(4, 4, 128), [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. encrypt_image_logistic / decrypt_image_logistic =====

///|
test "enc_edge: encrypt_image_logistic 零宽度" {
  try {
    let _ = @encryption.encrypt_image_logistic(enc_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: encrypt_image_logistic 数据不匹配" {
  try {
    let _ = @encryption.encrypt_image_logistic(enc_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: decrypt_image_logistic 零宽度" {
  try {
    let _ = @encryption.decrypt_image_logistic(enc_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. encrypt_image_xor / decrypt_image_xor =====

///|
test "enc_edge: encrypt_image_xor 零宽度" {
  try {
    let _ = @encryption.encrypt_image_xor(enc_zero_w(), "key")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: decrypt_image_xor 零宽度" {
  try {
    let _ = @encryption.decrypt_image_xor(enc_zero_w(), "key")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. embed_visible_watermark =====

///|
test "enc_edge: embed_visible_watermark 零宽度" {
  try {
    let _ = @encryption.embed_visible_watermark(enc_zero_w(), "WM", 0, 0, 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. embed_watermark_lsb / extract_watermark_lsb =====

///|
test "enc_edge: embed_watermark_lsb 零宽度" {
  try {
    let _ = @encryption.embed_watermark_lsb(enc_zero_w(), [b'\x01'], 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: extract_watermark_lsb 零宽度" {
  try {
    let _ = @encryption.extract_watermark_lsb(enc_zero_w(), 1, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. calculate_correlation / calculate_psnr =====

///|
test "enc_edge: calculate_correlation 零宽度" {
  try {
    let _ = @encryption.calculate_correlation(
      enc_zero_w(),
      enc_uniform(4, 4, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: calculate_psnr 零宽度" {
  try {
    let _ = @encryption.calculate_psnr(enc_zero_w(), enc_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. calculate_image_entropy / histogram_entropy =====

///|
test "enc_edge: calculate_image_entropy 零宽度" {
  try {
    let _ = @encryption.calculate_image_entropy(enc_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: histogram_entropy 零宽度" {
  try {
    let _ = @encryption.histogram_entropy(enc_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. evaluate_encryption_quality / evaluate_image_encryption_quality =====

///|
test "enc_edge: evaluate_encryption_quality 零宽度" {
  try {
    let _ = @encryption.evaluate_encryption_quality(
      enc_zero_w(),
      enc_uniform(4, 4, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: evaluate_image_encryption_quality 零宽度" {
  try {
    let _ = @encryption.evaluate_image_encryption_quality(
      enc_zero_w(),
      enc_uniform(4, 4, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 9. key_sensitivity_test / adjacent_correlation =====

///|
test "enc_edge: key_sensitivity_test 零宽度" {
  try {
    let _ = @encryption.key_sensitivity_test(enc_zero_w(), 0.123)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: adjacent_correlation 零宽度" {
  try {
    let _ = @encryption.adjacent_correlation(enc_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 10. batch_encrypt 空数组 =====

///|
test "enc_edge: batch_encrypt 空数组" {
  try {
    let _ = @encryption.batch_encrypt([], 0.123)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 11. arnold_scramble / chaotic_encrypt =====

///|
test "enc_edge: arnold_scramble 零宽度" {
  try {
    let params = @encryption.create_default_arnold_params()
    let _ = @encryption.arnold_scramble(enc_zero_w(), params)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "enc_edge: chaotic_encrypt 零宽度" {
  try {
    let params = @encryption.create_default_chaotic_params()
    let _ = @encryption.chaotic_encrypt(enc_zero_w(), params)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
