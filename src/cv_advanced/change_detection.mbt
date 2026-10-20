// 变化检测 — 差值/比值/对数比值/变化向量/多时相分析
// Change detection for multi-temporal remote sensing
//
// Phase 15 v365: 遥感与地理空间大扩展 — 变化检测。

///|
/// 变化检测方法。
/// Change detection method.
pub(all) enum ChangeMethod {
  Difference
  Ratio
  LogRatio
  ChangeVector
} derive(Eq, @debug.Debug)

///|
pub extend ChangeMethod with @debug.Debug::{to_repr}

///|
pub extend ChangeMethod with Eq::{not_equal, equal}

///|
/// 变化检测结果。
/// Change detection result.
pub(all) struct ChangeResult {
  change_map : Array[Array[Double]]
  binary_map : Array[Array[Int]]
  threshold : Double
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend ChangeResult with @debug.Debug::{to_repr}

///|
pub extend ChangeResult with Eq::{not_equal, equal}

///|
/// 图像差值变化检测。
/// Image differencing change detection.
pub fn change_difference(
  image1 : Array[Array[Double]],
  image2 : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = image1.length()
  if height == 0 {
    return []
  }
  let width = image1[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = image2[row][col] - image1[row][col]
    }
    result[row] = row_data
  }
  result
}

