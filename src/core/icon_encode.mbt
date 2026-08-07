// ICO/ICNS 图标容器编码（纯 MoonBit）
// ICO: Windows 图标格式，使用 PNG payload
// ICNS: macOS 图标格式

fn write_u16_le(out : Array[Byte], val : Int) -> Unit {
  out.push((val & 0xFF).to_byte())
  out.push(((val >> 8) & 0xFF).to_byte())
}

fn write_u32_le(out : Array[Byte], val : Int) -> Unit {
  out.push((val & 0xFF).to_byte())
  out.push(((val >> 8) & 0xFF).to_byte())
  out.push(((val >> 16) & 0xFF).to_byte())
  out.push(((val >> 24) & 0xFF).to_byte())
}

fn write_u32_be(out : Array[Byte], val : Int) -> Unit {
  out.push(((val >> 24) & 0xFF).to_byte())
  out.push(((val >> 16) & 0xFF).to_byte())
  out.push(((val >> 8) & 0xFF).to_byte())
  out.push((val & 0xFF).to_byte())
}

///|
/// 将单个 Image 编码为 ICO 字节流（PNG payload）
/// 图像尺寸应 <= 256，channels 应为 3 或 4
pub fn encode_ico(img : Image) -> Bytes raise LoadError {
  if img.width > 256 || img.height > 256 {
    raise LoadError::DecodeFailed("ICO 图像尺寸不能超过 256x256")
  }
  let png_data = write_png_to_bytes(img)
  let out : Array[Byte] = []
  // ICO header (6 bytes)
  write_u16_le(out, 0)    // reserved
  write_u16_le(out, 1)    // type = 1 (ICO)
  write_u16_le(out, 1)    // count = 1
  // Directory entry (16 bytes)
  let w_byte = if img.width == 256 { 0 } else { img.width }
  let h_byte = if img.height == 256 { 0 } else { img.height }
  out.push(w_byte.to_byte())  // width
  out.push(h_byte.to_byte())  // height
  out.push(b'\x00')           // colors (0 = true color)
  out.push(b'\x00')           // reserved
  write_u16_le(out, 1)        // planes
  write_u16_le(out, 32)       // bit count
  write_u32_le(out, png_data.length())  // size
  write_u32_le(out, 22)       // offset (6 + 16 = 22)
  // PNG data
  for i in 0..<png_data.length() {
    out.push(png_data[i])
  }
  Bytes::from_array(out)
}

///|
/// 将多个尺寸的 Image 编码为多尺寸 ICO 字节流
pub fn encode_ico_sizes(images : Array[Image]) -> Bytes raise LoadError {
  if images.length() == 0 {
    raise LoadError::DecodeFailed("至少需要一张图像")
  }
  let png_list : Array[Bytes] = []
  let total_size = Ref(0)
  for img in images {
    if img.width > 256 || img.height > 256 {
      raise LoadError::DecodeFailed("ICO 图像尺寸不能超过 256x256")
    }
    let png = write_png_to_bytes(img)
    png_list.push(png)
    total_size.val += png.length()
  }
  let out : Array[Byte] = []
  let count = images.length()
  let header_size = 6 + count * 16
  // ICO header
  write_u16_le(out, 0)
  write_u16_le(out, 1)
  write_u16_le(out, count)
  // Directory entries
  let offset = Ref(header_size)
  for i in 0..<count {
    let img = images[i]
    let png = png_list[i]
    let w_byte = if img.width == 256 { 0 } else { img.width }
    let h_byte = if img.height == 256 { 0 } else { img.height }
    out.push(w_byte.to_byte())
    out.push(h_byte.to_byte())
    out.push(b'\x00')
    out.push(b'\x00')
    write_u16_le(out, 1)
    write_u16_le(out, 32)
    write_u32_le(out, png.length())
    write_u32_le(out, offset.val)
    offset.val += png.length()
  }
  // PNG data
  for i in 0..<count {
    let png = png_list[i]
    for j in 0..<png.length() {
      out.push(png[j])
    }
  }
  let _ = total_size
  Bytes::from_array(out)
}

// ICNS 图标类型码 (OSType) 与尺寸映射
// 参考: https://en.wikipedia.org/wiki/Apple_Icon_Image_format
fn icns_type_for_size(size : Int, has_alpha : Bool) -> String? {
  match (size, has_alpha) {
    (16, true) => Some("icp4")
    (32, true) => Some("icp5")
    (64, true) => Some("icp6")
    (128, true) => Some("ic07")
    (256, true) => Some("ic08")
    (512, true) => Some("ic09")
    (1024, true) => Some("ic10")
    (16, false) => Some("is32")
    (32, false) => Some("il32")
    (128, false) => Some("ih32")
    (256, false) => Some("ih24")
    _ => None
  }
}

///|
/// 将 Image 编码为 ICNS 字节流（PNG payload）
/// 图像应为正方形，尺寸为 16/32/64/128/256/512/1024 之一
pub fn encode_icns(img : Image) -> Bytes raise LoadError {
  if img.width != img.height {
    raise LoadError::DecodeFailed("ICNS 图像必须为正方形")
  }
  let has_alpha = img.channels == 4
  let type_code = icns_type_for_size(img.width, has_alpha)
  let type_str = match type_code {
    Some(s) => s
    None => raise LoadError::DecodeFailed("不支持的 ICNS 尺寸: \{img.width}")
  }
  let png_data = write_png_to_bytes(img)
  let icon_data_size = 8 + png_data.length()
  let file_size = 8 + icon_data_size
  let out : Array[Byte] = []
  // ICNS header
  out.push(b'\x69') // i
  out.push(b'\x63') // c
  out.push(b'\x6E') // n
  out.push(b'\x73') // s
  write_u32_be(out, file_size)
  // Icon entry
  let type_bytes = @encoding/utf8.encode(type_str)
  for i in 0..<type_bytes.length() {
    out.push(type_bytes[i])
  }
  write_u32_be(out, icon_data_size)
  // PNG data
  for i in 0..<png_data.length() {
    out.push(png_data[i])
  }
  Bytes::from_array(out)
}