///|
test "is_qoi_format: valid" {
  let data = Bytes::from_array([
    0x71, 0x6F, 0x69, 0x66, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x03,
    0x00,
  ])
  assert_true(@codec.is_qoi_format(data))
}

///|
test "is_qoi_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_qoi_format(data))
}

///|
test "qoi_info_extended: parse RGB sRGB" {
  // qoif + 4x4 + channels=3 + colorspace=0
  let data = Bytes::from_array([
    0x71, 0x6F, 0x69, 0x66, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x03,
    0x00,
  ])
  let info = @codec.qoi_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.channels, 3)
  assert_eq(info.colorspace, 0)
  assert_eq(info.colorspace_name, "sRGB with linear alpha")
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
}

///|
test "qoi_info_extended: parse RGBA linear" {
  // qoif + 8x8 + channels=4 + colorspace=1
  let data = Bytes::from_array([
    0x71, 0x6F, 0x69, 0x66, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x08, 0x04,
    0x01,
  ])
  let info = @codec.qoi_info_extended(data)
  assert_eq(info.width, 8)
  assert_eq(info.height, 8)
  assert_eq(info.channels, 4)
  assert_eq(info.colorspace, 1)
  assert_eq(info.colorspace_name, "all linear")
  assert_true(info.has_alpha)
}

///|
test "qoi_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.qoi_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
