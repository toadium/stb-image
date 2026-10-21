// 植被指数 — NDVI/EVI/SAVI/MSAVI/GNDVI/RVI/DVI
// Vegetation indices
//
// Phase 15 v367: 遥感与地理空间大扩展 — 植被指数。

///|
/// 归一化植被指数 NDVI = (NIR - Red) / (NIR + Red)。
/// Normalized Difference Vegetation Index.
pub fn veg_ndvi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = nir[row][col] + red[row][col]
      row_data[col] = if denom != 0.0 {
        (nir[row][col] - red[row][col]) / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 增强植被指数 EVI = G * (NIR - Red) / (NIR + C1 * Red - C2 * Blue + L)。
/// Enhanced Vegetation Index.
pub fn veg_evi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
  blue : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let g = 2.5
  let c1 = 6.0
  let c2 = 7.5
  let l = 1.0
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = nir[row][col] + c1 * red[row][col] - c2 * blue[row][col] + l
      row_data[col] = if denom != 0.0 {
        g * (nir[row][col] - red[row][col]) / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 土壤调整植被指数 SAVI = (NIR - Red) / (NIR + Red + L) * (1 + L)。
/// Soil-Adjusted Vegetation Index.
pub fn veg_savi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
  l : Double,
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = nir[row][col] + red[row][col] + l
      row_data[col] = if denom != 0.0 {
        (nir[row][col] - red[row][col]) / denom * (1.0 + l)
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 修正土壤调整植被指数 MSAVI。
/// Modified Soil-Adjusted Vegetation Index.
pub fn veg_msavi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let n = nir[row][col]
      let r = red[row][col]
      let inner = 2.0 * n + 1.0
      let val = (inner * inner - 8.0 * (n - r)).sqrt()
      row_data[col] = (inner - val) / 2.0
    }
    result[row] = row_data
  }
  result
}

///|
/// 绿色归一化植被指数 GNDVI = (NIR - Green) / (NIR + Green)。
/// Green Normalized Difference Vegetation Index.
pub fn veg_gndvi(
  nir : Array[Array[Double]],
  green : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = nir[row][col] + green[row][col]
      row_data[col] = if denom != 0.0 {
        (nir[row][col] - green[row][col]) / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 比值植被指数 RVI = NIR / Red。
/// Ratio Vegetation Index.
pub fn veg_rvi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = if red[row][col] != 0.0 {
        nir[row][col] / red[row][col]
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 差值植被指数 DVI = NIR - Red。
/// Difference Vegetation Index.
pub fn veg_dvi(
  nir : Array[Array[Double]],
  red : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      row_data[col] = nir[row][col] - red[row][col]
    }
    result[row] = row_data
  }
  result
}

///|
/// 水体指数 NDWI = (Green - NIR) / (Green + NIR)。
/// Normalized Difference Water Index.
pub fn veg_ndwi(
  green : Array[Array[Double]],
  nir : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = green[row][col] + nir[row][col]
      row_data[col] = if denom != 0.0 {
        (green[row][col] - nir[row][col]) / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 建筑指数 NDBI = (SWIR - NIR) / (SWIR + NIR)。
/// Normalized Difference Built-up Index.
pub fn veg_ndbi(
  swir : Array[Array[Double]],
  nir : Array[Array[Double]],
) -> Array[Array[Double]] {
  let height = nir.length()
  if height == 0 {
    return []
  }
  let width = nir[0].length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      let denom = swir[row][col] + nir[row][col]
      row_data[col] = if denom != 0.0 {
        (swir[row][col] - nir[row][col]) / denom
      } else {
        0.0
      }
    }
    result[row] = row_data
  }
  result
}

///|
/// 计算植被指数均值。
/// Compute mean of vegetation index.
pub fn veg_mean_index(index : Array[Array[Double]]) -> Double {
  let height = index.length()
  if height == 0 {
    return 0.0
  }
  let mut total = 0.0
  let mut count = 0
  for row in 0..<height {
    for col in 0..<index[row].length() {
      total += index[row][col]
      count += 1
    }
  }
  if count > 0 {
    total / count.to_double()
  } else {
    0.0
  }
}

///|
/// 植被覆盖度 FVC = ((NDVI - NDVI_soil) / (NDVI_veg - NDVI_soil))^2。
/// Fractional Vegetation Cover.
pub fn veg_fractional_cover(
  ndvi : Array[Array[Double]],
  ndvi_soil : Double,
  ndvi_veg : Double,
) -> Array[Array[Double]] {
  let height = ndvi.length()
  if height == 0 {
    return []
  }
  let width = ndvi[0].length()
  let denom = ndvi_veg - ndvi_soil
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0.0)
    for col in 0..<width {
      if denom != 0.0 {
        let ratio = (ndvi[row][col] - ndvi_soil) / denom
        let clamped = if ratio < 0.0 {
          0.0
        } else if ratio > 1.0 {
          1.0
        } else {
          ratio
        }
        row_data[col] = clamped * clamped
      }
    }
    result[row] = row_data
  }
  result
}
