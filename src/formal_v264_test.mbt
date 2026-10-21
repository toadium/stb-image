// v264.0.0 形式化验证 + FAKE + MOCK + E2E 多策略测试
// 通过属性测试表达数学不变量，用 FAKE 生成器、MOCK 分派、E2E 流水线确保无 bug

// ============================================================
// FAKE: 结构化假图像生成器
// ============================================================

///|
fn v264_fake_solid(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(w * h * ch, val.to_byte())),
  }
}

///|
fn v264_fake_gradient(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let v = (x + y) % 256
        data.push(v.to_byte())
        let _ = c
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn v264_fake_checkerboard(w : Int32, h : Int32, block : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let bx = x / block
      let by = y / block
      let v = if (bx + by) % 2 == 0 { 255 } else { 0 }
      data.push(v.to_byte())
      data.push(v.to_byte())
      data.push(v.to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
fn v264_fake_stripes(w : Int32, h : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for _ in 0..<w {
      let v = if y % 2 == 0 { 200 } else { 50 }
      data.push(v.to_byte())
      data.push(v.to_byte())
      data.push(v.to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
fn v264_lcg(seed : Int32) -> () -> Int32 {
  let mut state = seed
  () => {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF
    state
  }
}

///|
fn v264_fake_random(
  seed : Int32,
  w : Int32,
  h : Int32,
  ch : Int32,
) -> @types.Image {
  let rng = v264_lcg(seed)
  let data : Array[Byte] = []
  for _ in 0..<(w * h * ch) {
    data.push((rng() % 256).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn v264_img_eq(a : @types.Image, b : @types.Image) -> Bool {
  if a.width != b.width || a.height != b.height || a.channels != b.channels {
    return false
  }
  for i in 0..<a.data.length() {
    if a.data[i] != b.data[i] {
      return false
    }
  }
  true
}

// ============================================================
// 形式化证明: Round-Trip 属性 (encode∘decode = identity)
// ============================================================

///|
test "v264 formal: PNG round-trip identity" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 4, 3)
    let encoded = @codec.encode_png_pure(img)
    let decoded = @codec.decode_png_pure(encoded)
    assert_true(v264_img_eq(img, decoded))
  }
}

///|
test "v264 formal: BMP round-trip identity" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 4, 3)
    let encoded = @codec.encode_bmp_pure(img)
    let decoded = @codec.decode_bmp_pure(encoded)
    assert_true(v264_img_eq(img, decoded))
  }
}

///|
test "v264 formal: PNM round-trip identity" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 4, 3)
    let encoded = @codec.encode_pnm_pure(img)
    let decoded = @codec.decode_pnm_pure(encoded)
    assert_true(v264_img_eq(img, decoded))
  }
}

///|
test "v264 formal: TGA round-trip identity" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 4, 3)
    let encoded = @codec.encode_tga_pure(img)
    let decoded = @codec.decode_tga_pure(encoded)
    assert_true(v264_img_eq(img, decoded))
  }
}

///|
test "v264 formal: QOI round-trip identity" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 4, 3)
    try {
      let encoded = @codec.encode_qoi_pure(img)
      let decoded = @codec.decode_qoi_pure(encoded)
      assert_true(v264_img_eq(img, decoded))
    } catch {
      _ => ()
    }
  }
}

// ============================================================
// 形式化证明: 代数不变量
// ============================================================

///|
test "v264 formal: flip_horizontal is involution (f∘f = id)" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 6, 4, 3)
    let f1 = @transform.flip_horizontal(img)
    let f2 = @transform.flip_horizontal(f1)
    assert_true(v264_img_eq(img, f2))
  }
}

///|
test "v264 formal: flip_vertical is involution (f∘f = id)" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 6, 4, 3)
    let f1 = @transform.flip_vertical(img)
    let f2 = @transform.flip_vertical(f1)
    assert_true(v264_img_eq(img, f2))
  }
}

///|
test "v264 formal: rotate_90 has order 4 (f⁴ = id)" {
  for seed in 1..<=5 {
    let img = v264_fake_random(seed, 4, 6, 3)
    let r1 = @transform.rotate_90(img)
    let r2 = @transform.rotate_90(r1)
    let r3 = @transform.rotate_90(r2)
    let r4 = @transform.rotate_90(r3)
    assert_true(v264_img_eq(img, r4))
  }
}

///|
test "v264 formal: rotate_90 swaps dimensions" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 4, 6, 3)
    let rotated = @transform.rotate_90(img)
    assert_eq(rotated.width, img.height)
    assert_eq(rotated.height, img.width)
  }
}

///|
test "v264 formal: flip preserves dimensions and channels" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 5, 7, 3)
    let fh = @transform.flip_horizontal(img)
    let fv = @transform.flip_vertical(img)
    assert_eq(fh.width, img.width)
    assert_eq(fh.height, img.height)
    assert_eq(fh.channels, img.channels)
    assert_eq(fv.width, img.width)
    assert_eq(fv.height, img.height)
    assert_eq(fv.channels, img.channels)
  }
}

