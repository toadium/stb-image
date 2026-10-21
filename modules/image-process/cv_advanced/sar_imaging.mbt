// SAR 成像 — RDA/CSA/ωKA 合成孔径雷达聚焦算法
// SAR (Synthetic Aperture Radar) imaging algorithms
//
// Phase 15 v363: 遥感与地理空间大扩展 — SAR 成像。

///|
/// SAR 成像算法模式。
/// SAR imaging algorithm mode.
pub(all) enum SarMode {
  RangeDoppler
  ChirpScaling
  OmegaK
} derive(Eq, @debug.Debug)

///|
pub extend SarMode with @debug.Debug::{to_repr}

///|
pub extend SarMode with Eq::{not_equal, equal}

///|
/// SAR 系统参数。
/// SAR system parameters.
pub(all) struct SarParams {
  carrier_freq : Double
  platform_velocity : Double
  pulse_duration : Double
  chirp_rate : Double
  sampling_rate : Double
  antenna_length : Double
  slant_range : Double
} derive(Eq, @debug.Debug)

///|
pub extend SarParams with @debug.Debug::{to_repr}

///|
pub extend SarParams with Eq::{not_equal, equal}

///|
/// SAR 图像（幅度数据）。
/// SAR image (magnitude data).
pub(all) struct SarImage {
  data : Array[Array[Double]]
  width : Int32
  height : Int32
  params : SarParams
} derive(Eq, @debug.Debug)

///|
pub extend SarImage with @debug.Debug::{to_repr}

///|
pub extend SarImage with Eq::{not_equal, equal}

///|
/// 构造 SAR 参数。
/// Construct SAR parameters.
pub fn sar_build_params(
  carrier_freq : Double,
  platform_velocity : Double,
  pulse_duration : Double,
  chirp_rate : Double,
  sampling_rate : Double,
  antenna_length : Double,
  slant_range : Double,
) -> SarParams {
  {
    carrier_freq,
    platform_velocity,
    pulse_duration,
    chirp_rate,
    sampling_rate,
    antenna_length,
    slant_range,
  }
}

///|
/// 生成线性调频脉冲（chirp 信号）。
/// Generate linear frequency modulated chirp pulse.
pub fn sar_simulate_chirp(
  num_samples : Int32,
  pulse_duration : Double,
  chirp_rate : Double,
) -> Array[Double] {
  let chirp = Array::make(num_samples, 0.0)
  let dt = pulse_duration / num_samples.to_double()
  for i in 0..<num_samples {
    let t = i.to_double() * dt - pulse_duration * 0.5
    let phase = 3.14159265358979323846 * chirp_rate * t * t
    chirp[i] = @math.cos(phase)
  }
  chirp
}

///|
/// 距离压缩（匹配滤波）。
/// Range compression via matched filtering.
pub fn sar_range_compression(
  raw_data : Array[Array[Double]],
  chirp_ref : Array[Double],
) -> Array[Array[Double]] {
  let height = raw_data.length()
  if height == 0 {
    return []
  }
  let width = raw_data[0].length()
  let ref_len = chirp_ref.length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let compressed = Array::make(width, 0.0)
    for col in 0..<width {
      let mut acc = 0.0
      for k in 0..<ref_len {
        let idx = col + k - ref_len / 2
        if idx >= 0 && idx < width {
          acc += raw_data[row][idx] * chirp_ref[k]
        }
      }
      compressed[col] = acc
    }
    result[row] = compressed
  }
  result
}

///|
/// 方位压缩（简化匹配滤波）。
/// Azimuth compression (simplified matched filtering).
pub fn sar_azimuth_compression(
  range_compressed : Array[Array[Double]],
  params : SarParams,
) -> Array[Array[Double]] {
  let height = range_compressed.length()
  if height == 0 {
    return []
  }
  let width = range_compressed[0].length()
  let synthetic_aperture = 2.0 *
    params.slant_range *
    params.wavelength() /
    params.antenna_length
  let az_ref_len = (synthetic_aperture /
  params.platform_velocity *
  params.sampling_rate).to_int()
  let az_ref_len = if az_ref_len > 1 && az_ref_len < height {
    az_ref_len
  } else {
    height
  }
  let az_ref = Array::make(az_ref_len, 0.0)
  for i in 0..<az_ref_len {
    let t = i.to_double() / params.sampling_rate -
      synthetic_aperture * 0.5 / params.platform_velocity
    let doppler_rate = 2.0 *
      params.platform_velocity *
      params.platform_velocity /
      (params.wavelength() * params.slant_range)
    let phase = 3.14159265358979323846 * doppler_rate * t * t
    az_ref[i] = @math.cos(phase)
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let compressed = Array::make(width, 0.0)
    for col in 0..<width {
      let mut acc = 0.0
      for k in 0..<az_ref_len {
        let idx = row + k - az_ref_len / 2
        if idx >= 0 && idx < height {
          acc += range_compressed[idx][col] * az_ref[k]
        }
      }
      compressed[col] = acc
    }
    result[row] = compressed
  }
  result
}

///|
/// 距离多普勒算法（RDA）完整流程。
/// Range Doppler Algorithm (RDA) full pipeline.
pub fn sar_rda(
  raw_data : Array[Array[Double]],
  params : SarParams,
) -> Array[Array[Double]] {
  let width = if raw_data.length() > 0 { raw_data[0].length() } else { 0 }
  let chirp_ref = sar_simulate_chirp(
    width,
    params.pulse_duration,
    params.chirp_rate,
  )
  let range_compressed = sar_range_compression(raw_data, chirp_ref)
  sar_azimuth_compression(range_compressed, params)
}

