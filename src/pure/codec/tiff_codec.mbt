// 纯 MoonBit TIFF 编解码（全目标可用：native/wasm/js）
// 仅支持无压缩 (Compression=1) TIFF
// 支持 8-bit 灰度、8-bit RGB、8-bit RGBA
// 规范: https://www.itu.int/rec/dologin.asp?lang=e&id=T-81-199303-I!!1-E

///|
/// TIFF IFD 条目
priv struct TiffIfdEntry {
  tag : Int
  type_id : Int
  count : Int
  value_or_offset : Int
}

///|
/// TIFF 解析上下文
priv struct TiffContext {
  data : Bytes
  little_endian : Bool
}

///|
/// 读取 16-bit 值（根据字节序）
fn tiff_read_u16(ctx : TiffContext, offset : Int) -> Int {
  if ctx.little_endian {
    read_u16_le(ctx.data, offset)
  } else {
    read_u16_be(ctx.data, offset)
  }
}

///|
/// 读取 32-bit 值（根据字节序）
fn tiff_read_u32(ctx : TiffContext, offset : Int) -> Int {
  if ctx.little_endian {
    read_u32_le(ctx.data, offset)
  } else {
    read_u32_be(ctx.data, offset)
  }
}

///|
/// 根据 type_id 和 count 计算 IFD 条目值的字节数
fn tiff_type_size(type_id : Int) -> Int {
  match type_id {
    1 => 1 // BYTE
    2 => 1 // ASCII
    3 => 2 // SHORT
    4 => 4 // LONG
    5 => 8 // RATIONAL
    6 => 1 // SBYTE
    7 => 1 // UNDEFINED
    8 => 2 // SSHORT
    9 => 4 // SLONG
    10 => 8 // SRATIONAL
    11 => 4 // FLOAT
    12 => 8 // DOUBLE
    _ => 0
  }
}

///|
/// 读取 IFD 条目的数值数组（当值超过 4 字节时从偏移处读取）
fn tiff_read_values(ctx : TiffContext, entry : TiffIfdEntry) -> Array[Int] {
  let total_bytes = tiff_type_size(entry.type_id) * entry.count
  let values : Array[Int] = []
  if total_bytes <= 4 {
    // 值内联在 value_or_offset 中
    let v = entry.value_or_offset
    match entry.type_id {
      1 | 7 =>
        for i in 0..<entry.count {
          values.push((v >> (i * 8)) & 0xFF)
        }
      3 =>
        for i in 0..<entry.count {
          values.push((v >> (i * 16)) & 0xFFFF)
        }
      4 => values.push(v)
      _ =>
        for _ in 0..<entry.count {
          values.push(0)
        }
    }
  } else {
    // 值在偏移处
    let base = entry.value_or_offset
    let len = ctx.data.length()
    match entry.type_id {
      1 | 7 =>
        for i in 0..<entry.count {
          if base + i < len {
            values.push(ctx.data[base + i].to_int())
          } else {
            values.push(0)
          }
        }
      3 =>
        for i in 0..<entry.count {
          values.push(tiff_read_u16(ctx, base + i * 2))
        }
      4 =>
        for i in 0..<entry.count {
          values.push(tiff_read_u32(ctx, base + i * 4))
        }
      _ =>
        for _ in 0..<entry.count {
          values.push(0)
        }
    }
  }
  values
}

///|
/// 解析 IFD 条目
fn tiff_parse_ifd(
  ctx : TiffContext,
  ifd_offset : Int,
) -> Array[TiffIfdEntry] raise @types.LoadError {
  let len = ctx.data.length()
  if ifd_offset + 2 > len {
    raise @types.LoadError::DecodeFailed("TIFF IFD 偏移越界")
  }
  let count = tiff_read_u16(ctx, ifd_offset)
  if ifd_offset + 2 + count * 12 > len {
    raise @types.LoadError::DecodeFailed("TIFF IFD 条目数据不完整")
  }
  let entries : Array[TiffIfdEntry] = []
  for i in 0..<count {
    let base = ifd_offset + 2 + i * 12
    let tag = tiff_read_u16(ctx, base)
    let type_id = tiff_read_u16(ctx, base + 2)
    let cnt = tiff_read_u32(ctx, base + 4)
    let val_or_off = tiff_read_u32(ctx, base + 8)
    entries.push(TiffIfdEntry::{
      tag,
      type_id,
      count: cnt,
      value_or_offset: val_or_off,
    })
  }
  entries
}

///|
/// 在 IFD 条目中查找指定 tag 的值数组
fn tiff_get_values(
  entries : Array[TiffIfdEntry],
  ctx : TiffContext,
  tag : Int,
) -> Array[Int]? {
  for i in 0..<entries.length() {
    if entries[i].tag == tag {
      return Some(tiff_read_values(ctx, entries[i]))
    }
  }
  None
}

