///|
test "is_hdr_format: valid" {
  // "#?RGBE\n"
  let data = Bytes::from_array([0x23, 0x3F, 0x52, 0x47, 0x42, 0x45, 0x0A])
  assert_true(@codec.is_hdr_format(data))
}

///|
test "is_hdr_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_hdr_format(data))
}

///|
test "hdr_info_extended: parse basic HDR" {
  // "#?RGBE\nFORMAT=32-bit_rle_rgbe\n-Y 4 +X 4\n"
  let data = Bytes::from_array([
    0x23, 0x3F, 0x52, 0x47, 0x42, 0x45, 0x0A, 0x46, 0x4F, 0x52, 0x4D, 0x41, 0x54,
    0x3D, 0x33, 0x32, 0x2D, 0x62, 0x69, 0x74, 0x5F, 0x72, 0x6C, 0x65, 0x5F, 0x72,
    0x67, 0x62, 0x65, 0x0A, 0x2D, 0x59, 0x20, 0x34, 0x20, 0x2B, 0x58, 0x20, 0x34,
    0x0A,
  ])
  let info = @codec.hdr_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
}

///|
test "hdr_info_extended: parse without FORMAT line" {
  // "#?RGBE\n-Y 2 +X 3\n"
  let data = Bytes::from_array([
    0x23, 0x3F, 0x52, 0x47, 0x42, 0x45, 0x0A, 0x2D, 0x59, 0x20, 0x32, 0x20, 0x2B,
    0x58, 0x20, 0x33, 0x0A,
  ])
  let info = @codec.hdr_info_extended(data)
  assert_eq(info.width, 3)
  assert_eq(info.height, 2)
}

///|
test "hdr_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.hdr_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
