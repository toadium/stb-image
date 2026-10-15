///|
test "is_psd_format: valid 8BPS" {
  let data = Bytes::from_array([
    0x38, 0x42, 0x50, 0x53, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x03, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x08, 0x00, 0x03,
  ])
  assert_true(@codec.is_psd_format(data))
}

///|
test "is_psd_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(@codec.is_psd_format(data))
}

///|
test "psd_info_extended: parse basic PSD" {
  // PSD header: 8BPS + version=1 + reserved(6) + channels=3 + h=4 + w=4 + depth=8 + mode=3(RGB)
  // + 3 empty segments + image data compression=0
  let data = Bytes::from_array([
    0x38, 0x42, 0x50, 0x53, // "8BPS"
     0x00, 0x01, // version=1
     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, // reserved
     0x00, 0x03, // channel_count=3
     0x00, 0x00, 0x00, 0x04, // height=4
     0x00, 0x00, 0x00, 0x04, // width=4
     0x00, 0x08, // bitdepth=8
     0x00, 0x03, // color_mode=3 (RGB)
    // color mode data (length=0)
     0x00, 0x00, 0x00, 0x00,
    // image resources (length=0)
     0x00, 0x00, 0x00, 0x00,
    // layer and mask data (length=0)
     0x00, 0x00, 0x00, 0x00,
    // image data: compression=0 (Raw)
     0x00, 0x00,
  ])
  let info = @codec.psd_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.bit_depth, 8)
  assert_eq(info.channel_count, 3)
  assert_eq(info.num_channels, 3)
  assert_false(info.has_alpha)
  assert_eq(info.color_mode, 3)
  assert_eq(info.color_mode_name, "RGB")
  assert_eq(info.compression, 0)
  assert_eq(info.compression_name, "Raw")
  assert_eq(info.version, 1)
}

///|
test "psd_info_extended: RGBA with alpha" {
  let data = Bytes::from_array([
    0x38, 0x42, 0x50, 0x53, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x04, // channel_count=4 (RGBA)
     0x00, 0x00, 0x00, 0x08, // height=8
     0x00, 0x00, 0x00, 0x08, // width=8
     0x00, 0x08, 0x00, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00,
  ])
  let info = @codec.psd_info_extended(data)
  assert_eq(info.width, 8)
  assert_eq(info.height, 8)
  assert_eq(info.channel_count, 4)
  assert_true(info.has_alpha)
  assert_eq(info.num_channels, 4)
}

///|
test "psd_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.psd_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
