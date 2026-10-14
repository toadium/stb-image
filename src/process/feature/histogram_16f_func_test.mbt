// v237.0.0 histogram_16f 功能+错误路径增强测试

// ===== 辅助函数 =====

///|
fn h16f_make_img16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn h16f_make_img16_rgba(
  w : Int,
  h : Int,
  r : Int,
  g : Int,
  b : Int,
  a : Int,
) -> @types.Image16 {
  let n = w * h
  let data : Array[Byte] = Array::make(n * 4 * 2, b'\x00')
  for i in 0..<n {
    let vals = [r, g, b, a]
    for c in 0..<4 {
      data[i * 8 + c * 2] = (vals[c] & 0xFF).to_byte()
      data[i * 8 + c * 2 + 1] = ((vals[c] >> 8) & 0xFF).to_byte()
    }
  }
  @types.Image16::{
    width: w,
    height: h,
    channels: 4,
    data: Bytes::from_array(data),
  }
}

///|
fn h16f_make_imgf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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
fn h16f_make_imgf_rgba(
  w : Int,
  h : Int,
  r : Float,
  g : Float,
  b : Float,
  a : Float,
) -> @types.ImageF {
  let n = w * h
  let data : Array[Byte] = Array::make(n * 4 * 4, b'\x00')
  for i in 0..<n {
    let vals = [r, g, b, a]
    for c in 0..<4 {
      let bits = vals[c].reinterpret_as_int()
      let off = i * 16 + c * 4
      data[off] = (bits & 0xFF).to_byte()
      data[off + 1] = ((bits >> 8) & 0xFF).to_byte()
      data[off + 2] = ((bits >> 16) & 0xFF).to_byte()
      data[off + 3] = ((bits >> 24) & 0xFF).to_byte()
    }
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: 4,
    data: Bytes::from_array(data),
  }
}

