// 描述子匹配 — BFMatcher/FLANN/KNN
// Descriptor matching: BFMatcher/FLANN/KNN
//
// Phase 12 v317: 大规模扩展 CV 算法库 — 描述子匹配。

///|
/// 单个匹配结果。
/// Single match result.
pub(all) struct DMatch {
  query_idx : Int32
  train_idx : Int32
  distance : Double
} derive(Eq, @debug.Debug)

///|
pub extend DMatch with @debug.Debug::{to_repr}

///|
pub extend DMatch with Eq::{not_equal, equal}

///|
/// 匹配器类型。
/// Matcher kind.
pub(all) enum MatcherKind {
  BruteForce // 暴力匹配
  FlannBased // FLANN 近似匹配
  KNN // K 最近邻匹配
} derive(Eq, @debug.Debug)

///|
pub extend MatcherKind with @debug.Debug::{to_repr}

///|
pub extend MatcherKind with Eq::{not_equal, equal}

///|
/// 暴力匹配二进制描述子（汉明距离）。
/// Brute-force match binary descriptors (Hamming distance).
pub fn bf_match_binary(
  query : Array[BinaryDescriptor],
  train : Array[BinaryDescriptor],
) -> Array[DMatch] {
  let result : Array[DMatch] = []
  for i in 0..<query.length() {
    let mut best_idx = 0
    let mut best_dist = 999999.0
    for j in 0..<train.length() {
      let dist = hamming_distance(query[i], train[j]).to_double()
      if dist < best_dist {
        best_dist = dist
        best_idx = j
      }
    }
    if train.length() > 0 {
      result.push({ query_idx: i, train_idx: best_idx, distance: best_dist, })
    }
  }
  result
}

///|
/// 暴力匹配浮点描述子（欧氏距离）。
/// Brute-force match float descriptors (Euclidean distance).
pub fn bf_match_float(
  query : Array[FloatDescriptor],
  train : Array[FloatDescriptor],
) -> Array[DMatch] {
  let result : Array[DMatch] = []
  for i in 0..<query.length() {
    let mut best_idx = 0
    let mut best_dist = 1000000000000000000.0
    for j in 0..<train.length() {
      let dist = euclidean_distance(query[i], train[j])
      if dist < best_dist {
        best_dist = dist
        best_idx = j
      }
    }
    if train.length() > 0 {
      result.push({ query_idx: i, train_idx: best_idx, distance: best_dist, })
    }
  }
  result
}

///|
/// KNN 匹配二进制描述子。
/// KNN match binary descriptors.
pub fn knn_match_binary(
  query : Array[BinaryDescriptor],
  train : Array[BinaryDescriptor],
  k : Int32,
) -> Array[Array[DMatch]] {
  let result : Array[Array[DMatch]] = []
  for i in 0..<query.length() {
    let matches : Array[DMatch] = []
    for j in 0..<train.length() {
      let dist = hamming_distance(query[i], train[j]).to_double()
      matches.push({ query_idx: i, train_idx: j, distance: dist, })
    }
    let sorted = sort_matches(matches)
    let top : Array[DMatch] = []
    let limit = if k < sorted.length() { k } else { sorted.length() }
    for n in 0..<limit {
      top.push(sorted[n])
    }
    result.push(top)
  }
  result
}

///|
/// KNN 匹配浮点描述子。
/// KNN match float descriptors.
pub fn knn_match_float(
  query : Array[FloatDescriptor],
  train : Array[FloatDescriptor],
  k : Int32,
) -> Array[Array[DMatch]] {
  let result : Array[Array[DMatch]] = []
  for i in 0..<query.length() {
    let matches : Array[DMatch] = []
    for j in 0..<train.length() {
      let dist = euclidean_distance(query[i], train[j])
      matches.push({ query_idx: i, train_idx: j, distance: dist, })
    }
    let sorted = sort_matches(matches)
    let top : Array[DMatch] = []
    let limit = if k < sorted.length() { k } else { sorted.length() }
    for n in 0..<limit {
      top.push(sorted[n])
    }
    result.push(top)
  }
  result
}

///|
/// 按距离排序匹配结果（内部辅助）。
fn sort_matches(matches : Array[DMatch]) -> Array[DMatch] {
  let arr : Array[DMatch] = []
  for m in matches {
    arr.push(m)
  }
  let n = arr.length()
  for i in 0..<(n - 1) {
    let mut min_idx = i
    for j in (i + 1)..<n {
      if arr[j].distance < arr[min_idx].distance {
        min_idx = j
      }
    }
    if min_idx != i {
      let tmp = arr[i]
      arr[i] = arr[min_idx]
      arr[min_idx] = tmp
    }
  }
  arr
}

///|
/// Lowe's Ratio Test 过滤匹配。
/// Lowe's Ratio Test to filter matches.
pub fn ratio_test(
  knn_matches : Array[Array[DMatch]],
  ratio : Double,
) -> Array[DMatch] {
  let result : Array[DMatch] = []
  for matches in knn_matches {
    if matches.length() >= 2 {
      let d1 = matches[0].distance
      let d2 = matches[1].distance
      if d2 > 0.0 && d1 / d2 < ratio {
        result.push(matches[0])
      }
    }
  }
  result
}

///|
/// FLANN 近似匹配（简化版，随机采样最近邻）。
/// FLANN approximate match (simplified, random sampling nearest neighbor).
pub fn flann_match_float(
  query : Array[FloatDescriptor],
  train : Array[FloatDescriptor],
) -> Array[DMatch] {
  let result : Array[DMatch] = []
  let train_len = train.length()
  let sample_step = if train_len > 10 { train_len / 10 } else { 1 }
  for i in 0..<query.length() {
    let mut best_idx = 0
    let mut best_dist = 1000000000000000000.0
    let mut j = 0
    while j < train_len {
      let dist = euclidean_distance(query[i], train[j])
      if dist < best_dist {
        best_dist = dist
        best_idx = j
      }
      j = j + sample_step
    }
    if train_len > 0 {
      result.push({ query_idx: i, train_idx: best_idx, distance: best_dist, })
    }
  }
  result
}

///|
/// 交叉验证匹配（双向匹配）。
/// Cross-validation match (bidirectional).
pub fn cross_validate_match(
  matches1 : Array[DMatch],
  matches2 : Array[DMatch],
) -> Array[DMatch] {
  let result : Array[DMatch] = []
  for m1 in matches1 {
    for m2 in matches2 {
      if m1.query_idx == m2.train_idx && m1.train_idx == m2.query_idx {
        result.push(m1)
      }
    }
  }
  result
}
