// v252.0.0 process 模块覆盖率提升 — quality 边界测试

///|
fn v252_solid(w : Int32, h : Int32, ch : Int32, v : Int32) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h * ch) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
test "v252 compute_mse: different sizes returns -1" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let mse = @quality.compute_mse(img1, img2)
  assert_true(mse == -1.0)
}

///|
test "v252 compute_mse: known difference" {
  let img1 = v252_solid(2, 1, 1, 100)
  let img2 = v252_solid(2, 1, 1, 110)
  let mse = @quality.compute_mse(img1, img2)
  assert_true(mse == 100.0)
}

///|
test "v252 compute_mse: 3-channel" {
  let img1 = v252_solid(1, 1, 3, 100)
  let img2 = v252_solid(1, 1, 3, 200)
  let mse = @quality.compute_mse(img1, img2)
  assert_true(mse == 10000.0)
}

///|
test "v252 compute_mae: different sizes returns -1" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let mae = @quality.compute_mae(img1, img2)
  assert_true(mae == -1.0)
}

///|
test "v252 compute_mae: known difference" {
  let img1 = v252_solid(2, 1, 1, 100)
  let img2 = v252_solid(2, 1, 1, 130)
  let mae = @quality.compute_mae(img1, img2)
  assert_true(mae == 30.0)
}

///|
test "v252 compute_psnr: different sizes returns -1" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let psnr = @quality.compute_psnr(img1, img2)
  assert_true(psnr == -1.0)
}

///|
test "v252 compute_ssim: different sizes returns -1" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let ssim = @quality.compute_ssim(img1, img2)
  assert_true(ssim == -1.0)
}

///|
test "v252 images_equal: different sizes returns false" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  assert_false(@quality.images_equal(img1, img2))
}

///|
test "v252 images_equal: different channels returns false" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(2, 2, 3, 100)
  assert_false(@quality.images_equal(img1, img2))
}

///|
test "v252 images_equal: same image returns true" {
  let img = v252_solid(4, 4, 3, 128)
  assert_true(@quality.images_equal(img, img))
}

///|
test "v252 compute_diff_image: same image returns zeros" {
  let img = v252_solid(2, 2, 1, 100)
  let diff = @quality.compute_diff_image(img, img)
  assert_eq(diff.width, 2)
  assert_eq(diff.height, 2)
  for i in 0..<diff.data.length() {
    assert_eq(diff.data[i].to_int(), 0)
  }
}

///|
test "v252 compute_diff_image: different sizes returns img1" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let diff = @quality.compute_diff_image(img1, img2)
  assert_eq(diff.width, 2)
  assert_eq(diff.height, 2)
}

///|
test "v252 compute_diff_image: 3-channel output" {
  let img1 = v252_solid(2, 1, 3, 200)
  let img2 = v252_solid(2, 1, 3, 100)
  let diff = @quality.compute_diff_image(img1, img2)
  assert_eq(diff.channels, 3)
  for i in 0..<diff.data.length() {
    if i % 3 == 0 {
      assert_eq(diff.data[i].to_int(), 100)
    } else {
      assert_eq(diff.data[i].to_int(), 0)
    }
  }
}

///|
test "v252 compute_quality_metrics: different sizes" {
  let img1 = v252_solid(2, 2, 1, 100)
  let img2 = v252_solid(3, 3, 1, 100)
  let metrics = @quality.compute_quality_metrics(img1, img2)
  assert_true(metrics.mse == -1.0)
  assert_true(metrics.mae == -1.0)
}
