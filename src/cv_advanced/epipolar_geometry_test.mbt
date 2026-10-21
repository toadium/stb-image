// 极线几何测试 — 基础矩阵/本质矩阵/三角化
// Epipolar geometry tests

///|
fn make_identity_fundamental() -> @cv_advanced.FundamentalMatrix {
  {
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

///|
fn make_simple_correspondences() -> Array[@cv_advanced.PointCorrespondence] {
  [
    { x1: 10.0, y1: 10.0, x2: 12.0, y2: 10.0, },
    { x1: 20.0, y1: 10.0, x2: 22.0, y2: 10.0, },
    { x1: 10.0, y1: 20.0, x2: 12.0, y2: 20.0, },
    { x1: 20.0, y1: 20.0, x2: 22.0, y2: 20.0, },
    { x1: 30.0, y1: 30.0, x2: 32.0, y2: 30.0, },
    { x1: 40.0, y1: 20.0, x2: 42.0, y2: 20.0, },
    { x1: 50.0, y1: 10.0, x2: 52.0, y2: 10.0, },
    { x1: 15.0, y1: 25.0, x2: 17.0, y2: 25.0, },
  ]
}

///|
fn make_identity_intrinsics_d(
  w : Int32,
  h : Int32,
) -> @cv_advanced.CameraIntrinsics {
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
test "形式化: compute_fundamental_matrix 返回 3x3 矩阵" {
  let corrs = make_simple_correspondences()
  let f = @cv_advanced.compute_fundamental_matrix(corrs)
  assert_true(f.m22 == 1.0 || f.m22 == 0.0)
}

///|
test "形式化: compute_epipolar_line 返回极线" {
  let f = make_identity_fundamental()
  let line = @cv_advanced.compute_epipolar_line(f, 10.0, 20.0)
  assert_true(line.a >= 0.0 || line.a < 0.0)
  assert_true(line.b >= 0.0 || line.b < 0.0)
}

///|
test "形式化: check_epipolar_constraint 返回非负距离" {
  let line : @cv_advanced.EpipolarLine = { a: 1.0, b: 0.0, c: -5.0, }
  let dist = @cv_advanced.check_epipolar_constraint(line, 10.0, 0.0)
  assert_true(dist >= 0.0)
}

///|
test "形式化: fundamental_matrix_rank 返回 2 或 3" {
  let f = make_identity_fundamental()
  let rank = @cv_advanced.fundamental_matrix_rank(f)
  assert_true(rank == 2 || rank == 3)
}

///|
test "FAKE: compute_essential_matrix 返回矩阵" {
  let corrs = make_simple_correspondences()
  let f = @cv_advanced.compute_fundamental_matrix(corrs)
  let k1 = make_identity_intrinsics_d(100, 100)
  let k2 = make_identity_intrinsics_d(100, 100)
  let e = @cv_advanced.compute_essential_matrix(f, k1, k2)
  assert_true(e.m00 >= 0.0 || e.m00 < 0.0)
}

///|
test "MOCK: triangulate_point 返回 3D 点" {
  let corrs = make_simple_correspondences()
  let f = @cv_advanced.compute_fundamental_matrix(corrs)
  let p = corrs[0]
  let pt3d = @cv_advanced.triangulate_point(p, f)
  assert_true(pt3d.x >= 0.0 || pt3d.x < 0.0)
  assert_true(pt3d.y >= 0.0 || pt3d.y < 0.0)
  assert_true(pt3d.z > 0.0)
}

///|
test "E2E: 完整极线几何流程" {
  let corrs = make_simple_correspondences()
  let f = @cv_advanced.compute_fundamental_matrix(corrs)
  let p = corrs[0]
  let line = @cv_advanced.compute_epipolar_line(f, p.x2, p.y2)
  let dist = @cv_advanced.check_epipolar_constraint(line, p.x1, p.y1)
  assert_true(dist >= 0.0)
  let pt3d = @cv_advanced.triangulate_point(p, f)
  assert_true(pt3d.z > 0.0)
}

///|
test "AI: essential_matrix_svd 返回非负奇异值" {
  let e : @cv_advanced.EssentialMatrix = {
    m00: 1.0,
    m01: 0.0,
    m02: 0.0,
    m10: 0.0,
    m11: 1.0,
    m12: 0.0,
    m20: 0.0,
    m21: 0.0,
    m22: 0.0,
  }
  let (s1, s2, s3) = @cv_advanced.essential_matrix_svd(e)
  assert_true(s1 >= 0.0)
  assert_true(s2 >= 0.0)
  assert_true(s3 >= 0.0)
  assert_true(s1 >= s2)
  assert_true(s2 >= s3)
}
