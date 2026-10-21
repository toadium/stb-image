// 功能成像测试
// Functional imaging tests

///|
test "functional_fmri_detect: 基本激活检测" {
  let brain_data : Array[Array[Double]] = []
  brain_data.push([1.0, 1.0, 1.0, 1.0])
  brain_data.push([2.0, 2.0, 2.0, 2.0])
  brain_data.push([1.0, 1.0, 1.0, 1.0])
  brain_data.push([2.0, 2.0, 2.0, 2.0])
  let stimulus = [0, 1, 0, 1]
  let result = @cv_advanced.functional_fmri_detect(brain_data, stimulus, 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.activation.length(), 4)
  for i in 0..<4 {
    assert_true(result.activation[i] > 0.0)
  }
}

///|
test "functional_fmri_detect: 无激活" {
  let brain_data : Array[Array[Double]] = []
  brain_data.push([1.0, 1.0, 1.0, 1.0])
  brain_data.push([1.0, 1.0, 1.0, 1.0])
  let stimulus = [0, 1]
  let result = @cv_advanced.functional_fmri_detect(brain_data, stimulus, 2, 2)
  for i in 0..<4 {
    assert_true(result.activation[i] < 0.001 && result.activation[i] > -0.001)
  }
}

///|
test "functional_pet_suv: 基本计算" {
  let pet = [100.0, 200.0, 300.0, 400.0]
  let suv = @cv_advanced.functional_pet_suv(pet, 10.0, 70.0)
  assert_eq(suv.length(), 4)
  assert_true(suv[0] > 0.0)
}

///|
test "functional_pet_suv: 零剂量" {
  let pet = [100.0, 200.0]
  let suv = @cv_advanced.functional_pet_suv(pet, 0.0, 70.0)
  assert_eq(suv[0], 100.0)
  assert_eq(suv[1], 200.0)
}

///|
test "functional_pet_metabolic_rate: 基本计算" {
  let suv = [2.0, 3.0, 4.0]
  let mr = @cv_advanced.functional_pet_metabolic_rate(suv, 0.5, 5.0)
  assert_true(mr > 0.0)
}

///|
test "functional_pet_metabolic_rate: 零常数" {
  let suv = [2.0, 3.0]
  let mr = @cv_advanced.functional_pet_metabolic_rate(suv, 0.0, 5.0)
  assert_eq(mr, 0.0)
}

///|
test "functional_perfusion_params: 基本计算" {
  let signal = [100.0, 90.0, 80.0, 90.0, 100.0]
  let times = [0.0, 1.0, 2.0, 3.0, 4.0]
  let aif = [0.0, 50.0, 100.0, 50.0, 0.0]
  let (cbf, cbv, _mtt) = @cv_advanced.functional_perfusion_params(
    signal, times, aif,
  )
  assert_true(cbf >= 0.0)
  assert_true(cbv >= 0.0)
}

///|
test "functional_diffusion_adc: 基本计算" {
  let images : Array[Array[Double]] = []
  images.push([100.0, 100.0])
  images.push([50.0, 50.0])
  let b_values = [0.0, 1000.0]
  let adc = @cv_advanced.functional_diffusion_adc(images, b_values)
  assert_eq(adc.length(), 2)
  for i in 0..<2 {
    assert_true(adc[i] >= 0.0)
  }
}

///|
test "functional_build_pet_params: 构建参数" {
  let suv = [2.0, 3.0, 4.0]
  let params = @cv_advanced.functional_build_pet_params(
    suv, 10.0, 70.0, 0.5, 5.0,
  )
  assert_eq(params.suv.length(), 3)
  assert_eq(params.injection_dose, 10.0)
  assert_eq(params.patient_weight, 70.0)
  assert_true(params.metabolic_rate > 0.0)
}
