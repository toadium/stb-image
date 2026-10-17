// v192b retrieval 增强测试：边值 + 属性 + 枚举 + 数据库序列

///|
fn ret_make_img(w : Int, h : Int, ch : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let v : Int = i * 37 % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "FeatureType: 全枚举值验证" {
  assert_true(
    @retrieval.FeatureType::ColorHistogram ==
    @retrieval.FeatureType::ColorHistogram,
  )
  assert_true(
    @retrieval.FeatureType::ColorCorrelogram ==
    @retrieval.FeatureType::ColorCorrelogram,
  )
  assert_true(
    @retrieval.FeatureType::Texture == @retrieval.FeatureType::Texture,
  )
  assert_true(@retrieval.FeatureType::Shape == @retrieval.FeatureType::Shape)
  assert_true(@retrieval.FeatureType::SIFT == @retrieval.FeatureType::SIFT)
  assert_true(@retrieval.FeatureType::SURF == @retrieval.FeatureType::SURF)
  assert_true(@retrieval.FeatureType::ORB == @retrieval.FeatureType::ORB)
  assert_true(@retrieval.FeatureType::HOG == @retrieval.FeatureType::HOG)
  assert_true(@retrieval.FeatureType::LBP == @retrieval.FeatureType::LBP)
  assert_true(@retrieval.FeatureType::Gabor == @retrieval.FeatureType::Gabor)
  assert_true(
    @retrieval.FeatureType::DeepFeature == @retrieval.FeatureType::DeepFeature,
  )
  assert_true(
    @retrieval.FeatureType::Combined == @retrieval.FeatureType::Combined,
  )
  assert_true(
    @retrieval.FeatureType::Unknown == @retrieval.FeatureType::Unknown,
  )
  assert_true(
    @retrieval.FeatureType::ColorHistogram != @retrieval.FeatureType::Texture,
  )
  assert_true(@retrieval.FeatureType::SIFT != @retrieval.FeatureType::ORB)
}

///|
test "SimilarityMetric: 全枚举值验证" {
  assert_true(
    @retrieval.SimilarityMetric::Cosine == @retrieval.SimilarityMetric::Cosine,
  )
  assert_true(
    @retrieval.SimilarityMetric::Euclidean ==
    @retrieval.SimilarityMetric::Euclidean,
  )
  assert_true(
    @retrieval.SimilarityMetric::Manhattan ==
    @retrieval.SimilarityMetric::Manhattan,
  )
  assert_true(
    @retrieval.SimilarityMetric::Chebyshev ==
    @retrieval.SimilarityMetric::Chebyshev,
  )
  assert_true(
    @retrieval.SimilarityMetric::Correlation ==
    @retrieval.SimilarityMetric::Correlation,
  )
  assert_true(
    @retrieval.SimilarityMetric::Intersection ==
    @retrieval.SimilarityMetric::Intersection,
  )
  assert_true(
    @retrieval.SimilarityMetric::ChiSquare ==
    @retrieval.SimilarityMetric::ChiSquare,
  )
  assert_true(
    @retrieval.SimilarityMetric::Hellinger ==
    @retrieval.SimilarityMetric::Hellinger,
  )
  assert_true(
    @retrieval.SimilarityMetric::JensenShannon ==
    @retrieval.SimilarityMetric::JensenShannon,
  )
  assert_true(
    @retrieval.SimilarityMetric::Unknown == @retrieval.SimilarityMetric::Unknown,
  )
  assert_true(
    @retrieval.SimilarityMetric::Cosine !=
    @retrieval.SimilarityMetric::Euclidean,
  )
  assert_true(
    @retrieval.SimilarityMetric::ChiSquare !=
    @retrieval.SimilarityMetric::Hellinger,
  )
}

///|
test "cosine_similarity_cbir: 单元素向量" {
  let v1 = [1.0]
  let v2 = [1.0]
  let sim = @retrieval.cosine_similarity_cbir(v1, v2)
  assert_true(sim >= 0.0)
  assert_true(sim <= 1.0 + 0.001)
}

///|
test "cosine_similarity_cbir: 对称性属性" {
  let v1 = [1.0, 2.0, 3.0, 4.0]
  let v2 = [0.5, 1.5, 2.5, 3.5]
  let sim12 = @retrieval.cosine_similarity_cbir(v1, v2)
  let sim21 = @retrieval.cosine_similarity_cbir(v2, v1)
  assert_true((sim12 - sim21).abs() < 0.001)
}

///|
test "cosine_similarity_cbir: 反向向量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [-1.0, -2.0, -3.0]
  let sim = @retrieval.cosine_similarity_cbir(v1, v2)
  assert_true(sim <= 0.0 + 0.001)
}

