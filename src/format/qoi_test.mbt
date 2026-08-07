///|
test "encode_qoi: 1x1 RGB image" {
  let img = @core.load_from_bytes(make_1x1_red_bmp(), req_channels=Some(3))
  let qoi_bytes = encode_qoi(img)
  // QOI header: 14 bytes + end: 8 bytes = 22 bytes minimum
  assert_true(qoi_bytes.length() >= 22)
  // 检查 magic
  assert_eq(qoi_bytes[0].to_int(), 0x71) // q
  assert_eq(qoi_bytes[1].to_int(), 0x6F) // o
  assert_eq(qoi_bytes[2].to_int(), 0x69) // i
  assert_eq(qoi_bytes[3].to_int(), 0x66) // f
  let _ = img
  let _ = qoi_bytes
}

///|
test "decode_qoi: round-trip 1x1 RGB" {
  let img = @core.load_from_bytes(make_1x1_red_bmp(), req_channels=Some(3))
  let qoi_bytes = encode_qoi(img)
  let img2 = decode_qoi(qoi_bytes)
  assert_eq(img2.width, 1)
  assert_eq(img2.height, 1)
  assert_eq(img2.channels, 3)
  // 红色像素
  assert_eq(img2.data[0].to_int(), 255)
  assert_eq(img2.data[1].to_int(), 0)
  assert_eq(img2.data[2].to_int(), 0)
  let _ = img
  let _ = img2
}

///|
test "decode_qoi: round-trip 4x4 PNG" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let qoi_bytes = encode_qoi(img)
  let img2 = decode_qoi(qoi_bytes)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  assert_eq(img2.channels, 3)
  assert_eq(img2.data.length(), img.data.length())
  let _ = img
  let _ = img2
}

///|
test "decode_qoi: round-trip RGBA" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let qoi_bytes = encode_qoi(img)
  let img2 = decode_qoi(qoi_bytes)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  assert_eq(img2.channels, 4)
  let _ = img
  let _ = img2
}

///|
test "decode_qoi: invalid magic raises" {
  let bad = b"xxxx\x00\x00\x00\x01\x00\x00\x00\x01\x03\x00"
  try {
    let _ = decode_qoi(bad)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_qoi: too short raises" {
  let short = b"qoi"
  try {
    let _ = decode_qoi(short)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "encode_qoi: invalid channels raises" {
  let img = @core.Image::{ width: 1, height: 1, channels: 2, data: b"\x00\x00" }
  try {
    let _ = encode_qoi(img)
    assert_true(false)
  } catch {
    @core.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_qoi: detect_format recognizes QOI" {
  let img = @core.load_from_bytes(make_1x1_red_bmp(), req_channels=Some(3))
  let qoi_bytes = encode_qoi(img)
  assert_eq(@core.detect_format(qoi_bytes), @core.ImageFormat::Qoi)
  let _ = img
  let _ = qoi_bytes
}
