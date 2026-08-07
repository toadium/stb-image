// 图像金字塔（纯 MoonBit）

///|
/// 高斯金字塔下采样。将图像尺寸减半（宽高各 /2），使用 2x2 均值滤波。
pub fn pyr_down(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("pyr_down 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let new_w = w / 2
  let new_h = h / 2
  if new_w == 0 || new_h == 0 {
    raise @core.LoadError::DecodeFailed("图像太小，无法下采样")
  }
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  for y in 0..<new_h {
    for x in 0..<new_w {
      for c in 0..<ch {
        let mut sum = 0
        let mut count = 0
        for dy in 0..<2 {
          for dx in 0..<2 {
            let sx = x * 2 + dx
            let sy = y * 2 + dy
            if sx < w && sy < h {
              sum += img.data[(sy * w + sx) * ch + c].to_int()
              count += 1
            }
          }
        }
        out[(y * new_w + x) * ch + c] = (sum / count).to_byte()
      }
    }
  }
  @core.Image::{ width: new_w, height: new_h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 拉普拉斯金字塔上采样。将图像尺寸加倍（宽高各 *2），使用双线性插值。
pub fn pyr_up(img : @core.Image) -> @core.Image raise @core.LoadError {
  if img.channels != 1 && img.channels != 3 && img.channels != 4 {
    raise @core.LoadError::DecodeFailed("pyr_up 仅支持 channels=1/3/4")
  }
  let ch = img.channels
  let w = img.width
  let h = img.height
  let new_w = w * 2
  let new_h = h * 2
  let out : Array[Byte] = Array::make(new_w * new_h * ch, b'\x00')
  for y in 0..<new_h {
    for x in 0..<new_w {
      for c in 0..<ch {
        // 双线性插值
        let fx = (Float::from_int(x) - 0.5F) / 2.0F
        let fy = (Float::from_int(y) - 0.5F) / 2.0F
        let x0 = fx.to_int().clamp(min=0, max=w - 1)
        let y0 = fy.to_int().clamp(min=0, max=h - 1)
        let x1 = (x0 + 1).clamp(min=0, max=w - 1)
        let y1 = (y0 + 1).clamp(min=0, max=h - 1)
        let wx = fx - Float::from_int(x0)
        let wy = fy - Float::from_int(y0)
        let v00 = Float::from_int(img.data[(y0 * w + x0) * ch + c].to_int())
        let v01 = Float::from_int(img.data[(y0 * w + x1) * ch + c].to_int())
        let v10 = Float::from_int(img.data[(y1 * w + x0) * ch + c].to_int())
        let v11 = Float::from_int(img.data[(y1 * w + x1) * ch + c].to_int())
        let top = v00 * (1.0F - wx) + v01 * wx
        let bot = v10 * (1.0F - wx) + v11 * wx
        let v = top * (1.0F - wy) + bot * wy
        let clamped = if v < 0.0F { 0 } else if v > 255.0F { 255 } else { v.to_int() }
        out[(y * new_w + x) * ch + c] = clamped.to_byte()
      }
    }
  }
  @core.Image::{ width: new_w, height: new_h, channels: ch, data: Bytes::from_array(out) }
}

///|
/// 构建高斯金字塔。返回各级图像（从原图到最小级），levels 为最大层数（0=自动到 1x1）。
pub fn build_gaussian_pyramid(img : @core.Image, levels : Int) -> Array[@core.Image] raise @core.LoadError {
  let result : Array[@core.Image] = [img]
  let mut current = img
  let max_levels = if levels == 0 { 100 } else { levels }
  for _ in 1..<max_levels {
    if current.width < 2 || current.height < 2 {
      break
    }
    current = pyr_down(current)
    result.push(current)
  }
  result
}

///|
/// 构建拉普拉斯金字塔。返回各级拉普拉斯图像（高斯金字塔相邻层之差）。
/// 最后一层为高斯金字塔的最小级（不加差）。
pub fn build_laplacian_pyramid(img : @core.Image, levels : Int) -> Array[@core.Image] raise @core.LoadError {
  let gaussian = build_gaussian_pyramid(img, levels)
  let result : Array[@core.Image] = []
  for i in 0..<(gaussian.length() - 1) {
    let upsampled = pyr_up(gaussian[i + 1])
    let lap = laplacian_diff(gaussian[i], upsampled)
    result.push(lap)
  }
  result.push(gaussian[gaussian.length() - 1])
  result
}

///|
fn laplacian_diff(a : @core.Image, b : @core.Image) -> @core.Image {
  let ch = a.channels
  let w = a.width
  let h = a.height
  let out : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let va = a.data[(y * w + x) * ch + c].to_int()
        let bx = (x * b.width / w).clamp(min=0, max=b.width - 1)
        let by = (y * b.height / h).clamp(min=0, max=b.height - 1)
        let vb = b.data[(by * b.width + bx) * ch + c].to_int()
        let diff = va - vb + 128
        let clamped = if diff < 0 { 0 } else if diff > 255 { 255 } else { diff }
        out[(y * w + x) * ch + c] = clamped.to_byte()
      }
    }
  }
  @core.Image::{ width: w, height: h, channels: ch, data: Bytes::from_array(out) }
}