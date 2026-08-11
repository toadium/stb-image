// 纯 MoonBit ICO/CUR 编解码测试

///|
fn make_2x2_rgba_image() -> @types.Image {
  // 2x2 RGBA: 红, 绿, 蓝, 白
  @types.Image::{
    width: 2,
    height: 2,
    channels: 4,
    data: b"\xFF\x00\x00\xFF\x00\xFF\x00\xFF\x00\x00\xFF\xFF\xFF\xFF\xFF\xFF",
  }
}

///|
fn make_3x3_rgb_image() -> @types.Image {
  // 3x3 RGB 全红
  let data : Array[Byte] = Array::make(27, b'\x00')
  for i in 0..<9 {
    data[i * 3] = b'\xFF'
  }
  @types.Image::{
    width: 3,
    height: 3,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

///|
test "encode_ico_pure / decode_ico_pure: 1x1 roundtrip" {
  let img = @types.Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: b"\xFF\x80\x40\xFF",
  }
  let ico = encode_ico_pure(img)
  let decoded = decode_ico_pure(ico)
  assert_eq(decoded.width, 1)
  assert_eq(decoded.height, 1)
  assert_eq(decoded.channels, 4)
  assert_eq(decoded.data[0].to_int(), 255)
  assert_eq(decoded.data[1].to_int(), 128)
  assert_eq(decoded.data[2].to_int(), 64)
  assert_eq(decoded.data[3].to_int(), 255)
}

///|
test "encode_ico_pure / decode_ico_pure: 2x2 RGBA roundtrip" {
  let img = make_2x2_rgba_image()
  let ico = encode_ico_pure(img)
  let decoded = decode_ico_pure(ico)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.channels, 4)
  // 红, 绿, 蓝, 白
  let expected = [
    255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255,
  ]
  for i in 0..<16 {
    assert_eq(decoded.data[i].to_int(), expected[i])
  }
}

///|
test "encode_ico_pure / decode_ico_pure: 3x3 RGB roundtrip" {
  let img = make_3x3_rgb_image()
  let ico = encode_ico_pure(img)
  let decoded = decode_ico_pure(ico)
  assert_eq(decoded.width, 3)
  assert_eq(decoded.height, 3)
  assert_eq(decoded.channels, 4)
  // 全红，alpha=255
  for i in 0..<9 {
    assert_eq(decoded.data[i * 4].to_int(), 255)
    assert_eq(decoded.data[i * 4 + 1].to_int(), 0)
    assert_eq(decoded.data[i * 4 + 2].to_int(), 0)
    assert_eq(decoded.data[i * 4 + 3].to_int(), 255)
  }
}

///|
test "encode_ico_pure: ICO 文件头正确" {
  let img = make_2x2_rgba_image()
  let ico = encode_ico_pure(img)
  // ICONDIR: reserved=0, type=1, count=1
  assert_eq(ico[0].to_int(), 0)
  assert_eq(ico[1].to_int(), 0)
  assert_eq(ico[2].to_int(), 1)
  assert_eq(ico[3].to_int(), 0)
  assert_eq(ico[4].to_int(), 1)
  assert_eq(ico[5].to_int(), 0)
  // ICONDIRENTRY: width=2, height=2
  assert_eq(ico[6].to_int(), 2)
  assert_eq(ico[7].to_int(), 2)
}

///|
test "encode_ico_with_sizes_pure: 多尺寸 ICO" {
  let img1 = @types.Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: b"\xFF\x00\x00\xFF",
  }
  let img2 = make_2x2_rgba_image()
  let ico = encode_ico_with_sizes_pure([img1, img2])
  // count=2
  assert_eq(ico[4].to_int(), 2)
  assert_eq(ico[5].to_int(), 0)
  // 解码应选面积最大的 (2x2)
  let decoded = decode_ico_pure(ico)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
}

///|
test "encode_cur_pure / decode_cur_pure: roundtrip" {
  let img = make_2x2_rgba_image()
  let cur = encode_cur_pure(img)
  // CUR type=2
  assert_eq(cur[2].to_int(), 2)
  assert_eq(cur[3].to_int(), 0)
  let decoded = decode_cur_pure(cur)
  assert_eq(decoded.width, 2)
  assert_eq(decoded.height, 2)
  assert_eq(decoded.channels, 4)
  let expected = [
    255, 0, 0, 255, 0, 255, 0, 255, 0, 0, 255, 255, 255, 255, 255, 255,
  ]
  for i in 0..<16 {
    assert_eq(decoded.data[i].to_int(), expected[i])
  }
}

///|
test "encode_cur_with_hotspot_pure: 热点坐标" {
  let img = make_2x2_rgba_image()
  let cur = encode_cur_with_hotspot_pure(img, 1, 0)
  // 热点 X 在 offset 10-11 (planes 位置)
  assert_eq(cur[10].to_int(), 1)
  assert_eq(cur[11].to_int(), 0)
  // 热点 Y 在 offset 12-13 (bitcount 位置)
  assert_eq(cur[12].to_int(), 0)
  assert_eq(cur[13].to_int(), 0)
}

///|
test "decode_ico_pure: 透明像素 AND 掩码" {
  // 构造 1x1 24-bit ICO，AND 掩码标记透明
  let out : Array[Byte] = []
  // ICONDIR
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x01')
  out.push(b'\x00')
  out.push(b'\x01')
  out.push(b'\x00')
  // ICONDIRENTRY: 1x1, 24-bit
  out.push(b'\x01') // width
  out.push(b'\x01') // height
  out.push(b'\x00') // colors
  out.push(b'\x00') // reserved
  out.push(b'\x01')
  out.push(b'\x00') // planes
  out.push(b'\x18')
  out.push(b'\x00') // bitcount=24
  // byte_size: 40 (DIB) + 4 (XOR, 1px*3+1pad) + 4 (AND, 1bit+3pad) = 48
  out.push(b'\x30')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // offset = 22
  out.push(b'\x16')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // BITMAPINFOHEADER
  out.push(b'\x28')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00') // size=40
  out.push(b'\x01')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00') // width=1
  out.push(b'\x02')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00') // height=2
  out.push(b'\x01')
  out.push(b'\x00') // planes
  out.push(b'\x18')
  out.push(b'\x00') // bitcount=24
  for _ in 0..<24 {
    out.push(b'\x00')
  } // rest of DIB
  // XOR: BGR + 1 pad = 4 bytes, 蓝色 (B=255,G=0,R=0)
  out.push(b'\xFF')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // AND: 1 byte (bit7=1 透明) + 3 pad
  out.push(b'\x80')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  let ico = Bytes::from_array(out)
  let decoded = decode_ico_pure(ico)
  assert_eq(decoded.width, 1)
  assert_eq(decoded.height, 1)
  assert_eq(decoded.channels, 4)
  // 透明像素 alpha=0
  assert_eq(decoded.data[3].to_int(), 0)
}

///|
test "decode_ico_pure: 数据过短报错" {
  try {
    let _ = decode_ico_pure(b"\x00\x00")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_ico_pure: type 无效报错" {
  // type=3 无效
  let bad = b"\x00\x00\x03\x00\x01\x00"
  try {
    let _ = decode_ico_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_cur_pure: ICO 文件用 CUR 解码报错" {
  let img = make_2x2_rgba_image()
  let ico = encode_ico_pure(img)
  try {
    let _ = decode_cur_pure(ico)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
