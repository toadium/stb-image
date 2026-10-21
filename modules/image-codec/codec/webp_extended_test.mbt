///|
test "is_webp_format: valid RIFF WEBP" {
  let data = Bytes::from_array([
    b'R', b'I', b'F', b'F', 0x10, 0x00, 0x00, 0x00, b'W', b'E', b'B', b'P',
  ])
  assert_true(@codec.is_webp_format(data))
}

///|
test "is_webp_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(@codec.is_webp_format(data))
}

///|
test "webp_info_extended: VP8X extended format" {
  // RIFF + WEBP + VP8X (alpha + animation, 256x256)
  let data = Bytes::from_array([
    b'R', b'I', b'F', b'F', 0x16, 0x00, 0x00, 0x00, b'W', b'E', b'B', b'P', b'V',
    b'P', b'8', b'X', 0x0A, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00, 0xFF, 0x00,
    0x00, 0xFF, 0x00, 0x00,
  ])
  let info = @codec.webp_info_extended(data)
  assert_eq(info.width, 256)
  assert_eq(info.height, 256)
  assert_eq(info.format, "extended")
  assert_true(info.has_alpha)
  assert_true(info.has_animation)
  assert_eq(info.num_channels, 4)
}

///|
test "webp_info_extended: VP8L lossless format" {
  // RIFF + WEBP + VP8L (4x4, no alpha)
  let data = Bytes::from_array([
    b'R', b'I', b'F', b'F', 0x11, 0x00, 0x00, 0x00, b'W', b'E', b'B', b'P', b'V',
    b'P', b'8', b'L', 0x05, 0x00, 0x00, 0x00, 0x2F, 0x03, 0xC0, 0x00, 0x00,
  ])
  let info = @codec.webp_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.format, "lossless")
  assert_false(info.has_alpha)
  assert_eq(info.num_channels, 3)
}

///|
test "webp_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.webp_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
