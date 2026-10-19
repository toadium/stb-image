// 功能成像 — fMRI/PET/功能参数
// Functional imaging
//
// Phase 14 v355: 医学影像大扩展 — 功能成像。

///|
/// 功能成像类型。
/// Functional imaging type.
pub(all) enum FunctionalImagingType {
  FMRI
  PET
  SPECT
  Perfusion
  Diffusion
} derive(Eq, @debug.Debug)

///|
pub extend FunctionalImagingType with @debug.Debug::{to_repr}

///|
pub extend FunctionalImagingType with Eq::{not_equal, equal}

///|
/// fMRI 激活图。
/// fMRI activation map.
pub(all) struct FMRIActivation {
  activation : Array[Double]
  t_values : Array[Double]
  p_values : Array[Double]
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend FMRIActivation with @debug.Debug::{to_repr}

///|
pub extend FMRIActivation with Eq::{not_equal, equal}

///|
/// PET 参数。
/// PET parameters.
pub(all) struct PETParams {
  suv : Array[Double]
  metabolic_rate : Double
  injection_dose : Double
  patient_weight : Double
} derive(Eq, @debug.Debug)

///|
pub extend PETParams with @debug.Debug::{to_repr}

///|
pub extend PETParams with Eq::{not_equal, equal}

///|
/// fMRI 激活检测（简化 t 检验）。
/// fMRI activation detection (simplified t-test).
pub fn functional_fmri_detect(
  brain_data : Array[Array[Double]],
  stimulus_pattern : Array[Int],
  width : Int,
  height : Int,
) -> FMRIActivation {
  let n = width * height
  let activation : Array[Double] = []
  let t_values : Array[Double] = []
  let p_values : Array[Double] = []
  let num_active = stimulus_pattern.length()
  let mut active_count = 0
  let mut rest_count = 0
  for i in 0..<num_active {
    if stimulus_pattern[i] > 0 {
      active_count = active_count + 1
    } else {
      rest_count = rest_count + 1
    }
  }
  for voxel in 0..<n {
    let mut active_sum = 0.0
    let mut rest_sum = 0.0
    for t in 0..<num_active {
      let val = if t < brain_data.length() && voxel < brain_data[t].length() {
        brain_data[t][voxel]
      } else {
        0.0
      }
      if stimulus_pattern[t] > 0 {
        active_sum = active_sum + val
      } else {
        rest_sum = rest_sum + val
      }
    }
    let active_mean = if active_count > 0 {
      active_sum / active_count.to_double()
    } else {
      0.0
    }
    let rest_mean = if rest_count > 0 {
      rest_sum / rest_count.to_double()
    } else {
      0.0
    }
    let diff = active_mean - rest_mean
    activation.push(diff)
    let t_val = diff * 10.0
    t_values.push(t_val)
    let p_val = if t_val.abs() > 2.0 { 0.05 } else { 0.5 }
    p_values.push(p_val)
  }
  FMRIActivation::{ activation, t_values, p_values, width, height, }
}

///|
/// PET SUV 计算。
/// PET SUV computation.
pub fn functional_pet_suv(
  pet_image : Array[Double],
  injection_dose : Double,
  patient_weight : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  let factor = if injection_dose > 0.0 {
    patient_weight / injection_dose
  } else {
    1.0
  }
  for i in 0..<pet_image.length() {
    result.push(pet_image[i] * factor)
  }
  result
}

///|
/// PET 代谢率计算。
/// PET metabolic rate computation.
pub fn functional_pet_metabolic_rate(
  suv_values : Array[Double],
  lumped_constant : Double,
  plasma_glucose : Double,
) -> Double {
  let mut sum = 0.0
  for i in 0..<suv_values.length() {
    sum = sum + suv_values[i]
  }
  let mean_suv = if suv_values.length() > 0 {
    sum / suv_values.length().to_double()
  } else {
    0.0
  }
  if lumped_constant > 0.0 {
    mean_suv * plasma_glucose / lumped_constant
  } else {
    0.0
  }
}

///|
/// 灌注参数计算（CBF/CBV/MTT）。
/// Perfusion parameter computation (CBF/CBV/MTT).
pub fn functional_perfusion_params(
  time_signal : Array[Double],
  time_points : Array[Double],
  arterial_input : Array[Double],
) -> (Double, Double, Double) {
  let mut cbf = 0.0
  let mut cbv = 0.0
  let mut max_signal = 0.0
  let mut min_signal = 1.7976931348623157e308
  for i in 0..<time_signal.length() {
    if time_signal[i] > max_signal {
      max_signal = time_signal[i]
    }
    if time_signal[i] < min_signal {
      min_signal = time_signal[i]
    }
  }
  let mut aif_max = 0.0
  for i in 0..<arterial_input.length() {
    if arterial_input[i] > aif_max {
      aif_max = arterial_input[i]
    }
  }
  if aif_max > 0.0 {
    cbf = (max_signal - min_signal) / aif_max * 100.0
  }
  let mut area = 0.0
  for i in 0..<time_signal.length() {
    area = area + time_signal[i]
  }
  cbv = area * 0.01
  let mtt = if cbf > 0.0 { cbv / cbf * 60.0 } else { 0.0 }
  let _ = time_points
  (cbf, cbv, mtt)
}

///|
/// 弥散张量计算（简化 ADC）。
/// Diffusion tensor computation (simplified ADC).
pub fn functional_diffusion_adc(
  images : Array[Array[Double]],
  b_values : Array[Double],
) -> Array[Double] {
  let n = if images.length() > 0 { images[0].length() } else { 0 }
  let result : Array[Double] = []
  for voxel in 0..<n {
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut sum_xy = 0.0
    let mut sum_xx = 0.0
    let count = b_values.length()
    for i in 0..<count {
      let b = b_values[i]
      let s = if i < images.length() && voxel < images[i].length() {
        if images[i][voxel] > 0.0 {
          @math.log2(images[i][voxel])
        } else {
          0.0
        }
      } else {
        0.0
      }
      sum_x = sum_x + b
      sum_y = sum_y + s
      sum_xy = sum_xy + b * s
      sum_xx = sum_xx + b * b
    }
    let denom = count.to_double() * sum_xx - sum_x * sum_x
    let adc = if denom != 0.0 {
      (count.to_double() * sum_xy - sum_x * sum_y) / denom
    } else {
      0.0
    }
    result.push(-adc)
  }
  result
}

///|
/// 构建 PET 参数。
/// Build PET parameters.
pub fn functional_build_pet_params(
  suv : Array[Double],
  injection_dose : Double,
  patient_weight : Double,
  lumped_constant : Double,
  plasma_glucose : Double,
) -> PETParams {
  let mr = functional_pet_metabolic_rate(suv, lumped_constant, plasma_glucose)
  PETParams::{ suv, metabolic_rate: mr, injection_dose, patient_weight, }
}
