// v232.0.0 qr_decode 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn qrd_make_img(w : Int, h : Int, val : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val.to_byte())),
  }
}

// ========== decode_qrcode_full 错误路径 ==========

///|
test "decode_qrcode_full: channels 5 raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 5,
      data: Bytes::from_array(Array::make(64 * 64 * 5, 128)),
    }
    let _ = @barcode.decode_qrcode_full(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_qrcode_full: data mismatch raises" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 1,
      data: Bytes::from_array(Array::make(100, 128)),
    }
    let _ = @barcode.decode_qrcode_full(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

// ========== decode_qrcode_full 功能路径 ==========

///|
test "decode_qrcode_full: all white returns None" {
  try {
    let result = @barcode.decode_qrcode_full(qrd_make_img(64, 64, 255))
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decode_qrcode_full: all black returns None" {
  try {
    let result = @barcode.decode_qrcode_full(qrd_make_img(64, 64, 0))
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decode_qrcode_full: small image returns None" {
  try {
    let result = @barcode.decode_qrcode_full(qrd_make_img(10, 10, 128))
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decode_qrcode_full: RGB image returns None" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 3,
      data: Bytes::from_array(Array::make(64 * 64 * 3, 255)),
    }
    let result = @barcode.decode_qrcode_full(img)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "decode_qrcode_full: RGBA image returns None" {
  try {
    let img = @types.Image::{
      width: 64,
      height: 64,
      channels: 4,
      data: Bytes::from_array(Array::make(64 * 64 * 4, 255)),
    }
    let result = @barcode.decode_qrcode_full(img)
    assert_true(result is None)
  } catch {
    _ => assert_true(false)
  }
}

// ========== reed_solomon_decode 功能路径 ==========

///|
test "reed_solomon_decode: preserves data integrity" {
  let input = [1, 2, 3, 4, 5, 6, 7, 8]
  let (decoded, errors) = @barcode.reed_solomon_decode(input, 4)
  assert_eq(decoded.length(), 8)
  assert_eq(errors, 0)
  for i in 0..<8 {
    assert_eq(decoded[i], input[i])
  }
}

///|
test "reed_solomon_decode: large ec_bytes" {
  let input = [10, 20, 30]
  let (decoded, errors) = @barcode.reed_solomon_decode(input, 100)
  assert_eq(decoded.length(), 3)
  assert_eq(errors, 0)
}

///|
test "reed_solomon_decode: single element with ec" {
  let (decoded, errors) = @barcode.reed_solomon_decode([42], 5)
  assert_eq(decoded.length(), 1)
  assert_eq(decoded[0], 42)
  assert_eq(errors, 0)
}

///|
test "reed_solomon_decode: empty with ec_bytes" {
  let (decoded, errors) = @barcode.reed_solomon_decode([], 5)
  assert_eq(decoded.length(), 0)
  assert_eq(errors, 0)
}

///|
test "reed_solomon_decode: does not modify original" {
  let input = [1, 2, 3]
  let _ = @barcode.reed_solomon_decode(input, 2)
  assert_eq(input[0], 1)
  assert_eq(input[1], 2)
  assert_eq(input[2], 3)
}
