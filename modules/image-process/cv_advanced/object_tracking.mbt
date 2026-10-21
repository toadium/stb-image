// 目标跟踪 — KCF/MOSSE/CSRT/Kalman
// Object tracking: KCF / MOSSE / CSRT / Kalman filter
//
// Phase 12 v322: 大规模扩展 CV 算法库 — 目标跟踪。

///|
/// 跟踪器类型。
/// Tracker kind.
pub(all) enum TrackerKind {
  KCF
  MOSSE
  CSRT
} derive(Eq, @debug.Debug)

///|
pub extend TrackerKind with @debug.Debug::{to_repr}

///|
pub extend TrackerKind with Eq::{not_equal, equal}

///|
/// 跟踪框。
/// Track bounding box.
pub(all) struct Track {
  x : Double
  y : Double
  width : Double
  height : Double
  id : Int32
  score : Double
} derive(Eq, @debug.Debug)

///|
pub extend Track with @debug.Debug::{to_repr}

///|
pub extend Track with Eq::{not_equal, equal}

///|
/// 跟踪器参数。
/// Tracker parameters.
pub(all) struct TrackerParams {
  kind : TrackerKind
  learning_rate : Double
  sigma : Double
  max_gap : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TrackerParams with @debug.Debug::{to_repr}

///|
pub extend TrackerParams with Eq::{not_equal, equal}

///|
/// Kalman 滤波器状态。
/// Kalman filter state.
pub(all) struct KalmanState {
  x : Double
  y : Double
  vx : Double
  vy : Double
  px : Double
  py : Double
  pvx : Double
  pvy : Double
} derive(Eq, @debug.Debug)

///|
pub extend KalmanState with @debug.Debug::{to_repr}

///|
pub extend KalmanState with Eq::{not_equal, equal}

///|
/// 初始化跟踪器。
/// Initialize tracker with bounding box.
pub fn init_tracker(
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  params : TrackerParams,
) -> Track {
  let _ = params
  { x, y, width: w, height: h, id: 0, score: 1.0, }
}

///|
/// 更新跟踪器位置。
/// Update tracker position.
pub fn update_tracker(
  track : Track,
  new_x : Double,
  new_y : Double,
  params : TrackerParams,
) -> Track {
  let lr = params.learning_rate
  let alpha = 1.0 - lr
  {
    x: alpha * track.x + lr * new_x,
    y: alpha * track.y + lr * new_y,
    width: track.width,
    height: track.height,
    id: track.id,
    score: track.score * 0.95,
  }
}

///|
/// 计算相关滤波响应（简化版）。
/// Compute correlation filter response (simplified).
pub fn compute_correlation_filter(
  img : @types.Image,
  track : Track,
  sigma : Double,
) -> Double {
  let w = img.width
  let h = img.height
  let tx = track.x.to_int()
  let ty = track.y.to_int()
  let tw = track.width.to_int()
  let th = track.height.to_int()
  let mut sum = 0.0
  let mut count = 0
  for dy in 0..<th {
    for dx in 0..<tw {
      let ix = tx + dx
      let iy = ty + dy
      if ix >= 0 && ix < w && iy >= 0 && iy < h {
        let idx = (iy * w + ix) * img.channels
        sum = sum + img.data[idx].to_int().to_double()
        count = count + 1
      }
    }
  }
  if count > 0 {
    let mean = sum / count.to_double()
    let g = @math.exp(-(mean - 128.0) * (mean - 128.0) / (2.0 * sigma * sigma))
    g
  } else {
    0.0
  }
}

///|
/// Kalman 预测步骤。
/// Kalman filter predict step.
pub fn kalman_predict(state : KalmanState) -> KalmanState {
  {
    x: state.x + state.vx,
    y: state.y + state.vy,
    vx: state.vx,
    vy: state.vy,
    px: state.px + 1.0,
    py: state.py + 1.0,
    pvx: state.pvx,
    pvy: state.pvy,
  }
}

///|
/// Kalman 校正步骤。
/// Kalman filter correct step.
pub fn kalman_correct(
  state : KalmanState,
  measured_x : Double,
  measured_y : Double,
) -> KalmanState {
  let kx = state.px / (state.px + 1.0)
  let ky = state.py / (state.py + 1.0)
  let new_x = state.x + kx * (measured_x - state.x)
  let new_y = state.y + ky * (measured_y - state.y)
  {
    x: new_x,
    y: new_y,
    vx: state.vx + kx * (measured_x - state.x) * 0.1,
    vy: state.vy + ky * (measured_y - state.y) * 0.1,
    px: state.px * (1.0 - kx) + 1.0,
    py: state.py * (1.0 - ky) + 1.0,
    pvx: state.pvx,
    pvy: state.pvy,
  }
}

///|
/// 多目标跟踪（简化版，基于 IoU 关联）。
/// Multi-object tracking (simplified, IoU-based association).
pub fn track_objects(
  existing : Array[Track],
  detections : Array[Track],
  iou_threshold : Double,
) -> Array[Track] {
  let result : Array[Track] = []
  let used : Array[Bool] = []
  for _ in 0..<detections.length() {
    used.push(false)
  }
  for track in existing {
    let mut best_idx = -1
    let mut best_iou = iou_threshold
    for i in 0..<detections.length() {
      if used[i] {
        continue
      }
      let det = detections[i]
      let iou = compute_iou(track, det)
      if iou > best_iou {
        best_iou = iou
        best_idx = i
      }
    }
    if best_idx >= 0 {
      used[best_idx] = true
      let det = detections[best_idx]
      result.push({
        x: det.x,
        y: det.y,
        width: det.width,
        height: det.height,
        id: track.id,
        score: det.score,
      })
    }
  }
  for i in 0..<detections.length() {
    if !used[i] {
      let det = detections[i]
      result.push({
        x: det.x,
        y: det.y,
        width: det.width,
        height: det.height,
        id: -1,
        score: det.score,
      })
    }
  }
  result
}

///|
/// 计算 IoU（交并比）。
/// Compute IoU (intersection over union).
pub fn compute_iou(a : Track, b : Track) -> Double {
  let ax2 = a.x + a.width
  let ay2 = a.y + a.height
  let bx2 = b.x + b.width
  let by2 = b.y + b.height
  let ix1 = if a.x > b.x { a.x } else { b.x }
  let iy1 = if a.y > b.y { a.y } else { b.y }
  let ix2 = if ax2 < bx2 { ax2 } else { bx2 }
  let iy2 = if ay2 < by2 { ay2 } else { by2 }
  let iw = ix2 - ix1
  let ih = iy2 - iy1
  if iw <= 0.0 || ih <= 0.0 {
    return 0.0
  }
  let intersection = iw * ih
  let union = a.width * a.height + b.width * b.height - intersection
  if union > 0.0 {
    intersection / union
  } else {
    0.0
  }
}
