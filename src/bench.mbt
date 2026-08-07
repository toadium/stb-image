// 性能基准测试：测量关键操作的执行时间
// 使用 @bench.T 进行基准测试，b.keep 防止优化消除

///|
test "bench: load PNG" (b : @bench.T) {
  b.bench(fn() {
    try {
      let img = @core.load_from_path(
        "testdata/test_4x4_red.png",
        req_channels=Some(3),
      )
      b.keep(img)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: load JPEG" (b : @bench.T) {
  b.bench(fn() {
    try {
      let img = @core.load_from_path(
        "testdata/test_4x4_red.jpg",
        req_channels=Some(3),
      )
      b.keep(img)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: load BMP" (b : @bench.T) {
  b.bench(fn() {
    try {
      let img = @core.load_from_path(
        "testdata/test_4x4_red.bmp",
        req_channels=Some(3),
      )
      b.keep(img)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: load GIF" (b : @bench.T) {
  b.bench(fn() {
    try {
      let img = @core.load_from_path(
        "testdata/test_4x4_red.gif",
        req_channels=Some(3),
      )
      b.keep(img)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write PNG" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let bytes = @core.write_png_to_bytes(img)
      b.keep(bytes)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write JPEG" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let bytes = @core.write_jpeg_to_bytes(img, quality=90)
      b.keep(bytes)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write BMP" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let bytes = @core.write_bmp_to_bytes(img)
      b.keep(bytes)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write QOI" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let bytes = @format.encode_qoi(img)
      b.keep(bytes)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write GIF" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let bytes = @format.encode_gif(img)
      b.keep(bytes)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: write PPM" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let bytes = @format.encode_ppm(img)
    b.keep(bytes)
  })
}

///|
test "bench: resize 4x4 -> 8x8" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let r = @core.resize(img, 8, 8)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: resize 4x4 -> 16x16" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let r = @core.resize(img, 16, 16)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: box_blur radius=1" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @filter.box_blur(img, 1)
    b.keep(r)
  })
}

///|
test "bench: gaussian_blur radius=1 sigma=1.5" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @filter.gaussian_blur(img, 1, 1.5F)
    b.keep(r)
  })
}

///|
test "bench: sharpen amount=1.0" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @filter.sharpen(img, 1.0F)
    b.keep(r)
  })
}

///|
test "bench: edge_detect_sobel" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @filter.edge_detect_sobel(img)
    b.keep(r)
  })
}

///|
test "bench: crop 4x4 -> 2x2" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    try {
      let r = @transform.crop(img, 0, 0, 2, 2)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: rotate_90" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @transform.rotate_90(img)
    b.keep(r)
  })
}

///|
test "bench: flip_horizontal" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @transform.flip_horizontal(img)
    b.keep(r)
  })
}

///|
test "bench: to_grayscale" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @color.to_grayscale(img)
    b.keep(r)
  })
}

///|
test "bench: to_rgba" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @color.to_rgba(img)
    b.keep(r)
  })
}

///|
test "bench: adjust_gamma 2.2" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @color.adjust_gamma(img, 2.2F)
    b.keep(r)
  })
}

///|
test "bench: invert" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @color.invert(img)
    b.keep(r)
  })
}

///|
test "bench: histogram" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @feature.histogram(img)
    b.keep(r)
  })
}

///|
test "bench: histogram_equalize" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @feature.histogram_equalize(img)
    b.keep(r)
  })
}

///|
test "bench: floyd_steinberg 4 colors" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @segment.floyd_steinberg(img, 4)
    b.keep(r)
  })
}

///|
test "bench: median_cut 4 colors" (b : @bench.T) {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  b.bench(fn() {
    let r = @segment.median_cut(img, 4)
    b.keep(r)
  })
}

///|
test "bench: detect_format" (b : @bench.T) {
  let bytes = @core.write_png_to_bytes(
    @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3)),
  )
  b.bench(fn() {
    let r = @core.detect_format(bytes)
    b.keep(r)
  })
}

