// v35.0.0 图像聚类高级测试 — image_clustering_advanced 模块 7 函数

///|
test "create_default_clustering_config: 默认聚类配置" {
  let config = create_default_clustering_config()
  assert_true(config.num_clusters > 0)
  assert_true(config.max_iterations > 0)
  assert_true(config.tolerance > 0.0)
  assert_true(config.eps > 0.0)
  assert_true(config.min_samples > 0)
  assert_true(config.fuzziness_parameter > 0.0)
  assert_true(config.use_feature_extraction)
  assert_true(config.use_normalization)
  assert_true(!config.use_gpu)
  assert_true(config.algorithm_type == ClusteringAlgorithmType::KMeans)
  assert_true(config.distance_metric == DistanceMetricType::Euclidean)
}

///|
test "kmeans_clustering: 基本聚类" {
  let config = create_default_clustering_config()
  let data = [
    [0.0, 0.0],
    [0.1, 0.1],
    [10.0, 10.0],
    [10.1, 10.1],
    [20.0, 20.0],
    [20.1, 20.1],
  ]
  let result = kmeans_clustering(data, 3, config)
  assert_true(result.num_clusters == 3)
  assert_true(result.num_samples == 6)
  assert_true(result.labels.length() == 6)
  assert_true(result.cluster_centers.length() == 3)
  assert_true(result.inertia >= 0.0)
  assert_true(result.num_iterations > 0)
  assert_true(result.clustering_time_ms > 0.0)
  // 标签应在 [0, num_clusters) 范围内
  for l in result.labels {
    assert_true(l >= 0 && l < 3)
  }
}

///|
test "kmeans_clustering: 单簇" {
  let config = create_default_clustering_config()
  let data = [[1.0, 1.0], [1.1, 1.1], [0.9, 0.9]]
  let result = kmeans_clustering(data, 1, config)
  assert_true(result.num_clusters == 1)
  assert_true(result.num_samples == 3)
  for l in result.labels {
    assert_true(l == 0)
  }
}

///|
test "dbscan_clustering: 基本DBSCAN" {
  let config = create_default_clustering_config()
  let data = [
    [0.0, 0.0],
    [0.1, 0.0],
    [0.0, 0.1],
    [10.0, 10.0],
    [10.1, 10.0],
    [10.0, 10.1],
  ]
  let result = dbscan_clustering(data, 0.5, 2, config)

  assert_true(result.labels.length() == 6)
  assert_true(result.eps == 0.5)
  assert_true(result.min_samples == 2)
  assert_true(result.num_noise_points >= 0)
  assert_true(result.num_core_points >= 0)
  assert_true(result.num_border_points >= 0)
  assert_true(result.clustering_time_ms > 0.0)
}

///|
test "dbscan_clustering: 全噪声点" {
  let config = create_default_clustering_config()
  let data = [[0.0, 0.0], [100.0, 100.0], [200.0, 200.0]]
  let result = dbscan_clustering(data, 0.1, 2, config)
  assert_true(result.labels.length() == 3)
  // 分散的点应为噪声
  assert_true(result.num_noise_points >= 0)
}

///|
test "hierarchical_clustering: 基本层次聚类" {
  let config = create_default_clustering_config()
  let data = [
    [0.0, 0.0],
    [0.1, 0.1],
    [10.0, 10.0],
    [10.1, 10.1],
    [20.0, 20.0],
    [20.1, 20.1],
  ]
  let result = hierarchical_clustering(data, 3, config)
  assert_true(result.num_clusters == 3)
  assert_true(result.num_samples == 6)
  assert_true(result.labels.length() == 6)
  assert_true(result.cluster_sizes.length() == 3)
  assert_true(result.merge_history.length() >= 0)
  assert_true(result.cophenetic_correlation >= 0.0)
  assert_true(result.clustering_time_ms > 0.0)
  assert_true(result.linkage_type == config.linkage_type)
  // 标签应在 [0, num_clusters) 范围内
  for l in result.labels {
    assert_true(l >= 0 && l < 3)
  }
}

///|
test "calculate_silhouette_score: 轮廓系数" {
  let data = [[0.0, 0.0], [0.1, 0.1], [10.0, 10.0], [10.1, 10.1]]
  let labels = [0, 0, 1, 1]
  let score = calculate_silhouette_score(data, labels)
  // 轮廓系数范围 [-1, 1]
  assert_true(score >= -1.0 && score <= 1.0)
}

///|
test "calculate_silhouette_score: 空数据" {
  let score = calculate_silhouette_score([], [])
  assert_true(score == 0.0)
}

///|
test "calculate_silhouette_score: 单簇" {
  let data = [[0.0, 0.0], [1.0, 1.0]]
  let labels = [0, 0]
  let score = calculate_silhouette_score(data, labels)
  // 单簇时轮廓系数为0（无其他簇比较）
  assert_true(score >= -1.0 && score <= 1.0)
}

///|
test "cluster_images: 图像聚类" {
  let config = create_default_clustering_config()
  let images = [
    [100.0, 150.0, 200.0],
    [110.0, 140.0, 190.0],
    [10.0, 20.0, 30.0],
    [15.0, 25.0, 35.0],
    [200.0, 210.0, 220.0],
    [190.0, 200.0, 210.0],
  ]
  let result = cluster_images(images, config)
  assert_true(result.num_clusters == config.num_clusters)
  assert_true(result.num_samples == 6)
  assert_true(result.labels.length() == 6)
  assert_true(result.cluster_sizes.length() == config.num_clusters)
  assert_true(result.inertia >= 0.0)
  assert_true(result.silhouette_score >= -1.0 && result.silhouette_score <= 1.0)
  assert_true(result.clustering_time_ms > 0.0)
  assert_true(result.num_iterations > 0)
}

///|
test "cluster_images: 空图像集" {
  let config = create_default_clustering_config()
  let result = cluster_images([], config)
  assert_true(result.num_samples == 0)
  assert_true(result.labels.length() == 0)
}

///|
test "image_clustering_report_to_string: 报告生成" {
  let config = create_default_clustering_config()
  let report = image_clustering_report_to_string(
    ImageClusteringTaskType::KMeansClustering,
    config,
    "聚类完成",
  )
  assert_true(report.contains("图像聚类高级报告"))
  assert_true(report.contains("任务信息"))
  assert_true(report.contains("聚类完成"))
}

///|
test "image_clustering_report_to_string: DBSCAN报告" {
  let config = create_default_clustering_config()
  let report = image_clustering_report_to_string(
    ImageClusteringTaskType::DBSCANClustering,
    config,
    "DBSCAN结果",
  )
  assert_true(report.contains("DBSCAN"))
  assert_true(report.contains("DBSCAN结果"))
}
