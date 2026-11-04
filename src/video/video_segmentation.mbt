// 视频分割 — 前景/背景/运动
// Video segmentation: foreground / background / motion
//
// Phase 17 v399: 视频处理大扩展 — 视频分割。

///|
/// 视频分割方法。
/// Video segmentation method.
pub(all) enum VideoSegmentationMethod {
  FrameDifference // 帧差法
  BackgroundSubtraction // 背景减除
  MotionBased // 基于运动
} derive(Eq, @debug.Debug)

///|
pub extend VideoSegmentationMethod with @debug.Debug::{to_repr}

///|
pub extend VideoSegmentationMethod with Eq::{not_equal, equal}

///|
/// 背景模型。
/// Background model.
pub(all) struct BackgroundModel {
  background : @types.Image
  variance : @types.Image // 每像素方差
  frame_count : Int32
} derive(Eq, @debug.Debug)

///|
pub extend BackgroundModel with @debug.Debug::{to_repr}

///|
pub extend BackgroundModel with Eq::{not_equal, equal}

///|
/// 分割配置。
/// Segmentation configuration.
pub(all) struct SegmentationConfig {
  seg_method : VideoSegmentationMethod
  threshold : Double // 二值化阈值
  learning_rate : Double // 背景学习率 (0.0-1.0)
  min_motion_area : Int32 // 最小运动区域面积
} derive(Eq, @debug.Debug)

///|
pub extend SegmentationConfig with @debug.Debug::{to_repr}

///|
pub extend SegmentationConfig with Eq::{not_equal, equal}

///|
/// 分割结果。
/// Segmentation result.
pub(all) struct SegmentationResult {
  foreground_mask : Array[Bool] // 前景掩模
  foreground_ratio : Double // 前景比例
  motion_area : Int32 // 运动面积
  width : Int32
  height : Int32
} derive(Eq, @debug.Debug)

///|
pub extend SegmentationResult with @debug.Debug::{to_repr}

///|
pub extend SegmentationResult with Eq::{not_equal, equal}

///|
/// 默认分割配置。
/// Default segmentation configuration.
pub fn default_segmentation_config() -> SegmentationConfig {
  {
    seg_method: FrameDifference,
    threshold: 30.0,
    learning_rate: 0.05,
    min_motion_area: 10,
  }
}

///|
/// 帧差法前景分割。
/// Frame difference foreground segmentation.
pub fn segment_frame_difference(
  current : @types.Image,
  previous : @types.Image,
  threshold : Double,
) -> SegmentationResult {
  let w = current.width
  let h = current.height
  let ch = current.channels
  let mask : Array[Bool] = []
  let mut motion_count = 0
  for y in 0..<h {
    for x in 0..<w {
      let mut diff = 0.0
      for c in 0..<ch {
        let ci = (y * w + x) * ch + c
        let d = current.data[ci].to_int() - previous.data[ci].to_int()
        diff = diff + d.to_double().abs()
      }
      diff = diff / ch.to_double()
      if diff > threshold {
        mask.push(true)
        motion_count = motion_count + 1
      } else {
        mask.push(false)
      }
    }
  }
  let total = w * h
  let ratio = if total > 0 {
    motion_count.to_double() / total.to_double()
  } else {
    0.0
  }
  {
    foreground_mask: mask,
    foreground_ratio: ratio,
    motion_area: motion_count,
    width: w,
    height: h,
  }
}

