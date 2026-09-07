// TIFF 覆盖率补充测试 (v5.8.0-p4)

///|
fn tt_entry_le(
  out : Array[Byte],
  tag : Int,
  type_id : Int,
  count : Int,
  value : Int,
) -> Unit {
  out.push((tag & 0xFF).to_byte())
  out.push(((tag >> 8) & 0xFF).to_byte())
  out.push((type_id & 0xFF).to_byte())
  out.push(((type_id >> 8) & 0xFF).to_byte())
  out.push((count & 0xFF).to_byte())
  out.push(((count >> 8) & 0xFF).to_byte())
  out.push(((count >> 16) & 0xFF).to_byte())
  out.push(((count >> 24) & 0xFF).to_byte())
  out.push((value & 0xFF).to_byte())
  out.push(((value >> 8) & 0xFF).to_byte())
  out.push(((value >> 16) & 0xFF).to_byte())
  out.push(((value >> 24) & 0xFF).to_byte())
}

///|
fn tt_entry_be(
  out : Array[Byte],
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

///|
fn tt_lzw_pack(init_code_len : Int, codes : Array[Int]) -> Array[Byte] {
  let code_len = init_code_len + 1
  let bits : Array[Int] = []
  for _ in 0..<code_len {
    bits.push(0)
  }
  for c in codes {
    for i in 0..<code_len {
      bits.push((c >> i) & 1)
    }
  }
  for i in 0..<code_len {
    bits.push((257 >> i) & 1)
  }
  let out : Array[Byte] = []
  out.push(init_code_len.to_byte())
  let mut i = 0
  while i < bits.length() {
    let mut b = 0
    let mut j = 0
    while j < 8 {
      if i < bits.length() {
        b = b | (bits[i] << j)
        i += 1
      }
      j += 1
    }
    out.push(b.to_byte())
  }
  out
}

///|
fn tt_deflate_stored(data_bytes : Array[Byte]) -> Array[Byte] {
  let n = data_bytes.length()
  let nlen = n ^ 0xFFFF
  let out : Array[Byte] = []
  out.push(b'\x01')
  out.push((n & 0xFF).to_byte())
  out.push(((n >> 8) & 0xFF).to_byte())
  out.push((nlen & 0xFF).to_byte())
  out.push(((nlen >> 8) & 0xFF).to_byte())
  for b in data_bytes {
    out.push(b)
  }
  out
}

///|
test "decode_tiff_pure: 大端字节序 MM 1x1 灰度" {
  let out : Array[Byte] = []
  out.push(b'\x4D')
  out.push(b'\x4D')
  out.push(b'\x00')
  out.push(b'\x2A')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  let po = 118
  tt_entry_be(out, 256, 4, 1, 1)
  tt_entry_be(out, 257, 4, 1, 1)
  tt_entry_be(out, 258, 3, 1, 8)
  tt_entry_be(out, 259, 3, 1, 1)
  tt_entry_be(out, 262, 3, 1, 1)
  tt_entry_be(out, 273, 4, 1, po)
  tt_entry_be(out, 277, 3, 1, 1)
  tt_entry_be(out, 278, 4, 1, 1)
  tt_entry_be(out, 279, 4, 1, 1)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\xC8')
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 1)
  assert_eq(img.height, 1)
  assert_eq(img.channels, 1)
  assert_eq(img.data[0].to_int(), 200)
}

///|
test "decode_tiff_pure: BitsPerSample 内联 BYTE 类型" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 1, 1, 8)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 1)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\xFF')
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 1)
  assert_eq(img.data[0].to_int(), 255)
}

///|
test "decode_tiff_pure: 缺少 ImageLength raises" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  let po = 110
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 1)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  try {
    let _ = decode_tiff_pure(Bytes::from_array(out))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed("TIFF 缺少 ImageLength") =>
      assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: PackBits 回退填充零字节" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 32773)
  tt_entry_le(out, 262, 3, 1, 2)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 3)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 2) // StripByteCounts=2
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x02')
  out.push(b'\x80')
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 1)
  assert_eq(img.channels, 3)
  // PackBits count=2, n=3, len=2 → outputs 2 bytes, third is zero
  assert_eq(img.data[0].to_int(), 128)
  assert_eq(img.data[1].to_int(), 0)
  assert_eq(img.data[2].to_int(), 0)
}

///|
test "decode_tiff_pure: LZW 数据不足回退填充零字节" {
  let lzw = tt_lzw_pack(8, [128])
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 2)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 5)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, lzw.length())
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  for b in lzw {
    out.push(b)
  }
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 2)
  assert_eq(img.data[0].to_int(), 128)
  assert_eq(img.data[1].to_int(), 0)
}

