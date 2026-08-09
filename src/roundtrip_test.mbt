// 全格式 roundtrip 测试：encode → decode → 验证一致性

///|
test "roundtrip: PNG RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
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
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let encoded = @core.write_png_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(4))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: BMP RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @core.write_bmp_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: BMP RGB pure vs FFI" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let bmp_bytes = @core.write_bmp_to_bytes(img)
  let pure_decoded = @pure.decode_bmp_pure(bmp_bytes)
  let ffi_decoded = @core.load_from_bytes(bmp_bytes, req_channels=Some(3))
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: TGA RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @core.write_tga_to_bytes(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: JPEG dimensions preserved (lossy)" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @core.write_jpeg_to_bytes(img, quality=90)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @format.encode_qoi(img)
  let restored = @format.decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI RGBA" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let encoded = @format.encode_qoi(img)
  let restored = @format.decode_qoi(encoded)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: QOI pure vs format" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let qoi_bytes = @format.encode_qoi(img)
  let pure_decoded = @pure.decode_qoi_pure(qoi_bytes)
  let format_decoded = @format.decode_qoi(qoi_bytes)
  // pure 包独立实现 vs format 包独立实现交叉验证
  assert_eq(pure_decoded.width, format_decoded.width)
  assert_eq(pure_decoded.height, format_decoded.height)
  assert_eq(pure_decoded.channels, format_decoded.channels)
  assert_eq(pure_decoded.data, format_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = format_decoded
}

///|
test "roundtrip: GIF RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @format.encode_gif(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PPM RGB" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
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
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array,
  }
  let encoded = @format.encode_pgm(img)
  let restored = @core.load_from_bytes(encoded, req_channels=Some(1))
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: ICO header valid" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
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
  let img = @core.loadf_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @core.write_hdr_to_bytes(img)
  let restored = @core.loadf_from_bytes(encoded, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF animation multi-frame" {
  let img1 = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let img2 = @color.invert(img1)
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
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
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
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  // crop → rotate → flip → invert → invert → should be consistent
  let cropped = @transform.crop(img, 0, 0, 2, 2)
  let rotated = @transform.rotate_90(cropped)
  let flipped = @transform.flip_horizontal(rotated)
  let inverted = @color.invert(flipped)
  let restored = @color.invert(inverted)
  // double invert = identity
  assert_eq(restored.data, flipped.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: color conversion pipeline" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  // RGB → RGBA → RGB should preserve
  let rgba = @color.to_rgba(img)
  let rgb = @color.to_rgb(rgba)
  assert_eq(rgb.data, img.data)
  let _ = img
  let _ = rgb
}

///|
test "roundtrip: resize then resize back" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
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
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let blurred1 = @filter.box_blur(img, 1)
  let blurred2 = @filter.box_blur(blurred1, 1)
  assert_eq(blurred2.width, img.width)
  assert_eq(blurred2.height, img.height)
  let _ = img
  let _ = blurred2
}

///|
test "roundtrip: quantize then encode GIF" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let quantized = @segment.floyd_steinberg(img, 4)
  let gif = @format.encode_gif(quantized)
  let restored = @core.load_from_bytes(gif, req_channels=Some(3))
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: TGA pure vs FFI" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let tga_bytes = @core.write_tga_to_bytes(img)
  let pure_decoded = @pure.decode_tga_pure(tga_bytes)
  let ffi_decoded = @core.load_from_bytes(tga_bytes, req_channels=Some(3))
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: PPM RGB pure vs FFI" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let encoded = @format.encode_ppm(img)
  let pure_decoded = @pure.decode_pnm_pure(encoded)
  let ffi_decoded = @core.load_from_bytes(encoded, req_channels=Some(3))
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: PGM grayscale pure vs FFI" {
  let img = @core.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: [b'\x00', b'\x40', b'\x80', b'\xFF'] |> Bytes::from_array,
  }
  let encoded = @format.encode_pgm(img)
  let pure_decoded = @pure.decode_pnm_pure(encoded)
  let ffi_decoded = @core.load_from_bytes(encoded, req_channels=Some(1))
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
/// 构造 PSD 字节流辅助：header(26) + 3 个空段 + image data(compression=0 + 按通道排列像素)
fn make_psd_bytes(
  channel_count : Int,
  h : Int,
  w : Int,
  channels_data : Array[Array[Byte]],
) -> Bytes {
  let out : Array[Byte] = []
  // signature "8BPS"
  out.push(b'\x38')
  out.push(b'\x42')
  out.push(b'\x50')
  out.push(b'\x53')
  // version=1 (BE)
  out.push(b'\x00')
  out.push(b'\x01')
  // reserved 6 字节
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // channelCount (BE)
  out.push(((channel_count >> 8) & 0xFF).to_byte())
  out.push((channel_count & 0xFF).to_byte())
  // h (BE)
  out.push(((h >> 24) & 0xFF).to_byte())
  out.push(((h >> 16) & 0xFF).to_byte())
  out.push(((h >> 8) & 0xFF).to_byte())
  out.push((h & 0xFF).to_byte())
  // w (BE)
  out.push(((w >> 24) & 0xFF).to_byte())
  out.push(((w >> 16) & 0xFF).to_byte())
  out.push(((w >> 8) & 0xFF).to_byte())
  out.push((w & 0xFF).to_byte())
  // bitdepth=8 (BE)
  out.push(b'\x00')
  out.push(b'\x08')
  // colorMode=3 (RGB, BE)
  out.push(b'\x00')
  out.push(b'\x03')
  // 3 个空段
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  out.push(b'\x00')
  // compression=0 (BE)
  out.push(b'\x00')
  out.push(b'\x00')
  // 按通道排列像素
  for ch in channels_data {
    for b in ch {
      out.push(b)
    }
  }
  Bytes::from_array(out)
}

