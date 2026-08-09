///|
test "read_exif_from_path: JPEG file" {
  // testdata 中有 JPEG 文件
  let result = read_exif_from_path("testdata/test_4x4_red.jpg")
  // 可能返回 None（如果 JPEG 不含 EXIF）或 Some(ExifInfo)
  // 主要验证不崩溃
  match result {
    Some(info) => {
      // orientation 应在 1-8 范围
      assert_true(info.orientation >= 1 && info.orientation <= 8)
      let _ = info
    }
    None => assert_true(true)
  }
  let _ = result
}

///|
test "read_exif_from_path: non-existent file raises" {
  try {
    let _ = read_exif_from_path("testdata/nonexistent.jpg")
    assert_true(false)
  } catch {
    @core.LoadError::FileIO(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "read_exif_from_path: non-JPEG file returns None" {
  // PNG 文件不含 EXIF
  let result = read_exif_from_path("testdata/test_4x4_red.png")
  assert_eq(result, None)
  let _ = result
}
