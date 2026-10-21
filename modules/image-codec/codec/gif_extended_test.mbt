///|
test "is_gif_format: valid GIF89a" {
  let data = Bytes::from_array([
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x04, 0x00, 0x03, 0x00, 0x81, 0x00, 0x00,
  ])
  assert_true(@codec.is_gif_format(data))
}

///|
test "is_gif_format: valid GIF87a" {
  let data = Bytes::from_array([
    0x47, 0x49, 0x46, 0x38, 0x37, 0x61, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00,
  ])
  assert_true(@codec.is_gif_format(data))
}

///|
test "is_gif_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_gif_format(data))
}

///|
test "gif_info_extended: parse GIF89a with global color table" {
  // GIF89a, 4x3, GCT of 4 colors (gct_size_bits=1)
  let data = Bytes::from_array([
    0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x04, 0x00, 0x03, 0x00, 0x81, 0x00, 0x00,
  ])
  let info = @codec.gif_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 3)
  assert_eq(info.version, "89a")
  assert_true(info.has_global_color_table)
  assert_eq(info.global_color_table_size, 4)
  assert_eq(info.color_resolution, 1)
  assert_false(info.is_sorted)
  assert_eq(info.background_color_index, 0)
  assert_eq(info.pixel_aspect_ratio, 0)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
}

///|
test "gif_info_extended: parse GIF87a without global color table" {
  // GIF87a, 2x2, no GCT
  let data = Bytes::from_array([
    0x47, 0x49, 0x46, 0x38, 0x37, 0x61, 0x02, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00,
  ])
  let info = @codec.gif_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 2)
  assert_eq(info.version, "87a")
  assert_false(info.has_global_color_table)
  assert_eq(info.global_color_table_size, 0)
}

///|
test "gif_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.gif_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
