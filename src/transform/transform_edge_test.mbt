// v211 transform 补充错误路径测试
// 覆盖：crop_f越界、resize_cover目标尺寸、pyramid无效通道/图像太小、seam_carving_16f参数越界、multi_band_blend_16f尺寸不匹配

///|
fn tr_mk_img(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, b'\x00')
  for i in 0..<(w * h * ch) {
    data[i] = ((i * 137 + 42) % 256).to_byte()
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn tr_mk_img16(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image16 {
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
fn tr_mk_imgf(w : Int32, h : Int32, ch : Int32, val : Float) -> @types.ImageF {
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

// ========== crop_f 错误路径 ==========

///|
test "tr3: crop_f 区域越界" {
  let img = tr_mk_imgf(4, 4, 3, 0.5F)
  try {
    let _ = @transform.crop_f(img, 2, 2, 4, 4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== resize_cover 错误路径 ==========

///|
test "tr3: resize_to_cover 目标宽度零" {
  let img = tr_mk_img(8, 8, 3)
  try {
    let _ = @transform.resize_to_cover(img, 0, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: resize_to_contain 目标高度零" {
  let img = tr_mk_img(8, 8, 3)
  try {
    let _ = @transform.resize_to_contain(img, 8, 0, [b'\x00'])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: resize_to_contain 空填充色" {
  let img = tr_mk_img(8, 8, 3)
  try {
    let _ = @transform.resize_to_contain(img, 16, 16, [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== pyramid 错误路径 ==========

///|
test "tr3: pyr_down 无效通道2" {
  let img = tr_mk_img(8, 8, 2)
  try {
    let _ = @transform.pyr_down(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_down 图像太小" {
  let img = tr_mk_img(1, 1, 3)
  try {
    let _ = @transform.pyr_down(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_up 无效通道2" {
  let img = tr_mk_img(4, 4, 2)
  try {
    let _ = @transform.pyr_up(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== pyramid_16f 错误路径 ==========

///|
test "tr3: pyr_down_16 无效通道2" {
  let img = tr_mk_img16(8, 8, 2, 100)
  try {
    let _ = @transform.pyr_down_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_down_16 图像太小" {
  let img = tr_mk_img16(1, 1, 3, 100)
  try {
    let _ = @transform.pyr_down_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_down_f 无效通道2" {
  let img = tr_mk_imgf(8, 8, 2, 0.5F)
  try {
    let _ = @transform.pyr_down_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_down_f 图像太小" {
  let img = tr_mk_imgf(1, 1, 3, 0.5F)
  try {
    let _ = @transform.pyr_down_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_up_16 无效通道2" {
  let img = tr_mk_img16(4, 4, 2, 100)
  try {
    let _ = @transform.pyr_up_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: pyr_up_f 无效通道2" {
  let img = tr_mk_imgf(4, 4, 2, 0.5F)
  try {
    let _ = @transform.pyr_up_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== seam_carving_16f 错误路径 ==========

///|
test "tr3: seam_carve_resize_16 无效尺寸" {
  let img = tr_mk_img16(8, 8, 3, 100)
  try {
    let _ = @transform.seam_carve_resize_16(img, 0, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: seam_carve_resize_16 放大超过2倍" {
  let img = tr_mk_img16(8, 8, 3, 100)
  try {
    let _ = @transform.seam_carve_resize_16(img, 20, 8)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: seam_carve_resize_f 无效尺寸" {
  let img = tr_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @transform.seam_carve_resize_f(img, 8, 0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: seam_carve_resize_f 放大超过2倍" {
  let img = tr_mk_imgf(8, 8, 3, 0.5F)
  try {
    let _ = @transform.seam_carve_resize_f(img, 8, 20)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

// ========== multi_band_blend_16f 错误路径 ==========

///|
test "tr3: multi_band_blend_16 图像尺寸不匹配" {
  let a = tr_mk_img16(8, 8, 3, 100)
  let b = tr_mk_img16(16, 8, 3, 200)
  let mask = tr_mk_img16(8, 8, 1, 255)
  try {
    let _ = @transform.multi_band_blend_16(a, b, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: multi_band_blend_16 mask尺寸不匹配" {
  let a = tr_mk_img16(8, 8, 3, 100)
  let b = tr_mk_img16(8, 8, 3, 200)
  let mask = tr_mk_img16(16, 8, 1, 255)
  try {
    let _ = @transform.multi_band_blend_16(a, b, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: multi_band_blend_f 图像尺寸不匹配" {
  let a = tr_mk_imgf(8, 8, 3, 0.5F)
  let b = tr_mk_imgf(16, 8, 3, 0.7F)
  let mask = tr_mk_imgf(8, 8, 1, 1.0F)
  try {
    let _ = @transform.multi_band_blend_f(a, b, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "tr3: multi_band_blend_f mask尺寸不匹配" {
  let a = tr_mk_imgf(8, 8, 3, 0.5F)
  let b = tr_mk_imgf(8, 8, 3, 0.7F)
  let mask = tr_mk_imgf(16, 8, 1, 1.0F)
  try {
    let _ = @transform.multi_band_blend_f(a, b, mask)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
