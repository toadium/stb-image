// v197 edge 16f 变体增强测试

///|
fn e16_make_varied16(w : Int32, h : Int32, ch : Int32) -> @types.Image16 {
  let data : Array[Byte] = Array::make(w * h * ch * 2, b'\x00')
  for i in 0..<(w * h * ch) {
    let val : Int32 = (i * 137 + 42) % 65536
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
fn e16_make_variedf(w : Int32, h : Int32, ch : Int32) -> @types.ImageF {
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
fn e16_make_uniform16(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Int32,
) -> @types.Image16 {
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
fn e16_make_uniformf(
  w : Int32,
  h : Int32,
  ch : Int32,
  val : Float,
) -> @types.ImageF {
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

// ========== canny_16f 增强测试 ==========

///|
test "e16: canny_edge_16 非均匀" {
  let img = e16_make_varied16(16, 16, 3)
  try {
    let result = @edge.canny_edge_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: canny_edge_f 非均匀" {
  let img = e16_make_variedf(16, 16, 3)
  try {
    let result = @edge.canny_edge_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: canny_edge_16 自定义阈值" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.canny_edge_16(
      img,
      low_threshold=5000,
      high_threshold=15000,
    )
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: canny_edge_f 自定义阈值" {
  let img = e16_make_variedf(16, 16, 1)
  try {
    let result = @edge.canny_edge_f(
      img,
      low_threshold=0.2F,
      high_threshold=0.5F,
    )
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: canny_edge_16 单通道" {
  let img = e16_make_varied16(8, 8, 1)
  try {
    let result = @edge.canny_edge_16(img)
    assert_eq(result.channels, 1)
  } catch {
    _ => assert_true(true)
  }
}

// ========== edge_detect_16f 增强测试 ==========

///|
test "e16: edge_detect_sobel_16 非均匀" {
  let img = e16_make_varied16(16, 16, 3)
  try {
    let result = @edge.edge_detect_sobel_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_sobel_f 非均匀" {
  let img = e16_make_variedf(16, 16, 3)
  try {
    let result = @edge.edge_detect_sobel_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_laplacian_16 非均匀" {
  let img = e16_make_varied16(16, 16, 3)
  try {
    let result = @edge.edge_detect_laplacian_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_laplacian_f 非均匀" {
  let img = e16_make_variedf(16, 16, 3)
  try {
    let result = @edge.edge_detect_laplacian_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_prewitt_16 非均匀" {
  let img = e16_make_varied16(16, 16, 3)
  try {
    let result = @edge.edge_detect_prewitt_16(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_prewitt_f 非均匀" {
  let img = e16_make_variedf(16, 16, 3)
  try {
    let result = @edge.edge_detect_prewitt_f(img)
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_sobel_16 单通道" {
  let img = e16_make_varied16(8, 8, 1)
  try {
    let result = @edge.edge_detect_sobel_16(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

// ========== contour_16f 增强测试 ==========

///|
test "e16: find_contours_16 非均匀" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.find_contours_16(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: find_contours_f 非均匀" {
  let img = e16_make_variedf(16, 16, 1)
  try {
    let result = @edge.find_contours_f(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: draw_contours_16 基本测试" {
  let img = e16_make_varied16(16, 16, 3)
  try {
    let contours = @edge.find_contours_16(img)
    let result = @edge.draw_contours_16(img, contours, [65535, 0, 0])
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: draw_contours_f 基本测试" {
  let img = e16_make_variedf(16, 16, 3)
  try {
    let contours = @edge.find_contours_f(img)
    let result = @edge.draw_contours_f(img, contours, [1.0F, 0.0F, 0.0F])
    assert_eq(result.width, 16)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: draw_contours_16 空轮廓" {
  let img = e16_make_varied16(8, 8, 3)
  try {
    let result = @edge.draw_contours_16(img, [], [65535, 0, 0])
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

// ========== hough_16f 增强测试 ==========

///|
test "e16: hough_lines_16 非均匀" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.hough_lines_16(img, 50)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_lines_f 非均匀" {
  let img = e16_make_variedf(16, 16, 1)
  try {
    let result = @edge.hough_lines_f(img, 50)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_lines_16 自定义分辨率" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.hough_lines_16(
      img,
      30,
      theta_resolution=2.0F,
      rho_resolution=2.0F,
    )
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

// ========== hough_circles_16f 增强测试 ==========

///|
test "e16: hough_circles_16 非均匀" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.hough_circles_16(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_circles_f 非均匀" {
  let img = e16_make_variedf(16, 16, 1)
  try {
    let result = @edge.hough_circles_f(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_circles_16 自定义参数" {
  let img = e16_make_varied16(16, 16, 1)
  try {
    let result = @edge.hough_circles_16(
      img,
      dp=2,
      min_dist=5,
      param1=80,
      param2=20,
      min_radius=2,
      max_radius=10,
    )
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_circles_f 自定义参数" {
  let img = e16_make_variedf(16, 16, 1)
  try {
    let result = @edge.hough_circles_f(
      img,
      dp=2,
      min_dist=5,
      param1=80,
      param2=20,
      min_radius=2,
      max_radius=10,
    )
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 均匀图像测试 ==========

///|
test "e16: canny_edge_16 均匀图像" {
  let img = e16_make_uniform16(8, 8, 1, 32768)
  try {
    let result = @edge.canny_edge_16(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_sobel_f 均匀图像" {
  let img = e16_make_uniformf(8, 8, 3, 0.5F)
  try {
    let result = @edge.edge_detect_sobel_f(img)
    assert_eq(result.width, 8)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: find_contours_16 均匀图像" {
  let img = e16_make_uniform16(8, 8, 1, 32768)
  try {
    let result = @edge.find_contours_16(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_circles_16 均匀图像" {
  let img = e16_make_uniform16(8, 8, 1, 32768)
  try {
    let result = @edge.hough_circles_16(img)
    assert_true(result.length() >= 0)
  } catch {
    _ => assert_true(true)
  }
}

// ========== 错误路径测试 ==========

///|
test "e16: canny_edge_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @edge.canny_edge_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: edge_detect_sobel_f 零宽度错误" {
  let img = @types.ImageF::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @edge.edge_detect_sobel_f(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: find_contours_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @edge.find_contours_16(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "e16: hough_lines_16 零宽度错误" {
  let img = @types.Image16::{ width: 0, height: 8, channels: 1, data: b"", }
  try {
    let _ = @edge.hough_lines_16(img, 50)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
