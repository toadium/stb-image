// image-process 演示入口
// Demonstrates image processing: color conversion, transform, filter, edge detection.

///|
fn main raise {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array([
      255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0, 0, 255, 255, 255, 0, 255, 128,
      128, 128, 64, 64, 64, 255, 128, 0, 128, 255, 0, 0, 128, 255, 255, 255, 255,
      32, 32, 32, 96, 96, 96, 160, 160, 160, 224, 224, 224,
    ]),
  }
  println("Image: \{img.width}x\{img.height}, channels=\{img.channels}")

  // 灰度转换
  let gray = @color.to_grayscale(img)
  println("Grayscale: \{gray.width}x\{gray.height}, channels=\{gray.channels}")

  // 旋转 90 度
  let rotated = @transform.rotate_90(img)
  println("Rotated 90: \{rotated.width}x\{rotated.height}")

  // 水平翻转
  let flipped = @transform.flip_horizontal(img)
  println("Flipped: \{flipped.width}x\{flipped.height}")

  println("\nimage-process demo complete!")
}
