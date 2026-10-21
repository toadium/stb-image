// 土地覆盖分类 — 监督/非监督分类/精度评估
// Land cover classification
//
// Phase 15 v366: 遥感与地理空间大扩展 — 土地覆盖分类。

///|
/// 分类方法。
/// Classification method.
pub(all) enum ClassMethod {
  MaxLikelihood
  MinDistance
  KMeans
  Isodata
} derive(Eq, @debug.Debug)

///|
pub extend ClassMethod with @debug.Debug::{to_repr}

///|
pub extend ClassMethod with Eq::{not_equal, equal}

///|
/// 训练样本。
/// Training sample.
pub(all) struct TrainingSample {
  class_id : Int32
  features : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend TrainingSample with @debug.Debug::{to_repr}

///|
pub extend TrainingSample with Eq::{not_equal, equal}

///|
/// 分类结果。
/// Classification result.
pub(all) struct ClassificationResult {
  class_map : Array[Array[Int32]]
  num_classes : Int32
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend ClassificationResult with @debug.Debug::{to_repr}

///|
pub extend ClassificationResult with Eq::{not_equal, equal}

///|
/// 计算类均值向量。
/// Compute class mean vectors.
pub fn classify_compute_class_means(
  samples : Array[TrainingSample],
  num_classes : Int32,
) -> Array[Array[Double]] {
  let num_features = if samples.length() > 0 {
    samples[0].features.length()
  } else {
    0
  }
  let means = Array::make(num_classes, [])
  let counts = Array::make(num_classes, 0)
  for c in 0..<num_classes {
    means[c] = Array::make(num_features, 0.0)
  }
  for i in 0..<samples.length() {
    let cid = samples[i].class_id
    if cid >= 0 && cid < num_classes {
      counts[cid] += 1
      for f in 0..<num_features {
        means[cid][f] += samples[i].features[f]
      }
    }
  }
  for c in 0..<num_classes {
    if counts[c] > 0 {
      for f in 0..<num_features {
        means[c][f] = means[c][f] / counts[c].to_double()
      }
    }
  }
  means
}

///|
/// 最小距离分类器。
/// Minimum distance to means classifier.
pub fn classify_min_distance(
  pixel_features : Array[Array[Array[Double]]],
  class_means : Array[Array[Double]],
) -> Array[Array[Int32]] {
  let height = pixel_features.length()
  if height == 0 {
    return []
  }
  let width = pixel_features[0].length()
  let num_classes = class_means.length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let features = pixel_features[row][col]
      let mut best_class = 0
      let mut best_dist = 1.7976931348623157e308
      for c in 0..<num_classes {
        let mut dist = 0.0
        for f in 0..<features.length() {
          let diff = features[f] - class_means[c][f]
          dist += diff * diff
        }
        if dist < best_dist {
          best_dist = dist
          best_class = c
        }
      }
      row_data[col] = best_class
    }
    result[row] = row_data
  }
  result
}

///|
/// 最大似然分类器（简化：使用对角协方差）。
/// Maximum likelihood classifier (simplified: diagonal covariance).
pub fn classify_max_likelihood(
  pixel_features : Array[Array[Array[Double]]],
  class_means : Array[Array[Double]],
  class_variances : Array[Array[Double]],
) -> Array[Array[Int32]] {
  let height = pixel_features.length()
  if height == 0 {
    return []
  }
  let width = pixel_features[0].length()
  let num_classes = class_means.length()
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let features = pixel_features[row][col]
      let mut best_class = 0
      let mut best_score = 1.7976931348623157e308
      for c in 0..<num_classes {
        let mut score = 0.0
        for f in 0..<features.length() {
          let variance = class_variances[c][f]
          if variance > 0.0 {
            let diff = features[f] - class_means[c][f]
            score += diff * diff / variance +
              @math.log2(variance) * 0.6931471805599453
          }
        }
        if score < best_score {
          best_score = score
          best_class = c
        }
      }
      row_data[col] = best_class
    }
    result[row] = row_data
  }
  result
}

