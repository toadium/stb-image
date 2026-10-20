// 高光谱分析 — 端元提取/丰度反演/光谱匹配
// Hyperspectral analysis
//
// Phase 15 v362: 遥感与地理空间大扩展 — 高光谱分析。

///|
/// 光谱匹配方法。
/// Spectral matching method.
pub(all) enum SpectralMatchMethod {
  SpectralAngleMapper
  SpectralInformationDivergence
  EuclideanDistance
  CorrelationCoefficient
} derive(Eq, @debug.Debug)

///|
pub extend SpectralMatchMethod with @debug.Debug::{to_repr}

///|
pub extend SpectralMatchMethod with Eq::{not_equal, equal}

///|
/// 端元提取结果。
/// Endmember extraction result.
pub(all) struct EndmemberResult {
  endmembers : Array[Array[Double]]
  abundance_maps : Array[Array[Double]]
  num_endmembers : Int
} derive(Eq, @debug.Debug)

///|
pub extend EndmemberResult with @debug.Debug::{to_repr}

///|
pub extend EndmemberResult with Eq::{not_equal, equal}

///|
/// 光谱角映射。
/// Spectral Angle Mapper.
pub fn hyperspectral_sam(
  pixel_spectrum : Array[Double],
  reference_spectrum : Array[Double],
) -> Double {
  let mut dot = 0.0
  let mut norm1 = 0.0
  let mut norm2 = 0.0
  let min_len = if pixel_spectrum.length() < reference_spectrum.length() {
    pixel_spectrum.length()
  } else {
    reference_spectrum.length()
  }
  for i in 0..<min_len {
    dot = dot + pixel_spectrum[i] * reference_spectrum[i]
    norm1 = norm1 + pixel_spectrum[i] * pixel_spectrum[i]
    norm2 = norm2 + reference_spectrum[i] * reference_spectrum[i]
  }
  if norm1 <= 0.0 || norm2 <= 0.0 {
    return 1.5707963267948966
  }
  let cos_val = dot / (norm1.sqrt() * norm2.sqrt())
  let clamped = if cos_val > 1.0 {
    1.0
  } else if cos_val < -1.0 {
    -1.0
  } else {
    cos_val
  }
  @math.acos(clamped)
}

///|
/// 欧氏距离。
/// Euclidean distance.
pub fn hyperspectral_euclidean(
  pixel_spectrum : Array[Double],
  reference_spectrum : Array[Double],
) -> Double {
  let mut sum = 0.0
  let min_len = if pixel_spectrum.length() < reference_spectrum.length() {
    pixel_spectrum.length()
  } else {
    reference_spectrum.length()
  }
  for i in 0..<min_len {
    let diff = pixel_spectrum[i] - reference_spectrum[i]
    sum = sum + diff * diff
  }
  sum.sqrt()
}

///|
/// 相关系数。
/// Correlation coefficient.
pub fn hyperspectral_correlation(
  pixel_spectrum : Array[Double],
  reference_spectrum : Array[Double],
) -> Double {
  let n = if pixel_spectrum.length() < reference_spectrum.length() {
    pixel_spectrum.length()
  } else {
    reference_spectrum.length()
  }
  if n < 2 {
    return 0.0
  }
  let mut sum1 = 0.0
  let mut sum2 = 0.0
  for i in 0..<n {
    sum1 = sum1 + pixel_spectrum[i]
    sum2 = sum2 + reference_spectrum[i]
  }
  let mean1 = sum1 / n.to_double()
  let mean2 = sum2 / n.to_double()
  let mut cov = 0.0
  let mut var1 = 0.0
  let mut var2 = 0.0
  for i in 0..<n {
    let d1 = pixel_spectrum[i] - mean1
    let d2 = reference_spectrum[i] - mean2
    cov = cov + d1 * d2
    var1 = var1 + d1 * d1
    var2 = var2 + d2 * d2
  }
  if var1 <= 0.0 || var2 <= 0.0 {
    return 0.0
  }
  cov / (var1.sqrt() * var2.sqrt())
}

