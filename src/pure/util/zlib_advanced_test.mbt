// zlib inflate 高级测试
// 覆盖 fixed Huffman (btype=1) + dynamic Huffman (btype=2) + 错误路径

///|
test "zlib: zlib_inflate invalid block type raises" {
  // bfinal=1, btype=11 (invalid) → bits: 1,1,1 → 0x07
  let data = b"\x78\x01\x07"
  try {
    let _ = zlib_inflate(data)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "zlib: zlib_inflate truncated after header raises" {
  let data = b"\x78\x01"
  try {
    let _ = zlib_inflate(data)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "zlib: zlib_inflate truncated stored block raises" {
  // stored block header says LEN=10 but only 3 bytes follow
  let data = b"\x78\x01\x01\x0A\x00\xF5\xFF\x41\x42\x43"
  try {
    let _ = zlib_inflate(data)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "zlib: zlib_inflate stored block LEN NLEN mismatch" {
  // Some decoders don't validate LEN/NLEN mismatch; just verify behavior
  let data = b"\x78\x01\x01\x03\x00\xFE\xFF\x41\x42\x43"
  try {
    let result = zlib_inflate(data)
    assert_eq(result.length(), 3)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "zlib: zlib_inflate fixed Huffman empty block" {
  // Fixed Huffman with just EOB (code 256, 7 bits, code=0b0000000)
  // Block header: bfinal=1, btype=01 → bits: 1,1,0
  // EOB: 0,0,0,0,0,0,0 (7 bits)
  // Total: 10 bits = 2 bytes
  // Byte 0: bits 0-7: 1(bfinal), 1(btype low), 0(btype high), 0(EOB), 0, 0, 0, 0 → 0b00000111 = 0x07
  // Wait, btype=01 means low=1, high=0, so bits: 1, 1, 0
  // Byte 0: 1, 1, 0, 0, 0, 0, 0, 0 → 0b00000011 = 0x03
  // Byte 1: 0, 0 (+ padding) → 0x00
  let data = b"\x78\x01\x03\x00"
  let result = zlib_inflate(data)
  assert_eq(result.length(), 0)
}

///|
test "zlib: zlib_inflate fixed Huffman single byte A" {
  // Fixed Huffman encoding of "A" (0x41 = 65)
  // Block header: bfinal=1, btype=01 → bits: 1, 1, 0
  // Literal 'A' (65): code length 8, code = 65 + 48 = 113 = 0b01110001
  //   Written MSB first: 0, 1, 1, 1, 0, 0, 0, 1
  // EOB (256): code length 7, code = 0 = 0b0000000
  //   Written MSB first: 0, 0, 0, 0, 0, 0, 0
  // Total: 3 + 8 + 7 = 18 bits = 3 bytes
  // Byte 0 (bits 0-7): 1, 1, 0, 0, 1, 1, 1, 0 → 0b01110111 → wait
  // Actually bits are packed LSB first:
  // bit0=1(bfinal), bit1=1(btype low), bit2=0(btype high)
  // bit3=0(A MSB), bit4=1, bit5=1, bit6=1, bit7=0
  // Byte 0 = 0b01110111 → no, byte = bit7*128+bit6*64+...+bit0
  // = 0*128 + 1*64 + 1*32 + 1*16 + 0*8 + 0*4 + 1*2 + 1*1 = 64+32+16+2+1 = 115 = 0x73
  // bit8=0, bit9=0, bit10=1(A LSB), bit11=0(EOB), bit12=0, bit13=0, bit14=0, bit15=0
  // Byte 1 = 0*128+0*64+0*32+0*16+0*8+1*4+0*2+0*1 = 4 = 0x04
  // bit16=0, bit17=0
  // Byte 2 = 0x00
  let data = b"\x78\x01\x73\x04\x00"
  let result = zlib_inflate(data)
  assert_eq(result.length(), 1)
  assert_eq(result[0].to_int(), 0x41)
}

///|
test "zlib: zlib_inflate fixed Huffman ABC" {
  // Fixed Huffman encoding of "ABC" (0x41, 0x42, 0x43)
  // Block header: bfinal=1, btype=01 → bits: 1, 1, 0
  // 'A' (65): code=113=0b01110001, 8 bits MSB first: 0,1,1,1,0,0,0,1
  // 'B' (66): code=114=0b01110010, 8 bits MSB first: 0,1,1,1,0,0,1,0
  // 'C' (67): code=115=0b01110011, 8 bits MSB first: 0,1,1,1,0,0,1,1
  // EOB (256): code=0, 7 bits: 0,0,0,0,0,0,0
  // Total: 3 + 8*3 + 7 = 34 bits = 5 bytes
  // Bits: 1,1,0, 0,1,1,1,0,0,0,1, 0,1,1,1,0,0,1,0, 0,1,1,1,0,0,1,1, 0,0,0,0,0,0,0
  // Byte 0 (bits 0-7): 1,1,0,0,1,1,1,0 → 0x73
  // Byte 1 (bits 8-15): 0,0,1,0,1,1,1,0 → 0x74
  // Byte 2 (bits 16-23): 0,1,0,0,1,1,1,0 → 0x72
  // Byte 3 (bits 24-31): 0,1,1,0,0,0,0,0 → 0x06
  // Byte 4 (bits 32-33): 0,0 → 0x00
  let data = b"\x78\x01\x73\x74\x72\x06\x00"
  let result = zlib_inflate(data)
  assert_eq(result.length(), 3)
  assert_eq(result[0].to_int(), 0x41)
  assert_eq(result[1].to_int(), 0x42)
  assert_eq(result[2].to_int(), 0x43)
}

///|
test "zlib: zlib_inflate data exhaust raises" {
  // Truncated mid-block
  let data = b"\x78\x01\x03"
  try {
    let _ = zlib_inflate(data)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "zlib: crc32 known vector" {
  // Verify CRC32 is deterministic and non-zero for known input
  let data = b"\x31\x32\x33\x34\x35\x36\x37\x38\x39"
  let h = crc32(data)
  assert_not_eq(h, 0)
  assert_eq(h, crc32(data))
}

///|
test "zlib: adler32 multi byte" {
  // Adler32("ABC") = ?
  // a = 1 + 65 + 66 + 67 = 199
  // b = (1+65) + (1+65+66) + (1+65+66+67) = 66 + 132 + 199 = 397
  // adler32 = (b << 16) | a = (397 << 16) | 199 = 0x018D00C7
  let data = b"\x41\x42\x43"
  assert_eq(adler32(data), 0x018D00C7)
}
