// 点云处理 — 采样/法向/分割
// Point cloud processing: sampling / normal estimation / segmentation
//
// Phase 18 v406: 3D视觉与渲染大扩展 — 点云处理。

///|
/// 点云采样方法。
/// Point cloud sampling method.
pub(all) enum PointCloudSampleMethod {
  RandomSampling // 随机采样
  UniformSampling // 均匀采样
  VoxelGridSampling // 体素网格采样
} derive(Eq, @debug.Debug)

///|
pub extend PointCloudSampleMethod with @debug.Debug::{to_repr}

///|
pub extend PointCloudSampleMethod with Eq::{not_equal, equal}

///|
/// 法向估计方法。
/// Normal estimation method.
pub(all) enum NormalEstimationMethod {
  KNN // K近邻
  RadiusSearch // 半径搜索
} derive(Eq, @debug.Debug)

///|
pub extend NormalEstimationMethod with @debug.Debug::{to_repr}

///|
pub extend NormalEstimationMethod with Eq::{not_equal, equal}

///|
/// 点云分割方法。
/// Point cloud segmentation method.
pub(all) enum PointCloudSegmentMethod {
  EuclideanClustering // 欧式聚类
  RegionGrowing // 区域生长
  PlaneSegmentation // 平面分割
} derive(Eq, @debug.Debug)

///|
pub extend PointCloudSegmentMethod with @debug.Debug::{to_repr}

///|
pub extend PointCloudSegmentMethod with Eq::{not_equal, equal}

///|
/// 三维点（轻量级）。
/// 3D point (lightweight).
pub(all) struct Point3DLight {
  x : Double
  y : Double
  z : Double
} derive(Eq, @debug.Debug)

///|
pub extend Point3DLight with @debug.Debug::{to_repr}

///|
pub extend Point3DLight with Eq::{not_equal, equal}

///|
/// 点云（轻量级）。
/// Point cloud (lightweight).
pub(all) struct PointCloud3D {
  points : Array[Point3DLight]
  normals : Array[Point3DLight] // 法向量（与points对应）
} derive(Eq, @debug.Debug)

///|
pub extend PointCloud3D with @debug.Debug::{to_repr}

///|
pub extend PointCloud3D with Eq::{not_equal, equal}

///|
/// 点云配置。
/// Point cloud configuration.
pub(all) struct PointCloudConfig {
  sample_method : PointCloudSampleMethod
  normal_method : NormalEstimationMethod
  segment_method : PointCloudSegmentMethod
  knn_k : Int32 // K近邻数
  voxel_size : Double // 体素大小
  cluster_tolerance : Double // 聚类容差
  min_cluster_size : Int32 // 最小聚类大小
} derive(Eq, @debug.Debug)

///|
pub extend PointCloudConfig with @debug.Debug::{to_repr}

///|
pub extend PointCloudConfig with Eq::{not_equal, equal}

///|
/// 聚类结果。
/// Cluster result.
pub(all) struct ClusterResult {
  clusters : Array[Array[Int32]] // 每个聚类的点索引
  cluster_centers : Array[Point3DLight] // 聚类中心
} derive(Eq, @debug.Debug)

///|
pub extend ClusterResult with @debug.Debug::{to_repr}

///|
pub extend ClusterResult with Eq::{not_equal, equal}

///|
/// 默认点云配置。
/// Default point cloud configuration.
pub fn default_pointcloud_config() -> PointCloudConfig {
  {
    sample_method: VoxelGridSampling,
    normal_method: KNN,
    segment_method: EuclideanClustering,
    knn_k: 10,
    voxel_size: 0.1,
    cluster_tolerance: 0.2,
    min_cluster_size: 5,
  }
}

///|
/// 创建空点云。
/// Create empty point cloud.
pub fn create_empty_cloud() -> PointCloud3D {
  { points: [], normals: [], }
}

///|
/// 从点数组创建点云。
/// Create point cloud from point array.
pub fn create_cloud(points : Array[Point3DLight]) -> PointCloud3D {
  let normals : Array[Point3DLight] = []
  for _ in points {
    normals.push({ x: 0.0, y: 0.0, z: 1.0, })
  }
  { points, normals, }
}

