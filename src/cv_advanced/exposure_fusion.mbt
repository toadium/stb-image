// 曝光融合 — Mertens/可微/多频段曝光融合
// Exposure fusion: Mertens / differentiable / multi-band
//
// Phase 16 v387: 计算摄影大扩展 — 曝光融合。

///|
/// 曝光融合方法。
/// Exposure fusion method.
pub(all) enum ExposureFusionMethod {
  Mertens // Mertens 质量权重融合
  Multiband // 多频段（拉普拉斯金字塔）融合
  WeightedAverage // 加权平均
  ContrastWeighted // 对比度加权
} derive(Eq, @debug.Debug)

///|
pub extend ExposureFusionMethod with @debug.Debug::{to_repr}

///|
pub extend ExposureFusionMethod with Eq::{not_equal, equal}

///|
/// 曝光融合参数。
/// Exposure fusion parameters.
pub(all) struct ExposureFusionParams {
  ef_method : ExposureFusionMethod
  contrast_weight : Double // 对比度权重指数
  saturation_weight : Double // 饱和度权重指数
  exposure_weight : Double // 良好曝光度权重指数
  pyramid_levels : Int32 // 金字塔层数（多频段融合用）
} derive(Eq, @debug.Debug)

///|
pub extend ExposureFusionParams with @debug.Debug::{to_repr}

///|
pub extend ExposureFusionParams with Eq::{not_equal, equal}

///|
/// 计算对比度权重。
/// Compute contrast weight: |Laplacian(L)|
fn compute_contrast_weight(
  img : @types.Image,
  x : Int32,
  y : Int32,
  c : Int32,
) -> Double {
  let w = img.width
  let h = img.height
  let pi = (y * w + x) * img.channels + c
  let center = img.data[pi].to_int().to_double()
  let mut lap = 4.0 * center
  if x > 0 {
    lap = lap -
      img.data[(y * w + x - 1) * img.channels + c].to_int().to_double()
  } else {
    lap = lap - center
  }
  if x + 1 < w {
    lap = lap -
      img.data[(y * w + x + 1) * img.channels + c].to_int().to_double()
  } else {
    lap = lap - center
  }
  if y > 0 {
    lap = lap -
      img.data[((y - 1) * w + x) * img.channels + c].to_int().to_double()
  } else {
    lap = lap - center
  }
  if y + 1 < h {
    lap = lap -
      img.data[((y + 1) * w + x) * img.channels + c].to_int().to_double()
  } else {
    lap = lap - center
  }
  lap.abs()
}

///|
/// 计算饱和度权重。
/// Compute saturation weight: std deviation of RGB channels.
fn compute_saturation_weight(
  img : @types.Image,
  x : Int32,
  y : Int32,
) -> Double {
  let ch = img.channels
  if ch < 3 {
    return 1.0
  }
  let pi = y * img.width + x
  let r = img.data[pi * ch].to_int().to_double()
  let g = img.data[pi * ch + 1].to_int().to_double()
  let b = img.data[pi * ch + 2].to_int().to_double()
  let mean = (r + g + b) / 3.0
  let dr = r - mean
  let dg = g - mean
  let db = b - mean
  (dr * dr + dg * dg + db * db).sqrt()
}

///|
/// 计算良好曝光度权重。
/// Compute well-exposedness weight: exp(-(L - 0.5)^2 / (2 * sigma^2))
fn compute_exposure_weight(
  img : @types.Image,
  x : Int32,
  y : Int32,
  c : Int32,
  sigma : Double,
) -> Double {
  let pi = (y * img.width + x) * img.channels + c
  let val = img.data[pi].to_int().to_double() / 255.0
  let diff = val - 0.5
  @math.exp(-(diff * diff) / (2.0 * sigma * sigma))
}

