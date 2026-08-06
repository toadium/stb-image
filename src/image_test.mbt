///|
test "load_from_bytes: 1x1 BMP returns correct Image" {
  let bmp = make_1x1_red_bmp()
  let img = load_from_bytes(bmp)
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 3)
  assert_eq(img.data.length(), 3)
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "load_from_bytes: 2x2 BMP returns correct Image" {
  let bmp = make_2x2_colors_bmp()
  let img = load_from_bytes(bmp)
  assert_eq(img.width, 2)
  assert_eq(img.height, 2)
  assert_eq(img.channels, 3)
  assert_eq(img.data.length(), 12)
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "load_from_bytes: empty bytes raises DecodeFailed" {
  let empty = b""
  try {
    let _ = load_from_bytes(empty)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_from_bytes: invalid data raises DecodeFailed" {
  let invalid = b"\x00\x01\x02\x03"
  try {
    let _ = load_from_bytes(invalid)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_from_path: PNG file returns correct Image" {
  let img = load_from_path("testdata/test_4x4_red.png")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
  assert_eq(img.data.length(), 48)
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "load_from_path: BMP file returns correct Image" {
  let img = load_from_path("testdata/test_4x4_red.bmp")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 3)
  assert_eq(img.data.length(), 48)
  assert_eq(img.data[0].to_int(), 255)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "load_from_path: GIF file returns correct dimensions" {
  let img = load_from_path("testdata/test_4x4_red.gif")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
}

///|
test "load_from_path: JPEG file returns correct dimensions" {
  let img = load_from_path("testdata/test_4x4_red.jpg")
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
}

///|
test "load_from_path: nonexistent file raises DecodeFailed" {
  try {
    let _ = load_from_path("testdata/nonexistent.png")
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_from_path: corrupt file raises DecodeFailed" {
  try {
    let _ = load_from_path("testdata/corrupt_truncated.png")
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}