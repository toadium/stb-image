// 视频跟踪 — 多目标/长程/关联
// Video tracking: multi-object / long-term / association
//
// Phase 17 v400: 视频处理大扩展 — 视频跟踪。

///|
/// 跟踪方法。
/// Tracking method.
pub(all) enum MultiTrackingMethod {
  Centroid // 质心跟踪
  KalmanFilter // 卡尔曼滤波
  MeanShift // 均值漂移
} derive(Eq, @debug.Debug)

///|
pub extend MultiTrackingMethod with @debug.Debug::{to_repr}

///|
pub extend MultiTrackingMethod with Eq::{not_equal, equal}

///|
/// 跟踪对象状态。
/// Tracked object state.
pub(all) enum MultiTrackState {
  Active // 活跃
  Lost // 丢失
  Terminated // 终止
} derive(Eq, @debug.Debug)

///|
pub extend MultiTrackState with @debug.Debug::{to_repr}

///|
pub extend MultiTrackState with Eq::{not_equal, equal}

///|
/// 跟踪对象。
/// Tracked object.
pub(all) struct MultiTrackedObject {
  id : Int32
  x : Double // 中心 x
  y : Double // 中心 y
  width : Double
  height : Double
  state : MultiTrackState
  age : Int32 // 存活帧数
  lost_count : Int32 // 连续丢失计数
} derive(Eq, @debug.Debug)

///|
pub extend MultiTrackedObject with @debug.Debug::{to_repr}

///|
pub extend MultiTrackedObject with Eq::{not_equal, equal}

///|
/// 检测对象。
/// Detected object.
pub(all) struct MultiDetectedObject {
  x : Double
  y : Double
  width : Double
  height : Double
  confidence : Double
} derive(Eq, @debug.Debug)

///|
pub extend MultiDetectedObject with @debug.Debug::{to_repr}

///|
pub extend MultiDetectedObject with Eq::{not_equal, equal}

///|
/// 跟踪配置。
/// Tracking configuration.
pub(all) struct MultiTrackingConfig {
  track_method : MultiTrackingMethod
  max_lost_frames : Int32 // 最大丢失帧数
  association_threshold : Double // 关联距离阈值
  min_confidence : Double // 最小检测置信度
} derive(Eq, @debug.Debug)

///|
pub extend MultiTrackingConfig with @debug.Debug::{to_repr}

///|
pub extend MultiTrackingConfig with Eq::{not_equal, equal}

///|
/// 默认跟踪配置。
/// Default tracking configuration.
pub fn default_tracking_config() -> MultiTrackingConfig {
  {
    track_method: Centroid,
    max_lost_frames: 5,
    association_threshold: 50.0,
    min_confidence: 0.5,
  }
}

///|
/// 计算两个对象间的中心距离。
/// Compute centroid distance between two objects.
fn centroid_distance(
  obj1 : MultiTrackedObject,
  obj2 : MultiDetectedObject,
) -> Double {
  let dx = obj1.x - obj2.x
  let dy = obj1.y - obj2.y
  (dx * dx + dy * dy).sqrt()
}

///|
/// 计算 IoU（交并比）。
/// Compute IoU (Intersection over Union).
fn compute_iou(obj1 : MultiTrackedObject, obj2 : MultiDetectedObject) -> Double {
  let x1 = obj1.x - obj1.width / 2.0
  let y1 = obj1.y - obj1.height / 2.0
  let x2 = obj1.x + obj1.width / 2.0
  let y2 = obj1.y + obj1.height / 2.0
  let x3 = obj2.x - obj2.width / 2.0
  let y3 = obj2.y - obj2.height / 2.0
  let x4 = obj2.x + obj2.width / 2.0
  let y4 = obj2.y + obj2.height / 2.0
  let ix1 = if x1 > x3 { x1 } else { x3 }
  let iy1 = if y1 > y3 { y1 } else { y3 }
  let ix2 = if x2 < x4 { x2 } else { x4 }
  let iy2 = if y2 < y4 { y2 } else { y4 }
  let inter_w = ix2 - ix1
  let inter_h = iy2 - iy1
  if inter_w <= 0.0 || inter_h <= 0.0 {
    return 0.0
  }
  let inter = inter_w * inter_h
  let area1 = obj1.width * obj1.height
  let area2 = obj2.width * obj2.height
  let union = area1 + area2 - inter
  if union <= 0.0 {
    return 0.0
  }
  inter / union
}

///|
/// 关联检测对象与跟踪对象。
/// Associate detected objects with tracked objects.
pub fn associate_objects(
  tracked : Array[MultiTrackedObject],
  detected : Array[MultiDetectedObject],
  config : MultiTrackingConfig,
) -> Array[(Int32, Int32)] {
  // 返回 (tracked_idx, detected_idx) 配对
  let pairs : Array[(Int32, Int32)] = []
  let used_detected : Array[Bool] = []
  for _ in 0..<detected.length() {
    used_detected.push(false)
  }
  for i in 0..<tracked.length() {
    if tracked[i].state is Terminated {
      continue
    }
    let mut best_j = -1
    let mut best_dist = config.association_threshold
    for j in 0..<detected.length() {
      if used_detected[j] {
        continue
      }
      let dist = centroid_distance(tracked[i], detected[j])
      let iou = compute_iou(tracked[i], detected[j])
      let score = dist - iou * 50.0
      if score < best_dist {
        best_dist = score
        best_j = j
      }
    }
    if best_j >= 0 {
      pairs.push((i, best_j))
      used_detected[best_j] = true
    }
  }
  pairs
}

