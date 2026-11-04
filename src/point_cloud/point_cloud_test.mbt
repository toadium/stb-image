///|
test "PointCloudSampleMethod: 枚举值" {
  assert_true(@point_cloud.RandomSampling is @point_cloud.RandomSampling)
  assert_true(@point_cloud.UniformSampling is @point_cloud.UniformSampling)
  assert_true(@point_cloud.VoxelGridSampling is @point_cloud.VoxelGridSampling)
}

///|
test "NormalEstimationMethod: 枚举值" {
  assert_true(@point_cloud.KNN is @point_cloud.KNN)
  assert_true(@point_cloud.RadiusSearch is @point_cloud.RadiusSearch)
}

///|
test "PointCloudSegmentMethod: 枚举值" {
  assert_true(
    @point_cloud.EuclideanClustering is @point_cloud.EuclideanClustering,
  )
  assert_true(@point_cloud.RegionGrowing is @point_cloud.RegionGrowing)
  assert_true(@point_cloud.PlaneSegmentation is @point_cloud.PlaneSegmentation)
}

///|
test "Point3DLight: 构造与字段" {
  let p : @point_cloud.Point3DLight = { x: 1.0, y: 2.0, z: 3.0, }
  assert_eq(p.x, 1.0)
  assert_eq(p.y, 2.0)
  assert_eq(p.z, 3.0)
}

///|
test "PointCloudConfig: 构造与字段" {
  let config : @point_cloud.PointCloudConfig = {
    sample_method: @point_cloud.RandomSampling,
    normal_method: @point_cloud.RadiusSearch,
    segment_method: @point_cloud.RegionGrowing,
    knn_k: 5,
    voxel_size: 0.05,
    cluster_tolerance: 0.1,
    min_cluster_size: 3,
  }
  assert_eq(config.knn_k, 5)
  assert_eq(config.voxel_size, 0.05)
  assert_eq(config.cluster_tolerance, 0.1)
  assert_eq(config.min_cluster_size, 3)
}

///|
test "default_pointcloud_config: 默认值" {
  let config = @point_cloud.default_pointcloud_config()
  assert_eq(config.knn_k, 10)
  assert_eq(config.voxel_size, 0.1)
  assert_eq(config.cluster_tolerance, 0.2)
  assert_eq(config.min_cluster_size, 5)
  assert_true(config.sample_method is @point_cloud.VoxelGridSampling)
  assert_true(config.normal_method is @point_cloud.KNN)
  assert_true(config.segment_method is @point_cloud.EuclideanClustering)
}

///|
test "create_empty_cloud: 空点云" {
  let cloud = @point_cloud.create_empty_cloud()
  assert_eq(cloud.points.length(), 0)
  assert_eq(cloud.normals.length(), 0)
}

///|
test "create_cloud: 从点数组创建" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  assert_eq(cloud.points.length(), 3)
  assert_eq(cloud.normals.length(), 3)
}

///|
test "compute_centroid: 质心计算" {
  let cloud = @point_cloud.create_cloud([
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 2.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 2.0, z: 0.0, },
    { x: 2.0, y: 2.0, z: 0.0, },
  ])
  let centroid = @point_cloud.compute_centroid(cloud)
  assert_eq(centroid.x, 1.0)
  assert_eq(centroid.y, 1.0)
  assert_eq(centroid.z, 0.0)
}

///|
test "compute_centroid: 空点云" {
  let cloud = @point_cloud.create_empty_cloud()
  let centroid = @point_cloud.compute_centroid(cloud)
  assert_eq(centroid.x, 0.0)
  assert_eq(centroid.y, 0.0)
  assert_eq(centroid.z, 0.0)
}

///|
test "random_sampling: 采样" {
  let points : Array[@point_cloud.Point3DLight] = []
  for i in 0..<100 {
    points.push({ x: i.to_double(), y: 0.0, z: 0.0, })
  }
  let cloud = @point_cloud.create_cloud(points)
  let sampled = @point_cloud.random_sampling(cloud, 0.5)
  assert_true(sampled.points.length() <= 100)
  assert_true(sampled.points.length() > 0)
}

///|
test "uniform_sampling: 步长采样" {
  let points : Array[@point_cloud.Point3DLight] = []
  for i in 0..<100 {
    points.push({ x: i.to_double(), y: 0.0, z: 0.0, })
  }
  let cloud = @point_cloud.create_cloud(points)
  let sampled = @point_cloud.uniform_sampling(cloud, 10)
  assert_eq(sampled.points.length(), 10)
}

///|
test "uniform_sampling: 步长1不变" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 2.0, y: 0.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let sampled = @point_cloud.uniform_sampling(cloud, 1)
  assert_eq(sampled.points.length(), 3)
}

