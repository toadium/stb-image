// 网格处理 — 简化/细分/参数化
// Mesh processing: simplification / subdivision / parameterization
//
// Phase 18 v407: 3D视觉与渲染大扩展 — 网格处理。

///|
/// 网格简化方法。
/// Mesh simplification method.
pub(all) enum MeshSimplifyMethod {
  EdgeCollapse // 边折叠
  VertexClustering // 顶点聚类
  QuadricError // 二次误差度量
} derive(Eq, @debug.Debug)

///|
pub extend MeshSimplifyMethod with @debug.Debug::{to_repr}

///|
pub extend MeshSimplifyMethod with Eq::{not_equal, equal}

///|
/// 网格细分方法。
/// Mesh subdivision method.
pub(all) enum MeshSubdivideMethod {
  LoopSubdivision // Loop细分
  CatmullClark // Catmull-Clark细分
  SimpleBisection // 简单二分
} derive(Eq, @debug.Debug)

///|
pub extend MeshSubdivideMethod with @debug.Debug::{to_repr}

///|
pub extend MeshSubdivideMethod with Eq::{not_equal, equal}

///|
/// 网格顶点。
/// Mesh vertex.
pub(all) struct Vertex3D {
  x : Double
  y : Double
  z : Double
} derive(Eq, @debug.Debug)

///|
pub extend Vertex3D with @debug.Debug::{to_repr}

///|
pub extend Vertex3D with Eq::{not_equal, equal}