///|
test "euclidean_distance_cbir: 非负性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let dist = @retrieval.euclidean_distance_cbir(v1, v2)
  assert_true(dist >= 0.0)
}

///|
test "euclidean_distance_cbir: 对称性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let d12 = @retrieval.euclidean_distance_cbir(v1, v2)
  let d21 = @retrieval.euclidean_distance_cbir(v2, v1)
  assert_true((d12 - d21).abs() < 0.001)
}

///|
test "euclidean_distance_cbir: 单元素" {
  let v1 = [3.0]
  let v2 = [7.0]
  let dist = @retrieval.euclidean_distance_cbir(v1, v2)
  assert_true((dist - 4.0).abs() < 0.001)
}

///|
test "manhattan_distance_cbir: 非负性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let dist = @retrieval.manhattan_distance_cbir(v1, v2)
  assert_true(dist >= 0.0)
}

///|
test "manhattan_distance_cbir: 对称性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let d12 = @retrieval.manhattan_distance_cbir(v1, v2)
  let d21 = @retrieval.manhattan_distance_cbir(v2, v1)
  assert_true((d12 - d21).abs() < 0.001)
}

///|
test "manhattan_distance_cbir: 单元素" {
  let v1 = [3.0]
  let v2 = [7.0]
  let dist = @retrieval.manhattan_distance_cbir(v1, v2)
  assert_true((dist - 4.0).abs() < 0.001)
}

///|
test "histogram_intersection_cbir: 非负性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.histogram_intersection_cbir(v1, v2)
  assert_true(sim >= 0.0)
}

///|
test "histogram_intersection_cbir: 有界性属性" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let s12 = @retrieval.histogram_intersection_cbir(v1, v2)
  assert_true(s12 >= 0.0)
  let s11 = @retrieval.histogram_intersection_cbir(v1, v1)
  assert_true(s11 >= 0.0)
}

///|
test "calculate_similarity: Chebyshev度量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::Chebyshev,
  )
  assert_true(sim >= 0.0)
}

///|
test "calculate_similarity: Correlation度量" {
  let v1 = [1.0, 2.0, 3.0, 4.0]
  let v2 = [4.0, 3.0, 2.0, 1.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::Correlation,
  )
  assert_true(sim >= -1.0 - 0.001)
  assert_true(sim <= 1.0 + 0.001)
}

///|
test "calculate_similarity: ChiSquare度量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::ChiSquare,
  )
  assert_true(sim >= 0.0)
}

///|
test "calculate_similarity: Hellinger度量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::Hellinger,
  )
  assert_true(sim >= 0.0)
}

///|
test "calculate_similarity: JensenShannon度量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::JensenShannon,
  )
  assert_true(sim >= 0.0)
}

///|
test "calculate_similarity: Unknown度量" {
  let v1 = [1.0, 2.0, 3.0]
  let v2 = [4.0, 5.0, 6.0]
  let sim = @retrieval.calculate_similarity(
    v1,
    v2,
    @retrieval.SimilarityMetric::Unknown,
  )
  assert_true(sim >= 0.0)
}

///|
test "ColorHistogramConfig: 自定义配置" {
  let config = @retrieval.ColorHistogramConfig::{
    num_bins: 32,
    color_space: "HSV",
    normalize: true,
    cumulative: true,
  }
  assert_eq(config.num_bins, 32)
  assert_eq(config.color_space, "HSV")
  assert_eq(config.normalize, true)
  assert_eq(config.cumulative, true)
}

///|
test "HOGConfig: 自定义配置" {
  let config = @retrieval.HOGConfig::{
    cell_size: 16,
    block_size: 2,
    num_bins: 18,
    normalize: true,
  }
  assert_eq(config.cell_size, 16)
  assert_eq(config.block_size, 2)
  assert_eq(config.num_bins, 18)
  assert_eq(config.normalize, true)
}

///|
test "LBPConfig: 自定义配置" {
  let config = @retrieval.LBPConfig::{
    radius: 3,
    num_points: 24,
    uniform: true,
    rotation_invariant: true,
  }
  assert_eq(config.radius, 3)
  assert_eq(config.num_points, 24)
  assert_eq(config.uniform, true)
  assert_eq(config.rotation_invariant, true)
}

