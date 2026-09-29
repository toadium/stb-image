///|
/// HEIF (High Efficiency Image File Format) 解码器
///
/// HEIF 基于 HEVC (H.265) 编码，使用 ISOBMFF 容器格式。
/// 本模块提供格式检测和基本头部解析，完整解码需 HEVC 解码器支持。
///
/// Magic bytes: 0x00 0x00 0x00 0x?? 0x66 0x74 0x79 0x70 0x68 0x65 0x69 0x63
/// (ftyp box with brand "heic", "heix", "hevc", or "mif1")

///|
/// HEIF 图像信息
pub struct HeifInfo {
  width : Int
  height : Int
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
}

///|
/// 检测数据是否为 HEIF 格式
///
/// HEIF 文件以 ftyp box 开头，brand 为 "heic", "heix", "hevc", "hevm", "heim", "heis", "mif1" 等
pub fn is_heif_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 12 {
    return false
  }
  // 检查 ftyp box: bytes 4-7 = "ftyp"
  if data[4] != b'f' || data[5] != b't' || data[6] != b'y' || data[7] != b'p' {
    return false
  }
  let b8 = data[8]
  let b9 = data[9]
  let b10 = data[10]
  let b11 = data[11]
  // "heic" = 0x68 0x65 0x69 0x63
  if b8 == b'h' && b9 == b'e' && b10 == b'i' && b11 == b'c' {
    return true
  }
  // "heix" = 0x68 0x65 0x69 0x78
  if b8 == b'h' && b9 == b'e' && b10 == b'i' && b11 == b'x' {
    return true
  }
  // "hevc" = 0x68 0x65 0x76 0x63
  if b8 == b'h' && b9 == b'e' && b10 == b'v' && b11 == b'c' {
    return true
  }
  // "mif1" = 0x6D 0x69 0x66 0x31
  if b8 == b'm' && b9 == b'i' && b10 == b'f' && b11 == b'1' {
    return true
  }
  false
}

///|
/// 解析 HEIF 头部信息
///
/// 解析 ISOBMFF box 结构，提取图像尺寸和位深信息。
pub fn heif_info(data : Bytes) -> HeifInfo raise @types.LoadError {
  if !is_heif_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not a HEIF file")
  }
  let len = data.length()
  let mut offset = 0
  let mut width = 0
  let mut height = 0
  let mut bit_depth = 8
  let mut has_alpha = false
  // 遍历 ISOBMFF boxes
  while offset + 8 <= len {
    let box_size = (data[offset].to_int() << 24) |
      (data[offset + 1].to_int() << 16) |
      (data[offset + 2].to_int() << 8) |
      data[offset + 3].to_int()
    if box_size < 8 || offset + box_size > len {
      break
    }
    let box_type_0 = data[offset + 4]
    let box_type_1 = data[offset + 5]
    let box_type_2 = data[offset + 6]
    let box_type_3 = data[offset + 7]
    // 检查 ispe box (ImageSpatialExtentsProperty)
    if box_type_0 == b'i' &&
      box_type_1 == b's' &&
      box_type_2 == b'p' &&
      box_type_3 == b'e' {
      if offset + 20 <= len {
        width = (data[offset + 12].to_int() << 24) |
          (data[offset + 13].to_int() << 16) |
          (data[offset + 14].to_int() << 8) |
          data[offset + 15].to_int()
        height = (data[offset + 16].to_int() << 24) |
          (data[offset + 17].to_int() << 16) |
          (data[offset + 18].to_int() << 8) |
          data[offset + 19].to_int()
      }
    }
    // 检查 auxC box for alpha
    if box_type_0 == b'a' &&
      box_type_1 == b'u' &&
      box_type_2 == b'x' &&
      box_type_3 == b'C' {
      has_alpha = true
    }
    // 检查 pixi box for bit depth
    if box_type_0 == b'p' &&
      box_type_1 == b'i' &&
      box_type_2 == b'x' &&
      box_type_3 == b'i' {
      if offset + 13 <= len {
        let num_ch = data[offset + 12].to_int()
        if num_ch > 0 && offset + 13 + num_ch <= len {
          bit_depth = data[offset + 13].to_int()
        }
      }
    }
    offset += box_size
  }
  if width == 0 || height == 0 {
    raise @types.LoadError::DecodeFailed(
      "HEIF: could not determine image dimensions",
    )
  }
  let num_channels = if has_alpha { 4 } else { 3 }
  HeifInfo::{ width, height, bit_depth, num_channels, has_alpha }
}

///|
/// 解码 HEIF 图像
///
/// 注意：完整 HEIF 解码需要 HEVC 解码器，当前返回 UnsupportedFormat。
/// 使用 heif_info 获取元数据。
pub fn heif_decode(data : Bytes) -> @types.Image raise @types.LoadError {
  let info = heif_info(data)
  raise @types.LoadError::UnsupportedFormat(
    "HEIF decode not yet implemented (HEVC decoder required). Image is \{info.width}x\{info.height} \{info.bit_depth}-bit",
  )
}
