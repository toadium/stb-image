// 锐化扩展 — 反卷积/Laplacian/深度感知锐化/自适应锐化
// Sharpening enhancement: deconvolution / Laplacian / depth-aware / adaptive
//
// Phase 16 v385: 计算摄影大扩展 — 锐化扩展。

///|
/// 锐化方法类型。
/// Sharpening method type.
pub(all) enum SharpeningMethod {
  UnsharpMask // Unsharp Mask
  Laplacian // Laplacian 锐化
  WienerDeconv // Wiener 反卷积
  Adaptive // 自适应锐化
  DepthAware // 深度感知锐化
} derive(Eq, @debug.Debug)

///|
pub extend SharpeningMethod with @debug.Debug::{to_repr}

///|
pub extend SharpeningMethod with Eq::{not_equal, equal}

///|
/// 锐化参数。
/// Sharpening parameters.
pub(all) struct SharpeningParams {
  sharpen_method : SharpeningMethod
  strength : Double // 锐化强度 (0.0~2.0)
  radius : Int32 // 锐化半径
  threshold : Double // 阈值（低于此值不锐化）
  noise_level : Double // 噪声估计（用于 Wiener）
} derive(Eq, @debug.Debug)

///|
pub extend SharpeningParams with @debug.Debug::{to_repr}

///|
pub extend SharpeningParams with Eq::{not_equal, equal}

