// 纯 MoonBit 直方图操作（全目标可用：native/wasm/js）
// 仅依赖 @types，不依赖 @core/FFI
// 移植自 src/process/feature/histogram.mbt:1-131 的 3 个直方图函数

///|
/// 计算灰度直方图（纯 MoonBit，全目标可用）。返回 256 个 bin 的计数数组。
/// 彩色图像先转灰度（BT.601）再计算。
pub fn histogram_pure(img : @types.Image) -> Array[Int] {
  let hist : Array[Int] = Array::make(256, 0)
  let n = img.width * img.height
  let ch = img.channels
  let data_int : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    data_int[i] = img.data[i].to_int()
  }
  for i in 0..<n {
    let v = if ch == 1 {
      data_int[i]
    } else {
      let r = data_int[i * ch]
      let g = data_int[i * ch + 1]
      let b = data_int[i * ch + 2]
      (r * 299 + g * 587 + b * 114) / 1000
    }
    hist[v] += 1
  }
  hist
}

///|
/// 直方图均衡化（纯 MoonBit，全目标可用）。基于灰度直方图计算映射 LUT，应用到所有颜色通道。
/// alpha 通道不变。
pub fn histogram_equalize_pure(img : @types.Image) -> @types.Image {
  let hist = histogram_pure(img)
  let n = img.width * img.height
  // 计算 CDF
  let cdf : Array[Int] = Array::make(256, 0)
  let mut cum = 0
  for i in 0..<256 {
    cum += hist[i]
    cdf[i] = cum
  }
  // 找到 CDF_min（第一个非零值）
  let mut cdf_min = 0
  for i in 0..<256 {
    if cdf[i] > 0 {
      cdf_min = cdf[i]
      break
    }
  }
  // 计算映射 LUT
  let lut : Array[Byte] = Array::make(256, b'\x00')
  let denom = n - cdf_min
  if denom <= 0 {
    // 所有像素相同，返回原图
    return img
  }
  for i in 0..<256 {
    let mapped = (cdf[i] - cdf_min) * 255 / denom
    lut[i] = mapped.clamp(min=0, max=255).to_byte()
  }
  // 应用 LUT
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let data_int : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    data_int[i] = img.data[i].to_int()
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      out[i * ch + c] = lut[data_int[i * ch + c]]
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
/// 直方图归一化（线性拉伸）（纯 MoonBit，全目标可用）。将像素值范围线性映射到 [0, 255]。
/// alpha 通道不变。
pub fn histogram_normalize_pure(img : @types.Image) -> @types.Image {
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let n = img.width * img.height
  let data_int : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    data_int[i] = img.data[i].to_int()
  }
  // 找到颜色通道的最小值和最大值
  let mut min_val = 255
  let mut max_val = 0
  for i in 0..<n {
    for c in 0..<color_ch {
      let v = data_int[i * ch + c]
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
  }
  let range = max_val - min_val
  if range == 0 {
    return img
  }
  // 应用线性拉伸
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    for c in 0..<color_ch {
      let v = data_int[i * ch + c]
      let scaled = (v - min_val) * 255 / range
      out[i * ch + c] = scaled.clamp(min=0, max=255).to_byte()
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
