// 目标检测 — 滑窗/CFAR/模板匹配/非极大值抑制
// Target detection
//
// Phase 15 v372: 遥感与地理空间大扩展 — 目标检测。

///|
/// 目标检测方法。
/// Target detection method.
pub(all) enum TargetDetMethod {
  SlidingWindow
  Cfar
  TemplateMatch
} derive(Eq, @debug.Debug)

///|
pub extend TargetDetMethod with @debug.Debug::{to_repr}

///|
pub extend TargetDetMethod with Eq::{not_equal, equal}

///|
/// 检测结果。
/// Detection result.
pub(all) struct TargetResult {
  x : Int32
  y : Int32
  width : Int32
  height : Int32
  confidence : Double
  class_id : Int32
} derive(Eq, @debug.Debug)

///|
pub extend TargetResult with @debug.Debug::{to_repr}

///|
pub extend TargetResult with Eq::{not_equal, equal}

///|
/// 构建检测结果。
/// Build detection result.
pub fn target_build_result(
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
  confidence : Double,
  class_id : Int32,
) -> TargetResult {
  { x, y, width, height, confidence, class_id, }
}

///|
/// 滑窗检测。
/// Sliding window detection.
pub fn target_sliding_window(
  image : Array[Array[Double]],
  window_size : Int32,
  threshold : Double,
) -> Array[TargetResult] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let results = []
  for row in 0..<=(height - window_size) {
    for col in 0..<=(width - window_size) {
      let mut sum = 0.0
      let mut count = 0
      for dy in 0..<window_size {
        for dx in 0..<window_size {
          sum += image[row + dy][col + dx]
          count += 1
        }
      }
      let mean = if count > 0 { sum / count.to_double() } else { 0.0 }
      if mean > threshold {
        results.push({
          x: col,
          y: row,
          width: window_size,
          height: window_size,
          confidence: mean,
          class_id: 0,
        })
      }
    }
  }
  results
}

///|
/// CFAR 检测（恒虚警率）。
/// CFAR (Constant False Alarm Rate) detection.
pub fn target_cfar(
  image : Array[Array[Double]],
  guard_size : Int32,
  ref_size : Int32,
  threshold_factor : Double,
) -> Array[TargetResult] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let total_size = guard_size + ref_size
  let results = []
  for row in total_size..<(height - total_size) {
    for col in total_size..<(width - total_size) {
      let mut ref_sum = 0.0
      let mut ref_count = 0
      for dy in -total_size..<=total_size {
        for dx in -total_size..<=total_size {
          let abs_dy = if dy < 0 { -dy } else { dy }
          let abs_dx = if dx < 0 { -dx } else { dx }
          if abs_dy > guard_size || abs_dx > guard_size {
            ref_sum += image[row + dy][col + dx]
            ref_count += 1
          }
        }
      }
      if ref_count > 0 {
        let ref_mean = ref_sum / ref_count.to_double()
        let threshold = ref_mean * threshold_factor
        if image[row][col] > threshold {
          results.push({
            x: col,
            y: row,
            width: 1,
            height: 1,
            confidence: image[row][col] / ref_mean,
            class_id: 0,
          })
        }
      }
    }
  }
  results
}

///|
/// 模板匹配检测。
/// Template matching detection.
pub fn target_template_match(
  image : Array[Array[Double]],
  template : Array[Array[Double]],
  threshold : Double,
) -> Array[TargetResult] {
  let height = image.length()
  if height == 0 {
    return []
  }
  let width = image[0].length()
  let t_height = template.length()
  let t_width = if t_height > 0 { template[0].length() } else { 0 }
  if t_height == 0 || t_width == 0 {
    return []
  }
  let results = []
  for row in 0..<=(height - t_height) {
    for col in 0..<=(width - t_width) {
      let mut correlation = 0.0
      let mut template_norm = 0.0
      for dy in 0..<t_height {
        for dx in 0..<t_width {
          correlation += image[row + dy][col + dx] * template[dy][dx]
          template_norm += template[dy][dx] * template[dy][dx]
        }
      }
      let score = if template_norm > 0.0 {
        correlation / template_norm.sqrt()
      } else {
        0.0
      }
      if score > threshold {
        results.push({
          x: col,
          y: row,
          width: t_width,
          height: t_height,
          confidence: score,
          class_id: 0,
        })
      }
    }
  }
  results
}

