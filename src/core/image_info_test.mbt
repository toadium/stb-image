///|
// FFI re-declaration for testing (extern "c" fn are file-private in MoonBit)
extern "c" fn test_failure_reason() -> Bytes = "stb_image_mbt_failure_reason"

///|
test "info_from_path: PNG returns correct ImageInfo" {
  let info = info_from_path("testdata/test_4x4_red.png")
  assert_true(info is Some(_))
  let i = info.unwrap()
  assert_eq(i.width, 4)
  assert_eq(i.height, 4)
  assert_eq(i.channels, 3)
}

///|
test "info_from_path: BMP returns correct ImageInfo" {
  let info = info_from_path("testdata/test_4x4_red.bmp")
  assert_true(info is Some(_))
  let i = info.unwrap()
  assert_eq(i.width, 4)
  assert_eq(i.height, 4)
  assert_eq(i.channels, 3)
}

///|
test "info_from_bytes: BMP returns correct ImageInfo" {
  let bmp = make_1x1_red_bmp()
  let info = info_from_bytes(bmp)
  assert_true(info is Some(_))
  let i = info.unwrap()
  assert_eq(i.width, 1)
  assert_eq(i.height, 1)
  assert_eq(i.channels, 3)
}

///|
test "info_from_path: nonexistent file returns None" {
  let info = info_from_path("testdata/nonexistent.png")
  assert_true(info is None)
}

///|
test "info_from_bytes: empty bytes raises DecodeFailed" {
  let empty = b""
  try {
    let _ = info_from_bytes(empty)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "is_16_bit_from_path: 8-bit PNG returns false" {
  let result = is_16_bit_from_path("testdata/test_4x4_red.png")
  assert_false(result)
}

///|
test "is_16_bit_from_bytes: 8-bit BMP returns false" {
  let bmp = make_1x1_red_bmp()
  let result = is_16_bit_from_bytes(bmp)
  assert_false(result)
}

///|
test "is_hdr_from_path: PNG returns false" {
  let result = is_hdr_from_path("testdata/test_4x4_red.png")
  assert_false(result)
}

///|
test "is_hdr_from_bytes: BMP returns false" {
  let bmp = make_1x1_red_bmp()
  let result = is_hdr_from_bytes(bmp)
  assert_false(result)
}

///|
test "failure_reason: returns string after failed load" {
  // 用 corrupt_random.bin 触发 "unknown image type" 错误
  let reason = try {
    let _ = load_from_path("testdata/corrupt_random.bin")
    ""
  } catch {
    _ => failure_reason()
  }
  let bytes_len = test_failure_reason().length()
  // stbi_failure_reason 在 stbi_load 失败后应返回非空字符串
  assert_true(reason.length() > 0 || bytes_len > 0)
}

///|
test "set_unpremultiply_on_load: does not crash" {
  set_unpremultiply_on_load(true)
  set_unpremultiply_on_load(false)
  assert_true(true)
}

///|
test "convert_iphone_png_to_rgb: does not crash" {
  convert_iphone_png_to_rgb(true)
  convert_iphone_png_to_rgb(false)
  assert_true(true)
}
