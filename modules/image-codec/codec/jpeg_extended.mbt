///|
/// JPEG 扩展信息（包含精度、分量数、渐进标志等）
pub struct JpegInfoExtended {
  width : Int32
  height : Int32
  precision : Int32
  num_components : Int32
  is_grayscale : Bool
  is_progressive : Bool
  sof_marker : Int32
  sof_name : String
  num_channels : Int32
  has_alpha : Bool
}

///|
/// 检测数据是否为 JPEG 格式
pub fn is_jpeg_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 4 {
    return false
  }
  data[0].to_int() == 0xFF &&
  data[1].to_int() == 0xD8 &&
  data[2].to_int() == 0xFF
}

///|
fn jpeg_sof_name(marker : Int32) -> String {
  match marker {
    0xC0 => "Baseline DCT"
    0xC1 => "Extended sequential DCT"
    0xC2 => "Progressive DCT"
    0xC3 => "Lossless sequential"
    0xC5 => "Differential sequential DCT"
    0xC6 => "Differential progressive DCT"
    0xC7 => "Differential lossless"
    0xC9 => "Extended sequential arithmetic"
    0xCA => "Progressive arithmetic"
    0xCB => "Lossless arithmetic"
    _ => "unknown"
  }
}

///|
fn jpeg_is_sof_marker(marker : Int32) -> Bool {
  marker == 0xC0 ||
  marker == 0xC1 ||
  marker == 0xC2 ||
  marker == 0xC3 ||
  marker == 0xC5 ||
  marker == 0xC6 ||
  marker == 0xC7 ||
  marker == 0xC9 ||
  marker == 0xCA ||
  marker == 0xCB
}

///|
/// 解析 JPEG 扩展头部信息
///
/// 遍历 JPEG markers，查找 SOF marker 提取尺寸、精度、分量数、渐进标志
pub fn jpeg_info_extended(
  data : Bytes,
) -> JpegInfoExtended raise @types.LoadError {
  if !is_jpeg_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a JPEG file")
  }
  let len = data.length()
  let mut pos = 2
  let mut width = 0
  let mut height = 0
  let mut precision = 8
  let mut num_components = 3
  let mut sof_marker = 0xC0
  let mut found_sof = false
  while pos + 2 <= len {
    if data[pos].to_int() != 0xFF {
      pos += 1
      continue
    }
    let marker = data[pos + 1].to_int()
    if marker == 0x00 || marker == 0xFF {
      pos += 1
      continue
    }
    if marker == 0xD8 || marker == 0xD9 {
      pos += 2
      continue
    }
    if marker >= 0xD0 && marker <= 0xD7 {
      pos += 2
      continue
    }
    if pos + 4 > len {
      break
    }
    let seg_len = read_u16_be(data, pos + 2)
    if jpeg_is_sof_marker(marker) && pos + 9 <= len {
      precision = data[pos + 4].to_int()
      height = read_u16_be(data, pos + 5)
      width = read_u16_be(data, pos + 7)
      num_components = data[pos + 9].to_int()
      sof_marker = marker
      found_sof = true
      break
    }
    pos += 2 + seg_len
  }
  if !found_sof || width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed(
      "JPEG: could not determine image dimensions",
    )
  }
  let is_progressive = sof_marker == 0xC2
  let is_grayscale = num_components == 1
  JpegInfoExtended::{
    width,
    height,
    precision,
    num_components,
    is_grayscale,
    is_progressive,
    sof_marker,
    sof_name: jpeg_sof_name(sof_marker),
    num_channels: num_components,
    has_alpha: false,
  }
}
