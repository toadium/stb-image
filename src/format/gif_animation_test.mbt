///|
test "encode_gif_animation: single frame" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let anim = @types.GifAnimation::{ frames: [img], delays: [100] }
  let gif = encode_gif_animation(anim)
  // GIF89a header
  assert_eq(gif[0].to_int(), 0x47) // G
  assert_eq(gif[1].to_int(), 0x49) // I
  assert_eq(gif[2].to_int(), 0x46) // F
  assert_eq(gif[3].to_int(), 0x38) // 8
  assert_eq(gif[4].to_int(), 0x39) // 9
  assert_eq(gif[5].to_int(), 0x61) // a
  // 以 trailer 结尾
  assert_eq(gif[gif.length() - 1].to_int(), 0x3B)
  let _ = img
  let _ = gif
}

///|
test "encode_gif_animation: multi-frame" {
  let img1 = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  // 创建第二帧（反色）
  let img2 = @color.invert(img1)
  let anim = @types.GifAnimation::{ frames: [img1, img2], delays: [100, 200] }
  let gif = encode_gif_animation(anim)
  // 应包含 Netscape Application Extension
  let mut has_netscape = false
  for i in 0..<(gif.length() - 10) {
    if gif[i].to_int() == 0x4E &&
      gif[i + 1].to_int() == 0x45 &&
      gif[i + 2].to_int() == 0x54 &&
      gif[i + 3].to_int() == 0x53 {
      has_netscape = true
      break
    }
  }
  assert_true(has_netscape)
  // 以 trailer 结尾
  assert_eq(gif[gif.length() - 1].to_int(), 0x3B)
  let _ = gif
}

///|
test "encode_gif_animation: round-trip with load_gif" {
  let img1 = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let img2 = @color.invert(img1)
  let anim = @types.GifAnimation::{ frames: [img1, img2], delays: [100, 200] }
  let gif = encode_gif_animation(anim)
  // 用 stb_image 加载
  let restored = @codec.decode_gif_animation_pure(gif)
  assert_eq(restored.frames.length(), 2)
  assert_eq(restored.frames[0].width, 4)
  assert_eq(restored.frames[0].height, 4)
  let _ = gif
  let _ = restored
}

///|
test "encode_gif_animation: empty frames raises" {
  let anim = @types.GifAnimation::{ frames: [], delays: [] }
  try {
    let _ = encode_gif_animation(anim)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = anim
}

///|
test "encode_gif_animation: mismatched lengths raises" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let anim = @types.GifAnimation::{ frames: [img], delays: [100, 200] }
  try {
    let _ = encode_gif_animation(anim)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
  let _ = anim
}

///|
test "encode_gif_animation: invalid channels raises" {
  let img = @types.Image::{
    width: 1,
    height: 1,
    channels: 1,
    data: [b'\x80'] |> Bytes::from_array,
  }
  let anim = @types.GifAnimation::{ frames: [img], delays: [100] }
  try {
    let _ = encode_gif_animation(anim)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
  let _ = img
  let _ = anim
}

///|
test "encode_gif_animation: detect_format recognizes GIF" {
  let img = @lib.load_from_bytes_auto(
    @testdata.test_4x4_red_png,
    req_channels=Some(3),
  )
  let anim = @types.GifAnimation::{
    frames: [img, @color.invert(img)],
    delays: [100, 100],
  }
  let gif = encode_gif_animation(anim)
  let fmt = @lib.detect_format(gif)
  assert_eq(fmt, @types.ImageFormat::Gif)
  let _ = img
  let _ = gif
  let _ = fmt
}
