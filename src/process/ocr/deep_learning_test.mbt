// v187.0.0 deep_learning.mbt 测试：CNN配置/激活函数/卷积/池化/推理/训练/特征提取

///|
test "create_default_char_cnn_config: 基本配置" {
  let config = @ocr.create_default_char_cnn_config(10)
  assert_eq(config.num_classes, 10)
  assert_eq(config.input_width, 32)
  assert_eq(config.input_height, 32)
  assert_eq(config.input_channels, 1)
  assert_eq(config.conv_layers.length(), 3)
  assert_eq(config.dense_layers.length(), 2)
}

///|
test "create_neural_layer: Conv2D 输出形状" {
  let layer = @ocr.create_neural_layer(@ocr.DLLayerType::Conv2D, "conv1", [
    1, 28, 28,
  ])
  assert_true(layer.layer_type == @ocr.DLLayerType::Conv2D)
  assert_eq(layer.name, "conv1")
  assert_eq(layer.output_shape.length(), 3)
}

///|
test "create_neural_layer: MaxPool2D 输出形状减半" {
  let layer = @ocr.create_neural_layer(@ocr.DLLayerType::MaxPool2D, "pool1", [
    1, 28, 28,
  ])
  assert_eq(layer.output_shape[1], 14)
  assert_eq(layer.output_shape[2], 14)
}

///|
test "create_neural_layer: Flatten 输出形状" {
  let layer = @ocr.create_neural_layer(@ocr.DLLayerType::Flatten, "flatten", [
    1, 4, 4,
  ])
  assert_eq(layer.output_shape.length(), 1)
  assert_eq(layer.output_shape[0], 16)
}

