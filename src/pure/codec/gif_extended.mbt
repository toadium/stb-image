///|
/// GIF 扩展信息（包含版本、全局颜色表、动画标志等）
pub struct GifInfoExtended {
  width : Int
  height : Int
  version : String
  has_global_color_table : Bool
  global_color_table_size : Int
  color_resolution : Int
  is_sorted : Bool
  background_color_index : Int
  pixel_aspect_ratio : Int
  num_channels : Int
  has_alpha : Bool
}

///|
/// 检测数据是否为 GIF 格式
pub fn is_gif_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 6 {
    return false
  }
  // "GIF87a" or "GIF89a"
  data[0].to_int() == 0x47 &&
  data[1].to_int() == 0x49 &&
  data[2].to_int() == 0x46 &&
  data[3].to_int() == 0x38 &&
  data[5].to_int() == 0x61 &&
  (data[4].to_int() == 0x37 || data[4].to_int() == 0x39)
}

///|
/// 解析 GIF 扩展头部信息
pub fn gif_info_extended(
  data : Bytes,
) -> GifInfoExtended raise @types.LoadError {
  if !is_gif_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a GIF file")
  }
  let len = data.length()
  if len < 13 {
    raise @types.LoadError::DecodeFailed("GIF 数据过短")
  }
  let version = if data[4].to_int() == 0x37 { "87a" } else { "89a" }
  let width = read_u16_le(data, 6)
  let height = read_u16_le(data, 8)
  let packed = data[10].to_int()
  let has_global_color_table = (packed & 0x80) != 0
  let color_resolution = ((packed >> 4) & 0x07) + 1
  let is_sorted = (packed & 0x08) != 0
  let gct_size_bits = packed & 0x07
  let global_color_table_size = if has_global_color_table {
    1 << (gct_size_bits + 1)
  } else {
    0
  }
  let background_color_index = data[11].to_int()
  let pixel_aspect_ratio = data[12].to_int()
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("GIF 尺寸无效")
  }
  GifInfoExtended::{
    width,
    height,
    version,
    has_global_color_table,
    global_color_table_size,
    color_resolution,
    is_sorted,
    background_color_index,
    pixel_aspect_ratio,
    num_channels: 3,
    has_alpha: false,
  }
}
