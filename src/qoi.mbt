// QOI (Quite OK Image) 纯 MoonBit 解码/编码
// 规范: https://qoiformat.org/qoi-specification.pdf

// QOI 哈希函数: (r*3 + g*5 + b*7 + a*11) % 64
fn qoi_hash(r : Int, g : Int, b : Int, a : Int) -> Int {
  (r * 3 + g * 5 + b * 7 + a * 11) % 64
}

///|
/// 解码 QOI 字节流为 Image（channels=3 或 4）
pub fn decode_qoi(data : Bytes) -> Image raise LoadError {
  let len = data.length()
  if len < 14 {
    raise LoadError::DecodeFailed("QOI 数据过短")
  }
  if data[0].to_int() != 0x71 || data[1].to_int() != 0x6F ||
    data[2].to_int() != 0x69 || data[3].to_int() != 0x66 {
    raise LoadError::DecodeFailed("QOI magic 不匹配")
  }
  let width = (data[4].to_int() << 24) | (data[5].to_int() << 16) | (data[6].to_int() << 8) | data[7].to_int()
  let height = (data[8].to_int() << 24) | (data[9].to_int() << 16) | (data[10].to_int() << 8) | data[11].to_int()
  let channels = data[12].to_int()
  if width <= 0 || height <= 0 {
    raise LoadError::DecodeFailed("QOI 尺寸无效")
  }
  let out_channels = if channels == 3 { 3 } else { 4 }
  let pixel_count = width * height
  let pixels : Array[Byte] = Array::make(pixel_count * out_channels, b'\x00')
  let index_r : Array[Int] = Array::make(64, 0)
  let index_g : Array[Int] = Array::make(64, 0)
  let index_b : Array[Int] = Array::make(64, 0)
  let index_a : Array[Int] = Array::make(64, 0)
  let px_r = Ref(0)
  let px_g = Ref(0)
  let px_b = Ref(0)
  let px_a = Ref(255)
  let pos = Ref(14)
  let pixel_idx = Ref(0)
  while pixel_idx.val < pixel_count && pos.val < len {
    let tag = data[pos.val].to_int()
    pos.val += 1
    if tag == 0xFE {
      px_r.val = data[pos.val].to_int()
      px_g.val = data[pos.val + 1].to_int()
      px_b.val = data[pos.val + 2].to_int()
      pos.val += 3
    } else if tag == 0xFF {
      px_r.val = data[pos.val].to_int()
      px_g.val = data[pos.val + 1].to_int()
      px_b.val = data[pos.val + 2].to_int()
      px_a.val = data[pos.val + 3].to_int()
      pos.val += 4
    } else if (tag & 0xC0) == 0x00 {
      let idx = tag & 0x3F
      px_r.val = index_r[idx]
      px_g.val = index_g[idx]
      px_b.val = index_b[idx]
      px_a.val = index_a[idx]
    } else if (tag & 0xC0) == 0x40 {
      px_r.val = (px_r.val + ((tag >> 4) & 0x03) - 2) & 0xFF
      px_g.val = (px_g.val + ((tag >> 2) & 0x03) - 2) & 0xFF
      px_b.val = (px_b.val + (tag & 0x03) - 2) & 0xFF
    } else if (tag & 0xC0) == 0x80 {
      let dg = (tag & 0x3F) - 32
      px_g.val = (px_g.val + dg) & 0xFF
      let b2 = data[pos.val].to_int()
      pos.val += 1
      let dr_dg = (b2 >> 4) - 8
      let db_dg = (b2 & 0x0F) - 8
      px_r.val = (px_r.val + dr_dg + dg) & 0xFF
      px_b.val = (px_b.val + db_dg + dg) & 0xFF
    } else {
      let run = (tag & 0x3F) + 1
      for _ in 0..<run {
        if pixel_idx.val < pixel_count {
          pixels[pixel_idx.val * out_channels] = px_r.val.to_byte()
          pixels[pixel_idx.val * out_channels + 1] = px_g.val.to_byte()
          pixels[pixel_idx.val * out_channels + 2] = px_b.val.to_byte()
          if out_channels == 4 {
            pixels[pixel_idx.val * out_channels + 3] = px_a.val.to_byte()
          }
          pixel_idx.val += 1
        }
      }
      continue
    }
    pixels[pixel_idx.val * out_channels] = px_r.val.to_byte()
    pixels[pixel_idx.val * out_channels + 1] = px_g.val.to_byte()
    pixels[pixel_idx.val * out_channels + 2] = px_b.val.to_byte()
    if out_channels == 4 {
      pixels[pixel_idx.val * out_channels + 3] = px_a.val.to_byte()
    }
    pixel_idx.val += 1
    let h = qoi_hash(px_r.val, px_g.val, px_b.val, px_a.val)
    index_r[h] = px_r.val
    index_g[h] = px_g.val
    index_b[h] = px_b.val
    index_a[h] = px_a.val
  }
  Image::{ width, height, channels: out_channels, data: Bytes::from_array(pixels) }
}