///|
/// 计算两点距离。
/// Compute distance between two points.
fn point_distance(p1 : Point3DLight, p2 : Point3DLight) -> Double {
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  let dz = p1.z - p2.z
  (dx * dx + dy * dy + dz * dz).sqrt()
}

///|
/// 计算点云质心。
/// Compute point cloud centroid.
pub fn compute_centroid(cloud : PointCloud3D) -> Point3DLight {
  let n = cloud.points.length()
  if n == 0 {
    return { x: 0.0, y: 0.0, z: 0.0, }
  }
  let mut sum_x = 0.0
  let mut sum_y = 0.0
  let mut sum_z = 0.0
  for p in cloud.points {
    sum_x = sum_x + p.x
    sum_y = sum_y + p.y
    sum_z = sum_z + p.z
  }
  {
    x: sum_x / n.to_double(),
    y: sum_y / n.to_double(),
    z: sum_z / n.to_double(),
  }
}

///|
/// 随机采样：按比例随机选取点。
/// Random sampling: select points by ratio.
pub fn random_sampling(cloud : PointCloud3D, ratio : Double) -> PointCloud3D {
  let n = cloud.points.length()
  let target_count = (n.to_double() * ratio).to_int()
  if target_count >= n {
    return cloud
  }
  let step = n / target_count
  let sampled_points : Array[Point3DLight] = []
  let sampled_normals : Array[Point3DLight] = []
  let mut i = 0
  while i < n {
    sampled_points.push(cloud.points[i])
    if i < cloud.normals.length() {
      sampled_normals.push(cloud.normals[i])
    }
    i = i + step
  }
  { points: sampled_points, normals: sampled_normals, }
}

///|
/// 均匀采样：按固定间隔选取点。
/// Uniform sampling: select points at fixed interval.
pub fn uniform_sampling(cloud : PointCloud3D, step : Int32) -> PointCloud3D {
  if step <= 1 {
    return cloud
  }
  let sampled_points : Array[Point3DLight] = []
  let sampled_normals : Array[Point3DLight] = []
  let n = cloud.points.length()
  let mut i = 0
  while i < n {
    sampled_points.push(cloud.points[i])
    if i < cloud.normals.length() {
      sampled_normals.push(cloud.normals[i])
    }
    i = i + step
  }
  { points: sampled_points, normals: sampled_normals, }
}

///|
/// 体素网格下采样：将空间划分为体素，每个体素保留一个代表点。
/// Voxel grid downsampling: divide space into voxels, keep one representative per voxel.
pub fn voxel_grid_sampling(
  cloud : PointCloud3D,
  voxel_size : Double,
) -> PointCloud3D {
  if voxel_size <= 0.0 {
    return cloud
  }
  let n = cloud.points.length()
  if n == 0 {
    return cloud
  }
  let mut min_x = cloud.points[0].x
  let mut min_y = cloud.points[0].y
  let mut min_z = cloud.points[0].z
  for p in cloud.points {
    if p.x < min_x {
      min_x = p.x
    }
    if p.y < min_y {
      min_y = p.y
    }
    if p.z < min_z {
      min_z = p.z
    }
  }
  let voxel_map : Array[Point3DLight] = []
  let voxel_keys : Array[Int32] = []
  for i in 0..<n {
    let p = cloud.points[i]
    let vx = ((p.x - min_x) / voxel_size).to_int()
    let vy = ((p.y - min_y) / voxel_size).to_int()
    let vz = ((p.z - min_z) / voxel_size).to_int()
    let key = vx * 73856093 + vy * 19349663 + vz * 83492791
    let mut found = false
    for j in 0..<voxel_keys.length() {
      if voxel_keys[j] == key {
        found = true
        break
      }
    }
    if !found {
      voxel_keys.push(key)
      voxel_map.push(p)
    }
  }
  let normals : Array[Point3DLight] = []
  for _ in voxel_map {
    normals.push({ x: 0.0, y: 0.0, z: 1.0, })
  }
  { points: voxel_map, normals, }
}

///|
/// 点云采样主流程。
/// Point cloud sampling pipeline.
pub fn sample_pointcloud(
  cloud : PointCloud3D,
  config : PointCloudConfig,
) -> PointCloud3D {
  match config.sample_method {
    RandomSampling => random_sampling(cloud, 0.5)
    UniformSampling => uniform_sampling(cloud, 2)
    VoxelGridSampling => voxel_grid_sampling(cloud, config.voxel_size)
  }
}

