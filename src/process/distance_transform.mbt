// 距离变换（纯 MoonBit）

///|
/// 距离变换。对二值图（非零为前景）计算每个前景像素到最近背景像素的距离。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4，取首通道）。
/// distance_type 为距离度量：1=城市距离(L1), 2=欧氏距离(L2近似), 3=棋盘距离(Linf)。
/// 返回 Float 数组，背景像素距离为 0。
pub fn distance_transform(
  img : @core.Image,
  distance_type~ : Int = 2
) -> Array[Float] raise @core.LoadError {
  if distance_type != 1 && distance_type != 2 && distance_type != 3 {
    raise @core.LoadError::DecodeFailed("distance_type 必须为 1(L1), 2(L2), 3(Linf)")
  }
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("distance_transform 仅支持 channels=1/3/4")
  }
  let w = img.width
  let h = img.height
  let n = w * h
  if n == 0 {
    return []
  }
  // 转为二值（非零为前景）
  let binary : Array[Bool] = Array::make(n, false)
  let ch = img.channels
  for i in 0..<n {
    binary[i] = img.data[i * ch].to_int() > 0
  }
  // 两遍扫描算法
  let dist : Array[Float] = Array::make(n, 10000000000.0F)
  // 初始化：背景为 0，前景为无穷大
  for i in 0..<n {
    if !binary[i] {
      dist[i] = 0.0F
    }
  }
  // 距离掩码
  let (mask1, mask2) = match distance_type {
    1 => ([(0, -1, 1.0F), (-1, 0, 1.0F)], [(0, 1, 1.0F), (1, 0, 1.0F)])
    3 => ([(0, -1, 1.0F), (-1, 0, 1.0F)], [(0, 1, 1.0F), (1, 0, 1.0F)])
    _ => ([(0, -1, 1.0F), (-1, 0, 1.0F), (-1, -1, 1.414F), (-1, 1, 1.414F)], [(0, 1, 1.0F), (1, 0, 1.0F), (1, 1, 1.414F), (1, -1, 1.414F)])
  }
  // 前向扫描（左上到右下）
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if !binary[idx] {
        continue
      }
      for m in mask1 {
        let (dx, dy, d) = m
        let nx = x + dx
        let ny = y + dy
        if nx >= 0 && nx < w && ny >= 0 && ny < h {
          let nd = dist[ny * w + nx] + d
          if nd < dist[idx] {
            dist[idx] = nd
          }
        }
      }
    }
  }
  // 反向扫描（右下到左上）
  for yy in 0..<h {
    let y = h - 1 - yy
    for xx in 0..<w {
      let x = w - 1 - xx
      let idx = y * w + x
      if !binary[idx] {
        continue
      }
      for m in mask2 {
        let (dx, dy, d) = m
        let nx = x + dx
        let ny = y + dy
        if nx >= 0 && nx < w && ny >= 0 && ny < h {
          let nd = dist[ny * w + nx] + d
          if nd < dist[idx] {
            dist[idx] = nd
          }
        }
      }
    }
  }
  dist
}

///|
/// 距离变换可视化。将距离变换结果归一化到 [0, 255] 并返回灰度图。
pub fn distance_transform_visualize(dist : Array[Float], w : Int, h : Int) -> @core.Image {
  let n = w * h
  let out : Array[Byte] = Array::make(n, b'\x00')
  if n == 0 {
    return @core.Image::{ width: 0, height: 0, channels: 1, data: Bytes::from_array([]) }
  }
  let mut max_dist = 0.0F
  for i in 0..<n {
    if dist[i] > max_dist {
      max_dist = dist[i]
    }
  }
  if max_dist > 0.0F {
    for i in 0..<n {
      let val = (dist[i] / max_dist * 255.0F).to_int()
      out[i] = val.clamp(min=0, max=255).to_byte()
    }
  }
  @core.Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out) }
}

///|
/// 骨架化（基于距离变换）。
/// 提取二值图的骨架（中轴线）。
/// 适用于灰度图（channels=1）或 RGB/RGBA 图（channels=3/4，取首通道）。
pub fn skeletonize(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("skeletonize 仅支持 channels=1/3/4")
  }
  let w = img.width
  let h = img.height
  let n = w * h
  if n == 0 {
    return img
  }
  // 计算距离变换
  let dist = distance_transform(img, distance_type=2)
  // 骨架点：局部最大值
  let ch = img.channels
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      if dist[idx] == 0.0F {
        continue
      }
      let mut is_max = true
      for dy in -1..=1 {
        for dx in -1..=1 {
          if dx == 0 && dy == 0 {
            continue
          }
          if dist[(y + dy) * w + (x + dx)] > dist[idx] {
            is_max = false
            break
          }
        }
        if !is_max {
          break
        }
      }
      if is_max {
        for c in 0..<ch {
          if ch == 1 {
            out[idx] = b'\xFF'
          } else if c < 3 {
            out[idx * ch + c] = b'\xFF'
          }
        }
        if ch == 4 {
          out[idx * ch + 3] = img.data[idx * ch + 3]
        }
      }
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}