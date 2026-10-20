///|
test "ImageLike: Image 实现 width/height/channels/data/bytes_per_pixel" {
  let img : @types.Image = @types.Image::{
    width: 4,
    height: 3,
    channels: 3,
    data: Bytes::from_array(Array::make(36, (128 : Byte))),
  }
  assert_eq(@types.ImageLike::width(img), 4)
  assert_eq(@types.ImageLike::height(img), 3)
  assert_eq(@types.ImageLike::channels(img), 3)
  assert_eq(@types.ImageLike::bytes_per_pixel(img), 1)
  assert_eq(@types.ImageLike::pixel_count(img), 36)
  assert_eq(@types.ImageLike::byte_count(img), 36)
  assert_true(@types.ImageLike::is_rgb(img))
  assert_true(!@types.ImageLike::is_grayscale(img))
}

///|
test "ImageLike: Image16 实现 bytes_per_pixel=2" {
  let img : @types.Image16 = @types.Image16::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(8, (0 : Byte))),
  }
  assert_eq(@types.ImageLike::bytes_per_pixel(img), 2)
  assert_eq(@types.ImageLike::pixel_count(img), 4)
  assert_eq(@types.ImageLike::byte_count(img), 8)
  assert_true(@types.ImageLike::is_grayscale(img))
}

///|
test "ImageLike: ImageF 实现 bytes_per_pixel=4" {
  let img : @types.ImageF = @types.ImageF::{
    width: 2,
    height: 2,
    channels: 4,
    data: Bytes::from_array(Array::make(64, (0 : Byte))),
  }
  assert_eq(@types.ImageLike::bytes_per_pixel(img), 4)
  assert_eq(@types.ImageLike::pixel_count(img), 16)
  assert_eq(@types.ImageLike::byte_count(img), 64)
  assert_true(@types.ImageLike::is_rgba(img))
}

///|
test "ImageLike: AnyImage 包装与解包" {
  let img : @types.Image = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Bytes::from_array(Array::make(12, (200 : Byte))),
  }
  let any = @types.image_to_any(img)
  assert_true(any is @types.AnyImage::U8(_))
  assert_eq(@types.ImageLike::width(any), 2)
  assert_eq(@types.ImageLike::height(any), 2)
  let back = @types.any_image_to_u8(any)
  assert_eq(back.width, 2)
  assert_eq(back.height, 2)
}

///|
test "ImageLike: AnyImage U16 转换 U8" {
  let img16 : @types.Image16 = @types.Image16::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([255, 0]),
  }
  let any = @types.image16_to_any(img16)
  assert_true(any is @types.AnyImage::U16(_))
  assert_eq(@types.ImageLike::bytes_per_pixel(any), 2)
  let u8 = @types.any_image_to_u8(any)
  assert_eq(u8.width, 1)
  assert_eq(u8.data[0], 255)
}

///|
test "ImageLike: hdr_from_u8 归一化" {
  let img : @types.Image = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: Bytes::from_array([255]),
  }
  let hdr = @types.hdr_from_u8(img)
  assert_eq(hdr.width, 1)
  assert_eq(hdr.height, 1)
  let f = Float::reinterpret_from_int(
    (hdr.data[3].to_int() << 24) |
    (hdr.data[2].to_int() << 16) |
    (hdr.data[1].to_int() << 8) |
    hdr.data[0].to_int(),
  )
  assert_true(f > 0.99F && f < 1.01F)
}
