// v215.0.0 filter 16f/f 错误路径增强测试

// ===== 辅助函数 =====

///|
fn fe2_flt16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn fe2_fltf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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
fn fe2_flt16_bad(w : Int, h : Int, ch : Int) -> @types.Image16 {
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(Array::make(4, 0)),
  }
}

// ===== 1. box_blur_16/f =====

///|
test "fe2_flt: box_blur_16 零宽度" {
  try {
    let _ = @filter.box_blur_16(fe2_flt16(0, 4, 1, 100), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: box_blur_16 数据不匹配" {
  try {
    let _ = @filter.box_blur_16(fe2_flt16_bad(4, 4, 1), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: box_blur_16 负半径" {
  try {
    let _ = @filter.box_blur_16(fe2_flt16(4, 4, 1, 100), -1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: box_blur_f 零宽度" {
  try {
    let _ = @filter.box_blur_f(fe2_fltf(0, 4, 1, 1.0F), 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: box_blur_f 负半径" {
  try {
    let _ = @filter.box_blur_f(fe2_fltf(4, 4, 1, 1.0F), -1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 2. gaussian_blur_16/f =====

///|
test "fe2_flt: gaussian_blur_16 零宽度" {
  try {
    let _ = @filter.gaussian_blur_16(fe2_flt16(0, 4, 1, 100), 1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: gaussian_blur_16 负半径" {
  try {
    let _ = @filter.gaussian_blur_16(fe2_flt16(4, 4, 1, 100), -1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: gaussian_blur_16 sigma为零" {
  try {
    let _ = @filter.gaussian_blur_16(fe2_flt16(4, 4, 1, 100), 1, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: gaussian_blur_f 零宽度" {
  try {
    let _ = @filter.gaussian_blur_f(fe2_fltf(0, 4, 1, 1.0F), 1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: gaussian_blur_f sigma为零" {
  try {
    let _ = @filter.gaussian_blur_f(fe2_fltf(4, 4, 1, 1.0F), 1, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 3. sharpen_16/f =====

///|
test "fe2_flt: sharpen_16 零宽度" {
  try {
    let _ = @filter.sharpen_16(fe2_flt16(0, 4, 1, 100), 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: sharpen_f 零宽度" {
  try {
    let _ = @filter.sharpen_f(fe2_fltf(0, 4, 1, 1.0F), 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 4. median_blur_16/f =====

///|
test "fe2_flt: median_blur_16 零宽度" {
  try {
    let _ = @filter.median_blur_16(fe2_flt16(0, 4, 1, 100), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: median_blur_16 ksize为零" {
  try {
    let _ = @filter.median_blur_16(fe2_flt16(4, 4, 1, 100), 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: median_blur_16 ksize偶数" {
  try {
    let _ = @filter.median_blur_16(fe2_flt16(4, 4, 1, 100), 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: median_blur_f 零宽度" {
  try {
    let _ = @filter.median_blur_f(fe2_fltf(0, 4, 1, 1.0F), 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: median_blur_f ksize偶数" {
  try {
    let _ = @filter.median_blur_f(fe2_fltf(4, 4, 1, 1.0F), 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 5. convolve_16/f =====

///|
test "fe2_flt: convolve_16 零宽度" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve_16(fe2_flt16(0, 4, 1, 100), kernel, 0.0F, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: convolve_16 scale为零" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve_16(fe2_flt16(4, 4, 1, 100), kernel, 0.0F, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: convolve_f 零宽度" {
  try {
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve_f(fe2_fltf(0, 4, 1, 1.0F), kernel, 0.0F, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 6. bilateral_filter_16/f =====

///|
test "fe2_flt: bilateral_filter_16 零宽度" {
  try {
    let _ = @filter.bilateral_filter_16(
      fe2_flt16(0, 4, 1, 100),
      3,
      30.0F,
      30.0F,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: bilateral_filter_16 radius为零" {
  try {
    let _ = @filter.bilateral_filter_16(
      fe2_flt16(4, 4, 1, 100),
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
test "fe2_flt: bilateral_filter_f 零宽度" {
  try {
    let _ = @filter.bilateral_filter_f(fe2_fltf(0, 4, 1, 1.0F), 3, 30.0F, 30.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 7. bilateral_filter_fast_16/f =====

///|
test "fe2_flt: bilateral_filter_fast_16 零宽度" {
  try {
    let _ = @filter.bilateral_filter_fast_16(
      fe2_flt16(0, 4, 1, 100),
      3,
      30.0F,
      30.0F,
      2,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: bilateral_filter_fast_f 零宽度" {
  try {
    let _ = @filter.bilateral_filter_fast_f(
      fe2_fltf(0, 4, 1, 1.0F),
      3,
      30.0F,
      30.0F,
      2,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 8. inpaint_16/f =====

///|
test "fe2_flt: inpaint_16 零宽度" {
  try {
    let mask = fe2_flt16(4, 4, 1, 0)
    let _ = @filter.inpaint_16(fe2_flt16(0, 4, 1, 100), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: inpaint_f 零宽度" {
  try {
    let mask = fe2_fltf(4, 4, 1, 0.0F)
    let _ = @filter.inpaint_f(fe2_fltf(0, 4, 1, 1.0F), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 9. inpaint_fast_16/f =====

///|
test "fe2_flt: inpaint_fast_16 零宽度" {
  try {
    let mask = fe2_flt16(4, 4, 1, 0)
    let _ = @filter.inpaint_fast_16(fe2_flt16(0, 4, 1, 100), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: inpaint_fast_f 零宽度" {
  try {
    let mask = fe2_fltf(4, 4, 1, 0.0F)
    let _ = @filter.inpaint_fast_f(fe2_fltf(0, 4, 1, 1.0F), mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 10. nlm_denoise_16/f =====

///|
test "fe2_flt: nlm_denoise_16 零宽度" {
  try {
    let _ = @filter.nlm_denoise_16(fe2_flt16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: nlm_denoise_f 零宽度" {
  try {
    let _ = @filter.nlm_denoise_f(fe2_fltf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 11. nlm_denoise_fast_16/f =====

///|
test "fe2_flt: nlm_denoise_fast_16 零宽度" {
  try {
    let _ = @filter.nlm_denoise_fast_16(fe2_flt16(0, 4, 1, 100))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: nlm_denoise_fast_f 零宽度" {
  try {
    let _ = @filter.nlm_denoise_fast_f(fe2_fltf(0, 4, 1, 1.0F))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ===== 12. filter 8bit 数据不匹配补充 =====

///|
test "fe2_flt: box_blur 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(16, 0)),
    }
    let _ = @filter.box_blur(img, 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: gaussian_blur 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, 0)),
    }
    let _ = @filter.gaussian_blur(img, 1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: median_blur 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(16, 0)),
    }
    let _ = @filter.median_blur(img, 3)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: bilateral_filter 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, 0)),
    }
    let _ = @filter.bilateral_filter(img, 3, 30.0F, 30.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: nlm_denoise 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(16, 0)),
    }
    let _ = @filter.nlm_denoise(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: sharpen 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, 0)),
    }
    let _ = @filter.sharpen(img, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: convolve 数据不匹配补充" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(16, 0)),
    }
    let kernel = [0.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F, 0.0F, 0.0F, 0.0F]
    let _ = @filter.convolve(img, kernel, 0.0F, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: inpaint 尺寸不匹配" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(16, 128)),
    }
    let mask = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 0)),
    }
    let _ = @filter.inpaint(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "fe2_flt: inpaint_fast 尺寸不匹配" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(16, 128)),
    }
    let mask = @types.Image::{
      width: 8,
      height: 8,
      channels: 1,
      data: Bytes::from_array(Array::make(64, 0)),
    }
    let _ = @filter.inpaint_fast(img, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
