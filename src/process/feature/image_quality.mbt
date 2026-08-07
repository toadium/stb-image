// 图像质量评估（纯 MoonBit）：mse / psnr / ssim

///|
/// 均方误差（MSE）。计算两幅图像对应像素的均方误差。
/// 两幅图像必须具有相同的尺寸和通道数。
/// 返回 Double 类型的 MSE 值。
pub fn mse(img1 : @core.Image, img2 : @core.Image) -> Double {
  let n = img1.data.length()
  let mut sum : Int = 0
  for i in 0..<n {
    let d = img1.data[i].to_int() - img2.data[i].to_int()
    sum += d * d
  }
  sum.to_double() / n.to_double()
}

///|
/// 峰值信噪比（PSNR）。基于 MSE 计算 PSNR（单位 dB）。
/// 若两幅图像完全相同（MSE=0），返回 Infinity。
/// 两幅图像必须具有相同的尺寸和通道数。
pub fn psnr(img1 : @core.Image, img2 : @core.Image) -> Double {
  let m = mse(img1, img2)
  if m == 0.0 {
    return 1.0 / 0.0
  }
  10.0 * @math.log10(255.0 * 255.0 / m)
}

///|
/// 结构相似性指数（SSIM）。在 8x8 局部窗口上计算 SSIM 均值。
/// 两幅图像必须具有相同的尺寸和通道数。
/// 返回 Double 类型的 SSIM 值，范围.围 [-1, 1]，越接近 1 越相似。
pub fn ssim(img1 : @core.Image, img2 : @core.Image) -> Double {
  let w = img1.width
  let h = img1.height
  let ch = img1.channels
  let n = w * h
  let c1 = 0.01 * 255.0 * (0.01 * 255.0)
  let c2 = 0.03 * 255.0 * (0.03 * 255.0)
  let win = 8
  let half = win / 2
  // 预计算 Double 数组，避免内层循环重复类型转换
  let src1 : Array[Double] = Array::make(n * ch, 0.0)
  let src2 : Array[Double] = Array::make(n * ch, 0.0)
  for i in 0..<(n * ch) {
    src1[i] = img1.data[i].to_int().to_double()
    src2[i] = img2.data[i].to_int().to_double()
  }
  let mut total : Double = 0.0
  let mut count = 0
  let inner_n = win * win * ch
  let inner_n_d = inner_n.to_double()
  // 内部区域：x in [half, w-half), y in [half, h-half)，8x8 窗口完全在图像内
  for y in half..<(h - half) {
    for x in half..<(w - half) {
      let mut mu1 : Double = 0.0
      let mut mu2 : Double = 0.0
      for dy in 0..<win {
        let row = ((y + dy - half) * w + (x - half)) * ch
        for dx in 0..<win {
          let base = row + dx * ch
          for c in 0..<ch {
            mu1 += src1[base + c]
            mu2 += src2[base + c]
          }
        }
      }
      mu1 /= inner_n_d
      mu2 /= inner_n_d
      let mut var1 : Double = 0.0
      let mut var2 : Double = 0.0
      let mut cov : Double = 0.0
      for dy in 0..<win {
        let row = ((y + dy - half) * w + (x - half)) * ch
        for dx in 0..<win {
          let base = row + dx * ch
          for c in 0..<ch {
            let v1 = src1[base + c] - mu1
            let v2 = src2[base + c] - mu2
            var1 += v1 * v1
            var2 += v2 * v2
            cov += v1 * v2
          }
        }
      }
      var1 /= inner_n_d
      var2 /= inner_n_d
      cov /= inner_n_d
      let s = (2.0 * mu1 * mu2 + c1) *
        (2.0 * cov + c2) /
        ((mu1 * mu1 + mu2 * mu2 + c1) * (var1 + var2 + c2))
      total += s
      count += 1
    }
  }
  // 边界区域
  for y in 0..<h {
    let y_inner = y >= half && y < h - half
    for x in 0..<w {
      if y_inner && x >= half && x < w - half {
        continue
      }
      let mut mu1 : Double = 0.0
      let mut mu2 : Double = 0.0
      let mut nn = 0
      for dy in 0..<win {
        for dx in 0..<win {
          let sx = clamp_i(x + dx - half, 0, w - 1)
          let sy = clamp_i(y + dy - half, 0, h - 1)
          for c in 0..<ch {
            mu1 += src1[(sy * w + sx) * ch + c]
            mu2 += src2[(sy * w + sx) * ch + c]
            nn += 1
          }
        }
      }
      mu1 /= nn.to_double()
      mu2 /= nn.to_double()
      let mut var1 : Double = 0.0
      let mut var2 : Double = 0.0
      let mut cov : Double = 0.0
      for dy in 0..<win {
        for dx in 0..<win {
          let sx = clamp_i(x + dx - half, 0, w - 1)
          let sy = clamp_i(y + dy - half, 0, h - 1)
          for c in 0..<ch {
            let v1 = src1[(sy * w + sx) * ch + c] - mu1
            let v2 = src2[(sy * w + sx) * ch + c] - mu2
            var1 += v1 * v1
            var2 += v2 * v2
            cov += v1 * v2
          }
        }
      }
      var1 /= nn.to_double()
      var2 /= nn.to_double()
      cov /= nn.to_double()
      let s = (2.0 * mu1 * mu2 + c1) *
        (2.0 * cov + c2) /
        ((mu1 * mu1 + mu2 * mu2 + c1) * (var1 + var2 + c2))
      total += s
      count += 1
    }
  }
  total / count.to_double()
}
