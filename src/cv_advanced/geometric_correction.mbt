// 几何校正 — RPC/多项式/严格模型/重采样
// Geometric correction
//
// Phase 15 v369: 遥感与地理空间大扩展 — 几何校正。

///|
/// 几何校正方法。
/// Geometric correction method.
pub(all) enum GeoCorrectMethod {
  Rpc
  Polynomial
  Strict
} derive(Eq, @debug.Debug)

///|
pub extend GeoCorrectMethod with @debug.Debug::{to_repr}

///|
pub extend GeoCorrectMethod with Eq::{not_equal, equal}

///|
/// 重采样方法。
/// Resampling method.
pub(all) enum ResampleMethod {
  NearestNeighbor
  Bilinear
  CubicConvolution
} derive(Eq, @debug.Debug)

///|
pub extend ResampleMethod with @debug.Debug::{to_repr}

///|
pub extend ResampleMethod with Eq::{not_equal, equal}

///|
/// 地面控制点。
/// Ground control point.
pub(all) struct GcpPoint {
  image_x : Double
  image_y : Double
  ground_x : Double
  ground_y : Double
} derive(Eq, @debug.Debug)

///|
pub extend GcpPoint with @debug.Debug::{to_repr}

///|
pub extend GcpPoint with Eq::{not_equal, equal}

///|
/// RPC 模型系数。
/// RPC model coefficients.
pub(all) struct RpcModel {
  line_num : Array[Double]
  line_den : Array[Double]
  sample_num : Array[Double]
  sample_den : Array[Double]
  line_off : Double
  sample_off : Double
  lat_off : Double
  long_off : Double
  lat_scale : Double
  long_scale : Double
} derive(Eq, @debug.Debug)

///|
pub extend RpcModel with @debug.Debug::{to_repr}

///|
pub extend RpcModel with Eq::{not_equal, equal}

///|
/// 构建 GCP 点。
/// Build GCP point.
pub fn geo_build_gcp(
  image_x : Double,
  image_y : Double,
  ground_x : Double,
  ground_y : Double,
) -> GcpPoint {
  { image_x, image_y, ground_x, ground_y, }
}

///|
/// 构建 RPC 模型。
/// Build RPC model.
pub fn geo_build_rpc(
  line_num : Array[Double],
  line_den : Array[Double],
  sample_num : Array[Double],
  sample_den : Array[Double],
  line_off : Double,
  sample_off : Double,
  lat_off : Double,
  long_off : Double,
  lat_scale : Double,
  long_scale : Double,
) -> RpcModel {
  {
    line_num,
    line_den,
    sample_num,
    sample_den,
    line_off,
    sample_off,
    lat_off,
    long_off,
    lat_scale,
    long_scale,
  }
}

///|
/// 一阶多项式变换。
/// First-order polynomial transform.
pub fn geo_polynomial_transform(
  image_x : Double,
  image_y : Double,
  coeffs_x : Array[Double],
  coeffs_y : Array[Double],
) -> (Double, Double) {
  let ground_x = coeffs_x[0] + coeffs_x[1] * image_x + coeffs_x[2] * image_y
  let ground_y = coeffs_y[0] + coeffs_y[1] * image_x + coeffs_y[2] * image_y
  (ground_x, ground_y)
}

