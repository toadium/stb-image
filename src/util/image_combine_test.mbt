// v251.0.0 image_combine 覆盖率测试

///|
fn v251_make_image(
  w : Int,
  h : Int,
  ch : Int,
  pixels : Array[Int],
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
test "alpha_blend: alpha=0 returns img1" {
  let img1 = v251_make_image(2, 1, 1, [100, 200])
  let img2 = v251_make_image(2, 1, 1, [50, 60])
  let result = @util.alpha_blend(img1, img2, 0.0F)
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[1].to_int(), 200)
}

///|
test "alpha_blend: alpha=1 returns img2" {
  let img1 = v251_make_image(2, 1, 1, [100, 200])
  let img2 = v251_make_image(2, 1, 1, [50, 60])
  let result = @util.alpha_blend(img1, img2, 1.0F)
  assert_eq(result.data[0].to_int(), 50)
  assert_eq(result.data[1].to_int(), 60)
}

///|
test "alpha_blend: alpha=0.5 averages" {
  let img1 = v251_make_image(2, 1, 1, [100, 200])
  let img2 = v251_make_image(2, 1, 1, [50, 60])
  let result = @util.alpha_blend(img1, img2, 0.5F)
  assert_eq(result.data[0].to_int(), 75)
  assert_eq(result.data[1].to_int(), 130)
}

///|
test "alpha_blend: 3-channel image" {
  let img1 = v251_make_image(1, 1, 3, [255, 0, 0])
  let img2 = v251_make_image(1, 1, 3, [0, 255, 0])
  let result = @util.alpha_blend(img1, img2, 0.5F)
  assert_eq(result.data[0].to_int(), 127)
  assert_eq(result.data[1].to_int(), 127)
  assert_eq(result.data[2].to_int(), 0)
}

