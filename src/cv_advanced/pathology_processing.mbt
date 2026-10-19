// 病理切片处理 — WSI/拼接/染色归一化
// Pathology slide processing
//
// Phase 14 v350: 医学影像大扩展 — 病理切片。

///|
/// 染色类型。
/// Stain type.
pub(all) enum PathologyStain {
  HAndE
  PAS
  MassonTrichrome
  Immunohistochemistry
  Silver
} derive(Eq, @debug.Debug)

///|
pub extend PathologyStain with @debug.Debug::{to_repr}

///|
pub extend PathologyStain with Eq::{not_equal, equal}

///|
/// WSI 配置。
/// WSI configuration.
pub(all) struct WSIConfig {
  tile_size : Int
  overlap : Int
  levels : Int
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend WSIConfig with @debug.Debug::{to_repr}

///|
pub extend WSIConfig with Eq::{not_equal, equal}

///|
/// 染色分离结果。
/// Stain separation result.
pub(all) struct StainSeparation {
  stain1 : Array[Double]
  stain2 : Array[Double]
  width : Int
  height : Int
} derive(Eq, @debug.Debug)

///|
pub extend StainSeparation with @debug.Debug::{to_repr}

///|
pub extend StainSeparation with Eq::{not_equal, equal}

///|
/// WSI 分块提取。
/// WSI tile extraction.
pub fn pathology_wsi_extract_tiles(
  image : Array[Double],
  width : Int,
  height : Int,
  config : WSIConfig,
) -> Array[Array[Double]] {
  let tiles : Array[Array[Double]] = []
  let step = config.tile_size - config.overlap
  let mut y = 0
  while y < height {
    let mut x = 0
    while x < width {
      let tile : Array[Double] = []
      for ty in 0..<config.tile_size {
        for tx in 0..<config.tile_size {
          let src_y = y + ty
          let src_x = x + tx
          if src_y < height && src_x < width {
            let idx = src_y * width + src_x
            tile.push(if idx < image.length() { image[idx] } else { 0.0 })
          } else {
            tile.push(0.0)
          }
        }
      }
      tiles.push(tile)
      x = x + step
    }
    y = y + step
  }
  tiles
}

///|
/// WSI 分块拼接。
/// WSI tile stitching.
pub fn pathology_wsi_stitch_tiles(
  tiles : Array[Array[Double]],
  config : WSIConfig,
) -> Array[Double] {
  let result : Array[Double] = []
  let n = config.width * config.height
  for _ in 0..<n {
    result.push(0.0)
  }
  let step = config.tile_size - config.overlap
  let mut tile_idx = 0
  let mut y = 0
  while y < config.height {
    let mut x = 0
    while x < config.width {
      if tile_idx < tiles.length() {
        let tile = tiles[tile_idx]
        for ty in 0..<config.tile_size {
          for tx in 0..<config.tile_size {
            let dst_y = y + ty
            let dst_x = x + tx
            if dst_y < config.height && dst_x < config.width {
              let dst_idx = dst_y * config.width + dst_x
              let src_idx = ty * config.tile_size + tx
              if dst_idx < result.length() && src_idx < tile.length() {
                result[dst_idx] = tile[src_idx]
              }
            }
          }
        }
      }
      tile_idx = tile_idx + 1
      x = x + step
    }
    y = y + step
  }
  result
}

///|
/// 染色归一化（Macenko 方法简化）。
/// Stain normalization (simplified Macenko method).
pub fn pathology_stain_normalize(
  image : Array[Double],
  width : Int,
  height : Int,
  target_stain : PathologyStain,
) -> Array[Double] {
  let result : Array[Double] = []
  let (target_r, target_g, target_b) = match target_stain {
    HAndE => (0.65, 0.70, 0.29)
    PAS => (0.80, 0.60, 0.40)
    MassonTrichrome => (0.70, 0.80, 0.50)
    Immunohistochemistry => (0.75, 0.65, 0.35)
    Silver => (0.90, 0.85, 0.80)
  }
  let source_r = 0.60
  let source_g = 0.75
  let source_b = 0.35
  let n = width * height
  for i in 0..<n {
    let val = if i < image.length() { image[i] } else { 0.0 }
    let normalized = val * target_r / source_r * 0.33 +
      val * target_g / source_g * 0.33 +
      val * target_b / source_b * 0.34
    result.push(normalized)
  }
  result
}

///|
/// 染色分离（Ruifrok-Johnston 简化）。
/// Stain separation (simplified Ruifrok-Johnston).
pub fn pathology_stain_separation(
  image : Array[Double],
  width : Int,
  height : Int,
) -> StainSeparation {
  let stain1 : Array[Double] = []
  let stain2 : Array[Double] = []
  let n = width * height
  for i in 0..<n {
    let val = if i < image.length() { image[i] } else { 0.0 }
    let s1 = val * 0.65 + val * 0.70 * 0.5
    let s2 = val * 0.29 + val * 0.70 * 0.5
    stain1.push(s1)
    stain2.push(s2)
  }
  StainSeparation::{ stain1, stain2, width, height, }
}

///|
/// 细胞核检测（简化阈值+形态学）。
/// Cell nucleus detection (simplified threshold + morphology).
pub fn pathology_detect_nuclei(
  image : Array[Double],
  width : Int,
  height : Int,
  threshold : Double,
) -> Array[Int] {
  let nuclei_positions : Array[Int] = []
  for y in 1..<(height - 1) {
    for x in 1..<(width - 1) {
      let idx = y * width + x
      let val = if idx < image.length() { image[idx] } else { 0.0 }
      if val < threshold {
        let mut is_local_min = true
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dy != 0 || dx != 0 {
              let nidx = (y + dy) * width + (x + dx)
              let nval = if nidx < image.length() { image[nidx] } else { 1.0 }
              if nval < val {
                is_local_min = false
              }
            }
          }
        }
        if is_local_min {
          nuclei_positions.push(idx)
        }
      }
    }
  }
  nuclei_positions
}

