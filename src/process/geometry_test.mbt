///|
/// 检查两个 Image 的像素值是否在 tolerance 范围内相等
fn assert_image_approx(
  actual : @core.Image,
  expected : @core.Image,
  tolerance : Int,
) -> Unit raise {
  assert_eq(actual.width, expected.width)
  assert_eq(actual.height, expected.height)
  assert_eq(actual.channels, expected.channels)
  let len = actual.data.length()
  for i in 0..<len {
    let diff = (actual.data[i].to_int() - expected.data[i].to_int()).abs()
    assert_true(diff <= tolerance)
  }
}

///|
test "warp_affine: identity matrix is identity" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = warp_affine(img, (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F), 4, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.data, img.data)
  let _ = img
  let _ = result
}

///|
test "warp_affine: scale down 2x" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = warp_affine(img, (2.0F, 0.0F, 0.0F, 0.0F, 2.0F, 0.0F), 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  let _ = img
  let _ = result
}

///|
test "warp_affine: translation" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = warp_affine(img, (1.0F, 0.0F, 1.0F, 0.0F, 1.0F, 1.0F), 4, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let _ = img
  let _ = result
}

///|
test "warp_affine: preserves channels" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let result = warp_affine(img, (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F), 4, 4)
  assert_eq(result.channels, 4)
  let _ = img
  let _ = result
}

///|
test "rotate: 0 degrees is identity" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = rotate(img, 0.0F)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.data, img.data)
  let _ = img
  let _ = result
}

///|
test "rotate: 180 degrees approx matches rotate_180" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = rotate(img, 180.0F)
  let expected = rotate_180(img)
  // 允许浮点误差
  assert_image_approx(result, expected, 5)
  let _ = img
  let _ = result
  let _ = expected
}

///|
test "rotate: 90 degrees approx matches rotate_90" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = rotate(img, 90.0F)
  let expected = rotate_90(img)
  assert_image_approx(result, expected, 5)
  let _ = img
  let _ = result
  let _ = expected
}

///|
test "rotate: preserves dimensions" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(4),
  )
  let result = rotate(img, 45.0F)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 4)
  let _ = img
  let _ = result
}

///|
test "rotate: 360 degrees approx identity" {
  let img = @core.load_from_path(
    "testdata/test_4x4_red.png",
    req_channels=Some(3),
  )
  let result = rotate(img, 360.0F)
  assert_image_approx(result, img, 5)
  let _ = img
  let _ = result
}
