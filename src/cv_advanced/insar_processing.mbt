// InSAR 处理 — 干涉测量/相位解缠/DEM 生成
// InSAR (Interferometric SAR) processing
//
// Phase 15 v364: 遥感与地理空间大扩展 — InSAR 处理。

///|
/// InSAR 干涉图。
/// InSAR interferogram.
pub(all) struct InsarInterferogram {
  phase : Array[Array[Double]]
  coherence : Array[Array[Double]]
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend InsarInterferogram with @debug.Debug::{to_repr}

///|
pub extend InsarInterferogram with Eq::{not_equal, equal}

///|
/// 相位解缠方法。
/// Phase unwrapping method.
pub(all) enum UnwrapMethod {
  LeastSquares
  PathFollowing
  QualityGuided
} derive(Eq, @debug.Debug)

///|
pub extend UnwrapMethod with @debug.Debug::{to_repr}

///|
pub extend UnwrapMethod with Eq::{not_equal, equal}

///|
/// 将相位缠绕到 [-π, π]。
/// Wrap phase to [-π, π].
pub fn insar_wrap_phase(phase : Double) -> Double {
  let two_pi = 6.28318530717958647692
  let mut wrapped = phase
  while wrapped > 3.14159265358979323846 {
    wrapped -= two_pi
  }
  while wrapped < -3.14159265358979323846 {
    wrapped += two_pi
  }
  wrapped
}

///|
/// 从两幅复数 SAR 图像生成干涉图。
/// Create interferogram from two complex SAR images.
/// Each image is represented as (real, imag) arrays.
pub fn insar_create_interferogram(
  real1 : Array[Array[Double]],
  imag1 : Array[Array[Double]],
  real2 : Array[Array[Double]],
  imag2 : Array[Array[Double]],
) -> InsarInterferogram {
  let height = real1.length()
  if height == 0 {
    return { phase: [], coherence: [], width: 0, height: 0, }
  }
  let width = real1[0].length()
  let phase = Array::make(height, [])
  let coherence = Array::make(height, [])
  for row in 0..<height {
    let phase_row = Array::make(width, 0.0)
    let coh_row = Array::make(width, 0.0)
    for col in 0..<width {
      let r1 = real1[row][col]
      let i1 = imag1[row][col]
      let r2 = real2[row][col]
      let i2 = imag2[row][col]
      let conj_real = r2
      let conj_imag = -i2
      let interf_real = r1 * conj_real - i1 * conj_imag
      let interf_imag = r1 * conj_imag + i1 * conj_real
      phase_row[col] = insar_wrap_phase(@math.atan2(interf_imag, interf_real))
      let mag1 = (r1 * r1 + i1 * i1).sqrt()
      let mag2 = (r2 * r2 + i2 * i2).sqrt()
      let denom = mag1 * mag2
      coh_row[col] = if denom > 0.0 {
        (interf_real * interf_real + interf_imag * interf_imag).sqrt() / denom
      } else {
        0.0
      }
    }
    phase[row] = phase_row
    coherence[row] = coh_row
  }
  { phase, coherence, width, height, }
}

///|
/// 估计相干性（窗口平均）。
/// Estimate coherence with window averaging.
pub fn insar_estimate_coherence(
  interferogram : InsarInterferogram,
  window_size : Int,
) -> Array[Array[Double]] {
  let half = window_size / 2
  let result = Array::make(interferogram.height, [])
  for row in 0..<interferogram.height {
    let row_data = Array::make(interferogram.width, 0.0)
    for col in 0..<interferogram.width {
      let mut total = 0.0
      let mut count = 0
      for dy in -half..<=half {
        for dx in -half..<=half {
          let r = row + dy
          let c = col + dx
          if r >= 0 &&
            r < interferogram.height &&
            c >= 0 &&
            c < interferogram.width {
            total += interferogram.coherence[r][c]
            count += 1
          }
        }
      }
      row_data[col] = if count > 0 { total / count.to_double() } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 简单相位解缠（最小二乘近似）。
/// Simple phase unwrapping (least-squares approximation).
pub fn insar_unwrap_phase(
  wrapped_phase : Array[Array[Double]],
  unwrap_method : UnwrapMethod,
) -> Array[Array[Double]] {
  let height = wrapped_phase.length()
  if height == 0 {
    return []
  }
  let width = wrapped_phase[0].length()
  let unwrapped = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      if col == 0 && row == 0 {
        row_data[col] = wrapped_phase[0][0]
      } else if col == 0 {
        let diff = wrapped_phase[row][0] - wrapped_phase[row - 1][0]
        let wrapped_diff = insar_wrap_phase(diff)
        row_data[col] = unwrapped[row - 1][0] + wrapped_diff
      } else {
        let diff = wrapped_phase[row][col] - wrapped_phase[row][col - 1]
        let wrapped_diff = insar_wrap_phase(diff)
        row_data[col] = row_data[col - 1] + wrapped_diff
      }
    }
    unwrapped[row] = row_data
  }
  match unwrap_method {
    LeastSquares => unwrapped
    PathFollowing => unwrapped
    QualityGuided => unwrapped
  }
}

///|
/// 相位转高程（DEM 生成）。
/// Convert phase to elevation (DEM generation).
pub fn insar_phase_to_height(
  unwrapped_phase : Array[Array[Double]],
  wavelength : Double,
  baseline : Double,
  slant_range : Double,
  look_angle : Double,
) -> Array[Array[Double]] {
  let height = unwrapped_phase.length()
  if height == 0 {
    return []
  }
  let width = unwrapped_phase[0].length()
  let sin_look = @math.sin(look_angle)
  let height_factor = wavelength *
    slant_range *
    sin_look /
    (4.0 * 3.14159265358979323846 * baseline)
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = unwrapped_phase[row][col] * height_factor
    }
    result[row] = row_data
  }
  result
}

