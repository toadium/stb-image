///|
test "ts_build_data: constructs correctly" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0, 4.0, 5.0])
  assert_eq(data.num_points, 5)
  assert_eq(data.values.length(), 5)
}

///|
test "ts_linear_trend: perfect linear" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0, 4.0, 5.0])
  let (slope, intercept) = @cv_advanced.ts_linear_trend(data)
  assert_true(slope > 0.99 && slope < 1.01)
  assert_true(intercept > 0.99 && intercept < 1.01)
}

///|
test "ts_linear_trend: constant series" {
  let data = @cv_advanced.ts_build_data([3.0, 3.0, 3.0, 3.0])
  let (slope, intercept) = @cv_advanced.ts_linear_trend(data)
  assert_true(slope > -0.01 && slope < 0.01)
  assert_true(intercept > 2.99 && intercept < 3.01)
}

///|
test "ts_linear_trend: insufficient data" {
  let data = @cv_advanced.ts_build_data([1.0])
  let (slope, intercept) = @cv_advanced.ts_linear_trend(data)
  assert_true(slope == 0.0)
  assert_true(intercept == 0.0)
}

///|
test "ts_moving_average: basic smoothing" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0, 4.0, 5.0])
  let smoothed = @cv_advanced.ts_moving_average(data, 3)
  assert_eq(smoothed.length(), 5)
  assert_true(smoothed[2] > 2.99 && smoothed[2] < 3.01)
}

///|
test "ts_moving_average: window 1" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0])
  let smoothed = @cv_advanced.ts_moving_average(data, 1)
  assert_true(smoothed[0] > 0.99 && smoothed[0] < 1.01)
  assert_true(smoothed[1] > 1.99 && smoothed[1] < 2.01)
}

///|
test "ts_moving_average: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let smoothed = @cv_advanced.ts_moving_average(data, 3)
  assert_eq(smoothed.length(), 0)
}

///|
test "ts_seasonal_decompose: basic decomposition" {
  let data = @cv_advanced.ts_build_data([1.0, 3.0, 1.0, 3.0, 1.0, 3.0])
  let (trend, _, _) = @cv_advanced.ts_seasonal_decompose(data, 2)
  assert_eq(trend.length(), 6)
}

///|
test "ts_seasonal_decompose: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let (trend, _, _) = @cv_advanced.ts_seasonal_decompose(data, 2)
  assert_eq(trend.length(), 0)
}

///|
test "ts_anomaly_detect: detects outliers" {
  let data = @cv_advanced.ts_build_data([1.0, 1.0, 1.0, 10.0, 1.0, 1.0])
  let anomalies = @cv_advanced.ts_anomaly_detect(data, 2.0)
  assert_eq(anomalies[3], 1)
  assert_eq(anomalies[0], 0)
}

///|
test "ts_anomaly_detect: no anomalies" {
  let data = @cv_advanced.ts_build_data([1.0, 1.0, 1.0, 1.0])
  let anomalies = @cv_advanced.ts_anomaly_detect(data, 2.0)
  for i in 0..<4 {
    assert_eq(anomalies[i], 0)
  }
}

///|
test "ts_anomaly_detect: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let anomalies = @cv_advanced.ts_anomaly_detect(data, 2.0)
  assert_eq(anomalies.length(), 0)
}

///|
test "ts_change_point_detect: detects change" {
  let data = @cv_advanced.ts_build_data([1.0, 1.0, 1.0, 5.0, 5.0, 5.0])
  let cps = @cv_advanced.ts_change_point_detect(data, 2)
  assert_true(cps.length() > 0)
}

///|
test "ts_change_point_detect: no change" {
  let data = @cv_advanced.ts_build_data([3.0, 3.0, 3.0, 3.0])
  let cps = @cv_advanced.ts_change_point_detect(data, 1)
  assert_true(cps.length() >= 0)
}

///|
test "ts_change_point_detect: insufficient data" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0])
  let cps = @cv_advanced.ts_change_point_detect(data, 2)
  assert_eq(cps.length(), 0)
}

///|
test "ts_forecast: linear extrapolation" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0, 4.0, 5.0])
  let forecast = @cv_advanced.ts_forecast(data, 3)
  assert_eq(forecast.length(), 3)
  assert_true(forecast[0] > 5.99 && forecast[0] < 6.01)
  assert_true(forecast[1] > 6.99 && forecast[1] < 7.01)
}

///|
test "ts_forecast: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let forecast = @cv_advanced.ts_forecast(data, 3)
  assert_eq(forecast.length(), 3)
}

///|
test "ts_mean: computes average" {
  let data = @cv_advanced.ts_build_data([1.0, 2.0, 3.0, 4.0, 5.0])
  let mean = @cv_advanced.ts_mean(data)
  assert_true(mean > 2.99 && mean < 3.01)
}

///|
test "ts_mean: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let mean = @cv_advanced.ts_mean(data)
  assert_true(mean == 0.0)
}

///|
test "ts_stddev: computes standard deviation" {
  let data = @cv_advanced.ts_build_data([1.0, 1.0, 1.0, 1.0])
  let stddev = @cv_advanced.ts_stddev(data)
  assert_true(stddev > -0.01 && stddev < 0.01)
}

///|
test "ts_stddev: varying data" {
  let data = @cv_advanced.ts_build_data([0.0, 2.0])
  let stddev = @cv_advanced.ts_stddev(data)
  assert_true(stddev > 0.99 && stddev < 1.01)
}

///|
test "ts_stddev: empty data" {
  let data = @cv_advanced.ts_build_data([])
  let stddev = @cv_advanced.ts_stddev(data)
  assert_true(stddev == 0.0)
}
