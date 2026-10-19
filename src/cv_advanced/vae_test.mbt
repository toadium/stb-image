// VAE 扩展测试 — VAE extension tests
// Phase 13 v338: 深度学习大扩展 — VAE 扩展。

///|
fn make_vae_config() -> @cv_advanced.VAEConfig {
  {
    latent_dim: 2,
    input_dim: 4,
    beta: 1.0,
    learning_rate: 0.001,
    vae_type: @cv_advanced.VAEType::Standard,
  }
}

///|
test "vae_encode: 基本编码" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let w = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
  let config = make_vae_config()
  let (z_mean, z_log_var) = @cv_advanced.vae_encode(input, w, w, config)
  assert_true(z_mean.length() == 2)
  assert_true(z_log_var.length() == 2)
}

///|
test "vae_decode: 基本解码" {
  let z = [0.5, 0.3]
  let w = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
  let config = make_vae_config()
  let result = @cv_advanced.vae_decode(z, w, config)
  assert_true(result.length() == 4)
}

///|
test "vae_reparameterize: 重参数化" {
  let z_mean = [0.5, 0.3]
  let z_log_var = [0.0, 0.0]
  let result = @cv_advanced.vae_reparameterize(z_mean, z_log_var)
  assert_true(result.length() == 2)
}

///|
test "vae_loss: 基本损失" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let recon = [0.9, 0.1, 0.1, 0.9]
  let z_mean = [0.5, 0.3]
  let z_log_var = [0.0, 0.0]
  let config = make_vae_config()
  let result = @cv_advanced.vae_loss(input, recon, z_mean, z_log_var, config)
  assert_true(result.reconstruction_loss >= 0.0)
  assert_true(result.total_loss == result.total_loss)
}

///|
test "beta_vae_loss: β-VAE 损失" {
  let input = [1.0, 0.0, 0.0, 1.0]
  let recon = [0.9, 0.1, 0.1, 0.9]
  let z_mean = [0.5, 0.3]
  let z_log_var = [0.0, 0.0]
  let loss = @cv_advanced.beta_vae_loss(input, recon, z_mean, z_log_var, 4.0)
  assert_true(loss == loss)
}

///|
test "vq_vae_quantize: VQ 量化" {
  let z = [0.4, 0.3]
  let codebook = [0.5, 0.5, 0.0, 0.0, 1.0, 1.0]
  let (quantized, idx) = @cv_advanced.vq_vae_quantize(z, codebook, 2)
  assert_true(quantized.length() == 2)
  assert_true(idx >= 0 && idx < 3)
}

///|
test "VAEType: enum 值" {
  let v1 = @cv_advanced.VAEType::Standard
  let v2 = @cv_advanced.VAEType::BetaVAE
  let v3 = @cv_advanced.VAEType::VQVAE
  let v4 = @cv_advanced.VAEType::ConditionalVAE
  assert_true(v1 != v2)
  assert_true(v2 != v3)
  assert_true(v3 != v4)
}

///|
test "VAEConfig: 构造与字段" {
  let config = make_vae_config()
  assert_true(config.latent_dim == 2)
  assert_true(config.input_dim == 4)
  assert_true(config.beta == 1.0)
}

///|
test "VAEResult: 构造" {
  let result : @cv_advanced.VAEResult = {
    reconstruction_loss: 0.1,
    kl_loss: 0.05,
    total_loss: 0.15,
    z_mean: [0.0],
    z_log_var: [0.0],
  }
  assert_true(result.reconstruction_loss == 0.1)
  assert_true(result.kl_loss == 0.05)
}
