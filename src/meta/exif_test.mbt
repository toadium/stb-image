///|
test "read_exif_from_bytes: non-JPEG returns None" {
  let data = Bytes::from_array([b'\x00', b'\x00', b'\x00', b'\x00'])
  let result = read_exif_from_bytes(data)
  assert_eq(result, None)
  let _ = data
  let _ = result
}

///|
test "read_exif_from_bytes: empty bytes returns None" {
  let data = Bytes::from_array([])
  let result = read_exif_from_bytes(data)
  assert_eq(result, None)
  let _ = data
  let _ = result
}

///|
test "read_exif_from_bytes: JPEG without EXIF returns None" {
  // 创建一个最小 JPEG (SOI + EOI)
  let data = Bytes::from_array([b'\xFF', b'\xD8', b'\xFF', b'\xD9'])
  let result = read_exif_from_bytes(data)
  assert_eq(result, None)
  let _ = data
  let _ = result
}

///|
test "ExifInfo: default values" {
  let info = ExifInfo::{ make: "", model: "", orientation: 1, date_time: "" }
  assert_eq(info.orientation, 1)
  assert_eq(info.make, "")
  let _ = info
}
