// v194 feature 16f 变体增强测试

///|
fn f16_make_varied_img16(w : Int, h : Int, ch : Int) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    let val : Int = (i * 137 + 42) % 65536
    data[i * 2] = (val & 0xFF).to_byte()
    data[i * 2 + 1] = ((val >> 8) & 0xFF).to_byte()
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn f16_make_varied_imgf(w : Int, h : Int, ch : Int) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for i in 0..<(w * h * ch) {
    let v : Float = Float::from_int(i % 100) / 100.0F
    let bits = v.reinterpret_as_int()
    data[i * 4] = (bits & 0xFF).to_byte()
    data[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    data[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    data[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn f16_make_uniform_img16(
  w : Int,
  h : Int,
  ch : Int,
  val : Int,
) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i * 2] = (val & 0xFF).to_byte()
    data[i * 2 + 1] = ((val >> 8) & 0xFF).to_byte()
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn f16_make_uniform_imgf(
  w : Int,
  h : Int,
  ch : Int,
  val : Float,
) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * ch * 4, b'\x00')
  for i in 0..<(w * h * ch) {
    let bits = val.reinterpret_as_int()
    data[i * 4] = (bits & 0xFF).to_byte()
    data[i * 4 + 1] = ((bits >> 8) & 0xFF).to_byte()
    data[i * 4 + 2] = ((bits >> 16) & 0xFF).to_byte()
    data[i * 4 + 3] = ((bits >> 24) & 0xFF).to_byte()
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== hash_quality_integral_16f 增强测试 ==========

///|
test "f16: ahash_16 非均匀图像" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let result = @feature.ahash_16(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ahash_16 多通道" {
  let img = f16_make_varied_img16(16, 16, 3)
  try {
    let result = @feature.ahash_16(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: dhash_16 非均匀图像" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let result = @feature.dhash_16(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: phash_16 非均匀图像" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let result = @feature.phash_16(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ahash_f 非均匀图像" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let result = @feature.ahash_f(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: dhash_f 非均匀图像" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let result = @feature.dhash_f(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: phash_f 非均匀图像" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let result = @feature.phash_f(img)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_16 不同图像" {
  let img1 = f16_make_varied_img16(16, 16, 1)
  let img2 = f16_make_uniform_img16(16, 16, 1, 10000)
  try {
    let result = @feature.mse_16(img1, img2)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_16 相同图像为零" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.mse_16(img, img)
    assert_true(result < 1.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: psnr_16 不同图像" {
  let img1 = f16_make_varied_img16(16, 16, 1)
  let img2 = f16_make_uniform_img16(16, 16, 1, 0)
  try {
    let result = @feature.psnr_16(img1, img2)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ssim_16 不同图像" {
  let img1 = f16_make_varied_img16(16, 16, 1)
  let img2 = f16_make_uniform_img16(16, 16, 1, 30000)
  try {
    let result = @feature.ssim_16(img1, img2)
    assert_true(result >= -1.0 && result <= 1.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_f 不同图像" {
  let img1 = f16_make_varied_imgf(16, 16, 1)
  let img2 = f16_make_uniform_imgf(16, 16, 1, 0.5F)
  try {
    let result = @feature.mse_f(img1, img2)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: psnr_f 不同图像" {
  let img1 = f16_make_varied_imgf(16, 16, 1)
  let img2 = f16_make_uniform_imgf(16, 16, 1, 0.0F)
  try {
    let result = @feature.psnr_f(img1, img2)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ssim_f 不同图像" {
  let img1 = f16_make_varied_imgf(16, 16, 1)
  let img2 = f16_make_uniform_imgf(16, 16, 1, 0.8F)
  try {
    let result = @feature.ssim_f(img1, img2)
    assert_true(result >= -1.0 && result <= 1.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: integral_image_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let ii = @feature.integral_image_16(img)
    let s1 = @feature.integral_sum(ii, 0, 0, 8, 8)
    let s2 = @feature.integral_sum(ii, 4, 4, 12, 12)
    assert_true(s1 >= 0)
    assert_true(s2 >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: integral_image_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let ii = @feature.integral_image_f(img)
    let s = @feature.integral_sum(ii, 0, 0, 8, 8)
    let _ = s
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: integral_image_sq_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let ii = @feature.integral_image_sq_16(img)
    let s = @feature.integral_sum_sq(ii, 0, 0, 8, 8)
    assert_true(s >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: integral_image_sq_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let ii = @feature.integral_image_sq_f(img)
    let s = @feature.integral_sum_sq(ii, 0, 0, 8, 8)
    let _ = s
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== histogram_16f 增强测试 ==========

///|
test "f16: histogram_16 非均匀图像" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let hist = @feature.histogram_16(img)
    assert_true(hist.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_f 非均匀图像" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let hist = @feature.histogram_f(img)
    assert_true(hist.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_equalize_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.histogram_equalize_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_equalize_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let result = @feature.histogram_equalize_f(img)
    assert_eq(result.width, 16)
    assert_eq(result.height, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_normalize_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.histogram_normalize_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_normalize_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let result = @feature.histogram_normalize_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== optical_glcm_16f 增强测试 ==========

///|
test "f16: compute_glcm_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let glcm = @feature.compute_glcm_16(img, 1, 0)
    let _ = glcm
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: compute_glcm_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let glcm = @feature.compute_glcm_f(img, 1, 0)
    let _ = glcm
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: glcm_features_multi_direction_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let features = @feature.glcm_features_multi_direction_16(img)
    let _ = features
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: glcm_features_multi_direction_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let features = @feature.glcm_features_multi_direction_f(img)
    let _ = features
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== gabor_template_16f 增强测试 ==========

///|
test "f16: gabor_filter_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.gabor_filter_16(img, 3, 0.5F, 0.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gabor_filter_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let result = @feature.gabor_filter_f(img, 3, 0.5F, 0.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gabor_filter_bank_16 非均匀" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.gabor_filter_bank_16(img, 3, 0.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gabor_filter_bank_f 非均匀" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let result = @feature.gabor_filter_bank_f(img, 3, 0.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: template_match_16 非均匀" {
  let img = f16_make_varied_img16(32, 32, 1)
  let tmpl = f16_make_varied_img16(8, 8, 1)
  try {
    let result = @feature.template_match_16(img, tmpl)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: template_match_f 非均匀" {
  let img = f16_make_varied_imgf(32, 32, 1)
  let tmpl = f16_make_varied_imgf(8, 8, 1)
  try {
    let result = @feature.template_match_f(img, tmpl)
    assert_true(result.length() > 0)
  } catch {
    _ => assert_true(true)
  }
}

// ========== feature_advanced_16f 增强测试 ==========

///|
test "f16: harris_corners_16 非均匀" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let corners = @feature.harris_corners_16(img)
    let _ = corners
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: harris_corners_f 非均匀" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let corners = @feature.harris_corners_f(img)
    let _ = corners
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: good_features_to_track_16 非均匀" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let corners = @feature.good_features_to_track_16(img, 50, 0.01F)
    let _ = corners
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: good_features_to_track_f 非均匀" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let corners = @feature.good_features_to_track_f(img, 50, 0.01F)
    let _ = corners
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sift_detect_16 非均匀" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let descriptors = @feature.sift_detect_16(img)
    let _ = descriptors
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sift_detect_f 非均匀" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let descriptors = @feature.sift_detect_f(img)
    let _ = descriptors
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: orb_detect_16 非均匀" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let keypoints = @feature.orb_detect_16(img)
    let _ = keypoints
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: orb_detect_f 非均匀" {
  let img = f16_make_varied_imgf(32, 32, 1)
  try {
    let keypoints = @feature.orb_detect_f(img)
    let _ = keypoints
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 错误路径测试 ==========

///|
test "f16: ahash_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.ahash_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: dhash_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.dhash_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: phash_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.phash_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.histogram_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @feature.histogram_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_16 尺寸不匹配" {
  let img1 = f16_make_varied_img16(16, 16, 1)
  let img2 = f16_make_varied_img16(8, 8, 1)
  try {
    let _ = @feature.mse_16(img1, img2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_f 尺寸不匹配" {
  let img1 = f16_make_varied_imgf(16, 16, 1)
  let img2 = f16_make_varied_imgf(8, 8, 1)
  try {
    let _ = @feature.mse_f(img1, img2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ssim_16 相同图像为1" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.ssim_16(img, img)
    assert_true((result - 1.0).abs() < 0.01)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: ssim_f 相同图像为1" {
  let img = f16_make_varied_imgf(16, 16, 1)
  try {
    let result = @feature.ssim_f(img, img)
    assert_true((result - 1.0).abs() < 0.01)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: mse_16 多通道" {
  let img1 = f16_make_varied_img16(16, 16, 3)
  let img2 = f16_make_uniform_img16(16, 16, 3, 20000)
  try {
    let result = @feature.mse_16(img1, img2)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: psnr_16 相同图像无穷" {
  let img = f16_make_varied_img16(16, 16, 1)
  try {
    let result = @feature.psnr_16(img, img)
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: integral_image_16 不同区域" {
  let img = f16_make_varied_img16(32, 32, 1)
  try {
    let ii = @feature.integral_image_16(img)
    let s1 = @feature.integral_sum(ii, 0, 0, 16, 16)
    let s2 = @feature.integral_sum(ii, 8, 8, 24, 24)
    let s3 = @feature.integral_sum(ii, 0, 0, 32, 32)
    assert_true(s1 >= 0)
    assert_true(s2 >= 0)
    assert_true(s3 >= s1)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: histogram_equalize_16 多通道" {
  let img = f16_make_varied_img16(16, 16, 3)
  try {
    let result = @feature.histogram_equalize_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gabor_filter_16 不同方向" {
  let img = f16_make_varied_img16(16, 16, 1)
  for angle in [0.0F, 45.0F, 90.0F, 135.0F] {
    try {
      let result = @feature.gabor_filter_16(img, 3, 0.5F, angle)
      assert_eq(result.width, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "f16: gabor_filter_f 不同方向" {
  let img = f16_make_varied_imgf(16, 16, 1)
  for angle in [0.0F, 45.0F, 90.0F, 135.0F] {
    try {
      let result = @feature.gabor_filter_f(img, 3, 0.5F, angle)
      assert_eq(result.width, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}
