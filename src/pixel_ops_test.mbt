// pixel_ops 测试：threshold / posterize / extract_channel / blend_*

///|
fn make_img(w : Int, h : Int, ch : Int, v : Byte) -> Image {
  Image::{
    width: w,
    height: h,
    channels: ch,
    data: Array::make(w * h * ch, v) |> Bytes::from_array
  }
}

///|
test "threshold: 128 splits values" {
  let img = Image::{
    width: 2,
    height: 1,
    channels: 1,
    data: [b'\x00', b'\xFF'] |> Bytes::from_array
  }
  let result = threshold(img, 128)
  assert_eq(result.data[0], b'\x00')
  assert_eq(result.data[1], b'\xFF')
  let _ = img
  let _ = result
}

///|
test "threshold: preserves alpha" {
  let img = Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: [b'\x40', b'\x40', b'\x40', b'\x80'] |> Bytes::from_array
  }
  let result = threshold(img, 128)
  assert_eq(result.data[3], b'\x80')
  let _ = img
  let _ = result
}

///|
test "posterize: 2 levels equals binary" {
  let img = Image::{
    width: 4,
    height: 1,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array
  }
  let result = posterize(img, 2)
  assert_eq(result.data[0], b'\x00')
  assert_eq(result.data[3], b'\x80')
  let _ = img
  let _ = result
}

///|
test "posterize: raises on invalid levels" {
  let img = make_img(1, 1, 1, b'\x80')
  try {
    let _ = posterize(img, 1)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "extract_channel: extracts R from RGB" {
  let img = Image::{
    width: 2,
    height: 1,
    channels: 3,
    data: [b'\x10', b'\x20', b'\x30', b'\x40', b'\x50', b'\x60'] |> Bytes::from_array
  }
  let r = extract_channel(img, 0)
  assert_eq(r.channels, 1)
  assert_eq(r.data[0], b'\x10')
  assert_eq(r.data[1], b'\x40')
  let g = extract_channel(img, 1)
  assert_eq(g.data[0], b'\x20')
  let b_ch = extract_channel(img, 2)
  assert_eq(b_ch.data[0], b'\x30')
  let _ = img
  let _ = r
  let _ = g
  let _ = b_ch
}

///|
test "extract_channel: raises on out of bounds" {
  let img = make_img(1, 1, 3, b'\x80')
  try {
    let _ = extract_channel(img, 3)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
}

///|
test "blend_multiply: white * any = any" {
  let base = make_img(2, 2, 3, b'\xFF')
  let blend = make_img(2, 2, 3, b'\x80')
  let result = blend_multiply(base, blend)
  assert_eq(result.data[0], b'\x80')
  let _ = base
  let _ = blend
  let _ = result
}

///|
test "blend_multiply: black * any = black" {
  let base = make_img(2, 2, 3, b'\x00')
  let blend = make_img(2, 2, 3, b'\x80')
  let result = blend_multiply(base, blend)
  assert_eq(result.data[0], b'\x00')
  let _ = base
  let _ = blend
  let _ = result
}

///|
test "blend_screen: black + any = any" {
  let base = make_img(2, 2, 3, b'\x00')
  let blend = make_img(2, 2, 3, b'\x80')
  let result = blend_screen(base, blend)
  assert_eq(result.data[0], b'\x80')
  let _ = base
  let _ = blend
  let _ = result
}

///|
test "blend_screen: white + any = white" {
  let base = make_img(2, 2, 3, b'\xFF')
  let blend = make_img(2, 2, 3, b'\x80')
  let result = blend_screen(base, blend)
  assert_eq(result.data[0], b'\xFF')
  let _ = base
  let _ = blend
  let _ = result
}

///|
test "blend_overlay: identity with mid-gray" {
  let base = make_img(2, 2, 3, b'\x80')
  let blend = make_img(2, 2, 3, b'\x80')
  let result = blend_overlay(base, blend)
  // overlay(128, 128) should be around 128
  let v = result.data[0].to_int()
  assert_true(v >= 126 && v <= 130)
  let _ = base
  let _ = blend
  let _ = result
}

///|
test "blend: raises on size mismatch" {
  let base = make_img(2, 2, 3, b'\x80')
  let blend = make_img(3, 3, 3, b'\x80')
  try {
    let _ = blend_multiply(base, blend)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = base
  let _ = blend
}