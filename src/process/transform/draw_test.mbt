///|
fn make_bytes(arr : Array[Byte]) -> Bytes {
  Bytes::from_array(arr)
}

///|
test "draw_copy: copy 2x2 into 4x4" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(4))
  let src = @lib.load_from_bytes_auto(make_1x1_red_bmp(), req_channels=Some(4))
  let result = draw_copy(dst, src, 0, 0)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let _ = dst
  let _ = src
  let _ = result
}

///|
test "draw_copy: out of bounds raises" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(4))
  let src = @lib.load_from_bytes_auto(make_1x1_red_bmp(), req_channels=Some(4))
  try {
    let _ = draw_copy(dst, src, 4, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = dst
  let _ = src
}

///|
test "draw_copy: channel mismatch raises" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(3))
  let src = @lib.load_from_bytes_auto(make_1x1_red_bmp(), req_channels=Some(4))
  try {
    let _ = draw_copy(dst, src, 0, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = dst
  let _ = src
}

///|
test "draw_over: full opacity src overwrites dst" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(4))
  let src = @types.Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: make_bytes([b'\x00', b'\xFF', b'\x00', b'\xFF']),
  }
  let result = draw_over(dst, src, 0, 0)
  // src alpha=255 → result = src
  assert_eq(result.data[0].to_int(), 0)
  assert_eq(result.data[1].to_int(), 255)
  assert_eq(result.data[2].to_int(), 0)
  assert_eq(result.data[3].to_int(), 255)
  let _ = dst
  let _ = src
  let _ = result
}

///|
test "draw_over: zero opacity src preserves dst" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(4))
  let src = @types.Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: make_bytes([b'\x00', b'\xFF', b'\x00', b'\x00']),
  }
  let result = draw_over(dst, src, 0, 0)
  // src alpha=0 → result = dst
  assert_eq(result.data[0].to_int(), dst.data[0].to_int())
  assert_eq(result.data[1].to_int(), dst.data[1].to_int())
  assert_eq(result.data[2].to_int(), dst.data[2].to_int())
  let _ = dst
  let _ = src
  let _ = result
}

///|
test "draw_over: non-RGBA raises" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(3))
  let src = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: make_bytes([b'\x00', b'\xFF', b'\x00']),
  }
  try {
    let _ = draw_over(dst, src, 0, 0)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = dst
  let _ = src
}

///|
test "draw_over: out of bounds raises" {
  let dst = @lib.load_from_bytes_auto(@testdata.test_4x4_red_png, req_channels=Some(4))
  let src = @types.Image::{
    width: 1,
    height: 1,
    channels: 4,
    data: make_bytes([b'\x00', b'\xFF', b'\x00', b'\xFF']),
  }
  try {
    let _ = draw_over(dst, src, 4, 4)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = dst
  let _ = src
}

///|
test "draw_copy: copy preserves src pixels" {
  let dst = @types.Image::{
    width: 2,
    height: 2,
    channels: 3,
    data: Array::make(12, b'\x00') |> Bytes::from_array,
  }
  let src = @types.Image::{
    width: 1,
    height: 1,
    channels: 3,
    data: make_bytes([b'\xFF', b'\xFF', b'\xFF']),
  }
  let result = draw_copy(dst, src, 1, 1)
  // pixel at (1,1) should be white
  let off = (1 * 2 + 1) * 3
  assert_eq(result.data[off].to_int(), 255)
  assert_eq(result.data[off + 1].to_int(), 255)
  assert_eq(result.data[off + 2].to_int(), 255)
  let _ = dst
  let _ = src
  let _ = result
}
