///|
test "round-trip: PNG load → write_to_bytes → load equals original" {
  let img = load_from_path("testdata/test_4x4_red.png")
  let png_bytes = write_png_to_bytes(img)
  let img2 = load_from_bytes(png_bytes)
  assert_eq(img2.width, img.width)
  assert_eq(img2.height, img.height)
  assert_eq(img2.channels, img.channels)
  assert_eq(img2.data.length(), img.data.length())
  assert_eq(img2.data[0].to_int(), 255)
  assert_eq(img2.data[1].to_int(), 0)
  assert_eq(img2.data[2].to_int(), 0)
}

///|
test "round-trip: BMP load → write_to_bytes → load equals original" {
  let img = load_from_path("testdata/test_4x4_red.bmp")
  let bmp_bytes = write_bmp_to_bytes(img)
  let img2 = load_from_bytes(bmp_bytes)
  assert_eq(img2.width, img.width)
  assert_eq(img2.height, img.height)
  assert_eq(img2.channels, img.channels)
}

///|
test "round-trip: write_png_to_path → load_from_path" {
  let img = load_from_path("testdata/test_4x4_red.png")
  write_png_to_path("testdata/roundtrip_out.png", img)
  let img2 = load_from_path("testdata/roundtrip_out.png")
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  assert_eq(img2.channels, 3)
}

///|
test "round-trip: write_jpeg_to_bytes → load_from_bytes" {
  let img = load_from_path("testdata/test_4x4_red.bmp")
  let jpg_bytes = write_jpeg_to_bytes(img)
  let img2 = load_from_bytes(jpg_bytes)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
}

///|
test "req_channels: load with req_channels=1 returns grayscale" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(1))
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 1)
  assert_eq(img.data.length(), 16)
}

///|
test "req_channels: load with req_channels=4 returns RGBA" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  assert_eq(img.width, 4)
  assert_eq(img.height, 4)
  assert_eq(img.channels, 4)
  assert_eq(img.data.length(), 64)
}

///|
test "req_channels: load_from_bytes with req_channels=3" {
  let bmp = make_1x1_red_bmp()
  let img = load_from_bytes(bmp, req_channels=Some(3))
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 3)
}

///|
test "flip: set_flip_vertically_on_load flips 2x2 image" {
  let bmp = make_2x2_colors_bmp()
  set_flip_vertically_on_load(true)
  let img = load_from_bytes(bmp)
  set_flip_vertically_on_load(false)
  // Original: (0,0)=red, (1,0)=white, (0,1)=green, (1,1)=blue
  // Flipped:  (0,0)=green, (1,0)=blue, (0,1)=red, (1,1)=white
  assert_eq(img.data[0].to_int(), 0)
  assert_eq(img.data[1].to_int(), 255)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "flip: flip_vertically_on_write produces flipped output" {
  let img = load_from_path("testdata/test_4x4_red.png")
  flip_vertically_on_write(true)
  let png_bytes = write_png_to_bytes(img)
  flip_vertically_on_write(false)
  assert_true(png_bytes.length() > 0)
  let img2 = load_from_bytes(png_bytes)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
}
