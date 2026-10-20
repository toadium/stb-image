///|
/// 编解码器统一接口 trait
///
/// 为 ImageFormat 枚举实现，提供统一的 encode / decode 方法
pub trait Codec {
  fn format_name(Self) -> String
  fn can_encode(Self) -> Bool
  fn can_decode(Self) -> Bool
  fn is_lossless(Self) -> Bool
  fn encode(Self, @types.AnyImage) -> Bytes raise @types.LoadError
  fn decode(Self, Bytes) -> @types.AnyImage raise @types.LoadError
}

///|
pub impl Codec for @types.ImageFormat with fn format_name(self) {
  match self {
    @types.ImageFormat::Png => "PNG"
    @types.ImageFormat::Jpeg => "JPEG"
    @types.ImageFormat::Bmp => "BMP"
    @types.ImageFormat::Gif => "GIF"
    @types.ImageFormat::Tga => "TGA"
    @types.ImageFormat::Psd => "PSD"
    @types.ImageFormat::Hdr => "HDR"
    @types.ImageFormat::Pnm => "PNM"
    @types.ImageFormat::Qoi => "QOI"
    @types.ImageFormat::Webp => "WebP"
    @types.ImageFormat::Tiff => "TIFF"
    @types.ImageFormat::Ico => "ICO"
    @types.ImageFormat::Cur => "CUR"
    @types.ImageFormat::Icns => "ICNS"
    @types.ImageFormat::Apng => "APNG"
    @types.ImageFormat::Avif => "AVIF"
    @types.ImageFormat::Heif => "HEIF"
    @types.ImageFormat::JpegXl => "JPEG-XL"
    @types.ImageFormat::Unknown => "Unknown"
  }
}

///|
pub impl Codec for @types.ImageFormat with fn can_encode(self) {
  match self {
    @types.ImageFormat::Png => true
    @types.ImageFormat::Jpeg => true
    @types.ImageFormat::Bmp => true
    @types.ImageFormat::Gif => true
    @types.ImageFormat::Tga => true
    @types.ImageFormat::Psd => false
    @types.ImageFormat::Hdr => true
    @types.ImageFormat::Pnm => true
    @types.ImageFormat::Qoi => true
    @types.ImageFormat::Webp => true
    @types.ImageFormat::Tiff => true
    @types.ImageFormat::Ico => true
    @types.ImageFormat::Cur => true
    @types.ImageFormat::Icns => true
    @types.ImageFormat::Apng => true
    @types.ImageFormat::Avif => false
    @types.ImageFormat::Heif => false
    @types.ImageFormat::JpegXl => false
    @types.ImageFormat::Unknown => false
  }
}

///|
pub impl Codec for @types.ImageFormat with fn can_decode(self) {
  match self {
    @types.ImageFormat::Unknown => false
    _ => true
  }
}

///|
pub impl Codec for @types.ImageFormat with fn is_lossless(self) {
  match self {
    @types.ImageFormat::Jpeg => false
    @types.ImageFormat::Webp => false
    @types.ImageFormat::Avif => false
    @types.ImageFormat::Heif => false
    @types.ImageFormat::JpegXl => false
    _ => true
  }
}

///|
pub impl Codec for @types.ImageFormat with fn encode(self, img) {
  match self {
    @types.ImageFormat::Png => encode_png_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Jpeg => encode_jpeg_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Bmp => encode_bmp_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Gif => encode_gif_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Tga => encode_tga_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Hdr =>
      match img {
        @types.AnyImage::F32(im) => encode_hdr_pure(im)
        _ => encode_hdr_pure(@types.hdr_from_u8(@types.any_image_to_u8(img)))
      }
    @types.ImageFormat::Pnm => encode_pnm_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Qoi => encode_qoi_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Webp =>
      encode_webp_lossy_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Tiff => encode_tiff_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Ico => encode_ico_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Cur => encode_cur_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Icns => encode_icns_pure(@types.any_image_to_u8(img))
    @types.ImageFormat::Apng => {
      let im = @types.any_image_to_u8(img)
      encode_apng_pure(@types.PngAnimation::{ frames: [im], delays: [0], })
    }
    _ =>
      raise @types.LoadError::EncodeFailed("Format not supported for encoding")
  }
}

///|
pub impl Codec for @types.ImageFormat with fn decode(self, data) {
  match self {
    @types.ImageFormat::Png => @types.AnyImage::U8(decode_png_pure(data))
    @types.ImageFormat::Jpeg => @types.AnyImage::U8(decode_jpeg_pure(data))
    @types.ImageFormat::Bmp => @types.AnyImage::U8(decode_bmp_pure(data))
    @types.ImageFormat::Gif => @types.AnyImage::U8(decode_gif_pure(data))
    @types.ImageFormat::Tga => @types.AnyImage::U8(decode_tga_pure(data))
    @types.ImageFormat::Psd => @types.AnyImage::U8(decode_psd_pure(data))
    @types.ImageFormat::Hdr => @types.AnyImage::F32(decode_hdr_pure(data))
    @types.ImageFormat::Pnm => @types.AnyImage::U8(decode_pnm_pure(data))
    @types.ImageFormat::Qoi => @types.AnyImage::U8(decode_qoi_pure(data))
    @types.ImageFormat::Webp => @types.AnyImage::U8(decode_webp_pure(data))
    @types.ImageFormat::Tiff => @types.AnyImage::U8(decode_tiff_pure(data))
    @types.ImageFormat::Ico => @types.AnyImage::U8(decode_ico_pure(data))
    @types.ImageFormat::Cur => @types.AnyImage::U8(decode_cur_pure(data))
    @types.ImageFormat::Icns => @types.AnyImage::U8(decode_icns_pure(data))
    @types.ImageFormat::Apng => {
      let anim = decode_apng_pure(data)
      match anim.frames {
        [first, ..] => @types.AnyImage::U8(first)
        [] => raise @types.LoadError::DecodeFailed("APNG has no frames")
      }
    }
    @types.ImageFormat::Avif => @types.AnyImage::U8(avif_decode(data))
    @types.ImageFormat::Heif => @types.AnyImage::U8(heif_decode(data))
    @types.ImageFormat::JpegXl => @types.AnyImage::U8(jpegxl_decode(data))
    @types.ImageFormat::Unknown =>
      raise @types.LoadError::DecodeFailed("Unknown format")
  }
}