///|
test "roundtrip: PSD RGB pure vs FFI" {
  // 2x2 3 通道 RGB PSD，像素值各不同
  // R 通道 [10,20,30,40] G 通道 [50,60,70,80] B 通道 [90,100,110,120]
  let r : Array[Byte] = [b'\x0A', b'\x14', b'\x1E', b'\x28']
  let g : Array[Byte] = [b'\x32', b'\x3C', b'\x46', b'\x50']
  let b : Array[Byte] = [b'\x5A', b'\x64', b'\x6E', b'\x78']
  let psd_bytes = make_psd_bytes(3, 2, 2, [r, g, b])
  let pure_decoded = @pure.decode_psd_pure(psd_bytes)
  // req_channels=Some(3) 让 @core 返回 3 通道匹配 pure 输出
  // stb_image PSD 内部输出 4 通道 RGBA，req_channels=3 强制转 3 通道
  let ffi_decoded = @core.load_from_bytes(psd_bytes, req_channels=Some(3))
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: PSD RGBA pure vs FFI" {
  // 2x2 4 通道 RGBA PSD，alpha 全为 255，避免 stb_image white matte removal 修改 RGB
  // R 通道 [10,20,30,40] G 通道 [50,60,70,80] B 通道 [90,100,110,120] A 通道 [255,255,255,255]
  let r : Array[Byte] = [b'\x0A', b'\x14', b'\x1E', b'\x28']
  let g : Array[Byte] = [b'\x32', b'\x3C', b'\x46', b'\x50']
  let b : Array[Byte] = [b'\x5A', b'\x64', b'\x6E', b'\x78']
  let a : Array[Byte] = [b'\xFF', b'\xFF', b'\xFF', b'\xFF']
  let psd_bytes = make_psd_bytes(4, 2, 2, [r, g, b, a])
  let pure_decoded = @pure.decode_psd_pure(psd_bytes)
  // 默认返回 4 通道，alpha=255 避免 white matte removal
  let ffi_decoded = @core.load_from_bytes(psd_bytes)
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: GIF RGB pure vs FFI" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let gif_bytes = @format.encode_gif(img)
  let pure_decoded = @pure.decode_gif_pure(gif_bytes)
  let ffi_decoded = @core.load_from_bytes(gif_bytes, req_channels=Some(3))
  // pure 包独立实现 vs stb_image C 库原生 FFI 基准对比
  assert_eq(pure_decoded.width, ffi_decoded.width)
  assert_eq(pure_decoded.height, ffi_decoded.height)
  assert_eq(pure_decoded.channels, ffi_decoded.channels)
  assert_eq(pure_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = pure_decoded
  let _ = ffi_decoded
}

///|
test "roundtrip: QOI pure encode→decode" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let qoi_bytes = @pure.encode_qoi_pure(img)
  let restored = @pure.decode_qoi_pure(qoi_bytes)
  // pure 编码 → pure 解码 roundtrip
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.channels, img.channels)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PPM pure encode→decode" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let ppm_bytes = @pure.encode_ppm_pure(img)
  let restored = @pure.decode_pnm_pure(ppm_bytes)
  // pure 编码 → pure 解码 roundtrip
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.channels, img.channels)
  assert_eq(restored.data, img.data)
  let _ = img
  let _ = restored
}

