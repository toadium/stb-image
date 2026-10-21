///|
/// PNG 扩展信息（包含位深、颜色类型、隔行扫描等）
pub struct PngInfoExtended {
  width : Int32
  height : Int32
  bit_depth : Int32
  color_type : Int32
  color_type_name : String
  num_channels : Int32
  has_alpha : Bool
  is_palette : Bool
  compression_method : Int32
  filter_method : Int32
  interlace_method : Int32
}

///|
/// 检测数据是否为 PNG 格式
pub fn is_png_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 8 {
    return false
  }
  data[0].to_int() == 0x89 &&
  data[1].to_int() == 0x50 &&
  data[2].to_int() == 0x4E &&
  data[3].to_int() == 0x47 &&
  data[4].to_int() == 0x0D &&
  data[5].to_int() == 0x0A &&
  data[6].to_int() == 0x1A &&
  data[7].to_int() == 0x0A
}

///|
fn png_color_type_name(ct : Int32) -> String {
  match ct {
    0 => "Grayscale"
    2 => "RGB"
    3 => "Palette"
    4 => "Grayscale+Alpha"
    6 => "RGBA"
    _ => "unknown"
  }
}

///|
fn png_channels_count(ct : Int32) -> Int32 {
  match ct {
    0 => 1
    2 => 3
    3 => 1
    4 => 2
    6 => 4
    _ => 0
  }
}

///|
/// 解析 PNG 扩展头部信息
///
/// 解析 IHDR chunk，提取尺寸、位深、颜色类型、压缩/滤波/隔行方式
pub fn png_info_extended(
  data : Bytes,
) -> PngInfoExtended raise @types.LoadError {
  if !is_png_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a PNG file")
  }
  let len = data.length()
  // IHDR chunk starts at offset 8
  // length(4) + "IHDR"(4) + width(4) + height(4) + bit_depth(1) + color_type(1) + compression(1) + filter(1) + interlace(1)
  if len < 29 {
    raise @types.LoadError::DecodeFailed("PNG 数据过短，无法读取 IHDR")
  }
  // 验证 IHDR chunk type
  if data[12].to_int() != 0x49 ||
    data[13].to_int() != 0x48 ||
    data[14].to_int() != 0x44 ||
    data[15].to_int() != 0x52 {
    raise @types.LoadError::DecodeFailed("PNG IHDR chunk 不存在")
  }
  let width = read_u32_be(data, 16)
  let height = read_u32_be(data, 20)
  let bit_depth = data[24].to_int()
  let color_type = data[25].to_int()
  let compression_method = data[26].to_int()
  let filter_method = data[27].to_int()
  let interlace_method = data[28].to_int()
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("PNG 尺寸无效")
  }
  let num_channels = png_channels_count(color_type)
  let has_alpha = color_type == 4 || color_type == 6
  let is_palette = color_type == 3
  PngInfoExtended::{
    width,
    height,
    bit_depth,
    color_type,
    color_type_name: png_color_type_name(color_type),
    num_channels,
    has_alpha,
    is_palette,
    compression_method,
    filter_method,
    interlace_method,
  }
}
