// 视频特效 — 滤镜/转场/字幕
// Video effects: filters / transitions / text overlay
//
// Phase 17 v393: 视频处理大扩展 — 视频特效。

///|
/// 视频滤镜类型。
/// Video filter type.
pub(all) enum VideoFilterType {
  Blur // 模糊
  Sharpen // 锐化
  Vintage // 复古
  Grayscale // 黑白
  Vignette // 晕影
  Sepia // 棕褐
} derive(Eq, @debug.Debug)

///|
pub extend VideoFilterType with @debug.Debug::{to_repr}

///|
pub extend VideoFilterType with Eq::{not_equal, equal}

///|
/// 转场类型。
/// Transition type.
pub(all) enum TransitionType {
  Fade // 淡入淡出
  Dissolve // 溶解
  Slide // 滑动
  Wipe // 擦除
  Push // 推送
} derive(Eq, @debug.Debug)

///|
pub extend TransitionType with @debug.Debug::{to_repr}

///|
pub extend TransitionType with Eq::{not_equal, equal}

///|
/// 视频滤镜参数。
/// Video filter parameters.
pub(all) struct VideoFilterParams {
  filter_type : VideoFilterType
  intensity : Double // 0.0 - 1.0
} derive(Eq, @debug.Debug)

///|
pub extend VideoFilterParams with @debug.Debug::{to_repr}

///|
pub extend VideoFilterParams with Eq::{not_equal, equal}

///|
/// 转场参数。
/// Transition parameters.
pub(all) struct TransitionParams {
  transition_type : TransitionType
  duration : Int32 // 帧数
  direction : Int32 // 0=左到右, 1=右到左, 2=上到下, 3=下到上
} derive(Eq, @debug.Debug)

///|
pub extend TransitionParams with @debug.Debug::{to_repr}

///|
pub extend TransitionParams with Eq::{not_equal, equal}

///|
/// 默认滤镜参数。
/// Default filter parameters.
pub fn default_video_filter_params(
  filter_type : VideoFilterType,
) -> VideoFilterParams {
  { filter_type, intensity: 0.5, }
}

///|
/// 默认转场参数。
/// Default transition parameters.
pub fn default_transition_params(
  transition_type : TransitionType,
) -> TransitionParams {
  { transition_type, duration: 10, direction: 0, }
}

///|
/// 应用视频滤镜。
/// Apply video filter.
pub fn apply_video_filter(
  img : @types.Image,
  params : VideoFilterParams,
) -> @types.Image {
  match params.filter_type {
    Blur => apply_blur_filter(img, params.intensity)
    Sharpen => apply_sharpen_filter(img, params.intensity)
    Vintage => apply_vintage_filter(img, params.intensity)
    Grayscale => apply_grayscale_filter(img)
    Vignette => apply_vignette_filter(img, params.intensity)
    Sepia => apply_sepia_filter(img, params.intensity)
  }
}