///|
test "roundtrip: PGM pure encode→decode" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pgm_bytes = @pure.encode_pgm_pure(img)
  let restored = @pure.decode_pnm_pure(pgm_bytes)
  // pure 编码 → pure 解码 roundtrip（RGB → 灰度转换）
  assert_eq(restored.width, img.width)
  assert_eq(restored.height, img.height)
  assert_eq(restored.channels, 1)
  // 逐像素验证 BT.601 灰度转换
  let n = img.width * img.height
  for i in 0..<n {
    let r = img.data[i * 3].to_int()
    let g = img.data[i * 3 + 1].to_int()
    let b = img.data[i * 3 + 2].to_int()
    let expected_gray = (r * 299 + g * 587 + b * 114) / 1000
    assert_eq(restored.data[i].to_int(), expected_gray)
  }
  let _ = img
  let _ = restored
}

///|
test "roundtrip: GIF pure encode→decode" {
  // 加载 PNG → pure encode GIF → pure decode GIF → 验证 roundtrip 稳定性
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let gif_bytes = @pure.encode_gif_pure(img)
  let restored1 = @pure.decode_gif_pure(gif_bytes)
  // GIF 3-3-2 量化后颜色可能变化，断言 roundtrip 稳定性：
  // 再次 encode → decode 结果与第一次一致
  let gif_bytes2 = @pure.encode_gif_pure(restored1)
  let restored2 = @pure.decode_gif_pure(gif_bytes2)
  assert_eq(restored1.width, restored2.width)
  assert_eq(restored1.height, restored2.height)
  assert_eq(restored1.channels, restored2.channels)
  assert_eq(restored1.data, restored2.data)
  let _ = img
  let _ = restored1
  let _ = restored2
}

///|
test "roundtrip: GIF pure encode vs FFI decode" {
  // pure encode → pure decode vs FFI decode 结果一致
  let orig_img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let gif_bytes = @pure.encode_gif_pure(orig_img)
  let pure_img = @pure.decode_gif_pure(gif_bytes)
  let ffi_img = @core.load_from_bytes(gif_bytes, req_channels=Some(3))
  // pure decode 与 FFI decode 结果一致：
  // 两者均输出 GIF 调色板中的 3-3-2 量化后颜色，stb_image 解码 GIF 不做颜色变换故与 pure 量化结果一致
  assert_eq(pure_img.width, ffi_img.width)
  assert_eq(pure_img.height, ffi_img.height)
  assert_eq(pure_img.channels, ffi_img.channels)
  assert_eq(pure_img.data, ffi_img.data)
  let _ = orig_img
  let _ = pure_img
  let _ = ffi_img
}

///|
test "lib vs core: BMP auto decode" {
  // @lib.load_from_bytes_auto（pure 侧自动分派）vs @core.load_from_bytes（FFI 基准）
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let bmp_bytes = @core.write_bmp_to_bytes(img)
  let lib_decoded = @lib.load_from_bytes_auto(bmp_bytes)
  let ffi_decoded = @core.load_from_bytes(bmp_bytes, req_channels=Some(3))
  assert_eq(lib_decoded.width, ffi_decoded.width)
  assert_eq(lib_decoded.height, ffi_decoded.height)
  assert_eq(lib_decoded.channels, ffi_decoded.channels)
  assert_eq(lib_decoded.data, ffi_decoded.data)
  let _ = img
  let _ = lib_decoded
  let _ = ffi_decoded
}

///|
test "lib vs format: QOI auto decode" {
  // @lib.load_from_bytes_auto（pure 侧自动分派）vs @format.decode_qoi（format 包纯 MoonBit 基准）
  // stb C 库不原生支持 QOI，@core.load_from_bytes 解码 QOI 会 raise LoadError，故用 @format.decode_qoi 作基准
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let qoi_bytes = @format.encode_qoi(img)
  let lib_decoded = @lib.load_from_bytes_auto(qoi_bytes)
  let format_decoded = @format.decode_qoi(qoi_bytes)
  assert_eq(lib_decoded.width, format_decoded.width)
  assert_eq(lib_decoded.height, format_decoded.height)
  assert_eq(lib_decoded.channels, format_decoded.channels)
  assert_eq(lib_decoded.data, format_decoded.data)
  let _ = img
  let _ = lib_decoded
  let _ = format_decoded
}

