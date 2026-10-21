///|
test "avif_info_extended: parse full AVIF metadata" {
  // ftyp(20) + meta(95) containing iprp→ipco→[ispe,pixi,colr,av1C]
  let data = Bytes::from_array([
    // ftyp box (20 bytes)
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, // meta box (95 bytes, FullBox)
     0x00, 0x00, 0x00, 0x5F, b'm', b'e', b't', b'a', 0x00, 0x00, 0x00, 0x00,
    // iprp box (83 bytes)
     0x00, 0x00, 0x00, 0x53, b'i', b'p', b'r', b'p',
    // ipco box (75 bytes)
     0x00, 0x00, 0x00, 0x4B, b'i', b'p', b'c', b'o',
    // ispe box (20 bytes): width=256, height=256
     0x00, 0x00, 0x00, 0x14, b'i', b's', b'p', b'e', 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00,
    // pixi box (16 bytes): 3 channels, 8-bit
     0x00, 0x00, 0x00, 0x10, b'p', b'i', b'x', b'i', 0x00, 0x00, 0x00, 0x00, 0x03,
    0x08, 0x08, 0x08, // colr box (19 bytes): nclx, primaries=1, transfer=1, matrix=1, full_range
     0x00, 0x00, 0x00, 0x13, b'c', b'o', b'l', b'r', b'n', b'c', b'l', b'x', 0x00,
    0x01, 0x00, 0x01, 0x00, 0x01, 0x80,
    // av1C box (12 bytes): profile=2, level=0, tier=0, mono=false
     0x00, 0x00, 0x00, 0x0C, b'a', b'v', b'1', b'C', 0x81, 0x40, 0x00, 0x00,
  ])
  let info = @codec.avif_info_extended(data)
  assert_eq(info.width, 256)
  assert_eq(info.height, 256)
  assert_eq(info.bit_depth, 8)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
  assert_eq(info.color_type, "nclx")
  assert_eq(info.color_primaries, 1)
  assert_eq(info.transfer_characteristics, 1)
  assert_eq(info.matrix_coefficients, 1)
  assert_true(info.full_range)
  assert_eq(info.av1_profile, 2)
  assert_eq(info.av1_level, 0)
  assert_eq(info.av1_tier, 0)
  assert_false(info.av1_monochrome)
}

///|
test "avif_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.avif_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "avif_info_extended: missing dimensions raises" {
  // ftyp only, no meta/ispe
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  try {
    ignore(@codec.avif_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "avif_info_extended: with rotation" {
  // ftyp(20) + meta(57) containing iprp→ipco→[ispe,irot]
  let data = Bytes::from_array([
    // ftyp (20)
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, // meta (57, FullBox)
     0x00, 0x00, 0x00, 0x39, b'm', b'e', b't', b'a', 0x00, 0x00, 0x00, 0x00,
    // iprp (45)
     0x00, 0x00, 0x00, 0x2D, b'i', b'p', b'r', b'p',
    // ipco (37)
     0x00, 0x00, 0x00, 0x25, b'i', b'p', b'c', b'o',
    // ispe (20): 64x64
     0x00, 0x00, 0x00, 0x14, b'i', b's', b'p', b'e', 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x40, // irot (9): rotation = 90 degrees
     0x00, 0x00, 0x00, 0x09, b'i', b'r', b'o', b't', 0x01,
  ])
  let info = @codec.avif_info_extended(data)
  assert_eq(info.width, 64)
  assert_eq(info.height, 64)
  assert_eq(info.rotation, 90)
}

///|
test "avif_info_extended: with alpha and mirror" {
  // ftyp(20) + meta(66) containing iprp→ipco→[ispe,auxC,imir]
  // ispe(20)+auxC(9)+imir(9)=38, ipco=46, iprp=54, meta=66
  let data = Bytes::from_array([
    // ftyp (20)
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'a', b'v', b'i', b'f', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, // meta (66, FullBox)
     0x00, 0x00, 0x00, 0x42, b'm', b'e', b't', b'a', 0x00, 0x00, 0x00, 0x00,
    // iprp (54)
     0x00, 0x00, 0x00, 0x36, b'i', b'p', b'r', b'p',
    // ipco (46)
     0x00, 0x00, 0x00, 0x2E, b'i', b'p', b'c', b'o',
    // ispe (20): 32x32
     0x00, 0x00, 0x00, 0x14, b'i', b's', b'p', b'e', 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x20, 0x00, 0x00, 0x00, 0x20, // auxC (9): alpha present
     0x00, 0x00, 0x00, 0x09, b'a', b'u', b'x', b'C', 0x00,
    // imir (9): mirror = 1
     0x00, 0x00, 0x00, 0x09, b'i', b'm', b'i', b'r', 0x01,
  ])
  let info = @codec.avif_info_extended(data)
  assert_eq(info.width, 32)
  assert_eq(info.height, 32)
  assert_true(info.has_alpha)
  assert_eq(info.num_channels, 4)
  assert_eq(info.mirror, 1)
}