///|
/// 纯像元指数（N-FINDR 简化）。
/// Pixel Purity Index (simplified N-FINDR).
pub fn hyperspectral_ppi(
  data : Array[Array[Double]],
  num_bands : Int,
  num_iterations : Int,
) -> Array[Int] {
  let num_pixels = data.length()
  let scores : Array[Int] = []
  for _ in 0..<num_pixels {
    scores.push(0)
  }
  for _ in 0..<num_iterations {
    let skew : Array[Double] = []
    for b in 0..<num_bands {
      skew.push(@math.sin(b.to_double() * 0.7) * 2.0 - 1.0)
    }
    let mut max_proj = -1.7976931348623157e308
    let mut min_proj = 1.7976931348623157e308
    let mut max_idx = 0
    let mut min_idx = 0
    for p in 0..<num_pixels {
      let mut proj = 0.0
      for b in 0..<num_bands {
        let val = if b < data[p].length() { data[p][b] } else { 0.0 }
        proj = proj + val * skew[b]
      }
      if proj > max_proj {
        max_proj = proj
        max_idx = p
      }
      if proj < min_proj {
        min_proj = proj
        min_idx = p
      }
    }
    scores[max_idx] = scores[max_idx] + 1
    scores[min_idx] = scores[min_idx] + 1
  }
  scores
}

///|
/// 端元提取（基于 PPI）。
/// Endmember extraction (PPI-based).
pub fn hyperspectral_extract_endmembers(
  data : Array[Array[Double]],
  num_bands : Int,
  num_endmembers : Int,
  num_iterations : Int,
) -> Array[Array[Double]] {
  let scores = hyperspectral_ppi(data, num_bands, num_iterations)
  let candidates : Array[(Int, Int)] = []
  for i in 0..<scores.length() {
    candidates.push((i, scores[i]))
  }
  let n = candidates.length()
  for i in 0..<n {
    for j in 0..<(n - 1 - i) {
      if candidates[j].1 < candidates[j + 1].1 {
        let tmp = candidates[j]
        candidates[j] = candidates[j + 1]
        candidates[j + 1] = tmp
      }
    }
  }
  let endmembers : Array[Array[Double]] = []
  let count = if num_endmembers < candidates.length() {
    num_endmembers
  } else {
    candidates.length()
  }
  for i in 0..<count {
    let idx = candidates[i].0
    if idx < data.length() {
      endmembers.push(data[idx])
    }
  }
  endmembers
}

///|
/// 丰度反演（全约束最小二乘简化）。
/// Abundance inversion (simplified fully constrained least squares).
pub fn hyperspectral_abundance_inversion(
  pixel_spectrum : Array[Double],
  endmembers : Array[Array[Double]],
) -> Array[Double] {
  let num_endmembers = endmembers.length()
  let abundances : Array[Double] = []
  let mut total_sim = 0.0
  let sims : Array[Double] = []
  for e in 0..<num_endmembers {
    let sim = hyperspectral_correlation(pixel_spectrum, endmembers[e])
    let positive_sim = if sim > 0.0 { sim } else { 0.0 }
    sims.push(positive_sim)
    total_sim = total_sim + positive_sim
  }
  for e in 0..<num_endmembers {
    if total_sim > 0.0 {
      abundances.push(sims[e] / total_sim)
    } else {
      abundances.push(1.0 / num_endmembers.to_double())
    }
  }
  abundances
}

///|
/// 光谱匹配分类。
/// Spectral matching classification.
pub fn hyperspectral_match(
  pixel_spectrum : Array[Double],
  reference_spectra : Array[Array[Double]],
  match_method : SpectralMatchMethod,
) -> Int {
  let mut best_idx = 0
  let mut best_score = 1.7976931348623157e308
  for i in 0..<reference_spectra.length() {
    let score = match match_method {
      SpectralAngleMapper =>
        hyperspectral_sam(pixel_spectrum, reference_spectra[i])
      SpectralInformationDivergence =>
        hyperspectral_euclidean(pixel_spectrum, reference_spectra[i])
      EuclideanDistance =>
        hyperspectral_euclidean(pixel_spectrum, reference_spectra[i])
      CorrelationCoefficient => {
        let corr = hyperspectral_correlation(
          pixel_spectrum,
          reference_spectra[i],
        )
        1.0 - corr
      }
    }
    if score < best_score {
      best_score = score
      best_idx = i
    }
  }
  best_idx
}

///|
/// 构建端元提取完整结果。
/// Build complete endmember extraction result.
pub fn hyperspectral_build_endmember_result(
  data : Array[Array[Double]],
  num_bands : Int,
  num_endmembers : Int,
  num_iterations : Int,
) -> EndmemberResult {
  let endmembers = hyperspectral_extract_endmembers(
    data, num_bands, num_endmembers, num_iterations,
  )
  let abundance_maps : Array[Array[Double]] = []
  for e in 0..<endmembers.length() {
    let map : Array[Double] = []
    for p in 0..<data.length() {
      let abundances = hyperspectral_abundance_inversion(data[p], endmembers)
      let val = if e < abundances.length() { abundances[e] } else { 0.0 }
      map.push(val)
    }
    abundance_maps.push(map)
  }
  EndmemberResult::{
    endmembers,
    abundance_maps,
    num_endmembers: endmembers.length(),
  }
}
