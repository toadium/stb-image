///|
test "is_avif_format: valid avif brand" {
  // ftyp box with brand "avif"
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(@codec.is_avif_format(data))
}

///|
test "is_avif_format: valid avis brand" {
  // ftyp box with brand "avis" (sequence)
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b's', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_true(@codec.is_avif_format(data))
}

///|
test "is_avif_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(@codec.is_avif_format(data))
}

///|
test "is_avif_format: too short" {
  let data = Bytes::from_array([0x00, 0x00, 0x00])
  assert_false(@codec.is_avif_format(data))
}

///|
test "is_avif_format: ftyp but wrong brand" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  assert_false(@codec.is_avif_format(data))
}

///|
test "avif_info: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.avif_info(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "avif_decode: returns unsupported" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  try {
    ignore(@codec.avif_decode(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