///|
/// 构建背景模型。
/// Build background model from frames.
pub fn build_background_model(frames : Array[@types.Image]) -> BackgroundModel? {
  let n = frames.length()
  if n == 0 {
    return None
  }
  let w = frames[0].width
  let h = frames[0].height
  let ch = frames[0].channels
  // 均值背景
  let bg_data : Array[Byte] = []
  let var_data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let mut sum = 0.0
    for frame in frames {
      sum = sum + frame.data[i].to_int().to_double()
    }
    let mean = sum / n.to_double()
    let mut var_sum = 0.0
    for frame in frames {
      let diff = frame.data[i].to_int().to_double() - mean
      var_sum = var_sum + diff * diff
    }
    let variance = var_sum / n.to_double()
    bg_data.push(mean.clamp(min=0.0, max=255.0).to_int().to_byte())
    var_data.push(variance.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  Some({
    background: {
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(bg_data),
    },
    variance: {
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(var_data),
    },
    frame_count: n,
  })
}

///|
/// 更新背景模型。
/// Update background model with new frame.
pub fn update_background_model(
  model : BackgroundModel,
  frame : @types.Image,
  learning_rate : Double,
) -> BackgroundModel {
  let w = model.background.width
  let h = model.background.height
  let ch = model.background.channels
  let alpha = learning_rate.clamp(min=0.0, max=1.0)
  let bg_data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let old = model.background.data[i].to_int().to_double()
    let new_val = frame.data[i].to_int().to_double()
    let updated = old * (1.0 - alpha) + new_val * alpha
    bg_data.push(updated.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  {
    background: {
      width: w,
      height: h,
      channels: ch,
      data: Bytes::from_array(bg_data),
    },
    variance: model.variance,
    frame_count: model.frame_count + 1,
  }
}

///|
/// 背景减除。
/// Background subtraction.
pub fn subtract_background(
  frame : @types.Image,
  model : BackgroundModel,
  threshold : Double,
) -> SegmentationResult {
  let w = frame.width
  let h = frame.height
  let ch = frame.channels
  let mask : Array[Bool] = []
  let mut motion_count = 0
  for y in 0..<h {
    for x in 0..<w {
      let mut diff = 0.0
      for c in 0..<ch {
        let ci = (y * w + x) * ch + c
        let d = frame.data[ci].to_int() - model.background.data[ci].to_int()
        diff = diff + d.to_double().abs()
      }
      diff = diff / ch.to_double()
      if diff > threshold {
        mask.push(true)
        motion_count = motion_count + 1
      } else {
        mask.push(false)
      }
    }
  }
  let total = w * h
  let ratio = if total > 0 {
    motion_count.to_double() / total.to_double()
  } else {
    0.0
  }
  {
    foreground_mask: mask,
    foreground_ratio: ratio,
    motion_area: motion_count,
    width: w,
    height: h,
  }
}

///|
/// 基于运动的分割。
/// Motion-based segmentation.
pub fn segment_motion(
  frames : Array[@types.Image],
  threshold : Double,
) -> Array[SegmentationResult] {
  let results : Array[SegmentationResult] = []
  let n = frames.length()
  if n < 2 {
    return results
  }
  for i in 1..<n {
    results.push(segment_frame_difference(frames[i], frames[i - 1], threshold))
  }
  results
}

///|
/// 视频分割流水线。
/// Video segmentation pipeline.
pub fn video_segmentation_pipeline(
  frames : Array[@types.Image],
  config : SegmentationConfig,
) -> Array[SegmentationResult] {
  match config.seg_method {
    FrameDifference => {
      let results : Array[SegmentationResult] = []
      let n = frames.length()
      if n < 2 {
        return results
      }
      for i in 1..<n {
        results.push(
          segment_frame_difference(frames[i], frames[i - 1], config.threshold),
        )
      }
      results
    }
    BackgroundSubtraction => {
      let results : Array[SegmentationResult] = []
      let n = frames.length()
      if n < 2 {
        return results
      }
      let model = build_background_model(frames)
      if model is Some(m) {
        for frame in frames {
          results.push(subtract_background(frame, m, config.threshold))
        }
      }
      results
    }
    MotionBased => segment_motion(frames, config.threshold)
  }
}

///|
/// 计算运动一致性。
/// Compute motion consistency across frames.
pub fn motion_consistency(results : Array[SegmentationResult]) -> Double {
  let n = results.length()
  if n == 0 {
    return 0.0
  }
  let w = results[0].width
  let h = results[0].height
  let total = w * h
  if total == 0 {
    return 0.0
  }
  // 计算每像素的运动频率
  let freq : Array[Int32] = Array::make(total, 0)
  for r in results {
    for i in 0..<total {
      if i < r.foreground_mask.length() && r.foreground_mask[i] {
        freq[i] = freq[i] + 1
      }
    }
  }
  // 一致性 = 高频运动像素比例
  let mut consistent = 0
  for f in freq {
    if f.to_double() / n.to_double() > 0.5 {
      consistent = consistent + 1
    }
  }
  consistent.to_double() / total.to_double()
}

///|
/// 提取前景图像。
/// Extract foreground image using mask.
pub fn extract_foreground(
  img : @types.Image,
  result : SegmentationResult,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let mask_idx = y * w + x
      let is_fg = if mask_idx < result.foreground_mask.length() {
        result.foreground_mask[mask_idx]
      } else {
        false
      }
      for c in 0..<ch {
        if is_fg {
          data.push(img.data[(y * w + x) * ch + c])
        } else {
          data.push((0 : Byte))
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}
