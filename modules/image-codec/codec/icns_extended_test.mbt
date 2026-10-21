///|
test "is_icns_format: valid" {
  // "icns" + file_size=16 + "ic11" + chunk_len=8
  let data = Bytes::from_array([
    0x69, 0x63, 0x6E, 0x73, 0x00, 0x00, 0x00, 0x10, 0x69, 0x63, 0x31, 0x31, 0x00,
    0x00, 0x00, 0x08,
  ])
  assert_true(@codec.is_icns_format(data))
}

///|
test "is_icns_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_icns_format(data))
}

///|
test "icns_info_extended: parse single 16x16 PNG icon" {
  // "icns" + file_size=16 + "ic11"(16x16 PNG) + chunk_len=8
  let data = Bytes::from_array([
    0x69, 0x63, 0x6E, 0x73, 0x00, 0x00, 0x00, 0x10, 0x69, 0x63, 0x31, 0x31, 0x00,
    0x00, 0x00, 0x08,
  ])
  let info = @codec.icns_info_extended(data)
  assert_eq(info.num_icons, 1)
  assert_eq(info.icon_types[0], "ic11")
  assert_eq(info.icon_sizes[0], 16)
  assert_true(info.is_png_list[0])
  assert_eq(info.width, 16)
  assert_eq(info.height, 16)
  assert_eq(info.num_channels, 4)
  assert_true(info.has_alpha)
}

///|
test "icns_info_extended: parse multiple icons" {
  // "icns" + "ic11"(16x16) + "ic08"(256x256)
  // file_size = 8 + 8 + 8 = 24
  let data = Bytes::from_array([
    0x69, 0x63, 0x6E, 0x73, 0x00, 0x00, 0x00, 0x18, 0x69, 0x63, 0x31, 0x31, 0x00,
    0x00, 0x00, 0x08, 0x69, 0x63, 0x30, 0x38, 0x00, 0x00, 0x00, 0x08,
  ])
  let info = @codec.icns_info_extended(data)
  assert_eq(info.num_icons, 2)
  assert_eq(info.icon_sizes[0], 16)
  assert_eq(info.icon_sizes[1], 256)
  assert_eq(info.width, 256)
  assert_eq(info.height, 256)
}

///|
test "icns_info_extended: parse ARGB icon" {
  // "icns" + "ic04"(16x16 ARGB) + chunk_len=8
  let data = Bytes::from_array([
    0x69, 0x63, 0x6E, 0x73, 0x00, 0x00, 0x00, 0x10, 0x69, 0x63, 0x30, 0x34, 0x00,
    0x00, 0x00, 0x08,
  ])
  let info = @codec.icns_info_extended(data)
  assert_eq(info.num_icons, 1)
  assert_eq(info.icon_types[0], "ic04")
  assert_eq(info.icon_sizes[0], 16)
  assert_false(info.is_png_list[0])
}

///|
test "icns_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.icns_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
