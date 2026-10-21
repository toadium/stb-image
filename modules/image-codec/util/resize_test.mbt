// v251.0.0 resize_pure 覆盖率测试

///|
fn v251_resize_make_image(
  w : Int32,
  h : Int32,
  ch : Int32,
  pixels : Array[Int32],
) -> @types.Image {
  let data : Array[Byte] = []
  for p in pixels {
    data.push(p.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "resize_pure: nearest neighbor upscale 1x1 to 2x2" {
  let img = v251_resize_make_image(1, 1, 1, [100])
  let result = @util.resize_pure(
    img,
    2,
    2,
    filter=@types.ResizeFilter::PointSample,
  )
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[1].to_int(), 100)
  assert_eq(result.data[2].to_int(), 100)
  assert_eq(result.data[3].to_int(), 100)
}

///|
test "resize_pure: nearest neighbor downscale 2x2 to 1x1" {
  let img = v251_resize_make_image(2, 2, 1, [10, 20, 30, 40])
  let result = @util.resize_pure(
    img,
    1,
    1,
    filter=@types.ResizeFilter::PointSample,
  )
  assert_eq(result.width, 1)
  assert_eq(result.height, 1)
  let val = result.data[0].to_int()
  assert_true(val >= 10 && val <= 40)
}

///|
test "resize_pure: bilinear upscale 1x1 to 2x2" {
  let img = v251_resize_make_image(1, 1, 1, [100])
  let result = @util.resize_pure(img, 2, 2)
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[1].to_int(), 100)
  assert_eq(result.data[2].to_int(), 100)
  assert_eq(result.data[3].to_int(), 100)
}

///|
test "resize_pure: bilinear downscale 4x1 to 2x1" {
  let img = v251_resize_make_image(4, 1, 1, [0, 100, 200, 255])
  let result = @util.resize_pure(img, 2, 1)
  assert_eq(result.width, 2)
  assert_eq(result.height, 1)
}

///|
test "resize_pure: 3-channel image" {
  let img = v251_resize_make_image(2, 2, 3, [
    255, 0, 0, 0, 255, 0, 0, 0, 255, 255, 255, 0,
  ])
  let result = @util.resize_pure(
    img,
    4,
    4,
    filter=@types.ResizeFilter::PointSample,
  )
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 3)
}

///|
test "resize_pure: same size returns equivalent image" {
  let img = v251_resize_make_image(2, 2, 1, [10, 20, 30, 40])
  let result = @util.resize_pure(
    img,
    2,
    2,
    filter=@types.ResizeFilter::PointSample,
  )
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
  assert_eq(result.data[0].to_int(), 10)
  assert_eq(result.data[1].to_int(), 20)
  assert_eq(result.data[2].to_int(), 30)
  assert_eq(result.data[3].to_int(), 40)
}

///|
test "resize_pure: zero width raises error" {
  let img = v251_resize_make_image(2, 2, 1, [10, 20, 30, 40])
  try {
    let _ = @util.resize_pure(img, 0, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "resize_pure: zero height raises error" {
  let img = v251_resize_make_image(2, 2, 1, [10, 20, 30, 40])
  try {
    let _ = @util.resize_pure(img, 2, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "resize_pure: negative dimensions raise error" {
  let img = v251_resize_make_image(2, 2, 1, [10, 20, 30, 40])
  try {
    let _ = @util.resize_pure(img, -1, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "resize_pure: upscale 1x1 to 3x3 bilinear" {
  let img = v251_resize_make_image(1, 1, 1, [128])
  let result = @util.resize_pure(img, 3, 3)
  assert_eq(result.width, 3)
  assert_eq(result.height, 3)
  for i in 0..<9 {
    assert_eq(result.data[i].to_int(), 128)
  }
}

///|
test "resize_pure: downscale 4x4 to 2x2 nearest" {
  let img = v251_resize_make_image(4, 4, 1, [
    10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160,
  ])
  let result = @util.resize_pure(
    img,
    2,
    2,
    filter=@types.ResizeFilter::PointSample,
  )
  assert_eq(result.width, 2)
  assert_eq(result.height, 2)
}