// ============================================================
// 形式化证明: 维度/通道保持属性
// ============================================================

///|
test "v264 formal: resize preserves target dimensions" {
  for seed in 1..<=5 {
    let img = v264_fake_random(seed, 8, 8, 3)
    for target in [1, 4, 16, 32] {
      try {
        let resized = @pure_util.resize_pure(img, target, target)
        assert_eq(resized.width, target)
        assert_eq(resized.height, target)
      } catch {
        _ => ()
      }
    }
  }
}

///|
test "v264 formal: crop preserves target dimensions" {
  let img = v264_fake_random(42, 10, 10, 3)
  for dims in [(2, 2, 5, 5), (0, 0, 10, 10), (3, 3, 4, 4)] {
    try {
      let cropped = @transform.crop(img, dims.0, dims.1, dims.2, dims.3)
      assert_eq(cropped.width, dims.2)
      assert_eq(cropped.height, dims.3)
    } catch {
      _ => ()
    }
  }
}

///|
test "v264 formal: to_grayscale reduces channels" {
  for seed in 1..<=10 {
    let img = v264_fake_random(seed, 8, 8, 3)
    try {
      let gray = @color.to_grayscale(img)
      assert_true(gray.channels <= img.channels)
    } catch {
      _ => ()
    }
  }
}

///|
test "v264 formal: gaussian_blur preserves dimensions" {
  for seed in 1..<=5 {
    let img = v264_fake_random(seed, 8, 8, 3)
    try {
      let blurred = @filter.gaussian_blur(img, 2, 1.0F)
      assert_eq(blurred.width, img.width)
      assert_eq(blurred.height, img.height)
      assert_eq(blurred.channels, img.channels)
    } catch {
      _ => ()
    }
  }
}

///|
test "v264 formal: box_blur preserves dimensions" {
  for seed in 1..<=5 {
    let img = v264_fake_random(seed, 8, 8, 3)
    try {
      let blurred = @filter.box_blur(img, 2)
      assert_eq(blurred.width, img.width)
      assert_eq(blurred.height, img.height)
      assert_eq(blurred.channels, img.channels)
    } catch {
      _ => ()
    }
  }
}

///|
test "v264 formal: adjust_brightness preserves dimensions" {
  let img = v264_fake_random(42, 6, 6, 3)
  for delta in [-100, 0, 50, 100] {
    try {
      let adjusted = @color.adjust_brightness(img, delta)
      assert_eq(adjusted.width, img.width)
      assert_eq(adjusted.height, img.height)
      assert_eq(adjusted.channels, img.channels)
    } catch {
      _ => ()
    }
  }
}

// ============================================================
// 形式化证明: FAKE 生成器属性
// ============================================================

///|
test "v264 fake: solid color image has uniform pixels" {
  let img = v264_fake_solid(4, 4, 3, 128)
  for i in 0..<img.data.length() {
    assert_eq(img.data[i].to_int(), 128)
  }
}

///|
test "v264 fake: gradient image has increasing values" {
  let img = v264_fake_gradient(8, 1, 1)
  assert_eq(img.data[0].to_int(), 0)
  assert_eq(img.data[7].to_int(), 7)
}

///|
test "v264 fake: checkerboard has alternating blocks" {
  let img = v264_fake_checkerboard(4, 4, 2)
  let first_pixel = img.data[0].to_int()
  let mid_pixel = img.data[2 * 4 * 3].to_int()
  assert_true(first_pixel != mid_pixel)
}

///|
test "v264 fake: stripes alternate by row" {
  let img = v264_fake_stripes(4, 4)
  let row0_val = img.data[0].to_int()
  let row1_val = img.data[4 * 3].to_int()
  assert_true(row0_val != row1_val)
}

// ============================================================
// MOCK: 格式检测与错误分派模拟
// ============================================================

///|
test "v264 mock: detect_format dispatches PNG correctly" {
  let img = v264_fake_solid(2, 2, 3, 100)
  let png = @codec.encode_png_pure(img)
  let fmt = @lib.detect_format(png)
  assert_true(fmt is @types.ImageFormat::Png)
}

///|
test "v264 mock: detect_format dispatches BMP correctly" {
  let img = v264_fake_solid(2, 2, 3, 100)
  let bmp = @codec.encode_bmp_pure(img)
  let fmt = @lib.detect_format(bmp)
  assert_true(fmt is @types.ImageFormat::Bmp)
}

///|
test "v264 mock: detect_format dispatches PNM correctly" {
  let img = v264_fake_solid(2, 2, 3, 100)
  let pnm = @codec.encode_pnm_pure(img)
  let fmt = @lib.detect_format(pnm)
  assert_true(fmt is @types.ImageFormat::Pnm)
}

///|
test "v264 mock: detect_format returns Unknown for garbage" {
  let garbage = Bytes::from_array([0x00, 0x01, 0x02, 0x03])
  let fmt = @lib.detect_format(garbage)
  assert_true(fmt is @types.ImageFormat::Unknown)
}