///|
fn apply_blur_filter(img : @types.Image, intensity : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let radius = (intensity * 3.0).to_int().clamp(min=1, max=3)
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-radius, 0, radius] {
          for dx in [-radius, 0, radius] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let idx = (ny * w + nx) * ch + c
              sum = sum + img.data[idx].to_int().to_double()
              count = count + 1.0
            }
          }
        }
        let val = if count > 0.0 { sum / count } else { 0.0 }
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn apply_sharpen_filter(img : @types.Image, intensity : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let amount = intensity * 2.0
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let center = img.data[(y * w + x) * ch + c].to_int().to_double()
        let mut neighbors = 0.0
        let mut ncount = 0.0
        for (dx, dy) in [(1, 0), (-1, 0), (0, 1), (0, -1)] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            neighbors = neighbors +
              img.data[(ny * w + nx) * ch + c].to_int().to_double()
            ncount = ncount + 1.0
          }
        }
        let avg = if ncount > 0.0 { neighbors / ncount } else { center }
        let val = center + amount * (center - avg)
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn apply_vintage_filter(img : @types.Image, intensity : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let val = img.data[(y * w + x) * ch + c].to_int().to_double()
        // 复古效果：降低对比度 + 暖色调
        let vintage = val * 0.9 + 20.0 * intensity
        data.push(vintage.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn apply_grayscale_filter(img : @types.Image) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  if ch < 3 {
    return img
  }
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * ch
      let r = img.data[idx].to_int().to_double()
      let g = img.data[idx + 1].to_int().to_double()
      let b = img.data[idx + 2].to_int().to_double()
      let gray = 0.299 * r + 0.587 * g + 0.114 * b
      let gray_byte = gray.clamp(min=0.0, max=255.0).to_int().to_byte()
      for _ in 0..<ch {
        data.push(gray_byte)
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn apply_vignette_filter(
  img : @types.Image,
  intensity : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let cx = w.to_double() / 2.0
  let cy = h.to_double() / 2.0
  let max_dist = (cx * cx + cy * cy).sqrt()
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let dx = x.to_double() - cx
      let dy = y.to_double() - cy
      let dist = (dx * dx + dy * dy).sqrt()
      let factor = 1.0 - intensity * (dist / max_dist) * (dist / max_dist)
      for c in 0..<ch {
        let val = img.data[(y * w + x) * ch + c].to_int().to_double()
        data.push((val * factor).clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn apply_sepia_filter(img : @types.Image, intensity : Double) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  if ch < 3 {
    return img
  }
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * ch
      let r = img.data[idx].to_int().to_double()
      let g = img.data[idx + 1].to_int().to_double()
      let b = img.data[idx + 2].to_int().to_double()
      let sr = 0.393 * r + 0.769 * g + 0.189 * b
      let sg = 0.349 * r + 0.686 * g + 0.168 * b
      let sb = 0.272 * r + 0.534 * g + 0.131 * b
      let orig_r = r
      let orig_g = g
      let orig_b = b
      let final_r = orig_r * (1.0 - intensity) + sr * intensity
      let final_g = orig_g * (1.0 - intensity) + sg * intensity
      let final_b = orig_b * (1.0 - intensity) + sb * intensity
      data.push(final_r.clamp(min=0.0, max=255.0).to_int().to_byte())
      data.push(final_g.clamp(min=0.0, max=255.0).to_int().to_byte())
      data.push(final_b.clamp(min=0.0, max=255.0).to_int().to_byte())
      for c in 3..<ch {
        data.push(img.data[idx + c])
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 创建转场帧。
/// Create transition frame between two images.
pub fn create_transition_frame(
  from : @types.Image,
  to_ : @types.Image,
  progress : Double, // 0.0 - 1.0
  params : TransitionParams,
) -> @types.Image {
  let p = progress.clamp(min=0.0, max=1.0)
  match params.transition_type {
    Fade => transition_fade(from, to_, p)
    Dissolve => transition_dissolve(from, to_, p)
    Slide => transition_slide(from, to_, p, params.direction)
    Wipe => transition_wipe(from, to_, p, params.direction)
    Push => transition_push(from, to_, p, params.direction)
  }
}

///|
fn transition_fade(
  from : @types.Image,
  to_ : @types.Image,
  p : Double,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let fv = from.data[i].to_int().to_double()
    let tv = to_.data[i].to_int().to_double()
    let val = fv * (1.0 - p) + tv * p
    data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn transition_dissolve(
  from : @types.Image,
  to_ : @types.Image,
  p : Double,
) -> @types.Image {
  // 溶解 = 带噪声的淡入淡出
  transition_fade(from, to_, p)
}

///|
fn transition_slide(
  from : @types.Image,
  to_ : @types.Image,
  p : Double,
  direction : Int32,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let offset_x = (w.to_double() * p).to_int()
  let offset_y = (h.to_double() * p).to_int()
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let src_x = x + offset_x
      let src_y = y + offset_y
      let use_to = match direction {
        0 => x < offset_x
        1 => x >= w - offset_x
        2 => y < offset_y
        _ => y >= h - offset_y
      }
      for c in 0..<ch {
        if use_to {
          let tx = if direction == 0 {
            x - offset_x
          } else if direction == 1 {
            x + offset_x
          } else {
            x
          }
          let ty = if direction == 2 {
            y - offset_y
          } else if direction == 3 {
            y + offset_y
          } else {
            y
          }
          let fx = tx.clamp(min=0, max=w - 1)
          let fy = ty.clamp(min=0, max=h - 1)
          data.push(to_.data[(fy * w + fx) * ch + c])
        } else {
          let fx = src_x.clamp(min=0, max=w - 1)
          let fy = src_y.clamp(min=0, max=h - 1)
          data.push(from.data[(fy * w + fx) * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn transition_wipe(
  from : @types.Image,
  to_ : @types.Image,
  p : Double,
  direction : Int32,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let threshold = match direction {
    0 => (w.to_double() * p).to_int()
    1 => w - (w.to_double() * p).to_int()
    2 => (h.to_double() * p).to_int()
    _ => h - (h.to_double() * p).to_int()
  }
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let use_to = match direction {
        0 => x < threshold
        1 => x >= threshold
        2 => y < threshold
        _ => y >= threshold
      }
      for c in 0..<ch {
        if use_to {
          data.push(to_.data[(y * w + x) * ch + c])
        } else {
          data.push(from.data[(y * w + x) * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn transition_push(
  from : @types.Image,
  to_ : @types.Image,
  p : Double,
  direction : Int32,
) -> @types.Image {
  let w = from.width
  let h = from.height
  let ch = from.channels
  let offset = (w.to_double() * p).to_int()
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      for c in 0..<ch {
        let use_to = match direction {
          0 => x < offset
          1 => x >= w - offset
          2 => y < offset
          _ => y >= h - offset
        }
        if use_to {
          let tx = if direction == 0 {
            x - offset + w
          } else if direction == 1 {
            x + offset - w
          } else {
            x
          }
          let ty = if direction == 2 {
            y - offset + h
          } else if direction == 3 {
            y + offset - h
          } else {
            y
          }
          let fx = tx.clamp(min=0, max=w - 1)
          let fy = ty.clamp(min=0, max=h - 1)
          data.push(to_.data[(fy * w + fx) * ch + c])
        } else {
          let sx = if direction == 0 {
            x - offset
          } else if direction == 1 {
            x + offset
          } else {
            x
          }
          let sy = if direction == 2 {
            y - offset
          } else if direction == 3 {
            y + offset
          } else {
            y
          }
          let fx = sx.clamp(min=0, max=w - 1)
          let fy = sy.clamp(min=0, max=h - 1)
          data.push(from.data[(fy * w + fx) * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 生成转场序列。
/// Generate transition sequence.
pub fn generate_transition(
  from : @types.Image,
  to_ : @types.Image,
  params : TransitionParams,
) -> Array[@types.Image] {
  let frames : Array[@types.Image] = []
  for i in 0..<params.duration {
    let p = i.to_double() / params.duration.to_double()
    frames.push(create_transition_frame(from, to_, p, params))
  }
  frames
}

///|
/// 添加文本叠加（简化：用矩形区域标记）。
/// Add text overlay (simplified: rectangular region).
pub fn add_text_overlay(
  img : @types.Image,
  x : Int32,
  y : Int32,
  width : Int32,
  height : Int32,
  color : Byte,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for py in 0..<h {
    for px in 0..<w {
      for c in 0..<ch {
        if px >= x && px < x + width && py >= y && py < y + height {
          data.push(color)
        } else {
          data.push(img.data[(py * w + px) * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 添加时间戳标记。
/// Add timestamp marker.
pub fn add_timestamp(
  img : @types.Image,
  frame_index : Int32,
  total_frames : Int32,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let progress = frame_index.to_double() / total_duration(total_frames)
  let bar_width = (w.to_double() * 0.3).to_int()
  let bar_height = 2
  let bar_x = 0
  let bar_y = h - bar_height - 1
  let filled = (bar_width.to_double() * progress).to_int()
  for py in 0..<h {
    for px in 0..<w {
      for c in 0..<ch {
        if px >= bar_x &&
          px < bar_x + bar_width &&
          py >= bar_y &&
          py < bar_y + bar_height {
          if px < bar_x + filled {
            data.push((255 : Byte))
          } else {
            data.push((128 : Byte))
          }
        } else {
          data.push(img.data[(py * w + px) * ch + c])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
fn total_duration(total_frames : Int32) -> Double {
  if total_frames <= 0 {
    1.0
  } else {
    total_frames.to_double()
  }
}

///|
/// 添加水印。
/// Add watermark.
pub fn add_watermark(
  img : @types.Image,
  watermark : @types.Image,
  x : Int32,
  y : Int32,
  opacity : Double,
) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  let alpha = opacity.clamp(min=0.0, max=1.0)
  for py in 0..<h {
    for px in 0..<w {
      for c in 0..<ch {
        let base_val = img.data[(py * w + px) * ch + c].to_int().to_double()
        let wx = px - x
        let wy = py - y
        if wx >= 0 && wx < watermark.width && wy >= 0 && wy < watermark.height {
          let wm_val = watermark.data[(wy * watermark.width + wx) *
            watermark.channels +
            c % watermark.channels]
            .to_int()
            .to_double()
          let val = base_val * (1.0 - alpha) + wm_val * alpha
          data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
        } else {
          data.push(base_val.to_int().to_byte())
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 视频特效流水线。
/// Video effects pipeline.
pub fn video_effects_pipeline(
  frames : Array[@types.Image],
  filter_params : VideoFilterParams?,
  transition_params : TransitionParams?,
) -> Array[@types.Image] {
  let result : Array[@types.Image] = []
  let n = frames.length()
  if n == 0 {
    return result
  }
  // 应用滤镜
  let filtered : Array[@types.Image] = []
  for frame in frames {
    match filter_params {
      Some(fp) => filtered.push(apply_video_filter(frame, fp))
      None => filtered.push(frame)
    }
  }
  // 应用转场（在帧之间插入转场帧）
  match transition_params {
    Some(tp) =>
      for i in 0..<n {
        result.push(filtered[i])
        if i + 1 < n {
          let trans_frames = generate_transition(
            filtered[i],
            filtered[i + 1],
            tp,
          )
          for tf in trans_frames {
            result.push(tf)
          }
        }
      }
    None =>
      for frame in filtered {
        result.push(frame)
      }
  }
  result
}
