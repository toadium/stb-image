// 散景渲染 — 光圈模拟/景深模糊/散景效果
// Bokeh rendering: aperture simulation / depth-of-field blur / bokeh effects
//
// Phase 16 v381: 计算摄影大扩展 — 散景渲染。

///|
/// 光圈形状。
/// Aperture shape.
pub(all) enum ApertureShape {
  Circular // 圆形
  Hexagonal // 六边形
  Octagonal // 八边形
  CatEye // 猫眼形（边缘变形）
} derive(Eq, @debug.Debug)

///|
pub extend ApertureShape with @debug.Debug::{to_repr}

///|
pub extend ApertureShape with Eq::{not_equal, equal}

///|
/// 散景渲染质量。
/// Bokeh rendering quality.
pub(all) enum BokehQuality {
  Fast // 快速（小核）
  Medium // 中等
  High // 高质量（大核）
} derive(Eq, @debug.Debug)

///|
pub extend BokehQuality with @debug.Debug::{to_repr}

///|
pub extend BokehQuality with Eq::{not_equal, equal}

///|
/// 散景渲染参数。
/// Bokeh rendering parameters.
pub(all) struct BokehParams {
  aperture_shape : ApertureShape
  aperture_f_number : Double // 光圈 f 值
  focal_length : Double // 焦距（mm）
  focus_distance : Double // 对焦距离（mm）
  blur_strength : Double // 模糊强度倍率
  quality : BokehQuality
  circle_of_confusion : Double // 弥散圆直径（mm）
} derive(Eq, @debug.Debug)

///|
pub extend BokehParams with @debug.Debug::{to_repr}

///|
pub extend BokehParams with Eq::{not_equal, equal}

///|
/// 散景渲染结果。
/// Bokeh rendering result.
pub(all) struct BokehResult {
  image : @types.Image // 渲染后图像
  max_blur_radius : Int // 最大模糊半径
  blur_map : Array[Double] // 每像素模糊半径
} derive(Eq, @debug.Debug)

///|
pub extend BokehResult with @debug.Debug::{to_repr}

///|
pub extend BokehResult with Eq::{not_equal, equal}

///|
/// 计算弥散圆直径。
/// Compute circle of confusion diameter.
/// CoC = |s - f| / s * D, where D = f / N
pub fn compute_circle_of_confusion(
  focus_distance : Double,
  focal_length : Double,
  aperture_f_number : Double,
  pixel_distance : Double,
) -> Double {
  let s = pixel_distance
  let f = focal_length
  let n = aperture_f_number
  if s <= 0.0 || f <= 0.0 || n <= 0.0 {
    return 0.0
  }
  // 光圈直径 D = f / N
  let d = f / n
  // 弥散圆: CoC = D * |s - f_focus| / s
  // 简化：用对焦距离和物体距离的差值
  let coc = d * (s - focus_distance).abs() / s
  if coc < 0.0 {
    0.0
  } else {
    coc
  }
}

///|
/// 生成光圈形状掩模。
/// Generate aperture shape mask.
pub fn generate_aperture_mask(
  shape : ApertureShape,
  radius : Int,
) -> Array[Array[Double]] {
  if radius <= 0 {
    return []
  }
  let size = radius * 2 + 1
  let mask : Array[Array[Double]] = []
  for y in 0..<size {
    let row : Array[Double] = []
    for x in 0..<size {
      let dx = x - radius
      let dy = y - radius
      let dist = (dx * dx + dy * dy).to_double().sqrt()
      match shape {
        Circular =>
          if dist <= radius.to_double() {
            row.push(1.0)
          } else {
            row.push(0.0)
          }
        Hexagonal => {
          // 六边形：检查是否在六边形内
          let angle = @math.atan2(dy.to_double(), dx.to_double())
          let r = radius.to_double()
          // 六边形半径随角度变化
          let sector = (angle * 3.0 / @math.PI).to_int()
          let sector_angle = sector.to_double() * @math.PI / 3.0
          let hex_r = r * 0.866 / @math.cos(angle - sector_angle)
          if dist <= hex_r {
            row.push(1.0)
          } else {
            row.push(0.0)
          }
        }
        Octagonal => {
          // 八边形：检查是否在八边形内
          let angle = @math.atan2(dy.to_double(), dx.to_double())
          let r = radius.to_double()
          let sector = (angle * 4.0 / @math.PI).to_int()
          let sector_angle = sector.to_double() * @math.PI / 4.0
          let oct_r = r * 0.9239 / @math.cos(angle - sector_angle)
          if dist <= oct_r {
            row.push(1.0)
          } else {
            row.push(0.0)
          }
        }
        CatEye => {
          // 猫眼：圆形但水平方向压缩
          let compressed_dx = dx.to_double() * 0.7
          let cat_dist = (compressed_dx * compressed_dx +
          dy.to_double() * dy.to_double()).sqrt()
          if cat_dist <= radius.to_double() {
            row.push(1.0)
          } else {
            row.push(0.0)
          }
        }
      }
    }
    mask.push(row)
  }
  mask
}

