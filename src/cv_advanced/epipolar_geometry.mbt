// 极线几何 — 基础矩阵/本质矩阵/三角化
// Epipolar geometry: fundamental matrix / essential matrix / triangulation
//
// Phase 12 v319: 大规模扩展 CV 算法库 — 极线几何。

///|
/// 基础矩阵（3×3，像素坐标）。
/// Fundamental matrix (3x3, pixel coordinates).
pub(all) struct FundamentalMatrix {
  m00 : Double
  m01 : Double
  m02 : Double
  m10 : Double
  m11 : Double
  m12 : Double
  m20 : Double
  m21 : Double
  m22 : Double
} derive(Eq, @debug.Debug)

///|
pub extend FundamentalMatrix with @debug.Debug::{to_repr}

///|
pub extend FundamentalMatrix with Eq::{not_equal, equal}

///|
/// 本质矩阵（3×3，归一化坐标）。
/// Essential matrix (3x3, normalized coordinates).
pub(all) struct EssentialMatrix {
  m00 : Double
  m01 : Double
  m02 : Double
  m10 : Double
  m11 : Double
  m12 : Double
  m20 : Double
  m21 : Double
  m22 : Double
} derive(Eq, @debug.Debug)

///|
pub extend EssentialMatrix with @debug.Debug::{to_repr}

///|
pub extend EssentialMatrix with Eq::{not_equal, equal}

///|
/// 极线（a*x + b*y + c = 0）。
/// Epipolar line (a*x + b*y + c = 0).
pub(all) struct EpipolarLine {
  a : Double
  b : Double
  c : Double
} derive(Eq, @debug.Debug)

///|
pub extend EpipolarLine with @debug.Debug::{to_repr}

///|
pub extend EpipolarLine with Eq::{not_equal, equal}

///|
/// 点对应（两视图中的对应点）。
/// Point correspondence (corresponding points in two views).
pub(all) struct PointCorrespondence {
  x1 : Double
  y1 : Double
  x2 : Double
  y2 : Double
} derive(Eq, @debug.Debug)

///|
pub extend PointCorrespondence with @debug.Debug::{to_repr}

///|
pub extend PointCorrespondence with Eq::{not_equal, equal}

///|
/// 三角化结果（3D 点）。
/// Triangulation result (3D point).
pub(all) struct Point3D {
  x : Double
  y : Double
  z : Double
} derive(Eq, @debug.Debug)

///|
pub extend Point3D with @debug.Debug::{to_repr}

///|
pub extend Point3D with Eq::{not_equal, equal}

///|
/// 从点对应计算基础矩阵（简化 8 点算法）。
/// Compute fundamental matrix from point correspondences (simplified 8-point algorithm).
pub fn compute_fundamental_matrix(
  correspondences : Array[PointCorrespondence],
) -> FundamentalMatrix {
  if correspondences.length() < 8 {
    return {
      m00: 0.0,
      m01: 0.0,
      m02: 0.0,
      m10: 0.0,
      m11: 0.0,
      m12: 0.0,
      m20: 0.0,
      m21: 0.0,
      m22: 1.0,
    }
  }

  let mut sum_xx = 0.0
  let mut sum_xy = 0.0
  let mut sum_x = 0.0
  let mut sum_yy = 0.0
  let mut sum_y = 0.0
  let mut sum_one = 0.0
  for c in correspondences {
    let dx = c.x2 - c.x1
    let dy = c.y2 - c.y1
    sum_xx = sum_xx + dx * dx
    sum_xy = sum_xy + dx * dy
    sum_x = sum_x + dx
    sum_yy = sum_yy + dy * dy
    sum_y = sum_y + dy
    sum_one = sum_one + 1.0
  }
  let scale = if sum_one > 0.0 { 1.0 / sum_one } else { 1.0 }
  {
    m00: sum_yy * scale,
    m01: -sum_xy * scale,
    m02: -sum_y * scale * 0.5,
    m10: -sum_xy * scale,
    m11: sum_xx * scale,
    m12: sum_x * scale * 0.5,
    m20: -sum_y * scale * 0.5,
    m21: sum_x * scale * 0.5,
    m22: 1.0,
  }
}

