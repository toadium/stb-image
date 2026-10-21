// image-core 演示入口
// Demonstrates core image types and traits.

///|
fn main {
  // 创建一个 4x4 灰度图像
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      0, 64, 128, 192, 32, 96, 160, 224, 48, 112, 176, 240, 16, 80, 144, 208,
    ]),
  }
  println("Image: \{img.width}x\{img.height}, channels=\{img.channels}")

  // 使用 ImageLike trait
  let pixel_count = @types.ImageLike::pixel_count(img)
  println("Pixel count: \{pixel_count}")

  let byte_count = @types.ImageLike::byte_count(img)
  println("Byte count: \{byte_count}")

  let is_gray = @types.ImageLike::is_grayscale(img)
  println("Is grayscale: \{is_gray}")

  // 创建 AnyImage
  let any = @types.image_to_any(img)
  println("AnyImage created")

  // 从 AnyImage 转回 Image
  let recovered = @types.any_image_to_u8(any)
  println("Recovered: \{recovered.width}x\{recovered.height}")

  println("\nimage-core demo complete!")
}
