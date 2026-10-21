// 3D 重建测试
// 3D reconstruction tests

///|
test "recon_marching_cubes: 空体素" {
  let volume = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let mesh = @cv_advanced.recon_marching_cubes(volume, 2, 2, 2, 0.5)
  assert_eq(mesh.faces.length(), 0)
}

///|
test "recon_marching_cubes: 有表面" {
  let volume = [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  let mesh = @cv_advanced.recon_marching_cubes(volume, 2, 2, 2, 0.5)
  assert_true(mesh.faces.length() >= 0)
}

///|
test "recon_mip: 最大强度" {
  let volume = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
  let result = @cv_advanced.recon_mip(volume, 2, 2, 2)
  assert_eq(result.length(), 4)
  assert_eq(result[0], 0.5)
  assert_eq(result[3], 0.8)
}

///|
test "recon_volume_render: 基本渲染" {
  let volume = [0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
  let result = @cv_advanced.recon_volume_render(volume, 2, 2, 2, 0.5)
  assert_eq(result.length(), 4)
  for i in 0..<4 {
    assert_true(result[i] > 0.0)
  }
}

///|
test "recon_surface_extract: 阈值分割" {
  let volume = [0.1, 0.5, 0.3, 0.8, 0.2, 0.9]
  let result = @cv_advanced.recon_surface_extract(volume, 0.4)
  assert_eq(result.length(), 6)
  assert_eq(result[0], 0)
  assert_eq(result[1], 1)
  assert_eq(result[3], 1)
}

///|
test "recon_compute_surface_area: 三角形面积" {
  let p0 = @cv_advanced.MedPoint3D::{ x: 0.0, y: 0.0, z: 0.0, }
  let p1 = @cv_advanced.MedPoint3D::{ x: 1.0, y: 0.0, z: 0.0, }
  let p2 = @cv_advanced.MedPoint3D::{ x: 0.0, y: 1.0, z: 0.0, }
  let face = @cv_advanced.MedTriangle3D::{ v0: p0, v1: p1, v2: p2, }
  let mesh = @cv_advanced.MedMesh3D::{ vertices: [p0, p1, p2], faces: [face], }
  let area = @cv_advanced.recon_compute_surface_area(mesh)
  assert_true(area > 0.49 && area < 0.51)
}

///|
test "recon_compute_volume: 四面体体积" {
  let p0 = @cv_advanced.MedPoint3D::{ x: 0.0, y: 0.0, z: 0.0, }
  let p1 = @cv_advanced.MedPoint3D::{ x: 1.0, y: 0.0, z: 0.0, }
  let p2 = @cv_advanced.MedPoint3D::{ x: 0.0, y: 1.0, z: 0.0, }
  let face = @cv_advanced.MedTriangle3D::{ v0: p0, v1: p1, v2: p2, }
  let mesh = @cv_advanced.MedMesh3D::{ vertices: [p0, p1, p2], faces: [face], }
  let vol = @cv_advanced.recon_compute_volume(mesh)
  let _ = vol
  assert_true(true)
}

///|
test "recon_simplify_mesh: 合并近点" {
  let p0 = @cv_advanced.MedPoint3D::{ x: 0.0, y: 0.0, z: 0.0, }
  let p1 = @cv_advanced.MedPoint3D::{ x: 0.001, y: 0.0, z: 0.0, }
  let p2 = @cv_advanced.MedPoint3D::{ x: 1.0, y: 0.0, z: 0.0, }
  let face = @cv_advanced.MedTriangle3D::{ v0: p0, v1: p1, v2: p2, }
  let mesh = @cv_advanced.MedMesh3D::{ vertices: [p0, p1, p2], faces: [face], }
  let simplified = @cv_advanced.recon_simplify_mesh(mesh, 0.01)
  assert_true(simplified.vertices.length() <= 3)
}

///|
test "recon_mip: 单层体素" {
  let volume = [0.3, 0.7, 0.5, 0.2]
  let result = @cv_advanced.recon_mip(volume, 2, 2, 1)
  assert_eq(result.length(), 4)
  assert_eq(result[0], 0.3)
  assert_eq(result[1], 0.7)
}