///|
/// 非极大值抑制。
/// Non-maximum suppression.
pub fn target_nms(
  detections : Array[TargetResult],
  iou_threshold : Double,
) -> Array[TargetResult] {
  let sorted = Array::make(
    detections.length(),
    target_build_result(0, 0, 0, 0, 0.0, 0),
  )
  for i in 0..<detections.length() {
    sorted[i] = detections[i]
  }
  for i in 0..<sorted.length() {
    for j in (i + 1)..<sorted.length() {
      if sorted[j].confidence > sorted[i].confidence {
        let temp = sorted[i]
        sorted[i] = sorted[j]
        sorted[j] = temp
      }
    }
  }
  let kept = []
  let suppressed = Array::make(sorted.length(), false)
  for i in 0..<sorted.length() {
    if suppressed[i] {
      continue
    }
    kept.push(sorted[i])
    for j in (i + 1)..<sorted.length() {
      if suppressed[j] {
        continue
      }
      let iou = target_compute_iou(sorted[i], sorted[j])
      if iou > iou_threshold {
        suppressed[j] = true
      }
    }
  }
  kept
}

///|
/// 计算 IoU（交并比）。
/// Compute IoU (Intersection over Union).
pub fn target_compute_iou(box1 : TargetResult, box2 : TargetResult) -> Double {
  let x1 = box1.x
  let y1 = box1.y
  let x2 = x1 + box1.width
  let y2 = y1 + box1.height
  let x3 = box2.x
  let y3 = box2.y
  let x4 = x3 + box2.width
  let y4 = y3 + box2.height
  let inter_x1 = if x1 > x3 { x1 } else { x3 }
  let inter_y1 = if y1 > y3 { y1 } else { y3 }
  let inter_x2 = if x2 < x4 { x2 } else { x4 }
  let inter_y2 = if y2 < y4 { y2 } else { y4 }
  let inter_width = inter_x2 - inter_x1
  let inter_height = inter_y2 - inter_y1
  if inter_width <= 0 || inter_height <= 0 {
    return 0.0
  }
  let inter_area = inter_width * inter_height
  let area1 = box1.width * box1.height
  let area2 = box2.width * box2.height
  let union_area = area1 + area2 - inter_area
  if union_area > 0 {
    inter_area.to_double() / union_area.to_double()
  } else {
    0.0
  }
}

///|
/// 目标检测主函数（分派）。
/// Main target detection function (dispatch).
pub fn target_detect(
  image : Array[Array[Double]],
  det_method : TargetDetMethod,
  window_size : Int32,
  threshold : Double,
) -> Array[TargetResult] {
  match det_method {
    SlidingWindow => target_sliding_window(image, window_size, threshold)
    Cfar => target_cfar(image, window_size / 2, window_size, threshold)
    TemplateMatch => {
      let template = Array::make(window_size, [])
      for i in 0..<window_size {
        template[i] = Array::make(window_size, 1.0)
      }
      target_template_match(image, template, threshold)
    }
  }
}

///|
/// 统计检测结果数量。
/// Count detection results.
pub fn target_count(detections : Array[TargetResult]) -> Int32 {
  detections.length()
}

///|
/// 获取最高置信度检测结果。
/// Get highest confidence detection.
pub fn target_best_detection(detections : Array[TargetResult]) -> TargetResult {
  if detections.length() == 0 {
    return target_build_result(0, 0, 0, 0, 0.0, 0)
  }
  let mut best = detections[0]
  for i in 1..<detections.length() {
    if detections[i].confidence > best.confidence {
      best = detections[i]
    }
  }
  best
}
