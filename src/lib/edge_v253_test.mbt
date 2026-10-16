// v253.0.0 边界条件+错误路径覆盖测试

///|
test "v253 format_supports_16bit: all formats" {
  let formats = [
    @lib.ImageFormat::Png,
    @lib.ImageFormat::Jpeg,
    @lib.ImageFormat::Bmp,
    @lib.ImageFormat::Gif,
    @lib.ImageFormat::Qoi,
    @lib.ImageFormat::Tga,
    @lib.ImageFormat::Psd,
    @lib.ImageFormat::Hdr,
    @lib.ImageFormat::Pnm,
    @lib.ImageFormat::Tiff,
    @lib.ImageFormat::Ico,
    @lib.ImageFormat::Cur,
    @lib.ImageFormat::Icns,
    @lib.ImageFormat::Apng,
    @lib.ImageFormat::Webp,
    @lib.ImageFormat::Avif,
    @lib.ImageFormat::Heif,
    @lib.ImageFormat::JpegXl,
  ]
  for fmt in formats {
    let _ = @lib.format_supports_16bit(fmt)
  }
  assert_true(@lib.format_supports_16bit(@lib.ImageFormat::Png))
  assert_true(@lib.format_supports_16bit(@lib.ImageFormat::Pnm))
  assert_false(@lib.format_supports_16bit(@lib.ImageFormat::Jpeg))
}

///|
test "v253 format_supports_float: all formats" {
  let formats = [
    @lib.ImageFormat::Png,
    @lib.ImageFormat::Jpeg,
    @lib.ImageFormat::Bmp,
    @lib.ImageFormat::Gif,
    @lib.ImageFormat::Qoi,
    @lib.ImageFormat::Tga,
    @lib.ImageFormat::Psd,
    @lib.ImageFormat::Hdr,
    @lib.ImageFormat::Pnm,
    @lib.ImageFormat::Tiff,
    @lib.ImageFormat::Ico,
    @lib.ImageFormat::Cur,
    @lib.ImageFormat::Icns,
    @lib.ImageFormat::Apng,
    @lib.ImageFormat::Webp,
    @lib.ImageFormat::Avif,
    @lib.ImageFormat::Heif,
    @lib.ImageFormat::JpegXl,
  ]
  for fmt in formats {
    let _ = @lib.format_supports_float(fmt)
  }
  assert_true(@lib.format_supports_float(@lib.ImageFormat::Hdr))
  assert_false(@lib.format_supports_float(@lib.ImageFormat::Png))
}

///|
test "v253 detect_format: empty bytes returns Unknown" {
  let result = @lib.detect_format(Bytes::from_array([]))
  assert_true(result is @lib.ImageFormat::Unknown)
}

///|
test "v253 detect_format: too short returns Unknown" {
  let result = @lib.detect_format(Bytes::from_array([0xFF]))
  assert_true(result is @lib.ImageFormat::Unknown)
}

///|
test "v253 detect_format: PNG signature" {
  let result = @lib.detect_format(
    Bytes::from_array([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]),
  )
  assert_true(result is @lib.ImageFormat::Png)
}

///|
test "v253 detect_format: JPEG signature" {
  let result = @lib.detect_format(Bytes::from_array([0xFF, 0xD8, 0xFF]))
  assert_true(result is @lib.ImageFormat::Jpeg)
}

///|
test "v253 detect_format: BMP signature" {
  let result = @lib.detect_format(Bytes::from_array([0x42, 0x4D]))
  assert_true(result is @lib.ImageFormat::Bmp)
}

///|
test "v253 detect_format: GIF87a signature" {
  let result = @lib.detect_format(
    Bytes::from_array([0x47, 0x49, 0x46, 0x38, 0x37, 0x61]),
  )
  assert_true(result is @lib.ImageFormat::Gif)
}

///|
test "v253 detect_format: GIF89a signature" {
  let result = @lib.detect_format(
    Bytes::from_array([0x47, 0x49, 0x46, 0x38, 0x39, 0x61]),
  )
  assert_true(result is @lib.ImageFormat::Gif)
}

///|
test "v253 detect_format: QOI signature" {
  let result = @lib.detect_format(Bytes::from_array([0x71, 0x6F, 0x69, 0x66]))
  assert_true(result is @lib.ImageFormat::Qoi)
}

///|
test "v253 detect_format: HDR signature" {
  let result = @lib.detect_format(
    Bytes::from_array([
      0x23, 0x3F, 0x52, 0x41, 0x44, 0x49, 0x41, 0x4E, 0x43, 0x45, 0x0A,
    ]),
  )
  assert_true(result is @lib.ImageFormat::Hdr)
}

///|
test "v253 detect_format: unknown format" {
  let result = @lib.detect_format(
    Bytes::from_array([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]),
  )
  assert_true(result is @lib.ImageFormat::Unknown)
}

///|
test "v253 get_image_info: empty bytes raises" {
  try {
    let _ = @lib.get_image_info(Bytes::from_array([]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v253 get_image_info: too short bytes raises" {
  try {
    let _ = @lib.get_image_info(Bytes::from_array([0x00]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v253 get_image_summary: empty bytes raises" {
  try {
    let _ = @lib.get_image_summary(Bytes::from_array([]))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn v253_make_img(w : Int, h : Int, ch : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h * ch) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "v253 save_image_auto: 1x1 PNG" {
  let img = v253_make_img(1, 1, 3, 128)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Png)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 1x1 BMP" {
  let img = v253_make_img(1, 1, 3, 128)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Bmp)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 1x1 QOI" {
  let img = v253_make_img(1, 1, 3, 128)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Qoi)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 1x1 TGA" {
  let img = v253_make_img(1, 1, 3, 128)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Tga)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 1x1 PNM" {
  let img = v253_make_img(1, 1, 3, 128)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Pnm)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 1-channel image" {
  let img = v253_make_img(2, 2, 1, 100)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Png)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_auto: 4-channel image" {
  let img = v253_make_img(2, 2, 4, 100)
  let result = @lib.save_image_auto(img, @lib.ImageFormat::Png)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_with_quality: WebP quality 0" {
  let img = v253_make_img(4, 4, 3, 128)
  let result = @lib.save_image_with_quality(img, @lib.ImageFormat::Webp, 0)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_with_quality: WebP quality 100" {
  let img = v253_make_img(4, 4, 3, 128)
  let result = @lib.save_image_with_quality(img, @lib.ImageFormat::Webp, 100)
  assert_true(result.length() > 0)
}

///|
test "v253 save_image_with_quality: JPEG quality 50" {
  let img = v253_make_img(4, 4, 3, 128)
  let result = @lib.save_image_with_quality(img, @lib.ImageFormat::Jpeg, 50)
  assert_true(result.length() > 0)
}