///|
/// 初始化跟踪器。
/// Initialize tracker with detected objects.
pub fn init_tracker(
  detections : Array[MultiDetectedObject],
  config : MultiTrackingConfig,
) -> Array[MultiTrackedObject] {
  let tracked : Array[MultiTrackedObject] = []
  let mut id = 0
  for det in detections {
    if det.confidence < config.min_confidence {
      continue
    }
    tracked.push({
      id,
      x: det.x,
      y: det.y,
      width: det.width,
      height: det.height,
      state: Active,
      age: 1,
      lost_count: 0,
    })
    id = id + 1
  }
  tracked
}

///|
/// 更新跟踪器。
/// Update tracker with new detections.
pub fn update_tracker(
  tracked : Array[MultiTrackedObject],
  detections : Array[MultiDetectedObject],
  config : MultiTrackingConfig,
) -> Array[MultiTrackedObject] {
  let pairs = associate_objects(tracked, detections, config)
  let used_detected : Array[Bool] = []
  for _ in 0..<detections.length() {
    used_detected.push(false)
  }
  let result : Array[MultiTrackedObject] = []
  // 标记已关联的检测
  for (_, j) in pairs {
    used_detected[j] = true
  }
  // 更新已关联的跟踪对象
  for i in 0..<tracked.length() {
    let mut paired_j = -1
    for (ti, dj) in pairs {
      if ti == i {
        paired_j = dj
      }
    }
    if paired_j >= 0 {
      let det = detections[paired_j]
      result.push({
        id: tracked[i].id,
        x: det.x,
        y: det.y,
        width: det.width,
        height: det.height,
        state: Active,
        age: tracked[i].age + 1,
        lost_count: 0,
      })
    } else {
      // 未关联：增加丢失计数
      let new_lost = tracked[i].lost_count + 1
      let new_state = if new_lost > config.max_lost_frames {
        Terminated
      } else {
        Lost
      }
      result.push({
        id: tracked[i].id,
        x: tracked[i].x,
        y: tracked[i].y,
        width: tracked[i].width,
        height: tracked[i].height,
        state: new_state,
        age: tracked[i].age + 1,
        lost_count: new_lost,
      })
    }
  }
  // 添加新检测到的对象
  let mut max_id = 0
  for t in tracked {
    if t.id > max_id {
      max_id = t.id
    }
  }
  let mut next_id = max_id + 1
  for j in 0..<detections.length() {
    if !used_detected[j] && detections[j].confidence >= config.min_confidence {
      result.push({
        id: next_id,
        x: detections[j].x,
        y: detections[j].y,
        width: detections[j].width,
        height: detections[j].height,
        state: Active,
        age: 1,
        lost_count: 0,
      })
      next_id = next_id + 1
    }
  }
  result
}

///|
/// 多目标跟踪。
/// Multi-object tracking across frames.
pub fn multi_object_track(
  detections_per_frame : Array[Array[MultiDetectedObject]],
  config : MultiTrackingConfig,
) -> Array[Array[MultiTrackedObject]] {
  let results : Array[Array[MultiTrackedObject]] = []
  let n = detections_per_frame.length()
  if n == 0 {
    return results
  }
  let mut tracked = init_tracker(detections_per_frame[0], config)
  results.push(tracked)
  for i in 1..<n {
    tracked = update_tracker(tracked, detections_per_frame[i], config)
    results.push(tracked)
  }
  results
}

///|
/// 计算跟踪长度。
/// Compute track length (age of longest track).
pub fn compute_track_length(tracked : Array[MultiTrackedObject]) -> Int32 {
  let mut max_age = 0
  for t in tracked {
    if t.age > max_age {
      max_age = t.age
    }
  }
  max_age
}

///|
/// 计算活跃跟踪数。
/// Compute number of active tracks.
pub fn count_active_tracks(tracked : Array[MultiTrackedObject]) -> Int32 {
  let mut count = 0
  for t in tracked {
    if t.state is Active {
      count = count + 1
    }
  }
  count
}

///|
/// 计算跟踪稳定性。
/// Compute tracking stability score.
pub fn tracking_stability(tracked : Array[MultiTrackedObject]) -> Double {
  let n = tracked.length()
  if n == 0 {
    return 0.0
  }
  let mut total_score = 0.0
  for t in tracked {
    let active_bonus = if t.state is Active { 1.0 } else { 0.0 }
    let age_score = t.age.to_double() / (t.age.to_double() + 10.0)
    total_score = total_score + active_bonus * age_score
  }
  total_score / n.to_double()
}

///|
/// 过滤低置信度检测。
/// Filter low confidence detections.
pub fn filter_detections(
  detections : Array[MultiDetectedObject],
  min_confidence : Double,
) -> Array[MultiDetectedObject] {
  let result : Array[MultiDetectedObject] = []
  for det in detections {
    if det.confidence >= min_confidence {
      result.push(det)
    }
  }
  result
}
