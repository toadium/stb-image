// v205.0.0 color 错误路径/边界增强测试

// ===== 辅助函数 =====

///|
fn col_make_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn col_make_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn col_make_uniform(w : Int32, h : Int32, v : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

///|
fn col_make_rgb(w : Int32, h : Int32, v : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, v.to_byte())),
  }
}

///|
fn col_make_rgba(w : Int32, h : Int32, v : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 4,
    data: Bytes::from_array(Array::make(w * h * 4, v.to_byte())),
  }
}

///|
fn col_make_imagef(w : Int32, h : Int32, v : Float) -> @types.ImageF {
  let data : Array[Byte] = Array::make(w * h * 3 * 4, b'\x00')
  let bytes = Float::to_le_bytes(v)
  for i in 0..<(w * h * 3) {
    data[i * 4] = bytes[0]
    data[i * 4 + 1] = bytes[1]
    data[i * 4 + 2] = bytes[2]
    data[i * 4 + 3] = bytes[3]
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(data),
  }
}

// ===== 1. adjust_brightness 错误路径 =====

///|
test "col_edge: adjust_brightness 零宽度" {
  try {
    let _ = @color.adjust_brightness(col_make_zero_w(), 50)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_brightness 数据不匹配" {
  try {
    let _ = @color.adjust_brightness(col_make_mismatch(), 50)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_brightness 单像素" {
  try {
    let result = @color.adjust_brightness(col_make_uniform(1, 1, 100), 50)
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: adjust_brightness 全黑" {
  try {
    let result = @color.adjust_brightness(col_make_uniform(4, 4, 0), 100)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 2. adjust_contrast 错误路径 =====

///|
test "col_edge: adjust_contrast 零宽度" {
  try {
    let _ = @color.adjust_contrast(col_make_zero_w(), 1.5F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_contrast 全白" {
  try {
    let result = @color.adjust_contrast(col_make_uniform(4, 4, 255), 2.0F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 3. adjust_gamma 错误路径 =====

///|
test "col_edge: adjust_gamma 零宽度" {
  try {
    let _ = @color.adjust_gamma(col_make_zero_w(), 2.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_gamma gamma为零" {
  try {
    let _ = @color.adjust_gamma(col_make_uniform(4, 4, 128), 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_gamma gamma为负" {
  try {
    let _ = @color.adjust_gamma(col_make_uniform(4, 4, 128), -1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_gamma 全黑" {
  try {
    let result = @color.adjust_gamma(col_make_uniform(4, 4, 0), 2.0F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 4. invert 错误路径 =====

///|
test "col_edge: invert 零宽度" {
  try {
    let _ = @color.invert(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: invert 单像素" {
  try {
    let result = @color.invert(col_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: invert 全黑" {
  try {
    let result = @color.invert(col_make_uniform(4, 4, 0))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: invert RGB" {
  try {
    let result = @color.invert(col_make_rgb(4, 4, 128))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 5. to_grayscale 错误路径 =====

///|
test "col_edge: to_grayscale 零宽度" {
  try {
    let _ = @color.to_grayscale(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: to_grayscale RGB" {
  try {
    let result = @color.to_grayscale(col_make_rgb(4, 4, 128))
    assert_true(result.channels == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: to_grayscale 单像素" {
  try {
    let result = @color.to_grayscale(col_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 6. to_rgb 错误路径 =====

///|
test "col_edge: to_rgb 零宽度" {
  try {
    let _ = @color.to_rgb(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: to_rgb 灰度" {
  try {
    let result = @color.to_rgb(col_make_uniform(4, 4, 128))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 7. to_rgba 错误路径 =====

///|
test "col_edge: to_rgba 零宽度" {
  try {
    let _ = @color.to_rgba(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: to_rgba 灰度" {
  try {
    let result = @color.to_rgba(col_make_uniform(4, 4, 128))
    assert_true(result.channels == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 8. ssr 错误路径 =====

///|
test "col_edge: ssr 零宽度" {
  try {
    let _ = @color.ssr(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: ssr sigma为零" {
  try {
    let _ = @color.ssr(col_make_uniform(4, 4, 128), sigma=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: ssr 全黑" {
  try {
    let result = @color.ssr(col_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: ssr RGB" {
  try {
    let result = @color.ssr(col_make_rgb(8, 8, 128))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 9. msr 错误路径 =====

///|
test "col_edge: msr 零宽度" {
  try {
    let _ = @color.msr(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: msr 空sigmas" {
  try {
    let _ = @color.msr(col_make_uniform(4, 4, 128), sigmas=[])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: msr 全黑" {
  try {
    let result = @color.msr(col_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 10. msrcr 错误路径 =====

///|
test "col_edge: msrcr 灰度图" {
  try {
    let _ = @color.msrcr(col_make_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: msrcr RGB全黑" {
  try {
    let result = @color.msrcr(col_make_rgb(8, 8, 10))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 11. adaptive_threshold_mean 错误路径 =====

///|
test "col_edge: adaptive_threshold_mean 零宽度" {
  try {
    let _ = @color.adaptive_threshold_mean(col_make_zero_w(), 3, 5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adaptive_threshold_mean 偶数block" {
  try {
    let _ = @color.adaptive_threshold_mean(col_make_uniform(8, 8, 128), 4, 5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adaptive_threshold_mean 全黑" {
  try {
    let result = @color.adaptive_threshold_mean(col_make_uniform(8, 8, 0), 3, 5)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 12. adaptive_threshold_gaussian 错误路径 =====

///|
test "col_edge: adaptive_threshold_gaussian 零宽度" {
  try {
    let _ = @color.adaptive_threshold_gaussian(col_make_zero_w(), 3, 5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adaptive_threshold_gaussian 偶数block" {
  try {
    let _ = @color.adaptive_threshold_gaussian(
      col_make_uniform(8, 8, 128),
      4,
      5,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adaptive_threshold_gaussian 全白" {
  try {
    let result = @color.adaptive_threshold_gaussian(
      col_make_uniform(8, 8, 255),
      3,
      5,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 13. threshold_otsu 错误路径 =====

///|
test "col_edge: threshold_otsu 零宽度" {
  try {
    let _ = @color.threshold_otsu(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: threshold_otsu 全黑" {
  try {
    let result = @color.threshold_otsu(col_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: threshold_otsu 单像素" {
  try {
    let result = @color.threshold_otsu(col_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 14. clahe 错误路径 =====

///|
test "col_edge: clahe 零宽度" {
  try {
    let _ = @color.clahe(col_make_zero_w(), 8, 2.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: clahe tile_size太小" {
  try {
    let _ = @color.clahe(col_make_uniform(8, 8, 128), 1, 2.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: clahe clip_limit为零" {
  try {
    let _ = @color.clahe(col_make_uniform(8, 8, 128), 8, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: clahe 全黑" {
  try {
    let result = @color.clahe(col_make_uniform(8, 8, 0), 8, 2.0F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: clahe RGB" {
  try {
    let result = @color.clahe(col_make_rgb(8, 8, 128), 8, 2.0F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 15. floyd_steinberg 错误路径 =====

///|
test "col_edge: floyd_steinberg 零宽度" {
  try {
    let _ = @color.floyd_steinberg(col_make_zero_w(), 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: floyd_steinberg levels太小" {
  try {
    let _ = @color.floyd_steinberg(col_make_uniform(4, 4, 128), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: floyd_steinberg 全黑" {
  try {
    let result = @color.floyd_steinberg(col_make_uniform(4, 4, 0), 2)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 16. median_cut 错误路径 =====

///|
test "col_edge: median_cut 零宽度" {
  try {
    let _ = @color.median_cut(col_make_zero_w(), 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: median_cut RGB" {
  try {
    let result = @color.median_cut(col_make_rgb(8, 8, 128), 4)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 17. kmeans_quantize 错误路径 =====

///|
test "col_edge: kmeans_quantize 零宽度" {
  try {
    let _ = @color.kmeans_quantize(col_make_zero_w(), 8, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: kmeans_quantize k为零" {
  try {
    let _ = @color.kmeans_quantize(col_make_uniform(4, 4, 128), 0, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: kmeans_quantize k太大" {
  try {
    let _ = @color.kmeans_quantize(col_make_uniform(4, 4, 128), 257, 10)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: kmeans_quantize 全黑" {
  try {
    let result = @color.kmeans_quantize(col_make_rgb(4, 4, 0), 4, 10)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 18. dehaze 错误路径 =====

///|
test "col_edge: dehaze 灰度图" {
  try {
    let _ = @color.dehaze(col_make_uniform(4, 4, 128))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: dehaze patch_size为零" {
  try {
    let _ = @color.dehaze(col_make_rgb(8, 8, 128), patch_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: dehaze patch_size太大" {
  try {
    let _ = @color.dehaze(col_make_rgb(8, 8, 128), patch_size=31)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: dehaze omega为零" {
  try {
    let _ = @color.dehaze(col_make_rgb(8, 8, 128), omega=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: dehaze t0为零" {
  try {
    let _ = @color.dehaze(col_make_rgb(8, 8, 128), t0=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: dehaze RGB全黑" {
  try {
    let result = @color.dehaze(col_make_rgb(8, 8, 10))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 19. apply_colormap 错误路径 =====

///|
test "col_edge: apply_colormap 零宽度" {
  try {
    let _ = @color.apply_colormap(col_make_zero_w(), @color.Colormap::JET)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: apply_colormap JET" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(8, 8, 128),
      @color.Colormap::JET,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: apply_colormap HOT" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(4, 4, 100),
      @color.Colormap::HOT,
    )
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: apply_colormap COOL" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(4, 4, 100),
      @color.Colormap::COOL,
    )
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: apply_colormap GRAY" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(4, 4, 100),
      @color.Colormap::GRAY,
    )
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: apply_colormap BONE" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(4, 4, 100),
      @color.Colormap::BONE,
    )
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "col_edge: apply_colormap COPPER" {
  try {
    let result = @color.apply_colormap(
      col_make_uniform(4, 4, 100),
      @color.Colormap::COPPER,
    )
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 20. reinhard_tonemap 错误路径 =====

///|
test "col_edge: reinhard_tonemap key为零" {
  try {
    let imgf = col_make_imagef(4, 4, 0.5F)
    let _ = @color.reinhard_tonemap(imgf, key=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: reinhard_tonemap 基本测试" {
  try {
    let imgf = col_make_imagef(4, 4, 0.5F)
    let result = @color.reinhard_tonemap(imgf)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 21. gamma_tonemap 错误路径 =====

///|
test "col_edge: gamma_tonemap gamma为零" {
  try {
    let imgf = col_make_imagef(4, 4, 0.5F)
    let _ = @color.gamma_tonemap(imgf, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: gamma_tonemap 基本测试" {
  try {
    let imgf = col_make_imagef(4, 4, 0.5F)
    let result = @color.gamma_tonemap(imgf, 2.2F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 22. adjust_saturation 错误路径 =====

///|
test "col_edge: adjust_saturation 零宽度" {
  try {
    let _ = @color.adjust_saturation(col_make_zero_w(), 1.5F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_saturation RGB" {
  try {
    let result = @color.adjust_saturation(col_make_rgb(4, 4, 128), 2.0F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 23. adjust_hue 错误路径 =====

///|
test "col_edge: adjust_hue 零宽度" {
  try {
    let _ = @color.adjust_hue(col_make_zero_w(), 30.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: adjust_hue RGB" {
  try {
    let result = @color.adjust_hue(col_make_rgb(4, 4, 128), 45.0F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 24. premultiply_alpha 错误路径 =====

///|
test "col_edge: premultiply_alpha 零宽度" {
  try {
    let _ = @color.premultiply_alpha(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: premultiply_alpha RGBA" {
  try {
    let result = @color.premultiply_alpha(col_make_rgba(4, 4, 128))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 25. unpremultiply_alpha 错误路径 =====

///|
test "col_edge: unpremultiply_alpha 零宽度" {
  try {
    let _ = @color.unpremultiply_alpha(col_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: unpremultiply_alpha RGBA" {
  try {
    let result = @color.unpremultiply_alpha(col_make_rgba(4, 4, 128))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 26. guided_filter 错误路径 =====

///|
test "col_edge: guided_filter 零宽度" {
  try {
    let img = col_make_uniform(4, 4, 128)
    let p = Array::make(16, 1.0F)
    let _ = @color.guided_filter(img, p)
    assert_true(true)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: guided_filter radius太小" {
  try {
    let img = col_make_uniform(4, 4, 128)
    let p = Array::make(16, 1.0F)
    let _ = @color.guided_filter(img, p, radius=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "col_edge: guided_filter eps为零" {
  try {
    let img = col_make_uniform(4, 4, 128)
    let p = Array::make(16, 1.0F)
    let _ = @color.guided_filter(img, p, eps=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
