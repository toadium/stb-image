///|
/// 通过 magic bytes 检测图像格式
pub fn detect_format(data : Bytes) -> ImageFormat {
  let len = data.length()
  if len < 2 {
    return ImageFormat::Unknown
  }
  // PNG: \x89PNG\r\n\x1a\n
  if len >= 8 &&
    data[0].to_int() == 0x89 &&
    data[1].to_int() == 0x50 &&
    data[2].to_int() == 0x4E &&
    data[3].to_int() == 0x47 {
    return ImageFormat::Png
  }
  // JPEG: \xFF\xD8\xFF
  if len >= 3 &&
    data[0].to_int() == 0xFF &&
    data[1].to_int() == 0xD8 &&
    data[2].to_int() == 0xFF {
    return ImageFormat::Jpeg
  }
  // BMP: BM
  if len >= 2 && data[0].to_int() == 0x42 && data[1].to_int() == 0x4D {
    return ImageFormat::Bmp
  }
  // GIF: GIF87a or GIF89a
  if len >= 6 &&
    data[0].to_int() == 0x47 &&
    data[1].to_int() == 0x49 &&
    data[2].to_int() == 0x46 {
    return ImageFormat::Gif
  }
  // PSD: 8BPS
  if len >= 4 &&
    data[0].to_int() == 0x38 &&
    data[1].to_int() == 0x42 &&
    data[2].to_int() == 0x50 &&
    data[3].to_int() == 0x53 {
    return ImageFormat::Psd
  }
  // HDR: #?RADIANCE or #?RGBE
  if len >= 10 &&
    data[0].to_int() == 0x23 &&
    data[1].to_int() == 0x3F &&
    data[2].to_int() == 0x52 {
    return ImageFormat::Hdr
  }
  // PNM: P1-P6
  if len >= 2 &&
    data[0].to_int() == 0x50 &&
    data[1].to_int() >= 0x31 &&
    data[1].to_int() <= 0x36 {
    return ImageFormat::Pnm
  }
  // QOI: qoif
  if len >= 4 &&
    data[0].to_int() == 0x71 &&
    data[1].to_int() == 0x6F &&
    data[2].to_int() == 0x69 &&
    data[3].to_int() == 0x66 {
    return ImageFormat::Qoi
  }
  // TGA: 无固定 magic bytes，通过其他特征检测较不可靠
  // stb_image 内部会尝试 TGA，这里标记为 Unknown（decode_any 仍会尝试）
  ImageFormat::Unknown
}

///|
/// 自动检测格式并解码为 8-bit Image
/// stb_image 内部支持 PNG/JPEG/BMP/GIF/PSD/TGA/HDR/PNM 自动检测
pub fn decode_any(
  data : Bytes,
  req_channels? : Int? = None,
) -> Image raise LoadError {
  load_from_bytes(data, req_channels~)
}

///|
/// 检查字节流是否为支持的图像格式
pub fn is_supported_format(data : Bytes) -> Bool {
  let fmt = detect_format(data)
  match fmt {
    ImageFormat::Unknown => false
    _ => true
  }
}
