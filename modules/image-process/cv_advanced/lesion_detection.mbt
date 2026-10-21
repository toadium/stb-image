// 病灶检测 — CAD/假阳性抑制/特征分类
// Lesion detection
//
// Phase 14 v353: 医学影像大扩展 — 病灶检测。

///|
/// 病灶类型。
/// Lesion type.
pub(all) enum LesionType {
  Nodule
  Mass
  Calcification
  Cyst
  Tumor
} derive(Eq, @debug.Debug)

///|
pub extend LesionType with @debug.Debug::{to_repr}

///|
pub extend LesionType with Eq::{not_equal, equal}

///|
/// 病灶候选。
/// Lesion candidate.
pub(all) struct LesionCandidate {
  x : Int32
  y : Int32
  radius : Int32
  score : Double
  lesion_type : LesionType
} derive(Eq, @debug.Debug)

///|
pub extend LesionCandidate with @debug.Debug::{to_repr}

///|
pub extend LesionCandidate with Eq::{not_equal, equal}

///|
/// CAD 检测结果。
/// CAD detection result.
pub(all) struct CADDetectionResult {
  candidates : Array[LesionCandidate]
  num_true_positives : Int32
  num_false_positives : Int32
  sensitivity : Double
} derive(Eq, @debug.Debug)

///|
pub extend CADDetectionResult with @debug.Debug::{to_repr}

///|
pub extend CADDetectionResult with Eq::{not_equal, equal}

///|
/// 候选病灶检测（多尺度局部极值）。
/// Candidate lesion detection (multi-scale local extrema).
pub fn lesion_detect_candidates(
  image : Array[Double],
  width : Int32,
  height : Int32,
  min_radius : Int32,
  max_radius : Int32,
  threshold : Double,
) -> Array[LesionCandidate] {
  let candidates : Array[LesionCandidate] = []
  for y in 1..<(height - 1) {
    for x in 1..<(width - 1) {
      let idx = y * width + x
      let val = if idx < image.length() { image[idx] } else { 0.0 }
      if val > threshold {
        let mut is_local_max = true
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dy != 0 || dx != 0 {
              let nidx = (y + dy) * width + (x + dx)
              let nval = if nidx < image.length() { image[nidx] } else { 0.0 }
              if nval > val {
                is_local_max = false
              }
            }
          }
        }
        if is_local_max {
          let radius = (min_radius + max_radius) / 2
          candidates.push(LesionCandidate::{
            x,
            y,
            radius,
            score: val,
            lesion_type: Nodule,
          })
        }
      }
    }
  }
  candidates
}

///|
/// 假阳性抑制（基于特征评分）。
/// False positive reduction (feature-based scoring).
pub fn lesion_reduce_false_positives(
  candidates : Array[LesionCandidate],
  image : Array[Double],
  width : Int32,
  height : Int32,
  score_threshold : Double,
) -> Array[LesionCandidate] {
  let result : Array[LesionCandidate] = []
  for i in 0..<candidates.length() {
    let candidate = candidates[i]
    let mut feature_score = candidate.score
    let cx = candidate.x
    let cy = candidate.y
    let r = candidate.radius
    let mut edge_count = 0
    let mut total_count = 0
    for dy in [-r, 0, r] {
      for dx in [-r, 0, r] {
        let ny = cy + dy
        let nx = cx + dx
        if ny >= 0 && ny < height && nx >= 0 && nx < width {
          let nidx = ny * width + nx
          if nidx < image.length() {
            total_count = total_count + 1
            if image[nidx] > candidate.score * 0.5 {
              edge_count = edge_count + 1
            }
          }
        }
      }
    }
    if total_count > 0 {
      let compactness = edge_count.to_double() / total_count.to_double()
      feature_score = feature_score * compactness
    }
    if feature_score > score_threshold {
      result.push(LesionCandidate::{
        x: cx,
        y: cy,
        radius: r,
        score: feature_score,
        lesion_type: candidate.lesion_type,
      })
    }
  }
  result
}