///|
test "decode_tiff_pure: Deflate 存储块解码" {
  let deflate_data = tt_deflate_stored([1, 2, 3])
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 3)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 8)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, deflate_data.length())
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  for b in deflate_data {
    out.push(b)
  }
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 3)
  assert_eq(img.data[0].to_int(), 1)
  assert_eq(img.data[1].to_int(), 2)
  assert_eq(img.data[2].to_int(), 3)
}

///|
test "decode_tiff_pure: Deflate 数据过短 raises" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 8)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 10)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x01')
  try {
    let _ = decode_tiff_pure(Bytes::from_array(out))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: 无压缩数据越界 raises" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  let po = 110
  tt_entry_le(out, 256, 4, 1, 2)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 1)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x80')
  try {
    let _ = decode_tiff_pure(Bytes::from_array(out))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed("TIFF 像素数据越界") =>
      assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: Photometric=0 多通道反向" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 0)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 3)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 3)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x7F')
  out.push(b'\x7F')
  out.push(b'\x7F')
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.channels, 3)
  assert_eq(img.data[0].to_int(), 128)
  assert_eq(img.data[1].to_int(), 128)
  assert_eq(img.data[2].to_int(), 128)
}

///|
test "decode_tiff_pure: Photometric=1 多通道" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 3)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 3)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x40')
  out.push(b'\x40')
  out.push(b'\x40')
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.channels, 3)
  assert_eq(img.data[0].to_int(), 64)
  assert_eq(img.data[1].to_int(), 64)
  assert_eq(img.data[2].to_int(), 64)
}

///|
test "decode_tiff_pure: LZW 中间 CLEAR 重置字典" {
  let lzw = tt_lzw_pack(8, [65, 66])
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 2)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 3, 1, 8)
  tt_entry_le(out, 259, 3, 1, 5)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, lzw.length())
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  for b in lzw {
    out.push(b)
  }
  let img = decode_tiff_pure(Bytes::from_array(out))
  assert_eq(img.width, 2)
  assert_eq(img.data[0].to_int(), 65)
  assert_eq(img.data[1].to_int(), 66)
}

///|
test "decode_tiff_pure: LZW 字典回溯链" {
  let lzw = tt_lzw_pack(8, [65, 66, 258, 259])
  let decoded = tiff_lzw_decode(Bytes::from_array(lzw))
  assert_eq(decoded.length(), 3)
  assert_eq(decoded[0].to_int(), 65)
  assert_eq(decoded[1].to_int(), 66)
  assert_eq(decoded[2].to_int(), 65)
}

///|
test "decode_tiff_pure: LZW 码越界 raises" {
  let bits : Array[Int] = []
  for _ in 0..<9 {
    bits.push(0)
  }
  for i in 0..<9 {
    bits.push((259 >> i) & 1)
  }
  for i in 0..<9 {
    bits.push((257 >> i) & 1)
  }
  let bytes : Array[Byte] = []
  bytes.push(b'\x08')
  let mut i = 0
  while i < bits.length() {
    let mut b = 0
    let mut j = 0
    while j < 8 {
      if i < bits.length() {
        b = b | (bits[i] << j)
        i += 1
      }
      j += 1
    }
    bytes.push(b.to_byte())
  }
  try {
    let _ = tiff_lzw_decode(Bytes::from_array(bytes))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed("TIFF LZW 码越界") => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: PackBits 重复模式数据不足 raises" {
  let data = Bytes::from_array([b'\x80'])
  try {
    let _ = tiff_packbits_decode(data)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed("TIFF PackBits 数据不足") =>
      assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_tiff_pure: BitsPerSample 外部偏移越界推零" {
  let out : Array[Byte] = []
  out.push(b'\x49')
  out.push(b'\x49')
  out.push(b'\x2A')
  out.push(b'\x00')
  out.push(b'\x08')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x09')
  out.push(b'\x00')
  let po = 118
  tt_entry_le(out, 256, 4, 1, 1)
  tt_entry_le(out, 257, 4, 1, 1)
  tt_entry_le(out, 258, 1, 1, 999)
  tt_entry_le(out, 259, 3, 1, 1)
  tt_entry_le(out, 262, 3, 1, 1)
  tt_entry_le(out, 273, 4, 1, po)
  tt_entry_le(out, 277, 3, 1, 1)
  tt_entry_le(out, 278, 4, 1, 1)
  tt_entry_le(out, 279, 4, 1, 1)
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x80')
  try {
    let _ = decode_tiff_pure(Bytes::from_array(out))
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed("TIFF 仅支持 8-bit 样本") =>
      assert_true(true)
    _ => assert_true(false)
  }
}
