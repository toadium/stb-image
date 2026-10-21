// 运动检测扩展 — 帧差/累积/能量/光流
// Motion detection: frame diff / accumulator / energy / optical flow
//
// Phase 12 v324: 大规模扩展 CV 算法库 — 运动检测。

///|
/// 运动掩码。
/// Motion mask.
pub(all) struct MotionMask {
  width : Int32
  height : Int32
  mask : Array[Bool]
  intensity : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend MotionMask with @debug.Debug::{to_repr}

///|
pub extend MotionMask with Eq::{not_equal, equal}

///|
/// 运动检测参数。
/// Motion detection parameters.
pub(all) struct MotionParams {
  threshold : Double
  min_area : Int32
  blur_size : Int32
  dilate_iter : Int32
} derive(Eq, @debug.Debug)

///|
pub extend MotionParams with @debug.Debug::{to_repr}

///|
pub extend MotionParams with Eq::{not_equal, equal}

///|
/// 运动区域。
/// Motion region.
pub(all) struct MotionRegion {
  x : Int32
  y : Int32
  width : Int32
  height : Int32
  area : Int32
  intensity : Double
} derive(Eq, @debug.Debug)

///|
pub extend MotionRegion with @debug.Debug::{to_repr}

///|
pub extend MotionRegion with Eq::{not_equal, equal}

///|
/// 帧差法运动检测。
/// Frame difference motion detection.
pub fn detect_motion_frame_diff(
  prev : @types.Image,
  curr : @types.Image,
  params : MotionParams,
) -> MotionMask {
  let w = prev.width
  let h = prev.height
  let mask : Array[Bool] = []
  let intensity : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * prev.channels
      let diff = (curr.data[idx].to_int() - prev.data[idx].to_int())
        .abs()
        .to_double()
      intensity.push(diff)
      mask.push(diff > params.threshold)
    }
  }
  { width: w, height: h, mask, intensity, }
}

///|
/// 累积差法运动检测。
/// Accumulator-based motion detection.
pub fn detect_motion_accumulator(
  accumulator : Array[Double],
  curr : @types.Image,
  prev : @types.Image,
  params : MotionParams,
) -> (MotionMask, Array[Double]) {
  let w = prev.width
  let h = prev.height
  let mask : Array[Bool] = []
  let intensity : Array[Double] = []
  let new_acc : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let pix_idx = idx * prev.channels
      let diff = (curr.data[pix_idx].to_int() - prev.data[pix_idx].to_int())
        .abs()
        .to_double()
      let acc_val = if idx < accumulator.length() {
        accumulator[idx] * 0.9 + diff * 0.1
      } else {
        diff
      }
      new_acc.push(acc_val)
      intensity.push(acc_val)
      mask.push(acc_val > params.threshold)
    }
  }
  ({ width: w, height: h, mask, intensity, }, new_acc)
}

///|
/// 计算运动能量。
/// Compute motion energy.
pub fn compute_motion_energy(motion : MotionMask) -> Double {
  let mut total = 0.0
  for e in motion.intensity {
    total = total + e * e
  }
  if motion.intensity.length() > 0 {
    (total / motion.intensity.length().to_double()).sqrt()
  } else {
    0.0
  }
}

///|
/// 运动掩码形态学清理。
/// Motion mask morphology cleanup.
pub fn motion_morphology(motion : MotionMask, iter_count : Int32) -> MotionMask {
  let w = motion.width
  let h = motion.height
  let mut current = motion.mask
  for _ in 0..<iter_count {
    let dilated : Array[Bool] = []
    for y in 0..<h {
      for x in 0..<w {
        let idx = y * w + x
        let mut any = current[idx]
        for d in [-1, 1] {
          let nx = x + d
          let ny = y + d
          if nx >= 0 && nx < w && ny >= 0 && ny < h && current[ny * w + nx] {
            any = true
          }
          if ny >= 0 && ny < h && nx >= 0 && nx < w && current[ny * w + x] {
            any = true
          }
        }
        dilated.push(any)
      }
    }
    current = dilated
  }
  { width: w, height: h, mask: current, intensity: motion.intensity, }
}

///|
/// 从光流幅度检测运动。
/// Detect motion from optical flow magnitude.
pub fn motion_optical_flow(flow : FlowField, threshold : Double) -> MotionMask {
  let w = flow.width
  let h = flow.height
  let mask : Array[Bool] = []
  let intensity : Array[Double] = []
  for i in 0..<(w * h) {
    let mag = (flow.u[i] * flow.u[i] + flow.v[i] * flow.v[i]).sqrt()
    intensity.push(mag)
    mask.push(mag > threshold)
  }
  { width: w, height: h, mask, intensity, }
}

///|
/// 计算区域运动密度。
/// Compute motion density in regions.
pub fn motion_density(
  motion : MotionMask,
  grid_cols : Int32,
  grid_rows : Int32,
) -> Array[Double] {
  let w = motion.width
  let h = motion.height
  let cell_w = w / grid_cols
  let cell_h = h / grid_rows
  let densities : Array[Double] = []
  for gr in 0..<grid_rows {
    for gc in 0..<grid_cols {
      let mut total = 0
      let mut motion_count = 0
      let y0 = gr * cell_h
      let x0 = gc * cell_w
      for y in 0..<cell_h {
        for x in 0..<cell_w {
          let ix = x0 + x
          let iy = y0 + y
          if ix < w && iy < h {
            let idx = iy * w + ix
            total = total + 1
            if motion.mask[idx] {
              motion_count = motion_count + 1
            }
          }
        }
      }
      if total > 0 {
        densities.push(motion_count.to_double() / total.to_double())
      } else {
        densities.push(0.0)
      }
    }
  }
  densities
}

///|
/// 提取运动区域（连通域简化版）。
/// Extract motion regions (simplified connected components).
pub fn extract_motion_regions(
  motion : MotionMask,
  params : MotionParams,
) -> Array[MotionRegion] {
  let w = motion.width
  let h = motion.height
  let regions : Array[MotionRegion] = []
  let visited : Array[Bool] = []
  for _ in 0..<(w * h) {
    visited.push(false)
  }
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if motion.mask[idx] && !visited[idx] {
        let mut area = 0
        let mut min_x = x
        let mut max_x = x
        let mut min_y = y
        let mut max_y = y
        let stack : Array[(Int32, Int32)] = [(x, y)]
        while stack.length() > 0 {
          let (cx, cy) = stack[stack.length() - 1]
          let _ = stack.remove(stack.length() - 1)
          let cidx = cy * w + cx
          if cx < 0 ||
            cx >= w ||
            cy < 0 ||
            cy >= h ||
            visited[cidx] ||
            !motion.mask[cidx] {
            continue
          }
          visited[cidx] = true
          area = area + 1
          if cx < min_x {
            min_x = cx
          }
          if cx > max_x {
            max_x = cx
          }
          if cy < min_y {
            min_y = cy
          }
          if cy > max_y {
            max_y = cy
          }
          stack.push((cx + 1, cy))
          stack.push((cx - 1, cy))
          stack.push((cx, cy + 1))
          stack.push((cx, cy - 1))
        }
        if area >= params.min_area {
          regions.push({
            x: min_x,
            y: min_y,
            width: max_x - min_x + 1,
            height: max_y - min_y + 1,
            area,
            intensity: area.to_double(),
          })
        }
      }
    }
  }
  regions
}
