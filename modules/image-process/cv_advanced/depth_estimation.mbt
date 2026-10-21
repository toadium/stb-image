// 景深估计 — 单目深度/散焦深度/深度图后处理/景深流水线
// Depth estimation: monocular / defocus / post-processing / pipeline
//
// Phase 16 v380: 计算摄影大扩展 — 景深估计。

///|
/// 单目深度估计方法。
/// Monocular depth estimation method.
pub(all) enum MonocularDepthMethod {
  FromFocus // 从聚焦位置估计
  FromDefocus // 从散焦模糊度估计
  RelativeBlur // 从相对模糊度估计
  Hybrid // 混合方法
} derive(Eq, @debug.Debug)

///|
pub extend MonocularDepthMethod with @debug.Debug::{to_repr}

///|
pub extend MonocularDepthMethod with Eq::{not_equal, equal}

///|
/// 深度图后处理参数。
/// Depth map post-processing parameters.
pub(all) struct DepthPostProcessParams {
  smooth_radius : Int32 // 平滑半径
  fill_holes : Bool // 是否填充空洞
  normalize : Bool // 是否归一化到 [0,1]
  edge_refine : Bool // 是否边缘细化
  min_depth : Double // 最小深度值
  max_depth : Double // 最大深度值
} derive(Eq, @debug.Debug)

///|
pub extend DepthPostProcessParams with @debug.Debug::{to_repr}

///|
pub extend DepthPostProcessParams with Eq::{not_equal, equal}

///|
/// 景深估计流水线参数。
/// Depth estimation pipeline parameters.
pub(all) struct DepthEstimationParams {
  est_method : MonocularDepthMethod
  focal_length : Double // 焦距（像素单位）
  aperture : Double // 光圈直径
  focus_distance : Double // 对焦距离
  post_process : DepthPostProcessParams
} derive(Eq, @debug.Debug)

///|
pub extend DepthEstimationParams with @debug.Debug::{to_repr}

///|
pub extend DepthEstimationParams with Eq::{not_equal, equal}

///|
/// 景深范围结果。
/// Depth of field range result.
pub(all) struct DepthOfFieldRange {
  near : Double // 近景深边界
  far : Double // 远景深边界
  focal_plane : Double // 对焦平面距离
  hyperfocal : Double // 超焦距
} derive(Eq, @debug.Debug)

///|
pub extend DepthOfFieldRange with @debug.Debug::{to_repr}

///|
pub extend DepthOfFieldRange with Eq::{not_equal, equal}

///|
/// 从焦点堆叠序列中估计深度。
/// Estimate depth from focus stack sequence.
/// 每个像素的深度 = 对应最清晰图像的焦距位置。
pub fn estimate_depth_from_focus(
  sharpness_maps : Array[Array[Double]],
  focus_positions : Array[Double],
  width : Int32,
  height : Int32,
) -> DepthMap {
  let n = sharpness_maps.length()
  let depths : Array[Double] = []
  let valid : Array[Bool] = []
  for i in 0..<(width * height) {
    let mut best_sharp = -1.0
    let mut best_pos = 0.0
    let mut found = false
    for k in 0..<n {
      if i < sharpness_maps[k].length() {
        let s = sharpness_maps[k][i]
        if s > best_sharp {
          best_sharp = s
          best_pos = if k < focus_positions.length() {
            focus_positions[k]
          } else {
            k.to_double()
          }
          found = true
        }
      }
    }
    if found && best_sharp > 0.0 {
      depths.push(best_pos)
      valid.push(true)
    } else {
      depths.push(0.0)
      valid.push(false)
    }
  }
  { width, height, depths, valid, }
}

///|
/// 从散焦模糊度估计深度。
/// Estimate depth from defocus blur amount.
/// 模糊圆直径越大，离焦平面越远。
pub fn estimate_depth_from_defocus(
  blur_map : Array[Double],
  width : Int32,
  height : Int32,
  focal_length : Double,
  aperture : Double,
  focus_distance : Double,
) -> DepthMap {
  let depths : Array[Double] = []
  let valid : Array[Bool] = []
  let f2 = focal_length * focal_length
  for i in 0..<(width * height) {
    if i < blur_map.length() {
      let blur = blur_map[i]
      if blur >= 0.0 && aperture > 0.0 {
        // 散焦深度公式：d = f*D / (f - blur*D)
        // 简化：用模糊度偏移估计深度
        let denom = focal_length - blur * aperture
        if denom.abs() > 0.001 {
          let depth = f2 / denom
          if depth > 0.0 {
            depths.push(depth)
            valid.push(true)
          } else {
            depths.push(focus_distance)
            valid.push(true)
          }
        } else {
          depths.push(focus_distance)
          valid.push(true)
        }
      } else {
        depths.push(focus_distance)
        valid.push(true)
      }
    } else {
      depths.push(0.0)
      valid.push(false)
    }
  }
  { width, height, depths, valid, }
}

