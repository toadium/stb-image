// 医学可视化 — MIP/VR/MPR/CPR
// Medical visualization
//
// Phase 14 v358: 医学影像大扩展 — 医学可视化。

///|
/// 可视化模式。
/// Visualization mode.
pub(all) enum MedVizMode {
  MIP
  MinIP
  VolumeRendering
  SurfaceRendering
  MPR
  CPR
} derive(Eq, @debug.Debug)

///|
pub extend MedVizMode with @debug.Debug::{to_repr}

///|
pub extend MedVizMode with Eq::{not_equal, equal}

///|
/// MPR 切片方向。
/// MPR slice orientation.
pub(all) enum MPROrientation {
  Axial
  Coronal
  Sagittal
} derive(Eq, @debug.Debug)

///|
pub extend MPROrientation with @debug.Debug::{to_repr}

///|
pub extend MPROrientation with Eq::{not_equal, equal}

///|
/// 可视化配置。
/// Visualization configuration.
pub(all) struct MedVizConfig {
  mode : MedVizMode
  window_center : Double
  window_width : Double
  opacity : Double
} derive(Eq, @debug.Debug)

///|
pub extend MedVizConfig with @debug.Debug::{to_repr}

///|
pub extend MedVizConfig with Eq::{not_equal, equal}

///|
/// 窗宽窗位调整。
/// Window level adjustment.
pub fn medviz_window_level(
  image : Array[Double],
  center : Double,
  width : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  let min_val = center - width / 2.0
  let max_val = center + width / 2.0
  for i in 0..<image.length() {
    let v = image[i]
    if v <= min_val {
      result.push(0.0)
    } else if v >= max_val {
      result.push(1.0)
    } else {
      result.push((v - min_val) / width)
    }
  }
  result
}

///|
/// MPR 切片提取。
/// MPR slice extraction.
pub fn medviz_mpr_slice(
  volume : Array[Double],
  width : Int,
  height : Int,
  depth : Int,
  orientation : MPROrientation,
  slice_idx : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  match orientation {
    Axial =>
      if slice_idx >= 0 && slice_idx < depth {
        for y in 0..<height {
          for x in 0..<width {
            let idx = slice_idx * width * height + y * width + x
            result.push(if idx < volume.length() { volume[idx] } else { 0.0 })
          }
        }
      }
    Coronal =>
      if slice_idx >= 0 && slice_idx < height {
        for z in 0..<depth {
          for x in 0..<width {
            let idx = z * width * height + slice_idx * width + x
            result.push(if idx < volume.length() { volume[idx] } else { 0.0 })
          }
        }
      }
    Sagittal =>
      if slice_idx >= 0 && slice_idx < width {
        for z in 0..<depth {
          for y in 0..<height {
            let idx = z * width * height + y * width + slice_idx
            result.push(if idx < volume.length() { volume[idx] } else { 0.0 })
          }
        }
      }
  }
  result
}

///|
/// CPR 中心线提取（简化）。
/// CPR centerline extraction (simplified).
pub fn medviz_cpr_centerline(
  volume : Array[Double],
  width : Int,
  height : Int,
  depth : Int,
  path_points : Array[(Int, Int, Int)],
) -> Array[Double] {
  let result : Array[Double] = []
  for i in 0..<path_points.length() {
    let (x, y, z) = path_points[i]
    if x >= 0 && y >= 0 && z >= 0 && z < depth {
      let idx = z * width * height + y * width + x
      result.push(if idx < volume.length() { volume[idx] } else { 0.0 })
    } else {
      result.push(0.0)
    }
  }
  result
}

///|
/// 伪彩色映射。
/// Pseudo-color mapping.
pub fn medviz_pseudo_color(
  image : Array[Double],
  color_scheme : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  for i in 0..<image.length() {
    let v = image[i]
    let colored = match color_scheme {
      0 => v
      1 => if v < 0.5 { 2.0 * v } else { 1.0 }
      2 =>
        if v < 0.33 {
          3.0 * v
        } else if v < 0.67 {
          1.0
        } else {
          1.0 - 3.0 * (v - 0.67)
        }
      _ => v * v
    }
    result.push(colored)
  }
  result
}

///|
/// 体绘制（光线投射简化）。
/// Volume rendering (simplified ray casting).
pub fn medviz_volume_render(
  volume : Array[Double],
  width : Int,
  height : Int,
  depth : Int,
  config : MedVizConfig,
) -> Array[Double] {
  let result : Array[Double] = []
  let opacity = config.opacity
  for y in 0..<height {
    for x in 0..<width {
      let mut acc = 0.0
      let mut remaining = 1.0
      for z in 0..<depth {
        let idx = z * width * height + y * width + x
        if idx < volume.length() {
          let v = volume[idx]
          let normalized = if config.window_width > 0.0 {
            let min_val = config.window_center - config.window_width / 2.0
            let max_val = config.window_center + config.window_width / 2.0
            if v <= min_val {
              0.0
            } else if v >= max_val {
              1.0
            } else {
              (v - min_val) / config.window_width
            }
          } else {
            v
          }
          acc = acc + normalized * opacity * remaining
          remaining = remaining * (1.0 - opacity)
          if remaining < 0.01 {
            break
          }
        }
      }
      result.push(acc)
    }
  }
  result
}

///|
/// 深度着色。
/// Depth shading.
pub fn medviz_depth_shading(
  volume : Array[Double],
  width : Int,
  height : Int,
  depth : Int,
  threshold : Double,
) -> Array[Double] {
  let result : Array[Double] = []
  for y in 0..<height {
    for x in 0..<width {
      let mut first_hit = -1.0
      for z in 0..<depth {
        let idx = z * width * height + y * width + x
        if idx < volume.length() && volume[idx] > threshold {
          first_hit = z.to_double() / depth.to_double()
          break
        }
      }
      result.push(first_hit)
    }
  }
  result
}

///|
/// 梯度着色。
/// Gradient shading.
pub fn medviz_gradient_shading(
  volume : Array[Double],
  width : Int,
  height : Int,
  depth : Int,
) -> Array[Double] {
  let result : Array[Double] = []
  for z in 0..<depth {
    for y in 0..<height {
      for x in 0..<width {
        let idx = z * width * height + y * width + x
        let v = if idx < volume.length() { volume[idx] } else { 0.0 }
        let dx = if x > 0 && idx - 1 < volume.length() {
          v - volume[idx - 1]
        } else {
          0.0
        }
        let dy = if y > 0 && idx - width < volume.length() {
          v - volume[idx - width]
        } else {
          0.0
        }
        let dz = if z > 0 && idx - width * height < volume.length() {
          v - volume[idx - width * height]
        } else {
          0.0
        }
        result.push((dx * dx + dy * dy + dz * dz).sqrt())
      }
    }
  }
  result
}