///|
/// Unsharp Mask 锐化。
/// Unsharp Mask sharpening: img + strength * (img - blurred)
pub fn sharpen_unsharp_mask(
  img : @types.Image,
  strength : Double,
  radius : Int32,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let r = radius.clamp(min=1, max=10)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        // 简化高斯模糊：均值滤波
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-r, 0, r] {
          for dx in [-r, 0, r] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch + c
              sum = sum + img.data[npi].to_int().to_double()
              count = count + 1.0
            }
          }
        }
        let blurred = if count > 0.0 { sum / count } else { center }
        // Unsharp Mask: output = center + strength * (center - blurred)
        let sharpened = center + strength * (center - blurred)
        data.push(sharpened.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// Laplacian 锐化。
/// Laplacian sharpening: img - strength * laplacian(img)
pub fn sharpen_laplacian(img : @types.Image, strength : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        // Laplacian: 4*center - up - down - left - right
        let mut lap = 4.0 * center
        let mut neighbors = 0
        if x > 0 {
          lap = lap - img.data[(y * w + x - 1) * ch + c].to_int().to_double()
          neighbors = neighbors + 1
        }
        if x + 1 < w {
          lap = lap - img.data[(y * w + x + 1) * ch + c].to_int().to_double()
          neighbors = neighbors + 1
        }
        if y > 0 {
          lap = lap - img.data[((y - 1) * w + x) * ch + c].to_int().to_double()
          neighbors = neighbors + 1
        }
        if y + 1 < h {
          lap = lap - img.data[((y + 1) * w + x) * ch + c].to_int().to_double()
          neighbors = neighbors + 1
        }
        // 补偿缺失的邻居
        lap = lap - (4.0 - neighbors.to_double()) * center
        // output = center - strength * lap
        let sharpened = center - strength * lap
        data.push(sharpened.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// Wiener 反卷积锐化。
/// Wiener deconvolution sharpening.
/// 在频域中：H_wiener = H* / (|H|^2 + K)，其中 K = noise/signal
pub fn sharpen_wiener_deconv(
  img : @types.Image,
  strength : Double,
  noise_level : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  // 简化：在空间域实现 Wiener 滤波
  // 使用一个锐化核：[0, -a, 0; -a, 1+4a, -a; 0, -a, 0]
  // 其中 a = strength / (1 + noise_level)
  let a = strength / (1.0 + noise_level.clamp(min=0.0, max=10.0))
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        let mut result = (1.0 + 4.0 * a) * center
        if x > 0 {
          result = result -
            a * img.data[(y * w + x - 1) * ch + c].to_int().to_double()
        } else {
          result = result - a * center
        }
        if x + 1 < w {
          result = result -
            a * img.data[(y * w + x + 1) * ch + c].to_int().to_double()
        } else {
          result = result - a * center
        }
        if y > 0 {
          result = result -
            a * img.data[((y - 1) * w + x) * ch + c].to_int().to_double()
        } else {
          result = result - a * center
        }
        if y + 1 < h {
          result = result -
            a * img.data[((y + 1) * w + x) * ch + c].to_int().to_double()
        } else {
          result = result - a * center
        }
        data.push(result.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 自适应锐化：根据局部方差调整锐化强度。
/// Adaptive sharpening: adjust strength based on local variance.
pub fn sharpen_adaptive(
  img : @types.Image,
  max_strength : Double,
  radius : Int32,
  threshold : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let r = radius.clamp(min=1, max=5)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        // 计算局部方差
        let mut sum = 0.0
        let mut sum_sq = 0.0
        let mut count = 0.0
        for dy in [-r, 0, r] {
          for dx in [-r, 0, r] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let npi = (ny * w + nx) * ch + c
              let val = img.data[npi].to_int().to_double()
              sum = sum + val
              sum_sq = sum_sq + val * val
              count = count + 1.0
            }
          }
        }
        let mean = if count > 0.0 { sum / count } else { center }
        let variance = if count > 0.0 {
          sum_sq / count - mean * mean
        } else {
          0.0
        }
        // 高方差区域（边缘/纹理）锐化更强，低方差区域（平滑）锐化更弱
        let local_strength = if variance > threshold {
          max_strength
        } else if variance > threshold * 0.1 {
          max_strength * (variance / threshold)
        } else {
          0.0
        }
        // Unsharp Mask
        let sharpened = center + local_strength * (center - mean)
        data.push(sharpened.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 深度感知锐化：近处锐化更强，远处锐化更弱。
/// Depth-aware sharpening: stronger for near, weaker for far.
pub fn sharpen_depth_aware(
  img : @types.Image,
  depth : DepthMap,
  strength : Double,
  near_depth : Double,
  far_depth : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let depth_range = (far_depth - near_depth).abs()
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      // 根据深度计算锐化强度
      let depth_val = if idx < depth.depths.length() && depth.valid[idx] {
        depth.depths[idx]
      } else {
        (near_depth + far_depth) / 2.0
      }
      // 近处 strength=1.0, 远处 strength=0.2
      let depth_ratio = if depth_range > 0.001 {
        ((depth_val - near_depth) / depth_range).clamp(min=0.0, max=1.0)
      } else {
        0.5
      }
      let local_strength = strength * (1.0 - 0.8 * depth_ratio)
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        // 简化 Laplacian
        let mut lap = 4.0 * center
        if x > 0 {
          lap = lap - img.data[(y * w + x - 1) * ch + c].to_int().to_double()
        } else {
          lap = lap - center
        }
        if x + 1 < w {
          lap = lap - img.data[(y * w + x + 1) * ch + c].to_int().to_double()
        } else {
          lap = lap - center
        }
        if y > 0 {
          lap = lap - img.data[((y - 1) * w + x) * ch + c].to_int().to_double()
        } else {
          lap = lap - center
        }
        if y + 1 < h {
          lap = lap - img.data[((y + 1) * w + x) * ch + c].to_int().to_double()
        } else {
          lap = lap - center
        }
        let sharpened = center - local_strength * lap
        data.push(sharpened.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 锐化流水线。
/// Sharpening pipeline.
pub fn sharpen_pipeline(
  img : @types.Image,
  params : SharpeningParams,
) -> @types.Image {
  match params.sharpen_method {
    UnsharpMask => sharpen_unsharp_mask(img, params.strength, params.radius)
    Laplacian => sharpen_laplacian(img, params.strength)
    WienerDeconv =>
      sharpen_wiener_deconv(img, params.strength, params.noise_level)
    Adaptive =>
      sharpen_adaptive(img, params.strength, params.radius, params.threshold)
    DepthAware =>
      // 无深度图时退化为 Laplacian
      sharpen_laplacian(img, params.strength)
  }
}

///|
/// 创建默认锐化参数。
/// Create default sharpening parameters.
pub fn default_sharpening_params(
  sharpen_method : SharpeningMethod,
) -> SharpeningParams {
  {
    sharpen_method,
    strength: 0.5,
    radius: 1,
    threshold: 10.0,
    noise_level: 0.01,
  }
}

///|
/// 估计图像锐度（用于评估锐化效果）。
/// Estimate image sharpness (for evaluating sharpening effect).
/// 使用 Laplacian 方差作为锐度度量。
pub fn estimate_sharpness(img : @types.Image) -> Double {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let mut sum = 0.0
  let mut sum_sq = 0.0
  let mut count = 0.0
  for y in 1..<(h - 1) {
    for x in 1..<(w - 1) {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let center = img.data[pi].to_int().to_double()
        let lap = 4.0 * center -
          img.data[(y * w + x - 1) * ch + c].to_int().to_double() -
          img.data[(y * w + x + 1) * ch + c].to_int().to_double() -
          img.data[((y - 1) * w + x) * ch + c].to_int().to_double() -
          img.data[((y + 1) * w + x) * ch + c].to_int().to_double()
        sum = sum + lap
        sum_sq = sum_sq + lap * lap
        count = count + 1.0
      }
    }
  }
  if count > 0.0 {
    let mean = sum / count
    let variance = sum_sq / count - mean * mean
    variance
  } else {
    0.0
  }
}
