// 自适应阈值（纯 MoonBit）

///|
/// 自适应阈值（均值法）。以每个像素周围 block_size×block_size 区域的均值减去 C 作为局部阈值。
/// 仅处理灰度图（channels=1）或 RGB 图（channels=3/4），alpha 通道不变。
pub fn adaptive_threshold_mean(
  img : @core.Image,
  block_size : Int,
  c : Int
) -> @core.Image raise @core.LoadError {
  if block_size < 3 || block_size % 2 == 0 {
    raise @core.LoadError::DecodeFailed("block_size 必须为 >=3 的奇数")
  }
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("adaptive_threshold_mean 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let half = block_size / 2
  for c_idx in 0..<color_ch {
    for y in 0..<h {
      for x in 0..<w {
        let mut sum = 0
        let mut count = 0
        for dy in -half..=half {
          for dx in -half..=half {
            let ny = y + dy
            let nx = x + dx
            if ny >= 0 && ny < h && nx >= 0 && nx < w {
              sum += img.data[(ny * w + nx) * ch + c_idx].to_int()
              count += 1
            }
          }
        }
        let mean = if count > 0 { sum / count } else { 0 }
        let threshold = mean - c
        let v = img.data[(y * w + x) * ch + c_idx].to_int()
        out[(y * w + x) * ch + c_idx] = if v > threshold { b'\xFF' } else { b'\x00' }
      }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 自适应阈值（高斯加权法）。以每个像素周围 block_size×block_size 区域的高斯加权均值减去 C 作为局部阈值。
pub fn adaptive_threshold_gaussian(
  img : @core.Image,
  block_size : Int,
  c : Int
) -> @core.Image raise @core.LoadError {
  if block_size < 3 || block_size % 2 == 0 {
    raise @core.LoadError::DecodeFailed("block_size 必须为 >=3 的奇数")
  }
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("adaptive_threshold_gaussian 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let half = block_size / 2
  let sigma = Float::from_int(half) / 2.0F
  let two_sigma_sq = 2.0F * sigma * sigma
  let weights : Array[Array[Float]] = Array::make(block_size, Array::make(block_size, 0.0F))
  for dy in 0..<block_size {
    for dx in 0..<block_size {
      let fy = Float::from_int(dy - half)
      let fx = Float::from_int(dx - half)
      weights[dy][dx] = @math.expf(-(fx * fx + fy * fy) / two_sigma_sq)
    }
  }
  for c_idx in 0..<color_ch {
    for y in 0..<h {
      for x in 0..<w {
        let mut sum = 0.0F
        let mut weight_sum = 0.0F
        for dy in -half..=half {
          for dx in -half..=half {
            let ny = y + dy
            let nx = x + dx
            if ny >= 0 && ny < h && nx >= 0 && nx < w {
              let weight = weights[dy + half][dx + half]
              sum += Float::from_int(img.data[(ny * w + nx) * ch + c_idx].to_int()) * weight
              weight_sum += weight
            }
          }
        }
        let mean = if weight_sum > 0.0F { sum / weight_sum } else { 0.0F }
        let threshold = mean - Float::from_int(c)
        let v = Float::from_int(img.data[(y * w + x) * ch + c_idx].to_int())
        out[(y * w + x) * ch + c_idx] = if v > threshold { b'\xFF' } else { b'\x00' }
      }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// Otsu 大津法自动阈值。自动计算最佳全局阈值并二值化。
pub fn threshold_otsu(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("threshold_otsu 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { 1 }
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for c_idx in 0..<color_ch {
    let hist : Array[Int] = Array::make(256, 0)
    for i in 0..<n {
      hist[img.data[i * ch + c_idx].to_int()] += 1
    }
    let mut total = 0
    let mut sum = 0
    for t in 0..<256 {
      total += hist[t]
      sum += t * hist[t]
    }
    let mut best_t = 0
    let mut best_var = -1.0F
    let mut w0 = 0
    let mut sum0 = 0
    for t in 0..<256 {
      w0 += hist[t]
      sum0 += t * hist[t]
      if w0 == 0 || w0 == total {
        continue
      }
      let w1 = total - w0
      let sum1 = sum - sum0
      let mean0 = Float::from_int(sum0) / Float::from_int(w0)
      let mean1 = Float::from_int(sum1) / Float::from_int(w1)
      let var_between = Float::from_int(w0) * Float::from_int(w1) * (mean0 - mean1) * (mean0 - mean1)
      if var_between > best_var {
        best_var = var_between
        best_t = t
      }
    }
    for i in 0..<n {
      let v = img.data[i * ch + c_idx].to_int()
      out[i * ch + c_idx] = if v > best_t { b'\xFF' } else { b'\x00' }
    }
  }
  if ch == 4 {
    for i in 0..<n {
      out[i * 4 + 3] = img.data[i * 4 + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}