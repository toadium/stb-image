// v246.0.0 统一 info API 测试

///|
fn ui_make_bmp_4x4() -> Bytes {
  Bytes::from_array([
    0x42, 0x4D, 0x66, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00,
    0x00, 0x28, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00,
    0x01, 0x00, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00,
  ])
}

///|
fn ui_make_png_4x4() -> Bytes {
  Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x08, 0x06,
    0x00, 0x00, 0x00,
  ])
}

///|
fn ui_make_jpeg_4x4() -> Bytes {
  Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x04, 0x00, 0x04, 0x03, 0x01,
    0x22, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
  ])
}

///|
fn ui_make_qoi_4x4() -> Bytes {
  Bytes::from_array([
    0x71, 0x6F, 0x69, 0x66, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x03,
    0x00,
  ])
}

///|
test "get_image_info: BMP" {
  let info = @lib.get_image_info(ui_make_bmp_4x4())
  assert_eq(info.format, @lib.ImageFormat::Bmp)
  assert_eq(info.format_name, "BMP")
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.channels, 3)
  assert_eq(info.bit_depth, 24)
  assert_false(info.has_alpha)
}

///|
test "get_image_info: PNG RGBA" {
  let info = @lib.get_image_info(ui_make_png_4x4())
  assert_eq(info.format, @lib.ImageFormat::Png)
  assert_eq(info.format_name, "PNG")
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.channels, 4)
  assert_eq(info.bit_depth, 8)
  assert_true(info.has_alpha)
}

///|
test "get_image_info: JPEG" {
  let info = @lib.get_image_info(ui_make_jpeg_4x4())
  assert_eq(info.format, @lib.ImageFormat::Jpeg)
  assert_eq(info.format_name, "JPEG")
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.channels, 3)
  assert_eq(info.bit_depth, 8)
}

///|
test "get_image_info: QOI" {
  let info = @lib.get_image_info(ui_make_qoi_4x4())
  assert_eq(info.format, @lib.ImageFormat::Qoi)
  assert_eq(info.format_name, "QOI")
  assert_eq(info.width, 4)
  assert_eq(info.height, 4)
  assert_eq(info.channels, 3)
  assert_eq(info.bit_depth, 8)
}

///|
test "get_image_info: unknown raises" {
  let data = Bytes::from_array([0x00, 0x01, 0x02, 0x03])
  try {
    ignore(@lib.get_image_info(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "get_image_summary: BMP" {
  let summary = @lib.get_image_summary(ui_make_bmp_4x4())
  assert_eq(summary, "BMP 4x4 3ch 24bit")
}

///|
test "get_image_summary: PNG" {
  let summary = @lib.get_image_summary(ui_make_png_4x4())
  assert_eq(summary, "PNG 4x4 4ch 8bit")
}

///|
test "get_image_summary: JPEG" {
  let summary = @lib.get_image_summary(ui_make_jpeg_4x4())
  assert_eq(summary, "JPEG 4x4 3ch 8bit")
}

///|
test "get_image_summary: QOI" {
  let summary = @lib.get_image_summary(ui_make_qoi_4x4())
  assert_eq(summary, "QOI 4x4 3ch 8bit")
}
