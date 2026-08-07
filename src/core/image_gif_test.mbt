///|
test "load_gif_from_path: single-frame GIF returns 1 frame" {
  let anim = load_gif_from_path("testdata/test_4x4_red.gif")
  assert_true(anim.frames.length() >= 1)
  assert_eq(anim.delays.length(), anim.frames.length())
}

///|
test "load_gif_from_path: GIF frame dimensions match" {
  let anim = load_gif_from_path("testdata/test_4x4_red.gif")
  let frame = anim.frames[0]
  assert_eq(frame.width, 4)
  assert_eq(frame.height, 4)
}

///|
test "load_gif_from_bytes: empty bytes raises DecodeFailed" {
  let empty = b""
  try {
    let _ = load_gif_from_bytes(empty)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_gif_from_bytes: invalid data raises DecodeFailed" {
  let invalid = b"\x00\x01\x02\x03"
  try {
    let _ = load_gif_from_bytes(invalid)
    assert_true(false)
  } catch {
    LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "load_gif_from_path: req_channels=4 returns RGBA frames" {
  let anim = load_gif_from_path(
    "testdata/test_4x4_red.gif",
    req_channels=Some(4),
  )
  let frame = anim.frames[0]
  assert_eq(frame.channels, 4)
  assert_eq(frame.data.length(), frame.width * frame.height * 4)
}

///|
test "load_gif_from_path: pixel data is red for first frame" {
  let anim = load_gif_from_path("testdata/test_4x4_red.gif")
  let frame = anim.frames[0]
  if frame.channels >= 3 {
    assert_eq(frame.data[0].to_int(), 255)
    assert_eq(frame.data[1].to_int(), 0)
    assert_eq(frame.data[2].to_int(), 0)
  }
}