///|
/// 从相对模糊度估计深度。
/// Estimate depth from relative blur between two images.
/// 近处物体在远焦图像中更模糊，远处物体在近焦图像中更模糊。
pub fn estimate_depth_relative_blur(
  near_image : Array[Double],
  far_image : Array[Double],
  width : Int32,
  height : Int32,
  near_focus : Double,
  far_focus : Double,
) -> DepthMap {
  let depths : Array[Double] = []
  let valid : Array[Bool] = []
  for i in 0..<(width * height) {
    if i < near_image.length() && i < far_image.length() {
      let near_val = near_image[i]
      let far_val = far_image[i]
      let diff = near_val - far_val
      // diff > 0: 近焦更清晰 → 物体在近处
      // diff < 0: 远焦更清晰 → 物体在远处
      let total = near_val + far_val
      if total > 0.001 {
        let ratio = diff / total
        // 线性插值深度
        let depth = near_focus + (far_focus - near_focus) * (0.5 - ratio * 0.5)
        depths.push(depth)
        valid.push(true)
      } else {
        depths.push((near_focus + far_focus) / 2.0)
        valid.push(false)
      }
    } else {
      depths.push(0.0)
      valid.push(false)
    }
  }
  { width, height, depths, valid, }
}

///|
/// 深度图平滑（简化双边滤波）。
/// Smooth depth map (simplified bilateral filter).
pub fn smooth_depth_map(depth : DepthMap, radius : Int32) -> DepthMap {
  if radius <= 0 {
    return depth
  }
  let w = depth.width
  let h = depth.height
  let smoothed : Array[Double] = []
  let valid : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if !depth.valid[idx] {
        smoothed.push(0.0)
        valid.push(false)
        continue
      }
      let center = depth.depths[idx]
      let mut sum = 0.0
      let mut weight_sum = 0.0
      for dy in [-radius, 0, radius] {
        for dx in [-radius, 0, radius] {
          let nx = x + dx
          let ny = y + dy
          if nx >= 0 && nx < w && ny >= 0 && ny < h {
            let nidx = ny * w + nx
            if depth.valid[nidx] {
              let neighbor = depth.depths[nidx]
              // 空间权重 + 值域权重
              let spatial = if dx == 0 && dy == 0 { 1.0 } else { 0.5 }
              let val_diff = (neighbor - center).abs()
              let range_w = if val_diff < 0.5 {
                1.0
              } else if val_diff < 2.0 {
                0.5
              } else {
                0.1
              }
              let weight = spatial * range_w
              sum = sum + neighbor * weight
              weight_sum = weight_sum + weight
            }
          }
        }
      }
      if weight_sum > 0.0 {
        smoothed.push(sum / weight_sum)
        valid.push(true)
      } else {
        smoothed.push(center)
        valid.push(true)
      }
    }
  }
  { width: w, height: h, depths: smoothed, valid, }
}

///|
/// 填充深度图空洞（最近邻插值）。
/// Fill depth map holes using nearest neighbor interpolation.
pub fn fill_depth_holes(depth : DepthMap) -> DepthMap {
  let w = depth.width
  let h = depth.height
  let depths = depth.depths
  let valid = depth.valid
  let has_holes = {
    let mut found = false
    for i in 0..<(w * h) {
      if !valid[i] {
        found = true
        break
      }
    }
    found
  }
  if !has_holes {
    return depth
  }
  let filled : Array[Double] = []
  let new_valid : Array[Bool] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if valid[idx] {
        filled.push(depths[idx])
        new_valid.push(true)
        continue
      }
      // 搜索最近的有效点
      let mut best_dist = 1000000
      let mut best_val = 0.0
      let mut found = false
      for r in [1, 2, 4, 8, 16, 32] {
        if found {
          break
        }
        for dy in [-r, 0, r] {
          for dx in [-r, 0, r] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let nidx = ny * w + nx
              if valid[nidx] {
                let dist = dx * dx + dy * dy
                if dist < best_dist {
                  best_dist = dist
                  best_val = depths[nidx]
                  found = true
                }
              }
            }
          }
        }
      }
      if found {
        filled.push(best_val)
        new_valid.push(true)
      } else {
        filled.push(0.0)
        new_valid.push(false)
      }
    }
  }
  { width: w, height: h, depths: filled, valid: new_valid, }
}

