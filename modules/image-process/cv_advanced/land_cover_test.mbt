///|
test "classify_compute_class_means: computes means" {
  let samples = [
    @cv_advanced.classify_build_sample(0, [1.0, 2.0]),
    @cv_advanced.classify_build_sample(0, [3.0, 4.0]),
    @cv_advanced.classify_build_sample(1, [5.0, 6.0]),
    @cv_advanced.classify_build_sample(1, [7.0, 8.0]),
  ]
  let means = @cv_advanced.classify_compute_class_means(samples, 2)
  assert_true(means[0][0] > 1.99 && means[0][0] < 2.01)
  assert_true(means[0][1] > 2.99 && means[0][1] < 3.01)
  assert_true(means[1][0] > 5.99 && means[1][0] < 6.01)
}

///|
test "classify_compute_class_means: empty samples" {
  let means = @cv_advanced.classify_compute_class_means([], 2)
  assert_eq(means.length(), 2)
  assert_eq(means[0].length(), 0)
}

///|
test "classify_min_distance: basic classification" {
  let features = [[[1.0, 1.0], [5.0, 5.0]], [[2.0, 2.0], [6.0, 6.0]]]
  let means = [[1.5, 1.5], [5.5, 5.5]]
  let result = @cv_advanced.classify_min_distance(features, means)
  assert_eq(result[0][0], 0)
  assert_eq(result[0][1], 1)
  assert_eq(result[1][1], 1)
}

///|
test "classify_min_distance: empty input" {
  let result = @cv_advanced.classify_min_distance([], [[1.0]])
  assert_eq(result.length(), 0)
}

///|
test "classify_max_likelihood: basic classification" {
  let features = [[[1.0, 1.0], [5.0, 5.0]], [[2.0, 2.0], [6.0, 6.0]]]
  let means = [[1.5, 1.5], [5.5, 5.5]]
  let variances = [[1.0, 1.0], [1.0, 1.0]]
  let result = @cv_advanced.classify_max_likelihood(features, means, variances)
  assert_eq(result[0][0], 0)
  assert_eq(result[0][1], 1)
}

///|
test "classify_max_likelihood: empty input" {
  let result = @cv_advanced.classify_max_likelihood([], [[1.0]], [[1.0]])
  assert_eq(result.length(), 0)
}

///|
test "classify_kmeans: clusters data" {
  let features = [
    [[1.0, 1.0], [1.2, 0.8], [5.0, 5.0]],
    [[0.9, 1.1], [5.2, 4.8], [4.9, 5.1]],
  ]
  let (class_map, centers) = @cv_advanced.classify_kmeans(features, 2, 10)
  assert_eq(class_map.length(), 2)
  assert_eq(class_map[0].length(), 3)
  assert_eq(centers.length(), 2)
}

///|
test "classify_kmeans: empty input" {
  let (class_map, centers) = @cv_advanced.classify_kmeans([], 2, 10)
  assert_eq(class_map.length(), 0)
  assert_eq(centers.length(), 0)
}

///|
test "classify_isodata: filters small clusters" {
  let features = [
    [[1.0, 1.0], [1.1, 0.9], [5.0, 5.0]],
    [[0.9, 1.1], [5.1, 4.9], [4.9, 5.1]],
  ]
  let result = @cv_advanced.classify_isodata(features, 2, 10, 1)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 3)
}

///|
test "classify_isodata: empty input" {
  let result = @cv_advanced.classify_isodata([], 2, 10, 1)
  assert_eq(result.length(), 0)
}

///|
test "classify_confusion_matrix: builds matrix" {
  let predicted = [[0, 1], [1, 0]]
  let truth = [[0, 1], [1, 1]]
  let matrix = @cv_advanced.classify_confusion_matrix(predicted, truth, 2)
  assert_eq(matrix[0][0], 1)
  assert_eq(matrix[0][1], 0)
  assert_eq(matrix[1][0], 1)
  assert_eq(matrix[1][1], 2)
}

///|
test "classify_kappa: perfect agreement" {
  let matrix = [[10, 0], [0, 10]]
  let kappa = @cv_advanced.classify_kappa(matrix)
  assert_true(kappa > 0.99)
}

///|
test "classify_kappa: random agreement" {
  let matrix = [[5, 5], [5, 5]]
  let kappa = @cv_advanced.classify_kappa(matrix)
  assert_true(kappa > -0.01 && kappa < 0.01)
}

///|
test "classify_kappa: empty matrix" {
  let kappa = @cv_advanced.classify_kappa([])
  assert_true(kappa == 0.0)
}

///|
test "classify_overall_accuracy: perfect" {
  let matrix = [[10, 0], [0, 10]]
  let acc = @cv_advanced.classify_overall_accuracy(matrix)
  assert_true(acc > 0.99)
}

///|
test "classify_overall_accuracy: half correct" {
  let matrix = [[5, 5], [0, 0]]
  let acc = @cv_advanced.classify_overall_accuracy(matrix)
  assert_true(acc > 0.49 && acc < 0.51)
}

///|
test "classify_build_result: constructs correctly" {
  let class_map = [[0, 1], [1, 0]]
  let result = @cv_advanced.classify_build_result(class_map, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.num_classes, 2)
}

///|
test "classify_build_sample: constructs correctly" {
  let sample = @cv_advanced.classify_build_sample(1, [1.0, 2.0, 3.0])
  assert_eq(sample.class_id, 1)
  assert_eq(sample.features.length(), 3)
}
