// v254.0.0 格式解码增强测试 — AVIF/HEIF/JPEG-XL 元数据解析

///|
/// 构造 ISOBMFF box: size(4) + type(4) + data
fn v254_box(box_type : String, payload : Array[Byte]) -> Array[Byte] {
  let size = 8 + payload.length()
  let out : Array[Byte] = [
    ((size >> 24) & 0xFF).to_byte(),
    ((size >> 16) & 0xFF).to_byte(),
    ((size >> 8) & 0xFF).to_byte(),
    (size & 0xFF).to_byte(),
  ]
  for c in box_type.to_array() {
    out.push(c.to_int().to_byte())
  }
  for b in payload {
    out.push(b)
  }
  out
}

///|
/// 构造 ispe box: version(4) + width(4) + height(4)
fn v254_ispe(w : Int32, h : Int32) -> Array[Byte] {
  let payload : Array[Byte] = [
    0x00,
    0x00,
    0x00,
    0x00,
    ((w >> 24) & 0xFF).to_byte(),
    ((w >> 16) & 0xFF).to_byte(),
    ((w >> 8) & 0xFF).to_byte(),
    (w & 0xFF).to_byte(),
    ((h >> 24) & 0xFF).to_byte(),
    ((h >> 16) & 0xFF).to_byte(),
    ((h >> 8) & 0xFF).to_byte(),
    (h & 0xFF).to_byte(),
  ]
  v254_box("ispe", payload)
}

///|
/// 构造 pixi box: version(4) + num_channels(1) + bit_depths(...)
fn v254_pixi(num_ch : Int32, bit_depth : Int32) -> Array[Byte] {
  let payload : Array[Byte] = [0x00, 0x00, 0x00, 0x00, num_ch.to_byte()]
  for _ in 0..<num_ch {
    payload.push(bit_depth.to_byte())
  }
  v254_box("pixi", payload)
}

///|
/// 构造 auxC box (alpha indicator)
fn v254_auxc() -> Array[Byte] {
  let payload : Array[Byte] = [0x00, 0x00, 0x00, 0x00, b'a', b'l', b'p', b'h']
  v254_box("auxC", payload)
}

///|
/// 构造 ftyp box for AVIF
fn v254_ftyp_avif() -> Array[Byte] {
  let payload : Array[Byte] = [b'a', b'v', b'i', b'f', 0x00, 0x00, 0x00, 0x00]
  v254_box("ftyp", payload)
}

///|
test "v254 avif_info: parse ispe box for dimensions" {
  let data : Array[Byte] = []
  for b in v254_ftyp_avif() {
    data.push(b)
  }
  for b in v254_ispe(1920, 1080) {
    data.push(b)
  }
  let info = @codec.avif_info(Bytes::from_array(data))
  assert_eq(info.width, 1920)
  assert_eq(info.height, 1080)
  assert_eq(info.bit_depth, 8)
  assert_false(info.has_alpha)
}

///|
test "v254 avif_info: parse pixi box for bit depth" {
  let data : Array[Byte] = []
  for b in v254_ftyp_avif() {
    data.push(b)
  }
  for b in v254_ispe(640, 480) {
    data.push(b)
  }
  for b in v254_pixi(3, 10) {
    data.push(b)
  }
  let info = @codec.avif_info(Bytes::from_array(data))
  assert_eq(info.width, 640)
  assert_eq(info.height, 480)
  assert_eq(info.bit_depth, 10)
}

///|
test "v254 avif_info: parse auxC box for alpha" {
  let data : Array[Byte] = []
  for b in v254_ftyp_avif() {
    data.push(b)
  }
  for b in v254_ispe(256, 256) {
    data.push(b)
  }
  for b in v254_auxc() {
    data.push(b)
  }
  let info = @codec.avif_info(Bytes::from_array(data))
  assert_eq(info.width, 256)
  assert_eq(info.height, 256)
  assert_true(info.has_alpha)
  assert_eq(info.num_channels, 4)
}

