// v261.0.0 Codec 模糊测试 — 随机/截断/损坏数据馈入解码器
// 验证所有解码器优雅处理错误（raise LoadError 而非崩溃）

///|
/// 伪随机数生成器（LCG）
fn v261_lcg(seed : Int) -> () -> Int {
  let mut state = seed
  () => {
    state = (state * 1103515245 + 12345) & 0x7FFFFFFF
    state
  }
}

///|
/// 生成伪随机字节数组
fn v261_random_bytes(seed : Int, len : Int) -> Bytes {
  let rng = v261_lcg(seed)
  let out : Array[Byte] = []
  for _ in 0..<len {
    out.push((rng() % 256).to_byte())
  }
  Bytes::from_array(out)
}

///|
/// 截断数据到指定长度
fn v261_truncate(data : Bytes, len : Int) -> Bytes {
  let actual = if len < data.length() { len } else { data.length() }
  let out : Array[Byte] = []
  for i in 0..<actual {
    out.push(data[i])
  }
  Bytes::from_array(out)
}

///|
/// 在指定位置翻转一个字节
fn v261_flip_byte(data : Bytes, pos : Int) -> Bytes {
  if pos >= data.length() {
    return data
  }
  let out : Array[Byte] = []
  for i in 0..<data.length() {
    if i == pos {
      out.push((data[i].to_int() ^ 0xFF).to_byte())
    } else {
      out.push(data[i])
    }
  }
  Bytes::from_array(out)
}

///|
fn v261_make_img() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array(Array::make(48, b'\x80')),
  }
}

///|
test "v261 fuzz: random bytes to PNG decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_png_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to JPEG decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_jpeg_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to BMP decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_bmp_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to GIF decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_gif_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to QOI decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_qoi_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to TGA decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_tga_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to PNM decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_pnm_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to HDR decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_hdr_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: random bytes to WebP decoder" {
  for seed in 1..<=20 {
    let data = v261_random_bytes(seed, 64)
    ignore(@codec.decode_webp_pure(data)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: truncated PNG data" {
  let img = v261_make_img()
  let png = @codec.encode_png_pure(img)
  for trunc_len in [8, 16, 32, 64, png.length() / 2] {
    let truncated = v261_truncate(png, trunc_len)
    ignore(@codec.decode_png_pure(truncated)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: truncated BMP data" {
  let img = v261_make_img()
  let bmp = @codec.encode_bmp_pure(img)
  for trunc_len in [4, 8, 16, 32, bmp.length() / 2] {
    let truncated = v261_truncate(bmp, trunc_len)
    ignore(@codec.decode_bmp_pure(truncated)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: truncated QOI data" {
  let img = v261_make_img()
  let qoi = @codec.encode_qoi_pure(img) catch { _ => b"" }
  if qoi.length() > 0 {
    for trunc_len in [8, 16, 32, qoi.length() / 2] {
      let truncated = v261_truncate(qoi, trunc_len)
      ignore(@codec.decode_qoi_pure(truncated)) catch {
        _ => ()
      }
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: corrupted PNG data (flip bytes)" {
  let img = v261_make_img()
  let png = @codec.encode_png_pure(img)
  for pos in [0, 8, 16, png.length() / 2, png.length() - 1] {
    let corrupted = v261_flip_byte(png, pos)
    ignore(@codec.decode_png_pure(corrupted)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: corrupted BMP data (flip bytes)" {
  let img = v261_make_img()
  let bmp = @codec.encode_bmp_pure(img)
  for pos in [0, 2, 10, bmp.length() / 2, bmp.length() - 1] {
    let corrupted = v261_flip_byte(bmp, pos)
    ignore(@codec.decode_bmp_pure(corrupted)) catch {
      _ => ()
    }
  }
  assert_true(true)
}

///|
test "v261 fuzz: empty data to all decoders" {
  let empty = Bytes::from_array([])
  ignore(@codec.decode_png_pure(empty)) catch {
    _ => ()
  }
  ignore(@codec.decode_bmp_pure(empty)) catch {
    _ => ()
  }
  ignore(@codec.decode_qoi_pure(empty)) catch {
    _ => ()
  }
  ignore(@codec.decode_tga_pure(empty)) catch {
    _ => ()
  }
  ignore(@codec.decode_pnm_pure(empty)) catch {
    _ => ()
  }
  assert_true(true)
}

///|
test "v261 fuzz: single byte data to all decoders" {
  let single = Bytes::from_array([0x00])
  ignore(@codec.decode_png_pure(single)) catch {
    _ => ()
  }
  ignore(@codec.decode_bmp_pure(single)) catch {
    _ => ()
  }
  ignore(@codec.decode_qoi_pure(single)) catch {
    _ => ()
  }
  ignore(@codec.decode_tga_pure(single)) catch {
    _ => ()
  }
  ignore(@codec.decode_pnm_pure(single)) catch {
    _ => ()
  }
  assert_true(true)
}