///|
/// 归一化深度图到 [0, 1] 范围。
/// Normalize depth map to [0, 1] range.
pub fn normalize_depth_map(depth : DepthMap) -> DepthMap {
  let w = depth.width
  let h = depth.height
  let mut min_val = 1000000000000000000.0
  let mut max_val = -1000000000000000000.0
  for i in 0..<(w * h) {
    if depth.valid[i] {
      let v = depth.depths[i]
      if v < min_val {
        min_val = v
      }
      if v > max_val {
        max_val = v
      }
    }
  }
  let range = max_val - min_val
  if range < 0.000001 {
    return depth
  }
  let normalized : Array[Double] = []
  for i in 0..<(w * h) {
    if depth.valid[i] {
      normalized.push((depth.depths[i] - min_val) / range)
    } else {
      normalized.push(0.0)
    }
  }
  { width: w, height: h, depths: normalized, valid: depth.valid, }
}

///|
/// 深度图边缘细化。
/// Refine depth map edges using gradient guidance.
pub fn refine_depth_edges(depth : DepthMap, image : @types.Image) -> DepthMap {
  let w = depth.width
  let h = depth.height
  let refined : Array[Double] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      if !depth.valid[idx] {
        refined.push(0.0)
        continue
      }
      let center = depth.depths[idx]
      // 计算图像梯度
      let img_idx = (y * w + x) * image.channels
      let mut grad = 0.0
      if x + 1 < w {
        let right_idx = (y * w + x + 1) * image.channels
        let g = (image.data[right_idx].to_int() - image.data[img_idx].to_int()).to_double()
        grad = grad + g * g
      }
      if y + 1 < h {
        let down_idx = ((y + 1) * w + x) * image.channels
        let g = (image.data[down_idx].to_int() - image.data[img_idx].to_int()).to_double()
        grad = grad + g * g
      }
      // 在强边缘处保留原始深度，在平滑处做轻微平均
      if grad > 100.0 {
        refined.push(center)
      } else {
        let mut sum = center
        let mut count = 1.0
        for dy in [-1, 0, 1] {
          for dx in [-1, 0, 1] {
            if dx == 0 && dy == 0 {
              continue
            }
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let nidx = ny * w + nx
              if depth.valid[nidx] {
                sum = sum + depth.depths[nidx]
                count = count + 1.0
              }
            }
          }
        }
        refined.push(sum / count)
      }
    }
  }
  { width: w, height: h, depths: refined, valid: depth.valid, }
}

///|
/// 深度图转灰度图像。
/// Convert depth map to grayscale image.
pub fn depth_to_grayscale_image(depth : DepthMap) -> @types.Image {
  let w = depth.width
  let h = depth.height
  let normalized = normalize_depth_map(depth)
  let data : Array[Byte] = []
  for i in 0..<(w * h) {
    let v = normalized.depths[i]
    let g = (v * 255.0).clamp(min=0, max=255).to_int().to_byte()
    data.push(g)
  }
  { width: w, height: h, channels: 1, data: Bytes::from_array(data), }
}

///|
/// 计算景深范围。
/// Compute depth of field range.
/// 使用光学公式：H = f²/(N·c) + f, near = H·s/(H+s-f), far = H·s/(H-s-f)
pub fn compute_depth_of_field(
  focal_length : Double,
  aperture_f_number : Double,
  focus_distance : Double,
  circle_of_confusion : Double,
) -> DepthOfFieldRange {
  let f = focal_length
  let s = focus_distance
  let n = aperture_f_number
  let c = circle_of_confusion
  // 超焦距 H = f² / (N·c) + f
  let hyperfocal = if n * c > 0.0 { f * f / (n * c) + f } else { s }
  // 近景深 near = H·s / (H + s - f)
  let near = if hyperfocal + s - f > 0.0 {
    hyperfocal * s / (hyperfocal + s - f)
  } else {
    0.0
  }
  // 远景深 far = H·s / (H - s - f)
  let denom_far = hyperfocal - s - f
  let far = if denom_far > 0.0 {
    hyperfocal * s / denom_far
  } else {
    1000000000000000000.0
  }
  { near, far, focal_plane: s, hyperfocal, }
}

