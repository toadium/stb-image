// v250.0.0 PNG 元数据写入 + eXIf chunk 读写
// PNG text chunk 写入 + PNG eXIf chunk 读取/写入

///|
/// 计算 CRC32（PNG 使用的 IEEE 802.3 CRC32）
fn png_crc32(data : Bytes) -> UInt32 {
  let mut crc : UInt32 = 0xFFFFFFFFU
  for i in 0..<data.length() {
    let byte = data[i].to_uint()
    crc = crc ^ byte
    for _ in 0..<8 {
      if (crc & 1U) != 0U {
        crc = (crc >> 1) ^ 0xEDB88320U
      } else {
        crc = crc >> 1
      }
    }
  }
  crc ^ 0xFFFFFFFFU
}

///|
/// 构造 PNG chunk（length + type + data + CRC）
fn png_build_chunk(chunk_type : String, chunk_data : Bytes) -> Bytes {
  let out : Array[Byte] = []
  let len = chunk_data.length()
  // length (4 bytes BE)
  out.push(((len >> 24) & 0xFF).to_byte())
  out.push(((len >> 16) & 0xFF).to_byte())
  out.push(((len >> 8) & 0xFF).to_byte())
  out.push((len & 0xFF).to_byte())
  // type (4 bytes)
  for c in chunk_type.to_array() {
    out.push(c.to_int().to_byte())
  }
  // data
  for b in chunk_data {
    out.push(b)
  }
  // CRC: computed over type + data
  let crc_input : Array[Byte] = []
  for c in chunk_type.to_array() {
    crc_input.push(c.to_int().to_byte())
  }
  for b in chunk_data {
    crc_input.push(b)
  }
  let crc = png_crc32(Bytes::from_array(crc_input))
  out.push(((crc >> 24) & 0xFFU).to_byte())
  out.push(((crc >> 16) & 0xFFU).to_byte())
  out.push(((crc >> 8) & 0xFFU).to_byte())
  out.push((crc & 0xFFU).to_byte())
  Bytes::from_array(out)
}

///|
/// 将 text chunks 写入 PNG（在 IDAT 前插入 tEXt chunks）
/// 已有同名 keyword 的 tEXt 不做去重，直接追加
pub fn write_png_text_chunks(
  chunks : Array[PngTextChunk],
  png_data : Bytes,
) -> Bytes raise @types.LoadError {
  let len = png_data.length()
  if len < 8 ||
    png_data[0].to_int() != 0x89 ||
    png_data[1].to_int() != 0x50 ||
    png_data[2].to_int() != 0x4E ||
    png_data[3].to_int() != 0x47 {
    raise @types.LoadError::EncodeFailed("输入不是有效 PNG")
  }
  // 查找 IDAT chunk 位置
  let mut pos = 8
  let mut idat_pos = -1
  while pos + 8 <= len {
    let type0 = png_data[pos + 4].to_int()
    let type1 = png_data[pos + 5].to_int()
    let type2 = png_data[pos + 6].to_int()
    let type3 = png_data[pos + 7].to_int()
    if type0 == 0x49 && type1 == 0x44 && type2 == 0x41 && type3 == 0x54 {
      idat_pos = pos
      break
    }
    let chunk_len = png_data[pos].to_int() * 16777216 +
      png_data[pos + 1].to_int() * 65536 +
      png_data[pos + 2].to_int() * 256 +
      png_data[pos + 3].to_int()
    pos = pos + 8 + chunk_len + 4
  }
  if idat_pos < 0 {
    raise @types.LoadError::EncodeFailed("PNG 中未找到 IDAT chunk")
  }
  // 构造 tEXt chunks
  let text_chunks : Array[Byte] = []
  for chunk in chunks {
    let payload : Array[Byte] = []
    for c in chunk.keyword.to_array() {
      let code = c.to_int()
      if code < 128 {
        payload.push(code.to_byte())
      }
    }
    payload.push(b'\x00')
    for c in chunk.text.to_array() {
      let code = c.to_int()
      if code < 128 {
        payload.push(code.to_byte())
      }
    }
    let chunk_bytes = png_build_chunk("tEXt", Bytes::from_array(payload))
    for b in chunk_bytes {
      text_chunks.push(b)
    }
  }
  // 拼接：PNG header + existing chunks before IDAT + new tEXt chunks + IDAT and rest
  let out : Array[Byte] = []
  for i in 0..<idat_pos {
    out.push(png_data[i])
  }
  for b in text_chunks {
    out.push(b)
  }
  for i in idat_pos..<len {
    out.push(png_data[i])
  }
  Bytes::from_array(out)
}

