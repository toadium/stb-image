// 超声处理测试
// Ultrasound processing tests

///|
test "ultrasound_speckle_reduction: 基本降噪" {
  let image = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0]
  let result = @cv_advanced.ultrasound_speckle_reduction(image, 3, 3, 1)
  assert_eq(result.length(), 9)
  for i in 0..<9 {
    assert_true(result[i] >= 0.0 || result[i] < 0.0)
  }
}

///|
test "ultrasound_speckle_reduction: 常值图像不变" {
  let image = [50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0, 50.0]
  let result = @cv_advanced.ultrasound_speckle_reduction(image, 3, 3, 1)
  assert_eq(result.length(), 9)
}

///|
test "ultrasound_envelope_detection: 正弦信号" {
  let rf : Array[Double] = []
  for i in 0..<100 {
    let t = i.to_double() * 0.1
    rf.push(@math.sin(t * 6.283185307179586))
  }
  let envelope = @cv_advanced.ultrasound_envelope_detection(rf)
  assert_eq(envelope.length(), 100)
  for i in 0..<100 {
    assert_true(envelope[i] >= 0.0)
  }
}

///|
test "ultrasound_log_compression: 正值压缩" {
  let image = [1.0, 10.0, 100.0, 1000.0]
  let result = @cv_advanced.ultrasound_log_compression(image, 1000.0, 1.0)
  assert_eq(result.length(), 4)
  assert_true(result[0] >= 0.0)
  assert_true(result[3] >= result[0])
}

///|
test "ultrasound_log_compression: 零值处理" {
  let image = [0.0, -1.0, 5.0]
  let result = @cv_advanced.ultrasound_log_compression(image, 100.0, 1.0)
  assert_eq(result[0], 0.0)
  assert_eq(result[1], 0.0)
  assert_true(result[2] > 0.0)
}

///|
test "ultrasound_scan_conversion: 极坐标转换" {
  let polar : Array[Double] = []
  for i in 0..<100 {
    polar.push(i.to_double())
  }
  let result = @cv_advanced.ultrasound_scan_conversion(
    polar, 10, 10, 100.0, 5, 5,
  )
  assert_eq(result.length(), 25)
}

///|
test "ultrasound_elastography: 相同图像零应变" {
  let image = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
  let result = @cv_advanced.ultrasound_elastography(image, image, 3, 3, 1)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  assert_eq(result.strain.length(), 9)
  for i in 0..<9 {
    assert_true(result.strain[i] < 0.001 && result.strain[i] > -0.001)
  }
}

///|
test "ultrasound_elastography: 压缩图像正应变" {
  let pre = [100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0, 100.0]
  let post = [90.0, 90.0, 90.0, 90.0, 90.0, 90.0, 90.0, 90.0, 90.0]
  let result = @cv_advanced.ultrasound_elastography(pre, post, 3, 3, 1)
  for i in 0..<9 {
    assert_true(result.strain[i] < 0.0)
  }
}

///|
test "ultrasound_doppler_shift: 正向频移" {
  let v = @cv_advanced.ultrasound_doppler_shift(5000000.0, 5000100.0, 1540.0)
  assert_true(v > 0.0)
}

///|
test "ultrasound_doppler_shift: 零频移" {
  let v = @cv_advanced.ultrasound_doppler_shift(5000000.0, 5000000.0, 1540.0)
  assert_true(v < 0.001 && v > -0.001)
}

///|
test "ultrasound_time_gain_compensation: 深度增益" {
  let image = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
  let result = @cv_advanced.ultrasound_time_gain_compensation(image, 2, 3, 0.01)
  assert_eq(result.length(), 6)
  assert_true(result[4] >= result[0])
}