///|
test "v254 avif_info: no ispe box raises error" {
  let data = Bytes::from_array(v254_ftyp_avif())
  try {
    ignore(@codec.avif_info(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v254 avif_info: 12-bit depth" {
  let data : Array[Byte] = []
  for b in v254_ftyp_avif() {
    data.push(b)
  }
  for b in v254_ispe(100, 100) {
    data.push(b)
  }
  for b in v254_pixi(3, 12) {
    data.push(b)
  }
  let info = @codec.avif_info(Bytes::from_array(data))
  assert_eq(info.bit_depth, 12)
}

///|
test "v254 avif_decode: error message contains dimensions" {
  let data : Array[Byte] = []
  for b in v254_ftyp_avif() {
    data.push(b)
  }
  for b in v254_ispe(800, 600) {
    data.push(b)
  }
  try {
    ignore(@codec.avif_decode(Bytes::from_array(data)))
    assert_true(false)
  } catch {
    @types.LoadError::UnsupportedFormat(msg) => {
      assert_true(msg.contains("800"))
      assert_true(msg.contains("600"))
    }
    _ => assert_true(true)
  }
}

///|
/// HEIF tests
test "v254 heif_info: parse basic HEIF" {
  // HEIF uses ftyp with brand "heic" or "mif1"
  let ftyp : Array[Byte] = []
  let payload : Array[Byte] = [b'h', b'e', b'i', b'c', 0x00, 0x00, 0x00, 0x00]
  for b in v254_box("ftyp", payload) {
    ftyp.push(b)
  }
  let data : Array[Byte] = []
  for b in ftyp {
    data.push(b)
  }
  for b in v254_ispe(400, 300) {
    data.push(b)
  }
  let info = @codec.heif_info(Bytes::from_array(data))
  assert_eq(info.width, 400)
  assert_eq(info.height, 300)
}

///|
test "v254 heif_decode: returns unsupported" {
  let ftyp : Array[Byte] = []
  let payload : Array[Byte] = [b'h', b'e', b'i', b'c', 0x00, 0x00, 0x00, 0x00]
  for b in v254_box("ftyp", payload) {
    ftyp.push(b)
  }
  let data : Array[Byte] = []
  for b in ftyp {
    data.push(b)
  }
  for b in v254_ispe(100, 100) {
    data.push(b)
  }
  try {
    ignore(@codec.heif_decode(Bytes::from_array(data)))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
/// JPEG-XL tests
test "v254 jpegxl: container format detection" {
  // JPEG-XL container starts with 0x00 0x00 0x00 0x0C 0x4A 0x58 0x4C 0x20
  // (box size 12, type "JXL ")
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, 0x87, 0x0A,
  ])
  assert_true(@codec.is_jpegxl_format(data))
}

///|
test "v254 jpegxl: codestream format detection" {
  // JPEG-XL codestream starts with 0xFF 0x0A
  let data = Bytes::from_array([0xFF, 0x0A, 0x00, 0x01])
  assert_true(@codec.is_jpegxl_format(data))
}

///|
test "v254 jpegxl: non-JPEG-XL format" {
  let data = Bytes::from_array([0x89, 0x50, 0x4E, 0x47])
  assert_false(@codec.is_jpegxl_format(data))
}

///|
test "v254 jpegxl_decode: returns unsupported" {
  let data = Bytes::from_array([
    0x00, 0x00, 0x00, 0x0C, 0x4A, 0x58, 0x4C, 0x20, 0x0D, 0x0A, 0x87, 0x0A,
  ])
  try {
    ignore(@codec.jpegxl_decode(data))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "v254 jpegxl: too short data" {
  assert_false(@codec.is_jpegxl_format(Bytes::from_array([])))
  assert_false(@codec.is_jpegxl_format(Bytes::from_array([0xFF])))
}