///|
test "transform: crop pure vs process" {
  // @pure.crop_pure（纯 MoonBit，全目标）vs @transform.crop（process 包基准）
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.crop_pure(img, 0, 0, 2, 2)
  let proc_out = @transform.crop(img, 0, 0, 2, 2)
  assert_eq(pure_out.width, proc_out.width)
  assert_eq(pure_out.height, proc_out.height)
  assert_eq(pure_out.channels, proc_out.channels)
  assert_eq(pure_out.data, proc_out.data)
  let _ = img
  let _ = pure_out
  let _ = proc_out
}

///|
test "transform: rotate_90 pure vs process" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.rotate_90_pure(img)
  let proc_out = @transform.rotate_90(img)
  assert_eq(pure_out.width, proc_out.width)
  assert_eq(pure_out.height, proc_out.height)
  assert_eq(pure_out.channels, proc_out.channels)
  assert_eq(pure_out.data, proc_out.data)
  let _ = img
  let _ = pure_out
  let _ = proc_out
}

///|
test "transform: rotate_180 pure vs process" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.rotate_180_pure(img)
  let proc_out = @transform.rotate_180(img)
  assert_eq(pure_out.width, proc_out.width)
  assert_eq(pure_out.height, proc_out.height)
  assert_eq(pure_out.channels, proc_out.channels)
  assert_eq(pure_out.data, proc_out.data)
  let _ = img
  let _ = pure_out
  let _ = proc_out
}

///|
test "transform: rotate_270 pure vs process" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.rotate_270_pure(img)
  let proc_out = @transform.rotate_270(img)
  assert_eq(pure_out.width, proc_out.width)
  assert_eq(pure_out.height, proc_out.height)
  assert_eq(pure_out.channels, proc_out.channels)
  assert_eq(pure_out.data, proc_out.data)
  let _ = img
  let _ = pure_out
  let _ = proc_out
}

///|
test "transform: flip_horizontal pure vs process" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.flip_horizontal_pure(img)
  let proc_out = @transform.flip_horizontal(img)
  assert_eq(pure_out.width, proc_out.width)
  assert_eq(pure_out.height, proc_out.height)
  assert_eq(pure_out.channels, proc_out.channels)
  assert_eq(pure_out.data, proc_out.data)
  let _ = img
  let _ = pure_out
  let _ = proc_out
}

///|
test "pure vs color: to_grayscale" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.to_grayscale_pure(img)
  let color_out = @color.to_grayscale(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: to_rgb" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let pure_out = @pure.to_rgb_pure(img)
  let color_out = @color.to_rgb(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: to_rgba" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.to_rgba_pure(img)
  let color_out = @color.to_rgba(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: premultiply_alpha" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let pure_out = @pure.premultiply_alpha_pure(img)
  let color_out = @color.premultiply_alpha(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: unpremultiply_alpha" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let pure_out = @pure.unpremultiply_alpha_pure(img)
  let color_out = @color.unpremultiply_alpha(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: adjust_brightness" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.adjust_brightness_pure(img, 50)
  let color_out = @color.adjust_brightness(img, 50)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: adjust_contrast" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.adjust_contrast_pure(img, 2.0F)
  let color_out = @color.adjust_contrast(img, 2.0F)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: adjust_gamma" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.adjust_gamma_pure(img, 2.2F)
  let color_out = @color.adjust_gamma(img, 2.2F)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs color: invert" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.invert_pure(img)
  let color_out = @color.invert(img)
  assert_eq(pure_out.width, color_out.width)
  assert_eq(pure_out.height, color_out.height)
  assert_eq(pure_out.channels, color_out.channels)
  assert_eq(pure_out.data, color_out.data)
  let _ = img
  let _ = pure_out
  let _ = color_out
}

///|
test "pure vs filter: box_blur" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.box_blur_pure(img, 1)
  let filter_out = @filter.box_blur(img, 1)
  assert_eq(pure_out.width, filter_out.width)
  assert_eq(pure_out.height, filter_out.height)
  assert_eq(pure_out.channels, filter_out.channels)
  assert_eq(pure_out.data, filter_out.data)
  let _ = img
  let _ = pure_out
  let _ = filter_out
}

///|
test "pure vs filter: gaussian_blur" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.gaussian_blur_pure(img, 2, 1.5F)
  let filter_out = @filter.gaussian_blur(img, 2, 1.5F)
  assert_eq(pure_out.width, filter_out.width)
  assert_eq(pure_out.height, filter_out.height)
  assert_eq(pure_out.channels, filter_out.channels)
  assert_eq(pure_out.data, filter_out.data)
  let _ = img
  let _ = pure_out
  let _ = filter_out
}

///|
test "pure vs filter: sharpen" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.sharpen_pure(img, 0.5F)
  let filter_out = @filter.sharpen(img, 0.5F)
  assert_eq(pure_out.width, filter_out.width)
  assert_eq(pure_out.height, filter_out.height)
  assert_eq(pure_out.channels, filter_out.channels)
  assert_eq(pure_out.data, filter_out.data)
  let _ = img
  let _ = pure_out
  let _ = filter_out
}

///|
test "pure vs filter: edge_detect_sobel" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.edge_detect_sobel_pure(img)
  let filter_out = @filter.edge_detect_sobel(img)
  assert_eq(pure_out.width, filter_out.width)
  assert_eq(pure_out.height, filter_out.height)
  assert_eq(pure_out.channels, filter_out.channels)
  assert_eq(pure_out.data, filter_out.data)
  let _ = img
  let _ = pure_out
  let _ = filter_out
}

