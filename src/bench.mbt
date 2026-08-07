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
    let r = @process.box_blur(img, 1)
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
    let r = @process.gaussian_blur(img, 1, 1.5F)
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
    let r = @process.sharpen(img, 1.0F)
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
    let r = @process.edge_detect_sobel(img)
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
      let r = @process.crop(img, 0, 0, 2, 2)
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
    let r = @process.rotate_90(img)
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
    let r = @process.flip_horizontal(img)
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
    let r = @process.to_grayscale(img)
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
    let r = @process.to_rgba(img)
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
    let r = @process.adjust_gamma(img, 2.2F)
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
    let r = @process.invert(img)
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
    let r = @process.histogram(img)
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
    let r = @process.histogram_equalize(img)
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
    let r = @process.floyd_steinberg(img, 4)
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
    let r = @process.median_cut(img, 4)
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
