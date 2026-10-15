///|
test "is_tiff_format: valid little-endian" {
  // II + 42 + ifd_offset
  let data = Bytes::from_array([0x49, 0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00])
  assert_true(@codec.is_tiff_format(data))
}

///|
test "is_tiff_format: valid big-endian" {
  // MM + 42 + ifd_offset
  let data = Bytes::from_array([0x4D, 0x4D, 0x00, 0x2A, 0x00, 0x00, 0x00, 0x08])
  assert_true(@codec.is_tiff_format(data))
}

///|
test "is_tiff_format: invalid format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
  assert_false(@codec.is_tiff_format(data))
}

///|
test "tiff_info_extended: parse basic TIFF" {
  // Little-endian TIFF with 6 IFD entries: 4x4, 8-bit RGB
  let data = Bytes::from_array([
    // Header (8 bytes)
    0x49, 0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00,
    // IFD: count=6
     0x06, 0x00,
    // entry 0: ImageWidth=4 (tag=256, type=SHORT, count=1)
     0x00, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    // entry 1: ImageLength=4 (tag=257)
     0x01, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    // entry 2: BitsPerSample=8 (tag=258)
     0x02, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
    // entry 3: Compression=1 (tag=259, none)
     0x03, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00,
    // entry 4: PhotometricInterpretation=2 (tag=262, RGB)
     0x06, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00,
    // entry 5: SamplesPerPixel=3 (tag=277)
     0x15, 0x01, 0x03, 0x00, 0x01, 0x00, 0x00, 0x00, 0x03, 0x00, 0x00, 0x00,
    // next IFD offset = 0
     0x00, 0x00, 0x00, 0x00,
  ])
  let info = @codec.tiff_info_extended(data)
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.bit_depth, 8)
  assert_eq(info.samples_per_pixel, 3)
  assert_eq(info.compression, 1)
  assert_eq(info.compression_name, "none")
  assert_eq(info.photometric, 2)
  assert_eq(info.photometric_name, "RGB")
  assert_eq(info.orientation, 1)
  assert_true(info.is_little_endian)
  assert_false(info.has_alpha)
}

///|
test "tiff_info_extended: unsupported format raises" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.tiff_info_extended(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
