// 时间序列分析 — 趋势/季节/异常/变点/平滑/预测
// Time series analysis
//
// Phase 15 v374: 遥感与地理空间大扩展 — 时间序列分析。

///|
/// 时间序列数据。
/// Time series data.
pub(all) struct TimeSeriesData {
  values : Array[Double]
  num_points : Int
} derive(Eq, @debug.Debug)

///|
pub extend TimeSeriesData with @debug.Debug::{to_repr}

///|
pub extend TimeSeriesData with Eq::{not_equal, equal}

///|
/// 构建时间序列数据。
/// Build time series data.
pub fn ts_build_data(values : Array[Double]) -> TimeSeriesData {
  { values, num_points: values.length(), }
}

///|
/// 线性趋势分析（最小二乘）。
/// Linear trend analysis (least squares).
pub fn ts_linear_trend(data : TimeSeriesData) -> (Double, Double) {
  let n = data.num_points
  if n < 2 {
    return (0.0, 0.0)
  }
  let nd = n.to_double()
  let mean_t = (nd - 1.0) / 2.0
  let mut sum_y = 0.0
  let mut sum_ty = 0.0
  for i in 0..<n {
    sum_y += data.values[i]
    sum_ty += i.to_double() * data.values[i]
  }
  let mean_y = sum_y / nd
  let mut ss_tt = 0.0
  for i in 0..<n {
    let dt = i.to_double() - mean_t
    ss_tt += dt * dt
  }
  let ss_ty = sum_ty - nd * mean_t * mean_y
  let slope = if ss_tt > 0.0 { ss_ty / ss_tt } else { 0.0 }
  let intercept = mean_y - slope * mean_t
  (slope, intercept)
}

///|
/// 移动平均平滑。
/// Moving average smoothing.
pub fn ts_moving_average(
  data : TimeSeriesData,
  window_size : Int,
) -> Array[Double] {
  let n = data.num_points
  if n == 0 || window_size <= 0 {
    return []
  }
  let half = window_size / 2
  let result = Array::make(n, 0.0)
  for i in 0..<n {
    let mut sum = 0.0
    let mut count = 0
    for j in -half..<=half {
      let idx = i + j
      if idx >= 0 && idx < n {
        sum += data.values[idx]
        count += 1
      }
    }
    result[i] = if count > 0 { sum / count.to_double() } else { 0.0 }
  }
  result
}

///|
/// 季节分解（简化版）。
/// Seasonal decomposition (simplified).
pub fn ts_seasonal_decompose(
  data : TimeSeriesData,
  period : Int,
) -> (Array[Double], Array[Double], Array[Double]) {
  let n = data.num_points
  if n == 0 || period <= 0 {
    return ([], [], [])
  }
  let trend = ts_linear_trend(data)
  let (slope, intercept) = trend
  let trend_component = Array::make(n, 0.0)
  for i in 0..<n {
    trend_component[i] = slope * i.to_double() + intercept
  }
  let detrended = Array::make(n, 0.0)
  for i in 0..<n {
    detrended[i] = data.values[i] - trend_component[i]
  }
  let seasonal = Array::make(n, 0.0)
  for phase in 0..<period {
    let mut sum = 0.0
    let mut count = 0
    let mut i = phase
    while i < n {
      sum += detrended[i]
      count += 1
      i += period
    }
    let seasonal_val = if count > 0 { sum / count.to_double() } else { 0.0 }
    let mut j = phase
    while j < n {
      seasonal[j] = seasonal_val
      j += period
    }
  }
  let residual = Array::make(n, 0.0)
  for i in 0..<n {
    residual[i] = data.values[i] - trend_component[i] - seasonal[i]
  }
  (trend_component, seasonal, residual)
}

///|
/// 异常检测（Z-score）。
/// Anomaly detection (Z-score).
pub fn ts_anomaly_detect(
  data : TimeSeriesData,
  threshold : Double,
) -> Array[Int] {
  let n = data.num_points
  if n == 0 {
    return []
  }
  let mut mean = 0.0
  for i in 0..<n {
    mean += data.values[i]
  }
  mean = mean / n.to_double()
  let mut variance = 0.0
  for i in 0..<n {
    let diff = data.values[i] - mean
    variance += diff * diff
  }
  variance = (variance / n.to_double()).sqrt()
  let result = Array::make(n, 0)
  for i in 0..<n {
    if variance > 0.0 {
      let z_score = (data.values[i] - mean) / variance
      let abs_z = if z_score < 0.0 { -z_score } else { z_score }
      result[i] = if abs_z > threshold { 1 } else { 0 }
    }
  }
  result
}

///|
/// 变点检测（均值差异）。
/// Change point detection (mean difference).
pub fn ts_change_point_detect(
  data : TimeSeriesData,
  min_segment : Int,
) -> Array[Int] {
  let n = data.num_points
  if n < 2 * min_segment {
    return []
  }
  let change_points = []
  let mut max_diff = 0.0
  let mut best_cp = -1
  for i in min_segment..<(n - min_segment) {
    let mut sum_before = 0.0
    for j in 0..<i {
      sum_before += data.values[j]
    }
    let mean_before = sum_before / i.to_double()
    let mut sum_after = 0.0
    for j in i..<n {
      sum_after += data.values[j]
    }
    let mean_after = sum_after / (n - i).to_double()
    let diff = mean_after - mean_before
    let abs_diff = if diff < 0.0 { -diff } else { diff }
    if abs_diff > max_diff {
      max_diff = abs_diff
      best_cp = i
    }
  }
  if best_cp >= 0 {
    change_points.push(best_cp)
  }
  change_points
}

///|
/// 简单预测（线性外推）。
/// Simple forecast (linear extrapolation).
pub fn ts_forecast(data : TimeSeriesData, num_steps : Int) -> Array[Double] {
  let (slope, intercept) = ts_linear_trend(data)
  let n = data.num_points
  let result = Array::make(num_steps, 0.0)
  for i in 0..<num_steps {
    let t = (n + i).to_double()
    result[i] = slope * t + intercept
  }
  result
}

///|
/// 计算时间序列均值。
/// Compute time series mean.
pub fn ts_mean(data : TimeSeriesData) -> Double {
  let n = data.num_points
  if n == 0 {
    return 0.0
  }
  let mut total = 0.0
  for i in 0..<n {
    total += data.values[i]
  }
  total / n.to_double()
}

///|
/// 计算时间序列标准差。
/// Compute time series standard deviation.
pub fn ts_stddev(data : TimeSeriesData) -> Double {
  let n = data.num_points
  if n == 0 {
    return 0.0
  }
  let mean = ts_mean(data)
  let mut variance = 0.0
  for i in 0..<n {
    let diff = data.values[i] - mean
    variance += diff * diff
  }
  (variance / n.to_double()).sqrt()
}
