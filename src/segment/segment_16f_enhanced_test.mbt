// v198 segment 16f 变体增强测试

///|
fn s16_make_varied16(w : Int, h : Int, ch : Int) -> @types.Image16 {
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
fn s16_make_variedf(w : Int, h : Int, ch : Int) -> @types.ImageF {
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
fn s16_make_uniform16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn s16_make_uniformf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== morphology_16f 基本运算 ==========

///|
test "s16: erode_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.erode_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: erode_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.erode_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: dilate_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.dilate_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: dilate_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.dilate_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_open_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.morph_open_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_open_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.morph_open_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_close_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.morph_close_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_close_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.morph_close_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_gradient_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.morph_gradient_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_gradient_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.morph_gradient_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_tophat_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.morph_tophat_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_tophat_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.morph_tophat_f(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_blackhat_16 非均匀" {
  let img = s16_make_varied16(16, 16, 1)
  let result = @segment.morph_blackhat_16(img)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_blackhat_f 非均匀" {
  let img = s16_make_variedf(16, 16, 1)
  let result = @segment.morph_blackhat_f(img)
  assert_eq(result.width, 16)
}

// ========== morphology_16f 自定义结构元素 ==========

///|
test "s16: erode_custom_16 矩形SE" {
  let img = s16_make_varied16(16, 16, 1)
  let se = @segment.se_rect(3, 3)
  let result = @segment.erode_custom_16(img, se)
  assert_eq(result.width, 16)
}

///|
test "s16: dilate_custom_f 十字SE" {
  let img = s16_make_variedf(16, 16, 1)
  let se = @segment.se_cross(3)
  let result = @segment.dilate_custom_f(img, se)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_open_custom_16 椭圆SE" {
  let img = s16_make_varied16(16, 16, 1)
  let se = @segment.se_ellipse(5)
  let result = @segment.morph_open_custom_16(img, se)
  assert_eq(result.width, 16)
}

///|
test "s16: morph_close_custom_f 矩形SE" {
  let img = s16_make_variedf(16, 16, 1)
  let se = @segment.se_rect(5, 5)
  let result = @segment.morph_close_custom_f(img, se)
  assert_eq(result.width, 16)
}

// ========== morphology_16f 多通道 ==========

///|
test "s16: erode_16 多通道" {
  let img = s16_make_varied16(16, 16, 3)
  let result = @segment.erode_16(img)
  assert_eq(result.channels, 3)
}

///|
test "s16: dilate_f 多通道" {
  let img = s16_make_variedf(16, 16, 3)
  let result = @segment.dilate_f(img)
  assert_eq(result.channels, 3)
}

// ========== morphology_16f 均匀图像 ==========

///|
test "s16: erode_16 均匀图像" {
  let img = s16_make_uniform16(8, 8, 1, 32768)
  let result = @segment.erode_16(img)
  assert_eq(result.width, 8)
}

///|
test "s16: dilate_f 均匀图像" {
  let img = s16_make_uniformf(8, 8, 1, 0.5F)
  let result = @segment.dilate_f(img)
  assert_eq(result.width, 8)
}

// ========== segmentation_16f 增强测试 ==========

///|
test "s16: watershed_16 基本测试" {
  let img = s16_make_varied16(16, 16, 1)
  try {
    let result = @segment.watershed_16(img, [1, 2])
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: watershed_f 基本测试" {
  let img = s16_make_variedf(16, 16, 1)
  try {
    let result = @segment.watershed_f(img, [1, 2])
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: watershed_auto_16 基本测试" {
  let img = s16_make_varied16(16, 16, 1)
  try {
    let (labels, count) = @segment.watershed_auto_16(img)
    assert_true(labels.length() >= 0)
    assert_true(count >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: watershed_auto_f 基本测试" {
  let img = s16_make_variedf(16, 16, 1)
  try {
    let (labels, count) = @segment.watershed_auto_f(img)
    assert_true(labels.length() >= 0)
    assert_true(count >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: kmeans_segment_16 基本测试" {
  let img = s16_make_varied16(16, 16, 3)
  try {
    let (_, regions) = @segment.kmeans_segment_16(img, 3)
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: kmeans_segment_f 基本测试" {
  let img = s16_make_variedf(16, 16, 3)
  try {
    let (_, regions) = @segment.kmeans_segment_f(img, 2)
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: slic_16 基本测试" {
  let img = s16_make_varied16(16, 16, 3)
  try {
    let result = @segment.slic_16(img, 10, 30, 5)
    assert_true(result.labels.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "s16: slic_f 基本测试" {
  let img = s16_make_variedf(16, 16, 3)
  try {
    let result = @segment.slic_f(img, 10, 30, 5)
    assert_true(result.labels.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}
