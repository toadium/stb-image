// 医学图像配准 — 刚体/仿射/弹性/B样条
// Medical image registration
//
// Phase 14 v351: 医学影像大扩展 — 图像配准。

///|
/// 配准变换类型。
/// Registration transform type.
pub(all) enum MedRegType {
  Rigid
  Affine
  Elastic
  BSpline
} derive(Eq, @debug.Debug)

///|
pub extend MedRegType with @debug.Debug::{to_repr}

///|
pub extend MedRegType with Eq::{not_equal, equal}

///|
/// 刚体变换参数。
/// Rigid transform parameters.
pub(all) struct MedRigidTransform {
  angle : Double
  tx : Double
  ty : Double
} derive(Eq, @debug.Debug)

///|
pub extend MedRigidTransform with @debug.Debug::{to_repr}

///|
pub extend MedRigidTransform with Eq::{not_equal, equal}

///|
/// 仿射变换参数。
/// Affine transform parameters.
pub(all) struct MedAffineTransform {
  a11 : Double
  a12 : Double
  a21 : Double
  a22 : Double
  tx : Double
  ty : Double
} derive(Eq, @debug.Debug)

///|
pub extend MedAffineTransform with @debug.Debug::{to_repr}

///|
pub extend MedAffineTransform with Eq::{not_equal, equal}

///|
/// 配准结果。
/// Registration result.
pub(all) struct MedRegResult {
  transform_type : MedRegType
  rigid : MedRigidTransform
  affine : MedAffineTransform
  final_error : Double
  iterations : Int
} derive(Eq, @debug.Debug)

///|
pub extend MedRegResult with @debug.Debug::{to_repr}

///|
pub extend MedRegResult with Eq::{not_equal, equal}

///|
/// 应用刚体变换。
/// Apply rigid transform.
pub fn medreg_apply_rigid(
  image : Array[Double],
  width : Int,
  height : Int,
  transform : MedRigidTransform,
) -> Array[Double] {
  let result : Array[Double] = []
  let cos_a = @math.cos(transform.angle)
  let sin_a = @math.sin(transform.angle)
  let cx = width.to_double() / 2.0
  let cy = height.to_double() / 2.0
  for y in 0..<height {
    for x in 0..<width {
      let dx = x.to_double() - cx
      let dy = y.to_double() - cy
      let src_x = cos_a * dx - sin_a * dy + cx + transform.tx
      let src_y = sin_a * dx + cos_a * dy + cy + transform.ty
      let sx = src_x.to_int()
      let sy = src_y.to_int()
      if sx >= 0 && sx < width && sy >= 0 && sy < height {
        let idx = sy * width + sx
        result.push(if idx < image.length() { image[idx] } else { 0.0 })
      } else {
        result.push(0.0)
      }
    }
  }
  result
}

///|
/// 应用仿射变换。
/// Apply affine transform.
pub fn medreg_apply_affine(
  image : Array[Double],
  width : Int,
  height : Int,
  transform : MedAffineTransform,
) -> Array[Double] {
  let result : Array[Double] = []
  let cx = width.to_double() / 2.0
  let cy = height.to_double() / 2.0
  for y in 0..<height {
    for x in 0..<width {
      let dx = x.to_double() - cx
      let dy = y.to_double() - cy
      let src_x = transform.a11 * dx + transform.a12 * dy + cx + transform.tx
      let src_y = transform.a21 * dx + transform.a22 * dy + cy + transform.ty
      let sx = src_x.to_int()
      let sy = src_y.to_int()
      if sx >= 0 && sx < width && sy >= 0 && sy < height {
        let idx = sy * width + sx
        result.push(if idx < image.length() { image[idx] } else { 0.0 })
      } else {
        result.push(0.0)
      }
    }
  }
  result
}

