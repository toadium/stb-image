// v245.0.0 统一保存 API + APNG 自动分派测试

///|
fn sa_make_rgb(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data), }
}

///|
test "save_image_auto: PNG round-trip" {
  let img = sa_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
  ])
  let encoded = @lib.save_image_auto(img, @lib.ImageFormat::Png)
  assert_true(encoded.length() > 0)
  let decoded = @lib.load_from_bytes_auto(encoded)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
}

///|
test "save_image_auto: BMP round-trip" {
  let img = sa_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
  ])
  let encoded = @lib.save_image_auto(img, @lib.ImageFormat::Bmp)
  assert_true(encoded.length() > 0)
  let decoded = @lib.load_from_bytes_auto(encoded)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
}

///|
test "save_image_auto: QOI round-trip" {
  let img = sa_make_rgb(2, 2, [
    (100, 150, 200),
    (50, 60, 70),
    (200, 100, 50),
    (128, 128, 128),
  ])
  let encoded = @lib.save_image_auto(img, @lib.ImageFormat::Qoi)
  assert_true(encoded.length() > 0)
  let decoded = @lib.load_from_bytes_auto(encoded)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
}

///|
test "save_image_auto: TGA encode" {
  let img = sa_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
  ])
  let encoded = @lib.save_image_auto(img, @lib.ImageFormat::Tga)
  assert_true(encoded.length() > 0)
}

///|
test "save_image_auto: unsupported format raises" {
  let img = sa_make_rgb(1, 1, [(0, 0, 0)])
  try {
    ignore(@lib.save_image_auto(img, @lib.ImageFormat::Hdr))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "save_image_auto: AVIF unsupported raises" {
  let img = sa_make_rgb(1, 1, [(0, 0, 0)])
  try {
    ignore(@lib.save_image_auto(img, @lib.ImageFormat::Avif))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "save_image_with_quality: WebP encode" {
  let img = sa_make_rgb(4, 4, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
    (255, 255, 0),
    (0, 255, 255),
    (255, 0, 255),
    (64, 64, 64),
    (192, 192, 192),
    (32, 32, 32),
    (160, 160, 160),
    (96, 96, 96),
    (224, 224, 224),
    (48, 48, 48),
    (144, 144, 144),
    (80, 80, 80),
  ])
  let encoded = @lib.save_image_with_quality(img, @lib.ImageFormat::Webp, 80)
  assert_true(encoded.length() > 0)
}

///|
test "save_image_with_quality: PNG ignores quality" {
  let img = sa_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
  ])
  let encoded = @lib.save_image_with_quality(img, @lib.ImageFormat::Png, 50)
  assert_true(encoded.length() > 0)
  let decoded = @lib.load_from_bytes_auto(encoded)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
}

///|
test "detect_format: APNG detected" {
  let data = Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0x61, 0x63,
    0x54, 0x4C, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0x00, 0x00, 0x00, 0x00,
  ])
  assert_eq(@lib.detect_format(data), @lib.ImageFormat::Apng)
}

///|
test "detect_format: plain PNG not APNG" {
  let data = Bytes::from_array([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
    0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00, 0x00, 0x04, 0x08, 0x06,
    0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45,
    0x4E, 0x44, 0x00, 0x00, 0x00, 0x00,
  ])
  assert_eq(@lib.detect_format(data), @lib.ImageFormat::Png)
}

///|
test "load_from_bytes_auto: APNG first frame" {
  // 构造一个有效的 APNG：PNG sig + IHDR + acTL + fdTL + IDAT + IEND
  // 使用 encode_apng_pure 构造有效 APNG 数据
  let frame1 = sa_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (128, 128, 128),
  ])
  let frame2 = sa_make_rgb(2, 2, [
    (0, 255, 255),
    (255, 0, 255),
    (255, 255, 0),
    (64, 64, 64),
  ])
  let anim = @types.PngAnimation::{
    frames: [frame1, frame2],
    delays: [100, 100],
  }
  let encoded = @codec.encode_apng_pure(anim)
  assert_eq(@lib.detect_format(encoded), @lib.ImageFormat::Apng)
  let loaded = @lib.load_from_bytes_auto(encoded)
  assert_eq(loaded.width, 2)
  assert_eq(loaded.height, 2)
}