///|
test "roundtrip: histogram_equalize pure vs feature" {
  let orig_img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_img = @pure.histogram_equalize_pure(orig_img)
  let feature_img = @feature.histogram_equalize(orig_img)
  assert_eq(pure_img.width, feature_img.width)
  assert_eq(pure_img.height, feature_img.height)
  assert_eq(pure_img.channels, feature_img.channels)
  assert_eq(pure_img.data, feature_img.data)
  let _ = orig_img
  let _ = pure_img
  let _ = feature_img
}

///|
test "roundtrip: histogram_normalize pure vs feature" {
  let orig_img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_img = @pure.histogram_normalize_pure(orig_img)
  let feature_img = @feature.histogram_normalize(orig_img)
  assert_eq(pure_img.width, feature_img.width)
  assert_eq(pure_img.height, feature_img.height)
  assert_eq(pure_img.channels, feature_img.channels)
  assert_eq(pure_img.data, feature_img.data)
  let _ = orig_img
  let _ = pure_img
  let _ = feature_img
}

///|
test "pure vs segment: erode" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.erode_pure(img)
  let segment_out = @segment.erode(img)
  assert_eq(pure_out.width, segment_out.width)
  assert_eq(pure_out.height, segment_out.height)
  assert_eq(pure_out.channels, segment_out.channels)
  assert_eq(pure_out.data, segment_out.data)
  let _ = img
  let _ = pure_out
  let _ = segment_out
}

///|
test "pure vs segment: dilate" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.dilate_pure(img)
  let segment_out = @segment.dilate(img)
  assert_eq(pure_out.width, segment_out.width)
  assert_eq(pure_out.height, segment_out.height)
  assert_eq(pure_out.channels, segment_out.channels)
  assert_eq(pure_out.data, segment_out.data)
  let _ = img
  let _ = pure_out
  let _ = segment_out
}

///|
test "pure vs segment: morph_open" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.morph_open_pure(img)
  let segment_out = @segment.morph_open(img)
  assert_eq(pure_out.width, segment_out.width)
  assert_eq(pure_out.height, segment_out.height)
  assert_eq(pure_out.channels, segment_out.channels)
  assert_eq(pure_out.data, segment_out.data)
  let _ = img
  let _ = pure_out
  let _ = segment_out
}

///|
test "pure vs segment: morph_close" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_out = @pure.morph_close_pure(img)
  let segment_out = @segment.morph_close(img)
  assert_eq(pure_out.width, segment_out.width)
  assert_eq(pure_out.height, segment_out.height)
  assert_eq(pure_out.channels, segment_out.channels)
  assert_eq(pure_out.data, segment_out.data)
  let _ = img
  let _ = pure_out
  let _ = segment_out
}

///|
test "warp_affine: pure vs transform" {
  let orig = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_img = @pure.warp_affine_pure(
    orig,
    (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F),
    4,
    4,
  )
  let ffi_img = @transform.warp_affine(
    orig,
    (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F),
    4,
    4,
  )
  assert_eq(pure_img.width, ffi_img.width)
  assert_eq(pure_img.height, ffi_img.height)
  assert_eq(pure_img.channels, ffi_img.channels)
  assert_eq(pure_img.data, ffi_img.data)
  let _ = orig
  let _ = pure_img
  let _ = ffi_img
}

///|
test "rotate: pure vs transform" {
  let orig = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let pure_img = @pure.rotate_pure(orig, 45.0F)
  let ffi_img = @transform.rotate(orig, 45.0F)
  assert_eq(pure_img.width, ffi_img.width)
  assert_eq(pure_img.height, ffi_img.height)
  assert_eq(pure_img.channels, ffi_img.channels)
  assert_eq(pure_img.data, ffi_img.data)
  let _ = orig
  let _ = pure_img
  let _ = ffi_img
}
