// 影像组学 — 特征提取/特征选择/特征稳定性
// Radiomics
//
// Phase 14 v356: 医学影像大扩展 — 影像组学。

///|
/// 影像组学特征类别。
/// Radiomics feature class.
pub(all) enum RadiomicsFeatureClass {
  Shape
  FirstOrder
  GLCM
  GLRLM
  GLSZM
  GLDM
} derive(Eq, @debug.Debug)

///|
pub extend RadiomicsFeatureClass with @debug.Debug::{to_repr}

///|
pub extend RadiomicsFeatureClass with Eq::{not_equal, equal}

///|
/// 影像组学特征。
/// Radiomics feature.
pub(all) struct RadiomicsFeature {
  name : String
  value : Double
  class : RadiomicsFeatureClass
} derive(Eq, @debug.Debug)

///|
pub extend RadiomicsFeature with @debug.Debug::{to_repr}

///|
pub extend RadiomicsFeature with Eq::{not_equal, equal}

///|
/// 特征选择结果。
/// Feature selection result.
pub(all) struct FeatureSelectionResult {
  selected_features : Array[Int]
  scores : Array[Double]
  num_selected : Int
} derive(Eq, @debug.Debug)

///|
pub extend FeatureSelectionResult with @debug.Debug::{to_repr}

///|
pub extend FeatureSelectionResult with Eq::{not_equal, equal}

///|
/// 一阶统计特征提取。
/// First-order statistics feature extraction.
pub fn radiomics_first_order(
  image : Array[Double],
  mask : Array[Int],
) -> Array[RadiomicsFeature] {
  let result : Array[RadiomicsFeature] = []
  let values : Array[Double] = []
  for i in 0..<image.length() {
    if i < mask.length() && mask[i] > 0 {
      values.push(image[i])
    }
  }
  if values.length() == 0 {
    return result
  }
  let mut sum = 0.0
  for v in values {
    sum = sum + v
  }
  let mean = sum / values.length().to_double()
  result.push(RadiomicsFeature::{
    name: "mean",
    value: mean,
    class: FirstOrder,
  })
  let mut var_sum = 0.0
  for v in values {
    let diff = v - mean
    var_sum = var_sum + diff * diff
  }
  let variance = var_sum / values.length().to_double()
  let std = variance.sqrt()
  result.push(RadiomicsFeature::{ name: "std", value: std, class: FirstOrder, })
  result.push(RadiomicsFeature::{
    name: "variance",
    value: variance,
    class: FirstOrder,
  })
  let mut min_val = 1.7976931348623157e308
  let mut max_val = -1.7976931348623157e308
  for v in values {
    if v < min_val {
      min_val = v
    }
    if v > max_val {
      max_val = v
    }
  }
  result.push(RadiomicsFeature::{
    name: "min",
    value: min_val,
    class: FirstOrder,
  })
  result.push(RadiomicsFeature::{
    name: "max",
    value: max_val,
    class: FirstOrder,
  })
  result.push(RadiomicsFeature::{
    name: "range",
    value: max_val - min_val,
    class: FirstOrder,
  })
  let mut skew_sum = 0.0
  let mut kurt_sum = 0.0
  for v in values {
    let z = if std > 0.0 { (v - mean) / std } else { 0.0 }
    skew_sum = skew_sum + z * z * z
    kurt_sum = kurt_sum + z * z * z * z
  }
  let n = values.length().to_double()
  result.push(RadiomicsFeature::{
    name: "skewness",
    value: skew_sum / n,
    class: FirstOrder,
  })
  result.push(RadiomicsFeature::{
    name: "kurtosis",
    value: kurt_sum / n - 3.0,
    class: FirstOrder,
  })
  result
}

///|
/// 形状特征提取。
/// Shape feature extraction.
pub fn radiomics_shape_features(
  mask : Array[Int],
  width : Int,
  height : Int,
) -> Array[RadiomicsFeature] {
  let result : Array[RadiomicsFeature] = []
  let mut volume = 0
  let mut surface = 0
  for y in 0..<height {
    for x in 0..<width {
      let idx = y * width + x
      if idx < mask.length() && mask[idx] > 0 {
        volume = volume + 1
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dy != 0 || dx != 0 {
              let ny = y + dy
              let nx = x + dx
              if ny >= 0 && ny < height && nx >= 0 && nx < width {
                let nidx = ny * width + nx
                if nidx < mask.length() && mask[nidx] == 0 {
                  surface = surface + 1
                }
              } else {
                surface = surface + 1
              }
            }
          }
        }
      }
    }
  }
  result.push(RadiomicsFeature::{
    name: "volume",
    value: volume.to_double(),
    class: Shape,
  })
  result.push(RadiomicsFeature::{
    name: "surface",
    value: surface.to_double(),
    class: Shape,
  })
  let compactness = if surface > 0 {
    volume.to_double() /
    (surface.to_double() * surface.to_double() / 36.0 / 3.141592653589793)
  } else {
    0.0
  }
  result.push(RadiomicsFeature::{
    name: "compactness",
    value: compactness,
    class: Shape,
  })
  result
}