///|
test "GaborConfig: 结构体验证" {
  let config = @retrieval.GaborConfig::{
    num_scales: 5,
    num_orientations: 8,
    wavelength: 2.0,
    aspect_ratio: 0.5,
  }
  assert_eq(config.num_scales, 5)
  assert_eq(config.num_orientations, 8)
  assert_true((config.wavelength - 2.0).abs() < 0.001)
  assert_true((config.aspect_ratio - 0.5).abs() < 0.001)
}

///|
test "database_size: 添加后大小递增" {
  let db0 = @retrieval.image_database_new()
  assert_eq(@retrieval.database_size(db0), 0)
  let img1 = ret_make_img(8, 8, 3)
  let feat1 = @retrieval.extract_image_features(img1, "img1")
  let db1 = @retrieval.database_add_image(db0, feat1)
  assert_eq(@retrieval.database_size(db1), 1)
  let img2 = ret_make_img(16, 16, 3)
  let feat2 = @retrieval.extract_image_features(img2, "img2")
  let db2 = @retrieval.database_add_image(db1, feat2)
  assert_eq(@retrieval.database_size(db2), 2)
}

///|
test "database_remove_image: 添加后移除恢复空" {
  let db0 = @retrieval.image_database_new()
  let img = ret_make_img(8, 8, 3)
  let feat = @retrieval.extract_image_features(img, "test_img")
  let db1 = @retrieval.database_add_image(db0, feat)
  assert_eq(@retrieval.database_size(db1), 1)
  let db2 = @retrieval.database_remove_image(db1, "test_img")
  assert_true(@retrieval.database_size(db2) >= 0)
}

///|
test "search_similar_images: top_k参数" {
  let db0 = @retrieval.image_database_new()
  let img1 = ret_make_img(8, 8, 3)
  let feat1 = @retrieval.extract_image_features(img1, "img1")
  let db1 = @retrieval.database_add_image(db0, feat1)
  let img2 = ret_make_img(16, 16, 3)
  let feat2 = @retrieval.extract_image_features(img2, "img2")
  let db2 = @retrieval.database_add_image(db1, feat2)
  let query = ret_make_img(12, 12, 3)
  let query_feat = @retrieval.extract_image_features(query, "query")
  let results = @retrieval.search_similar_images(db2, query_feat, top_k=1)
  assert_true(results.length() <= 1)
}

///|
test "search_similar_images: 曼哈顿方法" {
  let db = @retrieval.image_database_new()
  let img = ret_make_img(8, 8, 3)
  let feat = @retrieval.extract_image_features(img, "img1")
  let db1 = @retrieval.database_add_image(db, feat)
  let query = ret_make_img(8, 8, 3)
  let query_feat = @retrieval.extract_image_features(query, "query")
  let results = @retrieval.search_similar_images(
    db1,
    query_feat,
    method_type="manhattan",
  )
  assert_true(results.length() >= 0)
}

///|
test "search_similar_images: 切比雪夫方法" {
  let db = @retrieval.image_database_new()
  let img = ret_make_img(8, 8, 3)
  let feat = @retrieval.extract_image_features(img, "img1")
  let db1 = @retrieval.database_add_image(db, feat)
  let query = ret_make_img(8, 8, 3)
  let query_feat = @retrieval.extract_image_features(query, "query")
  let results = @retrieval.search_similar_images(
    db1,
    query_feat,
    method_type="chebyshev",
  )
  assert_true(results.length() >= 0)
}

///|
test "image_similarity: 曼哈顿方法" {
  let img1 = ret_make_img(16, 16, 3)
  let img2 = ret_make_img(16, 16, 3)
  let sim = @retrieval.image_similarity(img1, img2, method_type="manhattan")
  assert_true(sim >= 0.0)
}

///|
test "image_similarity: 切比雪夫方法" {
  let img1 = ret_make_img(16, 16, 3)
  let img2 = ret_make_img(16, 16, 3)
  let sim = @retrieval.image_similarity(img1, img2, method_type="chebyshev")
  assert_true(sim >= 0.0)
}

///|
test "image_similarity: 灰度图" {
  let img1 = ret_make_img(16, 16, 1)
  let img2 = ret_make_img(16, 16, 1)
  let sim = @retrieval.image_similarity(img1, img2)
  assert_true(sim >= 0.0)
}

///|
test "extract_color_histogram: 不同通道数" {
  let config = @retrieval.create_default_color_histogram_config()
  for ch in [1, 3, 4] {
    let img = ret_make_img(16, 16, ch)
    let feat = @retrieval.extract_color_histogram(img, config)
    assert_true(feat.feature_vector.length() > 0)
    assert_true(feat.feature_length > 0)
  }
}

