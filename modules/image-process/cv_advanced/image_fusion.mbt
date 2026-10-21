// 影像融合 — IHS/PCA/小波/Gram-Schmidt
// Image fusion
//
// Phase 15 v371: 遥感与地理空间大扩展 — 影像融合。

///|
/// 影像融合方法。
/// Image fusion method.
pub(all) enum FusionMethod {
  Ihs
  Pca
  Wavelet
  GramSchmidt
} derive(Eq, @debug.Debug)

///|
pub extend FusionMethod with @debug.Debug::{to_repr}

///|
pub extend FusionMethod with Eq::{not_equal, equal}

///|
/// RGB 转 IHS。
/// RGB to IHS transform.
pub fn fusion_rgb_to_ihs(
  r : Double,
  g : Double,
  b : Double,
) -> (Double, Double, Double) {
  let intensity = (r + g + b) / 3.0
  let min_val = if r < g {
    if r < b {
      r
    } else {
      b
    }
  } else if g < b {
    g
  } else {
    b
  }
  let saturation = if intensity > 0.0 { 1.0 - min_val / intensity } else { 0.0 }
  let hue = if saturation == 0.0 {
    0.0
  } else {
    let denom = (r - g) * (r - g) + (r - b) * (g - b)
    if denom > 0.0 {
      let theta = @math.acos((r - 0.5 * g - 0.5 * b) / denom.sqrt())
      if g >= b {
        theta
      } else {
        6.28318530717958647692 - theta
      }
    } else {
      0.0
    }
  }
  (intensity, hue, saturation)
}

///|
/// IHS 转 RGB。
/// IHS to RGB transform.
pub fn fusion_ihs_to_rgb(
  intensity : Double,
  hue : Double,
  saturation : Double,
) -> (Double, Double, Double) {
  let h = hue * 60.0
  if h < 60.0 {
    let r = intensity * (1.0 + saturation)
    let g = intensity * (1.0 - saturation)
    let b = intensity * (1.0 - saturation)
    (r, g, b)
  } else if h < 120.0 {
    let r = intensity * (1.0 - saturation)
    let g = intensity * (1.0 + saturation)
    let b = intensity * (1.0 - saturation)
    (r, g, b)
  } else if h < 180.0 {
    let r = intensity * (1.0 - saturation)
    let g = intensity * (1.0 + saturation)
    let b = intensity * (1.0 - saturation)
    (r, g, b)
  } else if h < 240.0 {
    let r = intensity * (1.0 - saturation)
    let g = intensity * (1.0 - saturation)
    let b = intensity * (1.0 + saturation)
    (r, g, b)
  } else if h < 300.0 {
    let r = intensity * (1.0 + saturation)
    let g = intensity * (1.0 - saturation)
    let b = intensity * (1.0 - saturation)
    (r, g, b)
  } else {
    let r = intensity * (1.0 + saturation)
    let g = intensity * (1.0 - saturation)
    let b = intensity * (1.0 - saturation)
    (r, g, b)
  }
}

///|
/// IHS 融合。
/// IHS fusion.
pub fn fusion_ihs(
  multispectral : Array[Array[Array[Double]]],
  panchromatic : Array[Array[Double]],
) -> Array[Array[Array[Double]]] {
  let height = multispectral.length()
  if height == 0 {
    return []
  }
  let width = multispectral[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, [])
    for col in 0..<width {
      let bands = multispectral[row][col]
      let r = if bands.length() > 0 { bands[0] } else { 0.0 }
      let g = if bands.length() > 1 { bands[1] } else { 0.0 }
      let b = if bands.length() > 2 { bands[2] } else { 0.0 }
      let (_, hue, saturation) = fusion_rgb_to_ihs(r, g, b)
      let pan = if row < panchromatic.length() &&
        col < panchromatic[row].length() {
        panchromatic[row][col]
      } else {
        (r + g + b) / 3.0
      }
      let (new_r, new_g, new_b) = fusion_ihs_to_rgb(pan, hue, saturation)
      row_data[col] = [new_r, new_g, new_b]
    }
    result[row] = row_data
  }
  result
}

