///|
test "is_heif_format: valid heic brand" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(is_heif_format(data))
}

///|
test "is_heif_format: valid heix brand" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'x', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(is_heif_format(data))
}

///|
test "is_heif_format: valid hevc brand" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'v', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(is_heif_format(data))
}

///|
test "is_heif_format: valid mif1 brand" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'm', b'i', b'f', b'1', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(is_heif_format(data))
}

///|
test "is_heif_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(is_heif_format(data))
}

///|
test "is_heif_format: too short" {
  let data = Bytes::from_array([0x00, 0x00, 0x00])
  assert_false(is_heif_format(data))
}

///|
test "heif_info: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(heif_info(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "heif_decode: returns unsupported" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  try {
    ignore(heif_decode(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
