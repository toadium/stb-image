// 放射剂量 — DVH/剂量计算/治疗计划评估
// Radiation dose
//
// Phase 14 v357: 医学影像大扩展 — 放射剂量。

///|
/// DVH 类型。
/// DVH type.
pub(all) enum DVHType {
  Cumulative
  Differential
} derive(Eq, @debug.Debug)

///|
pub extend DVHType with @debug.Debug::{to_repr}

///|
pub extend DVHType with Eq::{not_equal, equal}

///|
/// DVH 结果。
/// DVH result.
pub(all) struct DVHResult {
  dose_bins : Array[Double]
  volume_bins : Array[Double]
  dvh_type : DVHType
  structure_name : String
} derive(Eq, @debug.Debug)

///|
pub extend DVHResult with @debug.Debug::{to_repr}

///|
pub extend DVHResult with Eq::{not_equal, equal}

///|
/// 剂量评估指标。
/// Dose evaluation metrics.
pub(all) struct DoseMetrics {
  d95 : Double
  d50 : Double
  d2 : Double
  mean_dose : Double
  max_dose : Double
  min_dose : Double
} derive(Eq, @debug.Debug)

///|
pub extend DoseMetrics with @debug.Debug::{to_repr}

///|
pub extend DoseMetrics with Eq::{not_equal, equal}

///|
/// 计算 DVH。
/// Compute DVH.
pub fn dose_compute_dvh(
  dose_image : Array[Double],
  structure_mask : Array[Int],
  num_bins : Int,
  max_dose : Double,
  structure_name : String,
) -> DVHResult {
  let dose_bins : Array[Double] = []
  let volume_bins : Array[Double] = []
  let bin_width = max_dose / num_bins.to_double()
  for b in 0..<num_bins {
    dose_bins.push(b.to_double() * bin_width)
  }
  let mut total_volume = 0.0
  for i in 0..<dose_image.length() {
    if i < structure_mask.length() && structure_mask[i] > 0 {
      total_volume = total_volume + 1.0
    }
  }
  for b in 0..<num_bins {
    let threshold = b.to_double() * bin_width
    let mut count = 0.0
    for i in 0..<dose_image.length() {
      if i < structure_mask.length() && structure_mask[i] > 0 {
        if dose_image[i] >= threshold {
          count = count + 1.0
        }
      }
    }
    let vol_pct = if total_volume > 0.0 {
      count / total_volume * 100.0
    } else {
      0.0
    }
    volume_bins.push(vol_pct)
  }
  DVHResult::{ dose_bins, volume_bins, dvh_type: Cumulative, structure_name, }
}

///|
/// 计算剂量评估指标。
/// Compute dose evaluation metrics.
pub fn dose_compute_metrics(
  dose_image : Array[Double],
  structure_mask : Array[Int],
) -> DoseMetrics {
  let doses : Array[Double] = []
  for i in 0..<dose_image.length() {
    if i < structure_mask.length() && structure_mask[i] > 0 {
      doses.push(dose_image[i])
    }
  }
  if doses.length() == 0 {
    return DoseMetrics::{
      d95: 0.0,
      d50: 0.0,
      d2: 0.0,
      mean_dose: 0.0,
      max_dose: 0.0,
      min_dose: 0.0,
    }
  }
  let sorted : Array[Double] = []
  for d in doses {
    sorted.push(d)
  }
  let n = sorted.length()
  for i in 0..<n {
    for j in 0..<(n - 1 - i) {
      if sorted[j] > sorted[j + 1] {
        let tmp = sorted[j]
        sorted[j] = sorted[j + 1]
        sorted[j + 1] = tmp
      }
    }
  }
  let d95_idx = (n.to_double() * 0.05).to_int()
  let d50_idx = (n.to_double() * 0.5).to_int()
  let d2_idx = (n.to_double() * 0.98).to_int()
  let d95 = sorted[d95_idx]
  let d50 = sorted[d50_idx]
  let d2 = sorted[d2_idx]
  let mut sum = 0.0
  for d in sorted {
    sum = sum + d
  }
  let mean = sum / n.to_double()
  DoseMetrics::{
    d95,
    d50,
    d2,
    mean_dose: mean,
    max_dose: sorted[n - 1],
    min_dose: sorted[0],
  }
}