///|
/// 计算检测灵敏度。
/// Compute detection sensitivity.
pub fn lesion_compute_sensitivity(
  detected : Array[LesionCandidate],
  ground_truth : Array[LesionCandidate],
  tolerance : Int32,
) -> (Int32, Int32, Double) {
  let mut true_positives = 0
  for i in 0..<detected.length() {
    let d = detected[i]
    let mut matched = false
    for j in 0..<ground_truth.length() {
      let g = ground_truth[j]
      let dx = d.x - g.x
      let dy = d.y - g.y
      if dx * dx + dy * dy <= tolerance * tolerance {
        matched = true
      }
    }
    if matched {
      true_positives = true_positives + 1
    }
  }
  let false_positives = detected.length() - true_positives
  let sensitivity = if ground_truth.length() > 0 {
    true_positives.to_double() / ground_truth.length().to_double()
  } else {
    0.0
  }
  (true_positives, false_positives, sensitivity)
}

///|
/// 非极大值抑制。
/// Non-maximum suppression.
pub fn lesion_nms(
  candidates : Array[LesionCandidate],
  overlap_threshold : Double,
) -> Array[LesionCandidate] {
  let sorted : Array[LesionCandidate] = []
  for i in 0..<candidates.length() {
    sorted.push(candidates[i])
  }
  let n = sorted.length()
  for i in 0..<n {
    for j in 0..<(n - 1 - i) {
      if sorted[j].score < sorted[j + 1].score {
        let tmp = sorted[j]
        sorted[j] = sorted[j + 1]
        sorted[j + 1] = tmp
      }
    }
  }
  let result : Array[LesionCandidate] = []
  let suppressed : Array[Bool] = []
  for _ in 0..<n {
    suppressed.push(false)
  }
  for i in 0..<n {
    if !suppressed[i] {
      result.push(sorted[i])
      for j in 0..<n {
        if i != j && !suppressed[j] {
          let dx = sorted[i].x - sorted[j].x
          let dy = sorted[i].y - sorted[j].y
          let dist = (dx * dx + dy * dy).to_double().sqrt()
          let r_sum = sorted[i].radius + sorted[j].radius
          let overlap = if r_sum > 0 {
            1.0 - dist / r_sum.to_double()
          } else {
            0.0
          }
          if overlap > overlap_threshold {
            suppressed[j] = true
          }
        }
      }
    }
  }
  result
}

///|
/// 构建 CAD 检测结果。
/// Build CAD detection result.
pub fn lesion_build_cad_result(
  candidates : Array[LesionCandidate],
  ground_truth : Array[LesionCandidate],
  tolerance : Int32,
) -> CADDetectionResult {
  let (tp, fp, sens) = lesion_compute_sensitivity(
    candidates, ground_truth, tolerance,
  )
  CADDetectionResult::{
    candidates,
    num_true_positives: tp,
    num_false_positives: fp,
    sensitivity: sens,
  }
}

///|
/// 特征提取（形状/纹理/强度）。
/// Feature extraction (shape/texture/intensity).
pub fn lesion_extract_features(
  image : Array[Double],
  width : Int32,
  height : Int32,
  candidate : LesionCandidate,
) -> Array[Double] {
  let features : Array[Double] = []
  let cx = candidate.x
  let cy = candidate.y
  let r = candidate.radius
  let mut sum = 0.0
  let mut count = 0.0
  let mut min_val = 1.7976931348623157e308
  let mut max_val = -1.7976931348623157e308
  for dy in [-r, 0, r] {
    for dx in [-r, 0, r] {
      let ny = cy + dy
      let nx = cx + dx
      if ny >= 0 && ny < height && nx >= 0 && nx < width {
        let nidx = ny * width + nx
        if nidx < image.length() {
          let val = image[nidx]
          sum = sum + val
          count = count + 1.0
          if val < min_val {
            min_val = val
          }
          if val > max_val {
            max_val = val
          }
        }
      }
    }
  }
  let mean = if count > 0.0 { sum / count } else { 0.0 }
  features.push(mean)
  features.push(min_val)
  features.push(max_val)
  features.push(max_val - min_val)
  features.push(candidate.score)
  features.push(r.to_double())
  features
}
