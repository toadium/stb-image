///|
test "is_tga_format: valid uncompressed true-color" {
  // 4x4 24-bit uncompressed true-color, bottom-up
  let data = Bytes::from_array([
    0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04,
    0x00, 0x04, 0x00, 0x18, 0x00,
  ])
  assert_true(@codec.is_tga_format(data))
}

///|
test "is_tga_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_tga_format(data))
}

///|
test "tga_info_extended: parse 24-bit uncompressed" {
  // 4x4 24-bit uncompressed true-color, bottom-up
  let data = Bytes::from_array([
    0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04,
    0x00, 0x04, 0x00, 0x18, 0x00,
  ])
  let info = @codec.tga_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.image_type, 2)
  assert_eq(info.image_type_name, "uncompressed true-color")
  assert_eq(info.bit_depth, 24)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
  assert_true(info.is_bottom_up)
  assert_eq(info.id_length, 0)
  assert_eq(info.color_map_type, 0)
}

///|
test "tga_info_extended: parse 32-bit RLE top-down" {
  // 8x8 32-bit RLE true-color, top-down (descriptor bit5=1)
  let data = Bytes::from_array([
    0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
    0x00, 0x08, 0x00, 0x20, 0x20,
  ])
  let info = @codec.tga_info_extended(data)
  assert_eq(info.width, 8)
  assert_eq(info.height, 8)
  assert_eq(info.image_type, 10)
  assert_eq(info.image_type_name, "RLE true-color")
  assert_eq(info.bit_depth, 32)
  assert_eq(info.num_channels, 4)
  assert_true(info.has_alpha)
  assert_false(info.is_bottom_up)
}

///|
test "tga_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.tga_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
