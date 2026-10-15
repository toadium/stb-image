///|
test "jpegxl_info_extended: bare codestream small header" {
  // 裸码流: 0xFF 0x0A + SizeHeader
  // small=0, selector=00, height=2, ratio=000, width=height=2
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x00, 0x00, 0x00])
  let info = @codec.jpegxl_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 2)
  assert_true(info.is_codestream)
}

///|
test "jpegxl_info_extended: bare codestream with ratio" {
  // small=1, height-1=7 (00111), ratio=1 (001) → height=8, width=8*4/3=10
  // byte0: 1 00111 00 = 0x9C, byte1: 1 0000000 = 0x80
  let data = Bytes::from_array([0xFF, 0x0A, 0x9C, 0x80, 0x00, 0x00])
  let info = @codec.jpegxl_info_extended(data)
  assert_eq(info.width, 10)
  assert_eq(info.height, 8)
  assert_true(info.is_codestream)
}

///|
test "jpegxl_info_extended: container format" {
  // ISOBMFF container: ftyp(12) + jxlc(12) with codestream 00 00 00 00
  let data = Bytes::from_array([
    // ftyp "JXL " (12 bytes)
    0x00, 0x00, 0x00, 0x0C, b'J', b'X', b'L', b' ', 0x0D, 0x0A, 0x87, 0x0A,
    // jxlc box (12 bytes): codestream at offset 20
     0x00, 0x00, 0x00, 0x0C, b'j', b'x', b'l', b'c', 0x00, 0x00, 0x00, 0x00,
  ])
  let info = @codec.jpegxl_info_extended(data)
  assert_eq(info.width, 2)
  assert_eq(info.height, 2)
  assert_false(info.is_codestream)
}

///|
test "jpegxl_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.jpegxl_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "jpegxl_info_extended: container without codestream raises" {
  // ftyp(12) + free box (12, no jxlc)
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, b'J', b'X', b'L', b' ', 0x0D, 0x0A, 0x87, 0x0A, 0x00,
    0x00, 0x00, 0x0C, b'f', b'r', b'e', b'e', 0x00, 0x00, 0x00, 0x00,
  ])
  try {
    ignore(@codec.jpegxl_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "jpegxl_info_extended: bare codestream ratio 2" {
  // small=1, height-1=15 (01111), ratio=2 (010) → height=16, width=16*3/2=24
  // byte0: 1 01111 01 = 0xBD, byte1: 0 0000000 = 0x00
  let data = Bytes::from_array([0xFF, 0x0A, 0xBD, 0x00, 0x00, 0x00])
  let info = @codec.jpegxl_info_extended(data)
  assert_eq(info.height, 16)
  assert_eq(info.width, 24)
}