///|
/// 在 IFD 条目中查找指定 tag 的单个值
fn tiff_get_value(
  entries : Array[TiffIfdEntry],
  ctx : TiffContext,
  tag : Int,
) -> Int? {
  match tiff_get_values(entries, ctx, tag) {
    Some(arr) => if arr.length() > 0 { Some(arr[0]) } else { None }
    None => None
  }
}

///|
/// 解码 TIFF 字节流为 Image
/// 仅支持无压缩 (Compression=1) 8-bit 灰度/RGB/RGBA
pub fn decode_tiff_pure(data : Bytes) -> @types.Image raise @types.LoadError {
  let len = data.length()
  if len < 8 {
    raise @types.LoadError::DecodeFailed("TIFF 数据过短")
  }
  // 检查字节序
  let little_endian = match data[0].to_int() {
    0x49 => true // 'I' = little-endian
    0x4D => false // 'M' = big-endian
    _ => raise @types.LoadError::DecodeFailed("TIFF 字节序标记无效")
  }
  let ctx = TiffContext::{ data, little_endian }
  // 检查 magic 42
  let magic = tiff_read_u16(ctx, 2)
  if magic != 42 {
    raise @types.LoadError::DecodeFailed("TIFF magic 无效")
  }
  let ifd_offset = tiff_read_u32(ctx, 4)
  if ifd_offset < 0 || ifd_offset >= len {
    raise @types.LoadError::DecodeFailed("TIFF IFD 偏移无效")
  }
  let entries = tiff_parse_ifd(ctx, ifd_offset)
  // 读取必要字段
  let width = match tiff_get_value(entries, ctx, 256) {
    Some(w) => w
    None => raise @types.LoadError::DecodeFailed("TIFF 缺少 ImageWidth")
  }
  let height = match tiff_get_value(entries, ctx, 257) {
    Some(h) => h
    None => raise @types.LoadError::DecodeFailed("TIFF 缺少 ImageLength")
  }
  let bits_per_sample = match tiff_get_values(entries, ctx, 258) {
    Some(arr) => arr
    None => [8]
  }
  let compression = match tiff_get_value(entries, ctx, 259) {
    Some(c) => c
    None => 1
  }
  let photometric = match tiff_get_value(entries, ctx, 262) {
    Some(p) => p
    None => 1
  }
  let samples_per_pixel = match tiff_get_value(entries, ctx, 277) {
    Some(s) => s
    None => 1
  }
  let strip_offsets = match tiff_get_values(entries, ctx, 273) {
    Some(arr) => arr
    None => raise @types.LoadError::DecodeFailed("TIFF 缺少 StripOffsets")
  }
  let rows_per_strip = match tiff_get_value(entries, ctx, 278) {
    Some(r) => r
    None => height
  }
  let _ = match tiff_get_values(entries, ctx, 279) {
    Some(arr) => arr
    None => []
  }
  // 仅支持无压缩
  if compression != 1 {
    raise @types.LoadError::DecodeFailed(
      "TIFF 仅支持无压缩 (Compression=1)",
    )
  }
  // 仅支持 8-bit
  for i in 0..<bits_per_sample.length() {
    if bits_per_sample[i] != 8 {
      raise @types.LoadError::DecodeFailed("TIFF 仅支持 8-bit 样本")
    }
  }
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed("TIFF 尺寸无效")
  }
  // 确定输出 channels
  let out_channels = samples_per_pixel
  if out_channels != 1 && out_channels != 3 && out_channels != 4 {
    raise @types.LoadError::DecodeFailed(
      "TIFF 仅支持 1/3/4 samples per pixel",
    )
  }
  // 读取像素数据
  let pixel_count = width * height
  let pixels : Array[Byte] = Array::make(pixel_count * out_channels, b'\x00')
  let bytes_per_pixel = out_channels
  let mut row = 0
  for strip_idx in 0..<strip_offsets.length() {
    if row >= height {
      break
    }
    let strip_offset = strip_offsets[strip_idx]
    let rows_in_strip = if row + rows_per_strip > height {
      height - row
    } else {
      rows_per_strip
    }
    for r in 0..<rows_in_strip {
      let y = row + r
      let row_start = strip_offset + r * width * bytes_per_pixel
      for x in 0..<width {
        let src = row_start + x * bytes_per_pixel
        let dst = (y * width + x) * out_channels
        if src + bytes_per_pixel > len {
          raise @types.LoadError::DecodeFailed("TIFF 像素数据越界")
        }
        if out_channels == 1 {
          // 灰度
          let g = ctx.data[src].to_int()
          let val = if photometric == 0 { 255 - g } else { g }
          pixels[dst] = val.to_byte()
          // RGB 或 RGBA
        } else if photometric == 2 {
          // RGB
          pixels[dst] = ctx.data[src]
          pixels[dst + 1] = ctx.data[src + 1]
          pixels[dst + 2] = ctx.data[src + 2]
          if out_channels == 4 {
            pixels[dst + 3] = b'\xFF'
          }
        } else if photometric == 0 || photometric == 1 {
          // 灰度存储为多通道（不常见，但处理之）
          let g = ctx.data[src].to_int()
          let val = if photometric == 0 { 255 - g } else { g }
          pixels[dst] = val.to_byte()
          pixels[dst + 1] = val.to_byte()
          pixels[dst + 2] = val.to_byte()
          if out_channels == 4 {
            pixels[dst + 3] = b'\xFF'
          }
        } else {
          raise @types.LoadError::DecodeFailed(
            "TIFF 不支持的 PhotometricInterpretation",
          )
        }
      }
    }
    row += rows_in_strip
  }
  @types.Image::{
    width,
    height,
    channels: out_channels,
    data: Bytes::from_array(pixels),
  }
}