///|
/// PCA 融合（简化版）。
/// PCA fusion (simplified).
pub fn fusion_pca(
  multispectral : Array[Array[Array[Double]]],
  panchromatic : Array[Array[Double]],
) -> Array[Array[Array[Double]]] {
  let height = multispectral.length()
  if height == 0 {
    return []
  }
  let width = multispectral[0].length()
  let num_bands = multispectral[0][0].length()
  let band_means = Array::make(num_bands, 0.0)
  let mut count = 0
  for row in 0..<height {
    for col in 0..<width {
      for band in 0..<num_bands {
        band_means[band] += multispectral[row][col][band]
      }
      count += 1
    }
  }
  if count > 0 {
    for band in 0..<num_bands {
      band_means[band] = band_means[band] / count.to_double()
    }
  }
  let mut pan_mean = 0.0
  let mut pan_count = 0
  for row in 0..<panchromatic.length() {
    for col in 0..<panchromatic[row].length() {
      pan_mean += panchromatic[row][col]
      pan_count += 1
    }
  }
  if pan_count > 0 {
    pan_mean = pan_mean / pan_count.to_double()
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, [])
    for col in 0..<width {
      let bands = Array::make(num_bands, 0.0)
      let pc1 = if row < panchromatic.length() &&
        col < panchromatic[row].length() {
        panchromatic[row][col]
      } else {
        0.0
      }
      for band in 0..<num_bands {
        bands[band] = multispectral[row][col][band] +
          (pc1 - pan_mean) / num_bands.to_double()
      }
      row_data[col] = bands
    }
    result[row] = row_data
  }
  result
}

///|
/// 小波融合（简化版：均值替换高频）。
/// Wavelet fusion (simplified: mean replacement).
pub fn fusion_wavelet(
  multispectral : Array[Array[Array[Double]]],
  panchromatic : Array[Array[Double]],
) -> Array[Array[Array[Double]]] {
  let height = multispectral.length()
  if height == 0 {
    return []
  }
  let width = multispectral[0].length()
  let num_bands = multispectral[0][0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, [])
    for col in 0..<width {
      let bands = Array::make(num_bands, 0.0)
      let pan = if row < panchromatic.length() &&
        col < panchromatic[row].length() {
        panchromatic[row][col]
      } else {
        0.0
      }
      for band in 0..<num_bands {
        let ms = multispectral[row][col][band]
        bands[band] = 0.5 * ms + 0.5 * pan
      }
      row_data[col] = bands
    }
    result[row] = row_data
  }
  result
}

///|
/// Gram-Schmidt 融合。
/// Gram-Schmidt fusion.
pub fn fusion_gram_schmidt(
  multispectral : Array[Array[Array[Double]]],
  panchromatic : Array[Array[Double]],
) -> Array[Array[Array[Double]]] {
  let height = multispectral.length()
  if height == 0 {
    return []
  }
  let width = multispectral[0].length()
  let num_bands = multispectral[0][0].length()
  let mut ms_mean = 0.0
  let mut count = 0
  for row in 0..<height {
    for col in 0..<width {
      for band in 0..<num_bands {
        ms_mean += multispectral[row][col][band]
        count += 1
      }
    }
  }
  if count > 0 {
    ms_mean = ms_mean / count.to_double()
  }
  let mut pan_mean = 0.0
  let mut pan_count = 0
  for row in 0..<panchromatic.length() {
    for col in 0..<panchromatic[row].length() {
      pan_mean += panchromatic[row][col]
      pan_count += 1
    }
  }
  if pan_count > 0 {
    pan_mean = pan_mean / pan_count.to_double()
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, [])
    for col in 0..<width {
      let bands = Array::make(num_bands, 0.0)
      let pan = if row < panchromatic.length() &&
        col < panchromatic[row].length() {
        panchromatic[row][col]
      } else {
        0.0
      }
      let gs1 = pan - pan_mean
      for band in 0..<num_bands {
        let ms = multispectral[row][col][band]
        bands[band] = ms + gs1 / num_bands.to_double()
      }
      row_data[col] = bands
    }
    result[row] = row_data
  }
  result
}

///|
/// 融合分派函数。
/// Fusion dispatch function.
pub fn fusion_dispatch(
  multispectral : Array[Array[Array[Double]]],
  panchromatic : Array[Array[Double]],
  fusion_method : FusionMethod,
) -> Array[Array[Array[Double]]] {
  match fusion_method {
    Ihs => fusion_ihs(multispectral, panchromatic)
    Pca => fusion_pca(multispectral, panchromatic)
    Wavelet => fusion_wavelet(multispectral, panchromatic)
    GramSchmidt => fusion_gram_schmidt(multispectral, panchromatic)
  }
}

///|
/// 计算融合质量指标（均值）。
/// Compute fusion quality metric (mean).
pub fn fusion_quality_mean(fused : Array[Array[Array[Double]]]) -> Double {
  let height = fused.length()
  if height == 0 {
    return 0.0
  }
  let mut total = 0.0
  let mut count = 0
  for row in 0..<height {
    for col in 0..<fused[row].length() {
      for band in 0..<fused[row][col].length() {
        total += fused[row][col][band]
        count += 1
      }
    }
  }
  if count > 0 {
    total / count.to_double()
  } else {
    0.0
  }
}
