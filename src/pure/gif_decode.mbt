// 纯 MoonBit GIF 解码器
// 支持 GIF89a/GIF87a 单帧解码（RGB，channels=3）
// 规范: GIF89a Specification + src/format/gif_encode.mbt

///|
fn read_u16_le_safe(data : Bytes, offset : Int, len : Int) -> Int raise @types.LoadError {
  if offset + 2 > len {
    raise @types.LoadError::DecodeFailed("GIF 数据过短：无法读取 2 字节 LE")
  }
  data[offset].to_int() | (data[offset + 1].to_int() << 8)
}

///|
/// LZW 解码（LSB 优先变长码）
/// 返回颜色索引序列
fn lzw_decode(data : Array[Byte], min_code_size : Int) -> Array[Int] raise @types.LoadError {
  let clear_code = 1 << min_code_size
  let end_code = clear_code + 1
  let mut code_width = min_code_size + 1
  let mut dict : Array[Array[Int]] = []
  for i in 0..<clear_code {
    dict.push([i])
  }
  dict.push([])
  dict.push([])
  let output : Array[Int] = []
  let mut bit_buffer = 0
  let mut bit_count = 0
  let mut data_pos = 0
  let mut prev : Int = -1
  let data_len = data.length()
  let mut done = false
  while !done {
    while bit_count < code_width {
      if data_pos >= data_len {
        done = true
        break
      }
      bit_buffer = bit_buffer | (data[data_pos].to_int() << bit_count)
      bit_count += 8
      data_pos += 1
    }
    if done {
      break
    }
    let code = bit_buffer & ((1 << code_width) - 1)
    bit_buffer = bit_buffer >> code_width
    bit_count -= code_width
    if code == clear_code {
      dict = []
      for i in 0..<clear_code {
        dict.push([i])
      }
      dict.push([])
      dict.push([])
      code_width = min_code_size + 1
      prev = -1
    } else if code == end_code {
      done = true
    } else {
      let entry : Array[Int] = if code < dict.length() {
        dict[code]
      } else if code == dict.length() && prev >= 0 {
        let prev_entry = dict[prev]
        let new_entry : Array[Int] = []
        for v in prev_entry {
          new_entry.push(v)
        }
        new_entry.push(prev_entry[0])
        new_entry
      } else {
        raise @types.LoadError::DecodeFailed(
          "GIF LZW 解码错误：code 超出字典范围",
        )
      }
      for v in entry {
        output.push(v)
      }
      if prev >= 0 {
        let prev_entry = dict[prev]
        let new_entry : Array[Int] = []
        for v in prev_entry {
          new_entry.push(v)
        }
        new_entry.push(entry[0])
        dict.push(new_entry)
        if dict.length() == (1 << code_width) && code_width < 12 {
          code_width += 1
        }
      }
      prev = code
    }
  }
  output
}

