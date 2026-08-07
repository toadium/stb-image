// K-means 色彩量化（纯 MoonBit）

///|
/// K-means 色彩量化。将图像颜色聚为 k 类，每类用聚类中心替代。
/// 适用于 RGB/RGBA 图像（channels=3/4），alpha 通道不变。
/// max_iters 控制最大迭代次数（默认 20）。
pub fn k_means_quantize(img : @core.Image, k : Int, max_iters : Int) -> @core.Image raise @core.LoadError {
  if k < 1 || k > 256 {
    raise @core.LoadError::DecodeFailed("k 必须在 1..256 之间")
  }
  if img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("k_means_quantize 需要 RGB/RGBA 图像")
  }
  let ch = img.channels
  let n = img.width * img.height
  if n == 0 {
    return img
  }
  // 初始化聚类中心：均匀采样
  let centroids_r : Array[Int] = Array::make(k, 0)
  let centroids_g : Array[Int] = Array::make(k, 0)
  let centroids_b : Array[Int] = Array::make(k, 0)
  let step = if n > k { n / k } else { 1 }
  for i in 0..<k {
    let idx = (i * step).clamp(min=0, max=n - 1)
    centroids_r[i] = img.data[idx * ch].to_int()
    centroids_g[i] = img.data[idx * ch + 1].to_int()
    centroids_b[i] = img.data[idx * ch + 2].to_int()
  }
  // 迭代
  let labels : Array[Int] = Array::make(n, 0)
  let iters = if max_iters < 1 { 20 } else { max_iters }
  for _ in 0..<iters {
    // 分配每个像素到最近的聚类
    let mut changed = false
    for i in 0..<n {
      let r = img.data[i * ch].to_int()
      let g = img.data[i * ch + 1].to_int()
      let b = img.data[i * ch + 2].to_int()
      let mut best = 0
      let mut best_dist = dist_sq(r, g, b, centroids_r[0], centroids_g[0], centroids_b[0])
      for j in 1..<k {
        let d = dist_sq(r, g, b, centroids_r[j], centroids_g[j], centroids_b[j])
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

    // 更新聚类中心
    let sum_r : Array[Int] = Array::make(k, 0)
    let sum_g : Array[Int] = Array::make(k, 0)
    let sum_b : Array[Int] = Array::make(k, 0)
    let cnt : Array[Int] = Array::make(k, 0)
    for i in 0..<n {
      let label = labels[i]
      sum_r[label] += img.data[i * ch].to_int()
      sum_g[label] += img.data[i * ch + 1].to_int()
      sum_b[label] += img.data[i * ch + 2].to_int()
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
  // 生成输出
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for i in 0..<n {
    let label = labels[i]
    out[i * ch] = centroids_r[label].to_byte()
    out[i * ch + 1] = centroids_g[label].to_byte()
    out[i * ch + 2] = centroids_b[label].to_byte()
    if ch == 4 {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @core.Image::{ width: img.width, height: img.height, channels: ch, data: Bytes::from_array(out) }
}

///|
fn dist_sq(r1 : Int, g1 : Int, b1 : Int, r2 : Int, g2 : Int, b2 : Int) -> Int {
  let dr = r1 - r2
  let dg = g1 - g2
  let db = b1 - b2
  dr * dr + dg * dg + db * db
}