///|
/// 计算互信息。
/// Compute mutual information.
pub fn medreg_mutual_information(
  fixed : Array[Double],
  moving : Array[Double],
  num_bins : Int,
) -> Double {
  let n = fixed.length()
  if n == 0 || moving.length() == 0 {
    return 0.0
  }
  let mut fixed_min = 1.7976931348623157e308
  let mut fixed_max = -1.7976931348623157e308
  let mut moving_min = 1.7976931348623157e308
  let mut moving_max = -1.7976931348623157e308
  for i in 0..<n {
    if fixed[i] < fixed_min {
      fixed_min = fixed[i]
    }
    if fixed[i] > fixed_max {
      fixed_max = fixed[i]
    }
  }
  for i in 0..<moving.length() {
    if moving[i] < moving_min {
      moving_min = moving[i]
    }
    if moving[i] > moving_max {
      moving_max = moving[i]
    }
  }
  let fixed_range = fixed_max - fixed_min
  let moving_range = moving_max - moving_min
  if fixed_range <= 0.0 || moving_range <= 0.0 {
    return 0.0
  }
  let hist : Array[Array[Int]] = []
  for _ in 0..<num_bins {
    let row : Array[Int] = []
    for _ in 0..<num_bins {
      row.push(0)
    }
    hist.push(row)
  }
  let min_len = if n < moving.length() { n } else { moving.length() }
  for i in 0..<min_len {
    let fi = ((fixed[i] - fixed_min) / fixed_range * num_bins.to_double()).to_int()
    let mi_val = ((moving[i] - moving_min) / moving_range * num_bins.to_double()).to_int()
    let f_idx = if fi >= num_bins { num_bins - 1 } else { fi }
    let m_idx = if mi_val >= num_bins { num_bins - 1 } else { mi_val }
    hist[f_idx][m_idx] = hist[f_idx][m_idx] + 1
  }
  let mut mi = 0.0
  let total = min_len.to_double()
  for i in 0..<num_bins {
    let mut row_sum = 0.0
    for j in 0..<num_bins {
      row_sum = row_sum + hist[i][j].to_double()
    }
    if row_sum > 0.0 {
      for j in 0..<num_bins {
        if hist[i][j] > 0 {
          let mut col_sum = 0.0
          for k in 0..<num_bins {
            col_sum = col_sum + hist[k][j].to_double()
          }
          if col_sum > 0.0 {
            let p_ij = hist[i][j].to_double() / total
            let p_i = row_sum / total
            let p_j = col_sum / total
            mi = mi + p_ij * @math.log2(p_ij / (p_i * p_j))
          }
        }
      }
    }
  }
  mi
}

///|
/// 刚体配准（网格搜索优化）。
/// Rigid registration (grid search optimization).
pub fn medreg_rigid(
  fixed : Array[Double],
  moving : Array[Double],
  width : Int,
  height : Int,
  max_iterations : Int,
) -> MedRegResult {
  let mut best_angle = 0.0
  let mut best_tx = 0.0
  let mut best_ty = 0.0
  let mut best_error = 1.7976931348623157e308
  let mut best_iter = 0
  for iter in 0..<max_iterations {
    let angle = (iter.to_double() / max_iterations.to_double() - 0.5) * 0.5
    for tx_candidate in [-2.0, 0.0, 2.0] {
      for ty_candidate in [-2.0, 0.0, 2.0] {
        let transform = MedRigidTransform::{
          angle,
          tx: tx_candidate,
          ty: ty_candidate,
        }
        let warped = medreg_apply_rigid(moving, width, height, transform)
        let mut error = 0.0
        let n = fixed.length()
        for i in 0..<n {
          if i < warped.length() {
            let diff = fixed[i] - warped[i]
            error = error + diff * diff
          }
        }
        if error < best_error {
          best_error = error
          best_angle = angle
          best_tx = tx_candidate
          best_ty = ty_candidate
          best_iter = iter
        }
      }
    }
  }
  MedRegResult::{
    transform_type: Rigid,
    rigid: MedRigidTransform::{ angle: best_angle, tx: best_tx, ty: best_ty, },
    affine: MedAffineTransform::{
      a11: 1.0,
      a12: 0.0,
      a21: 0.0,
      a22: 1.0,
      tx: best_tx,
      ty: best_ty,
    },
    final_error: best_error,
    iterations: best_iter,
  }
}

///|
/// 仿射配准（简化网格搜索）。
/// Affine registration (simplified grid search).
pub fn medreg_affine(
  fixed : Array[Double],
  moving : Array[Double],
  width : Int,
  height : Int,
) -> MedRegResult {
  let mut best_a11 = 1.0
  let mut best_a22 = 1.0
  let mut best_error = 1.7976931348623157e308
  for a11_candidate in [0.9, 1.0, 1.1] {
    for a22_candidate in [0.9, 1.0, 1.1] {
      let transform = MedAffineTransform::{
        a11: a11_candidate,
        a12: 0.0,
        a21: 0.0,
        a22: a22_candidate,
        tx: 0.0,
        ty: 0.0,
      }
      let warped = medreg_apply_affine(moving, width, height, transform)
      let mut error = 0.0
      let n = fixed.length()
      for i in 0..<n {
        if i < warped.length() {
          let diff = fixed[i] - warped[i]
          error = error + diff * diff
        }
      }
      if error < best_error {
        best_error = error
        best_a11 = a11_candidate
        best_a22 = a22_candidate
      }
    }
  }
  MedRegResult::{
    transform_type: Affine,
    rigid: MedRigidTransform::{ angle: 0.0, tx: 0.0, ty: 0.0, },
    affine: MedAffineTransform::{
      a11: best_a11,
      a12: 0.0,
      a21: 0.0,
      a22: best_a22,
      tx: 0.0,
      ty: 0.0,
    },
    final_error: best_error,
    iterations: 9,
  }
}

///|
/// 均方误差。
/// Mean squared error.
pub fn medreg_mse(fixed : Array[Double], moving : Array[Double]) -> Double {
  let n = fixed.length()
  if n == 0 {
    return 0.0
  }
  let mut sum = 0.0
  let min_len = if n < moving.length() { n } else { moving.length() }
  for i in 0..<min_len {
    let diff = fixed[i] - moving[i]
    sum = sum + diff * diff
  }
  sum / n.to_double()
}
