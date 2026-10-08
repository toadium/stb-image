///|
/// AVIF (AV1 Image File Format) 解码器
///
/// AVIF 基于 AV1 编码，使用 ISOBMFF 容器格式。
/// 本模块提供格式检测和基本头部解析，完整解码需 AV1 解码器支持。
///
/// Magic bytes: 0x00 0x00 0x00 0x?? 0x66 0x74 0x79 0x70 0x61 0x76 0x69 0x66
/// (ftyp box with brand "avif" or "avis")

///|
/// AVIF 图像信息
pub struct AvifInfo {
  width : Int
  height : Int
  bit_depth : Int
  num_channels : Int
  has_alpha : Bool
}

///|
/// 检测数据是否为 AVIF 格式
///
/// AVIF 文件以 ftyp box 开头，brand 为 "avif" 或 "avis"
pub fn is_avif_format(data : Bytes) -> Bool {
  let len = data.length()
  if len < 12 {
    return false
  }
  // 检查 ftyp box: bytes 4-7 = "ftyp"
  if data[4] != b'f' || data[5] != b't' || data[6] != b'y' || data[7] != b'p' {
    return false
  }
  // 检查 brand: bytes 8-11 = "avif" or "avis"
  let b8 = data[8]
  let b9 = data[9]
  let b10 = data[10]
  let b11 = data[11]
  // "avif" = 0x61 0x76 0x69 0x66
  if b8 == b'a' && b9 == b'v' && b10 == b'i' && b11 == b'f' {
    return true
  }
  // "avis" = 0x61 0x76 0x69 0x73
  if b8 == b'a' && b9 == b'v' && b10 == b'i' && b11 == b's' {
    return true
  }
  false
}

///|
/// 解析 AVIF 头部信息
///
/// 解析 ISOBMFF box 结构，提取图像尺寸和位深信息。
/// 注意：完整解析需要遍历所有 box，此处仅解析基本元数据。
pub fn avif_info(data : Bytes) -> AvifInfo raise @types.LoadError {
  if !is_avif_format(data) {
    raise @types.LoadError::UnsupportedFormat("Not an AVIF file")
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
    // box type "ispe" = 0x69 0x73 0x70 0x65
    if box_type_0 == b'i' &&
      box_type_1 == b's' &&
      box_type_2 == b'p' &&
      box_type_3 == b'e' {
      // ispe box: full_box_header(8) + version(4) + width(4) + height(4)
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
    // 检查 auxC box (AuxiliaryTypeProperty) for alpha
    // box type "auxC" = 0x61 0x75 0x78 0x43
    if box_type_0 == b'a' &&
      box_type_1 == b'u' &&
      box_type_2 == b'x' &&
      box_type_3 == b'C' {
      has_alpha = true
    }
    // 检查 pixi box (PixelInformationProperty) for bit depth
    // box type "pixi" = 0x70 0x69 0x78 0x69
    if box_type_0 == b'p' &&
      box_type_1 == b'i' &&
      box_type_2 == b'x' &&
      box_type_3 == b'i' {
      // pixi box: full_box_header(8) + version(4) + num_channels(1) + bit_depths(...)
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
      "AVIF: could not determine image dimensions",
    )
  }
  let num_channels = if has_alpha { 4 } else { 3 }
  AvifInfo::{ width, height, bit_depth, num_channels, has_alpha, }
}

///|
/// 解码 AVIF 图像
///
/// 注意：完整 AVIF 解码需要 AV1 解码器，当前返回 UnsupportedFormat。
/// 使用 avif_info 获取元数据。
pub fn avif_decode(data : Bytes) -> @types.Image raise @types.LoadError {
  let info = avif_info(data)
  raise @types.LoadError::UnsupportedFormat(
    "AVIF decode not yet implemented (AV1 decoder required). Image is \{info.width}x\{info.height} \{info.bit_depth}-bit",
  )
}
