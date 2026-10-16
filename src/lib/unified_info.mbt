// v246.0.0 统一 info API：整合基本信息 + 格式特定扩展信息

///|
/// 统一图像信息（跨格式通用字段）
pub(all) struct UnifiedImageInfo {
  format : @types.ImageFormat
  format_name : String
  width : Int
  height : Int
  channels : Int
  bit_depth : Int
  has_alpha : Bool
} derive(Eq, @debug.Debug)

///|
pub extend UnifiedImageInfo with @debug.Debug::{to_repr}

///|
pub extend UnifiedImageInfo with Eq::{not_equal, equal}

///|
/// 统一图像信息探测
/// 自动检测格式并返回跨格式通用信息（尺寸/通道/位深/alpha）
/// 未知格式 raise LoadError::UnsupportedFormat
pub fn get_image_info(data : Bytes) -> UnifiedImageInfo raise @types.LoadError {
  let format = detect_format(data)
  let ext = @codec.get_image_info_extended(data)
  let format_name = match format {
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
    @types.ImageFormat::Unknown => "unknown"
  }
  match ext {
    @codec.ImageInfoExtended::Avif(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Heif(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::JpegXl(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Webp(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 8,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Tiff(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Psd(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Bmp(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Gif(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 8,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Png(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Jpeg(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.precision,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Qoi(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 8,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Tga(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Hdr(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 32,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Pnm(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Ico(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: if e.bit_depths.length() > 0 {
          e.bit_depths[0]
        } else {
          0
        },
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Cur(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 8,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Icns(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: 32,
        has_alpha: e.has_alpha,
      }
    @codec.ImageInfoExtended::Apng(e) =>
      UnifiedImageInfo::{
        format,
        format_name,
        width: e.width,
        height: e.height,
        channels: e.num_channels,
        bit_depth: e.bit_depth,
        has_alpha: e.has_alpha,
      }
  }
}

///|
/// 人类可读的图像信息摘要
/// 返回格式如 "PNG 4x4 3ch 8bit"
pub fn get_image_summary(data : Bytes) -> String raise @types.LoadError {
  let info = get_image_info(data)
  info.format_name +
  " " +
  info.width.to_string() +
  "x" +
  info.height.to_string() +
  " " +
  info.channels.to_string() +
  "ch " +
  info.bit_depth.to_string() +
  "bit"
}
