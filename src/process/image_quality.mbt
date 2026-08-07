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
/// 返回 Double 类型的 SSIM 值，范围 [-1, 1]，越接近 1 越相似。
pub fn ssim(img1 : @core.Image, img2 : @core.Image) -> Double {
  let w = img1.width
  let h = img1.height
  let ch = img1.channels
  let c1 = 0.01 * 255.0 * (0.01 * 255.0)
  let c2 = 0.03 * 255.0 * (0.03 * 255.0)
  let mut total : Double = 0.0
  let mut count = 0
  let win = 8
  for y in 0..<h {
    for x in 0..<w {
      let mut mu1 : Double = 0.0
      let mut mu2 : Double = 0.0
      let mut n = 0
      for dy in 0..<win {
        for dx in 0..<win {
          let sx = clamp_i(x + dx - win / 2, 0, w - 1)
          let sy = clamp_i(y + dy - win / 2, 0, h - 1)
          for c in 0..<ch {
            mu1 += img1.data[(sy * w + sx) * ch + c].to_int().to_double()
            mu2 += img2.data[(sy * w + sx) * ch + c].to_int().to_double()
            n += 1
          }
        }
      }
      mu1 /= n.to_double()
      mu2 /= n.to_double()
      let mut var1 : Double = 0.0
      let mut var2 : Double = 0.0
      let mut cov : Double = 0.0
      for dy in 0..<win {
        for dx in 0..<win {
          let sx = clamp_i(x + dx - win / 2, 0, w - 1)
          let sy = clamp_i(y + dy - win / 2, 0, h - 1)
          for c in 0..<ch {
            let v1 = img1.data[(sy * w + sx) * ch + c].to_int().to_double() -
              mu1
            let v2 = img2.data[(sy * w + sx) * ch + c].to_int().to_double() -
              mu2
            var1 += v1 * v1
            var2 += v2 * v2
            cov += v1 * v2
          }
        }
      }
      var1 /= n.to_double()
      var2 /= n.to_double()
      cov /= n.to_double()
      let s = (2.0 * mu1 * mu2 + c1) *
        (2.0 * cov + c2) /
        ((mu1 * mu1 + mu2 * mu2 + c1) * (var1 + var2 + c2))
      total += s
      count += 1
    }
  }
  total / count.to_double()
}