///|
/// EUD 计算（等效均匀剂量）。
/// EUD computation (equivalent uniform dose).
pub fn dose_compute_eud(
  dose_image : Array[Double],
  structure_mask : Array[Int],
  n_param : Double,
) -> Double {
  let mut sum = 0.0
  let mut count = 0.0
  for i in 0..<dose_image.length() {
    if i < structure_mask.length() && structure_mask[i] > 0 {
      sum = sum + @math.pow(dose_image[i], n_param)
      count = count + 1.0
    }
  }
  if count == 0.0 {
    return 0.0
  }
  @math.pow(sum / count, 1.0 / n_param)
}

///|
/// TCP 计算（肿瘤控制概率）。
/// TCP computation (tumor control probability).
pub fn dose_compute_tcp(
  dose_image : Array[Double],
  structure_mask : Array[Int],
  d50 : Double,
  gamma : Double,
) -> Double {
  let metrics = dose_compute_metrics(dose_image, structure_mask)
  let mean_dose = metrics.mean_dose
  if d50 > 0.0 {
    1.0 / (1.0 + @math.pow(d50 / mean_dose, gamma))
  } else {
    0.0
  }
}

///|
/// NTCP 计算（正常组织并发症概率）。
/// NTCP computation (normal tissue complication probability).
pub fn dose_compute_ntcp(
  dose_image : Array[Double],
  structure_mask : Array[Int],
  td50 : Double,
  m_param : Double,
) -> Double {
  let metrics = dose_compute_metrics(dose_image, structure_mask)
  let mean_dose = metrics.mean_dose
  if td50 > 0.0 {
    let t = (mean_dose - td50) / (m_param * td50)
    0.5 * (1.0 + erf_approx(t))
  } else {
    0.0
  }
}

///|
/// 误差函数近似。
/// Error function approximation.
pub fn erf_approx(x : Double) -> Double {
  let a1 = 0.254829592
  let a2 = -0.284496736
  let a3 = 1.421413741
  let a4 = -1.453152027
  let a5 = 1.061405429
  let p = 0.3275911
  let sign = if x < 0.0 { -1.0 } else { 1.0 }
  let abs_x = x.abs()
  let t = 1.0 / (1.0 + p * abs_x)
  let y = 1.0 -
    ((((a5 * t + a4) * t + a3) * t + a2) * t + a1) *
    t *
    @math.exp(-abs_x * abs_x)
  sign * y
}

///|
/// 治疗计划评估。
/// Treatment plan evaluation.
pub fn dose_evaluate_plan(
  target_dose : Array[Double],
  target_mask : Array[Int],
  oar_doses : Array[Array[Double]],
  oar_masks : Array[Array[Int]],
  prescription_dose : Double,
) -> (Double, Double, Double) {
  let target_metrics = dose_compute_metrics(target_dose, target_mask)
  let target_coverage = if prescription_dose > 0.0 {
    target_metrics.d95 / prescription_dose
  } else {
    0.0
  }
  let mut max_oar_dose = 0.0
  let mut mean_oar_dose = 0.0
  let mut oar_count = 0.0
  for i in 0..<oar_doses.length() {
    if i < oar_masks.length() {
      let oar_metrics = dose_compute_metrics(oar_doses[i], oar_masks[i])
      if oar_metrics.max_dose > max_oar_dose {
        max_oar_dose = oar_metrics.max_dose
      }
      mean_oar_dose = mean_oar_dose + oar_metrics.mean_dose
      oar_count = oar_count + 1.0
    }
  }
  if oar_count > 0.0 {
    mean_oar_dose = mean_oar_dose / oar_count
  }
  let conformality = if max_oar_dose > 0.0 {
    prescription_dose / max_oar_dose
  } else {
    0.0
  }
  (target_coverage, conformality, mean_oar_dose)
}
