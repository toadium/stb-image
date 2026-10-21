// GAN 扩展测试 — GAN extension tests
// Phase 13 v337: 深度学习大扩展 — GAN 扩展。

///|
fn make_gan_config() -> @cv_advanced.GANConfig {
  {
    latent_dim: 4,
    img_channels: 1,
    img_size: 2,
    learning_rate: 0.0002,
    lambda_gp: 10.0,
  }
}

///|
test "gan_generator_forward: 基本生成" {
  let latent = [0.5, 0.3, 0.1, 0.2]
  let weights = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
  ]
  let config = make_gan_config()
  let result = @cv_advanced.gan_generator_forward(latent, weights, config)
  assert_true(result.length() == 4)
}

///|
test "gan_discriminator_forward: 基本判别" {
  let image = [0.5, 0.3, 0.1, 0.2]
  let weights = [1.0, 0.0, 0.0, 1.0]
  let config = make_gan_config()
  let result = @cv_advanced.gan_discriminator_forward(image, weights, config)
  assert_true(result > 0.0 && result < 1.0)
}

///|
test "gan_train_step: 基本训练步" {
  let real = [0.5, 0.3, 0.1, 0.2]
  let fake = [0.4, 0.2, 0.2, 0.1]
  let config = make_gan_config()
  let state = @cv_advanced.gan_train_step(real, fake, config)
  assert_true(state.iteration == 1)
  assert_true(!state.converged)
}

///|
test "wgan_gradient_penalty: 梯度惩罚" {
  let real = [0.5, 0.3]
  let fake = [0.4, 0.2]
  let grad = [1.0, 1.0]
  let config = make_gan_config()
  let penalty = @cv_advanced.wgan_gradient_penalty(real, fake, grad, config)
  assert_true(penalty >= 0.0)
}

///|
test "stylegan_modulated_conv: 调制卷积" {
  let input = [1.0, 2.0, 3.0, 4.0]
  let weight = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0]
  let style = [1.0, 2.0]
  let bias = [0.0, 0.0]
  let result = @cv_advanced.stylegan_modulated_conv(
    input, weight, style, bias, 2, 2, 1,
  )
  assert_true(result.length() == 4)
}

///|
test "gan_generate_samples: 生成样本" {
  let weights = [
    1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0,
  ]
  let config = make_gan_config()
  let samples = @cv_advanced.gan_generate_samples(weights, config, 3)
  assert_true(samples.length() == 3)
  for s in samples {
    assert_true(s.length() == 4)
  }
}

///|
test "GANType: enum 值" {
  let g1 = @cv_advanced.GANType::DCGAN
  let g2 = @cv_advanced.GANType::StyleGAN
  let g3 = @cv_advanced.GANType::WGAN
  let g4 = @cv_advanced.GANType::ConditionalGAN
  assert_true(g1 != g2)
  assert_true(g2 != g3)
  assert_true(g3 != g4)
}

///|
test "GANConfig: 构造与字段" {
  let config = make_gan_config()
  assert_true(config.latent_dim == 4)
  assert_true(config.img_size == 2)
}

///|
test "GANState: 构造" {
  let state : @cv_advanced.GANState = {
    generator_loss: 0.5,
    discriminator_loss: 0.3,
    iteration: 10,
    converged: false,
  }
  assert_true(state.iteration == 10)
  assert_true(!state.converged)
}
