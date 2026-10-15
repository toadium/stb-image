///|
/// TGA 扩展信息（包含图像类型、位深、行序等）
pub struct TgaInfoExtended {
  width : Int
  height : Int
  image_type : Int
  image_type_name : String
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
  is_bottom_up : Bool
  id_length : Int
  color_map_type : Int
  x_origin : Int
  y_origin : Int
}

///|
fn tga_image_type_name(t : Int) -> String {
  match t {
    0 => "no image data"
    1 => "uncompressed color-mapped"
    2 => "uncompressed true-color"
    3 => "uncompressed grayscale"
    9 => "RLE color-mapped"
    10 => "RLE true-color"
    11 => "RLE grayscale"
    _ => "unknown"
  }
}

///|
/// 检测数据是否为 TGA 格式
///
/// TGA 无明确 magic，通过头部字段有效性判断
pub fn is_tga_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 18 {
    return false
  }
  let color_map_type = data[1].to_int()
  let image_type = data[2].to_int()
  let bpp = data[16].to_int()
  color_map_type == 0 &&
  (image_type == 2 || image_type == 10) &&
  (bpp == 24 || bpp == 32)
}

///|
/// 解析 TGA 扩展头部信息
pub fn tga_info_extended(
  data : Bytes,
) -> TgaInfoExtended raise @types.LoadError {
  let len = data.length()
  if len < 18 {
    raise @types.LoadError::DecodeFailed("TGA 数据过短")
  }
  let id_length = data[0].to_int()
  let color_map_type = data[1].to_int()
  let image_type = data[2].to_int()
  let x_origin = read_u16_le(data, 8)
  let y_origin = read_u16_le(data, 10)
  let width = read_u16_le(data, 12)
  let height = read_u16_le(data, 14)
  let bpp = data[16].to_int()
  let descriptor = data[17].to_int()
  if color_map_type != 0 {
    raise @types.LoadError::DecodeFailed("TGA 颜色映射类型不支持")
  }
  if image_type != 2 && image_type != 10 && image_type != 3 && image_type != 11 {
    raise @types.LoadError::DecodeFailed("TGA image type 不支持")
  }
  if bpp != 8 && bpp != 24 && bpp != 32 {
    raise @types.LoadError::DecodeFailed("TGA 位深不支持")
  }
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("TGA 尺寸无效")
  }
  let is_bottom_up = (descriptor & 0x20) == 0
  let num_channels = bpp / 8
  TgaInfoExtended::{
    width,
    height,
    image_type,
    image_type_name: tga_image_type_name(image_type),
    bit_depth: bpp,
    num_channels,
    has_alpha: bpp == 32,
    is_bottom_up,
    id_length,
    color_map_type,
    x_origin,
    y_origin,
  }
}
