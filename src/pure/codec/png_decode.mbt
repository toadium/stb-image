// 纯 MoonBit PNG 解码（全目标可用：native/wasm/js）
// 依赖 @pure/zlib 进行 IDAT 解压缩
// 支持 color type 0/2/3/4/6, bit depth 8/16

///|
/// PNG 颜色类型对应的通道数
fn png_channels(color_type : Int) -> Int? {
  match color_type {
    0 => Some(1) // gray
    2 => Some(3) // rgb
    3 => Some(1) // palette
    4 => Some(2) // gray + alpha
    6 => Some(4) // rgba
    _ => None
  }
}

///|
/// Paeth 预测函数
fn paeth_predict(a : Int, b : Int, c : Int) -> Int {
  let p = a + b - c
  let pa = (p - a).abs()
  let pb = (p - b).abs()
  let pc = (p - c).abs()
  if pa <= pb && pa <= pc {
    a
  } else if pb <= pc {
    b
  } else {
    c
  }
}

///|
/// PNG 解码（纯 MoonBit，全目标可用）。
/// 支持 8-bit gray/RGB/RGBA/gray+alpha/palette。
/// 不支持 interlace。
pub fn decode_png_pure(data : Bytes) -> @types.Image raise @types.LoadError {
  let len = data.length()
  // 验证 PNG signature
  if len < 8 ||
    data[0].to_int() != 0x89 ||
    data[1].to_int() != 0x50 ||
    data[2].to_int() != 0x4E ||
    data[3].to_int() != 0x47 ||
    data[4].to_int() != 0x0D ||
    data[5].to_int() != 0x0A ||
    data[6].to_int() != 0x1A ||
    data[7].to_int() != 0x0A {
    raise @types.LoadError::DecodeFailed("PNG signature 错误")
  }
  let mut pos = 8
  // 解析 chunks
  let mut width = 0
  let mut height = 0
  let mut bit_depth = 0
  let mut color_type = 0
  let mut interlace = 0
  let palette : Array[(Int, Int, Int)] = []
  let idat_data : Array[Byte] = []
  let mut found_ihdr = false
  let mut found_iend = false
  while pos < len && !found_iend {
    if pos + 8 > len {
      raise @types.LoadError::DecodeFailed("PNG chunk 头部过短")
    }
    let chunk_len = data[pos].to_int() * 16777216 +
      data[pos + 1].to_int() * 65536 +
      data[pos + 2].to_int() * 256 +
      data[pos + 3].to_int()
    let chunk_key = data[pos + 4].to_int() * 16777216 +
      data[pos + 5].to_int() * 65536 +
      data[pos + 6].to_int() * 256 +
      data[pos + 7].to_int()
    pos += 8
    if pos + chunk_len > len {
      raise @types.LoadError::DecodeFailed("PNG chunk 数据越界")
    }
    match chunk_key {
      0x49484452 => {
        // IHDR
        if chunk_len < 13 {
          raise @types.LoadError::DecodeFailed("PNG IHDR 过短")
        }
        width = data[pos].to_int() * 16777216 +
          data[pos + 1].to_int() * 65536 +
          data[pos + 2].to_int() * 256 +
          data[pos + 3].to_int()
        height = data[pos + 4].to_int() * 16777216 +
          data[pos + 5].to_int() * 65536 +
          data[pos + 6].to_int() * 256 +
          data[pos + 7].to_int()
        bit_depth = data[pos + 8].to_int()
        color_type = data[pos + 9].to_int()
        interlace = data[pos + 12].to_int()
        found_ihdr = true
      }
      0x504C5445 => {
        // PLTE
        let num_colors = chunk_len / 3
        for i in 0..<num_colors {
          palette.push(
            (
              data[pos + i * 3].to_int(),
              data[pos + i * 3 + 1].to_int(),
              data[pos + i * 3 + 2].to_int(),
            ),
          )
        }
      }
      0x49444154 =>
        // IDAT
        for i in 0..<chunk_len {
          idat_data.push(data[pos + i])
        }
      0x49454E44 =>
        // IEND
        found_iend = true
      _ => ()
    }
    pos += chunk_len + 4 // skip data + CRC
  }
  if !found_ihdr {
    raise @types.LoadError::DecodeFailed("PNG 无 IHDR chunk")
  }
  if width <= 0 || height <= 0 {
    raise @types.LoadError::DecodeFailed("PNG 尺寸无效")
  }
  if interlace != 0 {
    raise @types.LoadError::DecodeFailed("PNG interlace 不支持")
  }
  if bit_depth != 8 {
    raise @types.LoadError::DecodeFailed("PNG 仅支持 8-bit bit depth")
  }
  let ch = match png_channels(color_type) {
    Some(c) => c
    None => raise @types.LoadError::DecodeFailed("PNG 无效 color type")
  }
  // zlib inflate IDAT 数据
  let raw = @util.zlib_inflate(Bytes::from_array(idat_data))
  // unfilter scanlines
  let bpp = ch // bytes per pixel (8-bit)
  let stride = width * bpp
  let unfiltered : Array[Byte] = Array::make(height * stride, b'\x00')
  let mut raw_pos = 0
  for y in 0..<height {
    if raw_pos >= raw.length() {
      raise @types.LoadError::DecodeFailed("PNG 解压数据过短")
    }
    let filter_type = raw[raw_pos].to_int()
    raw_pos += 1
    for x in 0..<stride {
      if raw_pos >= raw.length() {
        raise @types.LoadError::DecodeFailed("PNG 解压数据过短")
      }
      let raw_byte = raw[raw_pos].to_int()
      raw_pos += 1
      let a = if x >= bpp {
        unfiltered[y * stride + x - bpp].to_int()
      } else {
        0
      }
      let b = if y > 0 { unfiltered[(y - 1) * stride + x].to_int() } else { 0 }
      let c = if x >= bpp && y > 0 {
        unfiltered[(y - 1) * stride + x - bpp].to_int()
      } else {
        0
      }
      let val = match filter_type {
        0 => raw_byte // None
        1 => (raw_byte + a) & 0xFF // Sub
        2 => (raw_byte + b) & 0xFF // Up
        3 => (raw_byte + (a + b) / 2) & 0xFF // Average
        4 => (raw_byte + paeth_predict(a, b, c)) & 0xFF // Paeth
        _ => raise @types.LoadError::DecodeFailed("PNG 无效 filter type")
      }
      unfiltered[y * stride + x] = val.to_byte()
    }
  }
  // 转换为 Image
  let pixel_count = width * height
  let rgb_data : Array[Byte] = Array::make(pixel_count * 3, b'\x00')
  if color_type == 3 {
    // palette
    if palette.length() == 0 {
      raise @types.LoadError::DecodeFailed("PNG palette 缺失")
    }
    for i in 0..<pixel_count {
      let idx = unfiltered[i].to_int()
      if idx >= palette.length() {
        raise @types.LoadError::DecodeFailed("PNG palette 索引越界")
      }
      let (r, g, b) = palette[idx]
      rgb_data[i * 3] = r.to_byte()
      rgb_data[i * 3 + 1] = g.to_byte()
      rgb_data[i * 3 + 2] = b.to_byte()
    }
  } else if color_type == 0 {
    // gray → RGB
    for i in 0..<pixel_count {
      let v = unfiltered[i]
      rgb_data[i * 3] = v
      rgb_data[i * 3 + 1] = v
      rgb_data[i * 3 + 2] = v
    }
  } else if color_type == 2 {
    // RGB
    for i in 0..<(pixel_count * 3) {
      rgb_data[i] = unfiltered[i]
    }
  } else if color_type == 4 {
    // gray + alpha → RGB (drop alpha)
    for i in 0..<pixel_count {
      let v = unfiltered[i * 2]
      rgb_data[i * 3] = v
      rgb_data[i * 3 + 1] = v
      rgb_data[i * 3 + 2] = v
    }
  } else {
    // RGBA → RGB (drop alpha)
    for i in 0..<pixel_count {
      rgb_data[i * 3] = unfiltered[i * 4]
      rgb_data[i * 3 + 1] = unfiltered[i * 4 + 1]
      rgb_data[i * 3 + 2] = unfiltered[i * 4 + 2]
    }
  }
  @types.Image::{
    width,
    height,
    channels: 3,
    data: Bytes::from_array(rgb_data),
  }
}
