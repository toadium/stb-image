///|
test "encode_ppm: basic RGB image" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let ppm = encode_ppm(img)
  // 头部应以 "P6\n" 开头
  assert_eq(ppm[0].to_int(), 0x50) // P
  assert_eq(ppm[1].to_int(), 0x36) // 6
  assert_eq(ppm[2].to_int(), 0x0A) // \n
  let _ = img
  let _ = ppm
}

///|
test "encode_ppm: round-trip with load_from_bytes" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let ppm = encode_ppm(img)
  let restored = @lib.load_from_bytes_auto(ppm, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "encode_ppm: grayscale input converted to RGB" {
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x80', b'\x40', b'\xC0', b'\x00'] |> Bytes::from_array,
  }
  let ppm = encode_ppm(img)
  let restored = @lib.load_from_bytes_auto(ppm, req_channels=Some(3))
  assert_eq(restored.channels, 3)
  // 灰度 0x80 → RGB (128, 128, 128)
  assert_eq(restored.data[0].to_int(), 128)
  assert_eq(restored.data[1].to_int(), 128)
  assert_eq(restored.data[2].to_int(), 128)
  let _ = img
  let _ = restored
}

///|
test "encode_pgm: basic grayscale" {
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array,
  }
  let pgm = encode_pgm(img)
  // 头部应以 "P5\n" 开头
  assert_eq(pgm[0].to_int(), 0x50) // P
  assert_eq(pgm[1].to_int(), 0x35) // 5
  assert_eq(pgm[2].to_int(), 0x0A) // \n
  let _ = img
  let _ = pgm
}

///|
test "encode_pgm: round-trip with load_from_bytes" {
  let img = @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array,
  }
  let pgm = encode_pgm(img)
  let restored = @lib.load_from_bytes_auto(pgm, req_channels=Some(1))
  assert_eq(restored.width, 2)
  assert_eq(restored.height, 2)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "encode_pgm: RGB input converted to grayscale" {
  let img = @lib.load_from_bytes_auto(make_1x1_red_bmp(), req_channels=Some(3))
  let pgm = encode_pgm(img)
  let restored = @lib.load_from_bytes_auto(pgm, req_channels=Some(1))
  // R=255 → Y = 0.299*255 = 76
  assert_eq(restored.data[0].to_int(), 76)
  let _ = img
  let _ = restored
}

///|
test "encode_pnm: auto-selects PGM for grayscale" {
  let img = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: [b'\x80'] |> Bytes::from_array,
  }
  let pnm = encode_pnm(img)
  assert_eq(pnm[1].to_int(), 0x35) // P5
  let _ = img
  let _ = pnm
}

///|
test "encode_pnm: auto-selects PPM for RGB" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let pnm = encode_pnm(img)
  assert_eq(pnm[1].to_int(), 0x36) // P6
  let _ = img
  let _ = pnm
}

///|
test "encode_ppm: detect_format recognizes PPM" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let ppm = encode_ppm(img)
  let fmt = @lib.detect_format(ppm)
  assert_eq(fmt, @types.ImageFormat::Pnm)
  let _ = img
  let _ = ppm
  let _ = fmt
}