///|
/// 解码 GIF 字节流为 Image
/// 支持 GIF89a/GIF87a 单帧解码（RGB，channels=3）
/// 不支持 interlace（packed bit6=1 时 raise LoadError）
pub fn decode_gif_pure(data : Bytes) -> @types.Image raise @types.LoadError {
  let len = data.length()
  if len < 13 {
    raise @types.LoadError::DecodeFailed("GIF 数据过短：无法读取完整 header")
  }
  if data[0].to_int() != 0x47 ||
    data[1].to_int() != 0x49 ||
    data[2].to_int() != 0x46 ||
    data[3].to_int() != 0x38 ||
    (data[4].to_int() != 0x39 && data[4].to_int() != 0x37) ||
    data[5].to_int() != 0x61 {
    raise @types.LoadError::DecodeFailed(
      "GIF signature 错误，非 \"GIF87a\"/\"GIF89a\"",
    )
  }
  let _screen_width = read_u16_le_safe(data, 6, len)
  let _screen_height = read_u16_le_safe(data, 8, len)
  let packed = data[10].to_int()
  let has_gct = (packed & 0x80) != 0
  let gct_size = 1 << ((packed & 0x07) + 1)
  let mut pos = 13
  let gct : Array[(Int, Int, Int)] = []
  if has_gct {
    if pos + gct_size * 3 > len {
      raise @types.LoadError::DecodeFailed(
        "GIF 数据过短：无法读取 Global Color Table",
      )
    }
    for _ in 0..<gct_size {
      let r = data[pos].to_int()
      let g = data[pos + 1].to_int()
      let b = data[pos + 2].to_int()
      gct.push((r, g, b))
      pos += 3
    }
  }
  let mut found_image = false
  let mut img_width = 0
  let mut img_height = 0
  let mut lct : Array[(Int, Int, Int)] = []
  let mut lzw_min_code_size = 0
  let mut lzw_data : Array[Byte] = []
  while pos < len {
    let block_type = data[pos].to_int()
    pos += 1
    if block_type == 0x2C {
      found_image = true
      if pos + 9 > len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 Image Descriptor",
        )
      }
      let _left = read_u16_le_safe(data, pos, len)
      let _top = read_u16_le_safe(data, pos + 2, len)
      img_width = read_u16_le_safe(data, pos + 4, len)
      img_height = read_u16_le_safe(data, pos + 6, len)
      let img_packed = data[pos + 8].to_int()
      pos += 9
      let has_lct = (img_packed & 0x80) != 0
      let is_interlaced = (img_packed & 0x40) != 0
      let lct_size_val = 1 << ((img_packed & 0x07) + 1)
      if is_interlaced {
        raise @types.LoadError::DecodeFailed("GIF interlace 不支持")
      }
      lct = []
      if has_lct {
        if pos + lct_size_val * 3 > len {
          raise @types.LoadError::DecodeFailed(
            "GIF 数据过短：无法读取 Local Color Table",
          )
        }
        for _ in 0..<lct_size_val {
          let r = data[pos].to_int()
          let g = data[pos + 1].to_int()
          let b = data[pos + 2].to_int()
          lct.push((r, g, b))
          pos += 3
        }
      }
      if pos >= len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 LZW min code size",
        )
      }
      lzw_min_code_size = data[pos].to_int()
      pos += 1
      if lzw_min_code_size < 2 || lzw_min_code_size > 8 {
        raise @types.LoadError::DecodeFailed("GIF LZW minimum code size 无效")
      }
      lzw_data = []
      while pos < len {
        let sub_len = data[pos].to_int()
        pos += 1
        if sub_len == 0 {
          break
        }
        if pos + sub_len > len {
          raise @types.LoadError::DecodeFailed("GIF 子块长度越界")
        }
        for i in 0..<sub_len {
          lzw_data.push(data[pos + i])
        }
        pos += sub_len
      }
      break
    } else if block_type == 0x21 {
      if pos >= len {
        raise @types.LoadError::DecodeFailed(
          "GIF 数据过短：无法读取 Extension label",
        )
      }
      let label = data[pos].to_int()
      pos += 1
      if label == 0x01 {
        if pos + 8 > len {
          raise @types.LoadError::DecodeFailed(
            "GIF 数据过短：无法读取 Plain Text Extension header",
          )
        }
        pos += 8
      }
      while pos < len {
        let sub_len = data[pos].to_int()
        pos += 1
        if sub_len == 0 {
          break
        }
        if pos + sub_len > len {
          raise @types.LoadError::DecodeFailed("GIF 子块长度越界")
        }
        pos += sub_len
      }
    } else if block_type == 0x3B {
      break
    } else {
      raise @types.LoadError::DecodeFailed("GIF 未知 block type")
    }
  }
  if !found_image {
    raise @types.LoadError::DecodeFailed("GIF 无 Image Separator")
  }
  let indices = lzw_decode(lzw_data, lzw_min_code_size)
  let color_table = if lct.length() > 0 { lct } else { gct }
  if color_table.length() == 0 {
    raise @types.LoadError::DecodeFailed("GIF 无颜色表可用")
  }
  let pixel_count = img_width * img_height
  if indices.length() < pixel_count {
    raise @types.LoadError::DecodeFailed("GIF LZW 输出索引不足")
  }
  let rgb_data : Array[Byte] = Array::make(pixel_count * 3, b'\x00')
  for i in 0..<pixel_count {
    let idx = indices[i]
    if idx >= color_table.length() {
      raise @types.LoadError::DecodeFailed("GIF 颜色表索引越界")
    }
    let (r, g, b) = color_table[idx]
    rgb_data[i * 3] = r.to_byte()
    rgb_data[i * 3 + 1] = g.to_byte()
    rgb_data[i * 3 + 2] = b.to_byte()
  }
  @types.Image::{
    width: img_width,
    height: img_height,
    channels: 3,
    data: Bytes::from_array(rgb_data),
  }
}