///|
/// 深度图后处理流水线。
/// Depth map post-processing pipeline.
pub fn depth_post_process(
  depth : DepthMap,
  params : DepthPostProcessParams,
) -> DepthMap {
  let mut result = depth
  if params.fill_holes {
    result = fill_depth_holes(result)
  }
  if params.smooth_radius > 0 {
    result = smooth_depth_map(result, params.smooth_radius)
  }
  if params.normalize {
    result = normalize_depth_map(result)
  }
  // 限制深度范围
  if params.min_depth > 0.0 || params.max_depth > 0.0 {
    let w = result.width
    let h = result.height
    let clamped : Array[Double] = []
    for i in 0..<(w * h) {
      if result.valid[i] {
        let v = result.depths[i]
        let clamped_v = if params.max_depth > 0.0 && v > params.max_depth {
          params.max_depth
        } else if params.min_depth > 0.0 && v < params.min_depth {
          params.min_depth
        } else {
          v
        }
        clamped.push(clamped_v)
      } else {
        clamped.push(0.0)
      }
    }
    result = { width: w, height: h, depths: clamped, valid: result.valid, }
  }
  result
}

///|
/// 景深估计流水线。
/// Depth estimation pipeline.
pub fn depth_estimation_pipeline(
  images : Array[@types.Image],
  sharpness_maps : Array[Array[Double]],
  focus_positions : Array[Double],
  params : DepthEstimationParams,
) -> DepthMap {
  let w = if images.length() > 0 { images[0].width } else { 1 }
  let h = if images.length() > 0 { images[0].height } else { 1 }
  let raw_depth = match params.est_method {
    FromFocus =>
      estimate_depth_from_focus(sharpness_maps, focus_positions, w, h)
    FromDefocus => {
      // 从图像序列计算平均模糊度
      let blur_map : Array[Double] = []
      for i in 0..<(w * h) {
        let mut total_blur = 0.0
        for k in 0..<images.length() {
          let idx = i * images[k].channels
          if idx < images[k].data.length() {
            total_blur = total_blur +
              images[k].data[idx].to_int().to_double() / 255.0
          }
        }
        blur_map.push(total_blur / images.length().to_double())
      }
      estimate_depth_from_defocus(
        blur_map,
        w,
        h,
        params.focal_length,
        params.aperture,
        params.focus_distance,
      )
    }
    RelativeBlur =>
      if images.length() >= 2 {
        let near_arr : Array[Double] = []
        let far_arr : Array[Double] = []
        for i in 0..<(w * h) {
          let near_idx = i * images[0].channels
          let far_idx = i * images[1].channels
          near_arr.push(
            if near_idx < images[0].data.length() {
              images[0].data[near_idx].to_int().to_double()
            } else {
              0.0
            },
          )
          far_arr.push(
            if far_idx < images[1].data.length() {
              images[1].data[far_idx].to_int().to_double()
            } else {
              0.0
            },
          )
        }
        let near_f = if focus_positions.length() > 0 {
          focus_positions[0]
        } else {
          1.0
        }
        let far_f = if focus_positions.length() > 1 {
          focus_positions[1]
        } else {
          10.0
        }
        estimate_depth_relative_blur(near_arr, far_arr, w, h, near_f, far_f)
      } else {
        { width: w, height: h, depths: [], valid: [], }
      }
    Hybrid => {
      let focus_depth = estimate_depth_from_focus(
        sharpness_maps, focus_positions, w, h,
      )
      if images.length() >= 2 {
        let near_arr : Array[Double] = []
        let far_arr : Array[Double] = []
        for i in 0..<(w * h) {
          let near_idx = i * images[0].channels
          let far_idx = i * images[1].channels
          near_arr.push(
            if near_idx < images[0].data.length() {
              images[0].data[near_idx].to_int().to_double()
            } else {
              0.0
            },
          )
          far_arr.push(
            if far_idx < images[1].data.length() {
              images[1].data[far_idx].to_int().to_double()
            } else {
              0.0
            },
          )
        }
        let near_f = if focus_positions.length() > 0 {
          focus_positions[0]
        } else {
          1.0
        }
        let far_f = if focus_positions.length() > 1 {
          focus_positions[1]
        } else {
          10.0
        }
        let blur_depth = estimate_depth_relative_blur(
          near_arr, far_arr, w, h, near_f, far_f,
        )
        // 混合：50% focus + 50% blur
        let blended : Array[Double] = []
        for i in 0..<(w * h) {
          let fd = if i < focus_depth.depths.length() {
            focus_depth.depths[i]
          } else {
            0.0
          }
          let bd = if i < blur_depth.depths.length() {
            blur_depth.depths[i]
          } else {
            0.0
          }
          blended.push(fd * 0.5 + bd * 0.5)
        }
        { width: w, height: h, depths: blended, valid: focus_depth.valid, }
      } else {
        focus_depth
      }
    }
  }
  depth_post_process(raw_depth, params.post_process)
}
