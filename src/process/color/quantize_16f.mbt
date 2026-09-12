// 色彩量化 16-bit/float 变体
// K-means 量化 + Median Cut

///|
fn read_u16_q(data : Bytes, offset : Int) -> Int {
  data[offset].to_int() | (data[offset + 1].to_int() << 8)
}

///|
fn write_u16_q(data : Array[Byte], offset : Int, v : Int) -> Unit {
  data[offset] = (v & 0xFF).to_byte()
  data[offset + 1] = ((v >> 8) & 0xFF).to_byte()
}

///|
fn read_f32_q(data : Bytes, offset : Int) -> Float {
  let b0 = data[offset].to_int()
  let b1 = data[offset + 1].to_int()
  let b2 = data[offset + 2].to_int()
  let b3 = data[offset + 3].to_int()
  let bits = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  Float::reinterpret_from_int(bits)
}

///|
fn write_f32_q(data : Array[Byte], offset : Int, v : Float) -> Unit {
  let bits = v.reinterpret_as_int()
  data[offset] = (bits & 0xFF).to_byte()
  data[offset + 1] = ((bits >> 8) & 0xFF).to_byte()
  data[offset + 2] = ((bits >> 16) & 0xFF).to_byte()
  data[offset + 3] = ((bits >> 24) & 0xFF).to_byte()
}

///|
fn dist_sq_f(r1 : Float, g1 : Float, b1 : Float, r2 : Float, g2 : Float, b2 : Float) -> Float {
  let dr = r1 - r2
  let dg = g1 - g2
  let db = b1 - b2
  dr * dr + dg * dg + db * db
}

// ========== K-means 量化 16-bit ==========

///|
/// K-means 色彩量化 16-bit 版本。
pub fn kmeans_quantize_16(
  img : @types.Image16,
  k : Int,
  max_iters : Int,
) -> @types.Image16 raise @types.LoadError {
  if k < 1 || k > 256 {
    raise @types.LoadError::DecodeFailed("k 必须在 1..256 之间")
  }
  if img.channels != 3 && img.channels != 4 {
    raise @types.LoadError::DecodeFailed("kmeans_quantize_16 需要 RGB/RGBA 图像")
  }
  let ch = img.channels
  let n = img.width * img.height
  if n == 0 {
    return img
  }
  let centroids_r : Array[Int] = Array::make(k, 0)
  let centroids_g : Array[Int] = Array::make(k, 0)
  let centroids_b : Array[Int] = Array::make(k, 0)
  let data_int : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    data_int[i] = read_u16_q(img.data, i * 2)
  }
  let step = if n > k { n / k } else { 1 }
  for i in 0..<k {
    let idx = (i * step).clamp(min=0, max=n - 1)
    centroids_r[i] = data_int[idx * ch]
    centroids_g[i] = data_int[idx * ch + 1]
    centroids_b[i] = data_int[idx * ch + 2]
  }
  let labels : Array[Int] = Array::make(n, 0)
  let iters = if max_iters < 1 { 20 } else { max_iters }
  for _ in 0..<iters {
    let mut changed = false
    for i in 0..<n {
      let r = data_int[i * ch]
      let g = data_int[i * ch + 1]
      let b = data_int[i * ch + 2]
      let mut best = 0
      let mut best_dist = (r - centroids_r[0]) * (r - centroids_r[0]) +
        (g - centroids_g[0]) * (g - centroids_g[0]) +
        (b - centroids_b[0]) * (b - centroids_b[0])
      for j in 1..<k {
        let d = (r - centroids_r[j]) * (r - centroids_r[j]) +
          (g - centroids_g[j]) * (g - centroids_g[j]) +
          (b - centroids_b[j]) * (b - centroids_b[j])
        if d < best_dist {
          best_dist = d
          best = j
        }
      }
      if labels[i] != best {
        changed = true
        labels[i] = best
      }
    }
    if !changed {
      break
    }
    let sum_r : Array[Int] = Array::make(k, 0)
    let sum_g : Array[Int] = Array::make(k, 0)
    let sum_b : Array[Int] = Array::make(k, 0)
    let cnt : Array[Int] = Array::make(k, 0)
    for i in 0..<n {
      let label = labels[i]
      sum_r[label] += data_int[i * ch]
      sum_g[label] += data_int[i * ch + 1]
      sum_b[label] += data_int[i * ch + 2]
      cnt[label] += 1
    }
    for j in 0..<k {
      if cnt[j] > 0 {
        centroids_r[j] = sum_r[j] / cnt[j]
        centroids_g[j] = sum_g[j] / cnt[j]
        centroids_b[j] = sum_b[j] / cnt[j]
      }
    }
  }
  let out : Array[Byte] = Array::make(n * ch * 2, b'\x00')
  for i in 0..<n {
    let label = labels[i]
    write_u16_q(out, i * ch * 2, centroids_r[label])
    write_u16_q(out, (i * ch + 1) * 2, centroids_g[label])
    write_u16_q(out, (i * ch + 2) * 2, centroids_b[label])
    if ch == 4 {
      let v = read_u16_q(img.data, (i * ch + 3) * 2)
      write_u16_q(out, (i * ch + 3) * 2, v)
    }
  }
  @types.Image16::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

