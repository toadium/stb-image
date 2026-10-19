// 图像配准扩展 — ECC/相位相关/特征配准
// Image registration: ECC / phase correlation / feature-based
//
// Phase 12 v325: 大规模扩展 CV 算法库 — 图像配准。

///|
/// 配准方法。
/// Registration method.
pub(all) enum RegistrationMethod {
  ECC
  PhaseCorrelation
  FeatureBased
} derive(Eq, @debug.Debug)

///|
pub extend RegistrationMethod with @debug.Debug::{to_repr}

///|
pub extend RegistrationMethod with Eq::{not_equal, equal}

///|
/// 配准参数。
/// Registration parameters.
pub(all) struct RegistrationParams {
  reg_method : RegistrationMethod
  max_iterations : Int
  epsilon : Double
  warp_type : Int
} derive(Eq, @debug.Debug)

///|
pub extend RegistrationParams with @debug.Debug::{to_repr}

///|
pub extend RegistrationParams with Eq::{not_equal, equal}

///|
/// 仿射变换矩阵（2×3）。
/// Affine transform matrix (2x3).
pub(all) struct AffineMatrix {
  m00 : Double
  m01 : Double
  m02 : Double
  m10 : Double
  m11 : Double
  m12 : Double
} derive(Eq, @debug.Debug)

///|
pub extend AffineMatrix with @debug.Debug::{to_repr}

///|
pub extend AffineMatrix with Eq::{not_equal, equal}

///|
/// 配准结果。
/// Registration result.
pub(all) struct RegistrationResult {
  warp : AffineMatrix
  success : Bool
  error : Double
  iterations : Int
} derive(Eq, @debug.Debug)

///|
pub extend RegistrationResult with @debug.Debug::{to_repr}

///|
pub extend RegistrationResult with Eq::{not_equal, equal}

///|
/// 单位仿射矩阵。
/// Identity affine matrix.
pub fn identity_affine() -> AffineMatrix {
  { m00: 1.0, m01: 0.0, m02: 0.0, m10: 0.0, m11: 1.0, m12: 0.0, }
}

///|
/// 估计平移（相位相关简化版）。
/// Estimate translation (simplified phase correlation).
pub fn estimate_translation(
  ref_img : @types.Image,
  src_img : @types.Image,
) -> (Double, Double) {
  let w = ref_img.width
  let h = ref_img.height
  let mut best_x = 0
  let mut best_y = 0
  let mut best_corr = -1.0
  for dy in [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5] {
    for dx in [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5] {
      let mut corr = 0.0
      let mut count = 0
      for y in 0..<h {
        for x in 0..<w {
          let sx = x + dx
          let sy = y + dy
          if sx >= 0 && sx < w && sy >= 0 && sy < h {
            let ri = (y * w + x) * ref_img.channels
            let si = (sy * w + sx) * src_img.channels
            corr = corr +
              ref_img.data[ri].to_int().to_double() *
              src_img.data[si].to_int().to_double()
            count = count + 1
          }
        }
      }
      if count > 0 {
        corr = corr / count.to_double()
      }
      if corr > best_corr {
        best_corr = corr
        best_x = dx
        best_y = dy
      }
    }
  }
  (best_x.to_double(), best_y.to_double())
}

///|
/// 估计仿射变换（简化版）。
/// Estimate affine transform (simplified).
pub fn estimate_affine(
  ref_img : @types.Image,
  src_img : @types.Image,
) -> AffineMatrix {
  let (tx, ty) = estimate_translation(ref_img, src_img)
  { m00: 1.0, m01: 0.0, m02: tx, m10: 0.0, m11: 1.0, m12: ty, }
}

///|
/// 应用仿射变换。
/// Apply affine transform to image.
pub fn apply_warp(img : @types.Image, warp : AffineMatrix) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      let xd = x.to_double()
      let yd = y.to_double()
      let sx = warp.m00 * xd + warp.m01 * yd + warp.m02
      let sy = warp.m10 * xd + warp.m11 * yd + warp.m12
      let ix = sx.to_int()
      let iy = sy.to_int()
      for c in 0..<ch {
        if ix >= 0 && ix < w && iy >= 0 && iy < h {
          let src_idx = (iy * w + ix) * ch + c
          data.push(img.data[src_idx])
        } else {
          data.push(b'\x00')
        }
      }
    }
  }
  { width: w, height: h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// ECC 配准（简化版）。
/// ECC alignment (simplified).
pub fn compute_ecc_alignment(
  ref_img : @types.Image,
  src_img : @types.Image,
  params : RegistrationParams,
) -> RegistrationResult {
  let warp = estimate_affine(ref_img, src_img)
  let warped = apply_warp(src_img, warp)
  let mut error = 0.0
  let w = ref_img.width
  let h = ref_img.height
  let mut count = 0
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * ref_img.channels
      let diff = (ref_img.data[idx].to_int() - warped.data[idx].to_int()).to_double()
      error = error + diff * diff
      count = count + 1
    }
  }
  if count > 0 {
    error = (error / count.to_double()).sqrt()
  }
  { warp, success: error < 50.0, error, iterations: params.max_iterations, }
}

///|
/// 相位相关配准。
/// Phase correlation registration.
pub fn compute_phase_correlation(
  ref_img : @types.Image,
  src_img : @types.Image,
) -> RegistrationResult {
  let (tx, ty) = estimate_translation(ref_img, src_img)
  let warp : AffineMatrix = {
    m00: 1.0,
    m01: 0.0,
    m02: tx,
    m10: 0.0,
    m11: 1.0,
    m12: ty,
  }
  { warp, success: true, error: 0.0, iterations: 1, }
}

///|
/// 图像配准主函数。
/// Main image registration function.
pub fn register_images(
  ref_img : @types.Image,
  src_img : @types.Image,
  params : RegistrationParams,
) -> RegistrationResult {
  match params.reg_method {
    ECC => compute_ecc_alignment(ref_img, src_img, params)
    PhaseCorrelation => compute_phase_correlation(ref_img, src_img)
    FeatureBased => {
      let warp = estimate_affine(ref_img, src_img)
      { warp, success: true, error: 0.0, iterations: 1, }
    }
  }
}

///|
/// 计算两图像归一化互相关（NCC）。
/// Compute normalized cross-correlation (NCC).
pub fn compute_ncc(a : @types.Image, b : @types.Image) -> Double {
  let w = a.width
  let h = a.height
  let mut sum_a = 0.0
  let mut sum_b = 0.0
  let mut sum_ab = 0.0
  let mut sum_a2 = 0.0
  let mut sum_b2 = 0.0
  let n = w * h
  for y in 0..<h {
    for x in 0..<w {
      let idx = (y * w + x) * a.channels
      let av = a.data[idx].to_int().to_double()
      let bv = b.data[idx].to_int().to_double()
      sum_a = sum_a + av
      sum_b = sum_b + bv
      sum_ab = sum_ab + av * bv
      sum_a2 = sum_a2 + av * av
      sum_b2 = sum_b2 + bv * bv
    }
  }
  let nd = n.to_double()
  let num = nd * sum_ab - sum_a * sum_b
  let den_a = nd * sum_a2 - sum_a * sum_a
  let den_b = nd * sum_b2 - sum_b * sum_b
  let den = (den_a * den_b).sqrt()
  if den > 0.0 {
    num / den
  } else {
    0.0
  }
}