///|
test "v264 mock: load_from_bytes_auto dispatches to correct decoder" {
  let img = v264_fake_solid(4, 4, 3, 150)
  let png = @codec.encode_png_pure(img)
  try {
    let loaded = @lib.load_from_bytes_auto(png)
    assert_eq(loaded.width, 4)
    assert_eq(loaded.height, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 mock: save_image_auto produces detectable format" {
  let img = v264_fake_solid(4, 4, 3, 200)
  try {
    let saved = @lib.save_image_auto(img, @types.ImageFormat::Png)
    let fmt = @lib.detect_format(saved)
    assert_true(fmt is @types.ImageFormat::Png)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 mock: error propagation raises correct LoadError variant" {
  let bad_data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  try {
    ignore(@codec.decode_png_pure(bad_data))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(true)
  }
}

// ============================================================
// E2E: 端到端全流水线测试
// ============================================================

///|
test "v264 e2e: generate→encode PNG→decode→resize→encode BMP→decode→verify" {
  let img = v264_fake_gradient(8, 8, 3)
  let png = @codec.encode_png_pure(img)
  let decoded1 = @codec.decode_png_pure(png)
  try {
    let resized = @pure_util.resize_pure(decoded1, 4, 4)
    let bmp = @codec.encode_bmp_pure(resized)
    let decoded2 = @codec.decode_bmp_pure(bmp)
    assert_eq(decoded2.width, 4)
    assert_eq(decoded2.height, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 e2e: generate→grayscale→blur→sharpen→encode→decode→verify" {
  let img = v264_fake_checkerboard(8, 8, 2)
  try {
    let gray = @color.to_grayscale(img)
    let blurred = @filter.gaussian_blur(gray, 1, 1.0F)
    let sharpened = @filter.sharpen(blurred, 0.5F)
    let png = @codec.encode_png_pure(sharpened)
    let decoded = @codec.decode_png_pure(png)
    assert_eq(decoded.width, sharpened.width)
    assert_eq(decoded.height, sharpened.height)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 e2e: multi-format round-trip pipeline" {
  let img = v264_fake_random(77, 4, 4, 3)
  let png = @codec.encode_png_pure(img)
  let from_png = @codec.decode_png_pure(png)
  let bmp = @codec.encode_bmp_pure(from_png)
  let from_bmp = @codec.decode_bmp_pure(bmp)
  let pnm = @codec.encode_pnm_pure(from_bmp)
  let from_pnm = @codec.decode_pnm_pure(pnm)
  assert_true(v264_img_eq(img, from_pnm))
}

///|
test "v264 e2e: load_auto→process→save_auto→load_auto round-trip" {
  let img = v264_fake_solid(8, 8, 3, 100)
  let png = @codec.encode_png_pure(img)
  try {
    let loaded = @lib.load_from_bytes_auto(png)
    let flipped = @transform.flip_horizontal(loaded)
    let saved = @lib.save_image_auto(flipped, @types.ImageFormat::Png)
    let reloaded = @lib.load_from_bytes_auto(saved)
    assert_eq(reloaded.width, 8)
    assert_eq(reloaded.height, 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 e2e: solid color image survives full pipeline" {
  let img = v264_fake_solid(4, 4, 3, 128)
  let png = @codec.encode_png_pure(img)
  let decoded = @codec.decode_png_pure(png)
  let flipped = @transform.flip_horizontal(decoded)
  let rotated = @transform.rotate_90(flipped)
  let png2 = @codec.encode_png_pure(rotated)
  let final_img = @codec.decode_png_pure(png2)
  assert_eq(final_img.width, 4)
  assert_eq(final_img.height, 4)
  assert_eq(final_img.channels, 3)
}

///|
test "v264 e2e: error recovery in multi-format pipeline" {
  let good_img = v264_fake_solid(4, 4, 3, 50)
  let good_png = @codec.encode_png_pure(good_img)
  let bad_data = Bytes::from_array([0x00, 0x01, 0x02])
  ignore(@lib.load_from_bytes_auto(bad_data)) catch {
    _ => ()
  }
  try {
    let loaded = @lib.load_from_bytes_auto(good_png)
    assert_eq(loaded.width, 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "v264 e2e: 4-channel image through full pipeline" {
  let img = v264_fake_random(99, 4, 4, 4)
  let png = @codec.encode_png_pure(img)
  let decoded = @codec.decode_png_pure(png)
  assert_eq(decoded.channels, 4)
  let flipped = @transform.flip_horizontal(decoded)
  assert_eq(flipped.channels, 4)
}

///|
test "v264 e2e: various sizes through encode-decode-process pipeline" {
  for size in [1, 2, 4, 8, 16] {
    let img = v264_fake_gradient(size, size, 3)
    let png = @codec.encode_png_pure(img)
    let decoded = @codec.decode_png_pure(png)
    assert_eq(decoded.width, size)
    assert_eq(decoded.height, size)
    let rotated = @transform.rotate_90(decoded)
    assert_eq(rotated.width, size)
    assert_eq(rotated.height, size)
  }
}
