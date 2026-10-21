///|
/// CUR 扩展信息（包含图像数量、热点坐标等）
pub struct CurInfoExtended {
  icon_type : Int32
  num_images : Int32
  widths : Array[Int32]
  heights : Array[Int32]
  hotspot_xs : Array[Int32]
  hotspot_ys : Array[Int32]
  width : Int32
  height : Int32
  num_channels : Int32
  has_alpha : Bool
}

///|
/// 检测数据是否为 CUR 格式
pub fn is_cur_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 6 {
    return false
  }
  let reserved = read_u16_le(data, 0)
  let icon_type = read_u16_le(data, 2)
  reserved == 0 && icon_type == 2
}

///|
/// 解析 CUR 扩展头部信息
pub fn cur_info_extended(
  data : Bytes,
) -> CurInfoExtended raise @types.LoadError {
  let len = data.length()
  if len < 6 {
    raise @types.LoadError::DecodeFailed("CUR 数据过短")
  }
  let icon_type = read_u16_le(data, 2)
  let count = read_u16_le(data, 4)
  if icon_type != 2 {
    raise @types.LoadError::UnsupportedFormat("Not a CUR file")
  }
  if count == 0 {
    raise @types.LoadError::DecodeFailed("CUR 无图像条目")
  }
  if len < 6 + count * 16 {
    raise @types.LoadError::DecodeFailed("CUR 目录数据不完整")
  }
  let widths : Array[Int32] = []
  let heights : Array[Int32] = []
  let hotspot_xs : Array[Int32] = []
  let hotspot_ys : Array[Int32] = []
  let mut best_w = 0
  let mut best_h = 0
  let mut best_area = 0
  for i in 0..<count {
    let base = 6 + i * 16
    let w = data[base].to_int()
    let h = data[base + 1].to_int()
    let hotspot_x = read_u16_le(data, base + 4)
    let hotspot_y = read_u16_le(data, base + 6)
    let real_w = if w == 0 { 256 } else { w }
    let real_h = if h == 0 { 256 } else { h }
    widths.push(real_w)
    heights.push(real_h)
    hotspot_xs.push(hotspot_x)
    hotspot_ys.push(hotspot_y)
    let area = real_w * real_h
    if area > best_area {
      best_area = area
      best_w = real_w
      best_h = real_h
    }
  }
  CurInfoExtended::{
    icon_type,
    num_images: count,
    widths,
    heights,
    hotspot_xs,
    hotspot_ys,
    width: best_w,
    height: best_h,
    num_channels: 4,
    has_alpha: true,
  }
}
