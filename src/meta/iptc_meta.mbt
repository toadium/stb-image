// v250.0.0 IPTC IIM 元数据解析与写入
// IPTC IIM (Information Interchange Model) 存储在 JPEG APP13 段中
// 以 "Photoshop 3.0\0" + "8BIM\x04\x04" 开头，后跟记录序列

///|
/// IPTC IIM 元数据（常用字段）
pub(all) struct IptcInfo {
  title : String
  keywords : String
  creator : String
  creator_title : String
  city : String
  country : String
  caption : String
  caption_writer : String
  date_created : String
  category : String
  urgency : Int32
  raw_records : Array[(Int32, Int32, String)]
} derive(Eq, @debug.Debug)

///|
pub extend IptcInfo with Eq::{not_equal, equal}

///|
pub extend IptcInfo with @debug.Debug::{to_repr}

///|
/// Photoshop 3.0 header
fn iptc_photoshop_header() -> String {
  "Photoshop 3.0"
}

///|
/// 从字节提取 ASCII 字符串
fn iptc_extract_string(data : Bytes, start : Int32, max_len : Int32) -> String {
  let chars : Array[Byte] = []
  let len = data.length()
  for i in 0..<max_len {
    if start + i >= len {
      break
    }
    let b = data[start + i]
    if b == b'\x00' {
      break
    }
    chars.push(b)
  }
  @encoding/utf8.decode(Bytes::from_array(chars)[:]) catch {
    _ => ""
  }
}

///|
/// 从 JPEG 字节流读取 IPTC IIM 元数据
/// 返回 None 如果不含 IPTC 数据
pub fn read_iptc_from_bytes(data : Bytes) -> IptcInfo? {
  let len = data.length()
  if len < 4 || data[0].to_int() != 0xFF || data[1].to_int() != 0xD8 {
    return None
  }
  // 查找 APP13 marker with Photoshop 3.0 header
  let mut pos = 2
  let mut iptc_start = -1
  let mut iptc_len = 0
  while pos < len - 1 {
    if data[pos].to_int() == 0xFF && data[pos + 1].to_int() == 0xED {
      let seg_len = data[pos + 2].to_int() * 256 + data[pos + 3].to_int() - 2
      let header = iptc_extract_string(data, pos + 4, 14)
      if header == iptc_photoshop_header() {
        // 跳过 "Photoshop 3.0\0" (14 bytes) + "8BIM" (4) + 0x04 0x04 (2) + length(4)
        let bim_start = pos + 4 + 14
        if bim_start + 10 < pos + 4 + seg_len {
          // Check "8BIM"
          if data[bim_start].to_int() == 0x38 &&
            data[bim_start + 1].to_int() == 0x42 &&
            data[bim_start + 2].to_int() == 0x49 &&
            data[bim_start + 3].to_int() == 0x4D {
            // Check resource type 0x0404 (IPTC IIM)
            if data[bim_start + 4].to_int() == 0x04 &&
              data[bim_start + 5].to_int() == 0x04 {
              let iptc_data_len = data[bim_start + 6].to_int() * 16777216 +
                data[bim_start + 7].to_int() * 65536 +
                data[bim_start + 8].to_int() * 256 +
                data[bim_start + 9].to_int()
              iptc_start = bim_start + 10
              iptc_len = iptc_data_len
              break
            }
          }
        }
      }
      pos += 2 + seg_len + 2
    } else if data[pos].to_int() == 0xFF {
      let marker = data[pos + 1].to_int()
      if marker == 0xDA || marker == 0xD9 {
        break
      }
      let seg_len = data[pos + 2].to_int() * 256 + data[pos + 3].to_int()
      pos += 2 + seg_len
    } else {
      pos += 1
    }
  }
  if iptc_start < 0 || iptc_start + iptc_len > len {
    return None
  }
  // 解析 IPTC 记录
  let mut title = ""
  let mut keywords = ""
  let mut creator = ""
  let mut creator_title = ""
  let mut city = ""
  let mut country = ""
  let mut caption = ""
  let mut caption_writer = ""
  let mut date_created = ""
  let mut category = ""
  let mut urgency = 0
  let raw_records : Array[(Int32, Int32, String)] = []
  let mut rpos = iptc_start
  let rend = iptc_start + iptc_len
  while rpos + 5 <= rend {
    // 检查 tag marker 0x1C
    if data[rpos].to_int() != 0x1C {
      rpos += 1
      continue
    }
    let record_num = data[rpos + 1].to_int()
    let dataset_num = data[rpos + 2].to_int()
    let data_len = data[rpos + 3].to_int() * 256 + data[rpos + 4].to_int()
    let val_start = rpos + 5
    if val_start + data_len > rend {
      break
    }
    let val = iptc_extract_string(data, val_start, data_len)
    raw_records.push((record_num, dataset_num, val))
    match (record_num, dataset_num) {
      (2, 5) => title = val
      (2, 25) => keywords = val
      (2, 80) => creator = val
      (2, 85) => creator_title = val
      (2, 90) => city = val
      (2, 101) => country = val
      (2, 120) => caption = val
      (2, 122) => caption_writer = val
      (2, 55) => date_created = val
      (2, 15) => category = val
      (2, 10) =>
        match xmp_iptc_parse_urgency(val) {
          Some(n) => urgency = n
          None => ()
        }
      _ => ()
    }
    rpos = val_start + data_len
  }
  Some(IptcInfo::{
    title,
    keywords,
    creator,
    creator_title,
    city,
    country,
    caption,
    caption_writer,
    date_created,
    category,
    urgency,
    raw_records,
  })
}