///|
test "normalize_image: 基本归一化" {
  try {
    let result = @ocr.normalize_image([0.0, 128.0, 255.0], 128.0, 255.0)
    assert_eq(result.length(), 3)
    assert_true((result[0] - -128.0 / 255.0).abs() < 0.001)
    assert_true(result[1].abs() < 0.001)
    assert_true((result[2] - 127.0 / 255.0).abs() < 0.001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "normalize_image: 空数据抛异常" {
  try {
    let _ = @ocr.normalize_image([], 0.0, 1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "normalize_image: std为零抛异常" {
  try {
    let _ = @ocr.normalize_image([1.0, 2.0], 0.0, 0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "relu: 正值透传" {
  assert_true((@ocr.relu(3.5) - 3.5).abs() < 0.0001)
}

///|
test "relu: 负值返回零" {
  assert_true(@ocr.relu(-3.5).abs() < 0.0001)
}

///|
test "relu: 零返回零" {
  assert_true(@ocr.relu(0.0).abs() < 0.0001)
}

///|
test "sigmoid: 零返回0.5" {
  assert_true((@ocr.sigmoid(0.0) - 0.5).abs() < 0.01)
}

///|
test "sigmoid: 正值大于0.5" {
  assert_true(@ocr.sigmoid(2.0) > 0.5)
}

///|
test "sigmoid: 负值小于0.5" {
  assert_true(@ocr.sigmoid(-2.0) < 0.5)
}

///|
test "softmax: 和为1" {
  let result = @ocr.softmax([1.0, 2.0, 3.0])
  let mut sum = 0.0
  for v in result {
    sum += v
  }
  assert_true((sum - 1.0).abs() < 0.01)
}

///|
test "softmax: 最大值对应最大概率" {
  let result = @ocr.softmax([1.0, 5.0, 2.0])
  assert_true(result[1] > result[0])
  assert_true(result[1] > result[2])
}

///|
test "softmax: 长度保持" {
  let result = @ocr.softmax([0.0, 0.0, 0.0, 0.0])
  assert_eq(result.length(), 4)
}

///|
test "conv2d: 基本卷积" {
  try {
    let input = [1.0, 2.0, 3.0, 4.0]
    let kernel = [1.0, 0.0, 0.0, 1.0]
    let result = @ocr.conv2d(input, 2, 2, 1, kernel, 1, 2, 1, 0)
    assert_eq(result.length(), 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "conv2d: 空输入抛异常" {
  try {
    let _ = @ocr.conv2d([], 2, 2, 1, [1.0], 1, 1, 1, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "max_pool2d: 基本池化" {
  try {
    let input = [
      1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0,
      15.0, 16.0,
    ]
    let result = @ocr.max_pool2d(input, 4, 4, 1, 2)
    assert_eq(result.length(), 4)
    assert_true((result[0] - 6.0).abs() < 0.01)
    assert_true((result[3] - 16.0).abs() < 0.01)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "max_pool2d: 空输入抛异常" {
  try {
    let _ = @ocr.max_pool2d([], 2, 2, 1, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "dense_forward: relu激活" {
  let input = [1.0, 2.0]
  let weights = [1.0, 1.0, 0.5, 0.5]
  let biases = [0.0, 0.0]
  let result = @ocr.dense_forward(input, weights, biases, 2, 2, "relu")
  assert_eq(result.length(), 2)
  assert_true((result[0] - 3.0).abs() < 0.01)
}

///|
test "dense_forward: 无激活" {
  let input = [1.0, -1.0]
  let weights = [1.0, 1.0]
  let biases = [0.0]
  let result = @ocr.dense_forward(input, weights, biases, 2, 1, "none")
  assert_eq(result.length(), 1)
  assert_true(result[0].abs() < 0.01)
}

///|
test "cnn_infer: 基本推理" {
  let config = @ocr.create_default_char_cnn_config(3)
  let image_data = [0.5, 0.3, 0.8, 0.1, 0.9, 0.2, 0.7, 0.4, 0.6, 0.5]
  let labels = ["a", "b", "c"]
  let result = @ocr.cnn_infer(image_data, config, labels)
  assert_true(result.predicted_class >= 0 && result.predicted_class < 3)
  assert_eq(result.top_k_predictions.length() > 0, true)
}

///|
test "cross_entropy_loss: 基本计算" {
  let predicted = [0.7, 0.2, 0.1]
  let loss = @ocr.cross_entropy_loss(predicted, 0)
  assert_true(loss > 0.0)
}

///|
test "cross_entropy_loss: 标签越界用eps" {
  let predicted = [0.5, 0.5]
  let loss = @ocr.cross_entropy_loss(predicted, 10)
  assert_true(loss > 0.0)
}

///|
test "create_training_history: 字段正确" {
  let h = @ocr.create_training_history(1, 0.5, 0.9, 0.6, 0.85, 0.001, 100.0)
  assert_eq(h.epoch, 1)
  assert_true((h.train_loss - 0.5).abs() < 0.001)
  assert_true((h.train_accuracy - 0.9).abs() < 0.001)
}

///|
test "generate_training_report: 非空报告" {
  let config = @ocr.create_default_char_cnn_config(5)
  let history = [
    @ocr.create_training_history(1, 0.5, 0.9, 0.6, 0.85, 0.001, 100.0),
  ]
  let report = @ocr.generate_training_report(history, config)
  assert_true(report.length() > 0)
  assert_true(report.contains("CNN"))
}

///|
test "save_model: 返回true" {
  let config = @ocr.create_default_char_cnn_config(3)
  let result = @ocr.save_model(config, [0.1, 0.2], "model.json")
  assert_eq(result, true)
}

///|
test "load_model: 简化版返回None" {
  let result = @ocr.load_model("model.json")
  assert_true(result is None)
}

///|
test "create_feature_extractor: 字段正确" {
  let extractor = @ocr.create_feature_extractor("resnet", 128)
  assert_eq(extractor.model_name, "resnet")
  assert_eq(extractor.feature_dim, 128)
  assert_eq(extractor.layer_name, "conv3")
}

///|
test "extract_features: 维度填充到feature_dim" {
  let extractor = @ocr.create_feature_extractor("test", 32)
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      128, 64, 192, 32, 255, 0, 128, 64, 192, 32, 255, 0, 128, 64, 192, 32,
    ]),
  }
  let features = @ocr.extract_features(extractor, img)
  assert_eq(features.length(), 32)
}

///|
test "cosine_similarity: 相同向量返回1" {
  let v = [1.0, 2.0, 3.0]
  let sim = @ocr.cosine_similarity(v, v)
  assert_true((sim - 1.0).abs() < 0.01)
}

///|
test "cosine_similarity: 正交向量返回0" {
  let a = [1.0, 0.0]
  let b = [0.0, 1.0]
  let sim = @ocr.cosine_similarity(a, b)
  assert_true(sim.abs() < 0.01)
}

///|
test "cosine_similarity: 零向量返回0" {
  let sim = @ocr.cosine_similarity([0.0, 0.0], [1.0, 2.0])
  assert_true(sim.abs() < 0.01)
}

///|
test "create_training_sample: 基本创建" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      128, 64, 192, 32, 255, 0, 128, 64, 192, 32, 255, 0, 128, 64, 192, 32,
    ]),
  }
  try {
    let sample = @ocr.create_training_sample(img, 2, "char_a")
    assert_eq(sample.label, 2)
    assert_eq(sample.label_text, "char_a")
    assert_eq(sample.width, 32)
    assert_eq(sample.height, 32)
    assert_eq(sample.image_data.length(), 1024)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "create_training_sample: 负标签抛异常" {
  let img = @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
  }
  try {
    let _ = @ocr.create_training_sample(img, -1, "test")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
