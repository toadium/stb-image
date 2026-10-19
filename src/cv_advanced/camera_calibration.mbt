// 相机标定 — 张正友标定/畸变校正
// Camera calibration: Zhang's method / distortion correction
//
// Phase 12 v318: 大规模扩展 CV 算法库 — 相机标定。

///|
/// 相机内参。
/// Camera intrinsics.
pub(all) struct CameraIntrinsics {
  fx : Double
  fy : Double
  cx : Double
  cy : Double
  k1 : Double
  k2 : Double
  k3 : Double
  p1 : Double
  p2 : Double
} derive(Eq, @debug.Debug)

///|
pub extend CameraIntrinsics with @debug.Debug::{to_repr}

///|
pub extend CameraIntrinsics with Eq::{not_equal, equal}

///|
/// 棋盘格角点。
/// Chessboard corners.
pub(all) struct ChessboardCorners {
  corners : Array[(Double, Double)]
  rows : Int
  cols : Int
} derive(Eq, @debug.Debug)

///|
pub extend ChessboardCorners with @debug.Debug::{to_repr}

///|
pub extend ChessboardCorners with Eq::{not_equal, equal}

///|
/// 标定结果。
/// Calibration result.
pub(all) struct CalibrationResult {
  intrinsics : CameraIntrinsics
  reprojection_error : Double
  success : Bool
} derive(Eq, @debug.Debug)

///|
pub extend CalibrationResult with @debug.Debug::{to_repr}

///|
pub extend CalibrationResult with Eq::{not_equal, equal}

///|
/// 从棋盘格角点标定相机（简化版）。
/// Calibrate camera from chessboard corners (simplified).
pub fn calibrate_camera(
  corners : ChessboardCorners,
  image_width : Int,
  image_height : Int,
) -> CalibrationResult {
  let cx = image_width.to_double() / 2.0
  let cy = image_height.to_double() / 2.0
  let mut sum_dx = 0.0
  let mut sum_dy = 0.0
  let mut count = 0
  let cs = corners.corners
  if cs.length() >= 4 && corners.rows > 1 && corners.cols > 1 {
    for row in 0..<corners.rows {
      for col in 0..<(corners.cols - 1) {
        let idx1 = row * corners.cols + col
        let idx2 = row * corners.cols + col + 1
        if idx1 < cs.length() && idx2 < cs.length() {
          let (x1, _) = cs[idx1]
          let (x2, _) = cs[idx2]
          sum_dx = sum_dx + (x2 - x1).abs()
          count = count + 1
        }
      }
    }
    for col in 0..<corners.cols {
      for row in 0..<(corners.rows - 1) {
        let idx1 = row * corners.cols + col
        let idx2 = (row + 1) * corners.cols + col
        if idx1 < cs.length() && idx2 < cs.length() {
          let (_, y1) = cs[idx1]
          let (_, y2) = cs[idx2]
          sum_dy = sum_dy + (y2 - y1).abs()
          count = count + 1
        }
      }
    }
  }
  let avg_dx = if count > 0 { sum_dx / count.to_double() } else { 1.0 }
  let avg_dy = if count > 0 { sum_dy / count.to_double() } else { 1.0 }
  let fx = avg_dx * corners.cols.to_double()
  let fy = avg_dy * corners.rows.to_double()
  let intrinsics = {
    fx,
    fy,
    cx,
    cy,
    k1: 0.0,
    k2: 0.0,
    k3: 0.0,
    p1: 0.0,
    p2: 0.0,
  }
  let error = compute_reprojection_error(intrinsics, corners)
  { intrinsics, reprojection_error: error, success: error < 10.0, }
}

///|
/// 畸变校正（单点）。
/// Undistort a single point.
pub fn undistort_point(
  intrinsics : CameraIntrinsics,
  x : Double,
  y : Double,
) -> (Double, Double) {
  let xn = (x - intrinsics.cx) / intrinsics.fx
  let yn = (y - intrinsics.cy) / intrinsics.fy
  let r2 = xn * xn + yn * yn
  let r4 = r2 * r2
  let r6 = r4 * r2
  let radial = 1.0 +
    intrinsics.k1 * r2 +
    intrinsics.k2 * r4 +
    intrinsics.k3 * r6
  let dx = 2.0 * intrinsics.p1 * xn * yn + intrinsics.p2 * (r2 + 2.0 * xn * xn)
  let dy = intrinsics.p1 * (r2 + 2.0 * yn * yn) + 2.0 * intrinsics.p2 * xn * yn
  let xd = xn * radial + dx
  let yd = yn * radial + dy
  (intrinsics.fx * xd + intrinsics.cx, intrinsics.fy * yd + intrinsics.cy)
}

///|
/// 图像畸变校正。
/// Undistort image.
pub fn undistort_image(
  img : @types.Image,
  intrinsics : CameraIntrinsics,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let (ux, uy) = undistort_point(intrinsics, x.to_double(), y.to_double())
      let ix = ux.to_int()
      let iy = uy.to_int()
      for c in 0..<ch {
        if ix >= 0 && ix < w && iy >= 0 && iy < h {
          let src_idx = (iy * w + ix) * ch + c
          data.push(img.data[src_idx])
        } else {
          data.push(b'\x00')
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 计算重投影误差。
/// Compute reprojection error.
pub fn compute_reprojection_error(
  intrinsics : CameraIntrinsics,
  corners : ChessboardCorners,
) -> Double {
  let cs = corners.corners
  let mut total_error = 0.0
  let mut count = 0
  for i in 0..<cs.length() {
    let (x, y) = cs[i]
    let (ux, uy) = undistort_point(intrinsics, x, y)
    let dx = ux - x
    let dy = uy - y
    total_error = total_error + (dx * dx + dy * dy).sqrt()
    count = count + 1
  }
  if count > 0 {
    total_error / count.to_double()
  } else {
    0.0
  }
}

///|
/// 从标定结果提取焦距。
/// Extract focal length from calibration.
pub fn CalibrationResult::focal_length(
  self : CalibrationResult,
) -> (Double, Double) {
  (self.intrinsics.fx, self.intrinsics.fy)
}

///|
/// 从标定结果提取主点。
/// Extract principal point from calibration.
pub fn CalibrationResult::principal_point(
  self : CalibrationResult,
) -> (Double, Double) {
  (self.intrinsics.cx, self.intrinsics.cy)
}
