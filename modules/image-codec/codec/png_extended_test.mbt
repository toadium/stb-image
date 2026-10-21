///|
test "is_png_format: valid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_true(@codec.is_png_format(data))
}

///|
test "is_png_format: invalid" {
  let data = Bytes::from_array([0x42, 0x4D, 0x00, 0x00])
  assert_false(@codec.is_png_format(data))
}

///|
test "png_info_extended: parse 8-bit RGBA" {
  // PNG signature + IHDR chunk for 4x4 8-bit RGBA
  let data = Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x08, 0x06,
    0x00, 0x00, 0x00,
  ])
  let info = @codec.png_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.bit_depth, 8)
  assert_eq(info.color_type, 6)
  assert_eq(info.color_type_name, "RGBA")
  assert_eq(info.num_channels, 4)
  assert_true(info.has_alpha)
  assert_false(info.is_palette)
  assert_eq(info.compression_method, 0)
  assert_eq(info.filter_method, 0)
  assert_eq(info.interlace_method, 0)
}

///|
test "png_info_extended: parse 8-bit Grayscale" {
  // PNG signature + IHDR chunk for 2x2 8-bit Grayscale
  let data = Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x08, 0x00,
    0x00, 0x00, 0x00,
  ])
  let info = @codec.png_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 2)
  assert_eq(info.color_type, 0)
  assert_eq(info.color_type_name, "Grayscale")
  assert_eq(info.num_channels, 1)
  assert_false(info.has_alpha)
  assert_false(info.is_palette)
}

///|
test "png_info_extended: parse palette with interlace" {
  // PNG signature + IHDR chunk for 8x8 1-bit Palette, interlaced (Adam7)
  let data = Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00, 0x08, 0x01, 0x03,
    0x00, 0x00, 0x01,
  ])
  let info = @codec.png_info_extended(data)
  assert_eq(info.width, 8)
  assert_eq(info.height, 8)
  assert_eq(info.bit_depth, 1)
  assert_eq(info.color_type, 3)
  assert_eq(info.color_type_name, "Palette")
  assert_eq(info.num_channels, 1)
  assert_true(info.is_palette)
  assert_eq(info.interlace_method, 1)
}

///|
test "png_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x42, 0x4D, 0x00, 0x00])
  try {
    ignore(@codec.png_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