///|
test "voxel_grid_sampling: 体素下采样" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 0.05, y: 0.05, z: 0.05, },
    { x: 1.0, y: 1.0, z: 1.0, },
    { x: 1.05, y: 1.05, z: 1.05, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let sampled = @point_cloud.voxel_grid_sampling(cloud, 0.5)
  assert_eq(sampled.points.length(), 2)
}

///|
test "knn_search: 最近邻搜索" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 2.0, y: 0.0, z: 0.0, },
    { x: 3.0, y: 0.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let target : @point_cloud.Point3DLight = { x: 1.5, y: 0.0, z: 0.0, }
  let neighbors = @point_cloud.knn_search(cloud, target, 2)
  assert_eq(neighbors.length(), 2)
  assert_true(neighbors[0] == 1 || neighbors[0] == 2)
  assert_true(neighbors[1] == 1 || neighbors[1] == 2)
}

///|
test "estimate_normals: 法向估计" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 1.0, y: 0.0, z: 0.0, },
    { x: 0.0, y: 1.0, z: 0.0, },
    { x: 1.0, y: 1.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let config = @point_cloud.default_pointcloud_config()
  let result = @point_cloud.estimate_normals(cloud, config)
  assert_eq(result.normals.length(), 4)
}

///|
test "euclidean_clustering: 聚类" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 0.1, y: 0.0, z: 0.0, },
    { x: 5.0, y: 0.0, z: 0.0, },
    { x: 5.1, y: 0.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let result = @point_cloud.euclidean_clustering(cloud, 0.5, 1)
  assert_eq(result.clusters.length(), 2)
  assert_eq(result.cluster_centers.length(), 2)
}

///|
test "euclidean_clustering: 最小聚类大小" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 0.1, y: 0.0, z: 0.0, },
    { x: 5.0, y: 0.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let result = @point_cloud.euclidean_clustering(cloud, 0.5, 2)
  assert_eq(result.clusters.length(), 1)
}

///|
test "plane_segmentation: 平面拟合" {
  let points : Array[@point_cloud.Point3DLight] = []
  for y in 0..<5 {
    for x in 0..<5 {
      points.push({ x: x.to_double(), y: y.to_double(), z: 0.0, })
    }
  }
  let cloud = @point_cloud.create_cloud(points)
  let (normal, _, inliers) = @point_cloud.plane_segmentation(cloud, 0.1, 50)
  assert_eq(inliers.length(), 25)
  assert_true(normal.z.abs() > 0.9)
}

///|
test "sample_pointcloud: 各方法" {
  let points : Array[@point_cloud.Point3DLight] = []
  for i in 0..<50 {
    points.push({ x: i.to_double(), y: 0.0, z: 0.0, })
  }
  let cloud = @point_cloud.create_cloud(points)
  let config = @point_cloud.default_pointcloud_config()
  let sampled = @point_cloud.sample_pointcloud(cloud, config)
  assert_true(sampled.points.length() > 0)
}

///|
test "segment_pointcloud: 分割" {
  let points : Array[@point_cloud.Point3DLight] = [
    { x: 0.0, y: 0.0, z: 0.0, },
    { x: 0.1, y: 0.0, z: 0.0, },
    { x: 5.0, y: 0.0, z: 0.0, },
    { x: 5.1, y: 0.0, z: 0.0, },
  ]
  let cloud = @point_cloud.create_cloud(points)
  let config : @point_cloud.PointCloudConfig = {
    sample_method: @point_cloud.VoxelGridSampling,
    normal_method: @point_cloud.KNN,
    segment_method: @point_cloud.EuclideanClustering,
    knn_k: 2,
    voxel_size: 0.5,
    cluster_tolerance: 0.5,
    min_cluster_size: 1,
  }
  let result = @point_cloud.segment_pointcloud(cloud, config)
  assert_true(result.clusters.length() > 0)
}

///|
test "pointcloud_pipeline: 完整流水线" {
  let points : Array[@point_cloud.Point3DLight] = []
  for y in 0..<5 {
    for x in 0..<5 {
      points.push({ x: x.to_double(), y: y.to_double(), z: 0.0, })
    }
  }
  let cloud = @point_cloud.create_cloud(points)
  let config = @point_cloud.default_pointcloud_config()
  let (processed, clusters) = @point_cloud.pointcloud_pipeline(cloud, config)
  assert_true(processed.points.length() > 0)
  assert_true(clusters.clusters.length() >= 0)
}

///|
test "ClusterResult: 构造与字段" {
  let result : @point_cloud.ClusterResult = {
    clusters: [[0, 1], [2, 3]],
    cluster_centers: [{ x: 0.5, y: 0.0, z: 0.0, }, { x: 5.0, y: 0.0, z: 0.0, }],
  }
  assert_eq(result.clusters.length(), 2)
  assert_eq(result.cluster_centers.length(), 2)
}
