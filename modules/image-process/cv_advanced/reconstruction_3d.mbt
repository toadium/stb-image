// 3D 重建 — Marching Cubes/表面渲染/体绘制
// 3D reconstruction
//
// Phase 14 v354: 医学影像大扩展 — 3D 重建。

///|
/// 3D 点。
/// 3D point.
pub(all) struct MedPoint3D {
  x : Double
  y : Double
  z : Double
} derive(Eq, @debug.Debug)

///|
pub extend MedPoint3D with @debug.Debug::{to_repr}

///|
pub extend MedPoint3D with Eq::{not_equal, equal}

///|
/// 3D 三角面片。
/// 3D triangle face.
pub(all) struct MedTriangle3D {
  v0 : MedPoint3D
  v1 : MedPoint3D
  v2 : MedPoint3D
} derive(Eq, @debug.Debug)

///|
pub extend MedTriangle3D with @debug.Debug::{to_repr}

///|
pub extend MedTriangle3D with Eq::{not_equal, equal}

///|
/// 3D 网格。
/// 3D mesh.
pub(all) struct MedMesh3D {
  vertices : Array[MedPoint3D]
  faces : Array[MedTriangle3D]
} derive(Eq, @debug.Debug)

///|
pub extend MedMesh3D with @debug.Debug::{to_repr}

///|
pub extend MedMesh3D with Eq::{not_equal, equal}

///|
/// Marching Cubes 算法（简化）。
/// Marching Cubes algorithm (simplified).
pub fn recon_marching_cubes(
  volume : Array[Double],
  width : Int32,
  height : Int32,
  depth : Int32,
  isovalue : Double,
) -> MedMesh3D {
  let vertices : Array[MedPoint3D] = []
  let faces : Array[MedTriangle3D] = []
  for z in 0..<(depth - 1) {
    for y in 0..<(height - 1) {
      for x in 0..<(width - 1) {
        let idx = z * width * height + y * width + x
        let c000 = if idx < volume.length() { volume[idx] } else { 0.0 }
        let c100 = if idx + 1 < volume.length() { volume[idx + 1] } else { 0.0 }
        let c010 = if idx + width < volume.length() {
          volume[idx + width]
        } else {
          0.0
        }
        let c110 = if idx + width + 1 < volume.length() {
          volume[idx + width + 1]
        } else {
          0.0
        }
        let c001 = if idx + width * height < volume.length() {
          volume[idx + width * height]
        } else {
          0.0
        }
        let c101 = if idx + width * height + 1 < volume.length() {
          volume[idx + width * height + 1]
        } else {
          0.0
        }
        let c011 = if idx + width * height + width < volume.length() {
          volume[idx + width * height + width]
        } else {
          0.0
        }
        let c111 = if idx + width * height + width + 1 < volume.length() {
          volume[idx + width * height + width + 1]
        } else {
          0.0
        }
        let cube_index = (if c000 > isovalue { 1 } else { 0 }) +
          (if c100 > isovalue { 2 } else { 0 }) +
          (if c010 > isovalue { 4 } else { 0 }) +
          (if c110 > isovalue { 8 } else { 0 }) +
          (if c001 > isovalue { 16 } else { 0 }) +
          (if c101 > isovalue { 32 } else { 0 }) +
          (if c011 > isovalue { 64 } else { 0 }) +
          (if c111 > isovalue { 128 } else { 0 })
        if cube_index > 0 && cube_index < 255 {
          let px = x.to_double()
          let py = y.to_double()
          let pz = z.to_double()
          let p0 = MedPoint3D::{ x: px, y: py, z: pz, }
          let p1 = MedPoint3D::{ x: px + 1.0, y: py, z: pz, }
          let p2 = MedPoint3D::{ x: px, y: py + 1.0, z: pz, }
          vertices.push(p0)
          vertices.push(p1)
          vertices.push(p2)
          let v_base = vertices.length() - 3
          faces.push(MedTriangle3D::{
            v0: vertices[v_base],
            v1: vertices[v_base + 1],
            v2: vertices[v_base + 2],
          })
        }
      }
    }
  }
  MedMesh3D::{ vertices, faces, }
}

