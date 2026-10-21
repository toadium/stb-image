// MRI 处理 — K空间/伪影校正/分割
// MRI processing
//
// Phase 14 v348: 医学影像大扩展 — MRI 处理。

///|
/// MRI 脉冲序列类型。
/// MRI pulse sequence type.
pub(all) enum MRIPulseType {
  SpinEcho
  GradientEcho
  InversionRecovery
  EPI
} derive(Eq, @debug.Debug)

///|
pub extend MRIPulseType with @debug.Debug::{to_repr}

///|
pub extend MRIPulseType with Eq::{not_equal, equal}

///|
/// K 空间数据。
/// K-space data.
pub(all) struct KSpaceData {
  data_real : Array[Double]
  data_imag : Array[Double]
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend KSpaceData with @debug.Debug::{to_repr}

///|
pub extend KSpaceData with Eq::{not_equal, equal}

///|
/// MRI 配置。
/// MRI configuration.
pub(all) struct MRIConfig {
  field_strength : Double
  te : Double
  tr : Double
  pulse_type : MRIPulseType
} derive(Eq, @debug.Debug)

///|
pub extend MRIConfig with @debug.Debug::{to_repr}

///|
pub extend MRIConfig with Eq::{not_equal, equal}

///|
/// K 空间转图像（简化 IFFT）。
/// K-space to image (simplified IFFT).
pub fn mri_kspace_to_image(kspace : KSpaceData) -> Array[Double] {
  let n = kspace.width * kspace.height
  let result : Array[Double] = []
  for i in 0..<n {
    let real = if i < kspace.data_real.length() {
      kspace.data_real[i]
    } else {
      0.0
    }
    let imag = if i < kspace.data_imag.length() {
      kspace.data_imag[i]
    } else {
      0.0
    }
    result.push((real * real + imag * imag).sqrt())
  }
  result
}

///|
/// 图像转 K 空间（简化 FFT）。
/// Image to K-space (simplified FFT).
pub fn mri_image_to_kspace(
  image : Array[Double],
  width : Int32,
  height : Int32,
) -> KSpaceData {
  let n = width * height
  let real : Array[Double] = []
  let imag : Array[Double] = []
  for i in 0..<n {
    let val = if i < image.length() { image[i] } else { 0.0 }
    real.push(val)
    imag.push(0.0)
  }
  KSpaceData::{ data_real: real, data_imag: imag, width, height, }
}

///|
/// 偏置场校正。
/// Bias field correction.
pub fn mri_correct_bias_field(
  image : Array[Double],
  bias_field : Array[Double],
  width : Int32,
  height : Int32,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = width * height
  for i in 0..<n {
    let img_val = if i < image.length() { image[i] } else { 0.0 }
    let bias_val = if i < bias_field.length() { bias_field[i] } else { 1.0 }
    if bias_val > 0.0 {
      result.push(img_val / bias_val)
    } else {
      result.push(img_val)
    }
  }
  result
}

///|
/// 伪影校正（鬼影）。
/// Ghosting artifact correction.
pub fn mri_correct_ghosting(
  image : Array[Double],
  width : Int32,
  height : Int32,
  ghost_phase : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  for y in 0..<height {
    for x in 0..<width {
      let idx = y * width + x
      let val = if idx < image.length() { image[idx] } else { 0.0 }
      let correction = @math.cos(ghost_phase * y.to_double())
      result.push(val * correction)
    }
  }
  result
}

///|
/// T1 映射。
/// T1 mapping.
pub fn mri_compute_t1_map(
  images : Array[Array[Double]],
  inversion_times : Array[Double],
) -> Array[Double] {
  let n = if images.length() > 0 { images[0].length() } else { 0 }
  let result : Array[Double] = []
  for i in 0..<n {
    let mut best_t1 = 1000.0
    let mut best_error = 1.7976931348623157e308
    for t1_candidate in [100.0, 300.0, 500.0, 800.0, 1000.0, 1500.0, 2000.0] {
      let mut error = 0.0
      for t_idx in 0..<images.length() {
        let ti = if t_idx < inversion_times.length() {
          inversion_times[t_idx]
        } else {
          0.0
        }
        let predicted = 1.0 - 2.0 * @math.exp(-ti / t1_candidate)
        let actual = if i < images[t_idx].length() {
          images[t_idx][i]
        } else {
          0.0
        }
        let diff = predicted - actual
        error = error + diff * diff
      }
      if error < best_error {
        best_error = error
        best_t1 = t1_candidate
      }
    }
    result.push(best_t1)
  }
  result
}

///|
/// T2 映射。
/// T2 mapping.
pub fn mri_compute_t2_map(
  images : Array[Array[Double]],
  echo_times : Array[Double],
) -> Array[Double] {
  let n = if images.length() > 0 { images[0].length() } else { 0 }
  let result : Array[Double] = []
  for i in 0..<n {
    let mut best_t2 = 100.0
    let mut best_error = 1.7976931348623157e308
    for t2_candidate in [10.0, 30.0, 50.0, 80.0, 100.0, 200.0, 500.0] {
      let mut error = 0.0
      for t_idx in 0..<images.length() {
        let te = if t_idx < echo_times.length() {
          echo_times[t_idx]
        } else {
          0.0
        }
        let predicted = @math.exp(-te / t2_candidate)
        let actual = if i < images[t_idx].length() {
          images[t_idx][i]
        } else {
          0.0
        }
        let diff = predicted - actual
        error = error + diff * diff
      }
      if error < best_error {
        best_error = error
        best_t2 = t2_candidate
      }
    }
    result.push(best_t2)
  }
  result
}
