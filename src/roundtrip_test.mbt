// 全格式 roundtrip 测试：encode → decode → 验证一致性

///|
test "roundtrip: PNG RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = write_png_to_bytes(img)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PNG RGBA" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = write_png_to_bytes(img)
  let restored = load_from_bytes(encoded, req_channels=Some(4))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: BMP RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = write_bmp_to_bytes(img)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: TGA RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = write_tga_to_bytes(img)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: JPEG dimensions preserved (lossy)" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = write_jpeg_to_bytes(img, quality=90)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = encode_qoi(img)
  let restored = decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGBA" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = encode_qoi(img)
  let restored = decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = encode_gif(img)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PPM RGB" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = encode_ppm(img)
  let restored = load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PGM grayscale" {
  let img = Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array
  }
  let encoded = encode_pgm(img)
  let restored = load_from_bytes(encoded, req_channels=Some(1))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: ICO header valid" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = encode_ico(img)
  // ICO header: reserved=0x0000, type=0x0001 (icon), count=0x0001
  assert_eq(encoded[0], b'\x00')
  assert_eq(encoded[1], b'\x00')
  assert_eq(encoded[2], b'\x01')
  assert_eq(encoded[3], b'\x00')
  assert_eq(encoded[4], b'\x01')
  assert_eq(encoded[5], b'\x00')
  let _ = img
}

///|
test "roundtrip: HDR float" {
  let img = loadf_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = write_hdr_to_bytes(img)
  let restored = loadf_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF animation multi-frame" {
  let img1 = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let img2 = invert(img1)
  let anim = GifAnimation::{ frames: [img1, img2], delays: [100, 200] }
  let encoded = encode_gif_animation(anim)
  let restored = load_gif_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.frames.length(), 2)
  assert_eq(restored.frames[0].width, 4)
  assert_eq(restored.frames[1].width, 4)
  let _ = anim
  let _ = restored
}

///|
test "roundtrip: detect_format + decode_any consistency" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // PNG
  let png = write_png_to_bytes(img)
  assert_eq(detect_format(png), ImageFormat::Png)
  let restored = decode_any(png, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  // BMP
  let bmp = write_bmp_to_bytes(img)
  assert_eq(detect_format(bmp), ImageFormat::Bmp)
  let restored2 = decode_any(bmp, req_channels=Some(3))
  assert_eq(restored2.data, img.data)
  let _ = img
  let _ = restored
  let _ = restored2
}

///|
test "roundtrip: transform pipeline" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // crop → rotate → flip → invert → invert → should be consistent
  let cropped = crop(img, 0, 0, 2, 2)
  let rotated = rotate_90(cropped)
  let flipped = flip_horizontal(rotated)
  let inverted = invert(flipped)
  let restored = invert(inverted)
  // double invert = identity
  assert_eq(restored.data, flipped.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: color conversion pipeline" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // RGB → RGBA → RGB should preserve
  let rgba = to_rgba(img)
  let rgb = to_rgb(rgba)
  assert_eq(rgb.data, img.data)
  let _ = img
  let _ = rgb
}

///|
test "roundtrip: resize then resize back" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // 4x4 → 8x8 → 4x4
  let up = resize(img, 8, 8)
  let down = resize(up, 4, 4)
  assert_eq(down.width, 4)
  assert_eq(down.height, 4)
  let _ = img
  let _ = down
}

///|
test "roundtrip: filter then filter (box_blur twice)" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let blurred1 = box_blur(img, 1)
  let blurred2 = box_blur(blurred1, 1)
  assert_eq(blurred2.width, img.width)
  assert_eq(blurred2.height, img.height)
  let _ = img
  let _ = blurred2
}

///|
test "roundtrip: quantize then encode GIF" {
  let img = load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let quantized = floyd_steinberg(img, 4)
  let gif = encode_gif(quantized)
  let restored = load_from_bytes(gif, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}