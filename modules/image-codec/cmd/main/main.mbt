// image-codec 演示入口
// Demonstrates image codec: encode/decode multiple formats.

///|
fn main {
  // 创建一个 4x4 RGB 图像
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

  // BMP 编解码往返
  let bmp_data = @lib.encode_bmp(img)
  println("BMP encoded: \{bmp_data.length()} bytes")

  // PNG 编解码往返
  let png_data = @lib.encode_png(img)
  println("PNG encoded: \{png_data.length()} bytes")

  // TGA 编解码往返
  let tga_data = @lib.encode_tga(img)
  println("TGA encoded: \{tga_data.length()} bytes")

  // PPM 编解码往返
  let ppm_data = @lib.encode_ppm_auto(img)
  println("PPM encoded: \{ppm_data.length()} bytes")

  println("\nimage-codec demo complete!")
}
