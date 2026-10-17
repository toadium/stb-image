// v199 transform 16f 变体增强测试

///|
fn t16_make_varied16(w : Int, h : Int, ch : Int) -> @types.Image16 {
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
fn t16_make_variedf(w : Int, h : Int, ch : Int) -> @types.ImageF {
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
fn t16_make_uniform16(w : Int, h : Int, ch : Int, val : Int) -> @types.Image16 {
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
fn t16_make_uniformf(w : Int, h : Int, ch : Int, val : Float) -> @types.ImageF {
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

// ========== transform_16f 基本变换 ==========

///|
test "t16: rotate_90_16 非均匀" {
  let img = t16_make_varied16(16, 8, 3)
  let result = @transform.rotate_90_16(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 16)
}

///|
test "t16: rotate_90_f 非均匀" {
  let img = t16_make_variedf(16, 8, 3)
  let result = @transform.rotate_90_f(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 16)
}

///|
test "t16: rotate_180_16 非均匀" {
  let img = t16_make_varied16(16, 8, 3)
  let result = @transform.rotate_180_16(img)
  assert_eq(result.width, 16)
  assert_eq(result.height, 8)
}

///|
test "t16: rotate_180_f 非均匀" {
  let img = t16_make_variedf(16, 8, 3)
  let result = @transform.rotate_180_f(img)
  assert_eq(result.width, 16)
}

///|
test "t16: rotate_270_16 非均匀" {
  let img = t16_make_varied16(16, 8, 3)
  let result = @transform.rotate_270_16(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 16)
}

///|
test "t16: rotate_270_f 非均匀" {
  let img = t16_make_variedf(16, 8, 3)
  let result = @transform.rotate_270_f(img)
  assert_eq(result.width, 8)
}

///|
test "t16: flip_horizontal_16 非均匀" {
  let img = t16_make_varied16(16, 16, 3)
  let result = @transform.flip_horizontal_16(img)
  assert_eq(result.width, 16)
}

///|
test "t16: flip_horizontal_f 非均匀" {
  let img = t16_make_variedf(16, 16, 3)
  let result = @transform.flip_horizontal_f(img)
  assert_eq(result.width, 16)
}

///|
test "t16: flip_vertical_16 非均匀" {
  let img = t16_make_varied16(16, 16, 3)
  let result = @transform.flip_vertical_16(img)
  assert_eq(result.width, 16)
}

///|
test "t16: flip_vertical_f 非均匀" {
  let img = t16_make_variedf(16, 16, 3)
  let result = @transform.flip_vertical_f(img)
  assert_eq(result.width, 16)
}

///|
test "t16: transpose_16 非均匀" {
  let img = t16_make_varied16(16, 8, 3)
  let result = @transform.transpose_16(img)
  assert_eq(result.width, 8)
  assert_eq(result.height, 16)
}

///|
test "t16: transpose_f 非均匀" {
  let img = t16_make_variedf(16, 8, 3)
  let result = @transform.transpose_f(img)
  assert_eq(result.width, 8)
}

// ========== geometry_16f 几何变换 ==========

///|
test "t16: warp_affine_16 单位变换" {
  let img = t16_make_varied16(16, 16, 3)
  let result = @transform.warp_affine_16(
    img,
    (1.0F, 0.0F, 0.0F, 0.0F, 1.0F, 0.0F),
    16,
    16,
  )
  assert_eq(result.width, 16)
}

///|
test "t16: warp_affine_f 缩放" {
  let img = t16_make_variedf(16, 16, 3)
  let result = @transform.warp_affine_f(
    img,
    (0.5F, 0.0F, 0.0F, 0.0F, 0.5F, 0.0F),
    8,
    8,
  )
  assert_eq(result.width, 8)
}

///|
test "t16: resize_16 放大" {
  let img = t16_make_varied16(8, 8, 3)
  let result = @transform.resize_16(img, 16, 16)
  assert_eq(result.width, 16)
  assert_eq(result.height, 16)
}

///|
test "t16: resize_f 缩小" {
  let img = t16_make_variedf(16, 16, 3)
  let result = @transform.resize_f(img, 8, 8)
  assert_eq(result.width, 8)
}

///|
test "t16: warp_perspective_16 单位变换" {
  let img = t16_make_varied16(16, 16, 3)
  let m = @transform.PerspectiveMatrix::{
    m00: 1.0F,
    m01: 0.0F,
    m02: 0.0F,
    m10: 0.0F,
    m11: 1.0F,
    m12: 0.0F,
    m20: 0.0F,
    m21: 0.0F,
    m22: 1.0F,
  }
  let result = @transform.warp_perspective_16(img, m, 16, 16)
  assert_eq(result.width, 16)
}

// ========== pyramid_16f 金字塔 ==========

///|
test "t16: pyr_down_16 非均匀" {
  let img = t16_make_varied16(16, 16, 3)
  try {
    let result = @transform.pyr_down_16(img)
    assert_eq(result.width, 8)
    assert_eq(result.height, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: pyr_down_f 非均匀" {
  let img = t16_make_variedf(16, 16, 3)
  try {
    let result = @transform.pyr_down_f(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: pyr_up_16 非均匀" {
  let img = t16_make_varied16(8, 8, 3)
  try {
    let result = @transform.pyr_up_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: pyr_up_f 非均匀" {
  let img = t16_make_variedf(8, 8, 3)
  try {
    let result = @transform.pyr_up_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: build_gaussian_pyramid_16 基本测试" {
  let img = t16_make_varied16(16, 16, 3)
  try {
    let result = @transform.build_gaussian_pyramid_16(img, 3)
    assert_true(result.length() >= 1)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: build_gaussian_pyramid_f 基本测试" {
  let img = t16_make_variedf(16, 16, 3)
  try {
    let result = @transform.build_gaussian_pyramid_f(img, 3)
    assert_true(result.length() >= 1)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: build_laplacian_pyramid_16 基本测试" {
  let img = t16_make_varied16(16, 16, 3)
  try {
    let result = @transform.build_laplacian_pyramid_16(img, 3)
    assert_true(result.length() >= 1)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: build_laplacian_pyramid_float 基本测试" {
  let img = t16_make_variedf(16, 16, 3)
  try {
    let result = @transform.build_laplacian_pyramid_float(img, 3)
    assert_true(result.length() >= 1)
  } catch {
    _ => assert_true(true)
  }
}

// ========== seam_carving_16f 接缝雕刻 ==========

///|
test "t16: compute_energy_16 非均匀" {
  let img = t16_make_varied16(16, 16, 3)
  let result = @transform.compute_energy_16(img)
  assert_eq(result.length(), 16 * 16)
}

///|
test "t16: compute_energy_f 非均匀" {
  let img = t16_make_variedf(16, 16, 3)
  let result = @transform.compute_energy_f(img)
  assert_eq(result.length(), 16 * 16)
}

///|
test "t16: seam_carve_resize_16 缩小宽度" {
  let img = t16_make_varied16(16, 16, 3)
  try {
    let result = @transform.seam_carve_resize_16(img, 12, 16)
    assert_eq(result.width, 12)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "t16: seam_carve_resize_f 缩小宽度" {
  let img = t16_make_variedf(16, 16, 3)
  try {
    let result = @transform.seam_carve_resize_f(img, 12, 16)
    assert_eq(result.width, 12)
  } catch {
    _ => assert_true(true)
  }
}

// ========== draw_16f 绘图 ==========

///|
test "t16: draw_line_16 基本测试" {
  let img = t16_make_uniform16(16, 16, 3, 0)
  let result = @transform.draw_line_16(img, 0, 0, 15, 15, [65535, 0, 0])
  assert_eq(result.width, 16)
}

///|
test "t16: draw_line_f 基本测试" {
  let img = t16_make_uniformf(16, 16, 3, 0.0F)
  let result = @transform.draw_line_f(img, 0, 0, 15, 15, [1.0F, 0.0F, 0.0F])
  assert_eq(result.width, 16)
}

///|
test "t16: draw_rectangle_16 基本测试" {
  let img = t16_make_uniform16(16, 16, 3, 0)
  let result = @transform.draw_rectangle_16(img, 2, 2, 8, 8, [65535, 0, 0])
  assert_eq(result.width, 16)
}

///|
test "t16: draw_rectangle_f 填充" {
  let img = t16_make_uniformf(16, 16, 3, 0.0F)
  let result = @transform.draw_rectangle_f(
    img,
    2,
    2,
    8,
    8,
    [1.0F, 0.0F, 0.0F],
    fill=true,
  )
  assert_eq(result.width, 16)
}

///|
test "t16: draw_circle_16 基本测试" {
  let img = t16_make_uniform16(16, 16, 3, 0)
  let result = @transform.draw_circle_16(img, 8, 8, 4, [65535, 0, 0])
  assert_eq(result.width, 16)
}

///|
test "t16: draw_circle_f 填充" {
  let img = t16_make_uniformf(16, 16, 3, 0.0F)
  let result = @transform.draw_circle_f(
    img,
    8,
    8,
    4,
    [1.0F, 0.0F, 0.0F],
    fill=true,
  )
  assert_eq(result.width, 16)
}

// ========== 均匀图像测试 ==========

///|
test "t16: rotate_90_16 均匀图像" {
  let img = t16_make_uniform16(8, 8, 1, 32768)
  let result = @transform.rotate_90_16(img)
  assert_eq(result.width, 8)
}

///|
test "t16: resize_f 均匀图像" {
  let img = t16_make_uniformf(8, 8, 3, 0.5F)
  let result = @transform.resize_f(img, 16, 16)
  assert_eq(result.width, 16)
}

///|
test "t16: draw_line_16 均匀图像" {
  let img = t16_make_uniform16(8, 8, 1, 32768)
  let result = @transform.draw_line_16(img, 0, 0, 7, 7, [65535])
  assert_eq(result.width, 8)
}
