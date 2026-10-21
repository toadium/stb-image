// Diffusion 模型 — DDPM/DDIM/Score-based
// Diffusion models
//
// Phase 13 v339: 深度学习大扩展 — Diffusion 模型。

///|
/// Diffusion 类型。
/// Diffusion type.
pub(all) enum DiffusionType {
  DDPM
  DDIM
  ScoreBased
  StableDiffusion
} derive(Eq, @debug.Debug)

///|
pub extend DiffusionType with @debug.Debug::{to_repr}

///|
pub extend DiffusionType with Eq::{not_equal, equal}

///|
/// 噪声调度类型。
/// Noise schedule type.
pub(all) enum ScheduleType {
  Linear
  Cosine
  Quadratic
} derive(Eq, @debug.Debug)

///|
pub extend ScheduleType with @debug.Debug::{to_repr}

///|
pub extend ScheduleType with Eq::{not_equal, equal}

///|
/// Diffusion 配置。
/// Diffusion configuration.
pub(all) struct DiffusionConfig {
  num_steps : Int32
  beta_start : Double
  beta_end : Double
  schedule_type : ScheduleType
  diffusion_type : DiffusionType
} derive(Eq, @debug.Debug)

///|
pub extend DiffusionConfig with @debug.Debug::{to_repr}

///|
pub extend DiffusionConfig with Eq::{not_equal, equal}

///|
/// Diffusion 状态。
/// Diffusion state.
pub(all) struct DiffusionState {
  current_step : Int32
  x_t : Array[Double]
  noise : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend DiffusionState with @debug.Debug::{to_repr}

///|
pub extend DiffusionState with Eq::{not_equal, equal}

///|
/// 计算 beta 调度。
/// Compute beta schedule.
pub fn compute_beta_schedule(config : DiffusionConfig) -> Array[Double] {
  let betas : Array[Double] = []
  for i in 0..<config.num_steps {
    let t = i.to_double() / (config.num_steps - 1).to_double()
    let beta = match config.schedule_type {
      ScheduleType::Linear =>
        config.beta_start + t * (config.beta_end - config.beta_start)
      ScheduleType::Quadratic => {
        let start_sqrt = config.beta_start.sqrt()
        let end_sqrt = config.beta_end.sqrt()
        let val = start_sqrt + t * (end_sqrt - start_sqrt)
        val * val
      }
      ScheduleType::Cosine => {
        let angle = t * 1.5707963267948966
        config.beta_end * 0.5 * (1.0 + @math.cos(angle))
      }
    }
    betas.push(beta)
  }
  betas
}

///|
/// 计算 alpha 累积乘积。
/// Compute alpha cumulative product.
pub fn compute_alpha_cumprod(betas : Array[Double]) -> Array[Double] {
  let alpha_cumprods : Array[Double] = []
  let mut cumprod = 1.0
  for beta in betas {
    cumprod = cumprod * (1.0 - beta)
    alpha_cumprods.push(cumprod)
  }
  alpha_cumprods
}

///|
/// Diffusion 前向过程（加噪）。
/// Diffusion forward process (add noise).
pub fn diffusion_forward(
  x_0 : Array[Double],
  noise : Array[Double],
  alpha_cumprod_t : Double,
) -> Array[Double] {
  let sqrt_alpha = alpha_cumprod_t.sqrt()
  let sqrt_one_minus = (1.0 - alpha_cumprod_t).sqrt()
  let result : Array[Double] = []
  let n = x_0.length()
  let m = noise.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    result.push(sqrt_alpha * x_0[i] + sqrt_one_minus * noise[i])
  }
  result
}

///|
/// Diffusion 反向过程（去噪步）。
/// Diffusion reverse process (denoise step).
pub fn diffusion_reverse(
  x_t : Array[Double],
  predicted_noise : Array[Double],
  beta_t : Double,
  alpha_cumprod_t : Double,
) -> Array[Double] {
  let sqrt_alpha = alpha_cumprod_t.sqrt()
  let sqrt_one_minus = (1.0 - alpha_cumprod_t).sqrt()
  let coef = beta_t / sqrt_one_minus
  let result : Array[Double] = []
  let n = x_t.length()
  let m = predicted_noise.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    result.push((x_t[i] - coef * predicted_noise[i]) / sqrt_alpha)
  }
  result
}

///|
/// DDPM 采样。
/// DDPM sampling.
pub fn ddpm_sample(
  x_t : Array[Double],
  predicted_noise : Array[Double],
  beta_t : Double,
  alpha_cumprod_t : Double,
  noise : Array[Double],
) -> Array[Double] {
  let sqrt_alpha = alpha_cumprod_t.sqrt()
  let sqrt_one_minus = (1.0 - alpha_cumprod_t).sqrt()
  let coef1 = beta_t / sqrt_one_minus
  let coef2 = beta_t.sqrt()
  let result : Array[Double] = []
  let n = x_t.length()
  let m = predicted_noise.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let mean = (x_t[i] - coef1 * predicted_noise[i]) / sqrt_alpha
    let z = if i < noise.length() { noise[i] } else { 0.0 }
    result.push(mean + coef2 * z)
  }
  result
}

///|
/// DDIM 采样。
/// DDIM sampling.
pub fn ddim_sample(
  x_t : Array[Double],
  predicted_noise : Array[Double],
  alpha_cumprod_t : Double,
  alpha_cumprod_prev : Double,
  eta : Double,
) -> Array[Double] {
  let sqrt_alpha_t = alpha_cumprod_t.sqrt()
  let sqrt_alpha_prev = alpha_cumprod_prev.sqrt()
  let sqrt_one_minus_t = (1.0 - alpha_cumprod_t).sqrt()
  let sqrt_one_minus_prev = (1.0 - alpha_cumprod_prev).sqrt()
  let sigma = eta *
    ((1.0 - alpha_cumprod_prev) / (1.0 - alpha_cumprod_t)).sqrt() *
    (1.0 - alpha_cumprod_t / alpha_cumprod_prev).sqrt()
  let result : Array[Double] = []
  let n = x_t.length()
  let m = predicted_noise.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let pred_x0 = (x_t[i] - sqrt_one_minus_t * predicted_noise[i]) /
      sqrt_alpha_t
    let dir = sqrt_one_minus_prev * predicted_noise[i]
    result.push(sqrt_alpha_prev * pred_x0 + dir + sigma * 0.0)
  }
  result
}

///|
/// Score-based 损失。
/// Score-based loss.
pub fn score_based_loss(
  score_pred : Array[Double],
  noise : Array[Double],
) -> Double {
  let n = score_pred.length()
  let m = noise.length()
  let len = if n < m { n } else { m }
  if len == 0 {
    return 0.0
  }
  let mut loss = 0.0
  for i in 0..<len {
    let diff = score_pred[i] + noise[i]
    loss = loss + diff * diff
  }
  loss / (2.0 * len.to_double())
}
