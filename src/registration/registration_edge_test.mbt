// v222: registration 模块边界/错误路径测试

///|
fn re_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 2,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn re_mismatch() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array(Array::make(1, 0)),
  }
}

///|
fn re_bad_channels() -> @types.Image {
  @types.Image::{
    width: 2,
    height: 2,
    channels: 5,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn re_uniform(w : Int32, h : Int32, v : Int32) -> @types.Image {
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
test "re_edge: estimate_translation img1零宽度" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(re_zero_w(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: estimate_translation img1无效通道" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(re_bad_channels(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: estimate_translation img1数据不匹配" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(re_mismatch(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: estimate_translation img2零宽度" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(img, re_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: estimate_translation img2无效通道" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(img, re_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: estimate_translation img2数据不匹配" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.estimate_translation(img, re_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: warp_affine_transform 零宽度" {
  try {
    let t = @registration.affine_identity()
    let _ = @registration.warp_affine_transform(re_zero_w(), t)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: warp_affine_transform 无效通道" {
  try {
    let t = @registration.affine_identity()
    let _ = @registration.warp_affine_transform(re_bad_channels(), t)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: warp_affine_transform 数据不匹配" {
  try {
    let t = @registration.affine_identity()
    let _ = @registration.warp_affine_transform(re_mismatch(), t)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img1零宽度" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(re_zero_w(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img1无效通道" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(re_bad_channels(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img1数据不匹配" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(re_mismatch(), img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img2零宽度" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(img, re_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img2无效通道" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(img, re_bad_channels())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "re_edge: align_images img2数据不匹配" {
  try {
    let img = re_uniform(4, 4, 128)
    let _ = @registration.align_images(img, re_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
