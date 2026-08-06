///|
test "write_hdr_to_bytes: round-trip with loadf_from_bytes" {
  let img = loadf_from_path("testdata/test_4x4_red.png")
  let hdr_bytes = write_hdr_to_bytes(img)
  let img2 = loadf_from_bytes(hdr_bytes)
  assert_eq(img2.width, img.width)
  assert_eq(img2.height, img.height)
  assert_eq(img2.channels, img.channels)
  assert_eq(img2.data.length(), img.data.length())
  let _ = img2
  let _ = img
}

///|
test "write_hdr_to_bytes: 1x1 float image" {
  let img = loadf_from_bytes(make_1x1_red_bmp())
  let hdr_bytes = write_hdr_to_bytes(img)
  let img2 = loadf_from_bytes(hdr_bytes)
  assert_eq(img2.width, 1)
  assert_eq(img2.height, 1)
  assert_eq(img2.channels, 3)
  assert_eq(img2.data.length(), 12)
}

///|
test "write_hdr_to_path: round-trip with loadf_from_path" {
  let img = loadf_from_path("testdata/test_4x4_red.png")
  write_hdr_to_path("testdata/roundtrip_out.hdr", img)
  let img2 = loadf_from_path("testdata/roundtrip_out.hdr")
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  assert_eq(img2.channels, 3)
}

///|
test "write_hdr_to_bytes: req_channels=1 grayscale float" {
  let img = loadf_from_path("testdata/test_4x4_red.png", req_channels=Some(1))
  let hdr_bytes = write_hdr_to_bytes(img)
  let img2 = loadf_from_bytes(hdr_bytes)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  let _ = img
  let _ = img2
}