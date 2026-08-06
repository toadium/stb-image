///|
test "encode_gif: 1x1 RGB" {
  let img = load_from_bytes(make_1x1_red_bmp(), req_channels=Some(3))
  let gif = encode_gif(img)
  // 检查 GIF89a header
  assert_eq(gif[0].to_int(), 0x47) // G
  assert_eq(gif[1].to_int(), 0x49) // I
  assert_eq(gif[2].to_int(), 0x46) // F
  assert_eq(gif[3].to_int(), 0x38) // 8
  assert_eq(gif[4].to_int(), 0x39) // 9
  assert_eq(gif[5].to_int(), 0x61) // a
  let _ = img
  let _ = gif
}

///|
test "encode_gif: 4x4 PNG → GIF round-trip" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let gif = encode_gif(img)
  // 用 load_from_bytes 解码回来
  let img2 = load_from_bytes(gif)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  let _ = img
  let _ = img2
  let _ = gif
}

///|
test "encode_gif: RGBA (alpha ignored)" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let gif = encode_gif(img)
  let img2 = load_from_bytes(gif)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  let _ = img
  let _ = img2
  let _ = gif
}

///|
test "encode_gif: invalid channels raises" {
  let img = Image::{ width: 1, height: 1, channels: 2, data: b"\x00\x00" }
  try {
    let _ = encode_gif(img)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "encode_gif: detect_format recognizes GIF" {
  let img = load_from_bytes(make_1x1_red_bmp(), req_channels=Some(3))
  let gif = encode_gif(img)
  assert_eq(detect_format(gif), ImageFormat::Gif)
  let _ = img
  let _ = gif
}

///|
test "encode_gif: 2x2 colors" {
  let img = load_from_bytes(make_2x2_colors_bmp(), req_channels=Some(3))
  let gif = encode_gif(img)
  let img2 = load_from_bytes(gif)
  assert_eq(img2.width, 2)
  assert_eq(img2.height, 2)
  let _ = img
  let _ = img2
  let _ = gif
}

///|
test "encode_gif: larger image 32x32" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let resized = resize(img, 32, 32, filter=ResizeFilter::PointSample)
  let gif = encode_gif(resized)
  let img2 = load_from_bytes(gif)
  assert_eq(img2.width, 32)
  assert_eq(img2.height, 32)
  let _ = img
  let _ = resized
  let _ = img2
  let _ = gif
}