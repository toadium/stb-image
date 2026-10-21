// v46.0.0 表示学习高级测试

///|
test "create_default_representation_learning_config: 基本测试" {
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  assert_true(
    config.task_type
    is @representation_learning_advanced.RepresentationLearningTaskType::Autoencoder,
  )
}

///|
test "train_autoencoder: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let result = @representation_learning_advanced.train_autoencoder(data, config)
  assert_eq(result.num_samples, 4)
  assert_true(result.latent_dimension > 0)
}

///|
test "train_vae: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let result = @representation_learning_advanced.train_vae(data, config)
  assert_eq(result.num_samples, 4)
  assert_true(result.latent_dimension > 0)
}

///|
test "train_gan: 基本测试" {
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let result = @representation_learning_advanced.train_gan(4, 2, 8, config)
  assert_eq(result.num_generated, 4)
  assert_true(
    result.gan_type is @representation_learning_advanced.GANType::VanillaGAN,
  )
}

///|
test "train_contrastive: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let result = @representation_learning_advanced.train_contrastive(data, config)
  assert_eq(result.num_samples, 4)
  assert_true(result.representation_dimension > 0)
}

///|
test "learn_representation: 基本测试" {
  let data = make_test_data(4, 8)
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let result = @representation_learning_advanced.learn_representation(
    data, config,
  )
  assert_eq(result.num_samples, 4)
  assert_true(result.representation_dimension > 0)
}

///|
test "representation_learning_report_to_string: 基本测试" {
  let config = @representation_learning_advanced.create_default_representation_learning_config()
  let report = @representation_learning_advanced.representation_learning_report_to_string(
    @representation_learning_advanced.RepresentationLearningTaskType::Autoencoder,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_data(n : Int32, d : Int32) -> Array[Array[Double]] {
  let data : Array[Array[Double]] = []
  for i in 0..<n {
    let row : Array[Double] = []
    for j in 0..<d {
      row.push(((i * d + j) % 256).to_double())
    }
    data.push(row)
  }
  data
}
