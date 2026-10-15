///|
/// BMP 扩展信息（包含位深、压缩方式、行序、调色板等）
pub struct BmpInfoExtended {
  width : Int
  height : Int
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
  compression : Int
  compression_name : String
  is_bottom_up : Bool
  dib_size : Int
  num_colors : Int
  data_offset : Int
}

///|
/// 检测数据是否为 BMP 格式
pub fn is_bmp_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 14 {
    return false
  }
  data[0].to_int() == 0x42 && data[1].to_int() == 0x4D
}

///|
fn bmp_compression_name(c : Int) -> String {
  match c {
    0 => "BI_RGB"
    1 => "BI_RLE8"
    2 => "BI_RLE4"
    3 => "BI_BITFIELDS"
    4 => "BI_JPEG"
    5 => "BI_PNG"
    _ => "unknown"
  }
}

///|
/// 解析 BMP 扩展头部信息
pub fn bmp_info_extended(
  data : Bytes,
) -> BmpInfoExtended raise @types.LoadError {
  if !is_bmp_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a BMP file")
  }
  let len = data.length()
  if len < 54 {
    raise @types.LoadError::DecodeFailed("BMP 数据过短")
  }
  let data_offset = read_u32_le(data, 10)
  let dib_size = read_u32_le(data, 14)
  let width = read_u32_le(data, 18)
  let height = read_u32_le(data, 22)
  let bpp = read_u16_le(data, 28)
  let compression = read_u32_le(data, 30)
  let num_colors = if dib_size >= 40 && 46 < len {
    let nc = read_u32_le(data, 46)
    if nc > 0 {
      nc
    } else {
      1 << bpp
    }
  } else {
    0
  }
  let abs_width = if width < 0 { -width } else { width }
  let abs_height = if height < 0 { -height } else { height }
  if abs_width == 0 || abs_height == 0 {
    raise @types.LoadError::DecodeFailed("BMP 尺寸无效")
  }
  let is_bottom_up = height > 0
  let has_alpha = bpp == 32
  let num_channels = bpp / 8
  BmpInfoExtended::{
    width: abs_width,
    height: abs_height,
    bit_depth: bpp,
    num_channels,
    has_alpha,
    compression,
    compression_name: bmp_compression_name(compression),
    is_bottom_up,
    dib_size,
    num_colors,
    data_offset,
  }
}