// ========== K-means 量化 float ==========

///|
/// K-means 色彩量化 float 版本。
pub fn kmeans_quantize_f(
  img : @types.ImageF,
  k : Int,
  max_iters : Int,
) -> @types.ImageF raise @types.LoadError {
  if k < 1 || k > 256 {
    raise @types.LoadError::DecodeFailed("k 必须在 1..256 之间")
  }
  if img.channels != 3 && img.channels != 4 {
    raise @types.LoadError::DecodeFailed("kmeans_quantize_f 需要 RGB/RGBA 图像")
  }
  let ch = img.channels
  let n = img.width * img.height
  if n == 0 {
    return img
  }
  let centroids_r : Array[Float] = Array::make(k, 0.0F)
  let centroids_g : Array[Float] = Array::make(k, 0.0F)
  let centroids_b : Array[Float] = Array::make(k, 0.0F)
  let data_f : Array[Float] = Array::make(n * ch, 0.0F)
  for i in 0..<(n * ch) {
    data_f[i] = read_f32_q(img.data, i * 4)
  }
  let step = if n > k { n / k } else { 1 }
  for i in 0..<k {
    let idx = (i * step).clamp(min=0, max=n - 1)
    centroids_r[i] = data_f[idx * ch]
    centroids_g[i] = data_f[idx * ch + 1]
    centroids_b[i] = data_f[idx * ch + 2]
  }
  let labels : Array[Int] = Array::make(n, 0)
  let iters = if max_iters < 1 { 20 } else { max_iters }
  for _ in 0..<iters {
    let mut changed = false
    for i in 0..<n {
      let r = data_f[i * ch]
      let g = data_f[i * ch + 1]
      let b = data_f[i * ch + 2]
      let mut best = 0
      let mut best_dist = dist_sq_f(r, g, b, centroids_r[0], centroids_g[0], centroids_b[0])
      for j in 1..<k {
        let d = dist_sq_f(r, g, b, centroids_r[j], centroids_g[j], centroids_b[j])
        if d < best_dist {
          best_dist = d
          best = j
        }
      }
      if labels[i] != best {
        changed = true
        labels[i] = best
      }
    }
    if !changed {
      break
    }
    let sum_r : Array[Float] = Array::make(k, 0.0F)
    let sum_g : Array[Float] = Array::make(k, 0.0F)
    let sum_b : Array[Float] = Array::make(k, 0.0F)
    let cnt : Array[Int] = Array::make(k, 0)
    for i in 0..<n {
      let label = labels[i]
      sum_r[label] += data_f[i * ch]
      sum_g[label] += data_f[i * ch + 1]
      sum_b[label] += data_f[i * ch + 2]
      cnt[label] += 1
    }
    for j in 0..<k {
      if cnt[j] > 0 {
        centroids_r[j] = sum_r[j] / Float::from_int(cnt[j])
        centroids_g[j] = sum_g[j] / Float::from_int(cnt[j])
        centroids_b[j] = sum_b[j] / Float::from_int(cnt[j])
      }
    }
  }
  let out : Array[Byte] = Array::make(n * ch * 4, b'\x00')
  for i in 0..<n {
    let label = labels[i]
    write_f32_q(out, i * ch * 4, centroids_r[label])
    write_f32_q(out, (i * ch + 1) * 4, centroids_g[label])
    write_f32_q(out, (i * ch + 2) * 4, centroids_b[label])
    if ch == 4 {
      let v = read_f32_q(img.data, (i * ch + 3) * 4)
      write_f32_q(out, (i * ch + 3) * 4, v)
    }
  }
  @types.ImageF::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}
