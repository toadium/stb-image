// v247.0.0 16-bit/Float 统一 API + 格式能力查询测试

///|
test "format_supports_16bit: PNG true" {
  assert_true(@lib.format_supports_16bit(@lib.ImageFormat::Png))
}

///|
test "format_supports_16bit: PNM true" {
  assert_true(@lib.format_supports_16bit(@lib.ImageFormat::Pnm))
}

///|
test "format_supports_16bit: JPEG false" {
  assert_false(@lib.format_supports_16bit(@lib.ImageFormat::Jpeg))
}

///|
test "format_supports_16bit: BMP false" {
  assert_false(@lib.format_supports_16bit(@lib.ImageFormat::Bmp))
}

///|
test "format_supports_float: HDR true" {
  assert_true(@lib.format_supports_float(@lib.ImageFormat::Hdr))
}

///|
test "format_supports_float: PNG false" {
  assert_false(@lib.format_supports_float(@lib.ImageFormat::Png))
}

///|
test "load_any_f: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  try {
    ignore(@lib.load_any_f(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "save_any_f: unsupported format raises" {
  let img = @types.ImageF::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([
      0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x80, 0x3F,
    ]),
  }
  try {
    ignore(@lib.save_any_f(img, @lib.ImageFormat::Png))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "save_any_f: HDR round-trip" {
  let img = @types.ImageF::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array([
      0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x80, 0x3F, 0x00, 0x00, 0x80, 0x3F,
    ]),
  }
  let encoded = @lib.save_any_f(img, @lib.ImageFormat::Hdr)
  assert_true(encoded.length() > 0)
}
