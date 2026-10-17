// v224: production_utils 边界测试

///|
fn pu_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn pu_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn pu_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
test "pu_edge: validate_image_or_raise 零宽度" {
  try {
    @production_utils.validate_image_or_raise(pu_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pu_edge: validate_image_or_raise 无效通道" {
  try {
    @production_utils.validate_image_or_raise(pu_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pu_edge: validate_image_or_raise 数据不匹配" {
  try {
    @production_utils.validate_image_or_raise(pu_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pu_edge: validate_channels_or_raise 通道不匹配" {
  try {
    let img = @types.Image::{
      width: 2,
      height: 2,
      channels: 1,
      data: Bytes::from_array(Array::make(4, 0)),
    }
    @production_utils.validate_channels_or_raise(img, [3, 4], "test_fn")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pu_edge: validate_range_or_raise 超范围" {
  try {
    @production_utils.validate_range_or_raise(2.0, 0.0, 1.0, "param")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "pu_edge: validate_int_range_or_raise 超范围" {
  try {
    @production_utils.validate_int_range_or_raise(5, 0, 3, "param")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
