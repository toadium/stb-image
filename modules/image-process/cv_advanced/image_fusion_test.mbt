///|
test "fusion_rgb_to_ihs: basic conversion" {
  let (i, _, s) = @cv_advanced.fusion_rgb_to_ihs(0.5, 0.5, 0.5)
  assert_true(i > 0.49 && i < 0.51)
  assert_true(s == 0.0)
}

///|
test "fusion_rgb_to_ihs: colored pixel" {
  let (i, _, s) = @cv_advanced.fusion_rgb_to_ihs(0.8, 0.2, 0.2)
  assert_true(i > 0.39 && i < 0.41)
  assert_true(s > 0.0)
}

///|
test "fusion_ihs_to_rgb: basic conversion" {
  let (r, g, b) = @cv_advanced.fusion_ihs_to_rgb(0.5, 0.0, 0.0)
  assert_true(r > 0.49 && r < 0.51)
  assert_true(g > 0.49 && g < 0.51)
  assert_true(b > 0.49 && b < 0.51)
}

///|
test "fusion_ihs: basic fusion" {
  let ms = [
    [[0.5, 0.3, 0.2], [0.4, 0.4, 0.2]],
    [[0.3, 0.5, 0.2], [0.2, 0.4, 0.4]],
  ]
  let pan = [[0.6, 0.5], [0.4, 0.3]]
  let result = @cv_advanced.fusion_ihs(ms, pan)
  assert_eq(result.length(), 2)
  assert_eq(result[0].length(), 2)
  assert_eq(result[0][0].length(), 3)
}

///|
test "fusion_ihs: empty input" {
  let result = @cv_advanced.fusion_ihs([], [])
  assert_eq(result.length(), 0)
}

///|
test "fusion_pca: basic fusion" {
  let ms = [[[0.5, 0.3], [0.4, 0.2]], [[0.3, 0.5], [0.2, 0.4]]]
  let pan = [[0.6, 0.5], [0.4, 0.3]]
  let result = @cv_advanced.fusion_pca(ms, pan)
  assert_eq(result.length(), 2)
  assert_eq(result[0][0].length(), 2)
}

///|
test "fusion_pca: empty input" {
  let result = @cv_advanced.fusion_pca([], [])
  assert_eq(result.length(), 0)
}

///|
test "fusion_wavelet: basic fusion" {
  let ms = [[[0.5, 0.3], [0.4, 0.2]], [[0.3, 0.5], [0.2, 0.4]]]
  let pan = [[0.6, 0.5], [0.4, 0.3]]
  let result = @cv_advanced.fusion_wavelet(ms, pan)
  assert_eq(result.length(), 2)
  let expected = 0.5 * 0.5 + 0.5 * 0.6
  assert_true(
    result[0][0][0] > expected - 0.001 && result[0][0][0] < expected + 0.001,
  )
}

///|
test "fusion_wavelet: empty input" {
  let result = @cv_advanced.fusion_wavelet([], [])
  assert_eq(result.length(), 0)
}

///|
test "fusion_gram_schmidt: basic fusion" {
  let ms = [[[0.5, 0.3], [0.4, 0.2]], [[0.3, 0.5], [0.2, 0.4]]]
  let pan = [[0.6, 0.5], [0.4, 0.3]]
  let result = @cv_advanced.fusion_gram_schmidt(ms, pan)
  assert_eq(result.length(), 2)
  assert_eq(result[0][0].length(), 2)
}

///|
test "fusion_gram_schmidt: empty input" {
  let result = @cv_advanced.fusion_gram_schmidt([], [])
  assert_eq(result.length(), 0)
}

///|
test "fusion_dispatch: IHS method" {
  let ms = [[[0.5, 0.3, 0.2]]]
  let pan = [[0.6]]
  let result = @cv_advanced.fusion_dispatch(
    ms,
    pan,
    @cv_advanced.FusionMethod::Ihs,
  )
  assert_eq(result.length(), 1)
}

///|
test "fusion_dispatch: PCA method" {
  let ms = [[[0.5, 0.3]]]
  let pan = [[0.6]]
  let result = @cv_advanced.fusion_dispatch(
    ms,
    pan,
    @cv_advanced.FusionMethod::Pca,
  )
  assert_eq(result.length(), 1)
}

///|
test "fusion_dispatch: Wavelet method" {
  let ms = [[[0.5, 0.3]]]
  let pan = [[0.6]]
  let result = @cv_advanced.fusion_dispatch(
    ms,
    pan,
    @cv_advanced.FusionMethod::Wavelet,
  )
  assert_eq(result.length(), 1)
}

///|
test "fusion_dispatch: GramSchmidt method" {
  let ms = [[[0.5, 0.3]]]
  let pan = [[0.6]]
  let result = @cv_advanced.fusion_dispatch(
    ms,
    pan,
    @cv_advanced.FusionMethod::GramSchmidt,
  )
  assert_eq(result.length(), 1)
}

///|
test "fusion_quality_mean: computes average" {
  let fused = [[[0.5, 0.3], [0.7, 0.1]], [[0.2, 0.4], [0.6, 0.8]]]
  let mean = @cv_advanced.fusion_quality_mean(fused)
  assert_true(mean > 0.44 && mean < 0.46)
}

///|
test "fusion_quality_mean: empty input" {
  let mean = @cv_advanced.fusion_quality_mean([])
  assert_true(mean == 0.0)
}
