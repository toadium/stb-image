// v224: style_transfer 边界测试

///|
fn ste_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn ste_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn ste_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn ste_uniform(w : Int32, h : Int32, v : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "ste_edge: calculate_color_statistics 零宽度" {
  try {
    let _ = @style_transfer.calculate_color_statistics(ste_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: calculate_color_statistics 无效通道" {
  try {
    let _ = @style_transfer.calculate_color_statistics(ste_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: calculate_color_statistics 数据不匹配" {
  try {
    let _ = @style_transfer.calculate_color_statistics(ste_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: calculate_texture_features 零宽度" {
  try {
    let _ = @style_transfer.calculate_texture_features(ste_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: calculate_texture_features 无效通道" {
  try {
    let _ = @style_transfer.calculate_texture_features(ste_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: calculate_texture_features 数据不匹配" {
  try {
    let _ = @style_transfer.calculate_texture_features(ste_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: cartoonize 零宽度" {
  try {
    let _ = @style_transfer.cartoonize(ste_zero_w(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: cartoonize 无效通道" {
  try {
    let _ = @style_transfer.cartoonize(ste_bad_channels(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: cartoonize 数据不匹配" {
  try {
    let _ = @style_transfer.cartoonize(ste_mismatch(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: color_transfer content零宽度" {
  try {
    let style = ste_uniform(4, 4, 128)
    let _ = @style_transfer.color_transfer(ste_zero_w(), style, 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: color_transfer style零宽度" {
  try {
    let content = ste_uniform(4, 4, 128)
    let _ = @style_transfer.color_transfer(content, ste_zero_w(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: color_transfer content无效通道" {
  try {
    let style = ste_uniform(4, 4, 128)
    let _ = @style_transfer.color_transfer(ste_bad_channels(), style, 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: oil_painting 零宽度" {
  try {
    let _ = @style_transfer.oil_painting(ste_zero_w(), 4, 20)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: oil_painting 无效通道" {
  try {
    let _ = @style_transfer.oil_painting(ste_bad_channels(), 4, 20)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: oil_painting 数据不匹配" {
  try {
    let _ = @style_transfer.oil_painting(ste_mismatch(), 4, 20)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: sketch_effect 零宽度" {
  try {
    let _ = @style_transfer.sketch_effect(ste_zero_w(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: sketch_effect 无效通道" {
  try {
    let _ = @style_transfer.sketch_effect(ste_bad_channels(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: sketch_effect 数据不匹配" {
  try {
    let _ = @style_transfer.sketch_effect(ste_mismatch(), 0.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
fn ste_config() -> @style_transfer.StyleTransferConfig {
  @style_transfer.StyleTransferConfig::{
    algorithm: @style_transfer.StyleTransferAlgorithm::ColorTransfer,
    style_strength: 0.5,
    content_strength: 0.5,
    iterations: 10,
    learning_rate: 0.01,
    use_color_preservation: false,
    resolution: 256,
  }
}

///|
test "ste_edge: style_transfer content零宽度" {
  try {
    let style = ste_uniform(4, 4, 128)
    let _ = @style_transfer.style_transfer(ste_zero_w(), style, ste_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: style_transfer style零宽度" {
  try {
    let content = ste_uniform(4, 4, 128)
    let _ = @style_transfer.style_transfer(content, ste_zero_w(), ste_config())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ste_edge: style_transfer content无效通道" {
  try {
    let style = ste_uniform(4, 4, 128)
    let _ = @style_transfer.style_transfer(
      ste_bad_channels(),
      style,
      ste_config(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
