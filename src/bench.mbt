///|
fn bench_make_rgb(
  width : Int,
  height : Int,
) -> @types.Image {
  let n = width * height
  let data : Array[Byte] = Array::make(n * 3, b'\x80')
  for i in 0..<n {
    data[i * 3] = ((i * 37) % 256).to_byte()
    data[i * 3 + 1] = ((i * 71) % 256).to_byte()
    data[i * 3 + 2] = ((i * 113) % 256).to_byte()
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data) }
}

///|
fn bench_make_rgba(
  width : Int,
  height : Int,
) -> @types.Image {
  let n = width * height
  let data : Array[Byte] = Array::make(n * 4, b'\xFF')
  for i in 0..<n {
    data[i * 4] = ((i * 37) % 256).to_byte()
    data[i * 4 + 1] = ((i * 71) % 256).to_byte()
    data[i * 4 + 2] = ((i * 113) % 256).to_byte()
    data[i * 4 + 3] = b'\xFF'
  }
  @types.Image::{ width, height, channels: 4, data: Bytes::from_array(data) }
}

///|
pub fn bench_run() -> Unit {
  let b = @bench.Bench()
  let img128 = bench_make_rgb(128, 128)
  let img256 = bench_make_rgb(256, 256)
  let img_rgba128 = bench_make_rgba(128, 128)

  // 编解码
  b.bench(name="png encode 128x128", () => {
    ignore(@codec.encode_png_pure(img128))
  })
  b.bench(name="png decode 128x128", () => {
    let png = @codec.encode_png_pure(img128)
    ignore(try @codec.decode_png_pure(png) catch {
      _ => @types.Image::{ width: 0, height: 0, channels: 0, data: b"" }
    })
  })
  b.bench(name="bmp encode 128x128", () => {
    ignore(@codec.encode_bmp_pure(img128))
  })
  b.bench(name="qoi encode 128x128", () => {
    ignore(try @codec.encode_qoi_pure(img_rgba128) catch { _ => b"" })
  })
  b.bench(name="qoi decode 128x128", () => {
    let qoi = try @codec.encode_qoi_pure(img_rgba128) catch { _ => b"" }
    ignore(try @codec.decode_qoi_pure(qoi) catch {
      _ => @types.Image::{ width: 0, height: 0, channels: 0, data: b"" }
    })
  })

  // 缩放
  b.bench(name="resize 256->128", () => {
    ignore(try @pure_util.resize_pure(img256, 128, 128) catch { _ => img128 })
  })

  // 图像处理
  b.bench(name="gaussian_blur 128x128", () => {
    ignore(@filter.gaussian_blur(img128, 5, 1.0F))
  })
  b.bench(name="box_blur 128x128", () => {
    ignore(@filter.box_blur(img128, 5))
  })
  b.bench(name="sharpen 128x128", () => {
    ignore(@filter.sharpen(img128, 1.0F))
  })
  b.bench(name="edge_detect_sobel 128x128", () => {
    ignore(@filter.edge_detect_sobel(img128))
  })

  // 色彩
  b.bench(name="to_grayscale 128x128", () => {
    ignore(@color.to_grayscale(img128))
  })
  b.bench(name="adjust_brightness 128x128", () => {
    ignore(@color.adjust_brightness(img128, 50))
  })

  // 几何
  b.bench(name="crop 128x128", () => {
    ignore(try @transform.crop(img128, 10, 10, 64, 64) catch { _ => img128 })
  })
  b.bench(name="rotate_90 128x128", () => {
    ignore(@transform.rotate_90(img128))
  })

  ignore(b.dump_summaries())
}
