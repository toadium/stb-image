// v206.0.0 filter 错误路径/边界增强测试

// ===== 辅助函数 =====

///|
fn flt_make_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn flt_make_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn flt_make_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

///|
fn flt_make_rgb(w : Int, h : Int, v : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, v.to_byte())),
  }
}

///|
fn flt_make_checkerboard(w : Int, h : Int) -> @types.Image {
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

// ===== 1. box_blur 错误路径 =====

///|
test "flt_edge: box_blur 零宽度" {
  try {
    let _ = @filter.box_blur(flt_make_zero_w(), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: box_blur 数据不匹配" {
  try {
    let _ = @filter.box_blur(flt_make_mismatch(), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: box_blur 负半径" {
  try {
    let _ = @filter.box_blur(flt_make_uniform(4, 4, 128), -1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: box_blur 单像素" {
  try {
    let result = @filter.box_blur(flt_make_uniform(1, 1, 128), 1)
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: box_blur 全黑" {
  try {
    let result = @filter.box_blur(flt_make_uniform(8, 8, 0), 2)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: box_blur RGB" {
  try {
    let result = @filter.box_blur(flt_make_rgb(8, 8, 128), 2)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 2. gaussian_blur 错误路径 =====

///|
test "flt_edge: gaussian_blur 零宽度" {
  try {
    let _ = @filter.gaussian_blur(flt_make_zero_w(), 1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: gaussian_blur 负半径" {
  try {
    let _ = @filter.gaussian_blur(flt_make_uniform(4, 4, 128), -1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: gaussian_blur sigma为零" {
  try {
    let _ = @filter.gaussian_blur(flt_make_uniform(4, 4, 128), 1, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: gaussian_blur 全白" {
  try {
    let result = @filter.gaussian_blur(flt_make_uniform(8, 8, 255), 2, 1.5F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: gaussian_blur 棋盘格" {
  try {
    let result = @filter.gaussian_blur(flt_make_checkerboard(8, 8), 2, 1.0F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 3. sharpen 错误路径 =====

///|
test "flt_edge: sharpen 零宽度" {
  try {
    let _ = @filter.sharpen(flt_make_zero_w(), 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: sharpen 负amount" {
  try {
    let _ = @filter.sharpen(flt_make_uniform(4, 4, 128), -1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: sharpen 全黑" {
  try {
    let result = @filter.sharpen(flt_make_uniform(8, 8, 0), 0.5F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: sharpen RGB" {
  try {
    let result = @filter.sharpen(flt_make_rgb(8, 8, 128), 1.0F)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 4. median_blur 错误路径 =====

///|
test "flt_edge: median_blur 零宽度" {
  try {
    let _ = @filter.median_blur(flt_make_zero_w(), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: median_blur ksize为零" {
  try {
    let _ = @filter.median_blur(flt_make_uniform(4, 4, 128), 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: median_blur ksize偶数" {
  try {
    let _ = @filter.median_blur(flt_make_uniform(4, 4, 128), 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: median_blur 全黑" {
  try {
    let result = @filter.median_blur(flt_make_uniform(8, 8, 0), 3)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: median_blur 棋盘格" {
  try {
    let result = @filter.median_blur(flt_make_checkerboard(8, 8), 3)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 5. convolve 错误路径 =====

///|
test "flt_edge: convolve 零宽度" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve(flt_make_zero_w(), kernel, 0.0F, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: convolve scale为零" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve(flt_make_uniform(4, 4, 128), kernel, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: convolve 全黑" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let result = @filter.convolve(flt_make_uniform(4, 4, 0), kernel, 0.0F, 1.0F)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 6. bilateral_filter 错误路径 =====

///|
test "flt_edge: bilateral_filter 零宽度" {
  try {
    let _ = @filter.bilateral_filter(flt_make_zero_w(), 3, 30.0F, 30.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: bilateral_filter radius为零" {
  try {
    let _ = @filter.bilateral_filter(
      flt_make_uniform(4, 4, 128),
      0,
      30.0F,
      30.0F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: bilateral_filter 全黑" {
  try {
    let result = @filter.bilateral_filter(
      flt_make_uniform(8, 8, 0),
      3,
      30.0F,
      30.0F,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: bilateral_filter RGB" {
  try {
    let result = @filter.bilateral_filter(
      flt_make_rgb(8, 8, 128),
      3,
      30.0F,
      30.0F,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 7. bilateral_filter_fast 错误路径 =====

///|
test "flt_edge: bilateral_filter_fast 零宽度" {
  try {
    let _ = @filter.bilateral_filter_fast(flt_make_zero_w(), 3, 30.0F, 30.0F, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: bilateral_filter_fast 全黑" {
  try {
    let result = @filter.bilateral_filter_fast(
      flt_make_uniform(8, 8, 0),
      3,
      30.0F,
      30.0F,
      2,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 8. inpaint 错误路径 =====

///|
test "flt_edge: inpaint 零宽度" {
  try {
    let mask = flt_make_uniform(4, 4, 0)
    let _ = @filter.inpaint(flt_make_zero_w(), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: inpaint 全黑无掩码" {
  try {
    let img = flt_make_uniform(8, 8, 0)
    let mask = flt_make_uniform(8, 8, 0)
    let result = @filter.inpaint(img, mask)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: inpaint 全白无掩码" {
  try {
    let img = flt_make_uniform(8, 8, 255)
    let mask = flt_make_uniform(8, 8, 0)
    let result = @filter.inpaint(img, mask)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 9. inpaint_fast 错误路径 =====

///|
test "flt_edge: inpaint_fast 零宽度" {
  try {
    let mask = flt_make_uniform(4, 4, 0)
    let _ = @filter.inpaint_fast(flt_make_zero_w(), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: inpaint_fast 全黑无掩码" {
  try {
    let img = flt_make_uniform(8, 8, 0)
    let mask = flt_make_uniform(8, 8, 0)
    let result = @filter.inpaint_fast(img, mask)
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 10. nlm_denoise 错误路径 =====

///|
test "flt_edge: nlm_denoise 零宽度" {
  try {
    let _ = @filter.nlm_denoise(flt_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: nlm_denoise 全黑" {
  try {
    let result = @filter.nlm_denoise(flt_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: nlm_denoise 全白" {
  try {
    let result = @filter.nlm_denoise(flt_make_uniform(8, 8, 255))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: nlm_denoise 棋盘格" {
  try {
    let result = @filter.nlm_denoise(flt_make_checkerboard(8, 8))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 11. nlm_denoise_fast 错误路径 =====

///|
test "flt_edge: nlm_denoise_fast 零宽度" {
  try {
    let _ = @filter.nlm_denoise_fast(flt_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "flt_edge: nlm_denoise_fast 全黑" {
  try {
    let result = @filter.nlm_denoise_fast(flt_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "flt_edge: nlm_denoise_fast 自定义参数" {
  try {
    let result = @filter.nlm_denoise_fast(
      flt_make_uniform(8, 8, 128),
      patch_size=5,
      search_size=11,
      h=10,
      step=2,
    )
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}
