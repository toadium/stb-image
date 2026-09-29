///|
test "is_jpegxl_format: valid codestream" {
  // 裸码流: 0xFF 0x0A
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x00])
  assert_true(is_jpegxl_format(data))
}

///|
test "is_jpegxl_format: valid container" {
  // ISOBMFF 容器: 0x00 0x00 0x00 0x0C 0x4A 0x58 0x4C 0x20 0x0D 0x0A 0x87 0x0A
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, b'J', b'X', b'L', b' ', 0x0D, 0x0A, 0x87, 0x0A,
  ])
  assert_true(is_jpegxl_format(data))
}

///|
test "is_jpegxl_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(is_jpegxl_format(data))
}

///|
test "is_jpegxl_format: too short" {
  let data = Bytes::from_array([0xFF])
  assert_false(is_jpegxl_format(data))
}

///|
test "is_jpegxl_codestream: true for bare codestream" {
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x00])
  assert_true(is_jpegxl_codestream(data))
}

///|
test "is_jpegxl_codestream: false for container" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, b'J', b'X', b'L', b' ', 0x0D, 0x0A, 0x87, 0x0A,
  ])
  assert_false(is_jpegxl_codestream(data))
}

///|
test "is_jpegxl_container: true for container" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, b'J', b'X', b'L', b' ', 0x0D, 0x0A, 0x87, 0x0A,
  ])
  assert_true(is_jpegxl_container(data))
}

///|
test "is_jpegxl_container: false for codestream" {
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x00])
  assert_false(is_jpegxl_container(data))
}

///|
test "jpegxl_info: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(jpegxl_info(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "jpegxl_decode: returns unsupported" {
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x00])
  try {
    ignore(jpegxl_decode(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
