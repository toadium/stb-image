///|
test "detect_format: PNG" {
  let data = b"\x89PNG\r\n\x1a\n\x00\x00\x00\x0dIHDR"
  assert_eq(detect_format(data), ImageFormat::Png)
}

///|
test "detect_format: JPEG" {
  let data = b"\xff\xd8\xff\xe0\x00\x10JFIF"
  assert_eq(detect_format(data), ImageFormat::Jpeg)
}

///|
test "detect_format: BMP" {
  let data = b"BM\x00\x00\x00\x00"
  assert_eq(detect_format(data), ImageFormat::Bmp)
}

///|
test "detect_format: GIF" {
  let data = b"GIF89a\x01\x00"
  assert_eq(detect_format(data), ImageFormat::Gif)
}

///|
test "detect_format: PSD" {
  let data = b"8BPS\x00\x01"
  assert_eq(detect_format(data), ImageFormat::Psd)
}

///|
test "detect_format: HDR" {
  let data = b"#?RADIANCE\n"
  assert_eq(detect_format(data), ImageFormat::Hdr)
}

///|
test "detect_format: PNM (PPM)" {
  let data = b"P6\n4 4\n255\n"
  assert_eq(detect_format(data), ImageFormat::Pnm)
}

///|
test "detect_format: QOI" {
  let data = b"qoif\x00\x00\x00\x04"
  assert_eq(detect_format(data), ImageFormat::Qoi)
}

///|
test "detect_format: unknown" {
  let data = b"\x00\x01\x02\x03"
  assert_eq(detect_format(data), ImageFormat::Unknown)
}

///|
test "detect_format: empty" {
  let data = b""
  assert_eq(detect_format(data), ImageFormat::Unknown)
}

///|
test "detect_format: real PNG file" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let png_bytes = write_png_to_bytes(img)
  assert_eq(detect_format(png_bytes), ImageFormat::Png)
  let _ = img
}

///|
test "detect_format: real BMP file" {
  let bmp = make_1x1_red_bmp()
  assert_eq(detect_format(bmp), ImageFormat::Bmp)
}

///|
test "decode_any: BMP auto-detect" {
  let bmp = make_1x1_red_bmp()
  let img = decode_any(bmp)
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 3)
  let _ = img
}

///|
test "decode_any: PNG auto-detect with req_channels" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let png_bytes = write_png_to_bytes(img)
  let img2 = decode_any(png_bytes, req_channels=Some(1))
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  assert_eq(img2.channels, 1)
  let _ = img
  let _ = img2
}

///|
test "is_supported_format: PNG true" {
  let data = b"\x89PNG\r\n\x1a\n"
  assert_true(is_supported_format(data))
}

///|
test "is_supported_format: unknown false" {
  let data = b"\x00\x01\x02\x03"
  assert_false(is_supported_format(data))
}