///|
/// 图像比值变化检测。
/// Image ratioing change detection.
pub fn change_ratio(
  image1 : Array[Array[Double]],
  image2 : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = image1.length()
  if height == 0 {
    return []
  }
  let width = image1[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = image1[row][col]
      row_data[col] = if denom != 0.0 { image2[row][col] / denom } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 对数比值变化检测（适用于 SAR）。
/// Log-ratio change detection (suitable for SAR).
pub fn change_log_ratio(
  image1 : Array[Array[Double]],
  image2 : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = image1.length()
  if height == 0 {
    return []
  }
  let width = image1[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let v1 = image1[row][col]
      let v2 = image2[row][col]
      if v1 > 0.0 && v2 > 0.0 {
        row_data[col] = @math.log2(v2 / v1) * 0.6931471805599453
      } else {
        row_data[col] = 0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 变化向量分析（多波段）。
/// Change vector analysis (multi-band).
pub fn change_vector_analysis(
  image1 : Array[Array[Array[Double]]],
  image2 : Array[Array[Array[Double]]],
) -> Array[Array[Double]] {
  let height = image1.length()
  if height == 0 {
    return []
  }
  let width = image1[0].length()
  let num_bands = image1[0][0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let mut sum_sq = 0.0
      for band in 0..<num_bands {
        let diff = image2[row][col][band] - image1[row][col][band]
        sum_sq += diff * diff
      }
      row_data[col] = sum_sq.sqrt()
    }
    result[row] = row_data
  }
  result
}

///|
/// Otsu 自动阈值分割。
/// Otsu automatic thresholding.
pub fn change_otsu_threshold(
  change_map : Array[Array[Double]],
  num_bins : Int,
) -> Double {
  let height = change_map.length()
  if height == 0 {
    return 0.0
  }
  let width = change_map[0].length()
  let mut min_val = 1.7976931348623157e308
  let mut max_val = -1.7976931348623157e308
  for row in 0..<height {
    for col in 0..<width {
      let v = change_map[row][col]
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
  }
  if max_val <= min_val {
    return min_val
  }
  let bin_width = (max_val - min_val) / num_bins.to_double()
  let histogram = Array::make(num_bins, 0)
  for row in 0..<height {
    for col in 0..<width {
      let bin_idx = ((change_map[row][col] - min_val) / bin_width).to_int()
      let bin_idx = if bin_idx >= num_bins { num_bins - 1 } else { bin_idx }
      histogram[bin_idx] += 1
    }
  }
  let total = (width * height).to_double()
  let mut best_threshold = min_val
  let mut max_variance = -1.0
  for t in 0..<(num_bins - 1) {
    let mut w0 = 0.0
    let mut w1 = 0.0
    let mut sum0 = 0.0
    let mut sum1 = 0.0
    for i in 0..<num_bins {
      let count = histogram[i].to_double()
      if i <= t {
        w0 += count
        sum0 += i.to_double() * count
      } else {
        w1 += count
        sum1 += i.to_double() * count
      }
    }
    if w0 > 0.0 && w1 > 0.0 {
      let mu0 = sum0 / w0
      let mu1 = sum1 / w1
      let variance = w0 * w1 * (mu0 - mu1) * (mu0 - mu1) / (total * total)
      if variance > max_variance {
        max_variance = variance
        best_threshold = min_val + (t + 1).to_double() * bin_width
      }
    }
  }
  best_threshold
}

///|
/// 应用阈值生成二值变化图。
/// Apply threshold to generate binary change map.
pub fn change_threshold(
  change_map : Array[Array[Double]],
  threshold : Double,
) -> Array[Array[Int]] {
  let height = change_map.length()
  if height == 0 {
    return []
  }
  let width = change_map[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let v = change_map[row][col]
      let abs_v = if v < 0.0 { -v } else { v }
      row_data[col] = if abs_v > threshold { 1 } else { 0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 多时相趋势分析。
/// Multi-temporal trend analysis.
pub fn change_multitemporal_trend(
  time_series : Array[Array[Array[Double]]],
) -> Array[Array[Double]] {
  let num_times = time_series.length()
  if num_times < 2 {
    return []
  }
  let height = time_series[0].length()
  if height == 0 {
    return []
  }
  let width = time_series[0][0].length()
  let result = Array::make(height, [])
  let n = num_times.to_double()
  let mean_t = (n - 1.0) / 2.0
  let mut ss_tt = 0.0
  for t in 0..<num_times {
    let dt = t.to_double() - mean_t
    ss_tt += dt * dt
  }
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let mut sum_t_y = 0.0
      let mut sum_y = 0.0
      for t in 0..<num_times {
        sum_y += time_series[t][row][col]
        sum_t_y += t.to_double() * time_series[t][row][col]
      }
      let mean_y = sum_y / n
      let ss_ty = sum_t_y - n * mean_t * mean_y
      row_data[col] = if ss_tt > 0.0 { ss_ty / ss_tt } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 变化检测主函数（分派）。
/// Main change detection function (dispatch).
pub fn change_detect(
  image1 : Array[Array[Double]],
  image2 : Array[Array[Double]],
  det_method : ChangeMethod,
  threshold : Double,
) -> ChangeResult {
  let change_map = match det_method {
    Difference => change_difference(image1, image2)
    Ratio => change_ratio(image1, image2)
    LogRatio => change_log_ratio(image1, image2)
    ChangeVector => change_difference(image1, image2)
  }
  let binary_map = change_threshold(change_map, threshold)
  let height = change_map.length()
  let width = if height > 0 { change_map[0].length() } else { 0 }
  { change_map, binary_map, threshold, width, height, }
}

///|
/// 统计变化像素数量。
/// Count changed pixels.
pub fn change_count_changed(binary_map : Array[Array[Int]]) -> Int {
  let height = binary_map.length()
  let mut count = 0
  for row in 0..<height {
    for col in 0..<binary_map[row].length() {
      if binary_map[row][col] == 1 {
        count += 1
      }
    }
  }
  count
}

///|
/// 计算变化率。
/// Compute change rate.
pub fn change_rate(binary_map : Array[Array[Int]]) -> Double {
  let height = binary_map.length()
  if height == 0 {
    return 0.0
  }
  let mut total = 0
  let mut changed = 0
  for row in 0..<height {
    for col in 0..<binary_map[row].length() {
      total += 1
      if binary_map[row][col] == 1 {
        changed += 1
      }
    }
  }
  if total > 0 {
    changed.to_double() / total.to_double()
  } else {
    0.0
  }
}
