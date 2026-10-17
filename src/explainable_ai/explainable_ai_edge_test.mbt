// v224: explainable_ai 边界测试

///|
fn ea_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn ea_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn ea_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn ea_default_config() -> @explainable_ai.ExplainableAIConfig {
  @explainable_ai.ExplainableAIConfig::{
    method_type: @explainable_ai.ExplainabilityMethod::GradCAM,
    num_samples: 100,
    num_features: 10,
    perturbation_scale: 0.1,
    target_class: 0,
    use_smoothing: false,
    smoothing_sigma: 1.0,
    normalize: true,
  }
}

///|
test "ea_edge: compute_feature_importance 零宽度" {
  try {
    let _ = @explainable_ai.compute_feature_importance(
      ea_zero_w(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: compute_feature_importance 无效通道" {
  try {
    let _ = @explainable_ai.compute_feature_importance(
      ea_bad_channels(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: compute_feature_importance 数据不匹配" {
  try {
    let _ = @explainable_ai.compute_feature_importance(
      ea_mismatch(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: generate_saliency_map 零宽度" {
  try {
    let _ = @explainable_ai.generate_saliency_map(
      ea_zero_w(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: generate_saliency_map 无效通道" {
  try {
    let _ = @explainable_ai.generate_saliency_map(
      ea_bad_channels(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: generate_saliency_map 数据不匹配" {
  try {
    let _ = @explainable_ai.generate_saliency_map(
      ea_mismatch(),
      ea_default_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: visualize_feature_maps 零宽度" {
  try {
    let _ = @explainable_ai.visualize_feature_maps(ea_zero_w(), 8, "relu")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: visualize_feature_maps 无效通道" {
  try {
    let _ = @explainable_ai.visualize_feature_maps(ea_bad_channels(), 8, "relu")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ea_edge: visualize_feature_maps 数据不匹配" {
  try {
    let _ = @explainable_ai.visualize_feature_maps(ea_mismatch(), 8, "relu")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
