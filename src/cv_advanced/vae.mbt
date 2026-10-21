// VAE 扩展 — β-VAE/VQ-VAE/Conditional
// VAE extensions
//
// Phase 13 v338: 深度学习大扩展 — VAE 扩展。

///|
/// VAE 类型。
/// VAE type.
pub(all) enum VAEType {
  Standard
  BetaVAE
  VQVAE
  ConditionalVAE
} derive(Eq, @debug.Debug)

///|
pub extend VAEType with @debug.Debug::{to_repr}

///|
pub extend VAEType with Eq::{not_equal, equal}

///|
/// VAE 配置。
/// VAE configuration.
pub(all) struct VAEConfig {
  latent_dim : Int32
  input_dim : Int32
  beta : Double
  learning_rate : Double
  vae_type : VAEType
} derive(Eq, @debug.Debug)

///|
pub extend VAEConfig with @debug.Debug::{to_repr}

///|
pub extend VAEConfig with Eq::{not_equal, equal}

///|
/// VAE 结果。
/// VAE result.
pub(all) struct VAEResult {
  reconstruction_loss : Double
  kl_loss : Double
  total_loss : Double
  z_mean : Array[Double]
  z_log_var : Array[Double]
} derive(Eq, @debug.Debug)

///|
pub extend VAEResult with @debug.Debug::{to_repr}

///|
pub extend VAEResult with Eq::{not_equal, equal}

///|
/// VAE 编码。
/// VAE encode.
pub fn vae_encode(
  input : Array[Double],
  weight_mean : Array[Double],
  weight_log_var : Array[Double],
  config : VAEConfig,
) -> (Array[Double], Array[Double]) {
  let z_mean = linear_layer(
    input,
    weight_mean,
    config.input_dim,
    config.latent_dim,
  )
  let z_log_var = linear_layer(
    input,
    weight_log_var,
    config.input_dim,
    config.latent_dim,
  )
  (z_mean, z_log_var)
}

///|
/// VAE 解码。
/// VAE decode.
pub fn vae_decode(
  z : Array[Double],
  weight : Array[Double],
  config : VAEConfig,
) -> Array[Double] {
  linear_layer(z, weight, config.latent_dim, config.input_dim)
}

///|
/// 重参数化技巧。
/// Reparameterization trick.
pub fn vae_reparameterize(
  z_mean : Array[Double],
  z_log_var : Array[Double],
) -> Array[Double] {
  let result : Array[Double] = []
  let n = z_mean.length()
  let m = z_log_var.length()
  let len = if n < m { n } else { m }
  for i in 0..<len {
    let std_dev = (z_log_var[i] / 2.0).exp_safe()
    let epsilon = pseudo_random(i)
    result.push(z_mean[i] + std_dev * epsilon)
  }
  result
}

///|
/// VAE 损失。
/// VAE loss.
pub fn vae_loss(
  input : Array[Double],
  reconstruction : Array[Double],
  z_mean : Array[Double],
  z_log_var : Array[Double],
  config : VAEConfig,
) -> VAEResult {
  let n = input.length()
  let m = reconstruction.length()
  let len = if n < m { n } else { m }
  let mut recon_loss = 0.0
  for i in 0..<len {
    let diff = input[i] - reconstruction[i]
    recon_loss = recon_loss + diff * diff
  }
  recon_loss = recon_loss / len.to_double()
  let mut kl = 0.0
  let kl_len = z_mean.length()
  for i in 0..<kl_len {
    let mean = z_mean[i]
    let log_var = z_log_var[i]
    kl = kl + -0.5 * (1.0 + log_var - mean * mean - log_var.exp_safe())
  }
  kl = kl / kl_len.to_double()
  let total = recon_loss + config.beta * kl
  VAEResult::{
    reconstruction_loss: recon_loss,
    kl_loss: kl,
    total_loss: total,
    z_mean,
    z_log_var,
  }
}

///|
/// β-VAE 损失。
/// β-VAE loss.
pub fn beta_vae_loss(
  input : Array[Double],
  reconstruction : Array[Double],
  z_mean : Array[Double],
  z_log_var : Array[Double],
  beta : Double,
) -> Double {
  let n = input.length()
  let m = reconstruction.length()
  let len = if n < m { n } else { m }
  let mut recon_loss = 0.0
  for i in 0..<len {
    let diff = input[i] - reconstruction[i]
    recon_loss = recon_loss + diff * diff
  }
  recon_loss = recon_loss / len.to_double()
  let mut kl = 0.0
  for i in 0..<z_mean.length() {
    let mean = z_mean[i]
    let log_var = z_log_var[i]
    kl = kl + -0.5 * (1.0 + log_var - mean * mean - log_var.exp_safe())
  }
  recon_loss + beta * kl
}

///|
/// VQ-VAE 量化。
/// VQ-VAE quantization.
pub fn vq_vae_quantize(
  z : Array[Double],
  codebook : Array[Double],
  latent_dim : Int32,
) -> (Array[Double], Int32) {
  let num_codes = codebook.length() / latent_dim
  let mut best_idx = 0
  let mut best_dist = 1.7976931348623157e308
  for c in 0..<num_codes {
    let mut dist = 0.0
    for d in 0..<latent_dim {
      let z_idx = d
      let cb_idx = c * latent_dim + d
      if z_idx < z.length() && cb_idx < codebook.length() {
        let diff = z[z_idx] - codebook[cb_idx]
        dist = dist + diff * diff
      }
    }
    if dist < best_dist {
      best_dist = dist
      best_idx = c
    }
  }
  let quantized : Array[Double] = []
  for d in 0..<latent_dim {
    let cb_idx = best_idx * latent_dim + d
    if cb_idx < codebook.length() {
      quantized.push(codebook[cb_idx])
    } else {
      quantized.push(0.0)
    }
  }
  (quantized, best_idx)
}

///|
fn linear_layer(
  input : Array[Double],
  weight : Array[Double],
  in_dim : Int32,
  out_dim : Int32,
) -> Array[Double] {
  let result : Array[Double] = []
  for o in 0..<out_dim {
    let mut sum = 0.0
    for i in 0..<in_dim {
      let w_idx = o * in_dim + i
      if i < input.length() && w_idx < weight.length() {
        sum = sum + input[i] * weight[w_idx]
      }
    }
    result.push(sum)
  }
  result
}

///|
fn pseudo_random(seed : Int32) -> Double {
  let x = seed.to_double() * 12.9898 + 78.233
  let frac = x - x.floor()
  frac * 2.0 - 1.0
}

///|
fn Double::exp_safe(self : Double) -> Double {
  if self > 700.0 {
    1.7976931348623157e308
  } else if self < -700.0 {
    0.0
  } else {
    @math.exp(self)
  }
}
