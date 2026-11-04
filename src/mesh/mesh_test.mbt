///|
test "MeshSimplifyMethod: 枚举值" {
  assert_true(@mesh.EdgeCollapse is @mesh.EdgeCollapse)
  assert_true(@mesh.VertexClustering is @mesh.VertexClustering)
  assert_true(@mesh.QuadricError is @mesh.QuadricError)
}

///|
test "MeshSubdivideMethod: 枚举值" {
  assert_true(@mesh.LoopSubdivision is @mesh.LoopSubdivision)
  assert_true(@mesh.CatmullClark is @mesh.CatmullClark)
  assert_true(@mesh.SimpleBisection is @mesh.SimpleBisection)
}

///|
test "Vertex3D: 构造与字段" {
  let v : @mesh.Vertex3D = { x: 1.0, y: 2.0, z: 3.0, }
  assert_eq(v.x, 1.0)
  assert_eq(v.y, 2.0)
  assert_eq(v.z, 3.0)
}

///|
test "TriangleFace: 构造与字段" {
  let f : @mesh.TriangleFace = { v0: 0, v1: 1, v2: 2, }
  assert_eq(f.v0, 0)
  assert_eq(f.v1, 1)
  assert_eq(f.v2, 2)
}

///|
test "MeshConfig: 构造与字段" {
  let config : @mesh.MeshConfig = {
    simplify_method: @mesh.QuadricError,
    subdivide_method: @mesh.CatmullClark,
    target_ratio: 0.3,
    subdivide_levels: 2,
  }
  assert_eq(config.target_ratio, 0.3)
  assert_eq(config.subdivide_levels, 2)
  assert_true(config.simplify_method is @mesh.QuadricError)
  assert_true(config.subdivide_method is @mesh.CatmullClark)
}

///|
test "default_mesh_config: 默认值" {
  let config = @mesh.default_mesh_config()
  assert_eq(config.target_ratio, 0.5)
  assert_eq(config.subdivide_levels, 1)
  assert_true(config.simplify_method is @mesh.EdgeCollapse)
  assert_true(config.subdivide_method is @mesh.LoopSubdivision)
}

///|
test "create_empty_mesh: 空网格" {
  let mesh = @mesh.create_empty_mesh()
  assert_eq(mesh.vertices.length(), 0)
  assert_eq(mesh.faces.length(), 0)
}

///|
test "create_mesh: 从顶点和面片创建" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  assert_eq(mesh.vertices.length(), 3)
  assert_eq(mesh.faces.length(), 1)
}

///|
test "compute_mesh_centroid: 质心计算" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 2.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 2.0, z: 0.0, },
    { x: 2.0, y: 2.0, z: 0.0, },
  ]
  let mesh = @mesh.create_mesh(vertices, [])
  let centroid = @mesh.compute_mesh_centroid(mesh)
  assert_eq(centroid.x, 1.0)
  assert_eq(centroid.y, 1.0)
  assert_eq(centroid.z, 0.0)
}

///|
test "compute_mesh_centroid: 空网格" {
  let mesh = @mesh.create_empty_mesh()
  let centroid = @mesh.compute_mesh_centroid(mesh)
  assert_eq(centroid.x, 0.0)
  assert_eq(centroid.y, 0.0)
  assert_eq(centroid.z, 0.0)
}

///|
test "compute_mesh_area: 三角形面积" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 2.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 2.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  let area = @mesh.compute_mesh_area(mesh)
  assert_eq(area, 2.0)
}

///|
test "compute_mesh_area: 空网格" {
  let mesh = @mesh.create_empty_mesh()
  let area = @mesh.compute_mesh_area(mesh)
  assert_eq(area, 0.0)
}

///|
test "compute_mesh_volume: 四面体体积" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
    { x: 0.0, y: 0.0, z: 1.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [
    { v0: 1, v1: 2, v2: 3, },
    { v0: 0, v1: 3, v2: 2, },
    { v0: 0, v1: 1, v2: 3, },
    { v0: 0, v1: 2, v2: 1, },
  ]
  let mesh = @mesh.create_mesh(vertices, faces)
  let volume = @mesh.compute_mesh_volume(mesh)
  assert_true(volume > 0.1)
  assert_true(volume < 0.2)
}

