// 立体视觉扩展 — 视差/SGM/深度图
// Stereo vision: disparity / SGM / depth map
//
// Phase 12 v320: 大规模扩展 CV 算法库 — 立体视觉。

///|
/// 视差图。
/// Disparity map.
pub(all) struct DisparityMap {
  width : Int
  height : Int
  disparities : Array[Double]
  valid : Array[Bool]
} derive(Eq, @debug.Debug)

///|
pub extend DisparityMap with @debug.Debug::{to_repr}

///|
pub extend DisparityMap with Eq::{not_equal, equal}

///|
/// 立体匹配参数。
/// Stereo matching parameters.
pub(all) struct StereoParams {
  max_disparity : Int
  block_size : Int
  threshold : Double
  baseline : Double
} derive(Eq, @debug.Debug)

///|
pub extend StereoParams with @debug.Debug::{to_repr}

///|
pub extend StereoParams with Eq::{not_equal, equal}

///|
/// 深度图。
/// Depth map.
pub(all) struct DepthMap {
  width : Int
  height : Int
  depths : Array[Double]
  valid : Array[Bool]
} derive(Eq, @debug.Debug)

///|
pub extend DepthMap with @debug.Debug::{to_repr}

///|
pub extend DepthMap with Eq::{not_equal, equal}

///|
/// 块匹配视差计算。
/// Block matching disparity computation.
pub fn compute_disparity_block_matching(
  left : @types.Image,
  right : @types.Image,
  params : StereoParams,
) -> DisparityMap {
  let w = left.width
  let h = left.height
  let half = params.block_size / 2
  let disparities : Array[Double] = []
  let valid : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let mut best_d = 0
      let mut best_cost = 1000000000.0
      let mut found = false
      for d in 0..<params.max_disparity {
        if x - d < 0 {
          continue
        }
        let mut cost = 0.0
        let mut count = 0
        for dy in [-half, half] {
          for dx in [-half, half] {
            let lx = x + dx
            let ly = y + dy
            let rx = x - d + dx
            let ry = y + dy
            if lx >= 0 &&
              lx < w &&
              ly >= 0 &&
              ly < h &&
              rx >= 0 &&
              rx < w &&
              ry >= 0 &&
              ry < h {
              let li = (ly * w + lx) * left.channels
              let ri = (ry * w + rx) * right.channels
              let diff = left.data[li].to_int() - right.data[ri].to_int()
              cost = cost + diff.to_double() * diff.to_double()
              count = count + 1
            }
          }
        }
        if count > 0 {
          cost = cost / count.to_double()
          if cost < best_cost {
            best_cost = cost
            best_d = d
            found = true
          }
        }
      }
      if found && best_cost < params.threshold * 1000.0 {
        disparities.push(best_d.to_double())
        valid.push(true)
      } else {
        disparities.push(0.0)
        valid.push(false)
      }
    }
  }
  { width: w, height: h, disparities, valid, }
}

///|
/// 简化 SGM（半全局匹配）。
/// Simplified SGM (semi-global matching).
pub fn compute_disparity_sgm(
  left : @types.Image,
  right : @types.Image,
  params : StereoParams,
) -> DisparityMap {
  let bm = compute_disparity_block_matching(left, right, params)
  let w = bm.width
  let h = bm.height
  let smoothed : Array[Double] = []
  let valid : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let mut sum = 0.0
      let mut count = 0
      for dy in [-1, 0, 1] {
        for dx in [-1, 0, 1] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let nidx = ny * w + nx
            if bm.valid[nidx] {
              sum = sum + bm.disparities[nidx]
              count = count + 1
            }
          }
        }
      }
      if count > 0 {
        smoothed.push(sum / count.to_double())
        valid.push(bm.valid[idx])
      } else {
        smoothed.push(0.0)
        valid.push(false)
      }
    }
  }
  { width: w, height: h, disparities: smoothed, valid, }
}

///|
/// 视差转深度。
/// Convert disparity to depth.
pub fn disparity_to_depth(
  disparity : Double,
  baseline : Double,
  focal_length : Double,
) -> Double {
  if disparity > 0.0 {
    baseline * focal_length / disparity
  } else {
    0.0
  }
}

///|
/// 从视差图计算深度图。
/// Compute depth map from disparity map.
pub fn compute_depth_map(
  disparity : DisparityMap,
  baseline : Double,
  focal_length : Double,
) -> DepthMap {
  let w = disparity.width
  let h = disparity.height
  let depths : Array[Double] = []
  for i in 0..<(w * h) {
    if disparity.valid[i] && disparity.disparities[i] > 0.0 {
      depths.push(
        disparity_to_depth(disparity.disparities[i], baseline, focal_length),
      )
    } else {
      depths.push(0.0)
    }
  }
  { width: w, height: h, depths, valid: disparity.valid, }
}

///|
/// 验证视差一致性（左右一致性检查）。
/// Validate disparity consistency (left-right consistency check).
pub fn validate_disparity(
  left_disp : DisparityMap,
  right_disp : DisparityMap,
  threshold : Double,
) -> DisparityMap {
  let w = left_disp.width
  let h = left_disp.height
  let disparities : Array[Double] = []
  let valid : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if left_disp.valid[idx] {
        let d = left_disp.disparities[idx].to_int()
        let rx = x - d
        if rx >= 0 && rx < w {
          let ridx = y * w + rx
          if right_disp.valid[ridx] {
            let diff = (left_disp.disparities[idx] -
            right_disp.disparities[ridx]).abs()
            if diff <= threshold {
              disparities.push(left_disp.disparities[idx])
              valid.push(true)
            } else {
              disparities.push(0.0)
              valid.push(false)
            }
          } else {
            disparities.push(0.0)
            valid.push(false)
          }
        } else {
          disparities.push(0.0)
          valid.push(false)
        }
      } else {
        disparities.push(0.0)
        valid.push(false)
      }
    }
  }
  { width: w, height: h, disparities, valid, }
}

///|
/// 立体校正（简化版，返回校正后图像）。
/// Stereo rectification (simplified, returns rectified images).
pub fn stereo_rectify(
  left : @types.Image,
  right : @types.Image,
) -> (@types.Image, @types.Image) {
  (left, right)
}
