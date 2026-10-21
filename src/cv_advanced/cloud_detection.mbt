// 云检测 — 阈值/多光谱/渐进精化/阴影检测
// Cloud detection
//
// Phase 15 v373: 遥感与地理空间大扩展 — 云检测。

///|
/// 云检测方法。
/// Cloud detection method.
pub(all) enum CloudDetectMethod {
  Threshold
  Multispectral
  Progressive
} derive(Eq, @debug.Debug)

///|
pub extend CloudDetectMethod with @debug.Debug::{to_repr}

///|
pub extend CloudDetectMethod with Eq::{not_equal, equal}

///|
/// 云检测结果。
/// Cloud detection result.
pub(all) struct CloudResult {
  cloud_mask : Array[Array[Int32]]
  shadow_mask : Array[Array[Int32]]
  cloud_coverage : Double
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend CloudResult with @debug.Debug::{to_repr}

///|
pub extend CloudResult with Eq::{not_equal, equal}

///|
/// 阈值云检测。
/// Threshold-based cloud detection.
pub fn cloud_threshold_detect(
  image : Array[Array[Double]],
  threshold : Double,
) -> Array[Array[Int32]] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      row_data[col] = if image[row][col] > threshold { 1 } else { 0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 多光谱云检测（使用热红外和可见光波段）。
/// Multi-spectral cloud detection.
pub fn cloud_multispectral_detect(
  visible : Array[Array[Double]],
  thermal : Array[Array[Double]],
  vis_threshold : Double,
  thermal_threshold : Double,
) -> Array[Array[Int32]] {
  let height = visible.length()
  if height == 0 {
    return []
  }
  let width = visible[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let is_bright = visible[row][col] > vis_threshold
      let is_cold = thermal[row][col] < thermal_threshold
      row_data[col] = if is_bright && is_cold { 1 } else { 0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 云阴影检测。
/// Cloud shadow detection.
pub fn cloud_shadow_detect(
  image : Array[Array[Double]],
  cloud_mask : Array[Array[Int32]],
  shadow_threshold : Double,
  sun_azimuth : Double,
  sun_elevation : Double,
  shadow_offset : Int32,
) -> Array[Array[Int32]] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let dx = (shadow_offset.to_double() *
  @math.cos(sun_azimuth) /
  @math.sin(sun_elevation)).to_int()
  let dy = (shadow_offset.to_double() *
  @math.sin(sun_azimuth) /
  @math.sin(sun_elevation)).to_int()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let cloud_row = row - dy
      let cloud_col = col - dx
      if cloud_row >= 0 &&
        cloud_row < height &&
        cloud_col >= 0 &&
        cloud_col < width {
        if cloud_mask[cloud_row][cloud_col] == 1 &&
          image[row][col] < shadow_threshold {
          row_data[col] = 1
        }
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 渐进精化云检测。
/// Progressive refinement cloud detection.
pub fn cloud_progressive_refinement(
  image : Array[Array[Double]],
  initial_threshold : Double,
  num_iterations : Int32,
) -> Array[Array[Int32]] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let mut threshold = initial_threshold
  let mut mask = cloud_threshold_detect(image, threshold)
  for _ in 0..<num_iterations {
    let mut cloud_sum = 0.0
    let mut cloud_count = 0
    let mut clear_sum = 0.0
    let mut clear_count = 0
    for row in 0..<height {
      for col in 0..<width {
        if mask[row][col] == 1 {
          cloud_sum += image[row][col]
          cloud_count += 1
        } else {
          clear_sum += image[row][col]
          clear_count += 1
        }
      }
    }
    let cloud_mean = if cloud_count > 0 {
      cloud_sum / cloud_count.to_double()
    } else {
      threshold
    }
    let clear_mean = if clear_count > 0 {
      clear_sum / clear_count.to_double()
    } else {
      0.0
    }
    threshold = (cloud_mean + clear_mean) * 0.5
    mask = cloud_threshold_detect(image, threshold)
  }
  mask
}

///|
/// 计算云覆盖率。
/// Compute cloud coverage percentage.
pub fn cloud_compute_coverage(cloud_mask : Array[Array[Int32]]) -> Double {
  let height = cloud_mask.length()
  if height == 0 {
    return 0.0
  }
  let mut total = 0
  let mut cloud_pixels = 0
  for row in 0..<height {
    for col in 0..<cloud_mask[row].length() {
      total += 1
      if cloud_mask[row][col] == 1 {
        cloud_pixels += 1
      }
    }
  }
  if total > 0 {
    cloud_pixels.to_double() / total.to_double()
  } else {
    0.0
  }
}

///|
/// 形态学开运算（去噪）。
/// Morphological opening (denoising).
pub fn cloud_morph_open(
  mask : Array[Array[Int32]],
  kernel_size : Int32,
) -> Array[Array[Int32]] {
  let height = mask.length()
  if height == 0 {
    return []
  }
  let width = mask[0].length()
  let half = kernel_size / 2
  let eroded = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let mut all_one = true
      for dy in -half..<=half {
        for dx in -half..<=half {
          let r = row + dy
          let c = col + dx
          if r < 0 || r >= height || c < 0 || c >= width || mask[r][c] == 0 {
            all_one = false
          }
        }
      }
      row_data[col] = if all_one { 1 } else { 0 }
    }
    eroded[row] = row_data
  }
  let dilated = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let mut any_one = false
      for dy in -half..<=half {
        for dx in -half..<=half {
          let r = row + dy
          let c = col + dx
          if r >= 0 && r < height && c >= 0 && c < width && eroded[r][c] == 1 {
            any_one = true
          }
        }
      }
      row_data[col] = if any_one { 1 } else { 0 }
    }
    dilated[row] = row_data
  }
  dilated
}

///|
/// 构建云检测结果。
/// Build cloud detection result.
pub fn cloud_build_result(
  cloud_mask : Array[Array[Int32]],
  shadow_mask : Array[Array[Int32]],
) -> CloudResult {
  let height = cloud_mask.length()
  let width = if height > 0 { cloud_mask[0].length() } else { 0 }
  let coverage = cloud_compute_coverage(cloud_mask)
  { cloud_mask, shadow_mask, cloud_coverage: coverage, width, height, }
}

///|
/// 云检测主函数（分派）。
/// Main cloud detection function (dispatch).
pub fn cloud_detect(
  image : Array[Array[Double]],
  det_method : CloudDetectMethod,
  threshold : Double,
) -> Array[Array[Int32]] {
  match det_method {
    Threshold => cloud_threshold_detect(image, threshold)
    Multispectral => cloud_threshold_detect(image, threshold)
    Progressive => cloud_progressive_refinement(image, threshold, 3)
  }
}
