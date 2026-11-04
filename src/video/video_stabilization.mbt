// 视频稳定 — 轨迹/平滑/裁剪
// Video stabilization: trajectory / smoothing / cropping
//
// Phase 17 v396: 视频处理大扩展 — 视频稳定。

///|
/// 稳定方法。
/// Stabilization method.
pub(all) enum StabilizationMethod {
  MotionModel // 运动模型（平移）
  Affine // 仿射
  Perspective // 透视
} derive(Eq, @debug.Debug)

///|
pub extend StabilizationMethod with @debug.Debug::{to_repr}

///|
pub extend StabilizationMethod with Eq::{not_equal, equal}

///|
/// 平滑方法。
/// Smoothing method.
pub(all) enum TrajectorySmoothing {
  Gaussian // 高斯平滑
  MovingAverage // 移动平均
  MedianFilter // 中值滤波
} derive(Eq, @debug.Debug)

///|
pub extend TrajectorySmoothing with @debug.Debug::{to_repr}

///|
pub extend TrajectorySmoothing with Eq::{not_equal, equal}

///|
/// 轨迹点。
/// Trajectory point.
pub(all) struct TrajectoryPoint {
  x : Double
  y : Double
  frame_index : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TrajectoryPoint with @debug.Debug::{to_repr}

///|
pub extend TrajectoryPoint with Eq::{not_equal, equal}

///|
/// 稳定配置。
/// Stabilization configuration.
pub(all) struct StabilizationConfig {
  stab_method : StabilizationMethod
  smoothing : TrajectorySmoothing
  smoothing_radius : Int32 // 平滑窗口半径
  crop_margin : Double // 裁剪边距 (0.0-0.5)
} derive(Eq, @debug.Debug)

///|
pub extend StabilizationConfig with @debug.Debug::{to_repr}

///|
pub extend StabilizationConfig with Eq::{not_equal, equal}

///|
/// 稳定结果。
/// Stabilization result.
pub(all) struct StabilizationResult {
  frames : Array[@types.Image]
  trajectory : Array[TrajectoryPoint]
  smoothed_trajectory : Array[TrajectoryPoint]
  crop_x : Int32
  crop_y : Int32
  crop_width : Int32
  crop_height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend StabilizationResult with @debug.Debug::{to_repr}

///|
pub extend StabilizationResult with Eq::{not_equal, equal}

///|
/// 默认稳定配置。
/// Default stabilization configuration.
pub fn default_stabilization_config() -> StabilizationConfig {
  {
    stab_method: MotionModel,
    smoothing: Gaussian,
    smoothing_radius: 15,
    crop_margin: 0.1,
  }
}

///|
/// 计算帧间运动轨迹。
/// Compute inter-frame motion trajectory.
pub fn compute_trajectory(
  frames : Array[@types.Image],
) -> Array[TrajectoryPoint] {
  let trajectory : Array[TrajectoryPoint] = []
  let n = frames.length()
  if n == 0 {
    return trajectory
  }
  let mut cumul_x = 0.0
  let mut cumul_y = 0.0
  trajectory.push({ x: 0.0, y: 0.0, frame_index: 0, })
  for i in 1..<n {
    let prev = frames[i - 1]
    let curr = frames[i]
    // 简化：用帧间质心差作为运动
    let (dx, dy) = compute_frame_offset(prev, curr)
    cumul_x = cumul_x + dx
    cumul_y = cumul_y + dy
    trajectory.push({ x: cumul_x, y: cumul_y, frame_index: i, })
  }
  trajectory
}

///|
/// 计算帧间偏移（简化：用质心差）。
/// Compute frame offset (simplified: centroid difference).
fn compute_frame_offset(
  prev : @types.Image,
  curr : @types.Image,
) -> (Double, Double) {
  let w = prev.width
  let h = prev.height
  let ch = prev.channels
  let mut prev_cx = 0.0
  let mut prev_cy = 0.0
  let mut curr_cx = 0.0
  let mut curr_cy = 0.0
  let mut prev_weight = 0.0
  let mut curr_weight = 0.0
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * ch
      let pv = prev.data[idx].to_int().to_double()
      let cv = curr.data[idx].to_int().to_double()
      prev_cx = prev_cx + x.to_double() * pv
      prev_cy = prev_cy + y.to_double() * pv
      curr_cx = curr_cx + x.to_double() * cv
      curr_cy = curr_cy + y.to_double() * cv
      prev_weight = prev_weight + pv
      curr_weight = curr_weight + cv
    }
  }
  if prev_weight > 0.0 && curr_weight > 0.0 {
    (
      curr_cx / curr_weight - prev_cx / prev_weight,
      curr_cy / curr_weight - prev_cy / prev_weight,
    )
  } else {
    (0.0, 0.0)
  }
}