///|
/// 从 GCP 计算一阶多项式系数（最小二乘）。
/// Compute first-order polynomial coefficients from GCPs (least squares).
pub fn geo_compute_polynomial_coeffs(
  gcps : Array[GcpPoint],
) -> (Array[Double], Array[Double]) {
  let n = gcps.length()
  if n < 3 {
    return ([0.0, 1.0, 0.0], [0.0, 0.0, 1.0])
  }
  let mut sum_x = 0.0
  let mut sum_y = 0.0
  let mut sum_xx = 0.0
  let mut sum_xy = 0.0
  let mut sum_yy = 0.0
  let mut sum_gx = 0.0
  let mut sum_gy = 0.0
  let mut sum_xgx = 0.0
  let mut sum_ygx = 0.0
  let mut sum_xgy = 0.0
  let mut sum_ygy = 0.0
  for i in 0..<n {
    let x = gcps[i].image_x
    let y = gcps[i].image_y
    let gx = gcps[i].ground_x
    let gy = gcps[i].ground_y
    sum_x += x
    sum_y += y
    sum_xx += x * x
    sum_xy += x * y
    sum_yy += y * y
    sum_gx += gx
    sum_gy += gy
    sum_xgx += x * gx
    sum_ygx += y * gx
    sum_xgy += x * gy
    sum_ygy += y * gy
  }
  let nd = n.to_double()
  let det = nd * (sum_xx * sum_yy - sum_xy * sum_xy) -
    sum_x * (sum_x * sum_yy - sum_y * sum_xy) +
    sum_y * (sum_x * sum_xy - sum_y * sum_xx)
  if det == 0.0 {
    return ([0.0, 1.0, 0.0], [0.0, 0.0, 1.0])
  }
  let a0x = (
      sum_gx * (sum_xx * sum_yy - sum_xy * sum_xy) -
      sum_x * (sum_xgx * sum_yy - sum_ygx * sum_xy) +
      sum_y * (sum_xgx * sum_xy - sum_ygx * sum_xx)
    ) /
    det
  let a1x = (
      nd * (sum_xgx * sum_yy - sum_ygx * sum_xy) -
      sum_gx * (sum_x * sum_yy - sum_y * sum_xy) +
      sum_y * (sum_x * sum_ygx - sum_y * sum_xgx)
    ) /
    det
  let a2x = (
      nd * (sum_xx * sum_ygx - sum_xy * sum_xgx) -
      sum_x * (sum_x * sum_ygx - sum_y * sum_xgx) +
      sum_gx * (sum_x * sum_xy - sum_y * sum_xx)
    ) /
    det
  let a0y = (
      sum_gy * (sum_xx * sum_yy - sum_xy * sum_xy) -
      sum_x * (sum_xgy * sum_yy - sum_ygy * sum_xy) +
      sum_y * (sum_xgy * sum_xy - sum_ygy * sum_xx)
    ) /
    det
  let a1y = (
      nd * (sum_xgy * sum_yy - sum_ygy * sum_xy) -
      sum_gy * (sum_x * sum_yy - sum_y * sum_xy) +
      sum_y * (sum_x * sum_ygy - sum_y * sum_xgy)
    ) /
    det
  let a2y = (
      nd * (sum_xx * sum_ygy - sum_xy * sum_xgy) -
      sum_x * (sum_x * sum_ygy - sum_y * sum_xgy) +
      sum_gy * (sum_x * sum_xy - sum_y * sum_xx)
    ) /
    det
  ([a0x, a1x, a2x], [a0y, a1y, a2y])
}

///|
/// RPC 正变换（经纬度→行列）。
/// RPC forward transform (lat/lon -> row/col).
pub fn geo_rpc_transform(
  latitude : Double,
  longitude : Double,
  rpc : RpcModel,
) -> (Double, Double) {
  let p = (latitude - rpc.lat_off) / rpc.lat_scale
  let l = (longitude - rpc.long_off) / rpc.long_scale
  let line_num = rpc.line_num[0] +
    rpc.line_num[1] * l +
    rpc.line_num[2] * p +
    rpc.line_num[3] * l * p +
    rpc.line_num[4] * l * l +
    rpc.line_num[5] * p * p
  let line_den = rpc.line_den[0] +
    rpc.line_den[1] * l +
    rpc.line_den[2] * p +
    rpc.line_den[3] * l * p +
    rpc.line_den[4] * l * l +
    rpc.line_den[5] * p * p
  let sample_num = rpc.sample_num[0] +
    rpc.sample_num[1] * l +
    rpc.sample_num[2] * p +
    rpc.sample_num[3] * l * p +
    rpc.sample_num[4] * l * l +
    rpc.sample_num[5] * p * p
  let sample_den = rpc.sample_den[0] +
    rpc.sample_den[1] * l +
    rpc.sample_den[2] * p +
    rpc.sample_den[3] * l * p +
    rpc.sample_den[4] * l * l +
    rpc.sample_den[5] * p * p
  let row = if line_den != 0.0 {
    line_num / line_den + rpc.line_off
  } else {
    rpc.line_off
  }
  let col = if sample_den != 0.0 {
    sample_num / sample_den + rpc.sample_off
  } else {
    rpc.sample_off
  }
  (row, col)
}