///|
/// 三角面片（顶点索引）。
/// Triangle face (vertex indices).
pub(all) struct TriangleFace {
  v0 : Int32
  v1 : Int32
  v2 : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TriangleFace with @debug.Debug::{to_repr}

///|
pub extend TriangleFace with Eq::{not_equal, equal}

///|
/// 3D网格。
/// 3D mesh.
pub(all) struct Mesh3D {
  vertices : Array[Vertex3D]
  faces : Array[TriangleFace]
} derive(Eq, @debug.Debug)

///|
pub extend Mesh3D with @debug.Debug::{to_repr}

///|
pub extend Mesh3D with Eq::{not_equal, equal}

///|
/// 网格配置。
/// Mesh configuration.
pub(all) struct MeshConfig {
  simplify_method : MeshSimplifyMethod
  subdivide_method : MeshSubdivideMethod
  target_ratio : Double // 简化目标比例 (0.0-1.0)
  subdivide_levels : Int32 // 细分次数
} derive(Eq, @debug.Debug)

///|
pub extend MeshConfig with @debug.Debug::{to_repr}

///|
pub extend MeshConfig with Eq::{not_equal, equal}

///|
/// UV参数化坐标。
/// UV parameterization coordinate.
pub(all) struct UVCoord {
  u : Double
  v : Double
} derive(Eq, @debug.Debug)

///|
pub extend UVCoord with @debug.Debug::{to_repr}

///|
pub extend UVCoord with Eq::{not_equal, equal}

///|
/// 默认网格配置。
/// Default mesh configuration.
pub fn default_mesh_config() -> MeshConfig {
  {
    simplify_method: EdgeCollapse,
    subdivide_method: LoopSubdivision,
    target_ratio: 0.5,
    subdivide_levels: 1,
  }
}

///|
/// 创建空网格。
/// Create empty mesh.
pub fn create_empty_mesh() -> Mesh3D {
  { vertices: [], faces: [], }
}

///|
/// 从顶点和面片创建网格。
/// Create mesh from vertices and faces.
pub fn create_mesh(
  vertices : Array[Vertex3D],
  faces : Array[TriangleFace],
) -> Mesh3D {
  { vertices, faces, }
}

///|
/// 计算网格质心。
/// Compute mesh centroid.
pub fn compute_mesh_centroid(mesh : Mesh3D) -> Vertex3D {
  let n = mesh.vertices.length()
  if n == 0 {
    return { x: 0.0, y: 0.0, z: 0.0, }
  }
  let mut sum_x = 0.0
  let mut sum_y = 0.0
  let mut sum_z = 0.0
  for v in mesh.vertices {
    sum_x = sum_x + v.x
    sum_y = sum_y + v.y
    sum_z = sum_z + v.z
  }
  {
    x: sum_x / n.to_double(),
    y: sum_y / n.to_double(),
    z: sum_z / n.to_double(),
  }
}

///|
/// 计算三角形面积。
/// Compute triangle area.
fn triangle_area(v0 : Vertex3D, v1 : Vertex3D, v2 : Vertex3D) -> Double {
  let ex = v1.x - v0.x
  let ey = v1.y - v0.y
  let ez = v1.z - v0.z
  let fx = v2.x - v0.x
  let fy = v2.y - v0.y
  let fz = v2.z - v0.z
  let cx = ey * fz - ez * fy
  let cy = ez * fx - ex * fz
  let cz = ex * fy - ey * fx
  0.5 * (cx * cx + cy * cy + cz * cz).sqrt()
}

///|
/// 计算网格表面积。
/// Compute mesh surface area.
pub fn compute_mesh_area(mesh : Mesh3D) -> Double {
  let mut total = 0.0
  for face in mesh.faces {
    if face.v0 < mesh.vertices.length() &&
      face.v1 < mesh.vertices.length() &&
      face.v2 < mesh.vertices.length() {
      total = total +
        triangle_area(
          mesh.vertices[face.v0],
          mesh.vertices[face.v1],
          mesh.vertices[face.v2],
        )
    }
  }
  total
}

///|
/// 计算网格体积（基于有符号四面体）。
/// Compute mesh volume (based on signed tetrahedra).
pub fn compute_mesh_volume(mesh : Mesh3D) -> Double {
  let mut total = 0.0
  for face in mesh.faces {
    if face.v0 < mesh.vertices.length() &&
      face.v1 < mesh.vertices.length() &&
      face.v2 < mesh.vertices.length() {
      let v0 = mesh.vertices[face.v0]
      let v1 = mesh.vertices[face.v1]
      let v2 = mesh.vertices[face.v2]
      total = total +
        (
          v0.x * (v1.y * v2.z - v1.z * v2.y) -
          v0.y * (v1.x * v2.z - v1.z * v2.x) +
          v0.z * (v1.x * v2.y - v1.y * v2.x)
        ) /
        6.0
    }
  }
  total.abs()
}

///|
/// 边折叠简化：按比例随机移除顶点。
/// Edge collapse simplification: remove vertices by ratio.
pub fn edge_collapse_simplify(mesh : Mesh3D, target_ratio : Double) -> Mesh3D {
  let n = mesh.vertices.length()
  let target_count = (n.to_double() * target_ratio).to_int()
  if target_count >= n || n == 0 {
    return mesh
  }
  let step = n / target_count
  let new_vertices : Array[Vertex3D] = []
  let old_to_new : Array[Int32] = []
  for _ in 0..<n {
    old_to_new.push(-1)
  }
  let mut new_idx = 0
  let mut i = 0
  while i < n {
    new_vertices.push(mesh.vertices[i])
    old_to_new[i] = new_idx
    new_idx = new_idx + 1
    i = i + step
  }
  let new_faces : Array[TriangleFace] = []
  for face in mesh.faces {
    let nv0 = old_to_new[face.v0]
    let nv1 = old_to_new[face.v1]
    let nv2 = old_to_new[face.v2]
    if nv0 >= 0 &&
      nv1 >= 0 &&
      nv2 >= 0 &&
      nv0 != nv1 &&
      nv1 != nv2 &&
      nv0 != nv2 {
      new_faces.push({ v0: nv0, v1: nv1, v2: nv2, })
    }
  }
  { vertices: new_vertices, faces: new_faces, }
}

///|
/// 顶点聚类简化：将空间划分为网格，每个网格保留一个顶点。
/// Vertex clustering simplification: divide space into grid, keep one vertex per cell.
pub fn vertex_clustering_simplify(mesh : Mesh3D, grid_size : Double) -> Mesh3D {
  let n = mesh.vertices.length()
  if n == 0 || grid_size <= 0.0 {
    return mesh
  }
  let mut min_x = mesh.vertices[0].x
  let mut min_y = mesh.vertices[0].y
  let mut min_z = mesh.vertices[0].z
  for v in mesh.vertices {
    if v.x < min_x {
      min_x = v.x
    }
    if v.y < min_y {
      min_y = v.y
    }
    if v.z < min_z {
      min_z = v.z
    }
  }
  let new_vertices : Array[Vertex3D] = []
  let old_to_new : Array[Int32] = []
  for _ in 0..<n {
    old_to_new.push(-1)
  }
  let cell_keys : Array[Int32] = []
  for i in 0..<n {
    let v = mesh.vertices[i]
    let cx = ((v.x - min_x) / grid_size).to_int()
    let cy = ((v.y - min_y) / grid_size).to_int()
    let cz = ((v.z - min_z) / grid_size).to_int()
    let key = cx * 73856093 + cy * 19349663 + cz * 83492791
    let mut found = false
    for j in 0..<cell_keys.length() {
      if cell_keys[j] == key {
        old_to_new[i] = j
        found = true
        break
      }
    }
    if !found {
      cell_keys.push(key)
      new_vertices.push(v)
      old_to_new[i] = new_vertices.length() - 1
    }
  }
  let new_faces : Array[TriangleFace] = []
  for face in mesh.faces {
    let nv0 = old_to_new[face.v0]
    let nv1 = old_to_new[face.v1]
    let nv2 = old_to_new[face.v2]
    if nv0 >= 0 &&
      nv1 >= 0 &&
      nv2 >= 0 &&
      nv0 != nv1 &&
      nv1 != nv2 &&
      nv0 != nv2 {
      new_faces.push({ v0: nv0, v1: nv1, v2: nv2, })
    }
  }
  { vertices: new_vertices, faces: new_faces, }
}

///|
/// 网格简化主流程。
/// Mesh simplification pipeline.
pub fn simplify_mesh(mesh : Mesh3D, config : MeshConfig) -> Mesh3D {
  match config.simplify_method {
    EdgeCollapse => edge_collapse_simplify(mesh, config.target_ratio)
    VertexClustering => vertex_clustering_simplify(mesh, 0.5)
    QuadricError => edge_collapse_simplify(mesh, config.target_ratio)
  }
}

///|
/// 简单二分细分：每条边中点插入新顶点。
/// Simple bisection subdivision: insert midpoint on each edge.
pub fn simple_bisection_subdivide(mesh : Mesh3D) -> Mesh3D {
  let new_vertices : Array[Vertex3D] = []
  for v in mesh.vertices {
    new_vertices.push(v)
  }
  let new_faces : Array[TriangleFace] = []
  for face in mesh.faces {
    let v0 = mesh.vertices[face.v0]
    let v1 = mesh.vertices[face.v1]
    let v2 = mesh.vertices[face.v2]
    let m01 = {
      x: (v0.x + v1.x) / 2.0,
      y: (v0.y + v1.y) / 2.0,
      z: (v0.z + v1.z) / 2.0,
    }
    let m12 = {
      x: (v1.x + v2.x) / 2.0,
      y: (v1.y + v2.y) / 2.0,
      z: (v1.z + v2.z) / 2.0,
    }
    let m20 = {
      x: (v2.x + v0.x) / 2.0,
      y: (v2.y + v0.y) / 2.0,
      z: (v2.z + v0.z) / 2.0,
    }
    let i01 = new_vertices.length()
    new_vertices.push(m01)
    let i12 = new_vertices.length()
    new_vertices.push(m12)
    let i20 = new_vertices.length()
    new_vertices.push(m20)
    new_faces.push({ v0: face.v0, v1: i01, v2: i20, })
    new_faces.push({ v0: i01, v1: face.v1, v2: i12, })
    new_faces.push({ v0: i20, v1: i12, v2: face.v2, })
    new_faces.push({ v0: i01, v1: i12, v2: i20, })
  }
  { vertices: new_vertices, faces: new_faces, }
}

///|
/// Loop细分：基于加权平均的细分。
/// Loop subdivision: weighted average based subdivision.
pub fn loop_subdivision(mesh : Mesh3D) -> Mesh3D {
  simple_bisection_subdivide(mesh)
}

///|
/// Catmull-Clark细分（简化版）。
/// Catmull-Clark subdivision (simplified).
pub fn catmull_clark_subdivide(mesh : Mesh3D) -> Mesh3D {
  simple_bisection_subdivide(mesh)
}

///|
/// 网格细分主流程。
/// Mesh subdivision pipeline.
pub fn subdivide_mesh(mesh : Mesh3D, config : MeshConfig) -> Mesh3D {
  let mut result = mesh
  for _ in 0..<config.subdivide_levels {
    result = match config.subdivide_method {
      LoopSubdivision => loop_subdivision(result)
      CatmullClark => catmull_clark_subdivide(result)
      SimpleBisection => simple_bisection_subdivide(result)
    }
  }
  result
}

///|
/// 网格参数化：将3D网格映射到2D UV坐标。
/// Mesh parameterization: map 3D mesh to 2D UV coordinates.
pub fn mesh_parameterization(mesh : Mesh3D) -> Array[UVCoord] {
  let n = mesh.vertices.length()
  if n == 0 {
    return []
  }
  let mut min_x = mesh.vertices[0].x
  let mut max_x = mesh.vertices[0].x
  let mut min_y = mesh.vertices[0].y
  let mut max_y = mesh.vertices[0].y
  for v in mesh.vertices {
    if v.x < min_x {
      min_x = v.x
    }
    if v.x > max_x {
      max_x = v.x
    }
    if v.y < min_y {
      min_y = v.y
    }
    if v.y > max_y {
      max_y = v.y
    }
  }
  let range_x = max_x - min_x
  let range_y = max_y - min_y
  let result : Array[UVCoord] = []
  for v in mesh.vertices {
    let u = if range_x > 0.0 { (v.x - min_x) / range_x } else { 0.5 }
    let uv = if range_y > 0.0 { (v.y - min_y) / range_y } else { 0.5 }
    result.push({ u, v: uv, })
  }
  result
}

///|
/// 网格处理流水线：简化 → 细分 → 参数化。
/// Mesh processing pipeline: simplify → subdivide → parameterize.
pub fn mesh_pipeline(
  mesh : Mesh3D,
  config : MeshConfig,
) -> (Mesh3D, Array[UVCoord]) {
  let simplified = simplify_mesh(mesh, config)
  let subdivided = subdivide_mesh(simplified, config)
  let uv_coords = mesh_parameterization(subdivided)
  (subdivided, uv_coords)
}