///|
test "edge_collapse_simplify: 边折叠" {
  let vertices : Array[@mesh.Vertex3D] = []
  for i in 0..<100 {
    vertices.push({ x: i.to_double(), y: 0.0, z: 0.0, })
  }
  let mesh = @mesh.create_mesh(vertices, [])
  let simplified = @mesh.edge_collapse_simplify(mesh, 0.5)
  assert_true(simplified.vertices.length() < 100)
  assert_true(simplified.vertices.length() > 0)
}

///|
test "vertex_clustering_simplify: 顶点聚类" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 0.1, y: 0.1, z: 0.1, },
    { x: 5.0, y: 5.0, z: 5.0, },
    { x: 5.1, y: 5.1, z: 5.1, },
  ]
  let mesh = @mesh.create_mesh(vertices, [])
  let simplified = @mesh.vertex_clustering_simplify(mesh, 1.0)
  assert_eq(simplified.vertices.length(), 2)
}

///|
test "simplify_mesh: 各方法" {
  let vertices : Array[@mesh.Vertex3D] = []
  for i in 0..<50 {
    vertices.push({ x: i.to_double(), y: 0.0, z: 0.0, })
  }
  let mesh = @mesh.create_mesh(vertices, [])
  let config = @mesh.default_mesh_config()
  let simplified = @mesh.simplify_mesh(mesh, config)
  assert_true(simplified.vertices.length() > 0)
}

///|
test "simple_bisection_subdivide: 二分细分" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  let subdivided = @mesh.simple_bisection_subdivide(mesh)
  // 3原顶点 + 3中点 = 6顶点
  assert_eq(subdivided.vertices.length(), 6)
  // 1面 → 4面
  assert_eq(subdivided.faces.length(), 4)
}

///|
test "loop_subdivision: Loop细分" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  let subdivided = @mesh.loop_subdivision(mesh)
  assert_eq(subdivided.vertices.length(), 6)
  assert_eq(subdivided.faces.length(), 4)
}

///|
test "subdivide_mesh: 多次细分" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  let config : @mesh.MeshConfig = {
    simplify_method: @mesh.EdgeCollapse,
    subdivide_method: @mesh.SimpleBisection,
    target_ratio: 1.0,
    subdivide_levels: 2,
  }
  let subdivided = @mesh.subdivide_mesh(mesh, config)
  // 2次细分: 1面 → 4面 → 16面
  assert_eq(subdivided.faces.length(), 16)
}

///|
test "mesh_parameterization: UV参数化" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 1.0, },
    { x: 0.0, y: 1.0, z: 2.0, },
    { x: 1.0, y: 1.0, z: 3.0, },
  ]
  let mesh = @mesh.create_mesh(vertices, [])
  let uv = @mesh.mesh_parameterization(mesh)
  assert_eq(uv.length(), 4)
  // 第一个点应在(0,0)
  assert_eq(uv[0].u, 0.0)
  assert_eq(uv[0].v, 0.0)
  // 最后一个点应在(1,1)
  assert_eq(uv[3].u, 1.0)
  assert_eq(uv[3].v, 1.0)
}

///|
test "mesh_parameterization: 空网格" {
  let mesh = @mesh.create_empty_mesh()
  let uv = @mesh.mesh_parameterization(mesh)
  assert_eq(uv.length(), 0)
}

///|
test "mesh_pipeline: 完整流水线" {
  let vertices : Array[@mesh.Vertex3D] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let faces : Array[@mesh.TriangleFace] = [{ v0: 0, v1: 1, v2: 2, }]
  let mesh = @mesh.create_mesh(vertices, faces)
  let config = @mesh.default_mesh_config()
  let (result, uv) = @mesh.mesh_pipeline(mesh, config)
  assert_true(result.vertices.length() > 0)
  assert_true(uv.length() > 0)
}

///|
test "UVCoord: 构造与字段" {
  let uv : @mesh.UVCoord = { u: 0.5, v: 0.7, }
  assert_eq(uv.u, 0.5)
  assert_eq(uv.v, 0.7)
}
