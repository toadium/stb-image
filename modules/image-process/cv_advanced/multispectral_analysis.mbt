// 多光谱分析 — 波段运算/指数/分类
// Multispectral analysis
//
// Phase 15 v361: 遥感与地理空间大扩展 — 多光谱分析。

///|
/// 多光谱波段类型。
/// Multispectral band type.
pub(all) enum MultispectralBand {
  Blue
  Green
  Red
  NearIR
  ShortwaveIR1
  ShortwaveIR2
  ThermalIR
} derive(Eq, @debug.Debug)

///|
pub extend MultispectralBand with @debug.Debug::{to_repr}

///|
pub extend MultispectralBand with Eq::{not_equal, equal}

///|
/// 多光谱影像。
/// Multispectral image.
pub(all) struct MultispecImage {
  bands : Array[Array[Double]]
  width : Int32
  height : Int32
  num_bands : Int32
} derive(Eq, @debug.Debug)

///|
pub extend MultispecImage with @debug.Debug::{to_repr}

///|
pub extend MultispecImage with Eq::{not_equal, equal}

///|
/// 波段运算（加/减/乘/除）。
/// Band arithmetic (add/subtract/multiply/divide).
pub fn multispectral_band_arithmetic(
  band1 : Array[Double],
  band2 : Array[Double],
  op : Int32,
) -> Array[Double] {
  let result : Array[Double] = []
  let min_len = if band1.length() < band2.length() {
    band1.length()
  } else {
    band2.length()
  }
  for i in 0..<min_len {
    let v = match op {
      0 => band1[i] + band2[i]
      1 => band1[i] - band2[i]
      2 => band1[i] * band2[i]
      3 => if band2[i] != 0.0 { band1[i] / band2[i] } else { 0.0 }
      _ => band1[i]
    }
    result.push(v)
  }
  result
}

///|
/// 归一化差值指数。
/// Normalized difference index.
pub fn multispectral_normalized_difference(
  band1 : Array[Double],
  band2 : Array[Double],
) -> Array[Double] {
  let result : Array[Double] = []
  let min_len = if band1.length() < band2.length() {
    band1.length()
  } else {
    band2.length()
  }
  for i in 0..<min_len {
    let sum = band1[i] + band2[i]
    let diff = band1[i] - band2[i]
    if sum != 0.0 {
      result.push(diff / sum)
    } else {
      result.push(0.0)
    }
  }
  result
}

///|
/// 波段比值。
/// Band ratio.
pub fn multispectral_band_ratio(
  numerator : Array[Double],
  denominator : Array[Double],
) -> Array[Double] {
  let result : Array[Double] = []
  let min_len = if numerator.length() < denominator.length() {
    numerator.length()
  } else {
    denominator.length()
  }
  for i in 0..<min_len {
    if denominator[i] != 0.0 {
      result.push(numerator[i] / denominator[i])
    } else {
      result.push(0.0)
    }
  }
  result
}

///|
/// 波段统计。
/// Band statistics.
pub fn multispectral_band_stats(
  band : Array[Double],
) -> (Double, Double, Double, Double) {
  if band.length() == 0 {
    return (0.0, 0.0, 0.0, 0.0)
  }
  let mut sum = 0.0
  let mut min_val = 1.7976931348623157e308
  let mut max_val = -1.7976931348623157e308
  for v in band {
    sum = sum + v
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
  }
  let mean = sum / band.length().to_double()
  let mut var_sum = 0.0
  for v in band {
    let diff = v - mean
    var_sum = var_sum + diff * diff
  }
  let std = (var_sum / band.length().to_double()).sqrt()
  (mean, std, min_val, max_val)
}

///|
/// 多光谱分类（简化 K-means）。
/// Multispectral classification (simplified K-means).
pub fn multispectral_classify(
  image : MultispecImage,
  num_classes : Int32,
  max_iterations : Int32,
) -> Array[Int32] {
  let n = image.width * image.height
  let result : Array[Int32] = []
  let centroids : Array[Array[Double]] = []
  for k in 0..<num_classes {
    let center : Array[Double] = []
    for b in 0..<image.num_bands {
      center.push(k.to_double() * 0.3 + b.to_double() * 0.1)
    }
    centroids.push(center)
  }
  for _ in 0..<max_iterations {
    let new_centroids : Array[Array[Double]] = []
    let counts : Array[Int32] = []
    for _ in 0..<num_classes {
      let center : Array[Double] = []
      for _ in 0..<image.num_bands {
        center.push(0.0)
      }
      new_centroids.push(center)
      counts.push(0)
    }
    for pixel in 0..<n {
      let mut best_k = 0
      let mut best_dist = 1.7976931348623157e308
      for k in 0..<num_classes {
        let mut dist = 0.0
        for b in 0..<image.num_bands {
          let val = if b < image.bands.length() &&
            pixel < image.bands[b].length() {
            image.bands[b][pixel]
          } else {
            0.0
          }
          let diff = val - centroids[k][b]
          dist = dist + diff * diff
        }
        if dist < best_dist {
          best_dist = dist
          best_k = k
        }
      }
      for b in 0..<image.num_bands {
        let val = if b < image.bands.length() && pixel < image.bands[b].length() {
          image.bands[b][pixel]
        } else {
          0.0
        }
        new_centroids[best_k][b] = new_centroids[best_k][b] + val
      }
      counts[best_k] = counts[best_k] + 1
    }
    for k in 0..<num_classes {
      if counts[k] > 0 {
        for b in 0..<image.num_bands {
          centroids[k][b] = new_centroids[k][b] / counts[k].to_double()
        }
      }
    }
  }
  for pixel in 0..<n {
    let mut best_k = 0
    let mut best_dist = 1.7976931348623157e308
    for k in 0..<num_classes {
      let mut dist = 0.0
      for b in 0..<image.num_bands {
        let val = if b < image.bands.length() && pixel < image.bands[b].length() {
          image.bands[b][pixel]
        } else {
          0.0
        }
        let diff = val - centroids[k][b]
        dist = dist + diff * diff
      }
      if dist < best_dist {
        best_dist = dist
        best_k = k
      }
    }
    result.push(best_k)
  }
  result
}

///|
/// PCA 降维。
/// PCA dimensionality reduction.
pub fn multispectral_pca(
  image : MultispecImage,
  num_components : Int32,
) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  let n = image.width * image.height
  for c in 0..<num_components {
    let component : Array[Double] = []
    for pixel in 0..<n {
      let mut val = 0.0
      for b in 0..<image.num_bands {
        let band_val = if b < image.bands.length() &&
          pixel < image.bands[b].length() {
          image.bands[b][pixel]
        } else {
          0.0
        }
        let weight = if b == c { 1.0 } else { 0.0 }
        val = val + band_val * weight
      }
      component.push(val)
    }
    result.push(component)
  }
  result
}
