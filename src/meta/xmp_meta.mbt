// v249.0.0 XMP 元数据解析与写入
// XMP 基于 XML，嵌入在 JPEG APP1 段中（以 "http://ns.adobe.com/xap/1.0/\0" 开头）
// 纯 MoonBit 实现，无外部 XML 库依赖

///|
/// XMP 元数据（常用字段）
pub(all) struct XmpInfo {
  creator : String
  title : String
  description : String
  subject : String
  keywords : String
  rights : String
  create_date : String
  modify_date : String
  software : String
  rating : Int
  raw_xml : String
} derive(Eq, @debug.Debug)

///|
pub extend XmpInfo with Eq::{not_equal, equal}

///|
pub extend XmpInfo with @debug.Debug::{to_repr}

///|
/// XMP namespace URI
fn xmp_namespace_uri() -> String {
  "http://ns.adobe.com/xap/1.0/"
}

///|
/// 从字节中提取 ASCII 字符串（到 \0 或指定长度）
fn xmp_extract_string(data : Bytes, start : Int, max_len : Int) -> String {
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
/// 在字符串中查找子串，返回起始位置或 -1
fn xmp_str_find(haystack : String, needle : String) -> Int {
  let h = haystack.to_array()
  let n = needle.to_array()
  let hlen = h.length()
  let nlen = n.length()
  if nlen == 0 {
    return 0
  }
  if nlen > hlen {
    return -1
  }
  let end = hlen - nlen
  for i in 0..<=end {
    let mut found = true
    for j in 0..<nlen {
      if h[i + j] != n[j] {
        found = false
        break
      }
    }
    if found {
      return i
    }
  }
  -1
}

///|
/// 在 XML 中提取标签内容（简单解析，非完整 XML 解析器）
fn xmp_extract_tag(xml : String, tag : String) -> String {
  let open_tag = "<" + tag + ">"
  let close_tag = "</" + tag + ">"
  let open_idx = xmp_str_find(xml, open_tag)
  if open_idx < 0 {
    return ""
  }
  let content_start = open_idx + open_tag.length()
  let close_idx = xmp_str_find(xml[content_start:].to_owned(), close_tag)
  if close_idx < 0 {
    return ""
  }
  xml[content_start:content_start + close_idx].to_owned()
}

///|
/// 在 XML 中提取属性值
fn xmp_extract_attr(xml : String, tag : String, attr : String) -> String {
  let search = tag + " " + attr + "=\""
  let idx = xmp_str_find(xml, search)
  if idx < 0 {
    return ""
  }
  let val_start = idx + search.length()
  let rest = xml[val_start:].to_owned()
  let end = xmp_str_find(rest, "\"")
  if end < 0 {
    return ""
  }
  rest[:end].to_owned()
}

///|
/// 简单整数解析（支持正负号）
fn xmp_parse_int(s : String) -> Int? {
  if s.length() == 0 {
    return None
  }
  let chars = s.to_array()
  let mut idx = 0
  let mut neg = false
  if chars[0].to_int() == 0x2D {
    neg = true
    idx = 1
  } else if chars[0].to_int() == 0x2B {
    idx = 1
  }
  if idx >= chars.length() {
    return None
  }
  let mut result = 0
  while idx < chars.length() {
    let c = chars[idx].to_int()
    if c < 0x30 || c > 0x39 {
      return None
    }
    result = result * 10 + (c - 0x30)
    idx += 1
  }
  if neg {
    Some(-result)
  } else {
    Some(result)
  }
}

///|
/// 从 JPEG 字节流读取 XMP 元数据
/// 返回 None 如果不含 XMP 数据
pub fn read_xmp_from_bytes(data : Bytes) -> XmpInfo? {
  let len = data.length()
  if len < 4 || data[0].to_int() != 0xFF || data[1].to_int() != 0xD8 {
    return None
  }
  // 查找 APP1 marker with XMP namespace
  let mut pos = 2
  let mut xmp_start = -1
  let mut xmp_len = 0
  while pos < len - 1 {
    if data[pos].to_int() == 0xFF && data[pos + 1].to_int() == 0xE1 {
      let seg_len = data[pos + 2].to_int() * 256 + data[pos + 3].to_int() - 2
      let ns_start = pos + 4
      let ns = xmp_extract_string(data, ns_start, 29)
      if ns == xmp_namespace_uri() {
        xmp_start = ns_start + 29
        xmp_len = seg_len - 29
        break
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
  if xmp_start < 0 || xmp_start + xmp_len > len {
    return None
  }
  let xml = xmp_extract_string(data, xmp_start, xmp_len)
  let creator = xmp_extract_tag(xml, "dc:creator")
  let title = xmp_extract_tag(xml, "dc:title")
  let description = xmp_extract_tag(xml, "dc:description")
  let subject = xmp_extract_tag(xml, "dc:subject")
  let keywords = xmp_extract_tag(xml, "lr:hierarchicalSubject")
  let rights = xmp_extract_tag(xml, "dc:rights")
  let create_date = xmp_extract_attr(xml, "xmp:CreateDate", "xmp:CreateDate")
  let modify_date = xmp_extract_attr(xml, "xmp:ModifyDate", "xmp:ModifyDate")
  let software = xmp_extract_tag(xml, "xmp:CreatorTool")
  let rating_str = xmp_extract_tag(xml, "xmp:Rating")
  let rating = match xmp_parse_int(rating_str) {
    Some(n) => n
    None => 0
  }
  Some(XmpInfo::{
    creator,
    title,
    description,
    subject,
    keywords,
    rights,
    create_date,
    modify_date,
    software,
    rating,
    raw_xml: xml,
  })
}

///|
/// 构造 XMP APP1 段数据（不含 FF E1 前缀和长度）
pub fn create_xmp_segment(info : XmpInfo) -> Bytes {
  let ns = xmp_namespace_uri()
  let xml_parts : Array[String] = []
  xml_parts.push("<?xpacket begin='' id='W5M0MpCehiHzreSzNTczkc9d'?>")
  xml_parts.push("<x:xmpmeta xmlns:x='adobe:ns:meta/'>")
  xml_parts.push(
    "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>",
  )
  xml_parts.push("<rdf:Description rdf:about=''")
  if info.creator.length() > 0 {
    xml_parts.push(" xmlns:dc='http://purl.org/dc/elements/1.1/'")
  }
  if info.software.length() > 0 {
    xml_parts.push(" xmlns:xmp='http://ns.adobe.com/xap/1.0/'>")
  } else {
    xml_parts.push(">")
  }
  if info.title.length() > 0 {
    xml_parts.push("<dc:title>" + info.title + "</dc:title>")
  }
  if info.creator.length() > 0 {
    xml_parts.push("<dc:creator>" + info.creator + "</dc:creator>")
  }
  if info.description.length() > 0 {
    xml_parts.push("<dc:description>" + info.description + "</dc:description>")
  }
  if info.rights.length() > 0 {
    xml_parts.push("<dc:rights>" + info.rights + "</dc:rights>")
  }
  if info.software.length() > 0 {
    xml_parts.push("<xmp:CreatorTool>" + info.software + "</xmp:CreatorTool>")
  }
  if info.rating > 0 {
    xml_parts.push("<xmp:Rating>" + info.rating.to_string() + "</xmp:Rating>")
  }
  xml_parts.push("</rdf:Description>")
  xml_parts.push("</rdf:RDF>")
  xml_parts.push("</x:xmpmeta>")
  xml_parts.push("<?xpacket end='w'?>")
  let mut xml = ""
  for part in xml_parts {
    xml = xml + part
  }
  let out : Array[Byte] = []
  for c in ns.to_array() {
    let code = c.to_int()
    if code < 128 {
      out.push(code.to_byte())
    } else {
      out.push(b'?')
    }
  }
  out.push(b'\x00')
  for c in xml.to_array() {
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
/// 将 XMP 写入 JPEG（在 SOI 后插入 APP1，已有则替换）
pub fn write_xmp_to_bytes(
  info : XmpInfo,
  jpeg_data : Bytes,
) -> Bytes raise @types.LoadError {
  let len = jpeg_data.length()
  if len < 4 || jpeg_data[0].to_int() != 0xFF || jpeg_data[1].to_int() != 0xD8 {
    raise @types.LoadError::EncodeFailed("输入不是有效 JPEG")
  }
  let xmp_payload = create_xmp_segment(info)
  let xmp_seg_len = xmp_payload.length() + 2
  let xmp_seg : Array[Byte] = [
    0xFF,
    0xE1,
    (xmp_seg_len >> 8).to_byte(),
    (xmp_seg_len & 0xFF).to_byte(),
  ]
  for b in xmp_payload {
    xmp_seg.push(b)
  }
  // 查找并跳过已有 XMP APP1
  let mut pos = 2
  let mut insert_pos = 2
  while pos < len - 1 {
    if jpeg_data[pos].to_int() == 0xFF && jpeg_data[pos + 1].to_int() == 0xE1 {
      let seg_len = jpeg_data[pos + 2].to_int() * 256 +
        jpeg_data[pos + 3].to_int()
      let ns = xmp_extract_string(jpeg_data, pos + 4, 29)
      if ns == xmp_namespace_uri() {
        insert_pos = pos
        break
      }
      pos += 2 + seg_len
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
  for b in xmp_seg {
    out.push(b)
  }
  for i in insert_pos..<len {
    out.push(jpeg_data[i])
  }
  Bytes::from_array(out)
}