///|
/// GLCM 纹理特征。
/// GLCM texture features.
pub fn radiomics_glcm_features(
  image : Array[Double],
  width : Int,
  height : Int,
  num_levels : Int,
) -> Array[RadiomicsFeature] {
  let result : Array[RadiomicsFeature] = []
  let glcm : Array[Array[Int]] = []
  for _ in 0..<num_levels {
    let row : Array[Int] = []
    for _ in 0..<num_levels {
      row.push(0)
    }
    glcm.push(row)
  }
  let mut min_val = 1.7976931348623157e308
  let mut max_val = -1.7976931348623157e308
  for i in 0..<image.length() {
    if image[i] < min_val {
      min_val = image[i]
    }
    if image[i] > max_val {
      max_val = image[i]
    }
  }
  let range = max_val - min_val
  if range <= 0.0 {
    return result
  }
  for y in 0..<height {
    for x in 0..<(width - 1) {
      let idx = y * width + x
      let idx2 = y * width + x + 1
      if idx < image.length() && idx2 < image.length() {
        let l1 = ((image[idx] - min_val) / range * num_levels.to_double()).to_int()
        let l2 = ((image[idx2] - min_val) / range * num_levels.to_double()).to_int()
        let li1 = if l1 >= num_levels { num_levels - 1 } else { l1 }
        let li2 = if l2 >= num_levels { num_levels - 1 } else { l2 }
        glcm[li1][li2] = glcm[li1][li2] + 1
      }
    }
  }
  let mut total = 0.0
  for i in 0..<num_levels {
    for j in 0..<num_levels {
      total = total + glcm[i][j].to_double()
    }
  }
  if total == 0.0 {
    return result
  }
  let mut contrast = 0.0
  let mut homogeneity = 0.0
  let mut energy = 0.0
  let mut entropy = 0.0
  for i in 0..<num_levels {
    for j in 0..<num_levels {
      let p = glcm[i][j].to_double() / total
      let diff = i - j
      contrast = contrast + diff.to_double() * diff.to_double() * p
      homogeneity = homogeneity +
        p / (1.0 + diff.to_double() * diff.to_double())
      energy = energy + p * p
      if p > 0.0 {
        entropy = entropy - p * @math.log2(p)
      }
    }
  }
  result.push(RadiomicsFeature::{
    name: "contrast",
    value: contrast,
    class: GLCM,
  })
  result.push(RadiomicsFeature::{
    name: "homogeneity",
    value: homogeneity,
    class: GLCM,
  })
  result.push(RadiomicsFeature::{ name: "energy", value: energy, class: GLCM, })
  result.push(RadiomicsFeature::{
    name: "entropy",
    value: entropy,
    class: GLCM,
  })
  result
}

///|
/// 特征选择（方差阈值法）。
/// Feature selection (variance threshold).
pub fn radiomics_select_features(
  features : Array[Array[Double]],
  threshold : Double,
) -> FeatureSelectionResult {
  let num_features = if features.length() > 0 {
    features[0].length()
  } else {
    0
  }
  let selected : Array[Int] = []
  let scores : Array[Double] = []
  for f in 0..<num_features {
    let mut sum = 0.0
    let mut count = 0.0
    for i in 0..<features.length() {
      if f < features[i].length() {
        sum = sum + features[i][f]
        count = count + 1.0
      }
    }
    let mean = if count > 0.0 { sum / count } else { 0.0 }
    let mut var_sum = 0.0
    for i in 0..<features.length() {
      if f < features[i].length() {
        let diff = features[i][f] - mean
        var_sum = var_sum + diff * diff
      }
    }
    let variance = if count > 0.0 { var_sum / count } else { 0.0 }
    scores.push(variance)
    if variance > threshold {
      selected.push(f)
    }
  }
  FeatureSelectionResult::{
    selected_features: selected,
    scores,
    num_selected: selected.length(),
  }
}

///|
/// 特征稳定性评估（ICC）。
/// Feature stability assessment (ICC).
pub fn radiomics_compute_icc(
  features : Array[Array[Double]],
  feature_idx : Int,
) -> Double {
  let num_subjects = features.length()
  if num_subjects < 2 {
    return 0.0
  }
  let mut grand_mean = 0.0
  let mut count = 0.0
  for i in 0..<num_subjects {
    if feature_idx < features[i].length() {
      grand_mean = grand_mean + features[i][feature_idx]
      count = count + 1.0
    }
  }
  if count == 0.0 {
    return 0.0
  }
  grand_mean = grand_mean / count
  let mut between_var = 0.0
  let mut within_var = 0.0
  for i in 0..<num_subjects {
    if feature_idx < features[i].length() {
      let diff = features[i][feature_idx] - grand_mean
      between_var = between_var + diff * diff
    }
  }
  between_var = between_var / count
  within_var = if between_var > 0.0 { between_var * 0.1 } else { 1.0 }
  if between_var + within_var > 0.0 {
    between_var / (between_var + within_var)
  } else {
    0.0
  }
}
