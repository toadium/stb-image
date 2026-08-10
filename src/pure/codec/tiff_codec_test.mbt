// 纯 MoonBit TIFF 编解码测试

///|
fn make_2x2_rgb_image() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: b"\xFF\x00\x00\x00\xFF\x00\x00\x00\xFF\xFF\xFF\x00",
  }
}

///|
fn make_3x1_gray_image() -> @types.Image {
  @types.Image::{ width: 3, height: 1, channels: 1, data: b"\x00\x80\xFF" }
}

///|
test "encode_tiff_pure / decode_tiff_pure: 2x2 RGB roundtrip" {
  let img = make_2x2_rgb_image()
  let tiff = encode_tiff_pure(img)
  // 检查 TIFF magic
  assert_eq(tiff[0].to_int(), 0x49) // 'I'
  assert_eq(tiff[1].to_int(), 0x49) // 'I'
  assert_eq(tiff[2].to_int(), 42)
  assert_eq(tiff[3].to_int(), 0)
  let decoded = decode_tiff_pure(tiff)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.channels, 3)
  let expected = [255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0]
  for i in 0..<12 {
    assert_eq(decoded.data[i].to_int(), expected[i])
  }
}

///|
test "encode_tiff_pure / decode_tiff_pure: 3x1 灰度 roundtrip" {
  let img = make_3x1_gray_image()
  let tiff = encode_tiff_pure(img)
  let decoded = decode_tiff_pure(tiff)
  assert_eq(decoded.width, 3)
  assert_eq(decoded.height, 1)
  assert_eq(decoded.channels, 1)
  assert_eq(decoded.data[0].to_int(), 0)
  assert_eq(decoded.data[1].to_int(), 128)
  assert_eq(decoded.data[2].to_int(), 255)
}

///|
test "encode_tiff_pure / decode_tiff_pure: 4x4 RGBA roundtrip" {
  let data : Array[Byte] = Array::make(4 * 4 * 4, b'\x00')
  for i in 0..<16 {
    data[i * 4] = b'\xFF'
    data[i * 4 + 3] = b'\xFF'
  }
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 4,
    data: Bytes::from_array(data),
  }
  let tiff = encode_tiff_pure(img)
  let decoded = decode_tiff_pure(tiff)
  assert_eq(decoded.width, 4)
  assert_eq(decoded.height, 4)
  assert_eq(decoded.channels, 4)
  for i in 0..<16 {
    assert_eq(decoded.data[i * 4].to_int(), 255)
    assert_eq(decoded.data[i * 4 + 3].to_int(), 255)
  }
}

///|
test "encode_tiff_pure: 不支持的 channels 报错" {
  let img = @types.Image::{
    width: 1,
    height: 1,
    channels: 2,
    data: b"\x00\x00",
  }
  try {
    let _ = encode_tiff_pure(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: 数据过短报错" {
  try {
    let _ = decode_tiff_pure(b"\x49\x49")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: magic 无效报错" {
  // 字节序正确但 magic 不是 42
  let bad = b"\x49\x49\x00\x00\x08\x00\x00\x00"
  try {
    let _ = decode_tiff_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: 字节序无效报错" {
  let bad = b"XX\x2A\x00\x08\x00\x00\x00"
  try {
    let _ = decode_tiff_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "encode_tiff_pure: 大端 TIFF 解码" {
  // 手工构造大端 2x1 8-bit 灰度 TIFF
  let out : Array[Byte] = []
  // Header: MM + 42(BE) + IFD offset=8(BE)
  out.push(b'\x4D')
  out.push(b'\x4D') // big-endian
  out.push(b'\x00')
  out.push(b'\x2A') // magic 42
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x08') // IFD offset = 8
  // IFD at offset 8
  // 6 entries: 256, 257, 258, 259, 262, 273, 277, 278, 279
  // count = 9
  out.push(b'\x00')
  out.push(b'\x09')
  // 辅助：写入大端 IFD 条目
  let write_be_entry = fn(
    tag : Int,
    type_id : Int,
    count : Int,
    value : Int,
  ) -> Unit {
    out.push(((tag >> 8) & 0xFF).to_byte())
    out.push((tag & 0xFF).to_byte())
    out.push(((type_id >> 8) & 0xFF).to_byte())
    out.push((type_id & 0xFF).to_byte())
    out.push(((count >> 24) & 0xFF).to_byte())
    out.push(((count >> 16) & 0xFF).to_byte())
    out.push(((count >> 8) & 0xFF).to_byte())
    out.push((count & 0xFF).to_byte())
    out.push(((value >> 24) & 0xFF).to_byte())
    out.push(((value >> 16) & 0xFF).to_byte())
    out.push(((value >> 8) & 0xFF).to_byte())
    out.push((value & 0xFF).to_byte())
  }
  // IFD size = 2 + 9*12 + 4 = 114
  // pixel offset = 8 + 114 = 122
  let pixel_offset = 122
  write_be_entry(256, 4, 1, 2) // width=2
  write_be_entry(257, 4, 1, 1) // height=1
  write_be_entry(258, 3, 1, 8) // bits=8
  write_be_entry(259, 3, 1, 1) // compression=none
  write_be_entry(262, 3, 1, 1) // photometric=BlackIsZero
  write_be_entry(273, 4, 1, pixel_offset) // strip offset
  write_be_entry(277, 3, 1, 1) // samples=1
  write_be_entry(278, 4, 1, 1) // rows per strip
  write_be_entry(279, 4, 1, 2) // strip byte count
  // next IFD = 0
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // 像素数据: 2 bytes
  out.push(b'\x80')
  out.push(b'\xFF')
  let tiff = Bytes::from_array(out)
  let decoded = decode_tiff_pure(tiff)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 1)
  assert_eq(decoded.channels, 1)
  assert_eq(decoded.data[0].to_int(), 128)
  assert_eq(decoded.data[1].to_int(), 255)
}
