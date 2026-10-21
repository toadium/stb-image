///|
test "is_jpeg_format: valid" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xE0])
  assert_true(@codec.is_jpeg_format(data))
}

///|
test "is_jpeg_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_jpeg_format(data))
}

///|
test "jpeg_info_extended: parse baseline JPEG" {
  // SOI + SOF0 for 4x4 3-component baseline JPEG
  // SOF0 segment: length=17, precision=8, height=4, width=4, 3 components
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x04, 0x00, 0x04, 0x03, 0x01,
    0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
  ])
  let info = @codec.jpeg_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.precision, 8)
  assert_eq(info.num_components, 3)
  assert_false(info.is_grayscale)
  assert_false(info.is_progressive)
  assert_eq(info.sof_marker, 0xC0)
  assert_eq(info.sof_name, "Baseline DCT")
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
}

///|
test "jpeg_info_extended: parse progressive JPEG" {
  // SOI + SOF2 for 8x8 3-component progressive JPEG
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xC2, 0x00, 0x11, 0x08, 0x00, 0x08, 0x00, 0x08, 0x03, 0x01,
    0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
  ])
  let info = @codec.jpeg_info_extended(data)
  assert_eq(info.width, 8)
  assert_eq(info.height, 8)
  assert_eq(info.num_components, 3)
  assert_true(info.is_progressive)
  assert_eq(info.sof_marker, 0xC2)
  assert_eq(info.sof_name, "Progressive DCT")
}

///|
test "jpeg_info_extended: parse grayscale JPEG" {
  // SOI + SOF0 for 2x2 1-component grayscale JPEG
  // length = 8 + 3*1 = 11
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xC0, 0x00, 0x0B, 0x08, 0x00, 0x02, 0x00, 0x02, 0x01, 0x01,
    0x11, 0x00,
  ])
  let info = @codec.jpeg_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 2)
  assert_eq(info.num_components, 1)
  assert_true(info.is_grayscale)
  assert_eq(info.num_channels, 1)
}

///|
test "jpeg_info_extended: skip APP0 before SOF0" {
  // SOI + APP0(JFIF) + SOF0
  // APP0: FF E0 00 10 4A 46 49 46 00 01 01 00 00 01 00 01 00 00
  // SOF0: FF C0 00 11 08 00 04 00 04 03 01 22 00 02 11 01 03 11 01
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01, 0x01,
    0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00,
    0x04, 0x00, 0x04, 0x03, 0x01, 0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
  ])
  let info = @codec.jpeg_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.sof_marker, 0xC0)
}

///|
test "jpeg_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.jpeg_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
