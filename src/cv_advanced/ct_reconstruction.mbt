// CT 重建 — FBP/迭代重建/ART
// CT reconstruction
//
// Phase 14 v347: 医学影像大扩展 — CT 重建。

///|
/// 重建方法。
/// Reconstruction method.
pub(all) enum ReconstructionMethod {
  FBP
  Iterative
  ART
  SART
} derive(Eq, @debug.Debug)

///|
pub extend ReconstructionMethod with @debug.Debug::{to_repr}

///|
pub extend ReconstructionMethod with Eq::{not_equal, equal}

///|
/// CT 投影数据。
/// CT projection data.
pub(all) struct CTProjection {
  angles : Array[Double]
  detector_count : Int
  projection_data : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend CTProjection with @debug.Debug::{to_repr}

///|
pub extend CTProjection with Eq::{not_equal, equal}

///|
/// CT 配置。
/// CT configuration.
pub(all) struct CTConfig {
  image_size : Int
  num_angles : Int
  detector_count : Int
  recon_method : ReconstructionMethod
} derive(Eq, @debug.Debug)

///|
pub extend CTConfig with @debug.Debug::{to_repr}

///|
pub extend CTConfig with Eq::{not_equal, equal}

///|
/// Radon 变换（前向投影）。
/// Radon transform (forward projection).
pub fn ct_radon_transform(
  image : Array[Double],
  image_size : Int,
  angles : Array[Double],
) -> CTProjection {
  let num_angles = angles.length()
  let detector_count = image_size
  let projection_data : Array[Double] = []
  for a_idx in 0..<num_angles {
    let angle = angles[a_idx]
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    for d in 0..<detector_count {
      let t = d.to_double() - detector_count.to_double() / 2.0
      let mut sum = 0.0
      let mut count = 0
      for s_idx in 0..<detector_count {
        let s = s_idx.to_double() - detector_count.to_double() / 2.0
        let x = t * cos_a - s * sin_a + image_size.to_double() / 2.0
        let y = t * sin_a + s * cos_a + image_size.to_double() / 2.0
        let xi = x.to_int()
        let yi = y.to_int()
        if xi >= 0 && xi < image_size && yi >= 0 && yi < image_size {
          let idx = yi * image_size + xi
          if idx < image.length() {
            sum = sum + image[idx]
            count = count + 1
          }
        }
      }
      projection_data.push(if count > 0 { sum } else { 0.0 })
    }
  }
  CTProjection::{ angles, detector_count, projection_data, }
}

///|
/// Ramp 滤波器。
/// Ramp filter.
pub fn ct_ramp_filter(detector_count : Int, cutoff : Double) -> Array[Double] {
  let filter : Array[Double] = []
  let center = detector_count / 2
  for d in 0..<detector_count {
    let freq = (d - center).to_double()
    let ramp = freq.abs()
    let val = if ramp < cutoff { ramp } else { 0.0 }
    filter.push(val)
  }
  filter
}

///|
/// FBP 重建。
/// FBP reconstruction.
pub fn ct_fbp_reconstruct(
  projection : CTProjection,
  config : CTConfig,
) -> Array[Double] {
  let n = config.image_size
  let result : Array[Double] = []
  for _ in 0..<(n * n) {
    result.push(0.0)
  }
  let filter = ct_ramp_filter(
    config.detector_count,
    config.detector_count.to_double() / 2.0,
  )
  let num_angles = projection.angles.length()
  for a_idx in 0..<num_angles {
    let angle = projection.angles[a_idx]
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    for y in 0..<n {
      for x in 0..<n {
        let cx = x.to_double() - n.to_double() / 2.0
        let cy = y.to_double() - n.to_double() / 2.0
        let t = cx * cos_a + cy * sin_a + n.to_double() / 2.0
        let ti = t.to_int()
        if ti >= 0 && ti < config.detector_count {
          let proj_idx = a_idx * config.detector_count + ti
          if proj_idx < projection.projection_data.length() {
            let filtered = projection.projection_data[proj_idx] * filter[ti]
            let idx = y * n + x
            result[idx] = result[idx] + filtered
          }
        }
      }
    }
  }
  let norm = num_angles.to_double()
  for i in 0..<(n * n) {
    result[i] = result[i] / norm
  }
  result
}

///|
/// ART 重建（代数重建技术）。
/// ART reconstruction (Algebraic Reconstruction Technique).
pub fn ct_art_reconstruct(
  projection : CTProjection,
  config : CTConfig,
  num_iterations : Int,
) -> Array[Double] {
  let n = config.image_size
  let result : Array[Double] = []
  for _ in 0..<(n * n) {
    result.push(0.0)
  }
  let num_angles = projection.angles.length()
  for _ in 0..<num_iterations {
    for a_idx in 0..<num_angles {
      let angle = projection.angles[a_idx]
      let cos_a = @math.cos(angle)
      let sin_a = @math.sin(angle)
      for d in 0..<config.detector_count {
        let t_proj = d.to_double() - config.detector_count.to_double() / 2.0
        let proj_idx = a_idx * config.detector_count + d
        let measured = if proj_idx < projection.projection_data.length() {
          projection.projection_data[proj_idx]
        } else {
          0.0
        }
        let mut computed = 0.0
        let mut count = 0
        for s_idx in 0..<config.detector_count {
          let s = s_idx.to_double() - config.detector_count.to_double() / 2.0
          let x = t_proj * cos_a - s * sin_a + n.to_double() / 2.0
          let y = t_proj * sin_a + s * cos_a + n.to_double() / 2.0
          let xi = x.to_int()
          let yi = y.to_int()
          if xi >= 0 && xi < n && yi >= 0 && yi < n {
            let idx = yi * n + xi
            computed = computed + result[idx]
            count = count + 1
          }
        }
        if count > 0 {
          let correction = (measured - computed) / count.to_double()
          for s_idx in 0..<config.detector_count {
            let s = s_idx.to_double() - config.detector_count.to_double() / 2.0
            let x = t_proj * cos_a - s * sin_a + n.to_double() / 2.0
            let y = t_proj * sin_a + s * cos_a + n.to_double() / 2.0
            let xi = x.to_int()
            let yi = y.to_int()
            if xi >= 0 && xi < n && yi >= 0 && yi < n {
              let idx = yi * n + xi
              result[idx] = result[idx] + correction
            }
          }
        }
      }
    }
  }
  result
}

///|
/// 迭代重建。
/// Iterative reconstruction.
pub fn ct_iterative_reconstruct(
  projection : CTProjection,
  config : CTConfig,
  num_iterations : Int,
) -> Array[Double] {
  ct_art_reconstruct(projection, config, num_iterations)
}
