// v187.0.0 classifier.mbt 测试：距离度量/KNN分类器/模板匹配/特征归一化

///|
test "euclidean_distance: 基本计算" {
  try {
    let result = @ocr.euclidean_distance([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
    let expected = (9.0 + 9.0 + 9.0).sqrt()
    assert_true((result - expected).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "euclidean_distance: 相同向量返回0" {
  try {
    let result = @ocr.euclidean_distance([1.0, 2.0], [1.0, 2.0])
    assert_true(result.abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "euclidean_distance: 空向量a抛异常" {
  try {
    let _ = @ocr.euclidean_distance([], [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "manhattan_distance: 基本计算" {
  try {
    let result = @ocr.manhattan_distance([1.0, 2.0], [4.0, 6.0])
    assert_true((result - 7.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "manhattan_distance: 空向量b抛异常" {
  try {
    let _ = @ocr.manhattan_distance([1.0], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cosine_distance: 相同向量返回0" {
  try {
    let result = @ocr.cosine_distance([1.0, 2.0, 3.0], [2.0, 4.0, 6.0])
    assert_true(result.abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "cosine_distance: 正交向量返回1" {
  try {
    let result = @ocr.cosine_distance([1.0, 0.0], [0.0, 1.0])
    assert_true((result - 1.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "chebyshev_distance: 基本计算" {
  try {
    let result = @ocr.chebyshev_distance([1.0, 2.0, 3.0], [4.0, 5.0, 6.0])
    assert_true((result - 3.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "chebyshev_distance: 空向量抛异常" {
  try {
    let _ = @ocr.chebyshev_distance([], [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "compute_distance: Euclidean度量" {
  try {
    let result = @ocr.compute_distance(
      [1.0, 2.0],
      [3.0, 4.0],
      @ocr.DistanceMetric::Euclidean,
    )
    let expected = (4.0 + 4.0).sqrt()
    assert_true((result - expected).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "compute_distance: Manhattan度量" {
  try {
    let result = @ocr.compute_distance(
      [1.0, 2.0],
      [3.0, 4.0],
      @ocr.DistanceMetric::Manhattan,
    )
    assert_true((result - 4.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "compute_distance: Chebyshev度量" {
  try {
    let result = @ocr.compute_distance(
      [1.0, 2.0],
      [3.0, 4.0],
      @ocr.DistanceMetric::Chebyshev,
    )
    assert_true((result - 2.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_create: 默认参数" {
  try {
    let classifier = @ocr.knn_create()
    assert_eq(classifier.k, 3)
    assert_eq(classifier.distance_metric, "euclidean")
    assert_eq(classifier.samples.length(), 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_create: 自定义参数" {
  try {
    let classifier = @ocr.knn_create(k=5, distance_metric="manhattan")
    assert_eq(classifier.k, 5)
    assert_eq(classifier.distance_metric, "manhattan")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_create: k为零抛异常" {
  try {
    let _ = @ocr.knn_create(k=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "knn_add_sample: 添加样本" {
  try {
    let classifier = @ocr.knn_create()
    let updated = @ocr.knn_add_sample(classifier, [1.0, 2.0], "A")
    assert_eq(updated.samples.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_add_sample: 空特征抛异常" {
  try {
    let classifier = @ocr.knn_create()
    let _ = @ocr.knn_add_sample(classifier, [], "A")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "knn_add_samples: 批量添加" {
  try {
    let classifier = @ocr.knn_create()
    let samples = [([1.0, 2.0], "A"), ([3.0, 4.0], "B")]
    let updated = @ocr.knn_add_samples(classifier, samples)
    assert_eq(updated.samples.length(), 2)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_predict: 基本预测" {
  try {
    let classifier = @ocr.knn_create(k=1)
    let c1 = @ocr.knn_add_sample(classifier, [1.0, 1.0], "A")
    let c2 = @ocr.knn_add_sample(c1, [5.0, 5.0], "B")
    let result = @ocr.knn_predict(c2, [1.1, 1.1])
    assert_eq(result.label, "A")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "knn_predict: 无训练样本抛异常" {
  try {
    let classifier = @ocr.knn_create()
    let _ = @ocr.knn_predict(classifier, [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "template_matcher_create: 默认参数" {
  let matcher = @ocr.template_matcher_create()
  assert_eq(matcher.distance_metric, "euclidean")
  assert_eq(matcher.templates.length(), 0)
}

///|
test "template_matcher_add: 添加模板" {
  try {
    let matcher = @ocr.template_matcher_create()
    let updated = @ocr.template_matcher_add(matcher, "A", [1.0, 2.0])
    assert_eq(updated.templates.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "template_matcher_add: 空模板抛异常" {
  try {
    let matcher = @ocr.template_matcher_create()
    let _ = @ocr.template_matcher_add(matcher, "A", [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "template_matcher_predict: 基本预测" {
  try {
    let matcher = @ocr.template_matcher_create()
    let m1 = @ocr.template_matcher_add(matcher, "A", [1.0, 1.0])
    let m2 = @ocr.template_matcher_add(m1, "B", [5.0, 5.0])
    let result = @ocr.template_matcher_predict(m2, [1.1, 1.1])
    assert_eq(result.label, "A")
  } catch {
    _ => assert_true(false)
  }
}

///|
test "template_matcher_predict: 无模板抛异常" {
  try {
    let matcher = @ocr.template_matcher_create()
    let _ = @ocr.template_matcher_predict(matcher, [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "normalize_features: 基本归一化" {
  try {
    let result = @ocr.normalize_features([1.0, 2.0, 3.0, 4.0, 5.0])
    assert_eq(result.length(), 5)
    assert_true(result[0].abs() < 0.01)
    assert_true((result[4] - 1.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "normalize_features: 常数向量返回全零" {
  try {
    let result = @ocr.normalize_features([3.0, 3.0, 3.0])
    for v in result {
      assert_true(v.abs() < 0.01)
    }
  } catch {
    _ => assert_true(false)
  }
}

///|
test "normalize_features: 空向量抛异常" {
  try {
    let _ = @ocr.normalize_features([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "standardize_features: 基本标准化" {
  try {
    let result = @ocr.standardize_features([1.0, 2.0, 3.0])
    assert_eq(result.length(), 3)
    let mut sum = 0.0
    for v in result {
      sum += v
    }
    assert_true(sum.abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "standardize_features: 空向量抛异常" {
  try {
    let _ = @ocr.standardize_features([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