///|
/// K-means 非监督分类。
/// K-means unsupervised classification.
pub fn classify_kmeans(
  pixel_features : Array[Array[Array[Double]]],
  num_classes : Int32,
  max_iterations : Int32,
) -> (Array[Array[Int32]], Array[Array[Double]]) {
  let height = pixel_features.length()
  if height == 0 || num_classes <= 0 {
    return ([], [])
  }
  let width = pixel_features[0].length()
  let num_features = pixel_features[0][0].length()
  let mut centers = Array::make(num_classes, [])
  for c in 0..<num_classes {
    let row = c * height / num_classes % height
    let col = c * width / num_classes % width
    centers[c] = Array::make(num_features, 0.0)
    for f in 0..<num_features {
      centers[c][f] = pixel_features[row][col][f]
    }
  }
  let class_map = Array::make(height, [])
  for row in 0..<height {
    class_map[row] = Array::make(width, 0)
  }
  for _ in 0..<max_iterations {
    for row in 0..<height {
      for col in 0..<width {
        let features = pixel_features[row][col]
        let mut best_class = 0
        let mut best_dist = 1.7976931348623157e308
        for c in 0..<num_classes {
          let mut dist = 0.0
          for f in 0..<num_features {
            let diff = features[f] - centers[c][f]
            dist += diff * diff
          }
          if dist < best_dist {
            best_dist = dist
            best_class = c
          }
        }
        class_map[row][col] = best_class
      }
    }
    let new_centers = Array::make(num_classes, [])
    let counts = Array::make(num_classes, 0)
    for c in 0..<num_classes {
      new_centers[c] = Array::make(num_features, 0.0)
    }
    for row in 0..<height {
      for col in 0..<width {
        let c = class_map[row][col]
        counts[c] += 1
        for f in 0..<num_features {
          new_centers[c][f] += pixel_features[row][col][f]
        }
      }
    }
    for c in 0..<num_classes {
      if counts[c] > 0 {
        for f in 0..<num_features {
          new_centers[c][f] = new_centers[c][f] / counts[c].to_double()
        }
      } else {
        for f in 0..<num_features {
          new_centers[c][f] = centers[c][f]
        }
      }
    }
    centers = new_centers
  }
  (class_map, centers)
}

///|
/// ISODATA 非监督分类（简化版）。
/// ISODATA unsupervised classification (simplified).
pub fn classify_isodata(
  pixel_features : Array[Array[Array[Double]]],
  num_classes : Int32,
  max_iterations : Int32,
  min_samples : Int32,
) -> Array[Array[Int32]] {
  let (class_map, _) = classify_kmeans(
    pixel_features, num_classes, max_iterations,
  )
  let height = class_map.length()
  if height == 0 {
    return []
  }
  let width = class_map[0].length()
  let counts = Array::make(num_classes, 0)
  for row in 0..<height {
    for col in 0..<width {
      counts[class_map[row][col]] += 1
    }
  }
  let result = Array::make(height, [])
  for row in 0..<height {
    let row_data = Array::make(width, 0)
    for col in 0..<width {
      let c = class_map[row][col]
      row_data[col] = if counts[c] >= min_samples { c } else { 0 }
    }
    result[row] = row_data
  }
  result
}

///|
/// 构建混淆矩阵。
/// Build confusion matrix.
pub fn classify_confusion_matrix(
  predicted : Array[Array[Int32]],
  ground_truth : Array[Array[Int32]],
  num_classes : Int32,
) -> Array[Array[Int32]] {
  let matrix = Array::make(num_classes, [])
  for i in 0..<num_classes {
    matrix[i] = Array::make(num_classes, 0)
  }
  let height = predicted.length()
  for row in 0..<height {
    for col in 0..<predicted[row].length() {
      let pred = predicted[row][col]
      let truth = ground_truth[row][col]
      if pred >= 0 && pred < num_classes && truth >= 0 && truth < num_classes {
        matrix[truth][pred] += 1
      }
    }
  }
  matrix
}

///|
/// 计算 Kappa 系数。
/// Compute Kappa coefficient.
pub fn classify_kappa(confusion_matrix : Array[Array[Int32]]) -> Double {
  let n = confusion_matrix.length()
  if n == 0 {
    return 0.0
  }
  let mut total = 0
  let mut diagonal = 0
  let row_sums = Array::make(n, 0)
  let col_sums = Array::make(n, 0)
  for i in 0..<n {
    for j in 0..<n {
      let val = confusion_matrix[i][j]
      total += val
      row_sums[i] += val
      col_sums[j] += val
      if i == j {
        diagonal += val
      }
    }
  }
  if total == 0 {
    return 0.0
  }
  let po = diagonal.to_double() / total.to_double()
  let mut pe = 0.0
  for i in 0..<n {
    pe += row_sums[i].to_double() * col_sums[i].to_double()
  }
  pe = pe / (total.to_double() * total.to_double())
  if pe < 1.0 {
    (po - pe) / (1.0 - pe)
  } else {
    1.0
  }
}

///|
/// 计算总体精度。
/// Compute overall accuracy.
pub fn classify_overall_accuracy(
  confusion_matrix : Array[Array[Int32]],
) -> Double {
  let n = confusion_matrix.length()
  if n == 0 {
    return 0.0
  }
  let mut total = 0
  let mut diagonal = 0
  for i in 0..<n {
    for j in 0..<n {
      let val = confusion_matrix[i][j]
      total += val
      if i == j {
        diagonal += val
      }
    }
  }
  if total > 0 {
    diagonal.to_double() / total.to_double()
  } else {
    0.0
  }
}

///|
/// 构建分类结果。
/// Build classification result.
pub fn classify_build_result(
  class_map : Array[Array[Int32]],
  num_classes : Int32,
) -> ClassificationResult {
  let height = class_map.length()
  let width = if height > 0 { class_map[0].length() } else { 0 }
  { class_map, num_classes, width, height, }
}

///|
/// 构建训练样本。
/// Build training sample.
pub fn classify_build_sample(
  class_id : Int32,
  features : Array[Double],
) -> TrainingSample {
  { class_id, features, }
}