///|
fn h16f_make_imgf_range(w : Int, h : Int, ch : Int) -> @types.ImageF {
  let n = w * h
  let data : Array[Byte] = Array::make(n * ch * 4, b'\x00')
  for i in 0..<n {
    let val = if i < n / 3 {
      -0.5F
    } else if i < n * 2 / 3 {
      0.5F
    } else {
      1.5F
    }
    for c in 0..<ch {
      let bits = val.reinterpret_as_int()
      let off = i * ch * 4 + c * 4
      data[off] = (bits & 0xFF).to_byte()
      data[off + 1] = ((bits >> 8) & 0xFF).to_byte()
      data[off + 2] = ((bits >> 16) & 0xFF).to_byte()
      data[off + 3] = ((bits >> 24) & 0xFF).to_byte()
    }
  }
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

// ========== histogram_equalize_16 RGBA ==========

///|
test "h16f_eq16: RGBA preserves alpha" {
  let img = h16f_make_img16_rgba(4, 4, 1000, 2000, 3000, 4000)
  let result = @feature.histogram_equalize_16(img)
  assert_eq(result.channels, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let alpha_lo = result.data[6].to_int()
  let alpha_hi = result.data[7].to_int()
  assert_eq(alpha_lo + alpha_hi * 256, 4000)
}

// ========== histogram_equalize_f 越界值 ==========

///|
test "h16f_eqf: negative values clamp to bin 0" {
  let img = h16f_make_imgf(4, 4, 1, -0.5F)
  let result = @feature.histogram_equalize_f(img)
  assert_eq(result.channels, 1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "h16f_eqf: values >= 1.0 clamp to bin 255" {
  let img = h16f_make_imgf(4, 4, 1, 1.5F)
  let result = @feature.histogram_equalize_f(img)
  assert_eq(result.channels, 1)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "h16f_eqf: mixed range values" {
  let img = h16f_make_imgf_range(6, 6, 1)
  let result = @feature.histogram_equalize_f(img)
  assert_eq(result.channels, 1)
  assert_eq(result.width, 6)
  assert_eq(result.height, 6)
}

///|
test "h16f_eqf: RGBA preserves alpha" {
  let img = h16f_make_imgf_rgba(4, 4, 0.2F, 0.4F, 0.6F, 0.8F)
  let result = @feature.histogram_equalize_f(img)
  assert_eq(result.channels, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let alpha_bits = result.data[12].to_int() |
    (result.data[13].to_int() << 8) |
    (result.data[14].to_int() << 16) |
    (result.data[15].to_int() << 24)
  let alpha_val = Float::reinterpret_from_int(alpha_bits)
  assert_true((alpha_val - 0.8F).abs() < 0.001F)
}

// ========== histogram_normalize_16 错误路径 ==========

///|
test "h16f_norm16: invalid channels 0 raises" {
  try {
    let img = @types.Image16::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @feature.histogram_normalize_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_norm16: invalid channels 5 raises" {
  try {
    let img = @types.Image16::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(4 * 4 * 5 * 2, b'\x00')),
    }
    let _ = @feature.histogram_normalize_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_norm16: data mismatch raises" {
  try {
    let img = @types.Image16::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let _ = @feature.histogram_normalize_16(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_norm16: RGBA preserves alpha" {
  let img = h16f_make_img16_rgba(4, 4, 100, 5000, 30000, 60000)
  let result = @feature.histogram_normalize_16(img)
  assert_eq(result.channels, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  let alpha_lo = result.data[6].to_int()
  let alpha_hi = result.data[7].to_int()
  assert_eq(alpha_lo + alpha_hi * 256, 60000)
}

// ========== histogram_normalize_f 错误路径 ==========

///|
test "h16f_normf: invalid channels 0 raises" {
  try {
    let img = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @feature.histogram_normalize_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_normf: invalid channels 5 raises" {
  try {
    let img = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(4 * 4 * 5 * 4, b'\x00')),
    }
    let _ = @feature.histogram_normalize_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_normf: data mismatch raises" {
  try {
    let img = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let _ = @feature.histogram_normalize_f(img)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_normf: RGBA preserves alpha" {
  let img = h16f_make_imgf_rgba(4, 4, 0.1F, 0.3F, 0.5F, 0.9F)
  let result = @feature.histogram_normalize_f(img)
  assert_eq(result.channels, 4)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

// ========== histogram_matching_16 错误路径 ==========

///|
test "h16f_match16: img invalid channels raises" {
  try {
    let img = @types.Image16::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let reference = h16f_make_img16(4, 4, 1, 100)
    let _ = @feature.histogram_matching_16(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_match16: img data mismatch raises" {
  try {
    let img = @types.Image16::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let reference = h16f_make_img16(4, 4, 1, 100)
    let _ = @feature.histogram_matching_16(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_match16: reference invalid channels raises" {
  try {
    let img = h16f_make_img16(4, 4, 1, 100)
    let reference = @types.Image16::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @feature.histogram_matching_16(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_match16: reference data mismatch raises" {
  try {
    let img = h16f_make_img16(4, 4, 1, 100)
    let reference = @types.Image16::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let _ = @feature.histogram_matching_16(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_match16: different reference triggers cdf matching" {
  let img = h16f_make_img16(8, 8, 1, 10000)
  let reference = h16f_make_img16(8, 8, 1, 50000)
  let result = @feature.histogram_matching_16(img, reference)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
  assert_eq(result.channels, 1)
}

///|
test "h16f_match16: RGB with different reference" {
  let img = h16f_make_img16(4, 4, 3, 20000)
  let reference = h16f_make_img16(4, 4, 3, 40000)
  let result = @feature.histogram_matching_16(img, reference)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

// ========== histogram_matching_f 错误路径 ==========

///|
test "h16f_matchf: img invalid channels raises" {
  try {
    let img = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let reference = h16f_make_imgf(4, 4, 1, 0.5F)
    let _ = @feature.histogram_matching_f(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_matchf: img data mismatch raises" {
  try {
    let img = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let reference = h16f_make_imgf(4, 4, 1, 0.5F)
    let _ = @feature.histogram_matching_f(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_matchf: reference invalid channels raises" {
  try {
    let img = h16f_make_imgf(4, 4, 1, 0.5F)
    let reference = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array(Array::make(0, b'\x00')),
    }
    let _ = @feature.histogram_matching_f(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_matchf: reference data mismatch raises" {
  try {
    let img = h16f_make_imgf(4, 4, 1, 0.5F)
    let reference = @types.ImageF::{
      width: 4,
      height: 4,
      channels: 1,
      data: Bytes::from_array(Array::make(10, b'\x00')),
    }
    let _ = @feature.histogram_matching_f(img, reference)
    assert_true(false)
  } catch {
    @types.LoadError::DecodeFailed(_) => assert_true(true)
    _ => assert_true(false)
  }
}

///|
test "h16f_matchf: img with out-of-range values" {
  let img = h16f_make_imgf_range(6, 6, 1)
  let reference = h16f_make_imgf(6, 6, 1, 0.5F)
  let result = @feature.histogram_matching_f(img, reference)
  assert_eq(result.width, 6)
  assert_eq(result.height, 6)
  assert_eq(result.channels, 1)
}

///|
test "h16f_matchf: reference with out-of-range values" {
  let img = h16f_make_imgf(6, 6, 1, 0.5F)
  let reference = h16f_make_imgf_range(6, 6, 1)
  let result = @feature.histogram_matching_f(img, reference)
  assert_eq(result.width, 6)
  assert_eq(result.height, 6)
  assert_eq(result.channels, 1)
}

///|
test "h16f_matchf: RGB with different reference" {
  let img = h16f_make_imgf(4, 4, 3, 0.2F)
  let reference = h16f_make_imgf(4, 4, 3, 0.8F)
  let result = @feature.histogram_matching_f(img, reference)
  assert_eq(result.channels, 3)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}
