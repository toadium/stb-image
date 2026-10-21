// 器官分割 — Atlas/水平集/区域生长
// Organ segmentation
//
// Phase 14 v352: 医学影像大扩展 — 器官分割。

///|
/// 器官类型。
/// Organ type.
pub(all) enum OrganType {
  Heart
  Liver
  Kidney
  Lung
  Brain
  Spleen
  Pancreas
} derive(Eq, @debug.Debug)

///|
pub extend OrganType with @debug.Debug::{to_repr}

///|
pub extend OrganType with Eq::{not_equal, equal}

///|
/// 分割方法。
/// Segmentation method.
pub(all) enum OrganSegMethod {
  AtlasBased
  LevelSet
  RegionGrowing
  GraphCut
  DeepLearning
} derive(Eq, @debug.Debug)

///|
pub extend OrganSegMethod with @debug.Debug::{to_repr}

///|
pub extend OrganSegMethod with Eq::{not_equal, equal}

///|
/// 分割结果。
/// Segmentation result.
pub(all) struct OrganSegResult {
  mask : Array[Int32]
  organ : OrganType
  seg_method : OrganSegMethod
  volume : Int32
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend OrganSegResult with @debug.Debug::{to_repr}

///|
pub extend OrganSegResult with Eq::{not_equal, equal}

///|
/// 区域生长分割。
/// Region growing segmentation.
pub fn organ_region_growing(
  image : Array[Double],
  width : Int32,
  height : Int32,
  seed_x : Int32,
  seed_y : Int32,
  threshold : Double,
) -> Array[Int32] {
  let n = width * height
  let mask : Array[Int32] = []
  for _ in 0..<n {
    mask.push(0)
  }
  let seed_idx = seed_y * width + seed_x
  if seed_idx < 0 || seed_idx >= n {
    return mask
  }
  let seed_val = if seed_idx < image.length() { image[seed_idx] } else { 0.0 }
  mask[seed_idx] = 1
  let queue : Array[Int32] = []
  queue.push(seed_idx)
  let mut head = 0
  while head < queue.length() {
    let idx = queue[head]
    head = head + 1
    let y = idx / width
    let x = idx % width
    for dy in [-1, 0, 1] {
      for dx in [-1, 0, 1] {
        if dy != 0 || dx != 0 {
          let ny = y + dy
          let nx = x + dx
          if ny >= 0 && ny < height && nx >= 0 && nx < width {
            let nidx = ny * width + nx
            if nidx < n && mask[nidx] == 0 {
              let nval = if nidx < image.length() { image[nidx] } else { 0.0 }
              if (nval - seed_val).abs() < threshold {
                mask[nidx] = 1
                queue.push(nidx)
              }
            }
          }
        }
      }
    }
  }
  mask
}

///|
/// 水平集分割（简化）。
/// Level set segmentation (simplified).
pub fn organ_level_set(
  image : Array[Double],
  width : Int32,
  height : Int32,
  iterations : Int32,
  curvature_weight : Double,
) -> Array[Double] {
  let n = width * height
  let phi : Array[Double] = []
  for y in 0..<height {
    for x in 0..<width {
      let cx = width / 2
      let cy = height / 2
      let dx = x - cx
      let dy = y - cy
      let dist = (dx * dx + dy * dy).to_double().sqrt()
      phi.push(dist - width.to_double() / 4.0)
    }
  }
  for _ in 0..<iterations {
    let new_phi : Array[Double] = []
    for y in 0..<height {
      for x in 0..<width {
        let idx = y * width + x
        let cur = phi[idx]
        let left = if x > 0 { phi[idx - 1] } else { cur }
        let right = if x < width - 1 { phi[idx + 1] } else { cur }
        let up = if y > 0 { phi[idx - width] } else { cur }
        let down = if y < height - 1 { phi[idx + width] } else { cur }
        let dxx = right - 2.0 * cur + left
        let dyy = down - 2.0 * cur + up
        let curvature = (dxx + dyy) * 0.25
        let img_val = if idx < image.length() { image[idx] } else { 0.0 }
        let speed = img_val - 0.5
        new_phi.push(cur + 0.1 * speed - curvature_weight * curvature)
      }
    }
    for i in 0..<n {
      phi[i] = new_phi[i]
    }
  }
  phi
}

///|
/// Atlas 配准分割。
/// Atlas-based segmentation.
pub fn organ_atlas_based(
  image : Array[Double],
  atlas : Array[Double],
  atlas_mask : Array[Int32],
  width : Int32,
  height : Int32,
) -> Array[Int32] {
  let result : Array[Int32] = []
  let n = width * height
  for i in 0..<n {
    let img_val = if i < image.length() { image[i] } else { 0.0 }
    let atlas_val = if i < atlas.length() { atlas[i] } else { 0.0 }
    let diff = (img_val - atlas_val).abs()
    let mask_val = if i < atlas_mask.length() { atlas_mask[i] } else { 0 }
    if diff < 0.3 && mask_val > 0 {
      result.push(1)
    } else {
      result.push(0)
    }
  }
  result
}

///|
/// 计算分割体积。
/// Compute segmentation volume.
pub fn organ_compute_volume(mask : Array[Int32]) -> Int32 {
  let mut volume = 0
  for i in 0..<mask.length() {
    if mask[i] > 0 {
      volume = volume + 1
    }
  }
  volume
}

///|
/// 计算戴斯系数。
/// Compute Dice coefficient.
pub fn organ_dice_coefficient(
  mask1 : Array[Int32],
  mask2 : Array[Int32],
) -> Double {
  let mut intersection = 0.0
  let mut sum1 = 0.0
  let mut sum2 = 0.0
  let min_len = if mask1.length() < mask2.length() {
    mask1.length()
  } else {
    mask2.length()
  }
  for i in 0..<min_len {
    if mask1[i] > 0 {
      sum1 = sum1 + 1.0
    }
    if mask2[i] > 0 {
      sum2 = sum2 + 1.0
    }
    if mask1[i] > 0 && mask2[i] > 0 {
      intersection = intersection + 1.0
    }
  }
  if sum1 + sum2 == 0.0 {
    return 0.0
  }
  2.0 * intersection / (sum1 + sum2)
}

///|
/// 形态学开运算。
/// Morphological opening.
pub fn organ_morph_open(
  mask : Array[Int32],
  width : Int32,
  height : Int32,
  radius : Int32,
) -> Array[Int32] {
  let eroded = organ_morph_erode(mask, width, height, radius)
  organ_morph_dilate(eroded, width, height, radius)
}

///|
/// 形态学腐蚀。
/// Morphological erosion.
pub fn organ_morph_erode(
  mask : Array[Int32],
  width : Int32,
  height : Int32,
  radius : Int32,
) -> Array[Int32] {
  let result : Array[Int32] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut all_set = true
      for dy in [-radius, 0, radius] {
        for dx in [-radius, 0, radius] {
          let ny = y + dy
          let nx = x + dx
          if ny >= 0 && ny < height && nx >= 0 && nx < width {
            let nidx = ny * width + nx
            if nidx < mask.length() && mask[nidx] == 0 {
              all_set = false
            }
          } else {
            all_set = false
          }
        }
      }
      result.push(if all_set { 1 } else { 0 })
    }
  }
  result
}

///|
/// 形态学膨胀。
/// Morphological dilation.
pub fn organ_morph_dilate(
  mask : Array[Int32],
  width : Int32,
  height : Int32,
  radius : Int32,
) -> Array[Int32] {
  let result : Array[Int32] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut any_set = false
      for dy in [-radius, 0, radius] {
        for dx in [-radius, 0, radius] {
          let ny = y + dy
          let nx = x + dx
          if ny >= 0 && ny < height && nx >= 0 && nx < width {
            let nidx = ny * width + nx
            if nidx < mask.length() && mask[nidx] > 0 {
              any_set = true
            }
          }
        }
      }
      result.push(if any_set { 1 } else { 0 })
    }
  }
  result
}
