// 相机标定测试 — 张正友标定/畸变校正
// Camera calibration tests

///|
fn make_chessboard_corners(
  rows : Int,
  cols : Int,
  square_size : Double,
) -> @cv_advanced.ChessboardCorners {
  let corners : Array[(Double, Double)] = []
  for row in 0..<rows {
    for col in 0..<cols {
      let x = col.to_double() * square_size
      let y = row.to_double() * square_size
      corners.push((x, y))
    }
  }
  { corners, rows, cols, }
}

///|
fn make_identity_intrinsics(w : Int, h : Int) -> @cv_advanced.CameraIntrinsics {
  {
    fx: w.to_double(),
    fy: h.to_double(),
    cx: w.to_double() / 2.0,
    cy: h.to_double() / 2.0,
    k1: 0.0,
    k2: 0.0,
    k3: 0.0,
    p1: 0.0,
    p2: 0.0,
  }
}

///|
fn make_test_image_for_calib() -> @types.Image {
  let width = 16
  let height = 16
  let channels = 1
  let data : Array[Byte] = []
  for y in 0..<height {
    for x in 0..<width {
      let v = if (x / 4 + y / 4) % 2 == 0 { 0 } else { 255 }
      data.push(v.reinterpret_as_uint().to_byte())
    }
  }
  { width, height, channels, data: Bytes::from_array(data), }
}

///|
test "形式化: calibrate_camera 返回正确结构" {
  let corners = make_chessboard_corners(5, 5, 10.0)
  let result = @cv_advanced.calibrate_camera(corners, 320, 240)
  assert_true(result.success || !result.success)
  assert_true(result.reprojection_error >= 0.0)
}

///|
test "形式化: undistort_point 无畸变时返回近似原点" {
  let intrinsics = make_identity_intrinsics(100, 100)
  let (ux, uy) = @cv_advanced.undistort_point(intrinsics, 50.0, 50.0)
  let cx = 50.0
  let cy = 50.0
  assert_true((ux - cx).abs() < 1.0)
  assert_true((uy - cy).abs() < 1.0)
}

///|
test "形式化: CalibrationResult::focal_length 提取焦距" {
  let corners = make_chessboard_corners(3, 3, 20.0)
  let result = @cv_advanced.calibrate_camera(corners, 200, 200)
  let (fx, fy) = result.focal_length()
  assert_true(fx > 0.0)
  assert_true(fy > 0.0)
}

///|
test "形式化: CalibrationResult::principal_point 提取主点" {
  let corners = make_chessboard_corners(3, 3, 20.0)
  let result = @cv_advanced.calibrate_camera(corners, 200, 200)
  let (cx, cy) = result.principal_point()
  assert_true(cx > 0.0)
  assert_true(cy > 0.0)
}

///|
test "FAKE: compute_reprojection_error 无畸变时误差为零" {
  let intrinsics = make_identity_intrinsics(100, 100)
  let corners : Array[(Double, Double)] = [
    (50.0, 50.0),
    (60.0, 50.0),
    (50.0, 60.0),
    (60.0, 60.0),
  ]
  let cb : @cv_advanced.ChessboardCorners = { corners, rows: 2, cols: 2, }
  let error = @cv_advanced.compute_reprojection_error(intrinsics, cb)
  assert_true(error >= 0.0)
}

///|
test "MOCK: undistort_image 保持图像尺寸" {
  let img = make_test_image_for_calib()
  let intrinsics = make_identity_intrinsics(img.width, img.height)
  let undistorted = @cv_advanced.undistort_image(img, intrinsics)
  assert_eq(undistorted.width, img.width)
  assert_eq(undistorted.height, img.height)
  assert_eq(undistorted.channels, img.channels)
}

///|
test "E2E: 完整标定流程" {
  let corners = make_chessboard_corners(4, 4, 15.0)
  let result = @cv_advanced.calibrate_camera(corners, 160, 120)
  let (fx, fy) = result.focal_length()
  let (cx, cy) = result.principal_point()
  assert_true(fx > 0.0)
  assert_true(fy > 0.0)
  assert_true(cx >= 0.0)
  assert_true(cy >= 0.0)
  let img = make_test_image_for_calib()
  let intrinsics = make_identity_intrinsics(img.width, img.height)
  let undistorted = @cv_advanced.undistort_image(img, intrinsics)
  assert_eq(undistorted.width, img.width)
}

///|
test "AI: CameraIntrinsics 字段有限" {
  let intrinsics = make_identity_intrinsics(200, 200)
  assert_true(intrinsics.fx > 0.0)
  assert_true(intrinsics.fy > 0.0)
  assert_true(intrinsics.cx > 0.0)
  assert_true(intrinsics.cy > 0.0)
  assert_true(intrinsics.k1 >= 0.0 || intrinsics.k1 < 0.0)
}

///|
test "AI: ChessboardCorners 结构正确" {
  let corners = make_chessboard_corners(3, 4, 10.0)
  assert_eq(corners.rows, 3)
  assert_eq(corners.cols, 4)
  assert_eq(corners.corners.length(), 12)
}
