// 正射校正 — DEM 纠正/镶嵌/匀色/拼接线
// Orthorectification
//
// Phase 15 v370: 遥感与地理空间大扩展 — 正射校正。

///|
/// 正射校正参数。
/// Orthorectification parameters.
pub(all) struct OrthoParams {
  focal_length : Double
  flying_height : Double
  ground_resolution : Double
  dem_data : Array[Array[Double]]
} derive(Eq, @debug.Debug)

///|
pub extend OrthoParams with @debug.Debug::{to_repr}

///|
pub extend OrthoParams with Eq::{not_equal, equal}

///|
/// DEM 正射校正。
/// DEM-based orthorectification.
pub fn ortho_correct(
  image : Array[Array[Double]],
  params : OrthoParams,
) -> Array[Array[Double]] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let dem_height = params.dem_data.length()
  let dem_width = if dem_height > 0 { params.dem_data[0].length() } else { 0 }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let dem_row = row * dem_height / height
      let dem_col = col * dem_width / width
      let elevation = if dem_row < dem_height && dem_col < dem_width {
        params.dem_data[dem_row][dem_col]
      } else {
        0.0
      }
      let displacement = elevation * params.focal_length / params.flying_height
      let corrected_row = row.to_double() +
        displacement / params.ground_resolution
      let corrected_col = col.to_double()
      let ir = corrected_row.to_int()
      let ic = corrected_col.to_int()
      if ir >= 0 && ir < height && ic >= 0 && ic < width {
        row_data[col] = image[ir][ic]
      } else {
        row_data[col] = 0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 图像镶嵌。
/// Image mosaicking.
pub fn ortho_mosaic(
  images : Array[Array[Array[Double]]],
  offsets : Array[(Int32, Int32)],
) -> Array[Array[Double]] {
  if images.length() == 0 {
    return []
  }
  let mut max_x = 0
  let mut max_y = 0
  for i in 0..<images.length() {
    let h = images[i].length()
    let w = if h > 0 { images[i][0].length() } else { 0 }
    let (ox, oy) = offsets[i]
    if ox + w > max_x {
      max_x = ox + w
    }
    if oy + h > max_y {
      max_y = oy + h
    }
  }
  let result = Array::make(max_y, [])
  for row in 0..<max_y {
    result[row] = Array::make(max_x, 0.0)
  }
  for i in 0..<images.length() {
    let (ox, oy) = offsets[i]
    let h = images[i].length()
    let w = if h > 0 { images[i][0].length() } else { 0 }
    for row in 0..<h {
      for col in 0..<w {
        let dst_row = row + oy
        let dst_col = col + ox
        if dst_row < max_y && dst_col < max_x {
          result[dst_row][dst_col] = images[i][row][col]
        }
      }
    }
  }
  result
}

///|
/// 直方图匹配匀色。
/// Histogram matching color balancing.
pub fn ortho_color_balance(
  source : Array[Array[Double]],
  reference : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = source.length()
  if height == 0 {
    return []
  }
  let width = source[0].length()
  let mut src_mean = 0.0
  let mut src_var = 0.0
  let mut ref_mean = 0.0
  let mut ref_var = 0.0
  let mut count = 0
  for row in 0..<height {
    for col in 0..<width {
      src_mean += source[row][col]
      count += 1
    }
  }
  if count > 0 {
    src_mean = src_mean / count.to_double()
  }
  for row in 0..<height {
    for col in 0..<width {
      let diff = source[row][col] - src_mean
      src_var += diff * diff
    }
  }
  if count > 0 {
    src_var = (src_var / count.to_double()).sqrt()
  }
  let ref_height = reference.length()
  let mut ref_count = 0
  for row in 0..<ref_height {
    for col in 0..<reference[row].length() {
      ref_mean += reference[row][col]
      ref_count += 1
    }
  }
  if ref_count > 0 {
    ref_mean = ref_mean / ref_count.to_double()
  }
  for row in 0..<ref_height {
    for col in 0..<reference[row].length() {
      let diff = reference[row][col] - ref_mean
      ref_var += diff * diff
    }
  }
  if ref_count > 0 {
    ref_var = (ref_var / ref_count.to_double()).sqrt()
  }
  let scale = if src_var > 0.0 { ref_var / src_var } else { 1.0 }
  let offset = ref_mean - scale * src_mean
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = scale * source[row][col] + offset
    }
    result[row] = row_data
  }
  result
}

///|
/// Wallis 滤波匀色。
/// Wallis filter dodging.
pub fn ortho_wallis_dodging(
  image : Array[Array[Double]],
  window_size : Int32,
  target_mean : Double,
  target_var : Double,
) -> Array[Array[Double]] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let half = window_size / 2
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let mut sum = 0.0
      let mut sum_sq = 0.0
      let mut count = 0
      for dy in -half..<=half {
        for dx in -half..<=half {
          let r = row + dy
          let c = col + dx
          if r >= 0 && r < height && c >= 0 && c < width {
            let v = image[r][c]
            sum += v
            sum_sq += v * v
            count += 1
          }
        }
      }
      if count > 0 {
        let mean = sum / count.to_double()
        let std_dev = (sum_sq / count.to_double() - mean * mean).sqrt()
        if std_dev > 0.0 {
          row_data[col] = target_mean +
            target_var * (image[row][col] - mean) / std_dev
        } else {
          row_data[col] = image[row][col]
        }
      } else {
        row_data[col] = image[row][col]
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 生成简单拼接线（重叠区域中线）。
/// Generate simple seamline (center line of overlap).
pub fn ortho_seamline(
  overlap_width : Int32,
  overlap_height : Int32,
) -> Array[(Int32, Int32)] {
  let result = Array::make(overlap_height, (0, 0))
  for row in 0..<overlap_height {
    result[row] = (row, overlap_width / 2)
  }
  result
}

///|
/// 构建正射校正参数。
/// Build orthorectification parameters.
pub fn ortho_build_params(
  focal_length : Double,
  flying_height : Double,
  ground_resolution : Double,
  dem_data : Array[Array[Double]],
) -> OrthoParams {
  { focal_length, flying_height, ground_resolution, dem_data, }
}

///|
/// 计算正射校正位移量。
/// Compute orthorectification displacement.
pub fn ortho_displacement(
  elevation : Double,
  focal_length : Double,
  flying_height : Double,
) -> Double {
  elevation * focal_length / flying_height
}
