// reexport.mbt 公开 API 测试
// 覆盖 reexport.mbt 中未覆盖的转发函数

///|
fn re_make_rgb(
  width : Int,
  height : Int,
  pixels : Array[(Int, Int, Int)],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.0.to_byte())
    data.push(p.1.to_byte())
    data.push(p.2.to_byte())
  }
  @types.Image::{ width, height, channels: 3, data: Bytes::from_array(data) }
}

///|
test "reexport: detect_format BMP" {
  let img = re_make_rgb(2, 2, [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)])
  let bmp_bytes = @codec.encode_bmp_pure(img)
  assert_true(detect_format(bmp_bytes) is @types.ImageFormat::Bmp)
}

///|
test "reexport: detect_format PNG" {
  let img = re_make_rgb(2, 2, [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)])
  let png_bytes = @codec.encode_png_pure(img)
  assert_true(detect_format(png_bytes) is @types.ImageFormat::Png)
}

///|
test "reexport: detect_format JPEG" {
  let img = re_make_rgb(2, 2, [(0, 0, 0), (255, 0, 0), (0, 255, 0), (0, 0, 255)])
  let jpeg_bytes = @codec.encode_jpeg_pure(img)
  assert_true(detect_format(jpeg_bytes) is @types.ImageFormat::Jpeg)
}

///|
test "reexport: detect_format unknown" {
  let data = b"\x00\x01\x02\x03"
  assert_true(detect_format(data) is @types.ImageFormat::Unknown)
}

///|
test "reexport: is_supported_format" {
  let img = re_make_rgb(1, 1, [(128, 128, 128)])
  let bmp_bytes = @codec.encode_bmp_pure(img)
  assert_true(is_supported_format(bmp_bytes))
  assert_false(is_supported_format(b"\x00\x01\x02\x03"))
}

