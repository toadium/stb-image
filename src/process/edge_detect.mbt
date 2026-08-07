// 边缘检测扩展（纯 MoonBit）：edge_detect_laplacian / edge_detect_prewitt
// clamp_b 来自 pixel_advanced.mbt，clamp_i 来自 morphology.mbt

///|
/// Laplacian 边缘检测。使用 3x3 Laplacian 核：
/// [0, 1, 0; 1, -4, 1; 0, 1, 0]
/// 返回灰度图（channels=1）。
pub fn edge_detect_laplacian(img : @core.Image) -> @core.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n, b'\x00')
  // 预计算灰度 Int 数组
  let gray : Array[Int] = Array::make(n, 0)
  for i in 0..<n {
    if ch >= 3 {
      let r = img.data[i * ch].to_int()
      let g = img.data[i * ch + 1].to_int()
      let b = img.data[i * ch + 2].to_int()
      gray[i] = (r * 77 + g * 150 + b * 29) / 256
    } else {
      gray[i] = img.data[i * ch].to_int()
    }
  }
  // 内部区域：x in [1, w-1), y in [1, h-1)，直接访问 4 邻域
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      let center = gray[idx]
      let u = gray[idx - w]
      let d = gray[idx + w]
      let l = gray[idx - 1]
      let r = gray[idx + 1]
      let lap = u + d + l + r - 4 * center
      out[idx] = clamp_b(lap.abs())
    }
  }
  // 边界区域
  for y in 0..<h {
    let y_inner = y >= 1 && y < h - 1
    for x in 0..<w {
      if y_inner && x >= 1 && x < w - 1 {
        continue
      }
      let cx = clamp_i(x, 0, w - 1)
      let cy = clamp_i(y, 0, h - 1)
      let up = clamp_i(y - 1, 0, h - 1)
      let down = clamp_i(y + 1, 0, h - 1)
      let left = clamp_i(x - 1, 0, w - 1)
      let right = clamp_i(x + 1, 0, w - 1)
      let center = gray[cy * w + cx]
      let u = gray[up * w + cx]
      let d = gray[down * w + cx]
      let l = gray[cy * w + left]
      let r = gray[cy * w + right]
      let lap = u + d + l + r - 4 * center
      out[y * w + x] = clamp_b(lap.abs())
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}

///|
/// Prewitt 边缘检测。使用两个 3x3 Prewitt 核计算梯度幅值。
/// Gx = [-1, 0, 1; -1, 0, 1; -1, 0, 1]
/// Gy = [-1, -1, -1; 0, 0, 0; 1, 1, 1]
/// 返回灰度图（channels=1）。
pub fn edge_detect_prewitt(img : @core.Image) -> @core.Image {
  let ch = img.channels
  let w = img.width
  let h = img.height
  let n = w * h
  let out : Array[Byte] = Array::make(n, b'\x00')
  // 预计算灰度 Int 数组
  let gray : Array[Int] = Array::make(n, 0)
  for i in 0..<n {
    if ch >= 3 {
      let r = img.data[i * ch].to_int()
      let g = img.data[i * ch + 1].to_int()
      let b = img.data[i * ch + 2].to_int()
      gray[i] = (r * 77 + g * 150 + b * 29) / 256
    } else {
      gray[i] = img.data[i * ch].to_int()
    }
  }
  // 内部区域：x in [1, w-1), y in [1, h-1)
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      let ul = gray[idx - w - 1]
      let ur = gray[idx - w + 1]
      let ll = gray[idx + w - 1]
      let lr = gray[idx + w + 1]
      let l = gray[idx - 1]
      let r = gray[idx + 1]
      let u = gray[idx - w]
      let d = gray[idx + w]
      let gx = ur + r + lr - ul - l - ll
      let gy = ll + d + lr - ul - u - ur
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      out[idx] = clamp_b(mag.to_int())
    }
  }
  // 边界区域
  for y in 0..<h {
    let y_inner = y >= 1 && y < h - 1
    for x in 0..<w {
      if y_inner && x >= 1 && x < w - 1 {
        continue
      }
      let up = clamp_i(y - 1, 0, h - 1)
      let down = clamp_i(y + 1, 0, h - 1)
      let left = clamp_i(x - 1, 0, w - 1)
      let right = clamp_i(x + 1, 0, w - 1)
      let ul = gray[up * w + left]
      let ur = gray[up * w + right]
      let ll = gray[down * w + left]
      let lr = gray[down * w + right]
      let l = gray[y * w + left]
      let r = gray[y * w + right]
      let u = gray[up * w + x]
      let d = gray[down * w + x]
      let gx = ur + r + lr - ul - l - ll
      let gy = ll + d + lr - ul - u - ur
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      out[y * w + x] = clamp_b(mag.to_int())
    }
  }
  @core.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