///|

///|
/// 通过 Codec trait 统一解码：自动检测格式并解码
pub fn codec_decode_auto(
  data : Bytes,
) -> @types.AnyImage raise @types.LoadError {
  let format = codec_detect_format(data)
  Codec::decode(format, data)
}

///|
/// 检测图像格式（基于 magic bytes）
pub fn codec_detect_format(data : Bytes) -> @types.ImageFormat {
  if data.length() < 2 {
    return @types.ImageFormat::Unknown
  }
  let b0 = data[0].to_int()
  let b1 = data[1].to_int()
  // PNG: 89 50 4E 47
  if b0 == 0x89 && b1 == 0x50 {
    return @types.ImageFormat::Png
  }
  // JPEG: FF D8
  if b0 == 0xFF && b1 == 0xD8 {
    return @types.ImageFormat::Jpeg
  }
  // GIF: 47 49 46
  if b0 == 0x47 && b1 == 0x49 {
    return @types.ImageFormat::Gif
  }
  // BMP: 42 4D
  if b0 == 0x42 && b1 == 0x4D {
    return @types.ImageFormat::Bmp
  }
  // QOI: 71 6F 69 66
  if b0 == 0x71 && b1 == 0x6F {
    return @types.ImageFormat::Qoi
  }
  // WebP: 52 49 46 46 ... 57 45 42 50
  if b0 == 0x52 && b1 == 0x49 && data.length() >= 12 {
    let b8 = data[8].to_int()
    let b9 = data[9].to_int()
    let b10 = data[10].to_int()
    let b11 = data[11].to_int()
    if b8 == 0x57 && b9 == 0x45 && b10 == 0x42 && b11 == 0x50 {
      return @types.ImageFormat::Webp
    }
  }
  // TIFF: 49 49 or 4D 4D
  if (b0 == 0x49 && b1 == 0x49) || (b0 == 0x4D && b1 == 0x4D) {
    return @types.ImageFormat::Tiff
  }
  // ICO/CUR: 00 00 01 00 / 00 00 02 00
  if b0 == 0x00 && b1 == 0x00 && data.length() >= 4 {
    let b2 = data[2].to_int()
    if b2 == 0x01 {
      return @types.ImageFormat::Ico
    }
    if b2 == 0x02 {
      return @types.ImageFormat::Cur
    }
  }
  // HDR: #?RADIANCE or #?RGBE
  if b0 == 0x23 && b1 == 0x3F {
    return @types.ImageFormat::Hdr
  }
  // PNM: P1-P6
  if b0 == 0x50 && b1 >= 0x31 && b1 <= 0x36 {
    return @types.ImageFormat::Pnm
  }
  // PSD: 38 42 50 53
  if b0 == 0x38 && b1 == 0x42 {
    return @types.ImageFormat::Psd
  }
  // ICNS: 69 63 6E 73
  if b0 == 0x69 && b1 == 0x63 {
    return @types.ImageFormat::Icns
  }
  // AVIF/HEIF: ftyp box
  if b0 == 0x00 && data.length() >= 12 {
    let b4 = data[4].to_int()
    let b5 = data[5].to_int()
    let b6 = data[6].to_int()
    let b7 = data[7].to_int()
    if b4 == 0x66 && b5 == 0x74 && b6 == 0x79 && b7 == 0x70 {
      let b8 = data[8].to_int()
      let b9 = data[9].to_int()
      let b10 = data[10].to_int()
      let b11 = data[11].to_int()
      // avif/mif/avis
      if (b8 == 0x61 && b9 == 0x76 && b10 == 0x69 && b11 == 0x66) ||
        (b8 == 0x6D && b9 == 0x69 && b10 == 0x66 && b11 == 0x73) ||
        (b8 == 0x61 && b9 == 0x76 && b10 == 0x69 && b11 == 0x73) {
        return @types.ImageFormat::Avif
      }
      // heic/heix/heif/mif
      if (b8 == 0x68 && b9 == 0x65 && b10 == 0x69 && b11 == 0x63) ||
        (b8 == 0x68 && b9 == 0x65 && b10 == 0x69 && b11 == 0x78) ||
        (b8 == 0x68 && b9 == 0x65 && b10 == 0x69 && b11 == 0x66) ||
        (b8 == 0x6D && b9 == 0x69 && b10 == 0x66 && b11 == 0x73) {
        return @types.ImageFormat::Heif
      }
    }
  }
  // JPEG-XL: FF 0A (codestream) or 00 00 00 0C 4A 58 4C 20 (container)
  if b0 == 0xFF && b1 == 0x0A {
    return @types.ImageFormat::JpegXl
  }
  if b0 == 0x00 && b1 == 0x00 && data.length() >= 8 {
    let b4 = data[4].to_int()
    let b5 = data[5].to_int()
    let b6 = data[6].to_int()
    let b7 = data[7].to_int()
    if b4 == 0x4A && b5 == 0x58 && b6 == 0x4C && b7 == 0x20 {
      return @types.ImageFormat::JpegXl
    }
  }
  @types.ImageFormat::Unknown
}
