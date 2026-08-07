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
pub fn box_blur(img : @core.Image, radius : Int) -> @core.Image {
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
        sum = sum - img.data[(y * w + x_out) * ch + c].to_int() +
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
        sum = sum - temp[(y_out * w + x) * color_ch + c] +
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
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 高斯模糊。radius 为核半径，sigma 为标准差。
/// 使用可分离高斯核，O(n*radius) 复杂度。仅模糊颜色通道，alpha 不变。
pub fn gaussian_blur(img : @core.Image, radius : Int, sigma : Float) -> @core.Image {
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
  // 水平模糊：img -> temp (Float)
  let temp : Array[Float] = Array::make(n * color_ch, 0.0F)
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<color_ch {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sx = clamp_coord(x + k - radius, w)
          acc += kernel[k] * Float::from_int(img.data[(y * w + sx) * ch + c].to_int())
        }
        temp[(y * w + x) * color_ch + c] = acc
      }
    }
  }
  // 垂直模糊：temp -> out
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for x in 0..<w {
    for y in 0..<h {
      for c in 0..<color_ch {
        let mut acc = 0.0F
        for k in 0..<win_size {
          let sy = clamp_coord(y + k - radius, h)
          acc += kernel[k] * temp[(sy * w + x) * color_ch + c]
        }
        out[(y * w + x) * ch + c] = (acc + 0.5F).to_int().clamp(min=0, max=255).to_byte()
      }
    }
  }
  // 复制 alpha
  if ch == 4 {
    for i in 0..<n {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 锐化。amount 控制锐化强度（0.0=原图，1.0=强锐化）。
/// 使用拉普拉斯锐化卷积核。仅处理颜色通道，alpha 不变。
pub fn sharpen(img : @core.Image, amount : Float) -> @core.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let color_ch = if ch >= 3 { 3 } else { ch }
  let n = w * h
  let center = 1.0F + 4.0F * amount
  let out : Array[Byte] = Array::make(n * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<color_ch {
        let cx = img.data[(y * w + x) * ch + c].to_int()
        let x_l = clamp_coord(x - 1, w)
        let x_r = clamp_coord(x + 1, w)
        let y_t = clamp_coord(y - 1, h)
        let y_b = clamp_coord(y + 1, h)
        let left = img.data[(y * w + x_l) * ch + c].to_int()
        let right = img.data[(y * w + x_r) * ch + c].to_int()
        let top = img.data[(y_t * w + x) * ch + c].to_int()
        let bottom = img.data[(y_b * w + x) * ch + c].to_int()
        let val = Float::from_int(cx) * center -
          amount * Float::from_int(left + right + top + bottom)
        out[(y * w + x) * ch + c] = (val + 0.5F).to_int().clamp(min=0, max=255).to_byte()
      }
    }
  }
  // 复制 alpha
  if ch == 4 {
    for i in 0..<n {
      out[i * ch + 3] = img.data[i * ch + 3]
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// Sobel 边缘检测。先转灰度，然后计算梯度幅值。
/// 输出为单通道灰度图（channels=1）。
pub fn edge_detect_sobel(img : @core.Image) -> @core.Image {
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
  for y in 0..<h {
    for x in 0..<w {
      let x_l = clamp_coord(x - 1, w)
      let x_r = clamp_coord(x + 1, w)
      let y_t = clamp_coord(y - 1, h)
      let y_b = clamp_coord(y + 1, h)
      // Gx = [-1 0 1; -2 0 2; -1 0 1]
      let gx = -gray[y_t * w + x_l] + gray[y_t * w + x_r] -
        2 * gray[y * w + x_l] +
        2 * gray[y * w + x_r] -
        gray[y_b * w + x_l] +
        gray[y_b * w + x_r]
      // Gy = [-1 -2 -1; 0 0 0; 1 2 1]
      let gy = -gray[y_t * w + x_l] -
        2 * gray[y_t * w + x] -
        gray[y_t * w + x_r] +
        gray[y_b * w + x_l] +
        2 * gray[y_b * w + x] +
        gray[y_b * w + x_r]
      // magnitude = sqrt(Gx^2 + Gy^2)
      let mag = (Float::from_int(gx * gx + gy * gy)).sqrt()
      out[y * w + x] = (mag + 0.5F).to_int().clamp(min=0, max=255).to_byte()
    }
  }
  @core.Image::{ width: w, height: h, channels: 1, data: Bytes::from_array(out) }
}