///|
/// 统一图像扩展信息（自动格式检测后的联合类型）
///
/// 通过 `get_image_info_extended` 自动检测格式并返回对应类型的扩展信息
pub enum ImageInfoExtended {
  Avif(AvifInfoExtended)
  Heif(HeifInfoExtended)
  JpegXl(JpegXlInfoExtended)
  Webp(WebpInfoExtended)
  Tiff(TiffInfoExtended)
  Psd(PsdInfoExtended)
  Bmp(BmpInfoExtended)
  Gif(GifInfoExtended)
  Png(PngInfoExtended)
  Jpeg(JpegInfoExtended)
  Qoi(QoiInfoExtended)
  Tga(TgaInfoExtended)
  Hdr(HdrInfoExtended)
  Pnm(PnmInfoExtended)
  Ico(IcoInfoExtended)
  Cur(CurInfoExtended)
  Icns(IcnsInfoExtended)
  Apng(ApngInfoExtended)
}

///|
/// 检测图像格式并返回对应的扩展信息
///
/// 按 magic number 顺序检测 18 种格式，返回对应类型的 ImageInfoExtended
/// TGA 无明确 magic，放在最后通过头部字段有效性判断
pub fn get_image_info_extended(
  data : Bytes,
) -> ImageInfoExtended raise @types.LoadError {
  if is_apng_format(data) {
    return ImageInfoExtended::Apng(apng_info_extended(data))
  }
  if is_png_format(data) {
    return ImageInfoExtended::Png(png_info_extended(data))
  }
  if is_jpeg_format(data) {
    return ImageInfoExtended::Jpeg(jpeg_info_extended(data))
  }
  if is_bmp_format(data) {
    return ImageInfoExtended::Bmp(bmp_info_extended(data))
  }
  if is_gif_format(data) {
    return ImageInfoExtended::Gif(gif_info_extended(data))
  }
  if is_qoi_format(data) {
    return ImageInfoExtended::Qoi(qoi_info_extended(data))
  }
  if is_hdr_format(data) {
    return ImageInfoExtended::Hdr(hdr_info_extended(data))
  }
  if is_pnm_format(data) {
    return ImageInfoExtended::Pnm(pnm_info_extended(data))
  }
  if is_icns_format(data) {
    return ImageInfoExtended::Icns(icns_info_extended(data))
  }
  if is_webp_format(data) {
    return ImageInfoExtended::Webp(webp_info_extended(data))
  }
  if is_tiff_format(data) {
    return ImageInfoExtended::Tiff(tiff_info_extended(data))
  }
  if is_psd_format(data) {
    return ImageInfoExtended::Psd(psd_info_extended(data))
  }
  if is_avif_format(data) {
    return ImageInfoExtended::Avif(avif_info_extended(data))
  }
  if is_heif_format(data) {
    return ImageInfoExtended::Heif(heif_info_extended(data))
  }
  if is_jpegxl_format(data) {
    return ImageInfoExtended::JpegXl(jpegxl_info_extended(data))
  }
  if is_ico_format(data) {
    return ImageInfoExtended::Ico(ico_info_extended(data))
  }
  if is_cur_format(data) {
    return ImageInfoExtended::Cur(cur_info_extended(data))
  }
  if is_tga_format(data) {
    return ImageInfoExtended::Tga(tga_info_extended(data))
  }
  raise @types.LoadError::UnsupportedFormat("Unknown image format")
}

///|
/// 检测图像格式名称
///
/// 检测 18 种格式，返回格式名称字符串
pub fn detect_image_format(data : Bytes) -> String {
  if is_apng_format(data) {
    return "APNG"
  }
  if is_png_format(data) {
    return "PNG"
  }
  if is_jpeg_format(data) {
    return "JPEG"
  }
  if is_bmp_format(data) {
    return "BMP"
  }
  if is_gif_format(data) {
    return "GIF"
  }
  if is_qoi_format(data) {
    return "QOI"
  }
  if is_hdr_format(data) {
    return "HDR"
  }
  if is_pnm_format(data) {
    return "PNM"
  }
  if is_icns_format(data) {
    return "ICNS"
  }
  if is_webp_format(data) {
    return "WebP"
  }
  if is_tiff_format(data) {
    return "TIFF"
  }
  if is_psd_format(data) {
    return "PSD"
  }
  if is_avif_format(data) {
    return "AVIF"
  }
  if is_heif_format(data) {
    return "HEIF"
  }
  if is_jpegxl_format(data) {
    return "JPEG-XL"
  }
  if is_ico_format(data) {
    return "ICO"
  }
  if is_cur_format(data) {
    return "CUR"
  }
  if is_tga_format(data) {
    return "TGA"
  }
  "unknown"
}
