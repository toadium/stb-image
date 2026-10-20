///|
test "Codec: format_name 返回正确名称" {
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Png), "PNG")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Jpeg), "JPEG")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Bmp), "BMP")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Gif), "GIF")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Tga), "TGA")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Hdr), "HDR")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Qoi), "QOI")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Webp), "WebP")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Tiff), "TIFF")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Ico), "ICO")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Avif), "AVIF")
  assert_eq(@codec.Codec::format_name(@types.ImageFormat::Unknown), "Unknown")
}

///|
test "Codec: can_encode / can_decode" {
  assert_true(@codec.Codec::can_encode(@types.ImageFormat::Png))
  assert_true(@codec.Codec::can_encode(@types.ImageFormat::Jpeg))
  assert_true(!@codec.Codec::can_encode(@types.ImageFormat::Psd))
  assert_true(!@codec.Codec::can_encode(@types.ImageFormat::Avif))
  assert_true(!@codec.Codec::can_encode(@types.ImageFormat::Unknown))
  assert_true(@codec.Codec::can_decode(@types.ImageFormat::Png))
  assert_true(@codec.Codec::can_decode(@types.ImageFormat::Avif))
  assert_true(!@codec.Codec::can_decode(@types.ImageFormat::Unknown))
}

///|
test "Codec: is_lossless" {
  assert_true(@codec.Codec::is_lossless(@types.ImageFormat::Png))
  assert_true(!@codec.Codec::is_lossless(@types.ImageFormat::Jpeg))
  assert_true(!@codec.Codec::is_lossless(@types.ImageFormat::Webp))
  assert_true(@codec.Codec::is_lossless(@types.ImageFormat::Bmp))
}

///|
test "Codec: PNG encode/decode round-trip" {
  let img : @types.Image = @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, (128 : Byte))),
  }
  let any = @types.image_to_any(img)
  let encoded = @codec.Codec::encode(@types.ImageFormat::Png, any)
  let decoded = @codec.Codec::decode(@types.ImageFormat::Png, encoded)
  assert_true(decoded is @types.AnyImage::U8(_))
  match decoded {
    @types.AnyImage::U8(im) => {
      assert_eq(im.width, 4)
      assert_eq(im.height, 4)
      assert_eq(im.channels, 3)
    }
    _ => assert_true(false)
  }
}

///|
test "Codec: BMP encode/decode round-trip" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array([
      100, 150, 200, 100, 150, 200, 100, 150, 200, 100, 150, 200,
    ]),
  }
  let any = @types.image_to_any(img)
  let encoded = @codec.Codec::encode(@types.ImageFormat::Bmp, any)
  let decoded = @codec.Codec::decode(@types.ImageFormat::Bmp, encoded)
  match decoded {
    @types.AnyImage::U8(im) => {
      assert_eq(im.width, 2)
      assert_eq(im.height, 2)
    }
    _ => assert_true(false)
  }
}

///|
test "Codec: @codec.codec_detect_format 检测 PNG" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([128]),
  }
  let png_bytes = @codec.encode_png_pure(img)
  let fmt = @codec.codec_detect_format(png_bytes)
  assert_true(fmt is @types.ImageFormat::Png)
}

///|
test "Codec: @codec.codec_detect_format 检测 JPEG" {
  let jpeg_magic = Bytes::from_array([
    0xFF, 0xD8, 0xFF, 0xE0, 0, 0x10, 0x4A, 0x46, 0x49, 0x46, 0, 1,
  ])
  let fmt = @codec.codec_detect_format(jpeg_magic)
  assert_true(fmt is @types.ImageFormat::Jpeg)
}

///|
test "Codec: @codec.codec_detect_format 检测 BMP" {
  let bmp_magic = Bytes::from_array([0x42, 0x4D, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
  let fmt = @codec.codec_detect_format(bmp_magic)
  assert_true(fmt is @types.ImageFormat::Bmp)
}

///|
test "Codec: @codec.codec_decode_auto 自动检测 PNG" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (100 : Byte))),
  }
  let png_bytes = @codec.encode_png_pure(img)
  let decoded = @codec.codec_decode_auto(png_bytes)
  match decoded {
    @types.AnyImage::U8(im) => {
      assert_eq(im.width, 2)
      assert_eq(im.height, 2)
    }
    _ => assert_true(false)
  }
}

///|
test "Codec: PSD 不支持 encode" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([0]),
  }
  let any = @types.image_to_any(img)
  let result : Bytes? = Some(@codec.Codec::encode(@types.ImageFormat::Psd, any)) catch {
    _ => None
  }
  assert_true(result is None)
}