///|
/// 将 Image 编码为无压缩 TIFF 字节流（小端序）
/// 支持 1/3/4 channels
pub fn encode_tiff_pure(img : @types.Image) -> Bytes raise @types.LoadError {
  let width = img.width
  let height = img.height
  let channels = img.channels
  let data = img.data
  if channels != 1 && channels != 3 && channels != 4 {
    raise @types.LoadError::EncodeFailed(
      "TIFF 编码需要 channels 为 1 (灰度)、3 (RGB) 或 4 (RGBA)",
    )
  }
  let out : Array[Byte] = []
  // TIFF Header (8 bytes)
  out.push(b'\x49') // 'I' little-endian
  out.push(b'\x49') // 'I'
  write_u16_le(out, 42) // magic
  write_u32_le(out, 8) // IFD offset (immediately after header)
  // IFD: count(2) + entries(12 each) + next IFD offset(4)
  // 需要的 tags:
  // 256 ImageWidth, 257 ImageLength, 258 BitsPerSample,
  // 259 Compression, 262 Photometric, 273 StripOffsets,
  // 277 SamplesPerPixel, 278 RowsPerStrip, 279 StripByteCounts
  let num_entries = 9
  let ifd_size = 2 + num_entries * 12 + 4
  // BitsPerSample 可能需要外部存储（如果 channels > 1，3个SHORT=6字节 > 4字节）
  let bps_offset = 8 + ifd_size
  let bps_external = channels > 1
  let bps_bytes = if bps_external { 6 } else { 0 } // 3 SHORTs for RGB, 4 SHORTs for RGBA
  let bps_actual = if channels == 4 { 8 } else { bps_bytes }
  // 像素数据偏移
  let pixel_offset = bps_offset + bps_actual
  let pixel_size = width * height * channels
  // 写入 IFD
  write_u16_le(out, num_entries)
  // 辅助函数：写入 IFD 条目
  let write_entry = fn(
    tag : Int,
    type_id : Int,
    count : Int,
    value : Int,
  ) -> Unit {
    write_u16_le(out, tag)
    write_u16_le(out, type_id)
    write_u32_le(out, count)
    write_u32_le(out, value)
  }
  // 256: ImageWidth (LONG)
  write_entry(256, 4, 1, width)
  // 257: ImageLength (LONG)
  write_entry(257, 4, 1, height)
  // 258: BitsPerSample (SHORT)
  if bps_external {
    // 值在外部存储
    write_entry(258, 3, channels, bps_offset)
  } else {
    // 单通道，值内联
    write_entry(258, 3, 1, 8)
  }
  // 259: Compression (SHORT) = 1 (无压缩)
  write_entry(259, 3, 1, 1)
  // 262: PhotometricInterpretation (SHORT)
  let photometric = if channels == 1 { 1 } else { 2 } // 1=BlackIsZero, 2=RGB
  write_entry(262, 3, 1, photometric)
  // 273: StripOffsets (LONG)
  write_entry(273, 4, 1, pixel_offset)
  // 277: SamplesPerPixel (SHORT)
  write_entry(277, 3, 1, channels)
  // 278: RowsPerStrip (LONG)
  write_entry(278, 4, 1, height)
  // 279: StripByteCounts (LONG)
  write_entry(279, 4, 1, pixel_size)
  // Next IFD offset = 0 (无更多 IFD)
  write_u32_le(out, 0)
  // BitsPerSample 外部数据
  if bps_external {
    for _ in 0..<channels {
      write_u16_le(out, 8)
    }
  }
  // 像素数据
  for y in 0..<height {
    for x in 0..<width {
      let idx = (y * width + x) * channels
      if channels == 1 {
        out.push(data[idx])
      } else {
        // RGB 或 RGBA，TIFF 存储为 RGB(A)
        out.push(data[idx])
        out.push(data[idx + 1])
        out.push(data[idx + 2])
        if channels == 4 {
          out.push(data[idx + 3])
        }
      }
    }
  }
  Bytes::from_array(out)
}
