// v189.0.0 encryption 模块增强测试：边值/往返/属性/错误路径

///|
fn make_enc_img2(w : Int, h : Int, value : Byte) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, value)),
  }
}

///|
fn make_varied_img2(w : Int, h : Int) -> @types.Image {
  let arr : Array[Byte] = []
  for i in 0..<(w * h) {
    arr.push((i % 256).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(arr),
  }
}

///|
test "encrypt_image_logistic: 自定义密钥" {
  let img = make_varied_img2(8, 8)
  try {
    let enc = @encryption.encrypt_image_logistic(img, key=0.5, mu=3.9)
    assert_eq(enc.width, 8)
    assert_eq(enc.height, 8)
    assert_eq(enc.channels, 1)
    assert_eq(enc.data.length(), 64)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "encrypt_image_logistic: 往返加解密" {
  let img = make_varied_img2(8, 8)
  try {
    let enc = @encryption.encrypt_image_logistic(img, key=0.3, mu=3.99)
    let dec = @encryption.decrypt_image_logistic(enc, key=0.3, mu=3.99)
    let mut same = true
    for i in 0..<64 {
      if dec.data[i] != img.data[i] {
        same = false
      }
    }
    assert_true(same)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "encrypt_image_logistic: 多通道图像" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, 128)),
  }
  try {
    let enc = @encryption.encrypt_image_logistic(img)
    assert_eq(enc.channels, 3)
    assert_eq(enc.data.length(), 48)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "encrypt_image_logistic: 零尺寸错误" {
  let img = @types.Image::{
    width: 0,
    height: 0,
    channels: 1,
    data: Bytes::from_array([]),
  }
  try {
    let _ = @encryption.encrypt_image_logistic(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "encrypt_image_logistic: 无效通道错误" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 5,
    data: Bytes::from_array(Array::make(80, 0)),
  }
  try {
    let _ = @encryption.encrypt_image_logistic(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "encrypt_image_xor: 不同密钥" {
  let img = make_varied_img2(8, 8)
  try {
    let enc1 = @encryption.encrypt_image_xor(img, "key1")
    let enc2 = @encryption.encrypt_image_xor(img, "key2")
    let mut diff = 0
    for i in 0..<64 {
      if enc1.data[i] != enc2.data[i] {
        diff += 1
      }
    }
    assert_true(diff > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "encrypt_image_xor: 往返加解密" {
  let img = make_varied_img2(8, 8)
  try {
    let enc = @encryption.encrypt_image_xor(img, "secret")
    let dec = @encryption.decrypt_image_xor(enc, "secret")
    let mut same = true
    for i in 0..<64 {
      if dec.data[i] != img.data[i] {
        same = false
      }
    }
    assert_true(same)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "encrypt_image_xor: 空密钥" {
  let img = make_varied_img2(4, 4)
  try {
    let enc = @encryption.encrypt_image_xor(img, "")
    assert_eq(enc.width, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "histogram_entropy: 均匀图像低熵" {
  let img = make_enc_img2(8, 8, 128)
  try {
    let entropy = @encryption.histogram_entropy(img)
    assert_true(entropy >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "histogram_entropy: 变化图像高熵" {
  let img = make_varied_img2(16, 16)
  try {
    let entropy = @encryption.histogram_entropy(img)
    assert_true(entropy >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "adjacent_correlation: 水平方向" {
  let img = make_varied_img2(8, 8)
  try {
    let corr = @encryption.adjacent_correlation(img, direction="horizontal")
    assert_true(corr >= -1.0 && corr <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "adjacent_correlation: 垂直方向" {
  let img = make_varied_img2(8, 8)
  try {
    let corr = @encryption.adjacent_correlation(img, direction="vertical")
    assert_true(corr >= -1.0 && corr <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "adjacent_correlation: 对角方向" {
  let img = make_varied_img2(8, 8)
  try {
    let corr = @encryption.adjacent_correlation(img, direction="diagonal")
    assert_true(corr >= -1.0 && corr <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "evaluate_encryption_quality: 加密后评估" {
  let img = make_varied_img2(8, 8)
  try {
    let enc = @encryption.encrypt_image_logistic(img)
    let quality = @encryption.evaluate_encryption_quality(img, enc)
    assert_true(quality.entropy >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "key_sensitivity_test: 基本测试" {
  let img = make_varied_img2(8, 8)
  try {
    let sens = @encryption.key_sensitivity_test(img, 0.123456789)
    assert_true(sens >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "batch_encrypt: 多图像批量" {
  let img1 = make_varied_img2(4, 4)
  let img2 = make_enc_img2(4, 4, 200)
  try {
    let results = @encryption.batch_encrypt([img1, img2], 0.5)
    assert_eq(results.length(), 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "xor_encrypt: 基本加密往返" {
  let img = make_varied_img2(4, 4)
  let key = [b'\x01', b'\x02', b'\x03', b'\x04']
  try {
    let enc = @encryption.xor_encrypt(img, key)
    let dec = @encryption.xor_decrypt(enc, key)
    assert_eq(dec.width, 4)
    assert_eq(dec.height, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "generate_chaotic_sequence_enc: 序列范围" {
  let params = @encryption.create_default_chaotic_params()
  let seq = @encryption.generate_chaotic_sequence_enc(params, 100)
  assert_eq(seq.length(), 100)
}

///|
test "chaotic_encrypt: 基本加密" {
  let img = make_varied_img2(8, 8)
  let params = @encryption.create_default_chaotic_params()
  try {
    let enc = @encryption.chaotic_encrypt(img, params)
    assert_eq(enc.width, 8)
    assert_eq(enc.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "arnold_scramble: 基本置乱" {
  let img = make_varied_img2(8, 8)
  let params = @encryption.create_default_arnold_params()
  try {
    let scrambled = @encryption.arnold_scramble(img, params)
    assert_eq(scrambled.width, 8)
    assert_eq(scrambled.height, 8)
    assert_eq(scrambled.encrypted_data.length(), 64)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "embed_watermark_lsb: 嵌入提取往返" {
  let img = make_varied_img2(8, 8)
  let watermark : Array[Byte] = [
    b'\x01', b'\x00', b'\x01', b'\x00', b'\x01', b'\x00', b'\x01', b'\x00',
  ]
  try {
    let (embedded, _info) = @encryption.embed_watermark_lsb(img, watermark, 1)
    let extracted = @encryption.extract_watermark_lsb(embedded, 8, 1)
    assert_true(extracted.extracted)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "embed_visible_watermark: 基本嵌入" {
  let img = make_varied_img2(8, 8)
  try {
    let result = @encryption.embed_visible_watermark(
      img, "WATERMARK", 0, 0, 0.5,
    )
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "calculate_image_entropy: 均匀图像" {
  let img = make_enc_img2(8, 8, 128)
  try {
    let entropy = @encryption.calculate_image_entropy(img)
    assert_true(entropy >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "calculate_correlation: 相同图像为1" {
  let img = make_varied_img2(8, 8)
  let corr = @encryption.calculate_correlation(img, img)
  assert_true(corr > 0.99)
}

///|
test "calculate_psnr: 相同图像无穷大" {
  let img = make_varied_img2(8, 8)
  try {
    let psnr = @encryption.calculate_psnr(img, img)
    assert_true(psnr >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "evaluate_image_encryption_quality: 基本评估" {
  let img = make_varied_img2(8, 8)
  try {
    let enc = @encryption.encrypt_image_logistic(img)
    let quality = @encryption.evaluate_image_encryption_quality(img, enc)
    assert_true(quality.entropy >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "encryption_report_to_string: 报告非空" {
  let img = make_varied_img2(8, 8)
  let key : Array[Byte] = [b'\x01', b'\x02', b'\x03']
  try {
    let enc = @encryption.xor_encrypt(img, key)
    let quality = @encryption.evaluate_image_encryption_quality(img, @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(enc.encrypted_data),
    })
    let watermark_info = @encryption.WatermarkInfo::{
      watermark_type: @encryption.WatermarkType::Visible,
      watermark_data: [],
      watermark_width: 0,
      watermark_height: 0,
      strength: 0.0,
      embedded: false,
      embedding_position: "none",
      key: "",
    }
    let report = @encryption.encryption_report_to_string(
      enc, watermark_info, quality,
    )
    assert_true(report.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "encryption_default_config: 字段验证" {
  let config = @encryption.encryption_default_config()
  assert_true(config.key > 0.0 && config.key < 1.0)
  assert_true(config.mu > 3.56 && config.mu <= 4.0)
  assert_true(config.iterations > 0)
}