///|
/// 最大强度投影。
/// Maximum intensity projection.
pub fn recon_mip(
  volume : Array[Double],
  width : Int32,
  height : Int32,
  depth : Int32,
) -> Array[Double] {
  let result : Array[Double] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut max_val = -1.7976931348623157e308
      for z in 0..<depth {
        let idx = z * width * height + y * width + x
        if idx < volume.length() {
          if volume[idx] > max_val {
            max_val = volume[idx]
          }
        }
      }
      if max_val == -1.7976931348623157e308 {
        max_val = 0.0
      }
      result.push(max_val)
    }
  }
  result
}

///|
/// 体绘制（简化累积）。
/// Volume rendering (simplified accumulation).
pub fn recon_volume_render(
  volume : Array[Double],
  width : Int32,
  height : Int32,
  depth : Int32,
  opacity : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut acc = 0.0
      let mut remaining = 1.0
      for z in 0..<depth {
        let idx = z * width * height + y * width + x
        if idx < volume.length() {
          let val = volume[idx]
          acc = acc + val * opacity * remaining
          remaining = remaining * (1.0 - opacity)
        }
      }
      result.push(acc)
    }
  }
  result
}

///|
/// 表面提取（阈值化）。
/// Surface extraction (thresholding).
pub fn recon_surface_extract(
  volume : Array[Double],
  threshold : Double,
) -> Array[Int32] {
  let result : Array[Int32] = []
  for i in 0..<volume.length() {
    if volume[i] > threshold {
      result.push(1)
    } else {
      result.push(0)
    }
  }
  result
}

///|
/// 计算网格表面积。
/// Compute mesh surface area.
pub fn recon_compute_surface_area(mesh : MedMesh3D) -> Double {
  let mut total_area = 0.0
  for i in 0..<mesh.faces.length() {
    let face = mesh.faces[i]
    let ax = face.v1.x - face.v0.x
    let ay = face.v1.y - face.v0.y
    let az = face.v1.z - face.v0.z
    let bx = face.v2.x - face.v0.x
    let by = face.v2.y - face.v0.y
    let bz = face.v2.z - face.v0.z
    let cx = ay * bz - az * by
    let cy = az * bx - ax * bz
    let cz = ax * by - ay * bx
    let area = (cx * cx + cy * cy + cz * cz).sqrt() * 0.5
    total_area = total_area + area
  }
  total_area
}

///|
/// 计算网格体积。
/// Compute mesh volume.
pub fn recon_compute_volume(mesh : MedMesh3D) -> Double {
  let mut total_vol = 0.0
  for i in 0..<mesh.faces.length() {
    let face = mesh.faces[i]
    let det = face.v0.x * (face.v1.y * face.v2.z - face.v1.z * face.v2.y) -
      face.v0.y * (face.v1.x * face.v2.z - face.v1.z * face.v2.x) +
      face.v0.z * (face.v1.x * face.v2.y - face.v1.y * face.v2.x)
    total_vol = total_vol + det
  }
  total_vol / 6.0
}

///|
/// 简化网格（顶点合并）。
/// Simplify mesh (vertex merging).
pub fn recon_simplify_mesh(mesh : MedMesh3D, tolerance : Double) -> MedMesh3D {
  let new_vertices : Array[MedPoint3D] = []
  let old_to_new : Array[Int32] = []
  for i in 0..<mesh.vertices.length() {
    let v = mesh.vertices[i]
    let mut found = -1
    for j in 0..<new_vertices.length() {
      let nv = new_vertices[j]
      let dx = v.x - nv.x
      let dy = v.y - nv.y
      let dz = v.z - nv.z
      if (dx * dx + dy * dy + dz * dz).sqrt() < tolerance {
        found = j
      }
    }
    if found >= 0 {
      old_to_new.push(found)
    } else {
      new_vertices.push(v)
      old_to_new.push(new_vertices.length() - 1)
    }
  }
  let new_faces : Array[MedTriangle3D] = []
  for i in 0..<mesh.faces.length() {
    new_faces.push(mesh.faces[i])
  }
  MedMesh3D::{ vertices: new_vertices, faces: new_faces, }
}