///|
test "reexport: decode_any BMP" {
  let img = re_make_rgb(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let bmp_bytes = @codec.encode_bmp_pure(img)
  let restored = decode_any(bmp_bytes)
  assert_eq(restored.width, 2)
  assert_eq(restored.height, 2)
}

///|
test "reexport: load_from_bytes PNG" {
  let img = re_make_rgb(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let png_bytes = @codec.encode_png_pure(img)
  let restored = load_from_bytes(png_bytes)
  assert_eq(restored.width, 2)
  assert_eq(restored.height, 2)
  assert_eq(restored.channels, 3)
  // PNG 无损，像素应一致
  assert_eq(restored.data[0].to_int(), 10)
  assert_eq(restored.data[1].to_int(), 20)
  assert_eq(restored.data[2].to_int(), 30)
}

///|
test "reexport: load_from_bytes with req_channels" {
  let img = re_make_rgb(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let png_bytes = @codec.encode_png_pure(img)
  let restored = load_from_bytes(png_bytes, req_channels=Some(3))
  assert_eq(restored.width, 2)
  assert_eq(restored.height, 2)
}

///|
test "reexport: loadf_from_bytes HDR" {
  // 构造 1x1 HDR ImageF
  let fdata : Array[Byte] = []
  let rb = 1.0F.to_le_bytes()
  let gb = 0.5F.to_le_bytes()
  let bb = 0.25F.to_le_bytes()
  for i in 0..<4 {
    fdata.push(rb[i])
  }
  for i in 0..<4 {
    fdata.push(gb[i])
  }
  for i in 0..<4 {
    fdata.push(bb[i])
  }
  let imgf = @types.ImageF::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array(fdata),
  }
  let hdr_bytes = @codec.encode_hdr_pure(imgf)
  let restored = loadf_from_bytes(hdr_bytes)
  assert_eq(restored.width, 1)
  assert_eq(restored.height, 1)
  assert_eq(restored.channels, 3)
}

///|
test "reexport: write_bmp_to_bytes" {
  let img = re_make_rgb(1, 1, [(255, 0, 0)])
  let bmp_bytes = write_bmp_to_bytes(img)
  // BMP magic "BM"
  assert_eq(bmp_bytes[0].to_int(), 0x42)
  assert_eq(bmp_bytes[1].to_int(), 0x4D)
}

///|
test "reexport: write_jpeg_to_bytes" {
  let img = re_make_rgb(2, 2, [
    (128, 128, 128),
    (64, 64, 64),
    (192, 192, 192),
    (32, 32, 32),
  ])
  let jpeg_bytes = write_jpeg_to_bytes(img)
  // JPEG SOI
  assert_eq(jpeg_bytes[0].to_int(), 0xFF)
  assert_eq(jpeg_bytes[1].to_int(), 0xD8)
}

///|
test "reexport: write_tga_to_bytes" {
  let img = re_make_rgb(2, 2, [
    (255, 0, 0),
    (0, 255, 0),
    (0, 0, 255),
    (255, 255, 255),
  ])
  let tga_bytes = write_tga_to_bytes(img)
  // TGA 应可被 decode_tga_pure 解回
  let restored = @codec.decode_tga_pure(tga_bytes)
  assert_eq(restored.width, 2)
  assert_eq(restored.height, 2)
}

///|
test "reexport: resize" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let resized = resize(img, 2, 2)
  assert_eq(resized.width, 2)
  assert_eq(resized.height, 2)
}

///|
test "reexport: resize with filter and edge" {
  let img = re_make_rgb(4, 4, Array::make(16, (100, 150, 200)))
  let resized = resize(
    img,
    8,
    8,
    filter=@types.ResizeFilter::Default,
    edge=@types.ResizeEdge::Clamp,
  )
  assert_eq(resized.width, 8)
  assert_eq(resized.height, 8)
}

///|
test "reexport: write_png_to_bytes" {
  let img = re_make_rgb(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let png_bytes = write_png_to_bytes(img)
  // PNG signature
  assert_eq(png_bytes[0].to_int(), 0x89)
  assert_eq(png_bytes[1].to_int(), 0x50)
}

///|
test "reexport: write_hdr_to_bytes" {
  let fdata : Array[Byte] = []
  let rb = 1.0F.to_le_bytes()
  let gb = 0.5F.to_le_bytes()
  let bb = 0.25F.to_le_bytes()
  for i in 0..<4 {
    fdata.push(rb[i])
  }
  for i in 0..<4 {
    fdata.push(gb[i])
  }
  for i in 0..<4 {
    fdata.push(bb[i])
  }
  let imgf = @types.ImageF::{
    width: 1,
    height: 1,
    channels: 3,
    data: Bytes::from_array(fdata),
  }
  let hdr_bytes = write_hdr_to_bytes(imgf)
  // HDR magic "#?RADIANCE"
  assert_eq(hdr_bytes[0].to_int(), 0x23)
  assert_eq(hdr_bytes[1].to_int(), 0x3F)
}

///|
test "reexport: load_gif_from_bytes" {
  // 构造最小 GIF 动画
  let gif_bytes = @codec.encode_gif_pure(
    re_make_rgb(2, 2, [(255, 0, 0), (0, 255, 0), (0, 0, 255), (255, 255, 255)]),
  )
  let anim = load_gif_from_bytes(gif_bytes)
  assert_true(anim.frames.length() >= 1)
}

///|
test "reexport: canny_edge" {
  let img = re_make_rgb(4, 4, [
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
  ])
  let edges = canny_edge(img)
  assert_eq(edges.width, 4)
  assert_eq(edges.height, 4)
}

///|
test "reexport: canny_edge with thresholds" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let edges = canny_edge(img, low_threshold=30, high_threshold=80)
  assert_eq(edges.width, 4)
}

///|
test "reexport: dehaze" {
  let img = re_make_rgb(8, 8, Array::make(64, (100, 120, 140)))
  let result = dehaze(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "reexport: dehaze with params" {
  let img = re_make_rgb(8, 8, Array::make(64, (50, 60, 70)))
  let result = dehaze(img, patch_size=5, omega=0.9F, t0=0.2F)
  assert_eq(result.width, 8)
}

///|
test "reexport: nlm_denoise" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = nlm_denoise(img, patch_size=1, search_size=1, h=10)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "reexport: nlm_denoise_fast" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = nlm_denoise_fast(img, patch_size=1, search_size=1, h=10, step=1)
  assert_eq(result.width, 4)
}

///|
test "reexport: harris_corner" {
  let img = re_make_rgb(4, 4, [
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (255, 255, 255),
    (0, 0, 0),
  ])
  let _ = harris_corners(img)
  assert_true(true)
}

///|
test "reexport: hough_lines" {
  let img = re_make_rgb(8, 8, Array::make(64, (0, 0, 0)))
  let _ = hough_lines(img, 100)
  assert_true(true)
}

///|
test "reexport: hough_lines_nms" {
  let lines : Array[HoughLine] = []
  let _ = hough_lines_nms(lines)
  assert_true(true)
}

///|
test "reexport: gabor_filter" {
  let img = re_make_rgb(8, 8, Array::make(64, (128, 128, 128)))
  let result = gabor_filter(img, 3, 1.0F, 0.0F)
  assert_eq(result.width, 8)
}

///|
test "reexport: gabor_filter_bank" {
  let img = re_make_rgb(8, 8, Array::make(64, (128, 128, 128)))
  let result = gabor_filter_bank(img, 3, 1.0F)
  assert_eq(result.width, 8)
}

///|
test "reexport: gabor_kernel" {
  let _ = gabor_kernel(3, 1.0F, 0.0F)
  assert_true(true)
}

///|
test "reexport: haar_transform_2d" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let _ = haar_transform_2d(img)
  assert_true(true)
}

///|
test "reexport: haar_denoise" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = haar_denoise(img)
  assert_eq(result.width, 4)
}

