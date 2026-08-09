///|
/// pure 侧支持的图像格式枚举
pub(all) enum ImageFormat {
  Bmp
  Qoi
  Pnm
  Psd
  Gif
  Png
  Jpeg
  Tga
  Unknown
} derive(Eq, @debug.Debug)

///|
/// 通过 magic bytes 检测图像格式
/// - BMP "BM"、QOI "qoif"、PNM "P5"/"P6"、PSD "8BPS"、GIF "GIF87a"/"GIF89a"
/// - PNG 8字节签名、JPEG SOI 0xFF 0xD8
/// - TGA 无固定 magic bytes，检测为 Unknown，需显式调用 @pure.decode_tga_pure
pub fn detect_format(data : Bytes) -> ImageFormat {
  let len = data.length()
  if len < 2 {
    return ImageFormat::Unknown
  }
  // PNG: 8字节签名
  if len >= 8 &&
    data[0].to_int() == 0x89 &&
    data[1].to_int() == 0x50 &&
    data[2].to_int() == 0x4E &&
    data[3].to_int() == 0x47 &&
    data[4].to_int() == 0x0D &&
    data[5].to_int() == 0x0A &&
    data[6].to_int() == 0x1A &&
    data[7].to_int() == 0x0A {
    return ImageFormat::Png
  }
  // JPEG: SOI marker
  if data[0].to_int() == 0xFF && data[1].to_int() == 0xD8 {
    return ImageFormat::Jpeg
  }
  // BMP: "BM"
  if data[0].to_int() == 0x42 && data[1].to_int() == 0x4D {
    return ImageFormat::Bmp
  }
  // QOI: "qoif"
  if len >= 4 &&
    data[0].to_int() == 0x71 &&
    data[1].to_int() == 0x6F &&
    data[2].to_int() == 0x69 &&
    data[3].to_int() == 0x66 {
    return ImageFormat::Qoi
  }
  // PNM: "P5"/"P6"
  if data[0].to_int() == 0x50 && data[1].to_int() >= 0x35 && data[1].to_int() <= 0x36 {
    return ImageFormat::Pnm
  }
  // PSD: "8BPS"
  if len >= 4 &&
    data[0].to_int() == 0x38 &&
    data[1].to_int() == 0x42 &&
    data[2].to_int() == 0x50 &&
    data[3].to_int() == 0x53 {
    return ImageFormat::Psd
  }
  // GIF: "GIF87a" or "GIF89a"
  if len >= 6 &&
    data[0].to_int() == 0x47 &&
    data[1].to_int() == 0x49 &&
    data[2].to_int() == 0x46 {
    return ImageFormat::Gif
  }
  ImageFormat::Unknown
}

///|
/// 自动格式分派解码（pure 侧统一入口）
/// 根据 magic bytes 检测格式并委托对应 pure 解码器
/// - 不支持 TGA 自动分派（无固定 magic bytes），需显式调用 @pure.decode_tga_pure
/// - 未识别格式 raise LoadError::DecodeFailed
pub fn load_from_bytes_auto(data : Bytes) -> @types.Image raise @types.LoadError {
  match detect_format(data) {
    ImageFormat::Png => @pure.decode_png_pure(data)
    ImageFormat::Jpeg => @pure.decode_jpeg_pure(data)
    ImageFormat::Bmp => @pure.decode_bmp_pure(data)
    ImageFormat::Qoi => @pure.decode_qoi_pure(data)
    ImageFormat::Pnm => @pure.decode_pnm_pure(data)
    ImageFormat::Psd => @pure.decode_psd_pure(data)
    ImageFormat::Gif => @pure.decode_gif_pure(data)
    ImageFormat::Tga => @pure.decode_tga_pure(data)
    ImageFormat::Unknown =>
      raise @types.LoadError::DecodeFailed("unsupported or unrecognized format")
  }
}

///|
/// QOI 编码委托
pub fn encode_qoi_auto(img : @types.Image) -> Bytes raise @types.LoadError {
  @pure.encode_qoi_pure(img)
}

///|
/// PNM 编码委托（channels<=1 → PGM else → PPM）
pub fn encode_pnm_auto(img : @types.Image) -> Bytes {
  @pure.encode_pnm_pure(img)
}

///|
/// PPM 编码委托
pub fn encode_ppm_auto(img : @types.Image) -> Bytes {
  @pure.encode_ppm_pure(img)
}

///|
/// PGM 编码委托
pub fn encode_pgm_auto(img : @types.Image) -> Bytes {
  @pure.encode_pgm_pure(img)
}

///|
/// GIF 编码委托
pub fn encode_gif_auto(img : @types.Image) -> Bytes raise @types.LoadError {
  @pure.encode_gif_pure(img)
}

///|
/// PNG 编码委托
pub fn encode_png_auto(img : @types.Image) -> Bytes raise @types.LoadError {
  @pure.encode_png_pure(img)
}

///|
/// JPEG 编码委托
pub fn encode_jpeg_auto(img : @types.Image) -> Bytes raise @types.LoadError {
  @pure.encode_jpeg_pure(img)
}

///|
/// HDR 编码委托
pub fn encode_hdr_auto(img : @types.ImageF) -> Bytes raise @types.LoadError {
  @pure.encode_hdr_pure(img)
}

///|
/// BMP 编码委托
pub fn encode_bmp_auto(img : @types.Image) -> Bytes {
  @pure.encode_bmp_pure(img)
}

///|
/// TGA 编码委托
pub fn encode_tga_auto(img : @types.Image) -> Bytes {
  @pure.encode_tga_pure(img)
}
