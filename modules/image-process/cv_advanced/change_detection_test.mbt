///|
test "change_difference: basic subtraction" {
  let img1 = [[1.0, 2.0], [3.0, 4.0]]
  let img2 = [[2.0, 3.0], [4.0, 5.0]]
  let result = @cv_advanced.change_difference(img1, img2)
  assert_true(result[0][0] > 0.99 && result[0][0] < 1.01)
  assert_true(result[0][1] > 0.99 && result[0][1] < 1.01)
}

///|
test "change_difference: empty input" {
  let result = @cv_advanced.change_difference([], [])
  assert_eq(result.length(), 0)
}

///|
test "change_ratio: basic division" {
  let img1 = [[1.0, 2.0], [4.0, 8.0]]
  let img2 = [[2.0, 4.0], [8.0, 16.0]]
  let result = @cv_advanced.change_ratio(img1, img2)
  assert_true(result[0][0] > 1.99 && result[0][0] < 2.01)
  assert_true(result[1][1] > 1.99 && result[1][1] < 2.01)
}

///|
test "change_ratio: zero denominator" {
  let img1 = [[0.0, 2.0]]
  let img2 = [[1.0, 4.0]]
  let result = @cv_advanced.change_ratio(img1, img2)
  assert_true(result[0][0] == 0.0)
}

///|
test "change_log_ratio: basic log ratio" {
  let img1 = [[1.0, 2.0]]
  let img2 = [[2.0, 4.0]]
  let result = @cv_advanced.change_log_ratio(img1, img2)
  assert_true(result[0][0] > 0.69 && result[0][0] < 0.70)
}

///|
test "change_log_ratio: zero values" {
  let img1 = [[0.0, 2.0]]
  let img2 = [[1.0, 0.0]]
  let result = @cv_advanced.change_log_ratio(img1, img2)
  assert_true(result[0][0] == 0.0)
  assert_true(result[0][1] == 0.0)
}

///|
test "change_vector_analysis: multi-band" {
  let img1 = [[[1.0, 2.0], [3.0, 4.0]], [[5.0, 6.0], [7.0, 8.0]]]
  let img2 = [[[2.0, 3.0], [4.0, 5.0]], [[6.0, 7.0], [8.0, 9.0]]]
  let result = @cv_advanced.change_vector_analysis(img1, img2)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 2)
  let expected = (1.0 * 1.0 + 1.0 * 1.0).sqrt()
  assert_true(result[0][0] > expected - 0.01 && result[0][0] < expected + 0.01)
}

///|
test "change_vector_analysis: empty input" {
  let result = @cv_advanced.change_vector_analysis([], [])
  assert_eq(result.length(), 0)
}

///|
test "change_otsu_threshold: finds optimal" {
  let change_map = [[0.1, 0.2, 0.1, 0.2], [0.9, 0.8, 0.9, 0.8]]
  let threshold = @cv_advanced.change_otsu_threshold(change_map, 10)
  assert_true(threshold > 0.2 && threshold < 0.9)
}

///|
test "change_otsu_threshold: uniform values" {
  let change_map = [[1.0, 1.0], [1.0, 1.0]]
  let threshold = @cv_advanced.change_otsu_threshold(change_map, 10)
  assert_true(threshold > 0.99 && threshold < 1.01)
}

///|
test "change_threshold: binary map" {
  let change_map = [[0.1, 0.5], [1.5, 2.0]]
  let binary = @cv_advanced.change_threshold(change_map, 1.0)
  assert_eq(binary[0][0], 0)
  assert_eq(binary[0][1], 0)
  assert_eq(binary[1][0], 1)
  assert_eq(binary[1][1], 1)
}

///|
test "change_threshold: negative values" {
  let change_map = [[-2.0, 0.5]]
  let binary = @cv_advanced.change_threshold(change_map, 1.0)
  assert_eq(binary[0][0], 1)
  assert_eq(binary[0][1], 0)
}

///|
test "change_multitemporal_trend: linear trend" {
  let ts = [
    [[1.0, 2.0], [3.0, 4.0]],
    [[2.0, 3.0], [4.0, 5.0]],
    [[3.0, 4.0], [5.0, 6.0]],
  ]
  let trend = @cv_advanced.change_multitemporal_trend(ts)
  assert_eq(trend.length(), 2)
  assert_true(trend[0][0] > 0.99 && trend[0][0] < 1.01)
}

///|
test "change_multitemporal_trend: insufficient data" {
  let ts = [[[1.0, 2.0]]]
  let trend = @cv_advanced.change_multitemporal_trend(ts)
  assert_eq(trend.length(), 0)
}

///|
test "change_detect: difference method" {
  let img1 = [[1.0, 2.0], [3.0, 4.0]]
  let img2 = [[5.0, 2.0], [3.0, 8.0]]
  let result = @cv_advanced.change_detect(
    img1,
    img2,
    @cv_advanced.ChangeMethod::Difference,
    2.0,
  )
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.binary_map[0][0], 1)
  assert_eq(result.binary_map[0][1], 0)
}

///|
test "change_detect: ratio method" {
  let img1 = [[1.0, 1.0]]
  let img2 = [[3.0, 1.0]]
  let result = @cv_advanced.change_detect(
    img1,
    img2,
    @cv_advanced.ChangeMethod::Ratio,
    2.0,
  )
  assert_eq(result.binary_map[0][0], 1)
  assert_eq(result.binary_map[0][1], 0)
}

///|
test "change_count_changed: counts ones" {
  let binary = [[1, 0, 1], [0, 1, 0]]
  let count = @cv_advanced.change_count_changed(binary)
  assert_eq(count, 3)
}

///|
test "change_rate: computes ratio" {
  let binary = [[1, 0, 1], [0, 1, 0]]
  let rate = @cv_advanced.change_rate(binary)
  assert_true(rate > 0.49 && rate < 0.51)
}

///|
test "change_rate: empty map" {
  let rate = @cv_advanced.change_rate([])
  assert_true(rate == 0.0)
}
