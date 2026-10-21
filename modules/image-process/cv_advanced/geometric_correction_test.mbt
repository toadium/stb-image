///|
test "geo_build_gcp: constructs correctly" {
  let gcp = @cv_advanced.geo_build_gcp(10.0, 20.0, 100.0, 200.0)
  assert_true(gcp.image_x > 9.99 && gcp.image_x < 10.01)
  assert_true(gcp.ground_y > 199.99 && gcp.ground_y < 200.01)
}

///|
test "geo_polynomial_transform: first order" {
  let coeffs_x = [1.0, 2.0, 0.5]
  let coeffs_y = [0.0, 0.0, 1.0]
  let (gx, gy) = @cv_advanced.geo_polynomial_transform(
    3.0, 4.0, coeffs_x, coeffs_y,
  )
  assert_true(gx > 8.99 && gx < 9.01)
  assert_true(gy > 3.99 && gy < 4.01)
}

///|
test "geo_compute_polynomial_coeffs: identity transform" {
  let gcps = [
    @cv_advanced.geo_build_gcp(0.0, 0.0, 0.0, 0.0),
    @cv_advanced.geo_build_gcp(1.0, 0.0, 1.0, 0.0),
    @cv_advanced.geo_build_gcp(0.0, 1.0, 0.0, 1.0),
    @cv_advanced.geo_build_gcp(1.0, 1.0, 1.0, 1.0),
  ]
  let (coeffs_x, coeffs_y) = @cv_advanced.geo_compute_polynomial_coeffs(gcps)
  assert_true(coeffs_x[1] > 0.99 && coeffs_x[1] < 1.01)
  assert_true(coeffs_y[2] > 0.99 && coeffs_y[2] < 1.01)
}

///|
test "geo_compute_polynomial_coeffs: insufficient gcps" {
  let gcps = [@cv_advanced.geo_build_gcp(0.0, 0.0, 0.0, 0.0)]
  let (coeffs_x, _) = @cv_advanced.geo_compute_polynomial_coeffs(gcps)
  assert_true(coeffs_x[1] > 0.99 && coeffs_x[1] < 1.01)
}

///|
test "geo_rpc_transform: basic transform" {
  let rpc = @cv_advanced.geo_build_rpc(
    [0.0, 1.0, 0.0, 0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    [0.0, 0.0, 1.0, 0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
    1.0,
  )
  let (row, col) = @cv_advanced.geo_rpc_transform(0.5, 0.3, rpc)
  assert_true(row > 0.29 && row < 0.31)
  assert_true(col > 0.49 && col < 0.51)
}

///|
test "geo_resample_nearest: basic sampling" {
  let image = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [7.0, 8.0, 9.0]]
  let val = @cv_advanced.geo_resample_nearest(image, 1.4, 2.4)
  assert_true(val > 7.99 && val < 8.01)
}

///|
test "geo_resample_nearest: out of bounds" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample_nearest(image, 5.0, 5.0)
  assert_true(val == 0.0)
}

///|
test "geo_resample_nearest: empty image" {
  let val = @cv_advanced.geo_resample_nearest([], 1.0, 1.0)
  assert_true(val == 0.0)
}

///|
test "geo_resample_bilinear: basic interpolation" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample_bilinear(image, 0.5, 0.5)
  assert_true(val > 2.49 && val < 2.51)
}

///|
test "geo_resample_bilinear: exact pixel" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample_bilinear(image, 0.0, 0.0)
  assert_true(val > 0.99 && val < 1.01)
}

///|
test "geo_resample_bilinear: empty image" {
  let val = @cv_advanced.geo_resample_bilinear([], 1.0, 1.0)
  assert_true(val == 0.0)
}

///|
test "geo_resample: nearest dispatch" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample(
    image,
    0.0,
    0.0,
    @cv_advanced.ResampleMethod::NearestNeighbor,
  )
  assert_true(val > 0.99 && val < 1.01)
}

///|
test "geo_resample: bilinear dispatch" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample(
    image,
    0.5,
    0.5,
    @cv_advanced.ResampleMethod::Bilinear,
  )
  assert_true(val > 2.49 && val < 2.51)
}

///|
test "geo_resample: cubic dispatch" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let val = @cv_advanced.geo_resample(
    image,
    0.5,
    0.5,
    @cv_advanced.ResampleMethod::CubicConvolution,
  )
  assert_true(val > 2.49 && val < 2.51)
}

///|
test "geo_correct: basic correction" {
  let image = [[1.0, 2.0], [3.0, 4.0]]
  let gcps = [
    @cv_advanced.geo_build_gcp(0.0, 0.0, 0.0, 0.0),
    @cv_advanced.geo_build_gcp(1.0, 0.0, 1.0, 0.0),
    @cv_advanced.geo_build_gcp(0.0, 1.0, 0.0, 1.0),
    @cv_advanced.geo_build_gcp(1.0, 1.0, 1.0, 1.0),
  ]
  let result = @cv_advanced.geo_correct(
    image,
    gcps,
    2,
    2,
    @cv_advanced.ResampleMethod::NearestNeighbor,
  )
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 2)
}