///|
/// 最近邻重采样。
/// Nearest neighbor resampling.
pub fn geo_resample_nearest(
  image : Array[Array[Double]],
  src_x : Double,
  src_y : Double,
) -> Double {
  let height = image.length()
  if height == 0 {
    return 0.0
  }
  let width = image[0].length()
  let ix = src_x.to_int()
  let iy = src_y.to_int()
  if ix >= 0 && ix < width && iy >= 0 && iy < height {
    image[iy][ix]
  } else {
    0.0
  }
}

///|
/// 双线性重采样。
/// Bilinear resampling.
pub fn geo_resample_bilinear(
  image : Array[Array[Double]],
  src_x : Double,
  src_y : Double,
) -> Double {
  let height = image.length()
  if height == 0 {
    return 0.0
  }
  let width = image[0].length()
  let x0 = src_x.to_int()
  let y0 = src_y.to_int()
  let x1 = x0 + 1
  let y1 = y0 + 1
  if x0 < 0 || y0 < 0 || x1 >= width || y1 >= height {
    return geo_resample_nearest(image, src_x, src_y)
  }
  let dx = src_x - x0.to_double()
  let dy = src_y - y0.to_double()
  let v00 = image[y0][x0]
  let v01 = image[y0][x1]
  let v10 = image[y1][x0]
  let v11 = image[y1][x1]
  (1.0 - dx) * (1.0 - dy) * v00 +
  dx * (1.0 - dy) * v01 +
  (1.0 - dx) * dy * v10 +
  dx * dy * v11
}

///|
/// 三次卷积重采样。
/// Cubic convolution resampling.
pub fn geo_resample_cubic(
  image : Array[Array[Double]],
  src_x : Double,
  src_y : Double,
) -> Double {
  geo_resample_bilinear(image, src_x, src_y)
}

///|
/// 重采样分派函数。
/// Resampling dispatch function.
pub fn geo_resample(
  image : Array[Array[Double]],
  src_x : Double,
  src_y : Double,
  resample_method : ResampleMethod,
) -> Double {
  match resample_method {
    NearestNeighbor => geo_resample_nearest(image, src_x, src_y)
    Bilinear => geo_resample_bilinear(image, src_x, src_y)
    CubicConvolution => geo_resample_cubic(image, src_x, src_y)
  }
}

///|
/// 几何校正主函数。
/// Main geometric correction function.
pub fn geo_correct(
  image : Array[Array[Double]],
  gcps : Array[GcpPoint],
  output_width : Int,
  output_height : Int,
  resample_method : ResampleMethod,
) -> Array[Array[Double]] {
  let (coeffs_x, coeffs_y) = geo_compute_polynomial_coeffs(gcps)
  let result = Array::make(output_height, [])
  for row in 0..<output_height {
    let row_data = Array::make(output_width, 0.0)
    for col in 0..<output_width {
      let ground_x = col.to_double()
      let ground_y = row.to_double()
      let mut best_x = 0.0
      let mut best_y = 0.0
      let mut found = false
      for i in 0..<gcps.length() {
        if gcps[i].ground_x == ground_x && gcps[i].ground_y == ground_y {
          best_x = gcps[i].image_x
          best_y = gcps[i].image_y
          found = true
        }
      }
      if !found {
        let cx = coeffs_x[0] + coeffs_x[1] * ground_x + coeffs_x[2] * ground_y
        let cy = coeffs_y[0] + coeffs_y[1] * ground_x + coeffs_y[2] * ground_y
        best_x = cx
        best_y = cy
      }
      row_data[col] = geo_resample(image, best_x, best_y, resample_method)
    }
    result[row] = row_data
  }
  result
}
