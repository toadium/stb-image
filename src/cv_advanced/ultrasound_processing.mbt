// 超声处理 — 斑点降噪/弹性成像/包络检测/对数压缩
// Ultrasound processing
//
// Phase 14 v349: 医学影像大扩展 — 超声处理。

///|
/// 超声成像模式。
/// Ultrasound imaging mode.
pub(all) enum UltrasoundMode {
  BMode
  MMode
  DopplerMode
  ColorMode
  PowerMode
} derive(Eq, @debug.Debug)

///|
pub extend UltrasoundMode with @debug.Debug::{to_repr}

///|
pub extend UltrasoundMode with Eq::{not_equal, equal}

///|
/// 超声配置。
/// Ultrasound configuration.
pub(all) struct UltrasoundConfig {
  frequency : Double
  speed_of_sound : Double
  mode : UltrasoundMode
} derive(Eq, @debug.Debug)

///|
pub extend UltrasoundConfig with @debug.Debug::{to_repr}

///|
pub extend UltrasoundConfig with Eq::{not_equal, equal}

///|
/// 弹性成像结果。
/// Elastography result.
pub(all) struct ElastographyResult {
  strain : Array[Double]
  elasticity : Array[Double]
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend ElastographyResult with @debug.Debug::{to_repr}

///|
pub extend ElastographyResult with Eq::{not_equal, equal}

///|
/// 斑点降噪（Lee 滤波）。
/// Speckle noise reduction (Lee filter).
pub fn ultrasound_speckle_reduction(
  image : Array[Double],
  width : Int,
  height : Int,
  window_size : Int,
) -> Array[Double] {
  let n = width * height
  let result : Array[Double] = []
  let half = window_size / 2
  let noise_variance = 0.4
  for y in 0..<height {
    for x in 0..<width {
      let mut sum = 0.0
      let mut count = 0.0
      for dy in [-half, 0, half] {
        for dx in [-half, 0, half] {
          let ny = y + dy
          let nx = x + dx
          if ny >= 0 && ny < height && nx >= 0 && nx < width {
            let idx = ny * width + nx
            if idx < image.length() {
              sum = sum + image[idx]
              count = count + 1.0
            }
          }
        }
      }
      if count > 0.0 {
        let local_mean = sum / count
        let mut local_var = 0.0
        for dy in [-half, 0, half] {
          for dx in [-half, 0, half] {
            let ny = y + dy
            let nx = x + dx
            if ny >= 0 && ny < height && nx >= 0 && nx < width {
              let idx = ny * width + nx
              if idx < image.length() {
                let diff = image[idx] - local_mean
                local_var = local_var + diff * diff
              }
            }
          }
        }
        local_var = local_var / count
        let idx = y * width + x
        let center_val = if idx < image.length() { image[idx] } else { 0.0 }
        let denom = local_var + noise_variance * local_mean * local_mean
        let weight = if denom > 0.0 { local_var / denom } else { 0.0 }
        result.push(center_val + weight * (local_mean - center_val))
      } else {
        let idx = y * width + x
        result.push(if idx < image.length() { image[idx] } else { 0.0 })
      }
    }
  }
  let _ = n
  result
}

///|
/// 包络检测（Hilbert 变换近似）。
/// Envelope detection (Hilbert transform approximation).
pub fn ultrasound_envelope_detection(
  rf_signal : Array[Double],
) -> Array[Double] {
  let n = rf_signal.length()
  let result : Array[Double] = []
  let window = 5
  let half = window / 2
  for i in 0..<n {
    let mut hilbert_im = 0.0
    for k in 1..<(half + 1) {
      let idx1 = i + k
      let idx2 = i - k
      let v1 = if idx1 < n { rf_signal[idx1] } else { 0.0 }
      let v2 = if idx2 >= 0 && idx2 < n { rf_signal[idx2] } else { 0.0 }
      hilbert_im = hilbert_im + (v1 - v2) * (1.0 / k.to_double())
    }
    hilbert_im = hilbert_im * (2.0 / 3.141592653589793)
    let real = rf_signal[i]
    result.push((real * real + hilbert_im * hilbert_im).sqrt())
  }
  result
}

///|
/// 对数压缩。
/// Logarithmic compression.
pub fn ultrasound_log_compression(
  image : Array[Double],
  dynamic_range : Double,
  gain : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  for i in 0..<image.length() {
    let val = image[i]
    if val > 0.0 {
      let compressed = gain *
        @math.log2(val + 1.0) /
        @math.log2(dynamic_range + 1.0)
      result.push(compressed)
    } else {
      result.push(0.0)
    }
  }
  result
}

///|
/// 扫描转换（极坐标转笛卡尔）。
/// Scan conversion (polar to Cartesian).
pub fn ultrasound_scan_conversion(
  polar_data : Array[Double],
  num_lines : Int,
  num_samples : Int,
  max_depth : Double,
  output_width : Int,
  output_height : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  let cx = output_width / 2
  let cy = 0
  for y in 0..<output_height {
    for x in 0..<output_width {
      let dx = x - cx
      let dy = y - cy
      let radius = (dx.to_double() * dx.to_double() +
      dy.to_double() * dy.to_double()).sqrt()
      let angle = @math.atan2(dx.to_double(), dy.to_double())
      let depth = radius / output_height.to_double() * max_depth
      let line_idx = ((angle + 3.141592653589793) /
      (2.0 * 3.141592653589793) *
      num_lines.to_double()).to_int()
      let sample_idx = (depth / max_depth * num_samples.to_double()).to_int()
      let valid_line = line_idx >= 0 && line_idx < num_lines
      let valid_sample = sample_idx >= 0 && sample_idx < num_samples
      if valid_line && valid_sample {
        let idx = line_idx * num_samples + sample_idx
        result.push(
          if idx < polar_data.length() {
            polar_data[idx]
          } else {
            0.0
          },
        )
      } else {
        result.push(0.0)
      }
    }
  }
  result
}

///|
/// 弹性成像（应变计算）。
/// Elastography (strain computation).
pub fn ultrasound_elastography(
  pre_image : Array[Double],
  post_image : Array[Double],
  width : Int,
  height : Int,
  window_size : Int,
) -> ElastographyResult {
  let strain : Array[Double] = []
  let elasticity : Array[Double] = []
  let half = window_size / 2
  for y in 0..<height {
    for x in 0..<width {
      let mut pre_sum = 0.0
      let mut post_sum = 0.0
      let mut count = 0.0
      for dy in [-half, 0, half] {
        for dx in [-half, 0, half] {
          let ny = y + dy
          let nx = x + dx
          if ny >= 0 && ny < height && nx >= 0 && nx < width {
            let idx = ny * width + nx
            if idx < pre_image.length() && idx < post_image.length() {
              pre_sum = pre_sum + pre_image[idx]
              post_sum = post_sum + post_image[idx]
              count = count + 1.0
            }
          }
        }
      }
      if count > 0.0 {
        let pre_mean = pre_sum / count
        let post_mean = post_sum / count
        let s = if pre_mean > 0.0 {
          (post_mean - pre_mean) / pre_mean
        } else {
          0.0
        }
        strain.push(s)
        let e = if s > 0.0 { 1.0 / s } else { 1000000.0 }
        elasticity.push(e)
      } else {
        strain.push(0.0)
        elasticity.push(0.0)
      }
    }
  }
  ElastographyResult::{ strain, elasticity, width, height, }
}

///|
/// 多普勒频移计算。
/// Doppler frequency shift computation.
pub fn ultrasound_doppler_shift(
  transmitted_freq : Double,
  reflected_freq : Double,
  speed_of_sound : Double,
) -> Double {
  let delta_f = reflected_freq - transmitted_freq
  let v = delta_f * speed_of_sound / (2.0 * transmitted_freq)
  v
}

///|
/// 时间增益补偿。
/// Time gain compensation.
pub fn ultrasound_time_gain_compensation(
  image : Array[Double],
  width : Int,
  height : Int,
  attenuation : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  for y in 0..<height {
    let depth = y.to_double()
    let gain = @math.exp(attenuation * depth)
    for x in 0..<width {
      let idx = y * width + x
      let val = if idx < image.length() { image[idx] } else { 0.0 }
      result.push(val * gain)
    }
  }
  result
}
