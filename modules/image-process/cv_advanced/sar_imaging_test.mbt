///|
test "sar_build_params: construct valid params" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  assert_true(params.carrier_freq == 9.6e9)
  assert_true(params.platform_velocity == 150.0)
  assert_true(params.pulse_duration == 2.5e-6)
}

///|
test "sar_simulate_chirp: generates correct length" {
  let chirp = @cv_advanced.sar_simulate_chirp(64, 2.5e-6, 4.0e13)
  assert_eq(chirp.length(), 64)
  assert_true(chirp[32] > -2.0 && chirp[32] < 2.0)
}

///|
test "sar_simulate_chirp: center is cosine of zero" {
  let chirp = @cv_advanced.sar_simulate_chirp(101, 1.0, 0.0)
  let center = chirp[50]
  assert_true(center > 0.99 && center < 1.01)
}

///|
test "sar_range_compression: preserves dimensions" {
  let raw = [
    [1.0, 0.5, 0.0, 0.0, 0.5, 1.0, 0.5, 0.0],
    [0.5, 1.0, 0.5, 0.0, 0.0, 0.5, 1.0, 0.5],
  ]
  let chirp = [1.0, 0.5, 0.0, 0.5, 1.0]
  let result = @cv_advanced.sar_range_compression(raw, chirp)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 8)
}

///|
test "sar_range_compression: empty input returns empty" {
  let result = @cv_advanced.sar_range_compression([], [1.0, 0.5])
  assert_eq(result.length(), 0)
}

///|
test "sar_azimuth_compression: preserves width" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let data = [[1.0, 0.5, 0.0], [0.5, 1.0, 0.5], [0.0, 0.5, 1.0]]
  let result = @cv_advanced.sar_azimuth_compression(data, params)
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 3)
}

///|
test "sar_rda: full pipeline produces output" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let raw = [
    [1.0, 0.5, 0.0, 0.0, 0.5, 1.0, 0.5, 0.0],
    [0.5, 1.0, 0.5, 0.0, 0.0, 0.5, 1.0, 0.5],
    [0.0, 0.5, 1.0, 0.5, 0.0, 0.0, 0.5, 1.0],
  ]
  let result = @cv_advanced.sar_rda(raw, params)
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 8)
}

///|
test "sar_rda: empty input returns empty" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let result = @cv_advanced.sar_rda([], params)
  assert_eq(result.length(), 0)
}

///|
test "sar_csa: produces same dimensions as rda" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let raw = [[1.0, 0.5, 0.0, 0.0], [0.5, 1.0, 0.5, 0.0], [0.0, 0.5, 1.0, 0.5]]
  let csa_result = @cv_advanced.sar_csa(raw, params)
  assert_eq(csa_result.length(), 3)
  assert_eq(csa_result[0].length(), 4)
}

///|
test "sar_omega_k: produces same dimensions" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let raw = [[1.0, 0.5, 0.0, 0.0], [0.5, 1.0, 0.5, 0.0], [0.0, 0.5, 1.0, 0.5]]
  let result = @cv_advanced.sar_omega_k(raw, params)
  assert_eq(result.length(), 3)
  assert_eq(result[0].length(), 4)
}

///|
test "sar_focus: dispatches by mode" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let raw = [[1.0, 0.5, 0.0, 0.0], [0.5, 1.0, 0.5, 0.0]]
  let rda = @cv_advanced.sar_focus(
    raw,
    params,
    @cv_advanced.SarMode::RangeDoppler,
  )
  let csa = @cv_advanced.sar_focus(
    raw,
    params,
    @cv_advanced.SarMode::ChirpScaling,
  )
  let omega_k = @cv_advanced.sar_focus(
    raw,
    params,
    @cv_advanced.SarMode::OmegaK,
  )
  assert_eq(rda.length(), 2)
  assert_eq(csa.length(), 2)
  assert_eq(omega_k.length(), 2)
}

///|
test "sar_multilook: reduces height" {
  let data = [
    [1.0, 2.0, 3.0],
    [4.0, 5.0, 6.0],
    [7.0, 8.0, 9.0],
    [10.0, 11.0, 12.0],
  ]
  let result = @cv_advanced.sar_multilook(data, 2)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 3)
}

///|
test "sar_multilook: num_looks=1 returns original" {
  let data = [[1.0, 2.0], [3.0, 4.0]]
  let result = @cv_advanced.sar_multilook(data, 1)
  assert_eq(result.length(), 2)
}

///|
test "sar_multilook: empty input" {
  let result = @cv_advanced.sar_multilook([], 2)
  assert_eq(result.length(), 0)
}

///|
test "sar_detect_point_target: finds peak" {
  let data = [[0.1, 0.2, 0.1], [0.2, 5.0, 0.2], [0.1, 0.2, 0.1]]
  let (row, col, val) = @cv_advanced.sar_detect_point_target(data)
  assert_eq(row, 1)
  assert_eq(col, 1)
  assert_true(val > 4.99 && val < 5.01)
}

///|
test "sar_detect_point_target: empty input" {
  let (row, col, val) = @cv_advanced.sar_detect_point_target([])
  assert_eq(row, 0)
  assert_eq(col, 0)
  assert_true(val == 0.0)
}

///|
test "sar_build_image: constructs correctly" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let data = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0]]
  let image = @cv_advanced.sar_build_image(data, params)
  assert_eq(image.width, 3)
  assert_eq(image.height, 2)
}

///|
test "sar_mean_intensity: computes average squared value" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let data = [[2.0, 0.0], [0.0, 2.0]]
  let image = @cv_advanced.sar_build_image(data, params)
  let intensity = @cv_advanced.sar_mean_intensity(image)
  assert_true(intensity > 1.99 && intensity < 2.01)
}

///|
test "sar_mean_intensity: empty image" {
  let params = @cv_advanced.sar_build_params(
    9.6e9, 150.0, 2.5e-6, 4.0e13, 100.0e6, 2.0, 8000.0,
  )
  let image = @cv_advanced.sar_build_image([], params)
  let intensity = @cv_advanced.sar_mean_intensity(image)
  assert_true(intensity == 0.0)
}

///|
test "SarParams::wavelength: computes c/f" {
  let params = @cv_advanced.sar_build_params(
    3.0e8, 150.0, 1.0, 1.0, 1.0, 1.0, 1.0,
  )
  let wl = params.wavelength()
  assert_true(wl > 0.99 && wl < 1.01)
}
