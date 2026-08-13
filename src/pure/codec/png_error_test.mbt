// PNG 解码错误路径测试
// 覆盖 decode_png_pure 的各种错误分支

///|
test "decode_png_pure: invalid signature raises" {
  let bad = b"\x00\x00\x00\x00\x00\x00\x00\x00"
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: truncated data raises" {
  // Only PNG signature, no IHDR
  let bad = b"\x89PNG\r\n\x1A\n"
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: truncated IHDR raises" {
  let out : Array[Byte] = [
    b'\x89', b'P', b'N', b'G', b'\r', b'\n', b'\x1A', b'\n', b'\x00', b'\x00', b'\x00',
    b'\x05', // IHDR length=5 (too short)
     b'I', b'H', b'D', b'R', b'\x00', b'\x00', b'\x00', b'\x01',
  ]
  let bad = Bytes::from_array(out)
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: empty data raises" {
  try {
    let _ = decode_png_pure(b"")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: data too short for signature raises" {
  try {
    let _ = decode_png_pure(b"\x89PNG")
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: interlace flag raises" {
  // Construct a PNG with interlace=1 in IHDR
  let out : Array[Byte] = [
    b'\x89', b'P', b'N', b'G', b'\r', b'\n', b'\x1A', b'\n', b'\x00', b'\x00', b'\x00',
    b'\x0D', // IHDR length=13
     b'I', b'H', b'D', b'R', b'\x00', b'\x00', b'\x00', b'\x01', // width=1
     b'\x00', b'\x00', b'\x00', b'\x01', // height=1
     b'\x08', // bit depth=8
     b'\x02', // color type=2 (RGB)
     b'\x00', // compression=0
     b'\x00', // filter=0
     b'\x01', // interlace=1 (should raise)
  ]
  let bad = Bytes::from_array(out)
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: invalid color type raises" {
  let out : Array[Byte] = [
    b'\x89', b'P', b'N', b'G', b'\r', b'\n', b'\x1A', b'\n', b'\x00', b'\x00', b'\x00',
    b'\x0D', b'I', b'H', b'D', b'R', b'\x00', b'\x00', b'\x00', b'\x01', b'\x00',
    b'\x00', b'\x00', b'\x01', b'\x08', // bit depth=8
     b'\x05', // color type=5 (invalid)
     b'\x00', b'\x00', b'\x00',
  ]
  let bad = Bytes::from_array(out)
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: 16-bit bit depth raises" {
  let out : Array[Byte] = [
    b'\x89', b'P', b'N', b'G', b'\r', b'\n', b'\x1A', b'\n', b'\x00', b'\x00', b'\x00',
    b'\x0D', b'I', b'H', b'D', b'R', b'\x00', b'\x00', b'\x00', b'\x01', b'\x00',
    b'\x00', b'\x00', b'\x01', b'\x10', // bit depth=16 (should raise in 8-bit decoder)
     b'\x02', // color type=2
     b'\x00', b'\x00', b'\x00',
  ]
  let bad = Bytes::from_array(out)
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "decode_png_pure: req_channels out of range defaults to 4" {
  let img = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: [b'\x80', b'\x80', b'\x80'] |> Bytes::from_array,
  }
  let png = encode_png_pure(img)
  // req_channels=5 falls to default case (treated as 4)
  let decoded = decode_png_pure(png, req_channels=Some(5))
  assert_eq(decoded.width, 1)
  assert_eq(decoded.height, 1)
}

///|
test "decode_png_pure: chunk data beyond file raises" {
  let out : Array[Byte] = [
    b'\x89', b'P', b'N', b'G', b'\r', b'\n', b'\x1A', b'\n', b'\x00', b'\x00', b'\xFF',
    b'\xFF', // IHDR length=65535 (beyond file)
     b'I', b'H', b'D', b'R',
  ]
  let bad = Bytes::from_array(out)
  try {
    let _ = decode_png_pure(bad)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}
