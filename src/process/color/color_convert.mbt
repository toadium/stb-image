// 色彩模型转换（纯 MoonBit）

///|
/// 转为灰度图（channels=1）
/// 使用 ITU-R BT.601 亮度公式: Y = 0.299R + 0.587G + 0.114B
pub fn to_grayscale(img : @core.Image) -> @core.Image {
  if img.channels == 1 {
    return img
  }
  let pixel_count = img.width * img.height
  let ch = img.channels
  let data_int : Array[Int] = Array::make(pixel_count * ch, 0)
  for i in 0..<(pixel_count * ch) {
    data_int[i] = img.data[i].to_int()
  }
  let out : Array[Byte] = Array::make(pixel_count, b'\x00')
  for i in 0..<pixel_count {
    let r = data_int[i * ch]
    let g = data_int[i * ch + 1]
    let b = data_int[i * ch + 2]
    let gray = (r * 299 + g * 587 + b * 114) / 1000
    out[i] = gray.to_byte()
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: 1,
    data: Bytes::from_array(out),
  }
}

///|
/// 去除 alpha 通道（RGBA → RGB，channels=3）
pub fn to_rgb(img : @core.Image) -> @core.Image {
  if img.channels == 3 {
    return img
  }
  if img.channels < 3 {
    return img
  }
  let pixel_count = img.width * img.height
  let out : Array[Byte] = Array::make(pixel_count * 3, b'\x00')
  for i in 0..<pixel_count {
    out[i * 3] = img.data[i * img.channels]
    out[i * 3 + 1] = img.data[i * img.channels + 1]
    out[i * 3 + 2] = img.data[i * img.channels + 2]
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: 3,
    data: Bytes::from_array(out),
  }
}

///|
/// 添加 alpha 通道（RGB → RGBA，channels=4，alpha=255）
pub fn to_rgba(img : @core.Image) -> @core.Image {
  if img.channels == 4 {
    return img
  }
  let pixel_count = img.width * img.height
  let out : Array[Byte] = Array::make(pixel_count * 4, b'\x00')
  for i in 0..<pixel_count {
    let src_ch = img.channels
    out[i * 4] = img.data[i * src_ch]
    out[i * 4 + 1] = if src_ch >= 2 {
      img.data[i * src_ch + 1]
    } else {
      b'\x00'
    }
    out[i * 4 + 2] = if src_ch >= 3 {
      img.data[i * src_ch + 2]
    } else {
      b'\x00'
    }
    out[i * 4 + 3] = b'\xFF'
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: 4,
    data: Bytes::from_array(out),
  }
}

///|
/// 预乘 alpha（RGBA → RGBA premultiplied）
/// 要求 channels=4
pub fn premultiply_alpha(
  img : @core.Image,
) -> @core.Image raise @core.LoadError {
  if img.channels != 4 {
    raise @core.LoadError::DecodeFailed(
      "premultiply_alpha 需要 channels=4 (RGBA)",
    )
  }
  let pixel_count = img.width * img.height
  let data_int : Array[Int] = Array::make(pixel_count * 4, 0)
  for i in 0..<(pixel_count * 4) {
    data_int[i] = img.data[i].to_int()
  }
  let out : Array[Byte] = Array::make(pixel_count * 4, b'\x00')
  for i in 0..<pixel_count {
    let r = data_int[i * 4]
    let g = data_int[i * 4 + 1]
    let b = data_int[i * 4 + 2]
    let a = data_int[i * 4 + 3]
    out[i * 4] = (r * a / 255).to_byte()
    out[i * 4 + 1] = (g * a / 255).to_byte()
    out[i * 4 + 2] = (b * a / 255).to_byte()
    out[i * 4 + 3] = a.to_byte()
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: 4,
    data: Bytes::from_array(out),
  }
}

///|
/// 反预乘 alpha（RGBA premA → RGBA unpremultiplied）
/// 要求 channels=4
pub fn unpremultiply_alpha(
  img : @core.Image,
) -> @core.Image raise @core.LoadError {
  if img.channels != 4 {
    raise @core.LoadError::DecodeFailed(
      "unpremultiply_alpha 需要 channels=4 (RGBA)",
    )
  }
  let pixel_count = img.width * img.height
  let data_int : Array[Int] = Array::make(pixel_count * 4, 0)
  for i in 0..<(pixel_count * 4) {
    data_int[i] = img.data[i].to_int()
  }
  let out : Array[Byte] = Array::make(pixel_count * 4, b'\x00')
  for i in 0..<pixel_count {
    let r = data_int[i * 4]
    let g = data_int[i * 4 + 1]
    let b = data_int[i * 4 + 2]
    let a = data_int[i * 4 + 3]
    if a == 0 {
      out[i * 4] = b'\x00'
      out[i * 4 + 1] = b'\x00'
      out[i * 4 + 2] = b'\x00'
      out[i * 4 + 3] = b'\x00'
    } else {
      out[i * 4] = (r * 255 / a).to_byte()
      out[i * 4 + 1] = (g * 255 / a).to_byte()
      out[i * 4 + 2] = (b * 255 / a).to_byte()
      out[i * 4 + 3] = a.to_byte()
    }
  }
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: 4,
    data: Bytes::from_array(out),
  }
}