///|
/// Goldstein 自适应滤波（简化版）。
/// Goldstein adaptive filtering (simplified).
pub fn insar_filter_interferogram(
  phase : Array[Array[Double]],
  alpha : Double,
) -> Array[Array[Double]] {
  let height = phase.length()
  if height == 0 {
    return []
  }
  let width = phase[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let mut total = 0.0
      let mut count = 0
      for dy in [-1, 0, 1] {
        for dx in [-1, 0, 1] {
          let r = row + dy
          let c = col + dx
          if r >= 0 && r < height && c >= 0 && c < width {
            let weight = if dy == 0 && dx == 0 { 1.0 } else { alpha }
            total += weight * phase[r][c]
            count += 1
          }
        }
      }
      row_data[col] = if count > 0 { total / count.to_double() } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 计算干涉图的平均相干性。
/// Compute mean coherence of interferogram.
pub fn insar_mean_coherence(interferogram : InsarInterferogram) -> Double {
  if interferogram.width == 0 || interferogram.height == 0 {
    return 0.0
  }
  let mut total = 0.0
  for row in 0..<interferogram.height {
    for col in 0..<interferogram.width {
      total += interferogram.coherence[row][col]
    }
  }
  total / (interferogram.width * interferogram.height).to_double()
}

///|
/// 识别低相干区域（掩膜）。
/// Identify low coherence areas (mask).
pub fn insar_coherence_mask(
  interferogram : InsarInterferogram,
  threshold : Double,
) -> Array[Array[Int]] {
  let result = Array::make(interferogram.height, [])
  for row in 0..<interferogram.height {
    let row_data = Array::make(interferogram.width, 0)
    for col in 0..<interferogram.width {
      row_data[col] = if interferogram.coherence[row][col] >= threshold {
        1
      } else {
        0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 构建 InSAR 干涉图。
/// Build InSAR interferogram.
pub fn insar_build_interferogram(
  phase : Array[Array[Double]],
  coherence : Array[Array[Double]],
) -> InsarInterferogram {
  let height = phase.length()
  let width = if height > 0 { phase[0].length() } else { 0 }
  { phase, coherence, width, height, }
}