///|
/// 简单整数解析（IPTC urgency 0-8）
fn xmp_iptc_parse_urgency(s : String) -> Int32? {
  if s.length() == 0 {
    return None
  }
  let chars = s.to_array()
  if chars.length() == 1 {
    let c = chars[0].to_int()
    if c >= 0x30 && c <= 0x39 {
      return Some(c - 0x30)
    }
  }
  None
}

///|
/// 构造 IPTC 记录字节
fn iptc_build_record(record : Int32, dataset : Int32, value : String) -> Bytes {
  let out : Array[Byte] = []
  out.push(0x1C)
  out.push(record.to_byte())
  out.push(dataset.to_byte())
  let vlen = value.length()
  out.push(((vlen >> 8) & 0xFF).to_byte())
  out.push((vlen & 0xFF).to_byte())
  for c in value.to_array() {
    let code = c.to_int()
    if code < 128 {
      out.push(code.to_byte())
    } else {
      out.push(b'?')
    }
  }
  Bytes::from_array(out)
}

///|
/// 构造 IPTC APP13 段数据（不含 FF ED 前缀和长度）
pub fn create_iptc_segment(info : IptcInfo) -> Bytes {
  // 构造 IPTC 记录
  let records : Array[Byte] = []
  if info.title.length() > 0 {
    let r = iptc_build_record(2, 5, info.title)
    for b in r {
      records.push(b)
    }
  }
  if info.keywords.length() > 0 {
    let r = iptc_build_record(2, 25, info.keywords)
    for b in r {
      records.push(b)
    }
  }
  if info.creator.length() > 0 {
    let r = iptc_build_record(2, 80, info.creator)
    for b in r {
      records.push(b)
    }
  }
  if info.creator_title.length() > 0 {
    let r = iptc_build_record(2, 85, info.creator_title)
    for b in r {
      records.push(b)
    }
  }
  if info.city.length() > 0 {
    let r = iptc_build_record(2, 90, info.city)
    for b in r {
      records.push(b)
    }
  }
  if info.country.length() > 0 {
    let r = iptc_build_record(2, 101, info.country)
    for b in r {
      records.push(b)
    }
  }
  if info.caption.length() > 0 {
    let r = iptc_build_record(2, 120, info.caption)
    for b in r {
      records.push(b)
    }
  }
  if info.caption_writer.length() > 0 {
    let r = iptc_build_record(2, 122, info.caption_writer)
    for b in r {
      records.push(b)
    }
  }
  if info.date_created.length() > 0 {
    let r = iptc_build_record(2, 55, info.date_created)
    for b in r {
      records.push(b)
    }
  }
  if info.category.length() > 0 {
    let r = iptc_build_record(2, 15, info.category)
    for b in r {
      records.push(b)
    }
  }
  if info.urgency > 0 && info.urgency <= 9 {
    let r = iptc_build_record(2, 10, info.urgency.to_string())
    for b in r {
      records.push(b)
    }
  }
  let iptc_data = Bytes::from_array(records)
  let iptc_data_len = iptc_data.length()
  // Photoshop 3.0\0 + 8BIM + 0x04 0x04 + 4-byte length + IPTC data
  let out : Array[Byte] = []
  let header = iptc_photoshop_header()
  for c in header.to_array() {
    out.push(c.to_int().to_byte())
  }
  out.push(b'\x00')
  out.push(0x38) // '8'
  out.push(0x42) // 'B'
  out.push(0x49) // 'I'
  out.push(0x4D) // 'M'
  out.push(0x04)
  out.push(0x04)
  out.push(((iptc_data_len >> 24) & 0xFF).to_byte())
  out.push(((iptc_data_len >> 16) & 0xFF).to_byte())
  out.push(((iptc_data_len >> 8) & 0xFF).to_byte())
  out.push((iptc_data_len & 0xFF).to_byte())
  for b in iptc_data {
    out.push(b)
  }
  Bytes::from_array(out)
}

///|
/// 将 IPTC 写入 JPEG（在 SOI 后插入 APP13，已有则替换）
pub fn write_iptc_to_bytes(
  info : IptcInfo,
  jpeg_data : Bytes,
) -> Bytes raise @types.LoadError {
  let len = jpeg_data.length()
  if len < 4 || jpeg_data[0].to_int() != 0xFF || jpeg_data[1].to_int() != 0xD8 {
    raise @types.LoadError::EncodeFailed("输入不是有效 JPEG")
  }
  let iptc_payload = create_iptc_segment(info)
  let iptc_seg_len = iptc_payload.length() + 2
  let iptc_seg : Array[Byte] = [
    0xFF,
    0xED,
    (iptc_seg_len >> 8).to_byte(),
    (iptc_seg_len & 0xFF).to_byte(),
  ]
  for b in iptc_payload {
    iptc_seg.push(b)
  }
  // 查找并跳过已有 IPTC APP13
  let mut pos = 2
  let mut insert_pos = 2
  while pos < len - 1 {
    if jpeg_data[pos].to_int() == 0xFF && jpeg_data[pos + 1].to_int() == 0xED {
      insert_pos = pos
      break
    } else if jpeg_data[pos].to_int() == 0xFF {
      let marker = jpeg_data[pos + 1].to_int()
      if marker == 0xDA || marker == 0xD9 {
        insert_pos = pos
        break
      }
      let seg_len = jpeg_data[pos + 2].to_int() * 256 +
        jpeg_data[pos + 3].to_int()
      pos += 2 + seg_len
    } else {
      pos += 1
    }
  }
  let out : Array[Byte] = []
  for i in 0..<insert_pos {
    out.push(jpeg_data[i])
  }
  for b in iptc_seg {
    out.push(b)
  }
  for i in insert_pos..<len {
    out.push(jpeg_data[i])
  }
  Bytes::from_array(out)
}