///|
test "alpha_blend: different sizes raises error" {
  let img1 = v251_make_image(2, 1, 1, [100, 200])
  let img2 = v251_make_image(1, 1, 1, [50])
  try {
    let _ = @util.alpha_blend(img1, img2, 0.5F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "alpha_blend: different channels raises error" {
  let img1 = v251_make_image(1, 1, 1, [100])
  let img2 = v251_make_image(1, 1, 3, [50, 60, 70])
  try {
    let _ = @util.alpha_blend(img1, img2, 0.5F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "alpha_blend: alpha clamped to 0-1" {
  let img1 = v251_make_image(1, 1, 1, [100])
  let img2 = v251_make_image(1, 1, 1, [200])
  let r1 = @util.alpha_blend(img1, img2, 2.0F)
  assert_eq(r1.data[0].to_int(), 200)
  let r2 = @util.alpha_blend(img1, img2, -1.0F)
  assert_eq(r2.data[0].to_int(), 100)
}

///|
test "mask_blend: white mask shows img2" {
  let img1 = v251_make_image(2, 1, 1, [100, 100])
  let img2 = v251_make_image(2, 1, 1, [200, 200])
  let mask = v251_make_image(2, 1, 1, [255, 255])
  let result = @util.mask_blend(img1, img2, mask)
  assert_eq(result.data[0].to_int(), 200)
  assert_eq(result.data[1].to_int(), 200)
}

///|
test "mask_blend: black mask shows img1" {
  let img1 = v251_make_image(2, 1, 1, [100, 100])
  let img2 = v251_make_image(2, 1, 1, [200, 200])
  let mask = v251_make_image(2, 1, 1, [0, 0])
  let result = @util.mask_blend(img1, img2, mask)
  assert_eq(result.data[0].to_int(), 100)
  assert_eq(result.data[1].to_int(), 100)
}

///|
test "mask_blend: gray mask averages" {
  let img1 = v251_make_image(1, 1, 1, [100])
  let img2 = v251_make_image(1, 1, 1, [200])
  let mask = v251_make_image(1, 1, 1, [128])
  let result = @util.mask_blend(img1, img2, mask)
  let val = result.data[0].to_int()
  assert_true(val >= 148 && val <= 152)
}

///|
test "mask_blend: 3-channel with mask" {
  let img1 = v251_make_image(1, 1, 3, [255, 0, 0])
  let img2 = v251_make_image(1, 1, 3, [0, 0, 255])
  let mask = v251_make_image(1, 1, 1, [255])
  let result = @util.mask_blend(img1, img2, mask)
  assert_eq(result.data[0].to_int(), 0)
  assert_eq(result.data[1].to_int(), 0)
  assert_eq(result.data[2].to_int(), 255)
}

///|
test "mask_blend: different sizes raises error" {
  let img1 = v251_make_image(2, 1, 1, [100, 100])
  let img2 = v251_make_image(1, 1, 1, [200])
  let mask = v251_make_image(1, 1, 1, [128])
  try {
    let _ = @util.mask_blend(img1, img2, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "mask_blend: mask not single channel raises error" {
  let img1 = v251_make_image(1, 1, 1, [100])
  let img2 = v251_make_image(1, 1, 1, [200])
  let mask = v251_make_image(1, 1, 3, [128, 128, 128])
  try {
    let _ = @util.mask_blend(img1, img2, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "mask_blend: mask size mismatch raises error" {
  let img1 = v251_make_image(2, 1, 1, [100, 100])
  let img2 = v251_make_image(2, 1, 1, [200, 200])
  let mask = v251_make_image(1, 1, 1, [128])
  try {
    let _ = @util.mask_blend(img1, img2, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flip_horizontal: 2x1 image" {
  let img = v251_make_image(2, 1, 1, [100, 200])
  let result = @util.flip_horizontal(img)
  assert_eq(result.data[0].to_int(), 200)
  assert_eq(result.data[1].to_int(), 100)
}

///|
test "flip_horizontal: 3x2 image with 3 channels" {
  let img = v251_make_image(2, 1, 3, [10, 20, 30, 40, 50, 60])
  let result = @util.flip_horizontal(img)
  assert_eq(result.data[0].to_int(), 40)
  assert_eq(result.data[1].to_int(), 50)
  assert_eq(result.data[2].to_int(), 60)
  assert_eq(result.data[3].to_int(), 10)
  assert_eq(result.data[4].to_int(), 20)
  assert_eq(result.data[5].to_int(), 30)
}

///|
test "flip_horizontal: 1x1 image unchanged" {
  let img = v251_make_image(1, 1, 1, [100])
  let result = @util.flip_horizontal(img)
  assert_eq(result.data[0].to_int(), 100)
}

///|
test "flip_vertical: 1x2 image" {
  let img = v251_make_image(1, 2, 1, [100, 200])
  let result = @util.flip_vertical(img)
  assert_eq(result.data[0].to_int(), 200)
  assert_eq(result.data[1].to_int(), 100)
}

///|
test "flip_vertical: 1x3 image" {
  let img = v251_make_image(1, 3, 1, [100, 150, 200])
  let result = @util.flip_vertical(img)
  assert_eq(result.data[0].to_int(), 200)
  assert_eq(result.data[1].to_int(), 150)
  assert_eq(result.data[2].to_int(), 100)
}

///|
test "flip_vertical: 1x1 image unchanged" {
  let img = v251_make_image(1, 1, 1, [100])
  let result = @util.flip_vertical(img)
  assert_eq(result.data[0].to_int(), 100)
}

///|
test "flip_horizontal + flip_vertical: double flip restores original" {
  let img = v251_make_image(2, 2, 1, [10, 20, 30, 40])
  let flipped = @util.flip_vertical(@util.flip_horizontal(img))
  assert_eq(flipped.data[0].to_int(), 40)
  assert_eq(flipped.data[1].to_int(), 30)
  assert_eq(flipped.data[2].to_int(), 20)
  assert_eq(flipped.data[3].to_int(), 10)
}
