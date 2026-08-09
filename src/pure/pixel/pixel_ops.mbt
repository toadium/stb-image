// 纯 MoonBit 像素操作（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 移植自 src/util/pixel_ops.mbt:4-98 的基础像素操作

///|
pub fn clamp_byte_v(v : Int) -> Byte {
  if v < 0 {
    b'\x00'
  } else if v > 255 {
    b'\xFF'
  } else {
    v.to_byte()
  }
}

///|
/// 二值化（纯 MoonBit，全目标可用）。像素值 >= threshold 设为 255，否则设为 0。
/// 仅影响颜色通道，alpha 通道不变。
pub fn threshold_pure(img : @types.Image, thresh : Int) -> @types.Image {
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      out[i * ch + c] = if img.data[i * ch + c].to_int() >= thresh {
        b'\xFF'
      } else {
        b'\x00'
      }
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 色调分离（纯 MoonBit，全目标可用）。将每个通道的值量化到 levels 个级别。
/// levels=2 等价于二值化，levels=4 将 0-255 分成 4 段。
pub fn posterize_pure(
  img : @types.Image,
  levels : Int,
) -> @types.Image raise @types.LoadError {
  if levels < 2 || levels > 256 {
    raise @types.LoadError::DecodeFailed(
      "posterize levels 必须在 [2, 256] 范围内",
    )
  }
  let n = img.width * img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let step = 256.0F / Float::from_int(levels)
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let v = img.data[i * ch + c].to_int()
      let quantized = (Float::from_int(v) / step).to_int() * step.to_int()
      out[i * ch + c] = clamp_byte_v(quantized)
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 提取单个通道（纯 MoonBit，全目标可用）。返回单通道 Image（channels=1）。
/// channel: 0=R/Gray, 1=G, 2=B, 3=A
pub fn extract_channel_pure(
  img : @types.Image,
  channel : Int,
) -> @types.Image raise @types.LoadError {
  if channel < 0 || channel >= img.channels {
    raise @types.LoadError::DecodeFailed("channel 索引越界")
  }
  let n = img.width * img.height
  let out : Array[Byte] = Array::make(n, b'\x00')
  for i in 0..<n {
    out[i] = img.data[i * img.channels + channel]
  }
  @types.Image::{
    width: img.width,
    height: img.height,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