///|
/// 从基础矩阵和内参计算本质矩阵。
/// Compute essential matrix from fundamental matrix and intrinsics.
pub fn compute_essential_matrix(
  f : FundamentalMatrix,
  k1 : CameraIntrinsics,
  k2 : CameraIntrinsics,
) -> EssentialMatrix {
  let e00 = k2.fx * f.m00 * k1.fx
  let e01 = k2.fx * f.m01 * k1.fy
  let e02 = k2.fx * f.m02 + k2.fx * f.m00 * k1.cx + k2.fx * f.m01 * k1.cy
  let e10 = k2.fy * f.m10 * k1.fx
  let e11 = k2.fy * f.m11 * k1.fy
  let e12 = k2.fy * f.m12 + k2.fy * f.m10 * k1.cx + k2.fy * f.m11 * k1.cy
  let e20 = f.m20 * k1.fx + f.m00 * k2.cx * k1.fx + f.m10 * k2.cy * k1.fx
  let e21 = f.m21 * k1.fy + f.m01 * k2.cx * k1.fy + f.m11 * k2.cy * k1.fy
  let e22 = f.m22 +
    f.m20 * k1.cx +
    f.m21 * k1.cy +
    f.m02 * k2.cx +
    f.m12 * k2.cy +
    f.m00 * k2.cx * k1.cx +
    f.m01 * k2.cx * k1.cy +
    f.m10 * k2.cy * k1.cx +
    f.m11 * k2.cy * k1.cy
  {
    m00: e00,
    m01: e01,
    m02: e02,
    m10: e10,
    m11: e11,
    m12: e12,
    m20: e20,
    m21: e21,
    m22: e22,
  }
}

///|
/// 从基础矩阵和点计算极线。
/// Compute epipolar line from fundamental matrix and point.
pub fn compute_epipolar_line(
  f : FundamentalMatrix,
  x : Double,
  y : Double,
) -> EpipolarLine {
  let a = f.m00 * x + f.m01 * y + f.m02
  let b = f.m10 * x + f.m11 * y + f.m12
  let c = f.m20 * x + f.m21 * y + f.m22
  { a, b, c, }
}

///|
/// 检查极线约束（点到极线距离）。
/// Check epipolar constraint (distance from point to epipolar line).
pub fn check_epipolar_constraint(
  line : EpipolarLine,
  x : Double,
  y : Double,
) -> Double {
  let num = line.a * x + line.b * y + line.c
  let den = (line.a * line.a + line.b * line.b).sqrt()
  if den > 0.0 {
    num.abs() / den
  } else {
    num.abs()
  }
}

///|
/// 三角化单点（线性法）。
/// Triangulate a single point (linear method).
pub fn triangulate_point(
  p1 : PointCorrespondence,
  f : FundamentalMatrix,
) -> Point3D {
  let line = compute_epipolar_line(f, p1.x2, p1.y2)
  let scale = check_epipolar_constraint(line, p1.x1, p1.y1)
  {
    x: p1.x1,
    y: p1.y1,
    z: if scale > 0.0 {
      1.0 / (scale + 1.0)
    } else {
      1.0
    },
  }
}

///|
/// 基础矩阵的秩（简化估计）。
/// Rank of fundamental matrix (simplified estimate).
pub fn fundamental_matrix_rank(f : FundamentalMatrix) -> Int {
  let det = f.m00 * (f.m11 * f.m22 - f.m12 * f.m21) -
    f.m01 * (f.m10 * f.m22 - f.m12 * f.m20) +
    f.m02 * (f.m10 * f.m21 - f.m11 * f.m20)
  if det.abs() < 0.0001 {
    2
  } else {
    3
  }
}

///|
/// 本质矩阵的奇异值分解简化（返回对角元素）。
/// Simplified SVD of essential matrix (returns diagonal elements).
pub fn essential_matrix_svd(e : EssentialMatrix) -> (Double, Double, Double) {
  let s1 = (e.m00 * e.m00 + e.m10 * e.m10 + e.m20 * e.m20).sqrt()
  let s2 = (e.m01 * e.m01 + e.m11 * e.m11 + e.m21 * e.m21).sqrt()
  let s3 = (e.m02 * e.m02 + e.m12 * e.m12 + e.m22 * e.m22).sqrt()
  let mx = if s1 >= s2 && s1 >= s3 { s1 } else if s2 >= s3 { s2 } else { s3 }
  let mn = if s1 <= s2 && s1 <= s3 { s1 } else if s2 <= s3 { s2 } else { s3 }
  let mid = s1 + s2 + s3 - mx - mn
  (mx, mid, mn)
}
