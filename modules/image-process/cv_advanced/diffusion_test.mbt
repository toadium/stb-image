// Diffusion 模型测试 — Diffusion model tests
// Phase 13 v339: 深度学习大扩展 — Diffusion 模型。

///|
fn make_diffusion_config() -> @cv_advanced.DiffusionConfig {
  {
    num_steps: 10,
    beta_start: 0.0001,
    beta_end: 0.02,
    schedule_type: @cv_advanced.ScheduleType::Linear,
    diffusion_type: @cv_advanced.DiffusionType::DDPM,
  }
}

///|
test "compute_beta_schedule: 线性调度" {
  let config = make_diffusion_config()
  let betas = @cv_advanced.compute_beta_schedule(config)
  assert_true(betas.length() == 10)
  assert_true(betas[0] < betas[9])
}

///|
test "compute_beta_schedule: 余弦调度" {
  let config : @cv_advanced.DiffusionConfig = {
    num_steps: 10,
    beta_start: 0.0001,
    beta_end: 0.02,
    schedule_type: @cv_advanced.ScheduleType::Cosine,
    diffusion_type: @cv_advanced.DiffusionType::DDPM,
  }
  let betas = @cv_advanced.compute_beta_schedule(config)
  assert_true(betas.length() == 10)
}

///|
test "compute_alpha_cumprod: 累积乘积" {
  let betas = [0.1, 0.2, 0.3]
  let alphas = @cv_advanced.compute_alpha_cumprod(betas)
  assert_true(alphas.length() == 3)
  assert_true(alphas[0] > 0.0)
  assert_true(alphas[2] < alphas[0])
}

///|
test "diffusion_forward: 前向加噪" {
  let x_0 = [1.0, 2.0, 3.0]
  let noise = [0.1, 0.2, 0.3]
  let result = @cv_advanced.diffusion_forward(x_0, noise, 0.5)
  assert_true(result.length() == 3)
}

///|
test "diffusion_reverse: 反向去噪" {
  let x_t = [0.5, 0.6, 0.7]
  let pred_noise = [0.1, 0.1, 0.1]
  let result = @cv_advanced.diffusion_reverse(x_t, pred_noise, 0.01, 0.9)
  assert_true(result.length() == 3)
}

///|
test "ddpm_sample: DDPM 采样" {
  let x_t = [0.5, 0.6, 0.7]
  let pred_noise = [0.1, 0.1, 0.1]
  let noise = [0.01, 0.02, 0.01]
  let result = @cv_advanced.ddpm_sample(x_t, pred_noise, 0.01, 0.9, noise)
  assert_true(result.length() == 3)
}

///|
test "ddim_sample: DDIM 采样" {
  let x_t = [0.5, 0.6, 0.7]
  let pred_noise = [0.1, 0.1, 0.1]
  let result = @cv_advanced.ddim_sample(x_t, pred_noise, 0.9, 0.8, 0.0)
  assert_true(result.length() == 3)
}

///|
test "score_based_loss: Score 损失" {
  let score = [0.1, 0.2, 0.3]
  let noise = [0.1, 0.2, 0.3]
  let loss = @cv_advanced.score_based_loss(score, noise)
  assert_true(loss >= 0.0)
}

///|
test "DiffusionType: enum 值" {
  let d1 = @cv_advanced.DiffusionType::DDPM
  let d2 = @cv_advanced.DiffusionType::DDIM
  let d3 = @cv_advanced.DiffusionType::ScoreBased
  let d4 = @cv_advanced.DiffusionType::StableDiffusion
  assert_true(d1 != d2)
  assert_true(d2 != d3)
  assert_true(d3 != d4)
}