///|
/// K近邻搜索：找到距目标点最近的K个点。
/// K-nearest neighbor search: find K closest points to target.
pub fn knn_search(
  cloud : PointCloud3D,
  target : Point3DLight,
  k : Int32,
) -> Array[Int32] {
  let n = cloud.points.length()
  if n == 0 || k <= 0 {
    return []
  }
  let distances : Array[(Int32, Double)] = []
  for i in 0..<n {
    distances.push((i, point_distance(cloud.points[i], target)))
  }
  let sorted = sort_by_distance(distances)
  let result : Array[Int32] = []
  let count = if k < sorted.length() { k } else { sorted.length() }
  for i in 0..<count {
    let (idx, _) = sorted[i]
    result.push(idx)
  }
  result
}

///|
/// 按距离排序。
/// Sort by distance.
fn sort_by_distance(arr : Array[(Int32, Double)]) -> Array[(Int32, Double)] {
  let result = arr.copy()
  let n = result.length()
  for i in 0..<n {
    let mut min_idx = i
    for j in (i + 1)..<n {
      let (_, d1) = result[min_idx]
      let (_, d2) = result[j]
      if d2 < d1 {
        min_idx = j
      }
    }
    if min_idx != i {
      let tmp = result[i]
      result[i] = result[min_idx]
      result[min_idx] = tmp
    }
  }
  result
}

///|
/// 估计法向量：使用K近邻的协方差矩阵特征向量。
/// Estimate normal vectors: use eigenvector of KNN covariance matrix.
pub fn estimate_normals(
  cloud : PointCloud3D,
  config : PointCloudConfig,
) -> PointCloud3D {
  let n = cloud.points.length()
  if n == 0 {
    return cloud
  }
  let normals : Array[Point3DLight] = []
  for i in 0..<n {
    let neighbors = knn_search(cloud, cloud.points[i], config.knn_k)
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut sum_z = 0.0
    let count = neighbors.length()
    if count == 0 {
      normals.push({ x: 0.0, y: 0.0, z: 1.0, })
      continue
    }
    for idx in neighbors {
      sum_x = sum_x + cloud.points[idx].x
      sum_y = sum_y + cloud.points[idx].y
      sum_z = sum_z + cloud.points[idx].z
    }
    let cx = sum_x / count.to_double()
    let cy = sum_y / count.to_double()
    let cz = sum_z / count.to_double()
    let mut cxx = 0.0
    let mut cyy = 0.0
    let mut czz = 0.0
    for idx in neighbors {
      let dx = cloud.points[idx].x - cx
      let dy = cloud.points[idx].y - cy
      let dz = cloud.points[idx].z - cz
      cxx = cxx + dx * dx
      cyy = cyy + dy * dy
      czz = czz + dz * dz
    }
    let nx = cxx
    let ny = cyy
    let nz = czz
    let mag = (nx * nx + ny * ny + nz * nz).sqrt()
    if mag > 0.0001 {
      normals.push({ x: nx / mag, y: ny / mag, z: nz / mag, })
    } else {
      normals.push({ x: 0.0, y: 0.0, z: 1.0, })
    }
  }
  { points: cloud.points, normals, }
}

///|
/// 欧式聚类分割：基于距离的聚类。
/// Euclidean clustering: distance-based clustering.
pub fn euclidean_clustering(
  cloud : PointCloud3D,
  tolerance : Double,
  min_cluster_size : Int32,
) -> ClusterResult {
  let n = cloud.points.length()
  if n == 0 {
    return { clusters: [], cluster_centers: [], }
  }
  let visited : Array[Bool] = []
  for _ in 0..<n {
    visited.push(false)
  }
  let clusters : Array[Array[Int32]] = []
  for i in 0..<n {
    if visited[i] {
      continue
    }
    let cluster : Array[Int32] = []
    let queue : Array[Int32] = [i]
    visited[i] = true
    while queue.length() > 0 {
      let curr = queue[queue.length() - 1]
      ignore(queue.remove(queue.length() - 1))
      cluster.push(curr)
      for j in 0..<n {
        if !visited[j] &&
          point_distance(cloud.points[curr], cloud.points[j]) < tolerance {
          visited[j] = true
          queue.push(j)
        }
      }
    }
    if cluster.length() >= min_cluster_size {
      clusters.push(cluster)
    }
  }
  let centers : Array[Point3DLight] = []
  for cluster in clusters {
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut sum_z = 0.0
    for idx in cluster {
      sum_x = sum_x + cloud.points[idx].x
      sum_y = sum_y + cloud.points[idx].y
      sum_z = sum_z + cloud.points[idx].z
    }
    let cnt = cluster.length().to_double()
    centers.push({ x: sum_x / cnt, y: sum_y / cnt, z: sum_z / cnt, })
  }
  { clusters, cluster_centers: centers, }
}