///|
test "bench: decode_any" (b : @bench.T) {
  let bytes = @core.write_png_to_bytes(
    @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3)),
  )
  b.bench(fn() {
    try {
      let r = @core.decode_any(bytes, req_channels=Some(3))
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

// 生成 64x64 渐变灰度图用于大图基准测试

///|
fn bench_make_gradient_64() -> @core.Image {
  let w = 64
  let h = 64
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = ((x + y) % 256).to_byte()
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "bench: fft_2d 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @frequency.fft_2d(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: ifft_2d 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  let fft = try! @frequency.fft_2d(img)[0]
  b.bench(fn() {
    let r = @frequency.ifft_2d(fft)
    b.keep(r)
  })
}

///|
test "bench: watershed_auto 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let (labels, count) = @segment.watershed_auto(img)
      b.keep(labels)
      b.keep(count)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: nlm_denoise 32x32" (b : @bench.T) {
  // 32x32 渐变图（NLM 复杂度高，用较小尺寸）
  let w = 32
  let h = 32
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = ((x * 4 + y * 4) % 256).to_byte()
    }
  }
  let img = @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
  b.bench(fn() {
    try {
      let r = @filter.nlm_denoise(img, patch_size=2, search_size=5, h=10)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: nlm_denoise_fast 32x32" (b : @bench.T) {
  let w = 32
  let h = 32
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = ((x * 4 + y * 4) % 256).to_byte()
    }
  }
  let img = @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
  b.bench(fn() {
    try {
      let r = @filter.nlm_denoise_fast(
        img,
        patch_size=2,
        search_size=5,
        h=10,
        step=2,
      )
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

// 生成 64x64 渐变灰度图（带噪声，用于 ssim 等需要两幅图的基准）

///|
fn bench_make_gradient_64_noisy() -> @core.Image {
  let w = 64
  let h = 64
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = ((x + y + x * 7 % 13) % 256).to_byte()
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "bench: bilateral_filter 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @filter.bilateral_filter(img, 2, 3.0F, 30.0F)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: canny_edge 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @edge.canny_edge(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: hough_lines 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @edge.hough_lines(img, 50)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: find_contours 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @edge.find_contours(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: clahe 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @color.clahe(img, 8, 3.0F)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: dehaze 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @color.dehaze(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: msr 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @color.msr(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: adaptive_threshold_mean 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @color.adaptive_threshold_mean(img, 5, 2)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: haar_transform_2d 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @frequency.haar_transform_2d(img, levels=3)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: freq_filter 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @frequency.freq_filter(
        img,
        @frequency.FreqFilterType::LowPass,
        16.0F,
      )
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: warp_affine 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    let r = @transform.warp_affine(
      img,
      (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F),
      64,
      64,
    )
    b.keep(r)
  })
}

///|
test "bench: pyr_down 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @transform.pyr_down(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: draw_over 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @transform.draw_over(img, img, 0, 0)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: compute_glcm 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @feature.compute_glcm(img, 1, 0)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: integral_image 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @feature.integral_image(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: harris_corners 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @feature.harris_corners(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: gabor_filter 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @feature.gabor_filter(img, 5, 2.0F, 0.0F)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: lbp 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @feature.lbp(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: ssim 64x64" (b : @bench.T) {
  let img1 = bench_make_gradient_64()
  let img2 = bench_make_gradient_64_noisy()
  b.bench(fn() {
    let r = @feature.ssim(img1, img2)
    b.keep(r)
  })
}

///|
test "bench: connected_components 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let (labels, count) = @segment.connected_components(img, 4)
      b.keep(labels)
      b.keep(count)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: distance_transform 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @segment.distance_transform(img)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: kmeans_segment 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let (labels, regions) = @color.kmeans_segment(img, 4)
      b.keep(labels)
      b.keep(regions)
    } catch {
      _ => ()
    }
  })
}

///|
test "bench: erode 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    let r = @segment.erode(img)
    b.keep(r)
  })
}

///|
test "bench: k_means_quantize 64x64" (b : @bench.T) {
  let img = bench_make_gradient_64()
  b.bench(fn() {
    try {
      let r = @segment.k_means_quantize(img, 4, 10)
      b.keep(r)
    } catch {
      _ => ()
    }
  })
}
