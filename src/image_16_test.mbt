///|
test "load_16_from_path: PNG returns correct Image16 with 16-bit pixels" {
  let img = load_16_from_path("testdata/test_4x4_red.png")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
  // 16-bit: 4 * 4 * 3 * 2 = 96 bytes
  assert_eq(img.data.length(), 96)
  // 红色 R=255 提升为 16-bit 65535 = 0xFFFF (little-endian: [0xFF, 0xFF])
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 255)
  // 绿色 G=0 -> 16-bit 0 = [0x00, 0x00]
  assert_eq(img.data[2].to_int(), 0)
  assert_eq(img.data[3].to_int(), 0)
  // 蓝色 B=0 -> 16-bit 0 = [0x00, 0x00]
  assert_eq(img.data[4].to_int(), 0)
  assert_eq(img.data[5].to_int(), 0)
}

///|
test "load_16_from_bytes: BMP returns correct Image16" {
  let bmp = make_1x1_red_bmp()
  let img = load_16_from_bytes(bmp)
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 3)
  // 16-bit: 1 * 1 * 3 * 2 = 6 bytes
  assert_eq(img.data.length(), 6)
  // R=255 -> 65535 = [0xFF, 0xFF]
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 255)
}

///|
test "load_16_from_bytes: empty bytes raises DecodeFailed" {
  let empty = b""
  try {
    let _ = load_16_from_bytes(empty)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_16_from_bytes: invalid data raises DecodeFailed" {
  let invalid = b"\x00\x01\x02\x03"
  try {
    let _ = load_16_from_bytes(invalid)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_16_from_path: req_channels=1 returns grayscale 16-bit" {
  let img = load_16_from_path("testdata/test_4x4_red.png", req_channels=Some(1))
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 1)
  // 16-bit: 4 * 4 * 1 * 2 = 32 bytes
  assert_eq(img.data.length(), 32)
}

///|
test "load_16_from_path: req_channels=4 returns RGBA 16-bit" {
  let img = load_16_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 4)
  // 16-bit: 4 * 4 * 4 * 2 = 128 bytes
  assert_eq(img.data.length(), 128)
}