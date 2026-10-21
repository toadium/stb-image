///|
/// ICNS 扩展信息（包含图标数量、各图标类型/尺寸等）
pub struct IcnsInfoExtended {
  file_size : Int32
  num_icons : Int32
  icon_types : Array[String]
  icon_sizes : Array[Int32]
  is_png_list : Array[Bool]
  width : Int32
  height : Int32
  num_channels : Int32
  has_alpha : Bool
}

///|
/// 检测数据是否为 ICNS 格式
pub fn is_icns_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 8 {
    return false
  }
  data[0].to_int() == 0x69 &&
  data[1].to_int() == 0x63 &&
  data[2].to_int() == 0x6E &&
  data[3].to_int() == 0x73
}

///|
/// 解析 ICNS 扩展头部信息
pub fn icns_info_extended(
  data : Bytes,
) -> IcnsInfoExtended raise @types.LoadError {
  if !is_icns_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not an ICNS file")
  }
  let len = data.length()
  let file_size = read_u32_be(data, 4)
  let icon_types : Array[String] = []
  let icon_sizes : Array[Int32] = []
  let is_png_list : Array[Bool] = []
  let mut pos = 8
  let mut max_size = 0
  while pos + 8 <= len {
    let type_code = icns_type_to_string(data, pos)
    let chunk_len = read_u32_be(data, pos + 4)
    if chunk_len < 8 || pos + chunk_len > len {
      break
    }
    let (icon_size, is_png) = icns_icon_info(type_code)
    if icon_size > 0 {
      icon_types.push(type_code)
      icon_sizes.push(icon_size)
      is_png_list.push(is_png)
      if icon_size > max_size {
        max_size = icon_size
      }
    }
    pos += chunk_len
  }
  if max_size == 0 {
    raise @types.LoadError::DecodeFailed("ICNS 无有效图标")
  }
  IcnsInfoExtended::{
    file_size,
    num_icons: icon_types.length(),
    icon_types,
    icon_sizes,
    is_png_list,
    width: max_size,
    height: max_size,
    num_channels: 4,
    has_alpha: true,
  }
}
