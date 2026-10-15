// v208 barcode 模块补充错误路径测试

///|
fn bc3_mk_img(w : Int, h : Int, ch : Int, val : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn bc3_mk_bad_data(w : Int, h : Int, ch : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

///|
fn bc3_expect_error(f : () -> Unit raise @types.LoadError) -> Bool {
  try {
    f()
    false
  } catch {
    _ => true
  }
}

// ========== 无效通道错误 ==========

///|
test "bc3: decode_ean13 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_ean13(img))))
}

///|
test "bc3: decode_ean13 无效通道5 raise" {
  let img = bc3_mk_img(8, 8, 5, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_ean13(img))))
}

///|
test "bc3: decode_upca 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_upca(img))))
}

///|
test "bc3: decode_code128 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code128(img))))
}

///|
test "bc3: decode_code39 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code39(img))))
}

///|
test "bc3: decode_linear_barcode 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.decode_linear_barcode(img))),
  )
}

///|
test "bc3: decode_qrcode 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode(img))))
}

///|
test "bc3: decode_qrcode_full 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode_full(img))))
}

///|
test "bc3: decode_barcode 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_barcode(img))))
}

///|
test "bc3: detect_qr_finder_patterns 无效通道0 raise" {
  let img = bc3_mk_img(8, 8, 0, 128)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.detect_qr_finder_patterns(img))),
  )
}

///|
test "bc3: detect_qr_finder_patterns 无效通道5 raise" {
  let img = bc3_mk_img(8, 8, 5, 128)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.detect_qr_finder_patterns(img))),
  )
}

// ========== 数据大小不匹配错误 ==========

///|
test "bc3: decode_ean13 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_ean13(img))))
}

///|
test "bc3: decode_upca 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_upca(img))))
}

///|
test "bc3: decode_code128 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code128(img))))
}

///|
test "bc3: decode_code39 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code39(img))))
}

///|
test "bc3: decode_linear_barcode 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.decode_linear_barcode(img))),
  )
}

///|
test "bc3: decode_qrcode 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode(img))))
}

///|
test "bc3: decode_qrcode_full 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode_full(img))))
}

///|
test "bc3: decode_barcode 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_barcode(img))))
}

///|
test "bc3: detect_qr_finder_patterns 数据不匹配 raise" {
  let img = bc3_mk_bad_data(8, 8, 1)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.detect_qr_finder_patterns(img))),
  )
}

// ========== 零高度错误 ==========

///|
test "bc3: decode_ean13 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_ean13(img))))
}

///|
test "bc3: decode_upca 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_upca(img))))
}

///|
test "bc3: decode_code128 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code128(img))))
}

///|
test "bc3: decode_code39 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_code39(img))))
}

///|
test "bc3: decode_linear_barcode 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.decode_linear_barcode(img))),
  )
}

///|
test "bc3: decode_qrcode 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode(img))))
}

///|
test "bc3: decode_qrcode_full 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_qrcode_full(img))))
}

///|
test "bc3: decode_barcode 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(bc3_expect_error(() => ignore(@barcode.decode_barcode(img))))
}

///|
test "bc3: detect_qr_finder_patterns 零高度 raise" {
  let img = bc3_mk_img(8, 0, 1, 128)
  assert_true(
    bc3_expect_error(() => ignore(@barcode.detect_qr_finder_patterns(img))),
  )
}

// ========== reed_solomon_decode 边界 ==========

///|
test "bc3: reed_solomon_decode 单元素" {
  let (data, errors) = @barcode.reed_solomon_decode([42], 2)
  assert_eq(data.length(), 1)
  assert_eq(data[0], 42)
  assert_eq(errors, 0)
}

///|
test "bc3: reed_solomon_decode ec_bytes=0" {
  let (data, errors) = @barcode.reed_solomon_decode([1, 2, 3], 0)
  assert_eq(data.length(), 3)
  assert_eq(errors, 0)
}