///|
/// Chirp Scaling 算法（CSA，简化版）。
/// Chirp Scaling Algorithm (CSA, simplified).
pub fn sar_csa(
  raw_data : Array[Array[Double]],
  params : SarParams,
) -> Array[Array[Double]] {
  let height = raw_data.length()
  if height == 0 {
    return []
  }
  let width = raw_data[0].length()
  let scaled = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let range_cell = col.to_double()
      let scale_factor = 1.0 +
        params.wavelength() *
        params.wavelength() *
        row.to_double() *
        row.to_double() /
        (8.0 * params.slant_range * params.slant_range * params.slant_range)
      let scaled_idx = (range_cell * scale_factor).to_int()
      if scaled_idx >= 0 && scaled_idx < width {
        row_data[col] = raw_data[row][scaled_idx]
      }
    }
    scaled[row] = row_data
  }
  sar_rda(scaled, params)
}

///|
/// Omega-K 算法（ωKA，简化版）。
/// Omega-K Algorithm (ωKA, simplified).
pub fn sar_omega_k(
  raw_data : Array[Array[Double]],
  params : SarParams,
) -> Array[Array[Double]] {
  let height = raw_data.length()
  if height == 0 {
    return []
  }
  let width = raw_data[0].length()
  let stolt_corrected = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let k_range = col.to_double() *
        2.0 *
        3.14159265358979323846 /
        width.to_double()
      let k_azimuth = row.to_double() *
        2.0 *
        3.14159265358979323846 /
        height.to_double()
      let k_r0 = 4.0 *
        3.14159265358979323846 *
        params.carrier_freq /
        299792458.0
      let discriminant = (k_r0 * k_r0 + k_r0 * k_range) *
        (k_r0 * k_r0 + k_r0 * k_range) -
        k_azimuth * k_azimuth
      if discriminant > 0.0 {
        let k_range_new = discriminant.sqrt() - k_r0
        let new_col = (k_range_new *
        width.to_double() /
        (2.0 * 3.14159265358979323846)).to_int()
        if new_col >= 0 && new_col < width {
          row_data[col] = raw_data[row][new_col]
        }
      }
    }
    stolt_corrected[row] = row_data
  }
  sar_rda(stolt_corrected, params)
}

///|
/// 根据模式分派 SAR 聚焦算法。
/// Dispatch SAR focusing algorithm by mode.
pub fn sar_focus(
  raw_data : Array[Array[Double]],
  params : SarParams,
  alg_mode : SarMode,
) -> Array[Array[Double]] {
  match alg_mode {
    RangeDoppler => sar_rda(raw_data, params)
    ChirpScaling => sar_csa(raw_data, params)
    OmegaK => sar_omega_k(raw_data, params)
  }
}

///|
/// 多视处理（减少散斑噪声）。
/// Multi-look processing (reduce speckle noise).
pub fn sar_multilook(
  focused_data : Array[Array[Double]],
  num_looks : Int32,
) -> Array[Array[Double]] {
  let height = focused_data.length()
  if height == 0 || num_looks <= 1 {
    return focused_data
  }
  let width = focused_data[0].length()
  let look_height = height / num_looks
  let result = Array::make(look_height, [])
  for row in 0..<look_height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let mut acc = 0.0
      for look in 0..<num_looks {
        let src_row = row + look * look_height
        if src_row < height {
          let val = focused_data[src_row][col]
          acc += val * val
        }
      }
      row_data[col] = (acc / num_looks.to_double()).sqrt()
    }
    result[row] = row_data
  }
  result
}

///|
/// 点目标检测（峰值搜索）。
/// Point target detection (peak search).
pub fn sar_detect_point_target(
  focused_data : Array[Array[Double]],
) -> (Int32, Int32, Double) {
  let height = focused_data.length()
  if height == 0 {
    return (0, 0, 0.0)
  }
  let width = focused_data[0].length()
  let mut best_row = 0
  let mut best_col = 0
  let mut best_val = 0.0
  for row in 0..<height {
    for col in 0..<width {
      let val = focused_data[row][col]
      if val < 0.0 {
        continue
      }
      if val > best_val {
        best_val = val
        best_row = row
        best_col = col
      }
    }
  }
  (best_row, best_col, best_val)
}

///|
/// 构建 SAR 图像。
/// Build SAR image.
pub fn sar_build_image(
  data : Array[Array[Double]],
  params : SarParams,
) -> SarImage {
  let height = data.length()
  let width = if height > 0 { data[0].length() } else { 0 }
  { data, width, height, params, }
}

///|
/// 计算 SAR 图像的均值强度。
/// Compute mean intensity of SAR image.
pub fn sar_mean_intensity(image : SarImage) -> Double {
  if image.width == 0 || image.height == 0 {
    return 0.0
  }
  let mut total = 0.0
  for row in 0..<image.height {
    for col in 0..<image.width {
      let val = image.data[row][col]
      total += val * val
    }
  }
  total / (image.width * image.height).to_double()
}

///|
/// SAR 参数辅助方法：波长。
/// SAR params helper: wavelength.
pub fn SarParams::wavelength(self : SarParams) -> Double {
  299792458.0 / self.carrier_freq
}
