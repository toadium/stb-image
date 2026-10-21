///|
test "heif_info_extended: parse full HEIF metadata" {
  // ftyp(20) + meta(107) containing iprp→ipco→[ispe,pixi,colr,hvcC]
  let data = Bytes::from_array([
    // ftyp box (20 bytes)
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, // meta box (107 bytes, FullBox)
     0x00, 0x00, 0x00, 0x6B, b'm', b'e', b't', b'a', 0x00, 0x00, 0x00, 0x00,
    // iprp box (95 bytes)
     0x00, 0x00, 0x00, 0x5F, b'i', b'p', b'r', b'p',
    // ipco box (87 bytes)
     0x00, 0x00, 0x00, 0x57, b'i', b'p', b'c', b'o',
    // ispe box (20 bytes): width=256, height=256
     0x00, 0x00, 0x00, 0x14, b'i', b's', b'p', b'e', 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00,
    // pixi box (16 bytes): 3 channels, 8-bit
     0x00, 0x00, 0x00, 0x10, b'p', b'i', b'x', b'i', 0x00, 0x00, 0x00, 0x00, 0x03,
    0x08, 0x08, 0x08, // colr box (19 bytes): nclx
     0x00, 0x00, 0x00, 0x13, b'c', b'o', b'l', b'r', b'n', b'c', b'l', b'x', 0x00,
    0x01, 0x00, 0x01, 0x00, 0x01, 0x80,
    // hvcC box (24 bytes): profile=2, tier=0, level=93, chroma=1, 8-bit
     0x00, 0x00, 0x00, 0x18, b'h', b'v', b'c', b'C', 0x01, 0x02, 0x00, 0x00, 0x00,
    0x5D, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
  ])
  let info = @codec.heif_info_extended(data)
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
  assert_eq(info.hevc_profile, 2)
  assert_eq(info.hevc_tier, 0)
  assert_eq(info.hevc_level, 93)
  assert_eq(info.hevc_chroma_format, 1)
  assert_eq(info.hevc_bit_depth_luma, 8)
  assert_eq(info.hevc_bit_depth_chroma, 8)
}

///|
test "heif_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.heif_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "heif_info_extended: missing dimensions raises" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08,
  ])
  try {
    ignore(@codec.heif_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "heif_info_extended: with rotation" {
  // ftyp(20) + meta(57) containing iprp→ipco→[ispe,irot]
  let data = Bytes::from_array([
    // ftyp (20)
    0x00, 0x00, 0x00, 0x14, b'f', b't', b'y', b'p', b'h', b'e', b'i', b'c', 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, // meta (57, FullBox)
     0x00, 0x00, 0x00, 0x39, b'm', b'e', b't', b'a', 0x00, 0x00, 0x00, 0x00,
    // iprp (45)
     0x00, 0x00, 0x00, 0x2D, b'i', b'p', b'r', b'p',
    // ipco (37)
     0x00, 0x00, 0x00, 0x25, b'i', b'p', b'c', b'o',
    // ispe (20): 128x128
     0x00, 0x00, 0x00, 0x14, b'i', b's', b'p', b'e', 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x80, 0x00, 0x00, 0x00, 0x80, // irot (9): rotation = 180 degrees
     0x00, 0x00, 0x00, 0x09, b'i', b'r', b'o', b't', 0x02,
  ])
  let info = @codec.heif_info_extended(data)
  assert_eq(info.width, 128)
  assert_eq(info.height, 128)
  assert_eq(info.rotation, 180)
}
