///|
test "ortho_correct: basic correction" {
  let image = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
  let dem = [[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]]
  let params = @cv_advanced.ortho_build_params(100.0, 1000.0, 1.0, dem)
  let result = @cv_advanced.ortho_correct(image, params)
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 3)
}

///|
test "ortho_correct: with elevation" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let dem = [[10.0, 10.0], [10.0, 10.0]]
  let params = @cv_advanced.ortho_build_params(100.0, 1000.0, 1.0, dem)
  let result = @cv_advanced.ortho_correct(image, params)
  assert_eq(result.length(), 2)
}

///|
test "ortho_correct: empty input" {
  let params = @cv_advanced.ortho_build_params(100.0, 1000.0, 1.0, [])
  let result = @cv_advanced.ortho_correct([], params)
  assert_eq(result.length(), 0)
}

///|
test "ortho_mosaic: basic mosaicking" {
  let images = [[[1.0, 2.0], [3.0, 4.0]], [[5.0, 6.0], [7.0, 8.0]]]
  let offsets = [(0, 0), (2, 0)]
  let result = @cv_advanced.ortho_mosaic(images, offsets)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 4)
  assert_true(result[0][0] > 0.99 && result[0][0] < 1.01)
  assert_true(result[0][2] > 4.99 && result[0][2] < 5.01)
}

///|
test "ortho_mosaic: empty input" {
  let result = @cv_advanced.ortho_mosaic([], [])
  assert_eq(result.length(), 0)
}

///|
test "ortho_color_balance: basic balancing" {
  let source = [[1.0, 2.0], [3.0, 4.0]]
  let reference = [[2.0, 4.0], [6.0, 8.0]]
  let result = @cv_advanced.ortho_color_balance(source, reference)
  assert_eq(result.length(), 2)
  assert_true(result[0][0] > 1.99 && result[0][0] < 2.01)
}

///|
test "ortho_color_balance: empty source" {
  let result = @cv_advanced.ortho_color_balance([], [[1.0]])
  assert_eq(result.length(), 0)
}

///|
test "ortho_wallis_dodging: basic dodging" {
  let image = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
  let result = @cv_advanced.ortho_wallis_dodging(image, 3, 5.0, 2.0)
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 3)
}

///|
test "ortho_wallis_dodging: empty input" {
  let result = @cv_advanced.ortho_wallis_dodging([], 3, 5.0, 2.0)
  assert_eq(result.length(), 0)
}

///|
test "ortho_seamline: generates center line" {
  let seamline = @cv_advanced.ortho_seamline(10, 5)
  assert_eq(seamline.length(), 5)
  assert_eq(seamline[0], (0, 5))
  assert_eq(seamline[4], (4, 5))
}

///|
test "ortho_build_params: constructs correctly" {
  let dem = [[1.0, 2.0], [3.0, 4.0]]
  let params = @cv_advanced.ortho_build_params(100.0, 1000.0, 1.0, dem)
  assert_true(params.focal_length > 99.99 && params.focal_length < 100.01)
  assert_eq(params.dem_data.length(), 2)
}

///|
test "ortho_displacement: computes correctly" {
  let disp = @cv_advanced.ortho_displacement(100.0, 50.0, 1000.0)
  assert_true(disp > 4.99 && disp < 5.01)
}

///|
test "ortho_displacement: zero elevation" {
  let disp = @cv_advanced.ortho_displacement(0.0, 50.0, 1000.0)
  assert_true(disp == 0.0)
}
