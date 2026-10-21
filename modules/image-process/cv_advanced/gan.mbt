// GAN 扩展 — DCGAN/StyleGAN/WGAN
// GAN extensions
//
// Phase 13 v337: 深度学习大扩展 — GAN 扩展。

///|
/// GAN 类型。
/// GAN type.
pub(all) enum GANType {
  DCGAN
  StyleGAN
  WGAN
  ConditionalGAN
} derive(Eq, @debug.Debug)

///|
pub extend GANType with @debug.Debug::{to_repr}

///|
pub extend GANType with Eq::{not_equal, equal}

///|
/// GAN 配置。
/// GAN configuration.
pub(all) struct GANConfig {
  latent_dim : Int32
  img_channels : Int32
  img_size : Int32
  learning_rate : Double
  lambda_gp : Double
} derive(Eq, @debug.Debug)

///|
pub extend GANConfig with @debug.Debug::{to_repr}

///|
pub extend GANConfig with Eq::{not_equal, equal}

///|
/// GAN 训练状态。
/// GAN training state.
pub(all) struct GANState {
  generator_loss : Double
  discriminator_loss : Double
  iteration : Int32
  converged : Bool
} derive(Eq, @debug.Debug)

///|
pub extend GANState with @debug.Debug::{to_repr}

///|
pub extend GANState with Eq::{not_equal, equal}

///|
/// GAN 生成器前向传播。
/// GAN generator forward pass.
pub fn gan_generator_forward(
  latent : Array[Double],
  weights : Array[Double],
  config : GANConfig,
) -> Array[Double] {
  let output_size = config.img_size * config.img_size * config.img_channels
  let result : Array[Double] = []
  for o in 0..<output_size {
    let mut sum = 0.0
    for i in 0..<config.latent_dim {
      let w_idx = o * config.latent_dim + i
      if i < latent.length() && w_idx < weights.length() {
        sum = sum + latent[i] * weights[w_idx]
      }
    }
    result.push(leaky_relu(sum, 0.2))
  }
  result
}

///|
/// GAN 判别器前向传播。
/// GAN discriminator forward pass.
pub fn gan_discriminator_forward(
  image : Array[Double],
  weights : Array[Double],
  config : GANConfig,
) -> Double {
  let input_size = config.img_size * config.img_size * config.img_channels
  let mut sum = 0.0
  for i in 0..<input_size {
    let w_idx = i
    if i < image.length() && w_idx < weights.length() {
      sum = sum + image[i] * weights[w_idx]
    }
  }
  sigmoid_fn(sum)
}

///|
/// GAN 训练步。
/// GAN training step.
pub fn gan_train_step(
  real_images : Array[Double],
  fake_images : Array[Double],
  config : GANConfig,
) -> GANState {
  let d_real = gan_discriminator_forward(real_images, [1.0], config)
  let d_fake = gan_discriminator_forward(fake_images, [1.0], config)
  let d_loss = -(d_real.log_safe() + (1.0 - d_fake).log_safe()) / 2.0
  let g_loss = -d_fake.log_safe()
  GANState::{
    generator_loss: g_loss,
    discriminator_loss: d_loss,
    iteration: 1,
    converged: false,
  }
}

///|
/// WGAN 梯度惩罚。
/// WGAN gradient penalty.
pub fn wgan_gradient_penalty(
  real : Array[Double],
  fake : Array[Double],
  grad : Array[Double],
  config : GANConfig,
) -> Double {
  let n = real.length()
  let m = fake.length()
  let len = if n < m { n } else { m }
  let mut penalty = 0.0
  for i in 0..<len {
    let g = if i < grad.length() { grad[i] } else { 0.0 }
    let norm = g * g
    penalty = penalty + (norm - 1.0) * (norm - 1.0)
  }
  penalty = penalty / len.to_double()
  config.lambda_gp * penalty
}

///|
/// StyleGAN 调制卷积。
/// StyleGAN modulated convolution.
pub fn stylegan_modulated_conv(
  input : Array[Double],
  weight : Array[Double],
  style : Array[Double],
  bias : Array[Double],
  in_channels : Int32,
  out_channels : Int32,
  kernel_size : Int32,
) -> Array[Double] {
  let result : Array[Double] = []
  let spatial = input.length() / in_channels
  for o in 0..<out_channels {
    for s in 0..<spatial {
      let mut sum = 0.0
      for c in 0..<in_channels {
        let in_idx = c * spatial + s
        let style_val = if c < style.length() { style[c] } else { 1.0 }
        for k in 0..<kernel_size {
          let w_idx = o * in_channels * kernel_size + c * kernel_size + k
          if in_idx < input.length() && w_idx < weight.length() {
            sum = sum + input[in_idx] * weight[w_idx] * style_val
          }
        }
      }
      let b = if o < bias.length() { bias[o] } else { 0.0 }
      result.push(sum + b)
    }
  }
  result
}

///|
/// GAN 生成样本。
/// GAN generate samples.
pub fn gan_generate_samples(
  weights : Array[Double],
  config : GANConfig,
  num_samples : Int32,
) -> Array[Array[Double]] {
  let result : Array[Array[Double]] = []
  for s in 0..<num_samples {
    let latent : Array[Double] = []
    for i in 0..<config.latent_dim {
      let val = @math.sin((s * config.latent_dim + i).to_double() * 0.1)
      latent.push(val)
    }
    let sample = gan_generator_forward(latent, weights, config)
    result.push(sample)
  }
  result
}

///|
fn leaky_relu(x : Double, slope : Double) -> Double {
  if x > 0.0 {
    x
  } else {
    slope * x
  }
}

///|
fn sigmoid_fn(x : Double) -> Double {
  1.0 / (1.0 + @math.exp(-x))
}

///|
fn Double::log_safe(self : Double) -> Double {
  if self > 0.0 {
    @math.log2(self) * 0.6931471805599453
  } else {
    -100.0
  }
}
