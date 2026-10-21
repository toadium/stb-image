///|
test "insar_wrap_phase: wraps to pi range" {
  let wrapped = @cv_advanced.insar_wrap_phase(7.0)
  assert_true(wrapped >= -3.14159265358979323846)
  assert_true(wrapped <= 3.14159265358979323846)
}

///|
test "insar_wrap_phase: already in range unchanged" {
  let wrapped = @cv_advanced.insar_wrap_phase(1.5)
  assert_true(wrapped > 1.49 && wrapped < 1.51)
}

///|
test "insar_wrap_phase: negative wrap" {
  let wrapped = @cv_advanced.insar_wrap_phase(-7.0)
  assert_true(wrapped >= -3.14159265358979323846)
  assert_true(wrapped <= 3.14159265358979323846)
}

///|
test "insar_create_interferogram: basic interferogram" {
  let real1 = [[1.0, 0.0], [0.0, 1.0]]
  let imag1 = [[0.0, 1.0], [1.0, 0.0]]
  let real2 = [[1.0, 0.0], [0.0, 1.0]]
  let imag2 = [[0.0, 1.0], [1.0, 0.0]]
  let interf = @cv_advanced.insar_create_interferogram(
    real1, imag1, real2, imag2,
  )
  assert_eq(interf.width, 2)
  assert_eq(interf.height, 2)
}

///|
test "insar_create_interferogram: empty input" {
  let interf = @cv_advanced.insar_create_interferogram([], [], [], [])
  assert_eq(interf.width, 0)
  assert_eq(interf.height, 0)
}

///|
test "insar_estimate_coherence: window averaging" {
  let phase = [[0.0, 0.0], [0.0, 0.0]]
  let coherence = [[0.5, 0.8], [0.6, 0.9]]
  let interf = @cv_advanced.insar_build_interferogram(phase, coherence)
  let est = @cv_advanced.insar_estimate_coherence(interf, 3)
  assert_eq(est.length(), 2)
  assert_eq(est[0].length(), 2)
}

///|
test "insar_unwrap_phase: simple unwrapping" {
  let pi = 3.14159265358979323846
  let wrapped = [[0.0, pi * 0.5, pi * 0.9], [0.0, pi * 0.5, pi * 0.9]]
  let unwrapped = @cv_advanced.insar_unwrap_phase(
    wrapped,
    @cv_advanced.UnwrapMethod::LeastSquares,
  )
  assert_eq(unwrapped.length(), 2)
  assert_eq(unwrapped[0].length(), 3)
  assert_true(unwrapped[0][0] > -0.01 && unwrapped[0][0] < 0.01)
}

///|
test "insar_unwrap_phase: empty input" {
  let unwrapped = @cv_advanced.insar_unwrap_phase(
    [],
    @cv_advanced.UnwrapMethod::PathFollowing,
  )
  assert_eq(unwrapped.length(), 0)
}

///|
test "insar_unwrap_phase: quality guided method" {
  let wrapped = [[0.0, 1.0, 2.0], [0.0, 1.0, 2.0]]
  let unwrapped = @cv_advanced.insar_unwrap_phase(
    wrapped,
    @cv_advanced.UnwrapMethod::QualityGuided,
  )
  assert_eq(unwrapped.length(), 2)
}

///|
test "insar_phase_to_height: converts phase to DEM" {
  let unwrapped = [[1.0, 2.0], [3.0, 4.0]]
  let dem = @cv_advanced.insar_phase_to_height(
    unwrapped, 0.056, 100.0, 800000.0, 0.52359877559829887308,
  )
  assert_eq(dem.length(), 2)
  assert_eq(dem[0].length(), 2)
}

///|
test "insar_phase_to_height: empty input" {
  let dem = @cv_advanced.insar_phase_to_height([], 0.056, 100.0, 800000.0, 0.5)
  assert_eq(dem.length(), 0)
}

///|
test "insar_filter_interferogram: smoothing" {
  let phase = [[0.0, 1.0, 0.0], [1.0, 5.0, 1.0], [0.0, 1.0, 0.0]]
  let filtered = @cv_advanced.insar_filter_interferogram(phase, 0.5)
  assert_eq(filtered.length(), 3)
  assert_eq(filtered[0].length(), 3)
}

///|
test "insar_filter_interferogram: empty input" {
  let filtered = @cv_advanced.insar_filter_interferogram([], 0.5)
  assert_eq(filtered.length(), 0)
}

///|
test "insar_mean_coherence: computes average" {
  let phase = [[0.0, 0.0], [0.0, 0.0]]
  let coherence = [[0.8, 0.6], [0.4, 0.8]]
  let interf = @cv_advanced.insar_build_interferogram(phase, coherence)
  let mean = @cv_advanced.insar_mean_coherence(interf)
  assert_true(mean > 0.64 && mean < 0.66)
}

///|
test "insar_mean_coherence: empty interferogram" {
  let interf = @cv_advanced.insar_build_interferogram([], [])
  let mean = @cv_advanced.insar_mean_coherence(interf)
  assert_true(mean == 0.0)
}

///|
test "insar_coherence_mask: threshold filtering" {
  let phase = [[0.0, 0.0], [0.0, 0.0]]
  let coherence = [[0.9, 0.3], [0.5, 0.7]]
  let interf = @cv_advanced.insar_build_interferogram(phase, coherence)
  let mask = @cv_advanced.insar_coherence_mask(interf, 0.5)
  assert_eq(mask[0][0], 1)
  assert_eq(mask[0][1], 0)
  assert_eq(mask[1][0], 1)
  assert_eq(mask[1][1], 1)
}

///|
test "insar_build_interferogram: constructs correctly" {
  let phase = [[1.0, 2.0], [3.0, 4.0]]
  let coherence = [[0.5, 0.6], [0.7, 0.8]]
  let interf = @cv_advanced.insar_build_interferogram(phase, coherence)
  assert_eq(interf.width, 2)
  assert_eq(interf.height, 2)
}
