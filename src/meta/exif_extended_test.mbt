// v248.0.0 扩展 EXIF 读取测试

///|
test "read_exif_extended: no EXIF returns None" {
  let data = Bytes::from_array([0xFF, 0xD8, 0xFF, 0xD9])
  assert_true(@meta.read_exif_extended_from_bytes(data) is None)
}

///|
test "read_exif_extended: non-JPEG returns None" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_true(@meta.read_exif_extended_from_bytes(data) is None)
}

///|
test "read_exif_extended: empty data returns None" {
  let data = Bytes::from_array([])
  assert_true(@meta.read_exif_extended_from_bytes(data) is None)
}

///|
test "read_exif_extended: JPEG with minimal EXIF" {
  // SOI + APP1(Exif\0\0 + TIFF LE + IFD0 with 0 entries) + EOI
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xE1, 0x00, 0x0E, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00, 0x49,
    0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xD9,
  ])
  let result = @meta.read_exif_extended_from_bytes(data)
  match result {
    Some(info) => {
      assert_eq(info.make, "")
      assert_eq(info.model, "")
      assert_eq(info.orientation, 1)
      assert_eq(info.iso, 0)
      assert_eq(info.flash, 0)
      assert_eq(info.gps_latitude, 0.0)
      assert_eq(info.gps_longitude, 0.0)
      assert_eq(info.exposure_time, "")
      assert_eq(info.f_number, 0.0)
      assert_eq(info.focal_length, 0.0)
    }
    None => assert_true(false)
  }
}

///|
test "read_exif_extended: JPEG with Make tag" {
  // SOI + APP1(Exif\0\0 + TIFF LE + IFD0 with 1 entry: Make="Test")
  // IFD0 at offset 8, 1 entry, Make tag 0x010F type 2 count 5 offset 0x26
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xE1, 0x00, 0x1C, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00, 0x49,
    0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x0F, 0x01, 0x02, 0x00,
    0x05, 0x00, 0x00, 0x00, 0x16, 0x00, 0x00, 0x00, 0x54, 0x65, 0x73, 0x74, 0x00,
    0xFF, 0xD9,
  ])
  let result = @meta.read_exif_extended_from_bytes(data)
  match result {
    Some(info) => assert_eq(info.make, "Test")
    None => assert_true(false)
  }
}

///|
test "read_exif_extended: JPEG with Orientation tag" {
  // SOI + APP1(Exif\0\0 + TIFF LE + IFD0 with 1 entry: Orientation=6)
  let data = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xE1, 0x00, 0x1A, 0x45, 0x78, 0x69, 0x66, 0x00, 0x00, 0x49,
    0x49, 0x2A, 0x00, 0x08, 0x00, 0x00, 0x00, 0x01, 0x00, 0x12, 0x01, 0x03, 0x00,
    0x01, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0xFF, 0xD9,
  ])
  let result = @meta.read_exif_extended_from_bytes(data)
  match result {
    Some(info) => assert_eq(info.orientation, 6)
    None => assert_true(false)
  }
}
