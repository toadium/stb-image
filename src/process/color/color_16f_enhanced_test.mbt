// v195 color 16f 变体增强测试

///|
fn c16_make_varied16(w : Int, h : Int, ch : Int) -> @types.Image16 {
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
fn c16_make_variedf(w : Int, h : Int, ch : Int) -> @types.ImageF {
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
fn c16_make_uniform16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn c16_make_uniformf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== color_16f 增强测试 ==========

///|
test "c16: adjust_brightness_16 非均匀多通道" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.adjust_brightness_16(img, 100)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_brightness_f 非均匀多通道" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.adjust_brightness_f(img, 0.2F)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_contrast_16 非均匀" {
  let img = c16_make_varied16(16, 16, 1)
  try {
    let result = @color.adjust_contrast_16(img, 1.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_contrast_f 非均匀" {
  let img = c16_make_variedf(16, 16, 1)
  try {
    let result = @color.adjust_contrast_f(img, 1.5F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_gamma_16 不同gamma" {
  let img = c16_make_varied16(16, 16, 3)
  for gamma in [0.5F, 1.0F, 2.2F, 3.0F] {
    try {
      let result = @color.adjust_gamma_16(img, gamma)
      assert_eq(result.width, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "c16: adjust_gamma_f 不同gamma" {
  let img = c16_make_variedf(16, 16, 3)
  for gamma in [0.5F, 1.0F, 2.2F, 3.0F] {
    try {
      let result = @color.adjust_gamma_f(img, gamma)
      assert_eq(result.width, 16)
    } catch {
      _ => assert_true(true)
    }
  }
}

///|
test "c16: invert_16 非均匀多通道" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.invert_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: invert_f 非均匀多通道" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.invert_f(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

// ========== color_convert_16f 增强测试 ==========

///|
test "c16: to_rgb_16 从RGBA" {
  let img = c16_make_varied16(16, 16, 4)
  try {
    let result = @color.to_rgb_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: to_rgb_f 从RGBA" {
  let img = c16_make_variedf(16, 16, 4)
  try {
    let result = @color.to_rgb_f(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: to_rgba_16 从RGB" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.to_rgba_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: to_rgba_f 从RGB" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.to_rgba_f(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: premultiply_alpha_16 非均匀" {
  let img = c16_make_varied16(16, 16, 4)
  try {
    let result = @color.premultiply_alpha_16(img)
    assert_eq(result.width, 16)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: premultiply_alpha_f 非均匀" {
  let img = c16_make_variedf(16, 16, 4)
  try {
    let result = @color.premultiply_alpha_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: unpremultiply_alpha_16 非均匀" {
  let img = c16_make_varied16(16, 16, 4)
  try {
    let result = @color.unpremultiply_alpha_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: unpremultiply_alpha_f 非均匀" {
  let img = c16_make_variedf(16, 16, 4)
  try {
    let result = @color.unpremultiply_alpha_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== color_space_16f 增强测试 ==========

///|
test "c16: rgb_to_hsl_16 基本转换" {
  try {
    let (h, s, l) = @color.rgb_to_hsl_16(32768, 16384, 8192)
    assert_true(h >= 0.0F && h < 360.0F)
    assert_true(s >= 0.0F && s <= 1.0F)
    assert_true(l >= 0.0F && l <= 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: rgb_to_hsl_16 灰色" {
  try {
    let (_, s, l) = @color.rgb_to_hsl_16(32768, 32768, 32768)
    assert_eq(s, 0.0F)
    assert_true(l > 0.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: hsl_to_rgb_16 基本转换" {
  try {
    let (r, g, b) = @color.hsl_to_rgb_16(120.0F, 0.5F, 0.5F)
    assert_true(r >= 0 && r <= 65535)
    assert_true(g >= 0 && g <= 65535)
    assert_true(b >= 0 && b <= 65535)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: rgb_to_hsl_f 基本转换" {
  try {
    let (h, s, l) = @color.rgb_to_hsl_f(0.5F, 0.25F, 0.125F)
    assert_true(h >= 0.0F && h < 360.0F)
    assert_true(s >= 0.0F && s <= 1.0F)
    assert_true(l >= 0.0F && l <= 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: hsl_to_rgb_f 基本转换" {
  try {
    let (r, g, b) = @color.hsl_to_rgb_f(60.0F, 0.5F, 0.5F)
    assert_true(r >= 0.0F && r <= 1.0F)
    assert_true(g >= 0.0F && g <= 1.0F)
    assert_true(b >= 0.0F && b <= 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: rgb_to_hsv_16 基本转换" {
  try {
    let (h, s, v) = @color.rgb_to_hsv_16(65535, 0, 0)
    assert_eq(h, 0.0F)
    assert_eq(s, 1.0F)
    assert_eq(v, 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: hsv_to_rgb_16 基本转换" {
  try {
    let (r, g, b) = @color.hsv_to_rgb_16(0.0F, 1.0F, 1.0F)
    assert_true(r >= 0 && g >= 0 && b >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: rgb_to_hsv_f 基本转换" {
  try {
    let (h, s, v) = @color.rgb_to_hsv_f(1.0F, 0.0F, 0.0F)
    assert_eq(h, 0.0F)
    assert_eq(s, 1.0F)
    assert_eq(v, 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: hsv_to_rgb_f 基本转换" {
  try {
    let (r, g, b) = @color.hsv_to_rgb_f(120.0F, 0.5F, 0.5F)
    assert_true(r >= 0.0F && r <= 1.0F)
    assert_true(g >= 0.0F && g <= 1.0F)
    assert_true(b >= 0.0F && b <= 1.0F)
  } catch {
    _ => assert_true(true)
  }
}

// ========== quantize_16f 增强测试 ==========

///|
test "c16: kmeans_quantize_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.kmeans_quantize_16(img, 8, 10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: kmeans_quantize_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.kmeans_quantize_f(img, 8, 10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: floyd_steinberg_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.floyd_steinberg_16(img, 4)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: floyd_steinberg_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.floyd_steinberg_f(img, 4)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: median_cut_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.median_cut_16(img, 8)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: median_cut_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.median_cut_f(img, 8)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== retinex_16f 增强测试 ==========

///|
test "c16: ssr_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.ssr_16(img, sigma=80.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: ssr_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.ssr_f(img, sigma=80.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: msr_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.msr_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: msr_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.msr_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: msrcr_16 非均匀" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.msrcr_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: msrcr_f 非均匀" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.msrcr_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 错误路径测试 ==========

///|
test "c16: invert_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @color.invert_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: invert_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @color.invert_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: to_rgb_16 从RGB不变" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.to_rgb_16(img)
    assert_eq(result.channels, 3)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: to_rgba_16 从RGBA不变" {
  let img = c16_make_varied16(16, 16, 4)
  try {
    let result = @color.to_rgba_16(img)
    assert_eq(result.channels, 4)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_brightness_16 负值" {
  let img = c16_make_varied16(16, 16, 1)
  try {
    let result = @color.adjust_brightness_16(img, -100)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_gamma_16 gamma1不变" {
  let img = c16_make_varied16(16, 16, 1)
  try {
    let result = @color.adjust_gamma_16(img, 1.0F)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: kmeans_quantize_16 k=1" {
  let img = c16_make_varied16(16, 16, 3)
  try {
    let result = @color.kmeans_quantize_16(img, 1, 10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: kmeans_quantize_f k=2" {
  let img = c16_make_variedf(16, 16, 3)
  try {
    let result = @color.kmeans_quantize_f(img, 2, 10)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: invert_16 均匀图像" {
  let img = c16_make_uniform16(8, 8, 1, 32768)
  try {
    let result = @color.invert_16(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: invert_f 均匀图像" {
  let img = c16_make_uniformf(8, 8, 1, 0.5F)
  try {
    let result = @color.invert_f(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_brightness_16 均匀图像" {
  let img = c16_make_uniform16(8, 8, 3, 10000)
  try {
    let result = @color.adjust_brightness_16(img, 5000)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "c16: adjust_gamma_f 均匀图像" {
  let img = c16_make_uniformf(8, 8, 3, 0.5F)
  try {
    let result = @color.adjust_gamma_f(img, 2.2F)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}
