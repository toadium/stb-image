///|
/// HEIF 扩展信息（包含色彩空间、旋转、HEVC 编码配置等）
pub struct HeifInfoExtended {
  width : Int
  height : Int
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
  rotation : Int
  mirror : Int
  color_type : String
  color_primaries : Int
  transfer_characteristics : Int
  matrix_coefficients : Int
  full_range : Bool
  hevc_profile : Int
  hevc_level : Int
  hevc_tier : Int
  hevc_chroma_format : Int
  hevc_bit_depth_luma : Int
  hevc_bit_depth_chroma : Int
}

///|
/// 解析 HEIF 扩展头部信息
///
/// 递归遍历 ISOBMFF box 结构，提取色彩空间、旋转、镜像、HEVC 编码配置等
pub fn heif_info_extended(
  data : Bytes,
) -> HeifInfoExtended raise @types.LoadError {
  if !is_heif_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a HEIF file")
  }
  let len = data.length()
  let mut width = 0
  let mut height = 0
  let mut bit_depth = 8
  let mut has_alpha = false
  let mut rotation = 0
  let mut mirror = 0
  let mut color_type = "unknown"
  let mut color_primaries = 0
  let mut transfer_characteristics = 0
  let mut matrix_coefficients = 0
  let mut full_range = false
  let mut hevc_profile = 0
  let mut hevc_level = 0
  let mut hevc_tier = 0
  let mut hevc_chroma_format = 0
  let mut hevc_bit_depth_luma = 8
  let mut hevc_bit_depth_chroma = 8
  heif_scan_boxes(data, 0, len, fn(box_off, _box_size, box_type) {
    if box_type == "ispe" && box_off + 20 <= len {
      width = read_u32_be(data, box_off + 12)
      height = read_u32_be(data, box_off + 16)
    }
    if box_type == "auxC" {
      has_alpha = true
    }
    if box_type == "pixi" && box_off + 13 <= len {
      let num_ch = data[box_off + 12].to_int()
      if num_ch > 0 && box_off + 13 + num_ch <= len {
        bit_depth = data[box_off + 13].to_int()
      }
    }
    if box_type == "irot" && box_off + 9 <= len {
      let angle_bits = data[box_off + 8].to_int() & 0x03
      rotation = angle_bits * 90
    }
    if box_type == "imir" && box_off + 9 <= len {
      mirror = data[box_off + 8].to_int() & 0x01
    }
    if box_type == "colr" && box_off + 16 <= len {
      let ctype = read_4cc(data, box_off + 8)
      if ctype == "nclx" && box_off + 19 <= len {
        color_type = "nclx"
        color_primaries = read_u16_be(data, box_off + 12)
        transfer_characteristics = read_u16_be(data, box_off + 14)
        matrix_coefficients = read_u16_be(data, box_off + 16)
        full_range = (data[box_off + 18].to_int() & 0x80) != 0
      } else if ctype == "rICC" {
        color_type = "rICC"
      } else if ctype == "prof" {
        color_type = "prof"
      }
    }
    if box_type == "hvcC" && box_off + 22 <= len {
      let b1 = data[box_off + 9].to_int()
      hevc_tier = (b1 >> 6) & 0x01
      hevc_profile = b1 & 0x1F
      hevc_level = data[box_off + 13].to_int()
      let chroma_byte = data[box_off + 21].to_int()
      hevc_chroma_format = chroma_byte & 0x03
      if box_off + 23 <= len {
        hevc_bit_depth_luma = (data[box_off + 22].to_int() & 0x07) + 8
      }
      if box_off + 24 <= len {
        hevc_bit_depth_chroma = (data[box_off + 23].to_int() & 0x07) + 8
      }
    }
  })
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed(
      "HEIF: could not determine image dimensions",
    )
  }
  let num_channels = if has_alpha { 4 } else { 3 }
  HeifInfoExtended::{
    width,
    height,
    bit_depth,
    num_channels,
    has_alpha,
    rotation,
    mirror,
    color_type,
    color_primaries,
    transfer_characteristics,
    matrix_coefficients,
    full_range,
    hevc_profile,
    hevc_level,
    hevc_tier,
    hevc_chroma_format,
    hevc_bit_depth_luma,
    hevc_bit_depth_chroma,
  }
}

///|
fn heif_scan_boxes(
  data : Bytes,
  start : Int,
  end : Int,
  callback : (Int, Int, String) -> Unit,
) -> Unit {
  let mut offset = start
  while offset + 8 <= end {
    let box_size = read_u32_be(data, offset)
    if box_size < 8 || offset + box_size > end {
      break
    }
    let btype = box_type_str(data, offset)
    callback(offset, box_size, btype)
    if btype == "meta" ||
      btype == "iprp" ||
      btype == "ipco" ||
      btype == "moov" ||
      btype == "trak" ||
      btype == "mdia" {
      let child_start = if btype == "meta" { offset + 12 } else { offset + 8 }
      heif_scan_boxes(data, child_start, offset + box_size, callback)
    }
    offset += box_size
  }
}
