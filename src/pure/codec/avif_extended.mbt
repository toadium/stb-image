///|
/// AVIF 扩展信息（包含色彩空间、旋转、编码配置等）
pub struct AvifInfoExtended {
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
  av1_profile : Int
  av1_level : Int
  av1_tier : Int
  av1_monochrome : Bool
}

///|
fn read_4cc(data : Bytes, offset : Int) -> String {
  let b0 = data[offset].to_int()
  let b1 = data[offset + 1].to_int()
  let b2 = data[offset + 2].to_int()
  let b3 = data[offset + 3].to_int()
  let s : Array[Int] = [b0, b1, b2, b3]
  let buf : Array[String] = []
  for c in s {
    match c.to_char() {
      Some(ch) => buf.push(ch.to_string())
      None => buf.push("?")
    }
  }
  buf[0] + buf[1] + buf[2] + buf[3]
}

///|
fn box_type_str(data : Bytes, offset : Int) -> String {
  read_4cc(data, offset + 4)
}

///|
/// 解析 AVIF 扩展头部信息
///
/// 递归遍历 ISOBMFF box 结构，提取色彩空间、旋转、镜像、AV1 编码配置等
pub fn avif_info_extended(
  data : Bytes,
) -> AvifInfoExtended raise @types.LoadError {
  if !is_avif_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not an AVIF file")
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
  let mut av1_profile = 0
  let mut av1_level = 0
  let mut av1_tier = 0
  let mut av1_monochrome = false
  // 递归遍历所有 box
  scan_boxes(data, 0, len, fn(box_off, _box_size, box_type) {
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
    if box_type == "av1C" && box_off + 12 <= len {
      let b1 = data[box_off + 9].to_int()
      av1_profile = (b1 >> 5) & 0x07
      av1_level = b1 & 0x1F
      if box_off + 13 <= len {
        let b2 = data[box_off + 10].to_int()
        av1_tier = (b2 >> 7) & 0x01
        av1_monochrome = ((b2 >> 4) & 0x01) == 1
      }
    }
  })
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed(
      "AVIF: could not determine image dimensions",
    )
  }
  let num_channels = if has_alpha { 4 } else { 3 }
  AvifInfoExtended::{
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
    av1_profile,
    av1_level,
    av1_tier,
    av1_monochrome,
  }
}

///|
/// 递归扫描 ISOBMFF box 结构
fn scan_boxes(
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
    // 递归进入容器 box: meta, iprp, ipco, moov, trak, mdia
    if btype == "meta" ||
      btype == "iprp" ||
      btype == "ipco" ||
      btype == "moov" ||
      btype == "trak" ||
      btype == "mdia" {
      // full box: skip version(4) + flags for meta
      let child_start = if btype == "meta" { offset + 12 } else { offset + 8 }
      scan_boxes(data, child_start, offset + box_size, callback)
    }
    offset += box_size
  }
}
