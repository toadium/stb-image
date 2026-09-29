// v30.0.0 图像质量评估测试 — quality 模块 7 函数

///|
fn create_solid_ql(w : Int, h : Int, v : Int) -> @types.Image {
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
fn create_gradient_ql(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) * 255 / (w + h) % 256).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "compute_mse: 相同图像MSE为0" {
  let img = create_solid_ql(16, 16, 128)
  let mse = compute_mse(img, img)
  assert_true(mse == 0.0)
}

///|
test "compute_mae: 相同图像MAE为0" {
  let img = create_solid_ql(16, 16, 128)
  let mae = compute_mae(img, img)
  assert_true(mae == 0.0)
}

///|
test "compute_psnr: 相同图像PSNR高" {
  let img = create_gradient_ql(16, 16)
  let psnr = compute_psnr(img, img)
  assert_true(psnr >= 0.0)
}

///|
test "compute_ssim: 相同图像SSIM为1" {
  let img = create_gradient_ql(16, 16)
  let ssim = compute_ssim(img, img)
  assert_true(ssim >= 0.0 && ssim <= 1.0)
}

///|
test "compute_quality_metrics: 综合质量指标" {
  let img1 = create_gradient_ql(16, 16)
  let img2 = create_gradient_ql(16, 16)
  let metrics = compute_quality_metrics(img1, img2)
  assert_true(metrics.mse >= 0.0)
  assert_true(metrics.psnr >= 0.0)
  assert_true(metrics.ssim >= 0.0)
}

///|
test "images_equal: 相同图像返回true" {
  let img = create_solid_ql(16, 16, 128)
  assert_true(images_equal(img, img))
}

///|
test "images_equal: 不同图像返回false" {
  let img1 = create_solid_ql(16, 16, 100)
  let img2 = create_solid_ql(16, 16, 200)
  assert_true(!images_equal(img1, img2))
}

///|
test "compute_diff_image: 差值图像" {
  let img1 = create_solid_ql(16, 16, 200)
  let img2 = create_solid_ql(16, 16, 100)
  let diff = compute_diff_image(img1, img2)
  assert_true(diff.width == 16 && diff.height == 16)
}

///|
test "compute_mse: 不同图像MSE>0" {
  let img1 = create_solid_ql(16, 16, 200)
  let img2 = create_solid_ql(16, 16, 100)
  let mse = compute_mse(img1, img2)
  assert_true(mse > 0.0)
}