///|
/// 高斯平滑轨迹。
/// Gaussian smoothing of trajectory.
fn gaussian_smooth(
  trajectory : Array[TrajectoryPoint],
  radius : Int32,
) -> Array[TrajectoryPoint] {
  let n = trajectory.length()
  let result : Array[TrajectoryPoint] = []
  for i in 0..<n {
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut weight_sum = 0.0
    for j in -radius..<=radius {
      let idx = i + j
      if idx >= 0 && idx < n {
        let sigma = radius.to_double()
        let w = @math.exp(
          -(j.to_double() * j.to_double()) / (2.0 * sigma * sigma),
        )
        sum_x = sum_x + trajectory[idx].x * w
        sum_y = sum_y + trajectory[idx].y * w
        weight_sum = weight_sum + w
      }
    }
    if weight_sum > 0.0 {
      result.push({
        x: sum_x / weight_sum,
        y: sum_y / weight_sum,
        frame_index: i,
      })
    } else {
      result.push(trajectory[i])
    }
  }
  result
}

///|
/// 移动平均平滑轨迹。
/// Moving average smoothing of trajectory.
fn moving_average_smooth(
  trajectory : Array[TrajectoryPoint],
  radius : Int32,
) -> Array[TrajectoryPoint] {
  let n = trajectory.length()
  let result : Array[TrajectoryPoint] = []
  for i in 0..<n {
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut count = 0.0
    for j in -radius..<=radius {
      let idx = i + j
      if idx >= 0 && idx < n {
        sum_x = sum_x + trajectory[idx].x
        sum_y = sum_y + trajectory[idx].y
        count = count + 1.0
      }
    }
    if count > 0.0 {
      result.push({ x: sum_x / count, y: sum_y / count, frame_index: i, })
    } else {
      result.push(trajectory[i])
    }
  }
  result
}

///|
/// 中值滤波平滑轨迹。
/// Median filter smoothing of trajectory.
fn median_smooth(
  trajectory : Array[TrajectoryPoint],
  radius : Int32,
) -> Array[TrajectoryPoint] {
  let n = trajectory.length()
  let result : Array[TrajectoryPoint] = []
  for i in 0..<n {
    let xs : Array[Double] = []
    let ys : Array[Double] = []
    for j in -radius..<=radius {
      let idx = i + j
      if idx >= 0 && idx < n {
        xs.push(trajectory[idx].x)
        ys.push(trajectory[idx].y)
      }
    }
    xs.sort()
    ys.sort()
    let mid = xs.length() / 2
    result.push({ x: xs[mid], y: ys[mid], frame_index: i, })
  }
  result
}

///|
/// 平滑轨迹。
/// Smooth trajectory.
pub fn smooth_trajectory(
  trajectory : Array[TrajectoryPoint],
  config : StabilizationConfig,
) -> Array[TrajectoryPoint] {
  match config.smoothing {
    Gaussian => gaussian_smooth(trajectory, config.smoothing_radius)
    MovingAverage => moving_average_smooth(trajectory, config.smoothing_radius)
    MedianFilter => median_smooth(trajectory, config.smoothing_radius)
  }
}