///|
/// 深度感知模糊：根据深度图计算每像素模糊半径。
/// Depth-aware blur: compute per-pixel blur radius from depth map.
pub fn compute_blur_map(
  depth : DepthMap,
  focus_distance : Double,
  focal_length : Double,
  aperture_f_number : Double,
  blur_strength : Double,
) -> Array[Double] {
  let w = depth.width
  let h = depth.height
  let blur_map : Array[Double] = []
  let d = focal_length / aperture_f_number
  for i in 0..<(w * h) {
    if depth.valid[i] {
      let pixel_depth = depth.depths[i]
      let coc = compute_circle_of_confusion(
        focus_distance, focal_length, aperture_f_number, pixel_depth,
      )
      let blur = coc * blur_strength
      blur_map.push(blur)
    } else {
      blur_map.push(0.0)
    }
  }
  // 归一化模糊半径到像素单位
  let mut max_blur = 0.0
  for i in 0..<blur_map.length() {
    if blur_map[i] > max_blur {
      max_blur = blur_map[i]
    }
  }
  if max_blur > 0.0 {
    let normalized : Array[Double] = []
    for i in 0..<blur_map.length() {
      normalized.push(blur_map[i] / max_blur * d)
    }
    normalized
  } else {
    blur_map
  }
}

///|
/// 圆形散景模糊。
/// Circular bokeh blur.
pub fn bokeh_blur_circular(
  image : @types.Image,
  blur_map : Array[Double],
  max_radius : Int,
) -> @types.Image {
  let w = image.width
  let h = image.height
  let ch = image.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let blur = if idx < blur_map.length() { blur_map[idx] } else { 0.0 }
      let radius = (blur * max_radius.to_double())
        .to_int()
        .clamp(min=0, max=max_radius)
      if radius <= 0 {
        for c in 0..<ch {
          let pi = (y * w + x) * ch + c
          data.push(image.data[pi])
        }
        continue
      }
      // 圆形核卷积
      for c in 0..<ch {
        let mut sum = 0.0
        let mut count = 0.0
        for dy in [-radius, 0, radius] {
          for dx in [-radius, 0, radius] {
            let nx = x + dx
            let ny = y + dy
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              let dist = (dx * dx + dy * dy).to_double().sqrt()
              if dist <= radius.to_double() {
                let pi = (ny * w + nx) * ch + c
                sum = sum + image.data[pi].to_int().to_double()
                count = count + 1.0
              }
            }
          }
        }
        if count > 0.0 {
          data.push((sum / count).to_int().clamp(min=0, max=255).to_byte())
        } else {
          let pi = (y * w + x) * ch + c
          data.push(image.data[pi])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 多边形散景模糊。
/// Polygonal bokeh blur.
pub fn bokeh_blur_polygonal(
  image : @types.Image,
  blur_map : Array[Double],
  max_radius : Int,
  shape : ApertureShape,
) -> @types.Image {
  let w = image.width
  let h = image.height
  let ch = image.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let idx = y * w + x
      let blur = if idx < blur_map.length() { blur_map[idx] } else { 0.0 }
      let radius = (blur * max_radius.to_double())
        .to_int()
        .clamp(min=0, max=max_radius)
      if radius <= 0 {
        for c in 0..<ch {
          let pi = (y * w + x) * ch + c
          data.push(image.data[pi])
        }
        continue
      }
      // 使用光圈掩模
      let mask = generate_aperture_mask(shape, radius)
      let mask_size = radius * 2 + 1
      for c in 0..<ch {
        let mut sum = 0.0
        let mut count = 0.0
        for my in 0..<mask_size {
          for mx in 0..<mask_size {
            let nx = x + mx - radius
            let ny = y + my - radius
            if nx >= 0 && nx < w && ny >= 0 && ny < h {
              if mask[my][mx] > 0.0 {
                let pi = (ny * w + nx) * ch + c
                sum = sum + image.data[pi].to_int().to_double() * mask[my][mx]
                count = count + mask[my][mx]
              }
            }
          }
        }
        if count > 0.0 {
          data.push((sum / count).to_int().clamp(min=0, max=255).to_byte())
        } else {
          let pi = (y * w + x) * ch + c
          data.push(image.data[pi])
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 模拟镜头模糊。
/// Simulate lens blur.
pub fn simulate_lens_blur(
  image : @types.Image,
  depth : DepthMap,
  params : BokehParams,
) -> BokehResult {
  let blur_map = compute_blur_map(
    depth,
    params.focus_distance,
    params.focal_length,
    params.aperture_f_number,
    params.blur_strength,
  )
  let max_radius = match params.quality {
    Fast => 5
    Medium => 10
    High => 20
  }
  let result = match params.aperture_shape {
    Circular => bokeh_blur_circular(image, blur_map, max_radius)
    Hexagonal => bokeh_blur_polygonal(image, blur_map, max_radius, Hexagonal)
    Octagonal => bokeh_blur_polygonal(image, blur_map, max_radius, Octagonal)
    CatEye => bokeh_blur_polygonal(image, blur_map, max_radius, CatEye)
  }
  { image: result, max_blur_radius: max_radius, blur_map, }
}

///|
/// 估计散景强度。
/// Estimate bokeh strength from depth distribution.
pub fn estimate_bokeh_strength(depth : DepthMap) -> Double {
  let w = depth.width
  let h = depth.height
  let mut min_d = 1000000000.0
  let mut max_d = 0.0
  let mut count = 0
  for i in 0..<(w * h) {
    if depth.valid[i] {
      let v = depth.depths[i]
      if v < min_d {
        min_d = v
      }
      if v > max_d {
        max_d = v
      }
      count = count + 1
    }
  }
  if count == 0 || max_d <= min_d {
    return 1.0
  }
  // 深度范围越大，散景越强
  let range = max_d - min_d
  let mean = (min_d + max_d) / 2.0
  if mean > 0.0 {
    (range / mean).clamp(min=0.1, max=10.0)
  } else {
    1.0
  }
}

///|
/// 散景渲染流水线。
/// Bokeh rendering pipeline.
pub fn bokeh_pipeline(
  image : @types.Image,
  depth : DepthMap,
  params : BokehParams,
) -> BokehResult {
  // 1. 估计散景强度（如果未设置则自动估计）
  let actual_strength = if params.blur_strength <= 0.0 {
    let estimated = estimate_bokeh_strength(depth)
    estimated
  } else {
    params.blur_strength
  }
  // 2. 更新参数
  let updated_params : BokehParams = {
    aperture_shape: params.aperture_shape,
    aperture_f_number: params.aperture_f_number,
    focal_length: params.focal_length,
    focus_distance: params.focus_distance,
    blur_strength: actual_strength,
    quality: params.quality,
    circle_of_confusion: params.circle_of_confusion,
  }
  // 3. 模拟镜头模糊
  simulate_lens_blur(image, depth, updated_params)
}

///|
/// 创建默认散景参数。
/// Create default bokeh parameters.
pub fn default_bokeh_params(
  shape : ApertureShape,
  quality : BokehQuality,
) -> BokehParams {
  {
    aperture_shape: shape,
    aperture_f_number: 2.8,
    focal_length: 50.0,
    focus_distance: 2000.0,
    blur_strength: 1.0,
    quality,
    circle_of_confusion: 0.02,
  }
}