///|
/// 将 Image 编码为 QOI 字节流
/// 输入 Image 的 channels 必须为 3 (RGB) 或 4 (RGBA)
pub fn encode_qoi(img : Image) -> Bytes raise LoadError {
  if img.channels != 3 && img.channels != 4 {
    raise LoadError::DecodeFailed("QOI 编码需要 channels 为 3 (RGB) 或 4 (RGBA)")
  }
  let out : Array[Byte] = []
  out.push(b'\x71')
  out.push(b'\x6F')
  out.push(b'\x69')
  out.push(b'\x66')
  out.push(((img.width >> 24) & 0xFF).to_byte())
  out.push(((img.width >> 16) & 0xFF).to_byte())
  out.push(((img.width >> 8) & 0xFF).to_byte())
  out.push((img.width & 0xFF).to_byte())
  out.push(((img.height >> 24) & 0xFF).to_byte())
  out.push(((img.height >> 16) & 0xFF).to_byte())
  out.push(((img.height >> 8) & 0xFF).to_byte())
  out.push((img.height & 0xFF).to_byte())
  out.push(img.channels.to_byte())
  out.push(b'\x00')
  let index_r : Array[Int] = Array::make(64, 0)
  let index_g : Array[Int] = Array::make(64, 0)
  let index_b : Array[Int] = Array::make(64, 0)
  let index_a : Array[Int] = Array::make(64, 0)
  let prev_r = Ref(0)
  let prev_g = Ref(0)
  let prev_b = Ref(0)
  let prev_a = Ref(255)
  let has_alpha = img.channels == 4
  let pixel_count = img.width * img.height
  let run = Ref(0)
  for i in 0..<pixel_count {
    let r = img.data[i * img.channels].to_int()
    let g = img.data[i * img.channels + 1].to_int()
    let b = img.data[i * img.channels + 2].to_int()
    let a = if has_alpha { img.data[i * img.channels + 3].to_int() } else { 255 }
    if r == prev_r.val && g == prev_g.val && b == prev_b.val && a == prev_a.val {
      run.val += 1
      if run.val == 62 {
        out.push((0xC0 | (run.val - 1)).to_byte())
        run.val = 0
      }
    } else {
      if run.val > 0 {
        out.push((0xC0 | (run.val - 1)).to_byte())
        run.val = 0
      }
      let h = qoi_hash(r, g, b, a)
      if index_r[h] == r && index_g[h] == g && index_b[h] == b && index_a[h] == a {
        out.push((h & 0x3F).to_byte())
      } else if a == prev_a.val {
        let dr = r - prev_r.val
        let dg = g - prev_g.val
        let db = b - prev_b.val
        let dr_dg = dr - dg
        let db_dg = db - dg
        if dr >= -2 && dr <= 1 && dg >= -2 && dg <= 1 && db >= -2 && db <= 1 {
          out.push((0x40 | ((dr + 2) << 4) | ((dg + 2) << 2) | (db + 2)).to_byte())
        } else if dg >= -32 && dg <= 31 && dr_dg >= -8 && dr_dg <= 7 && db_dg >= -8 && db_dg <= 7 {
          out.push((0x80 | ((dg + 32) & 0x3F)).to_byte())
          out.push((((dr_dg + 8) << 4) | (db_dg + 8)).to_byte())
        } else {
          out.push(b'\xFE')
          out.push(r.to_byte())
          out.push(g.to_byte())
          out.push(b.to_byte())
        }
      } else {
        out.push(b'\xFF')
        out.push(r.to_byte())
        out.push(g.to_byte())
        out.push(b.to_byte())
        out.push(a.to_byte())
      }
      index_r[h] = r
      index_g[h] = g
      index_b[h] = b
      index_a[h] = a
    }
    prev_r.val = r
    prev_g.val = g
    prev_b.val = b
    prev_a.val = a
  }
  if run.val > 0 {
    out.push((0xC0 | (run.val - 1)).to_byte())
  }
  for i in 0..<8 {
    if i == 7 {
      out.push(b'\x01')
    } else {
      out.push(b'\x00')
    }
  }
  Bytes::from_array(out)
}
