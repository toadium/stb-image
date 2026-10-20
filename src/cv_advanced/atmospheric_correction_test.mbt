///|
test "atmo_radiometric_calibration: basic conversion" {
  let dn = [[100.0, 200.0], [50.0, 150.0]]
  let radiance = @cv_advanced.atmo_radiometric_calibration(dn, 0.1, 1.0)
  assert_true(radiance[0][0] > 10.99 && radiance[0][0] < 11.01)
  assert_true(radiance[0][1] > 20.99 && radiance[0][1] < 21.01)
}

///|
test "atmo_radiometric_calibration: empty input" {
  let radiance = @cv_advanced.atmo_radiometric_calibration([], 0.1, 1.0)
  assert_eq(radiance.length(), 0)
}

///|
test "atmo_dos_correction: subtracts minimum" {
  let radiance = [[5.0, 10.0], [3.0, 8.0]]
  let corrected = @cv_advanced.atmo_dos_correction(radiance)
  assert_true(corrected[1][0] == 0.0)
  assert_true(corrected[0][0] > 1.99 && corrected[0][0] < 2.01)
}

///|
test "atmo_dos_correction: empty input" {
  let corrected = @cv_advanced.atmo_dos_correction([])
  assert_eq(corrected.length(), 0)
}

///|
test "atmo_reflectance: basic conversion" {
  let params = @cv_advanced.atmo_build_params(1.0, 0.0, 0.1, 0.0, 1.0, 1000.0)
  let radiance = [[100.0]]
  let refl = @cv_advanced.atmo_reflectance(radiance, params)
  let sin_el = @math.sin(1.0)
  let expected = 100.0 / (1000.0 * sin_el)
  assert_true(refl[0][0] > expected - 0.001 && refl[0][0] < expected + 0.001)
}

///|
test "atmo_reflectance: empty input" {
  let params = @cv_advanced.atmo_build_params(1.0, 0.0, 0.1, 0.0, 1.0, 1000.0)
  let refl = @cv_advanced.atmo_reflectance([], params)
  assert_eq(refl.length(), 0)
}

///|
test "atmo_empirical_line: linear regression" {
  let raw = [[1.0, 2.0], [3.0, 4.0]]
  let field = [2.0, 4.0, 6.0, 8.0]
  let image = [1.0, 2.0, 3.0, 4.0]
  let result = @cv_advanced.atmo_empirical_line(raw, field, image)
  assert_true(result[0][0] > 1.99 && result[0][0] < 2.01)
  assert_true(result[0][1] > 3.99 && result[0][1] < 4.01)
}

///|
test "atmo_empirical_line: insufficient data" {
  let raw = [[1.0, 2.0]]
  let result = @cv_advanced.atmo_empirical_line(raw, [1.0], [1.0])
  assert_true(result[0][0] > 0.99 && result[0][0] < 1.01)
}

///|
test "atmo_rayleigh_correction: basic correction" {
  let radiance = [[10.0, 20.0], [15.0, 25.0]]
  let corrected = @cv_advanced.atmo_rayleigh_correction(
    radiance, 450.0, 0.5, 0.3,
  )
  assert_eq(corrected.length(), 2)
  assert_true(corrected[0][0] < 10.0)
}

///|
test "atmo_rayleigh_correction: empty input" {
  let corrected = @cv_advanced.atmo_rayleigh_correction([], 450.0, 0.5, 0.0)
  assert_eq(corrected.length(), 0)
}

///|
test "atmo_correct: DOS dispatch" {
  let radiance = [[5.0, 10.0], [3.0, 8.0]]
  let result = @cv_advanced.atmo_correct(
    radiance,
    @cv_advanced.AtmoMethod::DarkObjectSubtraction,
    450.0,
    0.5,
    0.0,
  )
  assert_true(result[1][0] == 0.0)
}

///|
test "atmo_correct: Rayleigh dispatch" {
  let radiance = [[10.0, 20.0]]
  let result = @cv_advanced.atmo_correct(
    radiance,
    @cv_advanced.AtmoMethod::Rayleigh,
    450.0,
    0.5,
    0.0,
  )
  assert_eq(result.length(), 1)
}

///|
test "atmo_correct: EmpiricalLine dispatch" {
  let radiance = [[10.0, 20.0]]
  let result = @cv_advanced.atmo_correct(
    radiance,
    @cv_advanced.AtmoMethod::EmpiricalLine,
    450.0,
    0.5,
    0.0,
  )
  assert_true(result[0][0] > 9.99 && result[0][0] < 10.01)
}

///|
test "atmo_build_params: constructs correctly" {
  let params = @cv_advanced.atmo_build_params(0.5, 1.0, 0.1, 1.0, 1.0, 1000.0)
  assert_true(params.sun_elevation > 0.49 && params.sun_elevation < 0.51)
  assert_true(params.gain > 0.09 && params.gain < 0.11)
}

///|
test "atmo_mean_radiance: computes average" {
  let radiance = [[10.0, 20.0], [30.0, 40.0]]
  let mean = @cv_advanced.atmo_mean_radiance(radiance)
  assert_true(mean > 24.99 && mean < 25.01)
}

///|
test "atmo_mean_radiance: empty input" {
  let mean = @cv_advanced.atmo_mean_radiance([])
  assert_true(mean == 0.0)
}
