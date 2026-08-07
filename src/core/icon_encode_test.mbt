///|
test "encode_ico: single 4x4 image" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let ico = encode_ico(img)
  // ICO header: 6 bytes + 1 directory entry: 16 bytes + PNG data
  assert_true(ico.length() > 22)
  // 检查 ICO header
  assert_eq(ico[0].to_int(), 0) // reserved
  assert_eq(ico[1].to_int(), 0)
  assert_eq(ico[2].to_int(), 1) // type = ICO
  assert_eq(ico[4].to_int(), 1) // count = 1
  // 检查 directory entry width/height
  assert_eq(ico[6].to_int(), 4) // width
  assert_eq(ico[7].to_int(), 4) // height
  let _ = img
  let _ = ico
}

///|
test "encode_ico: 256x256 uses 0 for width/height" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let resized = resize(img, 256, 256, filter=ResizeFilter::PointSample)
  let ico = encode_ico(resized)
  assert_eq(ico[6].to_int(), 0) // 256 encoded as 0
  assert_eq(ico[7].to_int(), 0)
  let _ = img
  let _ = resized
  let _ = ico
}

///|
test "encode_ico: multi-size" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let img16 = resize(img, 16, 16, filter=ResizeFilter::PointSample)
  let img32 = resize(img, 32, 32, filter=ResizeFilter::PointSample)
  let ico = encode_ico_sizes([img16, img32])
  assert_eq(ico[4].to_int(), 2) // count = 2
  assert_true(ico.length() > 38) // 6 + 2*16 = 38 header
  let _ = img
  let _ = img16
  let _ = img32
  let _ = ico
}

///|
test "encode_ico: too large raises" {
  let img = Image::{
    width: 257,
    height: 257,
    channels: 4,
    data: Array::make(257 * 257 * 4, b'\x00') |> Bytes::from_array,
  }
  try {
    let _ = encode_ico(img)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "encode_icns: 128x128 RGBA" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let resized = resize(img, 128, 128, filter=ResizeFilter::PointSample)
  let icns = encode_icns(resized)
  // 检查 magic "icns"
  assert_eq(icns[0].to_int(), 0x69) // i
  assert_eq(icns[1].to_int(), 0x63) // c
  assert_eq(icns[2].to_int(), 0x6E) // n
  assert_eq(icns[3].to_int(), 0x73) // s
  let _ = img
  let _ = resized
  let _ = icns
}

///|
test "encode_icns: non-square raises" {
  let img = Image::{
    width: 32,
    height: 64,
    channels: 4,
    data: Array::make(32 * 64 * 4, b'\x00') |> Bytes::from_array,
  }
  try {
    let _ = encode_icns(img)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "encode_icns: unsupported size raises" {
  let img = Image::{
    width: 48,
    height: 48,
    channels: 4,
    data: Array::make(48 * 48 * 4, b'\x00') |> Bytes::from_array,
  }
  try {
    let _ = encode_icns(img)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "encode_ico: round-trip with load (PNG in ICO)" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let ico = encode_ico(img)
  // ICO 中的 PNG data 从 offset 22 开始
  // 读取 directory entry 中的 size (offset 14-17)
  let png_size = ico[14].to_int() |
    (ico[15].to_int() << 8) |
    (ico[16].to_int() << 16) |
    (ico[17].to_int() << 24)
  assert_true(png_size > 0)
  // 提取 PNG 数据并验证可以解码
  let png_bytes : Array[Byte] = []
  for i in 0..<png_size {
    png_bytes.push(ico[22 + i])
  }
  let png = Bytes::from_array(png_bytes)
  let img2 = load_from_bytes(png)
  assert_eq(img2.width, 4)
  assert_eq(img2.height, 4)
  let _ = img
  let _ = img2
  let _ = ico
}