///|
/// 有丝分裂计数。
/// Mitosis counting.
pub fn pathology_count_mitosis(
  nuclei_positions : Array[Int],
  width : Int,
  min_distance : Int,
) -> Int {
  let mut count = 0
  let used : Array[Bool] = []
  for _ in 0..<nuclei_positions.length() {
    used.push(false)
  }
  for i in 0..<nuclei_positions.length() {
    if !used[i] {
      let mut neighbors = 0
      for j in 0..<nuclei_positions.length() {
        if i != j && !used[j] {
          let pos1 = nuclei_positions[i]
          let pos2 = nuclei_positions[j]
          let y1 = pos1 / width
          let x1 = pos1 % width
          let y2 = pos2 / width
          let x2 = pos2 % width
          let dy = y1 - y2
          let dx = x1 - x2
          let dist = (dx * dx + dy * dy).to_double().sqrt().to_int()
          if dist < min_distance {
            neighbors = neighbors + 1
            used[j] = true
          }
        }
      }
      if neighbors >= 2 {
        count = count + 1
      }
      used[i] = true
    }
  }
  count
}

///|
/// 组织分割（简化 K-means）。
/// Tissue segmentation (simplified K-means).
pub fn pathology_segment_tissue(
  image : Array[Double],
  num_clusters : Int,
) -> Array[Int] {
  let result : Array[Int] = []
  let centroids : Array[Double] = []
  for k in 0..<num_clusters {
    centroids.push(k.to_double() / num_clusters.to_double())
  }
  for _ in 0..<10 {
    let new_centroids : Array[Double] = []
    let counts : Array[Int] = []
    for _ in 0..<num_clusters {
      new_centroids.push(0.0)
      counts.push(0)
    }
    for i in 0..<image.length() {
      let val = image[i]
      let mut best_k = 0
      let mut best_dist = 1.7976931348623157e308
      for k in 0..<num_clusters {
        let dist = (val - centroids[k]) * (val - centroids[k])
        if dist < best_dist {
          best_dist = dist
          best_k = k
        }
      }
      new_centroids[best_k] = new_centroids[best_k] + val
      counts[best_k] = counts[best_k] + 1
    }
    for k in 0..<num_clusters {
      if counts[k] > 0 {
        centroids[k] = new_centroids[k] / counts[k].to_double()
      }
    }
  }
  for i in 0..<image.length() {
    let val = image[i]
    let mut best_k = 0
    let mut best_dist = 1.7976931348623157e308
    for k in 0..<num_clusters {
      let dist = (val - centroids[k]) * (val - centroids[k])
      if dist < best_dist {
        best_dist = dist
        best_k = k
      }
    }
    result.push(best_k)
  }
  result
}
