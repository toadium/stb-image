///|
test "cloud_threshold_detect: basic detection" {
  let image = [[0.2, 0.8, 0.3], [0.9, 0.1, 0.7], [0.4, 0.6, 0.85]]
  let mask = @cv_advanced.cloud_threshold_detect(image, 0.5)
  assert_eq(mask[0][0], 0)
  assert_eq(mask[0][1], 1)
  assert_eq(mask[1][1], 0)
  assert_eq(mask[2][2], 1)
}

///|
test "cloud_threshold_detect: empty image" {
  let mask = @cv_advanced.cloud_threshold_detect([], 0.5)
  assert_eq(mask.length(), 0)
}

///|
test "cloud_multispectral_detect: bright and cold" {
  let visible = [[0.8, 0.2], [0.3, 0.9]]
  let thermal = [[0.2, 0.8], [0.7, 0.1]]
  let mask = @cv_advanced.cloud_multispectral_detect(visible, thermal, 0.5, 0.5)
  assert_eq(mask[0][0], 1)
  assert_eq(mask[0][1], 0)
  assert_eq(mask[1][0], 0)
  assert_eq(mask[1][1], 1)
}

///|
test "cloud_multispectral_detect: empty input" {
  let mask = @cv_advanced.cloud_multispectral_detect([], [], 0.5, 0.5)
  assert_eq(mask.length(), 0)
}

///|
test "cloud_shadow_detect: detects shadows" {
  let image = [[0.1, 0.2, 0.8], [0.1, 0.2, 0.9], [0.1, 0.2, 0.7]]
  let cloud_mask = [[0, 0, 1], [0, 0, 1], [0, 0, 1]]
  let shadow_mask = @cv_advanced.cloud_shadow_detect(
    image, cloud_mask, 0.3, 0.0, 1.0, 1,
  )
  assert_eq(shadow_mask.length(), 3)
}

///|
test "cloud_shadow_detect: empty input" {
  let shadow_mask = @cv_advanced.cloud_shadow_detect([], [], 0.3, 0.0, 1.0, 1)
  assert_eq(shadow_mask.length(), 0)
}

///|
test "cloud_progressive_refinement: converges" {
  let image = [
    [0.1, 0.2, 0.8, 0.9],
    [0.1, 0.2, 0.7, 0.85],
    [0.1, 0.2, 0.8, 0.9],
    [0.1, 0.2, 0.7, 0.85],
  ]
  let mask = @cv_advanced.cloud_progressive_refinement(image, 0.5, 3)
  assert_eq(mask.length(), 4)
}

///|
test "cloud_progressive_refinement: empty input" {
  let mask = @cv_advanced.cloud_progressive_refinement([], 0.5, 3)
  assert_eq(mask.length(), 0)
}

///|
test "cloud_compute_coverage: computes percentage" {
  let mask = [[1, 0, 1], [0, 1, 0], [1, 1, 0]]
  let coverage = @cv_advanced.cloud_compute_coverage(mask)
  assert_true(coverage > 0.55 && coverage < 0.56)
}

///|
test "cloud_compute_coverage: all clear" {
  let mask = [[0, 0], [0, 0]]
  let coverage = @cv_advanced.cloud_compute_coverage(mask)
  assert_true(coverage == 0.0)
}

///|
test "cloud_compute_coverage: all cloud" {
  let mask = [[1, 1], [1, 1]]
  let coverage = @cv_advanced.cloud_compute_coverage(mask)
  assert_true(coverage > 0.99)
}

///|
test "cloud_compute_coverage: empty mask" {
  let coverage = @cv_advanced.cloud_compute_coverage([])
  assert_true(coverage == 0.0)
}

///|
test "cloud_morph_open: removes small features" {
  let mask = [
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 1, 1, 1, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0],
  ]
  let result = @cv_advanced.cloud_morph_open(mask, 3)
  assert_eq(result.length(), 5)
}

///|
test "cloud_morph_open: empty input" {
  let result = @cv_advanced.cloud_morph_open([], 3)
  assert_eq(result.length(), 0)
}

///|
test "cloud_build_result: constructs correctly" {
  let cloud_mask = [[1, 0], [0, 1]]
  let shadow_mask = [[0, 0], [0, 0]]
  let result = @cv_advanced.cloud_build_result(cloud_mask, shadow_mask)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_true(result.cloud_coverage > 0.49 && result.cloud_coverage < 0.51)
}

///|
test "cloud_detect: threshold dispatch" {
  let image = [[0.2, 0.8], [0.9, 0.1]]
  let mask = @cv_advanced.cloud_detect(
    image,
    @cv_advanced.CloudDetectMethod::Threshold,
    0.5,
  )
  assert_eq(mask[0][0], 0)
  assert_eq(mask[0][1], 1)
}

///|
test "cloud_detect: multispectral dispatch" {
  let image = [[0.2, 0.8], [0.9, 0.1]]
  let mask = @cv_advanced.cloud_detect(
    image,
    @cv_advanced.CloudDetectMethod::Multispectral,
    0.5,
  )
  assert_eq(mask[0][1], 1)
}

///|
test "cloud_detect: progressive dispatch" {
  let image = [[0.2, 0.8], [0.9, 0.1]]
  let mask = @cv_advanced.cloud_detect(
    image,
    @cv_advanced.CloudDetectMethod::Progressive,
    0.5,
  )
  assert_eq(mask.length(), 2)
}
