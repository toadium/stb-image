///|
test "to_grayscale: RGB → 1 channel" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let gray = to_grayscale(img)
  assert_eq(gray.width, 4)
  assert_eq(gray.height, 4)
  assert_eq(gray.channels, 1)
  let _ = img
  let _ = gray
}

///|
test "to_grayscale: already grayscale is identity" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(1),
  )
  let gray = to_grayscale(img)
  assert_eq(gray.channels, 1)
  assert_eq(gray.data, img.data)
  let _ = img
  let _ = gray
}

///|
test "to_rgb: RGBA → RGB" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(4),
  )
  let rgb = to_rgb(img)
  assert_eq(rgb.channels, 3)
  assert_eq(rgb.data.length(), 4 * 4 * 3)
  let _ = img
  let _ = rgb
}

///|
test "to_rgb: already RGB is identity" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let rgb = to_rgb(img)
  assert_eq(rgb.channels, 3)
  assert_eq(rgb.data, img.data)
  let _ = img
  let _ = rgb
}

///|
test "to_rgba: RGB → RGBA" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let rgba = to_rgba(img)
  assert_eq(rgba.channels, 4)
  assert_eq(rgba.data.length(), 4 * 4 * 4)
  // alpha should be 255
  assert_eq(rgba.data[3].to_int(), 255)
  let _ = img
  let _ = rgba
}

///|
test "to_rgba: already RGBA is identity" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(4),
  )
  let rgba = to_rgba(img)
  assert_eq(rgba.channels, 4)
  assert_eq(rgba.data, img.data)
  let _ = img
  let _ = rgba
}

///|
test "premultiply_alpha: full opacity is identity" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(4),
  )
  let premul = premultiply_alpha(img)
  // alpha=255 → premultiply is identity
  assert_eq(premul.data, img.data)
  let _ = img
  let _ = premul
}

///|
test "premultiply/unpremultiply round-trip" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(4),
  )
  let premul = premultiply_alpha(img)
  let restored = unpremultiply_alpha(premul)
  assert_eq(restored.width, 4)
  assert_eq(restored.height, 4)
  let _ = img
  let _ = restored
}

///|
test "premultiply_alpha: non-RGBA raises" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  try {
    let _ = premultiply_alpha(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "to_grayscale: red pixel luminance" {
  let img = @lib.load_from_bytes_auto(make_1x1_red_bmp(), req_channels=Some(3))
  let gray = to_grayscale(img)
  // R=255, G=0, B=0 → Y = 0.299*255 = 76
  assert_eq(gray.data[0].to_int(), 76)
  let _ = img
  let _ = gray
}
