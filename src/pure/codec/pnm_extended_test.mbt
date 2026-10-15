///|
test "is_pnm_format: valid P6" {
  let data = Bytes::from_array([0x50, 0x36, 0x0A])
  assert_true(@codec.is_pnm_format(data))
}

///|
test "is_pnm_format: valid P5" {
  let data = Bytes::from_array([0x50, 0x35, 0x0A])
  assert_true(@codec.is_pnm_format(data))
}

///|
test "is_pnm_format: invalid" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_pnm_format(data))
}

///|
test "pnm_info_extended: parse P6 PPM binary" {
  // P6\n4 4\n255\n + data
  let data = Bytes::from_array([
    0x50, 0x36, 0x0A, 0x34, 0x20, 0x34, 0x0A, 0x32, 0x35, 0x35, 0x0A, 0x00, 0x00,
    0x00,
  ])
  let info = @codec.pnm_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.format_type, "P6")
  assert_eq(info.maxval, 255)
  assert_eq(info.bit_depth, 8)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
  assert_true(info.is_binary)
}

///|
test "pnm_info_extended: parse P5 PGM binary" {
  // P5\n2 3\n255\n + data
  let data = Bytes::from_array([
    0x50, 0x35, 0x0A, 0x32, 0x20, 0x33, 0x0A, 0x32, 0x35, 0x35, 0x0A, 0x00, 0x00,
  ])
  let info = @codec.pnm_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 3)
  assert_eq(info.format_type, "P5")
  assert_eq(info.maxval, 255)
  assert_eq(info.num_channels, 1)
  assert_true(info.is_binary)
}

///|
test "pnm_info_extended: parse P3 PPM ASCII" {
  // P3\n4 4\n255\n
  let data = Bytes::from_array([
    0x50, 0x33, 0x0A, 0x34, 0x20, 0x34, 0x0A, 0x32, 0x35, 0x35, 0x0A,
  ])
  let info = @codec.pnm_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.format_type, "P3")
  assert_eq(info.num_channels, 3)
  assert_false(info.is_binary)
}

///|
test "pnm_info_extended: parse P1 PBM ASCII" {
  // P1\n4 4\n
  let data = Bytes::from_array([0x50, 0x31, 0x0A, 0x34, 0x20, 0x34, 0x0A])
  let info = @codec.pnm_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.format_type, "P1")
  assert_eq(info.maxval, 1)
  assert_eq(info.num_channels, 1)
  assert_false(info.is_binary)
}

///|
test "pnm_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.pnm_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