///|
/// 计算 Mertens 质量权重图。
/// Compute Mertens quality weight map.
pub fn compute_mertens_weights(
  img : @types.Image,
  params : ExposureFusionParams,
) -> Array[Double] {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let weights : Array[Double] = []
  let sigma = 0.2
  for y in 0..<h {
    for x in 0..<w {
      let mut weight = 1.0
      // 对比度权重
      if params.contrast_weight > 0.0 {
        let mut contrast = 0.0
        for c in 0..<ch {
          contrast = contrast + compute_contrast_weight(img, x, y, c)
        }
        contrast = contrast / ch.to_double()
        weight = weight * @math.pow(contrast + 1.0, params.contrast_weight)
      }
      // 饱和度权重
      if params.saturation_weight > 0.0 {
        let sat = compute_saturation_weight(img, x, y)
        weight = weight * @math.pow(sat + 1.0, params.saturation_weight)
      }
      // 良好曝光度权重
      if params.exposure_weight > 0.0 {
        let mut exp_w = 1.0
        for c in 0..<ch {
          exp_w = exp_w * compute_exposure_weight(img, x, y, c, sigma)
        }
        weight = weight * @math.pow(exp_w, params.exposure_weight)
      }
      weights.push(weight)
    }
  }
  weights
}

///|
/// 归一化权重图（使所有图像的权重和为 1）。
/// Normalize weight maps so sum across images = 1 at each pixel.
pub fn normalize_weights(
  weight_maps : Array[Array[Double]],
  num_pixels : Int32,
) -> Array[Array[Double]] {
  let n = weight_maps.length()
  let normalized : Array[Array[Double]] = []
  for _ in 0..<n {
    normalized.push([])
  }
  for i in 0..<num_pixels {
    let mut sum = 0.0
    for k in 0..<n {
      if i < weight_maps[k].length() {
        sum = sum + weight_maps[k][i]
      }
    }
    for k in 0..<n {
      if i < weight_maps[k].length() {
        let v = if sum > 0.0 { weight_maps[k][i] / sum } else { 0.0 }
        normalized[k].push(v)
      } else {
        normalized[k].push(0.0)
      }
    }
  }
  normalized
}

