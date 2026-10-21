///|
/// PSD 扩展信息（包含通道数、位深、颜色模式、压缩方式等）
pub struct PsdInfoExtended {
  width : Int32
  height : Int32
  bit_depth : Int32
  channel_count : Int32
  num_channels : Int32
  has_alpha : Bool
  color_mode : Int32
  color_mode_name : String
  compression : Int32
  compression_name : String
  version : Int32
}

///|
/// 检测数据是否为 PSD 格式
pub fn is_psd_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 26 {
    return false
  }
  // signature "8BPS" (0x38 0x42 0x50 0x53)
  data[0].to_int() == 0x38 &&
  data[1].to_int() == 0x42 &&
  data[2].to_int() == 0x50 &&
  data[3].to_int() == 0x53
}

///|
fn psd_color_mode_name(m : Int32) -> String {
  match m {
    0 => "Bitmap"
    1 => "Grayscale"
    2 => "Indexed"
    3 => "RGB"
    4 => "CMYK"
    7 => "Multichannel"
    8 => "Duotone"
    9 => "Lab"
    _ => "unknown"
  }
}

///|
fn psd_compression_name(c : Int32) -> String {
  match c {
    0 => "Raw"
    1 => "RLE"
    2 => "ZIP without prediction"
    3 => "ZIP with prediction"
    _ => "unknown"
  }
}

///|
/// 解析 PSD 扩展头部信息
///
/// 解析 PSD 文件头，提取尺寸、通道数、位深、颜色模式、压缩方式等
pub fn psd_info_extended(
  data : Bytes,
) -> PsdInfoExtended raise @types.LoadError {
  if !is_psd_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a PSD file")
  }
  let len = data.length()
  let version = read_u16_be(data, 4)
  let channel_count = read_u16_be(data, 12)
  let height = read_u32_be(data, 14)
  let width = read_u32_be(data, 18)
  let bit_depth = read_u16_be(data, 22)
  let color_mode = read_u16_be(data, 24)
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("PSD 尺寸无效")
  }
  // 跳过 3 个 length 前缀段（color mode data / image resources / layer and mask data）
  let mut pos = 26
  let mut compression = 0
  for seg_idx in 0..<3 {
    if pos + 4 > len {
      break
    }
    let seg_len = read_u32_be(data, pos)
    pos += 4
    if pos + seg_len > len {
      break
    }
    pos += seg_len
    let _ = seg_idx
  }
  // Image data: compression (2 bytes BE)
  if pos + 2 <= len {
    compression = read_u16_be(data, pos)
  }
  let has_alpha = channel_count == 4 || channel_count == 5
  let num_channels = if channel_count > 4 { 4 } else { channel_count }
  PsdInfoExtended::{
    width,
    height,
    bit_depth,
    channel_count,
    num_channels,
    has_alpha,
    color_mode,
    color_mode_name: psd_color_mode_name(color_mode),
    compression,
    compression_name: psd_compression_name(compression),
    version,
  }
}
