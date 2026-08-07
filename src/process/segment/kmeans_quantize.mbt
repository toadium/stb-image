// K-means 色彩量化（纯 MoonBit）

///|
/// K-means 色彩量化。将图像颜色聚为 k 类，每类用聚类中心替代。
/// 适用于 RGB/RGBA 图像（channels=3/4），alpha 通道不变。
/// max_iters 控制最大迭代次数（默认 20）。
pub fn k_means_quantize(
  img : @core.Image,
  k : Int,
  max_iters : Int,
) -> @core.Image raise @core.LoadError {
  if k < 1 || k > 256 {
    raise @core.LoadError::DecodeFailed("k 必须在 1..256 之间")
  }
  if img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed(
      "k_means_quantize 需要 RGB/RGBA 图像",
    )
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
  let data_int : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    data_int[i] = img.data[i].to_int()
  }
  let step = if n > k { n / k } else { 1 }
  for i in 0..<k {
    let idx = (i * step).clamp(min=0, max=n - 1)
    centroids_r[i] = data_int[idx * ch]
    centroids_g[i] = data_int[idx * ch + 1]
    centroids_b[i] = data_int[idx * ch + 2]
  }
  // 迭代
  let labels : Array[Int] = Array::make(n, 0)
  let iters = if max_iters < 1 { 20 } else { max_iters }
  for _ in 0..<iters {
    // 分配每个像素到最近的聚类
    let mut changed = false
    for i in 0..<n {
      let r = data_int[i * ch]
      let g = data_int[i * ch + 1]
      let b = data_int[i * ch + 2]
      let mut best = 0
      let mut best_dist = dist_sq(
        r,
        g,
        b,
        centroids_r[0],
        centroids_g[0],
        centroids_b[0],
      )
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
  @core.Image::{
    width: img.width,
    height: img.height,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
fn dist_sq(r1 : Int, g1 : Int, b1 : Int, r2 : Int, g2 : Int, b2 : Int) -> Int {
  let dr = r1 - r2
  let dg = g1 - g2
  let db = b1 - b2
  dr * dr + dg * dg + db * db
}
