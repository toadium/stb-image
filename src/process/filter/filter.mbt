// 图像滤波/卷积（纯 MoonBit）
// box_blur / gaussian_blur / sharpen / edge_detect_sobel

///|
fn clamp_coord(v : Int, max : Int) -> Int {
  if v < 0 {
    0
  } else if v >= max {
    max - 1
  } else {
    v
  }
}

///|
/// 盒模糊（均值滤波）。radius 为模糊半径，窗口大小 = 2*radius+1。
/// 使用可分离滑动窗口，O(n) 复杂度。仅模糊颜色通道，alpha 不变。
pub fn box_blur(img : @types.Image, radius : Int) -> @types.Image {
  if radius <= 0 {
    return img
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let n = w * h
  let win_size = 2 * radius + 1
  // 水平模糊：img -> temp
  let temp : Array[Int] = Array::make(n * color_ch, 0)
  for y in 0..<h {
    for c in 0..<color_ch {
      let mut sum = 0
      for dx in 0..<win_size {
        let x = clamp_coord(dx - radius, w)
        sum += img.data[(y * w + x) * ch + c].to_int()
      }
      for x in 0..<w {
        temp[(y * w + x) * color_ch + c] = sum / win_size
        let x_out = clamp_coord(x - radius, w)
        let x_in = clamp_coord(x + radius + 1, w)
        sum = sum -
          img.data[(y * w + x_out) * ch + c].to_int() +
          img.data[(y * w + x_in) * ch + c].to_int()
      }
    }
  }
  // 垂直模糊：temp -> out
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for x in 0..<w {
    for c in 0..<color_ch {
      let mut sum = 0
      for dy in 0..<win_size {
        let y = clamp_coord(dy - radius, h)
        sum += temp[(y * w + x) * color_ch + c]
      }
      for y in 0..<h {
        out[(y * w + x) * ch + c] = (sum / win_size).to_byte()
        let y_out = clamp_coord(y - radius, h)
        let y_in = clamp_coord(y + radius + 1, h)
        sum = sum -
          temp[(y_out * w + x) * color_ch + c] +
          temp[(y_in * w + x) * color_ch + c]
      }
    }
  }
  // 复制 alpha
  if ch == 4 {
    for i in 0..<n {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 高斯模糊。radius 为核半径，sigma 为标准差。
/// 使用可分离高斯核，O(n*radius) 复杂度。仅模糊颜色通道，alpha 不变。
pub fn gaussian_blur(
  img : @types.Image,
  radius : Int,
  sigma : Float,
) -> @types.Image {
  if radius <= 0 {
    return img
  }
  let w = img.width
  let h = img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let n = w * h
  let win_size = 2 * radius + 1
  // 生成 1D 高斯核
  let kernel : Array[Float] = Array::make(win_size, 0.0F)
  let two_sigma_sq = 2.0F * sigma * sigma
  let mut ksum = 0.0F
  for i in 0..<win_size {
    let x = Float::from_int(i - radius)
    let val = @math.expf(-(x * x) / two_sigma_sq)
    kernel[i] = val
    ksum += val
  }
  // 归一化
  for i in 0..<win_size {
    kernel[i] = kernel[i] / ksum
  }
  // 预计算像素 Float 数组，避免内层循环重复类型转换
  let src : Array[Float] = Array::make(n * color_ch, 0.0F)
  for i in 0..<n {
    for c in 0..<color_ch {
      src[i * color_ch + c] = Float::from_int(img.data[i * ch + c].to_int())
    }
  }
  // 水平模糊：src -> temp (Float)，分离内部/边界区域
  let temp : Array[Float] = Array::make(n * color_ch, 0.0F)
  let x_inner_start = if radius >= w { w } else { radius }
  let x_inner_end = if radius >= w { w } else { w - radius }
  for y in 0..<h {
    let row_base = y * w
    for c in 0..<color_ch {
      // 内部区域：x >= radius && x < w - radius，无需 clamp_coord
      for x in x_inner_start..<x_inner_end {
        let mut acc = 0.0F
        let base = (row_base + x - radius) * color_ch + c
        for k in 0..<win_size {
          acc += kernel[k] * src[base + k * color_ch]
        }
        temp[(row_base + x) * color_ch + c] = acc
      }
      // 左边界：x < radius
      for x in 0..<x_inner_start {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sx = clamp_coord(x + k - radius, w)
          acc += kernel[k] * src[(row_base + sx) * color_ch + c]
        }
        temp[(row_base + x) * color_ch + c] = acc
      }
      // 右边界：x >= w - radius
      for x in x_inner_end..<w {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sx = clamp_coord(x + k - radius, w)
          acc += kernel[k] * src[(row_base + sx) * color_ch + c]
        }
        temp[(row_base + x) * color_ch + c] = acc
      }
    }
  }
  // 垂直模糊：temp -> out，分离内部/边界区域
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  let y_inner_start = if radius >= h { h } else { radius }
  let y_inner_end = if radius >= h { h } else { h - radius }
  for x in 0..<w {
    for c in 0..<color_ch {
      // 内部区域：y >= radius && y < h - radius
      for y in y_inner_start..<y_inner_end {
        let mut acc = 0.0F
        let base = ((y - radius) * w + x) * color_ch + c
        for k in 0..<win_size {
          acc += kernel[k] * temp[base + k * w * color_ch]
        }
        out[(y * w + x) * ch + c] = (acc + 0.5F)
          .to_int()
          .clamp(min=0, max=255)
          .to_byte()
      }
      // 上边界：y < radius
      for y in 0..<y_inner_start {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sy = clamp_coord(y + k - radius, h)
          acc += kernel[k] * temp[(sy * w + x) * color_ch + c]
        }
        out[(y * w + x) * ch + c] = (acc + 0.5F)
          .to_int()
          .clamp(min=0, max=255)
          .to_byte()
      }
      // 下边界：y >= h - radius
      for y in y_inner_end..<h {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sy = clamp_coord(y + k - radius, h)
          acc += kernel[k] * temp[(sy * w + x) * color_ch + c]
        }
        out[(y * w + x) * ch + c] = (acc + 0.5F)
          .to_int()
          .clamp(min=0, max=255)
          .to_byte()
      }
    }
  }
  // 复制 alpha
  if ch == 4 {
    for i in 0..<n {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// 锐化。amount 控制锐化强度（0.0=原图，1.0=强锐化）。
/// 使用拉普拉斯锐化卷积核。仅处理颜色通道，alpha 不变。
pub fn sharpen(img : @types.Image, amount : Float) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let n = w * h
  let center = 1.0F + 4.0F * amount
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  // 预计算像素 Int 数组
  let px : Array[Int] = Array::make(n * ch, 0)
  for i in 0..<(n * ch) {
    px[i] = img.data[i].to_int()
  }
  // 内部区域：1 <= x < w-1 && 1 <= y < h-1，无需 clamp_coord
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let base = (y * w + x) * ch
      let base_l = base - ch
      let base_r = base + ch
      let base_t = base - w * ch
      let base_b = base + w * ch
      for c in 0..<color_ch {
        let cx = px[base + c]
        let left = px[base_l + c]
        let right = px[base_r + c]
        let top = px[base_t + c]
        let bottom = px[base_b + c]
        let val = Float::from_int(cx) * center -
          amount * Float::from_int(left + right + top + bottom)
        out[base + c] = (val + 0.5F).to_int().clamp(min=0, max=255).to_byte()
      }
    }
  }
  // 边界区域：x==0 || x==w-1 || y==0 || y==h-1
  for y in 0..<h {
    for x in 0..<w {
      if x >= 1 && x < w - 1 && y >= 1 && y < h - 1 {
        continue
      }
      let base = (y * w + x) * ch
      for c in 0..<color_ch {
        let cx = px[base + c]
        let x_l = clamp_coord(x - 1, w)
        let x_r = clamp_coord(x + 1, w)
        let y_t = clamp_coord(y - 1, h)
        let y_b = clamp_coord(y + 1, h)
        let left = px[(y * w + x_l) * ch + c]
        let right = px[(y * w + x_r) * ch + c]
        let top = px[(y_t * w + x) * ch + c]
        let bottom = px[(y_b * w + x) * ch + c]
        let val = Float::from_int(cx) * center -
          amount * Float::from_int(left + right + top + bottom)
        out[base + c] = (val + 0.5F).to_int().clamp(min=0, max=255).to_byte()
      }
    }
  }
  // 复制 alpha
  if ch == 4 {
    for i in 0..<n {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(out),
  }
}

///|
/// Sobel 边缘检测。先转灰度，然后计算梯度幅值。
/// 输出为单通道灰度图（channels=1）。
pub fn edge_detect_sobel(img : @types.Image) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let n = w * h
  // 先转灰度
  let gray : Array[Int] = Array::make(n, 0)
  for i in 0..<n {
    if ch == 1 {
      gray[i] = img.data[i].to_int()
    } else {
      let r = img.data[i * ch].to_int()
      let g = img.data[i * ch + 1].to_int()
      let b = img.data[i * ch + 2].to_int()
      gray[i] = (r * 299 + g * 587 + b * 114) / 1000
    }
  }
  // Sobel 卷积
  let out : Array[Byte] = Array::make(n, b'\x00')
  // 内部区域：1 <= x < w-1 && 1 <= y < h-1，无需 clamp_coord
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      let idx = y * w + x
      let idx_l = idx - 1
      let idx_r = idx + 1
      let idx_t = idx - w
      let idx_b = idx + w
      // Gx = [-1 0 1; -2 0 2; -1 0 1]
      let gx = -gray[idx_t - 1] +
        gray[idx_t + 1] -
        2 * gray[idx_l] +
        2 * gray[idx_r] -
        gray[idx_b - 1] +
        gray[idx_b + 1]
      // Gy = [-1 -2 -1; 0 0 0; 1 2 1]
      let gy = -gray[idx_t - 1] -
        2 * gray[idx_t] -
        gray[idx_t + 1] +
        gray[idx_b - 1] +
        2 * gray[idx_b] +
        gray[idx_b + 1]
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      out[idx] = (mag + 0.5F).to_int().clamp(min=0, max=255).to_byte()
    }
  }
  // 边界区域
  for y in 0..<h {
    for x in 0..<w {
      if x >= 1 && x < w - 1 && y >= 1 && y < h - 1 {
        continue
      }
      let x_l = clamp_coord(x - 1, w)
      let x_r = clamp_coord(x + 1, w)
      let y_t = clamp_coord(y - 1, h)
      let y_b = clamp_coord(y + 1, h)
      let gx = -gray[y_t * w + x_l] +
        gray[y_t * w + x_r] -
        2 * gray[y * w + x_l] +
        2 * gray[y * w + x_r] -
        gray[y_b * w + x_l] +
        gray[y_b * w + x_r]
      let gy = -gray[y_t * w + x_l] -
        2 * gray[y_t * w + x] -
        gray[y_t * w + x_r] +
        gray[y_b * w + x_l] +
        2 * gray[y_b * w + x] +
        gray[y_b * w + x_r]
      let mag = Float::from_int(gx * gx + gy * gy).sqrt()
      out[y * w + x] = (mag + 0.5F).to_int().clamp(min=0, max=255).to_byte()
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(out),
  }
}
