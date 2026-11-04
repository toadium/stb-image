// 视频质量 — VMAF/PSNR/SSIM
// Video quality: VMAF / PSNR / SSIM
//
// Phase 17 v404: 视频处理大扩展 — 视频质量评估。

///|
/// 视频质量度量方法。
/// Video quality metric.
pub(all) enum VideoQualityMetric {
  PSNRMetric // PSNR
  SSIMMetric // SSIM
  VMAFMetric // VMAF (简化)
} derive(Eq, @debug.Debug)

///|
pub extend VideoQualityMetric with @debug.Debug::{to_repr}

///|
pub extend VideoQualityMetric with Eq::{not_equal, equal}

///|
/// 视频质量评估结果。
/// Video quality assessment result.
pub(all) struct VideoQualityResult {
  metric : VideoQualityMetric
  score : Double // 质量分数
  per_frame_scores : Array[Double] // 每帧分数
  mean_score : Double // 平均分数
  min_score : Double // 最低分数
  max_score : Double // 最高分数
} derive(Eq, @debug.Debug)

///|
pub extend VideoQualityResult with @debug.Debug::{to_repr}

///|
pub extend VideoQualityResult with Eq::{not_equal, equal}

///|
/// 计算 PSNR（峰值信噪比）。
/// Compute PSNR (Peak Signal-to-Noise Ratio).
pub fn compute_psnr(
  reference : @types.Image,
  distorted : @types.Image,
) -> Double {
  let w = reference.width
  let h = reference.height
  let ch = reference.channels
  let mut mse = 0.0
  let n = w * h * ch
  if n == 0 {
    return 0.0
  }
  for i in 0..<n {
    let diff = reference.data[i].to_double() - distorted.data[i].to_double()
    mse = mse + diff * diff
  }
  mse = mse / n.to_double()
  if mse < 0.0001 {
    return 100.0
  }
  10.0 * @math.log10(255.0 * 255.0 / mse)
}

///|
/// 计算单窗口 SSIM。
/// Compute SSIM for a single window.
fn compute_ssim_window(
  ref_data : @types.Image,
  dis_data : @types.Image,
  x0 : Int32,
  y0 : Int32,
  window_size : Int32,
) -> Double {
  let w = ref_data.width
  let ch = ref_data.channels
  let c1 = 0.01 * 255.0 * (0.01 * 255.0)
  let c2 = 0.03 * 255.0 * (0.03 * 255.0)
  let mut sum_ref = 0.0
  let mut sum_dis = 0.0
  let mut sum_ref_sq = 0.0
  let mut sum_dis_sq = 0.0
  let mut sum_ref_dis = 0.0
  let count = window_size * window_size
  for dy in 0..<window_size {
    for dx in 0..<window_size {
      let x = x0 + dx
      let y = y0 + dy
      if x >= w || y >= ref_data.height {
        continue
      }
      let idx = (y * w + x) * ch
      let r = ref_data.data[idx].to_double()
      let d = dis_data.data[idx].to_double()
      sum_ref = sum_ref + r
      sum_dis = sum_dis + d
      sum_ref_sq = sum_ref_sq + r * r
      sum_dis_sq = sum_dis_sq + d * d
      sum_ref_dis = sum_ref_dis + r * d
    }
  }
  let mu_r = sum_ref / count.to_double()
  let mu_d = sum_dis / count.to_double()
  let var_r = sum_ref_sq / count.to_double() - mu_r * mu_r
  let var_d = sum_dis_sq / count.to_double() - mu_d * mu_d
  let cov = sum_ref_dis / count.to_double() - mu_r * mu_d
  let numerator = (2.0 * mu_r * mu_d + c1) * (2.0 * cov + c2)
  let denominator = (mu_r * mu_r + mu_d * mu_d + c1) * (var_r + var_d + c2)
  if denominator > 0.0 {
    numerator / denominator
  } else {
    0.0
  }
}

///|
/// 计算 SSIM（结构相似性指数）。
/// Compute SSIM (Structural Similarity Index).
pub fn compute_ssim(
  reference : @types.Image,
  distorted : @types.Image,
) -> Double {
  let w = reference.width
  let h = reference.height
  let window_size = 8
  if w < window_size || h < window_size {
    return compute_ssim_window(
      reference,
      distorted,
      0,
      0,
      if w < h {
        w
      } else {
        h
      },
    )
  }
  let mut total_ssim = 0.0
  let mut count = 0
  let step = window_size
  let mut y = 0
  while y + window_size <= h {
    let mut x = 0
    while x + window_size <= w {
      total_ssim = total_ssim +
        compute_ssim_window(reference, distorted, x, y, window_size)
      count = count + 1
      x = x + step
    }
    y = y + step
  }
  if count > 0 {
    total_ssim / count.to_double()
  } else {
    0.0
  }
}

