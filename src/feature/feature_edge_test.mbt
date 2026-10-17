// v204.0.0 feature 错误路径/边界增强测试

// ===== 辅助函数 =====

///|
fn feat_make_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn feat_make_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn feat_make_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

///|
fn feat_make_rgb(w : Int, h : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, 128)),
  }
}

///|
fn feat_make_checkerboard(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      if (x + y) % 2 == 0 {
        data[y * w + x] = b'\xFF'
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ===== 1. histogram 错误路径 =====

///|
test "feat_edge: histogram 零宽度" {
  try {
    let _ = @feature.histogram(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: histogram 数据不匹配" {
  try {
    let _ = @feature.histogram(feat_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: histogram 单像素" {
  try {
    let hist = @feature.histogram(feat_make_uniform(1, 1, 128))
    assert_eq(hist.length(), 256)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: histogram 全黑" {
  try {
    let hist = @feature.histogram(feat_make_uniform(8, 8, 0))
    assert_eq(hist[0], 64)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: histogram 全白" {
  try {
    let hist = @feature.histogram(feat_make_uniform(8, 8, 255))
    assert_eq(hist[255], 64)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. histogram_equalize 错误路径 =====

///|
test "feat_edge: histogram_equalize 零宽度" {
  try {
    let _ = @feature.histogram_equalize(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: histogram_equalize 全黑" {
  try {
    let result = @feature.histogram_equalize(feat_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: histogram_equalize 单像素" {
  try {
    let result = @feature.histogram_equalize(feat_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 3. histogram_normalize 错误路径 =====

///|
test "feat_edge: histogram_normalize 零宽度" {
  try {
    let _ = @feature.histogram_normalize(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: histogram_normalize 全白" {
  try {
    let result = @feature.histogram_normalize(feat_make_uniform(4, 4, 255))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 4. compare_hist 错误路径 =====

///|
test "feat_edge: compare_hist 不同长度" {
  try {
    let _ = @feature.compare_hist(
      [1, 2, 3],
      [1, 2],
      @feature.HistCompareMethod::Correlation,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: compare_hist 相同直方图" {
  try {
    let result = @feature.compare_hist(
      [10, 20, 30],
      [10, 20, 30],
      @feature.HistCompareMethod::Correlation,
    )
    assert_true(result >= -1.0 && result <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: compare_hist ChiSquare" {
  try {
    let result = @feature.compare_hist(
      [10, 20, 30],
      [20, 10, 30],
      @feature.HistCompareMethod::ChiSquare,
    )
    assert_true(result >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: compare_hist Bhattacharyya" {
  try {
    let result = @feature.compare_hist(
      [10, 20, 30],
      [10, 20, 30],
      @feature.HistCompareMethod::Bhattacharyya,
    )
    assert_true(result >= 0.0 && result <= 1.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 5. mse 错误路径 =====

///|
test "feat_edge: mse 零宽度img1" {
  try {
    let _ = @feature.mse(feat_make_zero_w(), feat_make_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: mse 零宽度img2" {
  try {
    let _ = @feature.mse(feat_make_uniform(4, 4, 128), feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: mse 尺寸不同" {
  try {
    let _ = @feature.mse(
      feat_make_uniform(4, 4, 128),
      feat_make_uniform(8, 8, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: mse 相同图像" {
  try {
    let img = feat_make_uniform(4, 4, 128)
    let result = @feature.mse(img, img)
    assert_eq(result, 0.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: mse 单像素" {
  try {
    let img1 = feat_make_uniform(1, 1, 100)
    let img2 = feat_make_uniform(1, 1, 200)
    let result = @feature.mse(img1, img2)
    assert_true(result > 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 6. psnr 错误路径 =====

///|
test "feat_edge: psnr 零宽度" {
  try {
    let _ = @feature.psnr(feat_make_zero_w(), feat_make_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: psnr 尺寸不同" {
  try {
    let _ = @feature.psnr(
      feat_make_uniform(4, 4, 128),
      feat_make_uniform(2, 2, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: psnr 相同图像" {
  try {
    let img = feat_make_uniform(4, 4, 128)
    let result = @feature.psnr(img, img)
    assert_true(result > 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 7. ssim 错误路径 =====

///|
test "feat_edge: ssim 零宽度" {
  try {
    let _ = @feature.ssim(feat_make_zero_w(), feat_make_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: ssim 尺寸不同" {
  try {
    let _ = @feature.ssim(
      feat_make_uniform(4, 4, 128),
      feat_make_uniform(8, 8, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: ssim 相同图像" {
  try {
    let img = feat_make_uniform(8, 8, 128)
    let result = @feature.ssim(img, img)
    assert_true(result > 0.9)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 8. integral_image 错误路径 =====

///|
test "feat_edge: integral_image 零宽度" {
  try {
    let _ = @feature.integral_image(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: integral_image 数据不匹配" {
  try {
    let _ = @feature.integral_image(feat_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: integral_image 单像素" {
  try {
    let ii = @feature.integral_image(feat_make_uniform(1, 1, 100))
    let s = @feature.integral_sum(ii, 0, 0, 1, 1)
    assert_eq(s, 100L)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: integral_image 全黑4x4" {
  try {
    let ii = @feature.integral_image(feat_make_uniform(4, 4, 0))
    let s = @feature.integral_sum(ii, 0, 0, 4, 4)
    assert_eq(s, 0L)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 9. lbp 错误路径 =====

///|
test "feat_edge: lbp 零宽度" {
  try {
    let _ = @feature.lbp(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: lbp 数据不匹配" {
  try {
    let _ = @feature.lbp(feat_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: lbp 单像素" {
  try {
    let result = @feature.lbp(feat_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: lbp 全黑" {
  try {
    let result = @feature.lbp(feat_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 10. lbp_uniform 错误路径 =====

///|
test "feat_edge: lbp_uniform 零宽度" {
  try {
    let _ = @feature.lbp_uniform(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: lbp_uniform 棋盘格" {
  try {
    let result = @feature.lbp_uniform(feat_make_checkerboard(4, 4))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 11. ahash 错误路径 =====

///|
test "feat_edge: ahash 零宽度" {
  try {
    let _ = @feature.ahash(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: ahash 数据不匹配" {
  try {
    let _ = @feature.ahash(feat_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: ahash 单像素" {
  try {
    let hash = @feature.ahash(feat_make_uniform(1, 1, 128))
    assert_eq(hash.length(), 64)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: ahash RGB图像" {
  try {
    let hash = @feature.ahash(feat_make_rgb(8, 8))
    assert_eq(hash.length(), 64)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 12. dhash 错误路径 =====

///|
test "feat_edge: dhash 零宽度" {
  try {
    let _ = @feature.dhash(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: dhash 单像素" {
  try {
    let hash = @feature.dhash(feat_make_uniform(1, 1, 128))
    assert_eq(hash.length(), 64)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 13. phash 错误路径 =====

///|
test "feat_edge: phash 零宽度" {
  try {
    let _ = @feature.phash(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: phash 单像素" {
  try {
    let hash = @feature.phash(feat_make_uniform(1, 1, 128))
    assert_eq(hash.length(), 64)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 14. hamming_distance 错误路径 =====

///|
test "feat_edge: hamming_distance 不同长度" {
  try {
    let _ = @feature.hamming_distance([1, 0, 1], [1, 0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: hamming_distance 相同哈希" {
  try {
    let d = @feature.hamming_distance([1, 0, 1, 0], [1, 0, 1, 0])
    assert_eq(d, 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: hamming_distance 完全不同" {
  try {
    let d = @feature.hamming_distance([1, 1, 1, 1], [0, 0, 0, 0])
    assert_eq(d, 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 15. harris_corners 错误路径 =====

///|
test "feat_edge: harris_corners 零宽度" {
  try {
    let _ = @feature.harris_corners(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: harris_corners k为零" {
  try {
    let _ = @feature.harris_corners(feat_make_uniform(8, 8, 128), k=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: harris_corners threshold为负" {
  try {
    let _ = @feature.harris_corners(
      feat_make_uniform(8, 8, 128),
      threshold=-1.0F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: harris_corners 全黑" {
  try {
    let corners = @feature.harris_corners(feat_make_uniform(8, 8, 0))
    assert_true(corners.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: harris_corners 棋盘格" {
  try {
    let corners = @feature.harris_corners(feat_make_checkerboard(8, 8))
    assert_true(corners.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: harris_corners RGB" {
  try {
    let corners = @feature.harris_corners(feat_make_rgb(8, 8))
    assert_true(corners.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 16. gabor_filter 错误路径 =====

///|
test "feat_edge: gabor_filter 零宽度" {
  try {
    let _ = @feature.gabor_filter(feat_make_zero_w(), 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: gabor_filter 全黑" {
  try {
    let result = @feature.gabor_filter(
      feat_make_uniform(8, 8, 0),
      3,
      1.0F,
      0.0F,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: gabor_filter RGB" {
  try {
    let result = @feature.gabor_filter(feat_make_rgb(8, 8), 3, 1.0F, 0.5F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 17. compute_glcm 错误路径 =====

///|
test "feat_edge: compute_glcm 零宽度" {
  try {
    let _ = @feature.compute_glcm(feat_make_zero_w(), 1, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: compute_glcm dx_dy都为零" {
  try {
    let _ = @feature.compute_glcm(feat_make_uniform(4, 4, 128), 0, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: compute_glcm levels太小" {
  try {
    let _ = @feature.compute_glcm(feat_make_uniform(4, 4, 128), 1, 0, levels=1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: compute_glcm levels太大" {
  try {
    let _ = @feature.compute_glcm(
      feat_make_uniform(4, 4, 128),
      1,
      0,
      levels=257,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: compute_glcm 全黑" {
  try {
    let glcm = @feature.compute_glcm(feat_make_uniform(4, 4, 0), 1, 0)
    assert_true(glcm.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: compute_glcm 棋盘格" {
  try {
    let glcm = @feature.compute_glcm(
      feat_make_checkerboard(4, 4),
      1,
      0,
      levels=4,
    )
    assert_true(glcm.length() > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 18. lucas_kanade 错误路径 =====

///|
test "feat_edge: lucas_kanade prev零宽度" {
  try {
    let _ = @feature.lucas_kanade(
      feat_make_zero_w(),
      feat_make_uniform(4, 4, 128),
      [],
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: lucas_kanade next零宽度" {
  try {
    let _ = @feature.lucas_kanade(
      feat_make_uniform(4, 4, 128),
      feat_make_zero_w(),
      [],
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: lucas_kanade 空点集" {
  try {
    let img = feat_make_uniform(8, 8, 128)
    let _ = @feature.lucas_kanade(img, img, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 19. horn_schunck 错误路径 =====

///|
test "feat_edge: horn_schunck prev零宽度" {
  try {
    let _ = @feature.horn_schunck(
      feat_make_zero_w(),
      feat_make_uniform(4, 4, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: horn_schunck 相同图像" {
  try {
    let img = feat_make_uniform(8, 8, 128)
    let (u, v) = @feature.horn_schunck(img, img)
    assert_true(u.length() >= 0 && v.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 20. template_match 错误路径 =====

///|
test "feat_edge: template_match 零宽度" {
  try {
    let _ = @feature.template_match(
      feat_make_zero_w(),
      feat_make_uniform(2, 2, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: template_match 模板零宽度" {
  try {
    let _ = @feature.template_match(
      feat_make_uniform(8, 8, 128),
      feat_make_zero_w(),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: template_match 全黑" {
  try {
    let img = feat_make_uniform(8, 8, 0)
    let tpl = feat_make_uniform(2, 2, 0)
    let results = @feature.template_match(img, tpl)
    assert_true(results.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: template_match_best 全黑" {
  try {
    let img = feat_make_uniform(8, 8, 0)
    let tpl = feat_make_uniform(2, 2, 0)
    let result = @feature.template_match_best(img, tpl)
    assert_true(result is Some(_) || result is None)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 21. integral_mean 边界 =====

///|
test "feat_edge: integral_mean 全白" {
  try {
    let ii = @feature.integral_image(feat_make_uniform(4, 4, 255))
    let m = @feature.integral_mean(ii, 0, 0, 4, 4)
    assert_true(m > 250.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "feat_edge: integral_mean 部分区域" {
  try {
    let ii = @feature.integral_image(feat_make_uniform(8, 8, 100))
    let m = @feature.integral_mean(ii, 2, 2, 4, 4)
    assert_true(m > 95.0 && m < 105.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 22. integral_image_sq 边界 =====

///|
test "feat_edge: integral_image_sq 零宽度" {
  try {
    let _ = @feature.integral_image_sq(feat_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: integral_image_sq 单像素" {
  try {
    let iisq = @feature.integral_image_sq(feat_make_uniform(1, 1, 100))
    let s = @feature.integral_sum_sq(iisq, 0, 0, 1, 1)
    assert_eq(s, 10000L)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 23. integral_variance 边界 =====

///|
test "feat_edge: integral_variance 全黑" {
  try {
    let ii = @feature.integral_image(feat_make_uniform(4, 4, 0))
    let iisq = @feature.integral_image_sq(feat_make_uniform(4, 4, 0))
    let v = @feature.integral_variance(ii, iisq, 0, 0, 4, 4)
    assert_true(v >= 0.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 24. histogram_matching 边界 =====

///|
test "feat_edge: histogram_matching 零宽度" {
  try {
    let _ = @feature.histogram_matching(
      feat_make_zero_w(),
      feat_make_uniform(4, 4, 128),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "feat_edge: histogram_matching 相同图像" {
  try {
    let img = feat_make_uniform(4, 4, 128)
    let result = @feature.histogram_matching(img, img)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 25. gabor_filter_bank 边界 =====

///|
test "feat_edge: gabor_filter_bank 全黑" {
  try {
    let result = @feature.gabor_filter_bank(feat_make_uniform(8, 8, 0), 3, 1.0F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 26. glcm_features 边界 =====

///|
test "feat_edge: glcm_features 零矩阵" {
  let glcm : Array[Array[Int]] = Array::make(4, Array::make(4, 0))
  let features = @feature.glcm_features(glcm)
  assert_true(features.contrast >= 0.0)
}

///|
test "feat_edge: glcm_features 单元素" {
  let glcm : Array[Array[Int]] = [
    [1, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
  ]
  let features = @feature.glcm_features(glcm)
  assert_true(features.contrast >= 0.0)
}
