///|
test "veg_ndvi: basic computation" {
  let nir = [[0.6, 0.4], [0.8, 0.2]]
  let red = [[0.2, 0.4], [0.1, 0.3]]
  let ndvi = @cv_advanced.veg_ndvi(nir, red)
  let expected = (0.6 - 0.2) / (0.6 + 0.2)
  assert_true(ndvi[0][0] > expected - 0.001 && ndvi[0][0] < expected + 0.001)
}

///|
test "veg_ndvi: zero denominator" {
  let nir = [[0.5, 0.0]]
  let red = [[-0.5, 0.0]]
  let ndvi = @cv_advanced.veg_ndvi(nir, red)
  assert_true(ndvi[0][0] == 0.0)
  assert_true(ndvi[0][1] == 0.0)
}

///|
test "veg_ndvi: empty input" {
  let ndvi = @cv_advanced.veg_ndvi([], [])
  assert_eq(ndvi.length(), 0)
}

///|
test "veg_evi: basic computation" {
  let nir = [[0.5]]
  let red = [[0.1]]
  let blue = [[0.05]]
  let evi = @cv_advanced.veg_evi(nir, red, blue)
  let expected = 2.5 * (0.5 - 0.1) / (0.5 + 6.0 * 0.1 - 7.5 * 0.05 + 1.0)
  assert_true(evi[0][0] > expected - 0.001 && evi[0][0] < expected + 0.001)
}

///|
test "veg_evi: empty input" {
  let evi = @cv_advanced.veg_evi([], [], [])
  assert_eq(evi.length(), 0)
}

///|
test "veg_savi: basic computation" {
  let nir = [[0.6]]
  let red = [[0.2]]
  let savi = @cv_advanced.veg_savi(nir, red, 0.5)
  let expected = (0.6 - 0.2) / (0.6 + 0.2 + 0.5) * 1.5
  assert_true(savi[0][0] > expected - 0.001 && savi[0][0] < expected + 0.001)
}

///|
test "veg_savi: empty input" {
  let savi = @cv_advanced.veg_savi([], [], 0.5)
  assert_eq(savi.length(), 0)
}

///|
test "veg_msavi: basic computation" {
  let nir = [[0.6]]
  let red = [[0.2]]
  let msavi = @cv_advanced.veg_msavi(nir, red)
  assert_true(msavi[0][0] > 0.0)
}

///|
test "veg_msavi: empty input" {
  let msavi = @cv_advanced.veg_msavi([], [])
  assert_eq(msavi.length(), 0)
}

///|
test "veg_gndvi: basic computation" {
  let nir = [[0.6]]
  let green = [[0.3]]
  let gndvi = @cv_advanced.veg_gndvi(nir, green)
  let expected = (0.6 - 0.3) / (0.6 + 0.3)
  assert_true(gndvi[0][0] > expected - 0.001 && gndvi[0][0] < expected + 0.001)
}

///|
test "veg_rvi: basic computation" {
  let nir = [[0.6]]
  let red = [[0.2]]
  let rvi = @cv_advanced.veg_rvi(nir, red)
  assert_true(rvi[0][0] > 2.99 && rvi[0][0] < 3.01)
}

///|
test "veg_rvi: zero denominator" {
  let nir = [[0.5]]
  let red = [[0.0]]
  let rvi = @cv_advanced.veg_rvi(nir, red)
  assert_true(rvi[0][0] == 0.0)
}

///|
test "veg_dvi: basic computation" {
  let nir = [[0.6]]
  let red = [[0.2]]
  let dvi = @cv_advanced.veg_dvi(nir, red)
  assert_true(dvi[0][0] > 0.39 && dvi[0][0] < 0.41)
}

///|
test "veg_ndwi: basic computation" {
  let green = [[0.3]]
  let nir = [[0.1]]
  let ndwi = @cv_advanced.veg_ndwi(green, nir)
  let expected = (0.3 - 0.1) / (0.3 + 0.1)
  assert_true(ndwi[0][0] > expected - 0.001 && ndwi[0][0] < expected + 0.001)
}

///|
test "veg_ndbi: basic computation" {
  let swir = [[0.4]]
  let nir = [[0.3]]
  let ndbi = @cv_advanced.veg_ndbi(swir, nir)
  let expected = (0.4 - 0.3) / (0.4 + 0.3)
  assert_true(ndbi[0][0] > expected - 0.001 && ndbi[0][0] < expected + 0.001)
}

///|
test "veg_mean_index: computes average" {
  let index = [[0.5, 0.3], [0.7, 0.1]]
  let mean = @cv_advanced.veg_mean_index(index)
  assert_true(mean > 0.39 && mean < 0.41)
}

///|
test "veg_mean_index: empty input" {
  let mean = @cv_advanced.veg_mean_index([])
  assert_true(mean == 0.0)
}

///|
test "veg_fractional_cover: basic computation" {
  let ndvi = [[0.5, 0.1], [0.8, 0.3]]
  let fvc = @cv_advanced.veg_fractional_cover(ndvi, 0.1, 0.8)
  assert_eq(fvc.length(), 2)
  let expected = (0.5 - 0.1) / (0.8 - 0.1) * ((0.5 - 0.1) / (0.8 - 0.1))
  assert_true(fvc[0][0] > expected - 0.001 && fvc[0][0] < expected + 0.001)
}

///|
test "veg_fractional_cover: clamping" {
  let ndvi = [[-0.5, 1.5]]
  let fvc = @cv_advanced.veg_fractional_cover(ndvi, 0.1, 0.8)
  assert_true(fvc[0][0] == 0.0)
  assert_true(fvc[0][1] == 1.0)
}

///|
test "veg_fractional_cover: empty input" {
  let fvc = @cv_advanced.veg_fractional_cover([], 0.1, 0.8)
  assert_eq(fvc.length(), 0)
}