///|
/// 平面分割：RANSAC平面拟合。
/// Plane segmentation: RANSAC plane fitting.
pub fn plane_segmentation(
  cloud : PointCloud3D,
  threshold : Double,
  max_iterations : Int32,
) -> (Point3DLight, Double, Array[Int32]) {
  let n = cloud.points.length()
  if n < 3 {
    return ({ x: 0.0, y: 0.0, z: 1.0, }, 0.0, [])
  }
  let mut best_normal = { x: 0.0, y: 0.0, z: 1.0, }
  let mut best_d = 0.0
  let mut best_inliers : Array[Int32] = []
  for iter in 0..<max_iterations {
    let i1 = iter % n
    let i2 = (iter + n / 3) % n
    let i3 = (iter + 2 * n / 3) % n
    let p1 = cloud.points[i1]
    let p2 = cloud.points[i2]
    let p3 = cloud.points[i3]
    let v1x = p2.x - p1.x
    let v1y = p2.y - p1.y
    let v1z = p2.z - p1.z
    let v2x = p3.x - p1.x
    let v2y = p3.y - p1.y
    let v2z = p3.z - p1.z
    let nx = v1y * v2z - v1z * v2y
    let ny = v1z * v2x - v1x * v2z
    let nz = v1x * v2y - v1y * v2x
    let mag = (nx * nx + ny * ny + nz * nz).sqrt()
    if mag < 0.0001 {
      continue
    }
    let nx = nx / mag
    let ny = ny / mag
    let nz = nz / mag
    let d = -(nx * p1.x + ny * p1.y + nz * p1.z)
    let inliers : Array[Int32] = []
    for i in 0..<n {
      let dist = (nx * cloud.points[i].x +
      ny * cloud.points[i].y +
      nz * cloud.points[i].z +
      d).abs()
      if dist < threshold {
        inliers.push(i)
      }
    }
    if inliers.length() > best_inliers.length() {
      best_normal = { x: nx, y: ny, z: nz, }
      best_d = d
      best_inliers = inliers
    }
  }
  (best_normal, best_d, best_inliers)
}

///|
/// 点云分割主流程。
/// Point cloud segmentation pipeline.
pub fn segment_pointcloud(
  cloud : PointCloud3D,
  config : PointCloudConfig,
) -> ClusterResult {
  match config.segment_method {
    EuclideanClustering =>
      euclidean_clustering(
        cloud,
        config.cluster_tolerance,
        config.min_cluster_size,
      )
    RegionGrowing =>
      euclidean_clustering(
        cloud,
        config.cluster_tolerance,
        config.min_cluster_size,
      )
    PlaneSegmentation => {
      let (_, _, inliers) = plane_segmentation(
        cloud,
        config.cluster_tolerance,
        100,
      )
      let centers = if inliers.length() > 0 {
        [compute_centroid(cloud)]
      } else {
        []
      }
      { clusters: [inliers], cluster_centers: centers, }
    }
  }
}

///|
/// 点云处理流水线：采样 → 法向估计 → 分割。
/// Point cloud processing pipeline: sample → normal estimation → segmentation.
pub fn pointcloud_pipeline(
  cloud : PointCloud3D,
  config : PointCloudConfig,
) -> (PointCloud3D, ClusterResult) {
  let sampled = sample_pointcloud(cloud, config)
  let with_normals = estimate_normals(sampled, config)
  let clusters = segment_pointcloud(with_normals, config)
  (with_normals, clusters)
}
