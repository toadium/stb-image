// 放射剂量测试
// Radiation dose tests

///|
test "dose_compute_dvh: 基本 DVH" {
  let dose = [10.0, 20.0, 30.0, 40.0, 50.0, 60.0]
  let mask = [1, 1, 1, 1, 1, 1]
  let dvh = @cv_advanced.dose_compute_dvh(dose, mask, 10, 100.0, "PTV")
  assert_eq(dvh.dose_bins.length(), 10)
  assert_eq(dvh.volume_bins.length(), 10)
  assert_eq(dvh.structure_name, "PTV")
}

///|
test "dose_compute_dvh: 空结构" {
  let dose = [10.0, 20.0, 30.0]
  let mask = [0, 0, 0]
  let dvh = @cv_advanced.dose_compute_dvh(dose, mask, 5, 100.0, "empty")
  for i in 0..<5 {
    assert_eq(dvh.volume_bins[i], 0.0)
  }
}

///|
test "dose_compute_metrics: 基本指标" {
  let dose = [10.0, 20.0, 30.0, 40.0, 50.0]
  let mask = [1, 1, 1, 1, 1]
  let metrics = @cv_advanced.dose_compute_metrics(dose, mask)
  assert_eq(metrics.min_dose, 10.0)
  assert_eq(metrics.max_dose, 50.0)
  assert_true(metrics.mean_dose > 29.0 && metrics.mean_dose < 31.0)
}

///|
test "dose_compute_metrics: 空结构" {
  let dose = [10.0, 20.0, 30.0]
  let mask = [0, 0, 0]
  let metrics = @cv_advanced.dose_compute_metrics(dose, mask)
  assert_eq(metrics.mean_dose, 0.0)
}

///|
test "dose_compute_eud: 基本计算" {
  let dose = [10.0, 20.0, 30.0, 40.0]
  let mask = [1, 1, 1, 1]
  let eud = @cv_advanced.dose_compute_eud(dose, mask, 2.0)
  assert_true(eud > 0.0)
}

///|
test "dose_compute_tcp: 基本计算" {
  let dose = [50.0, 60.0, 70.0, 80.0]
  let mask = [1, 1, 1, 1]
  let tcp = @cv_advanced.dose_compute_tcp(dose, mask, 50.0, 2.0)
  assert_true(tcp >= 0.0 && tcp <= 1.0)
}

///|
test "dose_compute_ntcp: 基本计算" {
  let dose = [30.0, 40.0, 50.0, 60.0]
  let mask = [1, 1, 1, 1]
  let ntcp = @cv_advanced.dose_compute_ntcp(dose, mask, 50.0, 0.1)
  assert_true(ntcp >= 0.0 && ntcp <= 1.0)
}

///|
test "erf_approx: 基本值" {
  let result = @cv_advanced.erf_approx(0.0)
  assert_true(result < 0.001 && result > -0.001)
}

///|
test "erf_approx: 大正值" {
  let result = @cv_advanced.erf_approx(3.0)
  assert_true(result > 0.9)
}

///|
test "dose_evaluate_plan: 基本评估" {
  let target_dose = [60.0, 60.0, 60.0, 60.0]
  let target_mask = [1, 1, 1, 1]
  let oar_doses : Array[Array[Double]] = []
  oar_doses.push([10.0, 10.0, 10.0, 10.0])
  let oar_masks : Array[Array[Int]] = []
  oar_masks.push([0, 0, 1, 1])
  let (coverage, conformality, mean_oar) = @cv_advanced.dose_evaluate_plan(
    target_dose, target_mask, oar_doses, oar_masks, 60.0,
  )
  assert_true(coverage > 0.0)
  assert_true(conformality > 0.0)
  assert_true(mean_oar >= 0.0)
}