///|
test "reexport: kmeans_segment" {
  let img = re_make_rgb(4, 4, [
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
  ])
  let (labels, regions) = kmeans_segment(img, 2)
  assert_eq(regions.length(), 2)
  let _ = labels
}

///|
test "reexport: region_growing_segment" {
  let img = re_make_rgb(4, 4, [
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
    (0, 0, 0),
    (0, 0, 0),
    (255, 255, 255),
    (255, 255, 255),
  ])
  let (labels, regions) = region_growing_segment(img, [(0, 0), (0, 2)])
  assert_true(regions.length() >= 1)
  let _ = labels
}

///|
test "reexport: ssr" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = ssr(img)
  assert_eq(result.width, 4)
}

///|
test "reexport: msr" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = msr(img)
  assert_eq(result.width, 4)
}

///|
test "reexport: freq_filter" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = freq_filter(img, FreqFilterType::LowPass, 10.0F)
  assert_eq(result.width, 4)
}

///|
test "reexport: freq_filter_gaussian" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let result = freq_filter_gaussian(img, FreqFilterType::LowPass, 10.0F)
  assert_eq(result.width, 4)
}

///|
test "reexport: compute_glcm" {
  let data = Bytes::from_array(Array::make(16, b'\x80'))
  let img = @types.Image::{ width: 4, height: 4, channels: 1, data }
  let _ = compute_glcm(img, 1, 0)
  assert_true(true)
}

///|
test "reexport: glcm_features_multi_direction" {
  let data = Bytes::from_array(Array::make(16, b'\x80'))
  let img = @types.Image::{ width: 4, height: 4, channels: 1, data }
  let _ = glcm_features_multi_direction(img)
  assert_true(true)
}

///|
test "reexport: draw_corners" {
  let img = re_make_rgb(4, 4, Array::make(16, (128, 128, 128)))
  let corners : Array[CornerPoint] = []
  let result = draw_corners(img, corners)
  assert_eq(result.width, 4)
}

///|
test "reexport: decode_any with req_channels" {
  let img = re_make_rgb(2, 2, [
    (10, 20, 30),
    (40, 50, 60),
    (70, 80, 90),
    (100, 110, 120),
  ])
  let bmp_bytes = @codec.encode_bmp_pure(img)
  let restored = decode_any(bmp_bytes, req_channels=Some(3))
  assert_eq(restored.width, 2)
}
