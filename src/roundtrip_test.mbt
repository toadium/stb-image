// 全格式 roundtrip 测试：encode → decode → 验证一致性

///|
test "roundtrip: PNG RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @core.write_png_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PNG RGBA" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = @core.write_png_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(4))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: BMP RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @core.write_bmp_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: TGA RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @core.write_tga_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: JPEG dimensions preserved (lossy)" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @core.write_jpeg_to_bytes(img, quality=90)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @format.encode_qoi(img)
  let restored = @format.decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGBA" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = @format.encode_qoi(img)
  let restored = @format.decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @format.encode_gif(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PPM RGB" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @format.encode_ppm(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PGM grayscale" {
  let img = @core.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array
  }
  let encoded = @format.encode_pgm(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(1))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: ICO header valid" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(4))
  let encoded = @core.encode_ico(img)
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
  let img = @core.loadf_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let encoded = @core.write_hdr_to_bytes(img)
  let restored = @core.loadf_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF animation multi-frame" {
  let img1 = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let img2 = @process.invert(img1)
  let anim = @core.GifAnimation::{ frames: [img1, img2], delays: [100, 200] }
  let encoded = @format.encode_gif_animation(anim)
  let restored = @core.load_gif_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.frames.length(), 2)
  assert_eq(restored.frames[0].width, 4)
  assert_eq(restored.frames[1].width, 4)
  let _ = anim
  let _ = restored
}

///|
test "roundtrip: detect_format + decode_any consistency" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // PNG
  let png = @core.write_png_to_bytes(img)
  assert_eq(@core.detect_format(png), @core.ImageFormat::Png)
  let restored = @core.decode_any(png, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  // BMP
  let bmp = @core.write_bmp_to_bytes(img)
  assert_eq(@core.detect_format(bmp), @core.ImageFormat::Bmp)
  let restored2 = @core.decode_any(bmp, req_channels=Some(3))
  assert_eq(restored2.data, img.data)
  let _ = img
  let _ = restored
  let _ = restored2
}

///|
test "roundtrip: transform pipeline" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // crop → rotate → flip → invert → invert → should be consistent
  let cropped = @process.crop(img, 0, 0, 2, 2)
  let rotated = @process.rotate_90(cropped)
  let flipped = @process.flip_horizontal(rotated)
  let inverted = @process.invert(flipped)
  let restored = @process.invert(inverted)
  // double invert = identity
  assert_eq(restored.data, flipped.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: color conversion pipeline" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // RGB → RGBA → RGB should preserve
  let rgba = @process.to_rgba(img)
  let rgb = @process.to_rgb(rgba)
  assert_eq(rgb.data, img.data)
  let _ = img
  let _ = rgb
}

///|
test "roundtrip: resize then resize back" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  // 4x4 → 8x8 → 4x4
  let up = @core.resize(img, 8, 8)
  let down = @core.resize(up, 4, 4)
  assert_eq(down.width, 4)
  assert_eq(down.height, 4)
  let _ = img
  let _ = down
}

///|
test "roundtrip: filter then filter (box_blur twice)" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let blurred1 = @process.box_blur(img, 1)
  let blurred2 = @process.box_blur(blurred1, 1)
  assert_eq(blurred2.width, img.width)
  assert_eq(blurred2.height, img.height)
  let _ = img
  let _ = blurred2
}

///|
test "roundtrip: quantize then encode GIF" {
  let img = @core.load_from_path("testdata/test_4x4_red.png", req_channels=Some(3))
  let quantized = @process.floyd_steinberg(img, 4)
  let gif = @format.encode_gif(quantized)
  let restored = @core.load_from_bytes(gif, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}