///|
/// 计算 MS-SSIM（多尺度结构相似性）。
/// Compute MS-SSIM (Multi-Scale Structural Similarity).
pub fn compute_msssim(
  reference : @types.Image,
  distorted : @types.Image,
) -> Double {
  let weights = [0.0448, 0.2856, 0.3001, 0.2363, 0.1333]
  let mut result = 1.0
  let mut current_ref = reference
  let mut current_dis = distorted
  for i in 0..<5 {
    let ssim_val = compute_ssim(current_ref, current_dis)
    result = result * @math.pow(ssim_val, weights[i])
    let new_w = current_ref.width / 2
    let new_h = current_ref.height / 2
    if new_w < 4 || new_h < 4 {
      break
    }
    current_ref = downsample(current_ref)
    current_dis = downsample(current_dis)
  }
  result.clamp(min=0.0, max=1.0)
}

///|
/// 下采样图像（2x降采样）。
/// Downsample image (2x downsample).
fn downsample(img : @types.Image) -> @types.Image {
  let w = img.width
  let h = img.height
  let ch = img.channels
  let new_w = w / 2
  let new_h = h / 2
  let data : Array[Byte] = []
  for y in 0..<new_h {
    for x in 0..<new_w {
      for c in 0..<ch {
        let idx = (y * 2 * w + x * 2) * ch + c
        let idx_r = (y * 2 * w + x * 2 + 1) * ch + c
        let idx_d = ((y * 2 + 1) * w + x * 2) * ch + c
        let idx_dr = ((y * 2 + 1) * w + x * 2 + 1) * ch + c
        let val = (
            img.data[idx].to_double() +
            img.data[idx_r].to_double() +
            img.data[idx_d].to_double() +
            img.data[idx_dr].to_double()
          ) /
          4.0
        data.push(val.clamp(min=0.0, max=255.0).to_int().to_byte())
      }
    }
  }
  { width: new_w, height: new_h, channels: ch, data: Bytes::from_array(data), }
}

///|
/// 计算 VMAF 分数（简化版：基于 PSNR 和 SSIM 的加权组合）。
/// Compute VMAF score (simplified: weighted combination of PSNR and SSIM).
pub fn compute_vmaf_score(
  reference : @types.Image,
  distorted : @types.Image,
) -> Double {
  let psnr = compute_psnr(reference, distorted)
  let ssim = compute_ssim(reference, distorted)
  let psnr_norm = (psnr / 100.0).clamp(min=0.0, max=1.0)
  0.5 * psnr_norm + 0.5 * ssim
}

///|
/// 计算单帧质量。
/// Compute single frame quality.
pub fn compute_frame_quality(
  reference : @types.Image,
  distorted : @types.Image,
  metric : VideoQualityMetric,
) -> Double {
  match metric {
    PSNRMetric => {
      let psnr = compute_psnr(reference, distorted)
      (psnr / 100.0).clamp(min=0.0, max=1.0)
    }
    SSIMMetric => compute_ssim(reference, distorted)
    VMAFMetric => compute_vmaf_score(reference, distorted)
  }
}

///|
/// 计算视频质量。
/// Compute video quality.
pub fn compute_video_quality(
  reference : Array[@types.Image],
  distorted : Array[@types.Image],
  metric : VideoQualityMetric,
) -> VideoQualityResult {
  let n = reference.length()
  let per_frame : Array[Double] = []
  let mut sum_score = 0.0
  let mut min_score = 1.0
  let mut max_score = 0.0
  for i in 0..<n {
    let score = if i < distorted.length() {
      compute_frame_quality(reference[i], distorted[i], metric)
    } else {
      0.0
    }
    per_frame.push(score)
    sum_score = sum_score + score
    if score < min_score {
      min_score = score
    }
    if score > max_score {
      max_score = score
    }
  }
  let mean = if n > 0 { sum_score / n.to_double() } else { 0.0 }
  {
    metric,
    score: mean,
    per_frame_scores: per_frame,
    mean_score: mean,
    min_score,
    max_score,
  }
}

///|
/// 质量评估流水线：多度量综合评估。
/// Quality assessment pipeline: multi-metric comprehensive assessment.
pub fn quality_pipeline(
  reference : Array[@types.Image],
  distorted : Array[@types.Image],
) -> Array[VideoQualityResult] {
  let results : Array[VideoQualityResult] = []
  results.push(compute_video_quality(reference, distorted, PSNRMetric))
  results.push(compute_video_quality(reference, distorted, SSIMMetric))
  results.push(compute_video_quality(reference, distorted, VMAFMetric))
  results
}
