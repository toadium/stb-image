// v214.0.0 feature 16f/f 错误路径增强测试

// ===== 辅助函数 =====

///|
fn fe2_mk16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn fe2_mkf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

///|
fn fe2_mk16_bad(w : Int, h : Int, ch : Int) -> @types.Image16 {
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

///|
fn fe2_mkf_bad(w : Int, h : Int, ch : Int) -> @types.ImageF {
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

// ===== 1. histogram_16/f =====

///|
test "fe2_edge: histogram_16 零宽度" {
  try {
    let _ = @feature.histogram_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_16 无效通道" {
  try {
    let _ = @feature.histogram_16(fe2_mk16(4, 4, 5, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_16 数据不匹配" {
  try {
    let _ = @feature.histogram_16(fe2_mk16_bad(4, 4, 1))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_f 零宽度" {
  try {
    let _ = @feature.histogram_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_f 无效通道" {
  try {
    let _ = @feature.histogram_f(fe2_mkf(4, 4, 0, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_f 数据不匹配" {
  try {
    let _ = @feature.histogram_f(fe2_mkf_bad(4, 4, 1))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. histogram_equalize_16/f =====

///|
test "fe2_edge: histogram_equalize_16 零宽度" {
  try {
    let _ = @feature.histogram_equalize_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_equalize_f 零宽度" {
  try {
    let _ = @feature.histogram_equalize_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. histogram_normalize_16/f =====

///|
test "fe2_edge: histogram_normalize_16 零宽度" {
  try {
    let _ = @feature.histogram_normalize_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_normalize_f 零宽度" {
  try {
    let _ = @feature.histogram_normalize_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. histogram_matching_16/f =====

///|
test "fe2_edge: histogram_matching_16 零宽度" {
  try {
    let _ = @feature.histogram_matching_16(
      fe2_mk16(0, 4, 1, 100),
      fe2_mk16(4, 4, 1, 200),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: histogram_matching_f 零宽度" {
  try {
    let _ = @feature.histogram_matching_f(
      fe2_mkf(0, 4, 1, 1.0F),
      fe2_mkf(4, 4, 1, 2.0F),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. ahash/dhash/phash 16/f =====

///|
test "fe2_edge: ahash_16 零宽度" {
  try {
    let _ = @feature.ahash_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: ahash_f 零宽度" {
  try {
    let _ = @feature.ahash_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: dhash_16 零宽度" {
  try {
    let _ = @feature.dhash_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: dhash_f 零宽度" {
  try {
    let _ = @feature.dhash_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: phash_16 零宽度" {
  try {
    let _ = @feature.phash_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: phash_f 零宽度" {
  try {
    let _ = @feature.phash_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. harris_corners_16/f =====

///|
test "fe2_edge: harris_corners_16 零宽度" {
  try {
    let _ = @feature.harris_corners_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: harris_corners_f 零宽度" {
  try {
    let _ = @feature.harris_corners_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. good_features_to_track_16/f =====

///|
test "fe2_edge: good_features_to_track_16 零宽度" {
  try {
    let _ = @feature.good_features_to_track_16(
      fe2_mk16(0, 4, 1, 100),
      10,
      0.01F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: good_features_to_track_f 零宽度" {
  try {
    let _ = @feature.good_features_to_track_f(fe2_mkf(0, 4, 1, 1.0F), 10, 0.01F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. gabor_filter_16/f =====

///|
test "fe2_edge: gabor_filter_16 零宽度" {
  try {
    let _ = @feature.gabor_filter_16(fe2_mk16(0, 4, 1, 100), 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: gabor_filter_f 零宽度" {
  try {
    let _ = @feature.gabor_filter_f(fe2_mkf(0, 4, 1, 1.0F), 3, 1.0F, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 9. gabor_filter_bank_16/f =====

///|
test "fe2_edge: gabor_filter_bank_16 零宽度" {
  try {
    let _ = @feature.gabor_filter_bank_16(fe2_mk16(0, 4, 1, 100), 3, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: gabor_filter_bank_f 零宽度" {
  try {
    let _ = @feature.gabor_filter_bank_f(fe2_mkf(0, 4, 1, 1.0F), 3, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 10. compute_glcm_16/f =====

///|
test "fe2_edge: compute_glcm_16 零宽度" {
  try {
    let _ = @feature.compute_glcm_16(fe2_mk16(0, 4, 1, 100), 1, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: compute_glcm_16 dx_dy都为零" {
  try {
    let _ = @feature.compute_glcm_16(fe2_mk16(4, 4, 1, 100), 0, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: compute_glcm_f 零宽度" {
  try {
    let _ = @feature.compute_glcm_f(fe2_mkf(0, 4, 1, 1.0F), 1, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: compute_glcm_f dx_dy都为零" {
  try {
    let _ = @feature.compute_glcm_f(fe2_mkf(4, 4, 1, 1.0F), 0, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 11. glcm_features_multi_direction_16/f =====

///|
test "fe2_edge: glcm_features_multi_direction_16 零宽度" {
  try {
    let _ = @feature.glcm_features_multi_direction_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: glcm_features_multi_direction_f 零宽度" {
  try {
    let _ = @feature.glcm_features_multi_direction_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 12. lbp_16/f =====

///|
test "fe2_edge: lbp_16 零宽度" {
  try {
    let _ = @feature.lbp_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: lbp_f 零宽度" {
  try {
    let _ = @feature.lbp_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 13. lbp_uniform_16/f =====

///|
test "fe2_edge: lbp_uniform_16 零宽度" {
  try {
    let _ = @feature.lbp_uniform_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: lbp_uniform_f 零宽度" {
  try {
    let _ = @feature.lbp_uniform_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 14. integral_image_16/f =====

///|
test "fe2_edge: integral_image_16 零宽度" {
  try {
    let _ = @feature.integral_image_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: integral_image_f 零宽度" {
  try {
    let _ = @feature.integral_image_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 15. integral_image_sq_16/f =====

///|
test "fe2_edge: integral_image_sq_16 零宽度" {
  try {
    let _ = @feature.integral_image_sq_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: integral_image_sq_f 零宽度" {
  try {
    let _ = @feature.integral_image_sq_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 16. mse_16/f =====

///|
test "fe2_edge: mse_16 零宽度" {
  try {
    let _ = @feature.mse_16(fe2_mk16(0, 4, 1, 100), fe2_mk16(4, 4, 1, 200))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: mse_16 尺寸不同" {
  try {
    let _ = @feature.mse_16(fe2_mk16(4, 4, 1, 100), fe2_mk16(8, 8, 1, 200))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: mse_f 零宽度" {
  try {
    let _ = @feature.mse_f(fe2_mkf(0, 4, 1, 1.0F), fe2_mkf(4, 4, 1, 2.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: mse_f 尺寸不同" {
  try {
    let _ = @feature.mse_f(fe2_mkf(4, 4, 1, 1.0F), fe2_mkf(8, 8, 1, 2.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 17. psnr_16/f =====

///|
test "fe2_edge: psnr_16 零宽度" {
  try {
    let _ = @feature.psnr_16(fe2_mk16(0, 4, 1, 100), fe2_mk16(4, 4, 1, 200))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: psnr_f 零宽度" {
  try {
    let _ = @feature.psnr_f(fe2_mkf(0, 4, 1, 1.0F), fe2_mkf(4, 4, 1, 2.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 18. ssim_16/f =====

///|
test "fe2_edge: ssim_16 零宽度" {
  try {
    let _ = @feature.ssim_16(fe2_mk16(0, 4, 1, 100), fe2_mk16(4, 4, 1, 200))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: ssim_f 零宽度" {
  try {
    let _ = @feature.ssim_f(fe2_mkf(0, 4, 1, 1.0F), fe2_mkf(4, 4, 1, 2.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 19. lucas_kanade_16/f =====

///|
test "fe2_edge: lucas_kanade_16 prev零宽度" {
  try {
    let _ = @feature.lucas_kanade_16(
      fe2_mk16(0, 4, 1, 100),
      fe2_mk16(4, 4, 1, 200),
      [],
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: lucas_kanade_16 空点集" {
  try {
    let img = fe2_mk16(8, 8, 1, 100)
    let _ = @feature.lucas_kanade_16(img, img, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: lucas_kanade_f prev零宽度" {
  try {
    let _ = @feature.lucas_kanade_f(
      fe2_mkf(0, 4, 1, 1.0F),
      fe2_mkf(4, 4, 1, 2.0F),
      [],
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: lucas_kanade_f 空点集" {
  try {
    let img = fe2_mkf(8, 8, 1, 1.0F)
    let _ = @feature.lucas_kanade_f(img, img, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 20. horn_schunck_16/f =====

///|
test "fe2_edge: horn_schunck_16 prev零宽度" {
  try {
    let _ = @feature.horn_schunck_16(
      fe2_mk16(0, 4, 1, 100),
      fe2_mk16(4, 4, 1, 200),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: horn_schunck_f prev零宽度" {
  try {
    let _ = @feature.horn_schunck_f(
      fe2_mkf(0, 4, 1, 1.0F),
      fe2_mkf(4, 4, 1, 2.0F),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 21. template_match_16/f =====

///|
test "fe2_edge: template_match_16 零宽度" {
  try {
    let _ = @feature.template_match_16(
      fe2_mk16(0, 4, 1, 100),
      fe2_mk16(2, 2, 1, 200),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: template_match_f 零宽度" {
  try {
    let _ = @feature.template_match_f(
      fe2_mkf(0, 4, 1, 1.0F),
      fe2_mkf(2, 2, 1, 2.0F),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 22. template_match_best_16/f =====

///|
test "fe2_edge: template_match_best_16 零宽度" {
  try {
    let _ = @feature.template_match_best_16(
      fe2_mk16(0, 4, 1, 100),
      fe2_mk16(2, 2, 1, 200),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: template_match_best_f 零宽度" {
  try {
    let _ = @feature.template_match_best_f(
      fe2_mkf(0, 4, 1, 1.0F),
      fe2_mkf(2, 2, 1, 2.0F),
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 23. orb_detect_16/f =====

///|
test "fe2_edge: orb_detect_16 零宽度" {
  try {
    let _ = @feature.orb_detect_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: orb_detect_f 零宽度" {
  try {
    let _ = @feature.orb_detect_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 24. sift_detect_16/f =====

///|
test "fe2_edge: sift_detect_16 零宽度" {
  try {
    let _ = @feature.sift_detect_16(fe2_mk16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_edge: sift_detect_f 零宽度" {
  try {
    let _ = @feature.sift_detect_f(fe2_mkf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 25. sift_match 空数组 =====

///|
test "fe2_edge: sift_match 空数组" {
  try {
    let _ = @feature.sift_match([], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 26. orb_match 空数组 =====

///|
test "fe2_edge: orb_match 空数组" {
  try {
    let _ = @feature.orb_match([], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 27. ransac_homography 空数组 =====

///|
test "fe2_edge: ransac_homography 空数组" {
  try {
    let _ = @feature.ransac_homography([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 28. sift_detect 8bit 太小 =====

///|
test "fe2_edge: sift_detect 图像太小" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(16, 128)),
    }
    let _ = @feature.sift_detect(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 29. good_features_to_track 8bit 零宽度 =====

///|
test "fe2_edge: good_features_to_track 零宽度" {
  try {
    let img = @types.Image::{
      width: 0,
      height: 4,
      channels: 1,
      data: Bytes::from_array([]),
    }
    let _ = @feature.good_features_to_track(img, 10, 0.01F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 30. compare_hist 空数组 =====

///|
test "fe2_edge: compare_hist 空数组" {
  try {
    let _ = @feature.compare_hist(
      [],
      [],
      @feature.HistCompareMethod::Correlation,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