///|
/// Mertens 曝光融合。
/// Mertens exposure fusion: weighted average using quality weights.
pub fn exposure_fusion_mertens(
  images : Array[@types.Image],
  params : ExposureFusionParams,
) -> @types.Image {
  let n = images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  if n == 1 {
    return images[0]
  }
  let w = images[0].width
  let h = images[0].height
  let ch = images[0].channels
  // 计算每张图像的权重图
  let weight_maps : Array[Array[Double]] = []
  for k in 0..<n {
    weight_maps.push(compute_mertens_weights(images[k], params))
  }
  // 归一化权重
  let normalized = normalize_weights(weight_maps, w * h)
  // 加权融合
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let idx = y * w + x
        let mut sum = 0.0
        for k in 0..<n {
          let pi = (y * w + x) * ch + c
          if pi < images[k].data.length() && idx < normalized[k].length() {
            sum = sum +
              images[k].data[pi].to_int().to_double() * normalized[k][idx]
          }
        }
        data.push(sum.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 加权平均曝光融合。
/// Weighted average exposure fusion.
pub fn exposure_fusion_weighted_average(
  images : Array[@types.Image],
  weights : Array[Double],
) -> @types.Image {
  let n = images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  let w = images[0].width
  let h = images[0].height
  let ch = images[0].channels
  let mut weight_sum = 0.0
  for k in 0..<n {
    let wk = if k < weights.length() { weights[k] } else { 1.0 }
    weight_sum = weight_sum + wk
  }
  if weight_sum <= 0.0 {
    weight_sum = n.to_double()
  }
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let mut sum = 0.0
    for k in 0..<n {
      let wk = if k < weights.length() { weights[k] } else { 1.0 }
      if i < images[k].data.length() {
        sum = sum + images[k].data[i].to_int().to_double() * wk
      }
    }
    data.push((sum / weight_sum).clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 对比度加权曝光融合。
/// Contrast-weighted exposure fusion.
pub fn exposure_fusion_contrast_weighted(
  images : Array[@types.Image],
) -> @types.Image {
  let n = images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  let w = images[0].width
  let h = images[0].height
  let ch = images[0].channels
  // 计算每张图像的对比度权重
  let weight_maps : Array[Array[Double]] = []
  let default_params : ExposureFusionParams = {
    ef_method: ContrastWeighted,
    contrast_weight: 1.0,
    saturation_weight: 0.0,
    exposure_weight: 0.0,
    pyramid_levels: 3,
  }
  for k in 0..<n {
    weight_maps.push(compute_mertens_weights(images[k], default_params))
  }
  let normalized = normalize_weights(weight_maps, w * h)
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let idx = y * w + x
        let mut sum = 0.0
        for k in 0..<n {
          let pi = (y * w + x) * ch + c
          if pi < images[k].data.length() && idx < normalized[k].length() {
            sum = sum +
              images[k].data[pi].to_int().to_double() * normalized[k][idx]
          }
        }
        data.push(sum.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 多频段（拉普拉斯金字塔）曝光融合（简化版）。
/// Multi-band (Laplacian pyramid) exposure fusion (simplified).
pub fn exposure_fusion_multiband(
  images : Array[@types.Image],
  params : ExposureFusionParams,
) -> @types.Image {
  let n = images.length()
  if n == 0 {
    return { width: 0, height: 0, channels: 0, data: Bytes::from_array([]), }
  }
  if n == 1 {
    return images[0]
  }
  // 简化：用 Mertens 融合 + 多频段增强
  let base = exposure_fusion_mertens(images, params)
  let w = base.width
  let h = base.height
  let ch = base.channels
  let levels = params.pyramid_levels.clamp(min=1, max=5)
  // 多频段增强：对每张输入图像计算细节层并叠加到融合结果
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let pi = (y * w + x) * ch + c
        let base_val = base.data[pi].to_int().to_double()
        // 计算输入图像的平均细节
        let mut detail_sum = 0.0
        for k in 0..<n {
          let img_pi = (y * w + x) * ch + c
          if img_pi < images[k].data.length() {
            let img_val = images[k].data[img_pi].to_int().to_double()
            // 简化细节：与局部均值的差
            let mut local_mean = 0.0
            let mut count = 0.0
            for dy in [-1, 0, 1] {
              for dx in [-1, 0, 1] {
                let nx = x + dx
                let ny = y + dy
                if nx >= 0 && nx < w && ny >= 0 && ny < h {
                  let npi = (ny * w + nx) * ch + c
                  if npi < images[k].data.length() {
                    local_mean = local_mean +
                      images[k].data[npi].to_int().to_double()
                    count = count + 1.0
                  }
                }
              }
            }
            let mean = if count > 0.0 { local_mean / count } else { img_val }
            detail_sum = detail_sum + (img_val - mean)
          }
        }
        let avg_detail = detail_sum / n.to_double()
        // 叠加细节（按金字塔层数衰减）
        let enhanced = base_val + avg_detail * 0.5 / levels.to_double()
        data.push(enhanced.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 曝光融合流水线。
/// Exposure fusion pipeline.
pub fn exposure_fusion_pipeline(
  images : Array[@types.Image],
  params : ExposureFusionParams,
) -> @types.Image {
  match params.ef_method {
    Mertens => exposure_fusion_mertens(images, params)
    Multiband => exposure_fusion_multiband(images, params)
    WeightedAverage => exposure_fusion_weighted_average(images, [])
    ContrastWeighted => exposure_fusion_contrast_weighted(images)
  }
}

///|
/// 创建默认曝光融合参数。
/// Create default exposure fusion parameters.
pub fn default_exposure_fusion_params(
  ef_method : ExposureFusionMethod,
) -> ExposureFusionParams {
  {
    ef_method,
    contrast_weight: 1.0,
    saturation_weight: 1.0,
    exposure_weight: 1.0,
    pyramid_levels: 3,
  }
}
