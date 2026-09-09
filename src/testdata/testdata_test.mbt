// testdata.mbt 测试：引用嵌入的测试数据常量，覆盖其定义行

///|
test "testdata: test_4x4_red_png is valid PNG bytes" {
  assert_eq(test_4x4_red_png[0], b'\x89')
  assert_eq(test_4x4_red_png[1], b'\x50')
  assert_eq(test_4x4_red_png[2], b'\x4E')
  assert_eq(test_4x4_red_png[3], b'\x47')
  assert_true(test_4x4_red_png.length() > 40)
}

///|
test "testdata: test_4x4_red_bmp is valid BMP bytes" {
  assert_eq(test_4x4_red_bmp[0], b'\x42')
  assert_eq(test_4x4_red_bmp[1], b'\x4D')
  assert_true(test_4x4_red_bmp.length() > 50)
}

///|
test "testdata: test_4x4_red_gif is valid GIF bytes" {
  assert_eq(test_4x4_red_gif[0], b'\x47')
  assert_eq(test_4x4_red_gif[1], b'\x49')
  assert_eq(test_4x4_red_gif[2], b'\x46')
  assert_eq(test_4x4_red_gif[3], b'\x38')
  assert_true(test_4x4_red_gif.length() > 30)
}

///|
test "testdata: test_4x4_red_jpg is valid JPEG bytes" {
  assert_eq(test_4x4_red_jpg[0], b'\xFF')
  assert_eq(test_4x4_red_jpg[1], b'\xD8')
  assert_true(test_4x4_red_jpg.length() > 100)
}

///|
test "testdata: corrupt_random_bin has 8 bytes" {
  assert_eq(corrupt_random_bin.length(), 8)
  assert_eq(corrupt_random_bin[0], b'\x00')
  assert_eq(corrupt_random_bin[7], b'\x07')
}

///|
test "testdata: corrupt_truncated_png has PNG signature" {
  assert_eq(corrupt_truncated_png[0], b'\x89')
  assert_eq(corrupt_truncated_png[1], b'\x50')
  assert_eq(corrupt_truncated_png[2], b'\x4E')
  assert_eq(corrupt_truncated_png[3], b'\x47')
  assert_true(corrupt_truncated_png.length() < 50)
}