///|
/// 平移图像。
/// Translate image by (dx, dy).
fn translate_image(
  img : @types.Image,
  dx : Double,
  dy : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let ix = dx.to_int()
  let iy = dy.to_int()
  for y in 0..<h {
    for x in 0..<w {
      let sx = x - ix
      let sy = y - iy
      for c in 0..<ch {
        if sx >= 0 && sx < w && sy >= 0 && sy < h {
          data.push(img.data[(sy * w + sx) * ch + c])
        } else {
          data.push((0 : Byte))
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 稳定单帧。
/// Stabilize a single frame.
pub fn stabilize_frame(
  img : @types.Image,
  original_point : TrajectoryPoint,
  smoothed_point : TrajectoryPoint,
) -> @types.Image {
  // 补偿 = 原始轨迹 - 平滑轨迹
  let dx = original_point.x - smoothed_point.x
  let dy = original_point.y - smoothed_point.y
  translate_image(img, dx, dy)
}

///|
/// 计算裁剪区域。
/// Compute crop region.
pub fn compute_crop_region(
  width : Int32,
  height : Int32,
  margin : Double,
) -> (Int32, Int32, Int32, Int32) {
  let m = margin.clamp(min=0.0, max=0.5)
  let crop_x = (width.to_double() * m).to_int()
  let crop_y = (height.to_double() * m).to_int()
  let crop_w = width - 2 * crop_x
  let crop_h = height - 2 * crop_y
  (crop_x, crop_y, crop_w, crop_h)
}

///|
/// 裁剪图像到区域。
/// Crop image to region.
fn crop_to_region(
  img : @types.Image,
  x : Int32,
  y : Int32,
  w : Int32,
  h : Int32,
) -> @types.Image {
  let ch = img.channels
  let data : Array[Byte] = []
  for py in 0..<h {
    for px in 0..<w {
      let sx = (x + px).clamp(min=0, max=img.width - 1)
      let sy = (y + py).clamp(min=0, max=img.height - 1)
      for c in 0..<ch {
        data.push(img.data[(sy * img.width + sx) * ch + c])
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 稳定视频序列。
/// Stabilize video sequence.
pub fn stabilize_video_sequence(
  frames : Array[@types.Image],
  config : StabilizationConfig,
) -> StabilizationResult {
  let n = frames.length()
  if n == 0 {
    return {
      frames: [],
      trajectory: [],
      smoothed_trajectory: [],
      crop_x: 0,
      crop_y: 0,
      crop_width: 0,
      crop_height: 0,
    }
  }
  let trajectory = compute_trajectory(frames)
  let smoothed = smooth_trajectory(trajectory, config)
  let stabilized : Array[@types.Image] = []
  for i in 0..<n {
    stabilized.push(stabilize_frame(frames[i], trajectory[i], smoothed[i]))
  }
  let w = frames[0].width
  let h = frames[0].height
  let (crop_x, crop_y, crop_w, crop_h) = compute_crop_region(
    w,
    h,
    config.crop_margin,
  )
  let cropped : Array[@types.Image] = []
  for frame in stabilized {
    cropped.push(crop_to_region(frame, crop_x, crop_y, crop_w, crop_h))
  }
  {
    frames: cropped,
    trajectory,
    smoothed_trajectory: smoothed,
    crop_x,
    crop_y,
    crop_width: crop_w,
    crop_height: crop_h,
  }
}

///|
/// 计算稳定度评分。
/// Compute stabilization quality score.
pub fn stabilization_score(
  original_trajectory : Array[TrajectoryPoint],
  smoothed_trajectory : Array[TrajectoryPoint],
) -> Double {
  let n = original_trajectory.length()
  if n == 0 {
    return 0.0
  }
  let mut total_jitter = 0.0
  for i in 0..<n {
    let dx = original_trajectory[i].x - smoothed_trajectory[i].x
    let dy = original_trajectory[i].y - smoothed_trajectory[i].y
    total_jitter = total_jitter + (dx * dx + dy * dy).sqrt()
  }
  let avg_jitter = total_jitter / n.to_double()
  // 评分 = 100 / (1 + avg_jitter)
  100.0 / (1.0 + avg_jitter)
}
