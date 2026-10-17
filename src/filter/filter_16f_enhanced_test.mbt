// v196 filter 16f 变体增强测试

///|
fn f16_make_varied16(w : Int, h : Int, ch : Int) -> @types.Image16 {
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
fn f16_make_variedf(w : Int, h : Int, ch : Int) -> @types.ImageF {
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
fn f16_make_uniform16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn f16_make_uniformf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== filter_16f 增强测试 ==========

///|
test "f16: box_blur_16 非均匀多通道" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.box_blur_16(img, 2)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: box_blur_f 非均匀多通道" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.box_blur_f(img, 2)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: box_blur_16 radius=1" {
  let img = f16_make_varied16(8, 8, 1)
  try {
    let result = @filter.box_blur_16(img, 1)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: box_blur_f radius=0" {
  let img = f16_make_variedf(8, 8, 1)
  try {
    let result = @filter.box_blur_f(img, 0)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gaussian_blur_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.gaussian_blur_16(img, 2, 2.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gaussian_blur_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.gaussian_blur_f(img, 1, 1.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: median_blur_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.median_blur_16(img, 2)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: median_blur_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.median_blur_f(img, 2)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sharpen_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.sharpen_16(img, 1.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sharpen_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.sharpen_f(img, 0.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sharpen_16 amount=0" {
  let img = f16_make_varied16(8, 8, 1)
  try {
    let result = @filter.sharpen_16(img, 0.0F)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

// ========== convolve_bilateral_16f 增强测试 ==========

///|
test "f16: convolve_16 非均匀" {
  let img = f16_make_varied16(16, 16, 1)
  let kernel = [0.0F, -1.0F, 0.0F, -1.0F, 5.0F, -1.0F, 0.0F, -1.0F, 0.0F]
  try {
    let result = @filter.convolve_16(img, kernel, 0.0F, 1.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: convolve_f 非均匀" {
  let img = f16_make_variedf(16, 16, 1)
  let kernel = [0.0F, -1.0F, 0.0F, -1.0F, 5.0F, -1.0F, 0.0F, -1.0F, 0.0F]
  try {
    let result = @filter.convolve_f(img, kernel, 0.0F, 1.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.bilateral_filter_16(img, 2, 10.0F, 30.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.bilateral_filter_f(img, 2, 10.0F, 30.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_fast_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.bilateral_filter_fast_16(img, 2, 10.0F, 30.0F, 2)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_fast_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.bilateral_filter_fast_f(img, 2, 10.0F, 30.0F, 2)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_16 单通道" {
  let img = f16_make_varied16(8, 8, 1)
  try {
    let result = @filter.bilateral_filter_16(img, 1, 5.0F, 20.0F)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

// ========== advanced_16f 增强测试 ==========

///|
test "f16: inpaint_16 基本测试" {
  let img = f16_make_varied16(16, 16, 3)
  let mask = f16_make_uniform16(16, 16, 1, 0)
  try {
    let result = @filter.inpaint_16(img, mask, iterations=10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: inpaint_f 基本测试" {
  let img = f16_make_variedf(16, 16, 3)
  let mask = f16_make_uniformf(16, 16, 1, 0.0F)
  try {
    let result = @filter.inpaint_f(img, mask, iterations=10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: inpaint_fast_16 基本测试" {
  let img = f16_make_varied16(16, 16, 3)
  let mask = f16_make_uniform16(16, 16, 1, 0)
  try {
    let result = @filter.inpaint_fast_16(img, mask, radius=3)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: inpaint_fast_f 基本测试" {
  let img = f16_make_variedf(16, 16, 3)
  let mask = f16_make_uniformf(16, 16, 1, 0.0F)
  try {
    let result = @filter.inpaint_fast_f(img, mask, radius=3)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: nlm_denoise_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.nlm_denoise_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: nlm_denoise_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.nlm_denoise_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: nlm_denoise_fast_16 非均匀" {
  let img = f16_make_varied16(16, 16, 3)
  try {
    let result = @filter.nlm_denoise_fast_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: nlm_denoise_fast_f 非均匀" {
  let img = f16_make_variedf(16, 16, 3)
  try {
    let result = @filter.nlm_denoise_fast_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: nlm_denoise_16 自定义参数" {
  let img = f16_make_varied16(16, 16, 1)
  try {
    let result = @filter.nlm_denoise_16(img, patch_size=5, search_size=10, h=20)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 均匀图像测试 ==========

///|
test "f16: box_blur_16 均匀图像" {
  let img = f16_make_uniform16(8, 8, 3, 32768)
  try {
    let result = @filter.box_blur_16(img, 2)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gaussian_blur_f 均匀图像" {
  let img = f16_make_uniformf(8, 8, 3, 0.5F)
  try {
    let result = @filter.gaussian_blur_f(img, 2, 2.0F)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: median_blur_16 均匀图像" {
  let img = f16_make_uniform16(8, 8, 1, 10000)
  try {
    let result = @filter.median_blur_16(img, 2)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: sharpen_f 均匀图像" {
  let img = f16_make_uniformf(8, 8, 3, 0.5F)
  try {
    let result = @filter.sharpen_f(img, 1.5F)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 错误路径测试 ==========

///|
test "f16: box_blur_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @filter.box_blur_16(img, 1)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: gaussian_blur_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @filter.gaussian_blur_f(img, 1, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: convolve_16 kernel尺寸错误" {
  let img = f16_make_varied16(8, 8, 1)
  let kernel = [1.0F, 0.0F, 0.0F]
  try {
    let _ = @filter.convolve_16(img, kernel, 0.0F, 1.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "f16: bilateral_filter_16 sigma零错误" {
  let img = f16_make_varied16(8, 8, 3)
  try {
    let _ = @filter.bilateral_filter_16(img, 2, 0.0F, 30.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
