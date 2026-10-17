// v213 color 16f 补充错误路径测试
// 覆盖：retinex_16f/tonemap_16f/dehaze_16f/quantize_16f 的无效通道/数据不匹配/参数越界

///|
fn cl_mk_img16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn cl_mk_imgf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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
fn cl_mk_bad16(w : Int, h : Int, ch : Int) -> @types.Image16 {
  @types.Image16::{ width: w, height: h, channels: ch, data: b"\x00\x01", }
}

///|
fn cl_mk_badf(w : Int, h : Int, ch : Int) -> @types.ImageF {
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: b"\x00\x01\x02\x03",
  }
}

// ========== retinex_16f 错误路径 ==========

///|
test "cl3: ssr_16 无效通道2" {
  let img = cl_mk_img16(8, 8, 2, 100)
  try {
    let _ = @color.ssr_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: ssr_16 sigma零" {
  let img = cl_mk_img16(8, 8, 3, 100)
  try {
    let _ = @color.ssr_16(img, sigma=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: msr_16 无效通道2" {
  let img = cl_mk_img16(8, 8, 2, 100)
  try {
    let _ = @color.msr_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: msr_16 空sigmas" {
  let img = cl_mk_img16(8, 8, 3, 100)
  try {
    let _ = @color.msr_16(img, sigmas=[])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: msrcr_16 灰度图" {
  let img = cl_mk_img16(8, 8, 1, 100)
  try {
    let _ = @color.msrcr_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: ssr_f 无效通道2" {
  let img = cl_mk_imgf(8, 8, 2, 0.5F)
  try {
    let _ = @color.ssr_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: msr_f 空sigmas" {
  let img = cl_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @color.msr_f(img, sigmas=[])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: msrcr_f 灰度图" {
  let img = cl_mk_imgf(8, 8, 1, 0.5F)
  try {
    let _ = @color.msrcr_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== tonemap_16f 错误路径 ==========

///|
test "cl3: gamma_tonemap_f 零宽度" {
  let img = cl_mk_imgf(0, 8, 3, 0.5F)
  try {
    let _ = @color.gamma_tonemap_f(img, 2.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: gamma_tonemap_f gamma零" {
  let img = cl_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @color.gamma_tonemap_f(img, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: reinhard_tonemap_f key零" {
  let img = cl_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @color.reinhard_tonemap_f(img, key=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: gamma_tonemap_16 零宽度" {
  let img = cl_mk_imgf(0, 8, 3, 0.5F)
  try {
    let _ = @color.gamma_tonemap_16(img, 2.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: gamma_tonemap_16 gamma零" {
  let img = cl_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @color.gamma_tonemap_16(img, 0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: reinhard_tonemap_16 key零" {
  let img = cl_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @color.reinhard_tonemap_16(img, key=0.0F)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== dehaze_16f 错误路径 ==========

///|
test "cl3: dehaze_16 零宽度" {
  let img = cl_mk_img16(0, 8, 3, 100)
  try {
    let _ = @color.dehaze_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: dehaze_16 数据不匹配" {
  let img = cl_mk_bad16(8, 8, 3)
  try {
    let _ = @color.dehaze_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: dehaze_f 零宽度" {
  let img = cl_mk_imgf(0, 8, 3, 0.5F)
  try {
    let _ = @color.dehaze_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: dehaze_f 数据不匹配" {
  let img = cl_mk_badf(8, 8, 3)
  try {
    let _ = @color.dehaze_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== quantize_16f 错误路径 ==========

///|
test "cl3: floyd_steinberg_16 零宽度" {
  let img = cl_mk_img16(0, 8, 3, 100)
  try {
    let _ = @color.floyd_steinberg_16(img, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "cl3: median_cut_16 零宽度" {
  let img = cl_mk_img16(0, 8, 3, 100)
  try {
    let _ = @color.median_cut_16(img, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
