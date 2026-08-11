// 色彩调整 16-bit/float 变体
// 支持 Image16 / ImageF 两种类型

///|
fn read_u16_le_c(data : Bytes, offset : Int) -> Int {
  data[offset].to_int() + data[offset + 1].to_int() * 256
}

///|
fn write_u16_le_c(buf : Array[Byte], offset : Int, val : Int) -> Unit {
  buf[offset] = (val & 0xFF).to_byte()
  buf[offset + 1] = ((val >> 8) & 0xFF).to_byte()
}

///|
fn write_f32_le(buf : Array[Byte], offset : Int, val : Float) -> Unit {
  let bits = val.reinterpret_as_int()
  buf[offset] = (bits & 0xFF).to_byte()
  buf[offset + 1] = ((bits >> 8) & 0xFF).to_byte()
  buf[offset + 2] = ((bits >> 16) & 0xFF).to_byte()
  buf[offset + 3] = ((bits >> 24) & 0xFF).to_byte()
}

///|
/// 16-bit 亮度调整。delta ∈ [-65535, 65535]
pub fn adjust_brightness_16(
  img : @types.Image16,
  delta : Int,
) -> @types.Image16 {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let bpp = ch * 2
  let out : Array[Byte] = Array::make(n * bpp, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let offset = i * bpp + c * 2
      let val = read_u16_le_c(img.data, offset)
      let adjusted = if val + delta < 0 {
        0
      } else if val + delta > 65535 {
        65535
      } else {
        val + delta
      }
      write_u16_le_c(out, offset, adjusted)
    }
    if ch == 4 {
      let alpha_off = i * bpp + 6
      out[alpha_off] = img.data[alpha_off]
      out[alpha_off + 1] = img.data[alpha_off + 1]
    }
  }
  @types.Image16::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// float 亮度调整。delta 为浮点偏移量
pub fn adjust_brightness_f(img : @types.ImageF, delta : Float) -> @types.ImageF {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let bpp = ch * 4
  let out : Array[Byte] = Array::make(n * bpp, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let offset = i * bpp + c * 4
      let val = read_float_le(img.data, offset)
      write_f32_le(out, offset, val + delta)
    }
    if ch == 4 {
      let alpha_off = i * bpp + 12
      for b in 0..<4 {
        out[alpha_off + b] = img.data[alpha_off + b]
      }
    }
  }
  @types.ImageF::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 16-bit 对比度调整。factor=1.0 为原图，以 32768 为中心
pub fn adjust_contrast_16(
  img : @types.Image16,
  factor : Float,
) -> @types.Image16 {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let bpp = ch * 2
  let out : Array[Byte] = Array::make(n * bpp, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let offset = i * bpp + c * 2
      let val = read_u16_le_c(img.data, offset)
      let adjusted = (Float::from_int(val - 32768) * factor + 32768.0F).to_int()
      let clamped = if adjusted < 0 {
        0
      } else if adjusted > 65535 {
        65535
      } else {
        adjusted
      }
      write_u16_le_c(out, offset, clamped)
    }
    if ch == 4 {
      let alpha_off = i * bpp + 6
      out[alpha_off] = img.data[alpha_off]
      out[alpha_off + 1] = img.data[alpha_off + 1]
    }
  }
  @types.Image16::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// float 对比度调整。factor=1.0 为原图，以 0.5 为中心
pub fn adjust_contrast_f(img : @types.ImageF, factor : Float) -> @types.ImageF {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let bpp = ch * 4
  let out : Array[Byte] = Array::make(n * bpp, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let offset = i * bpp + c * 4
      let val = read_float_le(img.data, offset)
      write_f32_le(out, offset, (val - 0.5F) * factor + 0.5F)
    }
    if ch == 4 {
      let alpha_off = i * bpp + 12
      for b in 0..<4 {
        out[alpha_off + b] = img.data[alpha_off + b]
      }
    }
  }
  @types.ImageF::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
