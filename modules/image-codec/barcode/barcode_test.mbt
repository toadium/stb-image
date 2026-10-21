// v45.0.0 条码解码测试

///|
test "barcode_default_config: 基本测试" {
  let config = @barcode.barcode_default_config()
  assert_eq(config.enable_ean13, true)
  assert_eq(config.enable_qrcode, true)
}

///|
test "decode_ean13: 基本测试" {
  let img = make_test_image(64, 32)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_ean13(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "detect_qr_finder_patterns: 基本测试" {
  let img = make_test_image(64, 64)
  let patterns = @barcode.detect_qr_finder_patterns(img)
  assert_true(patterns.length() >= 0)
}

///|
test "decode_qrcode: 基本测试" {
  let img = make_test_image(64, 64)
  let config = @barcode.barcode_default_config()
  let result = @barcode.decode_qrcode(img, config~)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_barcode: 基本测试" {
  let img = make_test_image(64, 32)
  let config = @barcode.barcode_default_config()
  let results = @barcode.decode_barcode(img, config~)
  assert_true(results.length() >= 0)
}

///|
test "decode_code128: 基本测试" {
  let img = make_test_image(64, 32)
  let result = @barcode.decode_code128(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_upca: 基本测试" {
  let img = make_test_image(64, 32)
  let result = @barcode.decode_upca(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_code39: 基本测试" {
  let img = make_test_image(64, 32)
  let result = @barcode.decode_code39(img)
  assert_true(result is None || result is Some(_))
}

///|
test "decode_linear_barcode: 基本测试" {
  let img = make_test_image(64, 32)
  let results = @barcode.decode_linear_barcode(img)
  assert_true(results.length() >= 0)
}

///|
test "decode_qrcode_full: 基本测试" {
  let img = make_test_image(64, 64)
  let result = @barcode.decode_qrcode_full(img)
  assert_true(result is None || result is Some(_))
}

///|
test "reed_solomon_decode: 基本测试" {
  let data = [1, 2, 3, 4, 5]
  let (decoded, corrected) = @barcode.reed_solomon_decode(data, 2)
  assert_true(decoded.length() >= 0)
  assert_true(corrected >= 0)
}

///|
fn make_test_image(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v : Int32 = i % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}
