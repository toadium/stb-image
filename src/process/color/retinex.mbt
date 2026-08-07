// 多尺度 Retinex（纯 MoonBit）

///|
/// Float 自然对数辅助函数
fn logf(x : Float) -> Float {
  Float::from_double(@math.log2(x.to_double()) * 0.6931471805599453)
}

///|
/// 单尺度 Retinex（SSR）。
/// 对每个像素计算 log(I) - log(I * G_sigma)，
/// 其中 G_sigma 为高斯滤波器。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4）。
/// sigma 为高斯标准差，gain 为增益，offset 为偏移。
pub fn ssr(
  img : @core.Image,
  sigma? : Float = 80.0F,
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("ssr 仅支持 channels=1/3/4")
  }
  if sigma <= 0.0F {
    raise @core.LoadError::DecodeFailed("sigma 必须 > 0")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  if n == 0 {
    return img
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c in 0..<ch {
    if ch == 4 && c == 3 {
      for i in 0..<n {
        out[i * ch + 3] = img.data[i * ch + 3]
      }
      continue
    }
    let channel : Array[Float] = Array::make(n, 0.0F)
    for i in 0..<n {
      let v = img.data[i * ch + c].to_int()
      channel[i] = Float::from_int(if v == 0 { 1 } else { v })
    }
    let blurred = gaussian_blur_channel(channel, w, h, sigma)
    for i in 0..<n {
      let log_i = logf(channel[i])
      let log_b = logf(if blurred[i] > 0.0F { blurred[i] } else { 1.0F })
      let retinex = (log_i - log_b) * gain + offset
      let val = (retinex * 30.0F + 128.0F).to_int()
      out[i * ch + c] = val.clamp(min=0, max=255).to_byte()
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 多尺度 Retinex（MSR）。
/// 对多个不同 sigma 的 SSR 结果取平均。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4）。
/// sigmas 为高斯标准差数组（默认 [15, 80, 250]）。
/// gain 为增益，offset 为偏移。
pub fn msr(
  img : @core.Image,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("msr 仅支持 channels=1/3/4")
  }
  if sigmas.length() == 0 {
    raise @core.LoadError::DecodeFailed("sigmas 不能为空")
  }
  for s in sigmas {
    if s <= 0.0F {
      raise @core.LoadError::DecodeFailed("sigma 必须 > 0")
    }
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  if n == 0 {
    return img
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let num_scales = sigmas.length()
  for c in 0..<ch {
    if ch == 4 && c == 3 {
      for i in 0..<n {
        out[i * ch + 3] = img.data[i * ch + 3]
      }
      continue
    }
    let channel : Array[Float] = Array::make(n, 0.0F)
    for i in 0..<n {
      let v = img.data[i * ch + c].to_int()
      channel[i] = Float::from_int(if v == 0 { 1 } else { v })
    }
    let retinex_sum : Array[Float] = Array::make(n, 0.0F)
    for sigma in sigmas {
      let blurred = gaussian_blur_channel(channel, w, h, sigma)
      for i in 0..<n {
        let log_i = logf(channel[i])
        let log_b = logf(if blurred[i] > 0.0F { blurred[i] } else { 1.0F })
        retinex_sum[i] += log_i - log_b
      }
    }
    for i in 0..<n {
      let retinex = retinex_sum[i] / Float::from_int(num_scales) * gain + offset
      let val = (retinex * 30.0F + 128.0F).to_int()
      out[i * ch + c] = val.clamp(min=0, max=255).to_byte()
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 带颜色恢复的多尺度 Retinex（MSRCR）。
/// 在 MSR 基础上恢复颜色信息。
/// 适用于 RGB/RGBA 图（channels=3/4）。
pub fn msrcr(
  img : @core.Image,
  sigmas? : Array[Float] = [15.0F, 80.0F, 250.0F],
  gain? : Float = 1.0F,
  offset? : Float = 0.0F,
  alpha? : Float = 125.0F,
  beta? : Float = 46.0F,
) -> @core.Image raise @core.LoadError {
  if img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("msrcr 需要 RGB/RGBA 图像")
  }
  if sigmas.length() == 0 {
    raise @core.LoadError::DecodeFailed("sigmas 不能为空")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  if n == 0 {
    return img
  }
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let num_scales = sigmas.length()
  // 提取各通道
  let channels : Array[Array[Float]] = [
    Array::make(n, 0.0F),
    Array::make(n, 0.0F),
    Array::make(n, 0.0F),
  ]
  for c in 0..<3 {
    for i in 0..<n {
      let v = img.data[i * ch + c].to_int()
      channels[c][i] = Float::from_int(if v == 0 { 1 } else { v })
    }
  }
  // 计算各通道 MSR
  let msr_results : Array[Array[Float]] = [
    Array::make(n, 0.0F),
    Array::make(n, 0.0F),
    Array::make(n, 0.0F),
  ]
  for c in 0..<3 {
    let retinex_sum : Array[Float] = Array::make(n, 0.0F)
    for sigma in sigmas {
      let blurred = gaussian_blur_channel(channels[c], w, h, sigma)
      for i in 0..<n {
        let log_i = logf(channels[c][i])
        let log_b = logf(if blurred[i] > 0.0F { blurred[i] } else { 1.0F })
        retinex_sum[i] += log_i - log_b
      }
    }
    for i in 0..<n {
      msr_results[c][i] = retinex_sum[i] / Float::from_int(num_scales)
    }
  }
  // 颜色恢复因子
  for i in 0..<n {
    let sum = channels[0][i] + channels[1][i] + channels[2][i]
    for c in 0..<3 {
      let crf = logf(alpha * channels[c][i] / (sum + 1.0F)) * beta
      let val = msr_results[c][i] * gain + offset + crf
      let mapped = (val * 30.0F + 128.0F).to_int()
      out[i * ch + c] = mapped.clamp(min=0, max=255).to_byte()
    }
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 对单通道进行高斯模糊
fn gaussian_blur_channel(
  channel : Array[Float],
  w : Int,
  h : Int,
  sigma : Float,
) -> Array[Float] {
  let n = w * h
  let out : Array[Float] = Array::make(n, 0.0F)
  let radius = (Float::from_int(3) * sigma).to_int()
  let radius = if radius < 1 { 1 } else { radius }
  let kernel_size = 2 * radius + 1
  let kernel : Array[Float] = Array::make(kernel_size, 0.0F)
  let two_sigma_sq = 2.0F * sigma * sigma
  let mut kernel_sum = 0.0F
  for i in 0..<kernel_size {
    let x = Float::from_int(i - radius)
    kernel[i] = @math.expf(-(x * x) / two_sigma_sq)
    kernel_sum += kernel[i]
  }
  for i in 0..<kernel_size {
    kernel[i] = kernel[i] / kernel_sum
  }
  // 水平模糊，分离内部/边界区域
  let temp : Array[Float] = Array::make(n, 0.0F)
  for y in 0..<h {
    let row_base = y * w
    // 内部区域：x in [radius, w-radius)
    for x in radius..<(w - radius) {
      let mut sum = 0.0F
      let base = row_base + x - radius
      for k in 0..<kernel_size {
        sum += channel[base + k] * kernel[k]
      }
      temp[row_base + x] = sum
    }
    // 边界区域
    for x in 0..<w {
      if x >= radius && x < w - radius {
        continue
      }
      let mut sum = 0.0F
      for k in -radius..<=radius {
        let px = (x + k).clamp(min=0, max=w - 1)
        sum += channel[row_base + px] * kernel[k + radius]
      }
      temp[row_base + x] = sum
    }
  }
  // 垂直模糊，分离内部/边界区域
  for x in 0..<w {
    // 内部区域：y in [radius, h-radius)
    for y in radius..<(h - radius) {
      let mut sum = 0.0F
      let base = (y - radius) * w + x
      for k in 0..<kernel_size {
        sum += temp[base + k * w] * kernel[k]
      }
      out[y * w + x] = sum
    }
    // 边界区域
    for y in 0..<h {
      if y >= radius && y < h - radius {
        continue
      }
      let mut sum = 0.0F
      for k in -radius..<=radius {
        let py = (y + k).clamp(min=0, max=h - 1)
        sum += temp[py * w + x] * kernel[k + radius]
      }
      out[y * w + x] = sum
    }
  }
  out
}
