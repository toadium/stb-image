// 大气校正 — 辐射定标/暗像元校正/瑞利校正/经验线校正
// Atmospheric correction
//
// Phase 15 v368: 遥感与地理空间大扩展 — 大气校正。

///|
/// 大气校正方法。
/// Atmospheric correction method.
pub(all) enum AtmoMethod {
  DarkObjectSubtraction
  EmpiricalLine
  Rayleigh
} derive(Eq, @debug.Debug)

///|
pub extend AtmoMethod with @debug.Debug::{to_repr}

///|
pub extend AtmoMethod with Eq::{not_equal, equal}

///|
/// 大气校正参数。
/// Atmospheric correction parameters.
pub(all) struct AtmoParams {
  sun_elevation : Double
  sun_azimuth : Double
  gain : Double
  offset : Double
  earth_sun_distance : Double
  solar_irradiance : Double
} derive(Eq, @debug.Debug)

///|
pub extend AtmoParams with @debug.Debug::{to_repr}

///|
pub extend AtmoParams with Eq::{not_equal, equal}

///|
/// 辐射定标：DN 值转辐射亮度。
/// Radiometric calibration: DN to radiance.
pub fn atmo_radiometric_calibration(
  dn_image : Array[Array[Double]],
  gain : Double,
  offset : Double,
) -> Array[Array[Double]] {
  let height = dn_image.length()
  if height == 0 {
    return []
  }
  let width = dn_image[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = gain * dn_image[row][col] + offset
    }
    result[row] = row_data
  }
  result
}

///|
/// 暗像元校正（DOS）。
/// Dark Object Subtraction.
pub fn atmo_dos_correction(
  radiance : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = radiance.length()
  if height == 0 {
    return []
  }
  let width = radiance[0].length()
  let mut min_val = 1.7976931348623157e308
  for row in 0..<height {
    for col in 0..<width {
      if radiance[row][col] < min_val {
        min_val = radiance[row][col]
      }
    }
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let corrected = radiance[row][col] - min_val
      row_data[col] = if corrected > 0.0 { corrected } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 辐射亮度转表观反射率。
/// Radiance to apparent reflectance.
pub fn atmo_reflectance(
  radiance : Array[Array[Double]],
  params : AtmoParams,
) -> Array[Array[Double]] {
  let height = radiance.length()
  if height == 0 {
    return []
  }
  let width = radiance[0].length()
  let sin_elevation = @math.sin(params.sun_elevation)
  let d_sq = params.earth_sun_distance * params.earth_sun_distance
  let denom = params.solar_irradiance * sin_elevation / d_sq
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = if denom != 0.0 {
        radiance[row][col] / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 经验线校正。
/// Empirical line calibration.
pub fn atmo_empirical_line(
  raw_image : Array[Array[Double]],
  field_data : Array[Double],
  image_data : Array[Double],
) -> Array[Array[Double]] {
  let n = field_data.length()
  if n < 2 {
    return raw_image
  }
  let mut sum_x = 0.0
  let mut sum_y = 0.0
  let mut sum_xy = 0.0
  let mut sum_xx = 0.0
  for i in 0..<n {
    sum_x += image_data[i]
    sum_y += field_data[i]
    sum_xy += image_data[i] * field_data[i]
    sum_xx += image_data[i] * image_data[i]
  }
  let nd = n.to_double()
  let denom = nd * sum_xx - sum_x * sum_x
  if denom == 0.0 {
    return raw_image
  }
  let slope = (nd * sum_xy - sum_x * sum_y) / denom
  let intercept = (sum_y - slope * sum_x) / nd
  let height = raw_image.length()
  if height == 0 {
    return []
  }
  let width = raw_image[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = slope * raw_image[row][col] + intercept
    }
    result[row] = row_data
  }
  result
}

///|
/// 瑞利散射校正（简化版）。
/// Rayleigh scattering correction (simplified).
pub fn atmo_rayleigh_correction(
  radiance : Array[Array[Double]],
  wavelength : Double,
  sun_elevation : Double,
  view_angle : Double,
) -> Array[Array[Double]] {
  let height = radiance.length()
  if height == 0 {
    return []
  }
  let width = radiance[0].length()
  let wl_um = wavelength / 1000000.0
  let rayleigh_optical_depth = 0.008569 /
    (wl_um * wl_um * wl_um * wl_um) *
    (1.0 + 0.0113 / (wl_um * wl_um) + 0.00013 / (wl_um * wl_um * wl_um * wl_um))
  let sin_sun = @math.sin(sun_elevation)
  let sin_view = @math.sin(view_angle)
  let mut path_radiance = 0.0
  if sin_sun > 0.0 && sin_view > 0.0 {
    path_radiance = rayleigh_optical_depth /
      (4.0 * 3.14159265358979323846) *
      sin_sun /
      (sin_sun + sin_view)
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let corrected = radiance[row][col] - path_radiance
      row_data[col] = if corrected > 0.0 { corrected } else { 0.0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 大气校正主函数（分派）。
/// Main atmospheric correction function (dispatch).
pub fn atmo_correct(
  radiance : Array[Array[Double]],
  atmo_method : AtmoMethod,
  wavelength : Double,
  sun_elevation : Double,
  view_angle : Double,
) -> Array[Array[Double]] {
  match atmo_method {
    DarkObjectSubtraction => atmo_dos_correction(radiance)
    EmpiricalLine => radiance
    Rayleigh =>
      atmo_rayleigh_correction(radiance, wavelength, sun_elevation, view_angle)
  }
}

///|
/// 构建大气校正参数。
/// Build atmospheric correction parameters.
pub fn atmo_build_params(
  sun_elevation : Double,
  sun_azimuth : Double,
  gain : Double,
  offset : Double,
  earth_sun_distance : Double,
  solar_irradiance : Double,
) -> AtmoParams {
  {
    sun_elevation,
    sun_azimuth,
    gain,
    offset,
    earth_sun_distance,
    solar_irradiance,
  }
}

///|
/// 计算图像均值辐射亮度。
/// Compute mean radiance.
pub fn atmo_mean_radiance(radiance : Array[Array[Double]]) -> Double {
  let height = radiance.length()
  if height == 0 {
    return 0.0
  }
  let mut total = 0.0
  let mut count = 0
  for row in 0..<height {
    for col in 0..<radiance[row].length() {
      total += radiance[row][col]
      count += 1
    }
  }
  if count > 0 {
    total / count.to_double()
  } else {
    0.0
  }
}
