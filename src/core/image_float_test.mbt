///|
test "loadf_from_path: PNG returns correct ImageF with float pixels" {
  let img = loadf_from_path("testdata/test_4x4_red.png")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
  // float: 4 * 4 * 3 * 4 = 192 bytes
  assert_eq(img.data.length(), 192)
  // 红色 R=255 -> float 1.0 = IEEE 754 little-endian [0x00, 0x00, 0x80, 0x3F]
  assert_eq(img.data[0].to_int(), 0)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 128)
  assert_eq(img.data[3].to_int(), 63)
  // 绿色 G=0 -> float 0.0 = [0x00, 0x00, 0x00, 0x00]
  assert_eq(img.data[4].to_int(), 0)
  assert_eq(img.data[5].to_int(), 0)
  assert_eq(img.data[6].to_int(), 0)
  assert_eq(img.data[7].to_int(), 0)
}

///|
test "loadf_from_bytes: BMP returns correct ImageF" {
  let bmp = make_1x1_red_bmp()
  let img = loadf_from_bytes(bmp)
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 3)
  // float: 1 * 1 * 3 * 4 = 12 bytes
  assert_eq(img.data.length(), 12)
  // R=255 -> float 1.0 = [0x00, 0x00, 0x80, 0x3F]
  assert_eq(img.data[0].to_int(), 0)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 128)
  assert_eq(img.data[3].to_int(), 63)
}

///|
test "loadf_from_bytes: empty bytes raises DecodeFailed" {
  let empty = b""
  try {
    let _ = loadf_from_bytes(empty)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "loadf_from_bytes: invalid data raises DecodeFailed" {
  let invalid = b"\x00\x01\x02\x03"
  try {
    let _ = loadf_from_bytes(invalid)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "loadf_from_path: req_channels=1 returns grayscale float" {
  let img = loadf_from_path("testdata/test_4x4_red.png", req_channels=Some(1))
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 1)
  // float: 4 * 4 * 1 * 4 = 64 bytes
  assert_eq(img.data.length(), 64)
}