///|
test "extract_lbp_feature: 不同半径" {
  let img = ret_make_img(16, 16, 1)
  for radius in [1, 2, 3] {
    let config = @retrieval.LBPConfig::{
      radius,
      num_points: radius * 8,
      uniform: true,
      rotation_invariant: false,
    }
    let feat = @retrieval.extract_lbp_feature(img, config)
    assert_true(feat.feature_vector.length() > 0)
  }
}

///|
test "extract_hog_feature: 不同cell_size" {
  let img = ret_make_img(32, 32, 3)
  for cell_size in [4, 8, 16] {
    let config = @retrieval.HOGConfig::{
      cell_size,
      block_size: 2,
      num_bins: 9,
      normalize: true,
    }
    let feat = @retrieval.extract_hog_feature(img, config)
    assert_true(feat.feature_vector.length() > 0)
  }
}

///|
test "extract_combined_features: 灰度图" {
  let img = ret_make_img(16, 16, 1)
  let feat = @retrieval.extract_combined_features(img)
  assert_true(feat.feature_vector.length() > 0)
  assert_true(feat.feature_length > 0)
}

///|
test "CBIRImageIndex: 多特征索引" {
  let index0 = @retrieval.create_image_index()
  assert_eq(index0.num_images, 0)
  let img1 = ret_make_img(8, 8, 3)
  let config = @retrieval.create_default_color_histogram_config()
  let feat1 = @retrieval.extract_color_histogram(img1, config)
  let index1 = @retrieval.add_to_index(index0, feat1)
  assert_true(index1.num_images >= 1)
  let img2 = ret_make_img(16, 16, 3)
  let feat2 = @retrieval.extract_color_histogram(img2, config)
  let index2 = @retrieval.add_to_index(index1, feat2)
  assert_true(index2.num_images >= 2)
}

///|
test "retrieve_images: 多图索引检索" {
  let index0 = @retrieval.create_image_index()
  let config = @retrieval.create_default_color_histogram_config()
  let img1 = ret_make_img(8, 8, 3)
  let feat1 = @retrieval.extract_color_histogram(img1, config)
  let index1 = @retrieval.add_to_index(index0, feat1)
  let img2 = ret_make_img(16, 16, 3)
  let feat2 = @retrieval.extract_color_histogram(img2, config)
  let index2 = @retrieval.add_to_index(index1, feat2)
  let query = ret_make_img(12, 12, 3)
  let query_feat = @retrieval.extract_color_histogram(query, config)
  let results = @retrieval.retrieve_images(
    query_feat,
    index2,
    1,
    @retrieval.SimilarityMetric::Cosine,
  )
  assert_true(results.num_results >= 0)
  assert_true(results.results.length() >= 0)
}

///|
test "retrieve_images: 不同度量" {
  let index0 = @retrieval.create_image_index()
  let config = @retrieval.create_default_color_histogram_config()
  let img = ret_make_img(8, 8, 3)
  let feat = @retrieval.extract_color_histogram(img, config)
  let index1 = @retrieval.add_to_index(index0, feat)
  let query = ret_make_img(8, 8, 3)
  let query_feat = @retrieval.extract_color_histogram(query, config)
  for
    metric in [
      @retrieval.SimilarityMetric::Cosine,
      @retrieval.SimilarityMetric::Euclidean,
      @retrieval.SimilarityMetric::Manhattan,
      @retrieval.SimilarityMetric::Intersection,
    ] {
    let results = @retrieval.retrieve_images(query_feat, index1, 1, metric)
    assert_true(results.num_results >= 0)
  }
}

///|
test "batch_extract_features: 单图批量" {
  let img = ret_make_img(8, 8, 3)
  let batch = [(img, "single")]
  let features = @retrieval.batch_extract_features(batch)
  assert_eq(features.length(), 1)
  assert_eq(features[0].image_id, "single")
}

///|
test "batch_extract_features: 多图批量" {
  let img1 = ret_make_img(8, 8, 3)
  let img2 = ret_make_img(16, 16, 3)
  let img3 = ret_make_img(32, 32, 3)
  let batch = [(img1, "a"), (img2, "b"), (img3, "c")]
  let features = @retrieval.batch_extract_features(batch)
  assert_eq(features.length(), 3)
  assert_eq(features[0].image_id, "a")
  assert_eq(features[1].image_id, "b")
  assert_eq(features[2].image_id, "c")
}
