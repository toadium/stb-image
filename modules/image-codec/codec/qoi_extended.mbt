///|
/// QOI 扩展信息（包含通道数、色彩空间等）
pub struct QoiInfoExtended {
  width : Int32
  height : Int32
  channels : Int32
  colorspace : Int32
  colorspace_name : String
  num_channels : Int32
  has_alpha : Bool
}

///|
/// 检测数据是否为 QOI 格式
pub fn is_qoi_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 14 {
    return false
  }
  data[0].to_int() == 0x71 &&
  data[1].to_int() == 0x6F &&
  data[2].to_int() == 0x69 &&
  data[3].to_int() == 0x66
}

///|
/// 解析 QOI 扩展头部信息
pub fn qoi_info_extended(
  data : Bytes,
) -> QoiInfoExtended raise @types.LoadError {
  if !is_qoi_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a QOI file")
  }
  let width = read_u32_be(data, 4)
  let height = read_u32_be(data, 8)
  let channels = data[12].to_int()
  let colorspace = data[13].to_int()
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("QOI 尺寸无效")
  }
  if channels != 3 && channels != 4 {
    raise @types.LoadError::DecodeFailed("QOI 通道数无效")
  }
  QoiInfoExtended::{
    width,
    height,
    channels,
    colorspace,
    colorspace_name: if colorspace == 0 {
      "sRGB with linear alpha"
    } else {
      "all linear"
    },
    num_channels: channels,
    has_alpha: channels == 4,
  }
}
