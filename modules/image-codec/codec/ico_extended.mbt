///|
/// ICO 扩展信息（包含图像数量、各子图像尺寸/位深等）
pub struct IcoInfoExtended {
  icon_type : Int32
  icon_type_name : String
  num_images : Int32
  widths : Array[Int32]
  heights : Array[Int32]
  bit_depths : Array[Int32]
  width : Int32
  height : Int32
  num_channels : Int32
  has_alpha : Bool
}

///|
/// 检测数据是否为 ICO 格式
pub fn is_ico_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 6 {
    return false
  }
  let reserved = read_u16_le(data, 0)
  let icon_type = read_u16_le(data, 2)
  reserved == 0 && icon_type == 1
}

///|
/// 解析 ICO 扩展头部信息
pub fn ico_info_extended(
  data : Bytes,
) -> IcoInfoExtended raise @types.LoadError {
  let len = data.length()
  if len < 6 {
    raise @types.LoadError::DecodeFailed("ICO 数据过短")
  }
  let icon_type = read_u16_le(data, 2)
  let count = read_u16_le(data, 4)
  if icon_type != 1 {
    raise @types.LoadError::UnsupportedFormat("Not an ICO file")
  }
  if count == 0 {
    raise @types.LoadError::DecodeFailed("ICO 无图像条目")
  }
  if len < 6 + count * 16 {
    raise @types.LoadError::DecodeFailed("ICO 目录数据不完整")
  }
  let widths : Array[Int32] = []
  let heights : Array[Int32] = []
  let bit_depths : Array[Int32] = []
  let mut best_w = 0
  let mut best_h = 0
  let mut best_area = 0
  for i in 0..<count {
    let base = 6 + i * 16
    let w = data[base].to_int()
    let h = data[base + 1].to_int()
    let planes = read_u16_le(data, base + 4)
    let bit_count = read_u16_le(data, base + 6)
    let real_w = if w == 0 { 256 } else { w }
    let real_h = if h == 0 { 256 } else { h }
    let real_bd = if planes == 0 { bit_count } else { planes * bit_count }
    widths.push(real_w)
    heights.push(real_h)
    bit_depths.push(real_bd)
    let area = real_w * real_h
    if area > best_area {
      best_area = area
      best_w = real_w
      best_h = real_h
    }
  }
  IcoInfoExtended::{
    icon_type,
    icon_type_name: "ICO",
    num_images: count,
    widths,
    heights,
    bit_depths,
    width: best_w,
    height: best_h,
    num_channels: 4,
    has_alpha: true,
  }
}
