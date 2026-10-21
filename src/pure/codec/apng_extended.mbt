///|
/// APNG 扩展信息（包含帧数、播放次数、动画标志等）
pub struct ApngInfoExtended {
  width : Int32
  height : Int32
  bit_depth : Int32
  color_type : Int32
  color_type_name : String
  num_channels : Int32
  has_alpha : Bool
  num_frames : Int32
  num_plays : Int32
  is_animated : Bool
}

///|
fn apng_color_type_name(ct : Int32) -> String {
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
fn apng_channels_count(ct : Int32) -> Int32 {
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
/// 检测数据是否为 APNG 格式（PNG signature + 含 acTL chunk）
pub fn is_apng_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 8 {
    return false
  }
  if !is_png_signature(data, 0) {
    return false
  }
  let mut pos = 8
  while pos + 8 <= len {
    let chunk_len = read_u32_be(data, pos)
    let b0 = data[pos + 4].to_int()
    let b1 = data[pos + 5].to_int()
    let b2 = data[pos + 6].to_int()
    let b3 = data[pos + 7].to_int()
    // 检查 "acTL" chunk
    if b0 == 0x61 && b1 == 0x63 && b2 == 0x54 && b3 == 0x4C {
      return true
    }
    if chunk_len > len {
      break
    }
    pos += 8 + chunk_len + 4
  }
  false
}

///|
/// 解析 APNG 扩展头部信息
///
/// 遍历 PNG chunks，提取 IHDR(尺寸/位深/颜色类型) + acTL(帧数/播放次数)
pub fn apng_info_extended(
  data : Bytes,
) -> ApngInfoExtended raise @types.LoadError {
  let len = data.length()
  if len < 8 {
    raise @types.LoadError::DecodeFailed("APNG 数据过短")
  }
  if !is_png_signature(data, 0) {
    raise @types.LoadError::UnsupportedFormat("Not a PNG/APNG file")
  }
  let mut pos = 8
  let mut width = 0
  let mut height = 0
  let mut bit_depth = 0
  let mut color_type = 0
  let mut num_frames = 0
  let mut num_plays = 0
  let mut found_ihdr = false
  while pos + 8 <= len {
    let chunk_len = read_u32_be(data, pos)
    let b0 = data[pos + 4].to_int()
    let b1 = data[pos + 5].to_int()
    let b2 = data[pos + 6].to_int()
    let b3 = data[pos + 7].to_int()
    if pos + 8 + chunk_len + 4 > len {
      break
    }
    // IHDR
    if b0 == 0x49 && b1 == 0x48 && b2 == 0x44 && b3 == 0x52 {
      width = read_u32_be(data, pos + 8)
      height = read_u32_be(data, pos + 12)
      bit_depth = data[pos + 16].to_int()
      color_type = data[pos + 17].to_int()
      found_ihdr = true
    }
    // acTL
    if b0 == 0x61 && b1 == 0x63 && b2 == 0x54 && b3 == 0x4C {
      num_frames = read_u32_be(data, pos + 8)
      num_plays = read_u32_be(data, pos + 12)
    }
    pos += 8 + chunk_len + 4
  }
  if !found_ihdr || width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed("APNG IHDR 不存在或尺寸无效")
  }
  let num_channels = apng_channels_count(color_type)
  let has_alpha = color_type == 4 || color_type == 6
  ApngInfoExtended::{
    width,
    height,
    bit_depth,
    color_type,
    color_type_name: apng_color_type_name(color_type),
    num_channels,
    has_alpha,
    num_frames,
    num_plays,
    is_animated: num_frames > 1,
  }
}
