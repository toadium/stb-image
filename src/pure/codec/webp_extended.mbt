///|
/// WebP 扩展信息（包含格式类型、alpha、动画、元数据标志等）
pub struct WebpInfoExtended {
  width : Int
  height : Int
  format : String
  has_alpha : Bool
  has_animation : Bool
  has_icc_profile : Bool
  has_exif : Bool
  has_xmp : Bool
  num_channels : Int
}

///|
/// 检测数据是否为 WebP 格式
pub fn is_webp_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 12 {
    return false
  }
  // RIFF magic
  if data[0].to_int() != 0x52 ||
    data[1].to_int() != 0x49 ||
    data[2].to_int() != 0x46 ||
    data[3].to_int() != 0x46 {
    return false
  }
  // WEBP fourcc
  data[8].to_int() == 0x57 &&
  data[9].to_int() == 0x45 &&
  data[10].to_int() == 0x42 &&
  data[11].to_int() == 0x50
}

///|
/// 解析 WebP 扩展头部信息
///
/// 遍历 RIFF chunk 结构，提取格式类型、尺寸、alpha、动画、ICC/EXIF/XMP 标志
pub fn webp_info_extended(
  data : Bytes,
) -> WebpInfoExtended raise @types.LoadError {
  if !is_webp_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a WebP file")
  }
  let len = data.length()
  let mut width = 0
  let mut height = 0
  let mut format = "unknown"
  let mut has_alpha = false
  let mut has_animation = false
  let mut has_icc_profile = false
  let mut has_exif = false
  let mut has_xmp = false
  // 遍历 RIFF chunks
  let mut pos = 12
  while pos + 8 <= len {
    let chunk_id = read_4cc(data, pos)
    let chunk_size = data[pos + 4].to_int() |
      (data[pos + 5].to_int() << 8) |
      (data[pos + 6].to_int() << 16) |
      (data[pos + 7].to_int() << 24)
    if chunk_size < 0 || pos + 8 + chunk_size > len {
      break
    }
    let chunk_data_start = pos + 8
    match chunk_id {
      "VP8X" => {
        format = "extended"
        if chunk_data_start + 10 <= len {
          let flags = data[chunk_data_start].to_int()
          has_alpha = (flags & 0x10) != 0
          has_animation = (flags & 0x20) != 0
          has_icc_profile = (flags & 0x01) != 0
          has_exif = (flags & 0x08) != 0
          has_xmp = (flags & 0x04) != 0
          // canvas width/height: 24-bit LE + 1
          width = data[chunk_data_start + 4].to_int() |
            (data[chunk_data_start + 5].to_int() << 8) |
            (data[chunk_data_start + 6].to_int() << 16)
          width += 1
          height = data[chunk_data_start + 7].to_int() |
            (data[chunk_data_start + 8].to_int() << 8) |
            (data[chunk_data_start + 9].to_int() << 16)
          height += 1
        }
      }
      "VP8 " => {
        if format != "extended" {
          format = "lossy"
        }
        // VP8 keyframe: 3 bytes tag + 3 bytes start code + 14 bits width + 2 bits + 14 bits height
        if chunk_data_start + 10 <= len && width == 0 {
          let tag = data[chunk_data_start].to_int() |
            (data[chunk_data_start + 1].to_int() << 8) |
            (data[chunk_data_start + 2].to_int() << 16)
          let is_keyframe = (tag & 1) == 0
          if is_keyframe {
            // start code: 0x9d 0x01 0x2a
            if chunk_data_start + 9 <= len {
              let w = data[chunk_data_start + 6].to_int() |
                (data[chunk_data_start + 7].to_int() << 8)
              let h = data[chunk_data_start + 8].to_int() |
                (data[chunk_data_start + 9].to_int() << 8)
              width = w & 0x3FFF
              height = h & 0x3FFF
            }
          }
        }
      }
      "VP8L" => {
        if format != "extended" {
          format = "lossless"
        }
        // VP8L: 0x2F signature + 14 bits width + 14 bits height + 1 bit alpha
        if chunk_data_start + 5 <= len && width == 0 {
          if data[chunk_data_start].to_int() == 0x2F {
            let b1 = data[chunk_data_start + 1].to_int()
            let b2 = data[chunk_data_start + 2].to_int()
            let b3 = data[chunk_data_start + 3].to_int()
            let b4 = data[chunk_data_start + 4].to_int()
            // width: 14 bits LE from b1 (8 bits) + b2 (6 bits)
            width = (b1 | ((b2 & 0x3F) << 8)) + 1
            // height: 14 bits from b2 (2 bits) + b3 (8 bits) + b4 (4 bits)
            height = (((b2 >> 6) & 0x03) | (b3 << 2) | ((b4 & 0x0F) << 10)) + 1
            // alpha: 1 bit from b4 bit 4
            if format != "extended" {
              has_alpha = ((b4 >> 4) & 1) == 1
            }
          }
        }
      }
      "ANIM" => has_animation = true
      "ICCP" => has_icc_profile = true
      "EXIF" => has_exif = true
      "XMP " => has_xmp = true
      _ => ()
    }
    pos += 8 + chunk_size
    if chunk_size % 2 == 1 {
      pos += 1 // padding
    }
  }
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed(
      "WebP: could not determine image dimensions",
    )
  }
  let num_channels = if has_alpha { 4 } else { 3 }
  WebpInfoExtended::{
    width,
    height,
    format,
    has_alpha,
    has_animation,
    has_icc_profile,
    has_exif,
    has_xmp,
    num_channels,
  }
}
