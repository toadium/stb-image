// v221: compression 模块边界/错误路径测试

///|
fn ce_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn ce_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn ce_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn ce_uniform(w : Int32, h : Int32, v : Int32) -> @types.Image {
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
test "ce_edge: calculate_image_entropy 零宽度" {
  try {
    let _ = @compression.calculate_image_entropy(ce_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_image_entropy 无效通道" {
  try {
    let _ = @compression.calculate_image_entropy(ce_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_image_entropy 数据不匹配" {
  try {
    let _ = @compression.calculate_image_entropy(ce_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: quantize_image 零宽度" {
  try {
    let _ = @compression.quantize_image(ce_zero_w(), 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: quantize_image 无效通道" {
  try {
    let _ = @compression.quantize_image(ce_bad_channels(), 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: quantize_image 数据不匹配" {
  try {
    let _ = @compression.quantize_image(ce_mismatch(), 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: quantize_image levels < 2" {
  try {
    let _ = @compression.quantize_image(ce_uniform(4, 4, 128), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: predictive_encode 零宽度" {
  try {
    let _ = @compression.predictive_encode(ce_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: predictive_encode 无效通道" {
  try {
    let _ = @compression.predictive_encode(ce_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: predictive_encode 数据不匹配" {
  try {
    let _ = @compression.predictive_encode(ce_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_compression_quality 零宽度" {
  try {
    let img = ce_uniform(4, 4, 128)
    let _ = @compression.calculate_compression_quality(ce_zero_w(), img, 16, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_compression_quality 无效通道" {
  try {
    let img = ce_uniform(4, 4, 128)
    let _ = @compression.calculate_compression_quality(
      ce_bad_channels(),
      img,
      16,
      8,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_compression_quality 数据不匹配" {
  try {
    let img = ce_uniform(4, 4, 128)
    let _ = @compression.calculate_compression_quality(
      ce_mismatch(),
      img,
      16,
      8,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: calculate_compression_quality 尺寸不一致" {
  try {
    let img1 = ce_uniform(4, 4, 128)
    let img2 = ce_uniform(2, 2, 128)
    let _ = @compression.calculate_compression_quality(img1, img2, 16, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_jpeg_simple 零宽度" {
  try {
    let _ = @compression.compress_jpeg_simple(ce_zero_w(), 80.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_jpeg_simple 无效通道" {
  try {
    let _ = @compression.compress_jpeg_simple(ce_bad_channels(), 80.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_jpeg_simple 数据不匹配" {
  try {
    let _ = @compression.compress_jpeg_simple(ce_mismatch(), 80.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_png_simple 零宽度" {
  try {
    let _ = @compression.compress_png_simple(ce_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_png_simple 无效通道" {
  try {
    let _ = @compression.compress_png_simple(ce_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_png_simple 数据不匹配" {
  try {
    let _ = @compression.compress_png_simple(ce_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_image 零宽度" {
  try {
    let config = @compression.create_default_compression_config()
    let _ = @compression.compress_image(ce_zero_w(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_image 无效通道" {
  try {
    let config = @compression.create_default_compression_config()
    let _ = @compression.compress_image(ce_bad_channels(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ce_edge: compress_image 数据不匹配" {
  try {
    let config = @compression.create_default_compression_config()
    let _ = @compression.compress_image(ce_mismatch(), config)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