///|
/// 从 PNG eXIf chunk 读取 EXIF 数据
/// 返回原始 EXIF 字节（以 "MM" 或 "II" TIFF 头开头），不含 "Exif\0\0" 前缀
pub fn read_png_exif_from_bytes(data : Bytes) -> Bytes? {
  let len = data.length()
  if len < 8 ||
    data[0].to_int() != 0x89 ||
    data[1].to_int() != 0x50 ||
    data[2].to_int() != 0x4E ||
    data[3].to_int() != 0x47 {
    return None
  }
  let mut pos = 8
  while pos + 8 <= len {
    let chunk_len = data[pos].to_int() * 16777216 +
      data[pos + 1].to_int() * 65536 +
      data[pos + 2].to_int() * 256 +
      data[pos + 3].to_int()
    let type0 = data[pos + 4].to_int()
    let type1 = data[pos + 5].to_int()
    let type2 = data[pos + 6].to_int()
    let type3 = data[pos + 7].to_int()
    let data_start = pos + 8
    if data_start + chunk_len > len {
      break
    }
    // eXIf: type = 0x65 0x58 0x49 0x66
    if type0 == 0x65 && type1 == 0x58 && type2 == 0x49 && type3 == 0x66 {
      let exif : Array[Byte] = []
      for i in 0..<chunk_len {
        exif.push(data[data_start + i])
      }
      return Some(Bytes::from_array(exif))
    }
    // IEND
    if type0 == 0x49 && type1 == 0x45 && type2 == 0x4E && type3 == 0x44 {
      break
    }
    pos = data_start + chunk_len + 4
  }
  None
}

///|
/// 将 EXIF 数据写入 PNG eXIf chunk（在 IDAT 前插入）
/// exif_data 应以 "MM" 或 "II" TIFF 头开头
pub fn write_png_exif_to_bytes(
  exif_data : Bytes,
  png_data : Bytes,
) -> Bytes raise @types.LoadError {
  let len = png_data.length()
  if len < 8 ||
    png_data[0].to_int() != 0x89 ||
    png_data[1].to_int() != 0x50 ||
    png_data[2].to_int() != 0x4E ||
    png_data[3].to_int() != 0x47 {
    raise @types.LoadError::EncodeFailed("输入不是有效 PNG")
  }
  // 查找 IDAT chunk 位置
  let mut pos = 8
  let mut idat_pos = -1
  while pos + 8 <= len {
    let type0 = png_data[pos + 4].to_int()
    let type1 = png_data[pos + 5].to_int()
    let type2 = png_data[pos + 6].to_int()
    let type3 = png_data[pos + 7].to_int()
    if type0 == 0x49 && type1 == 0x44 && type2 == 0x41 && type3 == 0x54 {
      idat_pos = pos
      break
    }
    let chunk_len = png_data[pos].to_int() * 16777216 +
      png_data[pos + 1].to_int() * 65536 +
      png_data[pos + 2].to_int() * 256 +
      png_data[pos + 3].to_int()
    pos = pos + 8 + chunk_len + 4
  }
  if idat_pos < 0 {
    raise @types.LoadError::EncodeFailed("PNG 中未找到 IDAT chunk")
  }
  let exif_chunk = png_build_chunk("eXIf", exif_data)
  let out : Array[Byte] = []
  for i in 0..<idat_pos {
    out.push(png_data[i])
  }
  for b in exif_chunk {
    out.push(b)
  }
  for i in idat_pos..<len {
    out.push(png_data[i])
  }
  Bytes::from_array(out)
}
