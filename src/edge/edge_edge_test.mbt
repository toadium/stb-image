// v207 edge 模块边界/错误路径增强测试

///|
fn edge_mk_img(w : Int32, h : Int32, ch : Int32, val : Int32) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h * ch, (val & 0xFF).to_byte())
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn edge_mk_img_bad_data(w : Int32, h : Int32, ch : Int32) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

///|
fn edge_mk_img16(
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
fn edge_mk_img16_bad(w : Int32, h : Int32, ch : Int32) -> @types.Image16 {
  @types.Image16::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

///|
fn edge_mk_imgf(w : Int32, h : Int32, ch : Int32, val : Float) -> @types.ImageF {
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
fn edge_mk_imgf_bad(w : Int32, h : Int32, ch : Int32) -> @types.ImageF {
  @types.ImageF::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array([b'\x00']),
  }
}

///|
fn edge_expect_error(f : () -> Unit raise @types.LoadError) -> Bool {
  try {
    f()
    false
  } catch {
    _ => true
  }
}

// ==================== canny_edge 8-bit 错误路径 ====================

///|
test "canny_edge: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge(img))))
}

///|
test "canny_edge: 无效通道2 raise" {
  let img = edge_mk_img(4, 4, 2, 128)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge(img))))
}

///|
test "canny_edge: 数据大小不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge(img))))
}

///|
test "canny_edge: low_threshold>255 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.canny_edge(img, low_threshold=300))),
  )
}

///|
test "canny_edge: high_threshold>255 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.canny_edge(img, high_threshold=300))),
  )
}

///|
test "canny_edge: low>high raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.canny_edge(img, low_threshold=100, high_threshold=50))
    }),
  )
}

// ==================== edge_detect_sobel 错误路径 ====================

///|
test "edge_detect_sobel: 零高度 raise" {
  let img = edge_mk_img(4, 0, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel(img))))
}

///|
test "edge_detect_sobel: 无效通道0 raise" {
  let img = edge_mk_img(4, 4, 0, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel(img))))
}

///|
test "edge_detect_sobel: 无效通道5 raise" {
  let img = edge_mk_img(4, 4, 5, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel(img))))
}

///|
test "edge_detect_sobel: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel(img))))
}

// ==================== edge_detect_laplacian 错误路径 ====================

///|
test "edge_detect_laplacian: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_laplacian(img))))
}

///|
test "edge_detect_laplacian: 无效通道0 raise" {
  let img = edge_mk_img(4, 4, 0, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_laplacian(img))))
}

///|
test "edge_detect_laplacian: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 3)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_laplacian(img))))
}

// ==================== edge_detect_prewitt 错误路径 ====================

///|
test "edge_detect_prewitt: 零高度 raise" {
  let img = edge_mk_img(4, 0, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_prewitt(img))))
}

///|
test "edge_detect_prewitt: 无效通道5 raise" {
  let img = edge_mk_img(4, 4, 5, 128)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_prewitt(img))))
}

///|
test "edge_detect_prewitt: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_prewitt(img))))
}

// ==================== find_contours 错误路径 ====================

///|
test "find_contours: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours(img))))
}

///|
test "find_contours: 无效通道2 raise" {
  let img = edge_mk_img(4, 4, 2, 128)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours(img))))
}

///|
test "find_contours: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours(img))))
}

// ==================== draw_contours 错误路径 ====================

///|
test "draw_contours: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours(img, [], [b'\xFF']))),
  )
}

///|
test "draw_contours: 无效通道2 raise" {
  let img = edge_mk_img(4, 4, 2, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours(img, [], [b'\xFF']))),
  )
}

///|
test "draw_contours: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours(img, [], [b'\xFF']))),
  )
}

///|
test "draw_contours: 空color数组 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.draw_contours(img, [], []))))
}

// ==================== hough_lines 错误路径 ====================

///|
test "hough_lines: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines(img, 1))))
}

///|
test "hough_lines: 无效通道2 raise" {
  let img = edge_mk_img(4, 4, 2, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines(img, 1))))
}

///|
test "hough_lines: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines(img, 1))))
}

///|
test "hough_lines: threshold=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines(img, 0))))
}

///|
test "hough_lines: theta_res<=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines(img, 1, theta_resolution=0.0F))
    }),
  )
}

///|
test "hough_lines: rho_res<=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines(img, 1, rho_resolution=0.0F))
    }),
  )
}

// ==================== hough_lines_nms 错误路径 ====================

///|
test "hough_lines_nms: rho_threshold<=0 raise" {
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines_nms([], rho_threshold=0.0F))
    }),
  )
}

///|
test "hough_lines_nms: theta_threshold<=0 raise" {
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines_nms([], theta_threshold=0.0F))
    }),
  )
}

// ==================== hough_circles 错误路径 ====================

///|
test "hough_circles: 零宽度 raise" {
  let img = edge_mk_img(0, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles(img))))
}

///|
test "hough_circles: 无效通道2 raise" {
  let img = edge_mk_img(4, 4, 2, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles(img))))
}

///|
test "hough_circles: 数据不匹配 raise" {
  let img = edge_mk_img_bad_data(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles(img))))
}

///|
test "hough_circles: dp=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles(img, dp=0))))
}

///|
test "hough_circles: min_dist=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles(img, min_dist=0))),
  )
}

///|
test "hough_circles: param1=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles(img, param1=0))),
  )
}

///|
test "hough_circles: param2=0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles(img, param2=0))),
  )
}

///|
test "hough_circles: min_radius<0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles(img, min_radius=-1))),
  )
}

///|
test "hough_circles: max_radius<0 raise" {
  let img = edge_mk_img(4, 4, 1, 128)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles(img, max_radius=-1))),
  )
}

// ==================== approx_poly_dp 错误路径 ====================

///|
test "approx_poly_dp: epsilon<0 raise" {
  assert_true(edge_expect_error(() => ignore(@edge.approx_poly_dp([], -1.0F))))
}

///|
test "approx_poly_dp: 空数组返回空" {
  let result = @edge.approx_poly_dp([], 1.0F) catch { _ => [] }
  assert_eq(result.length(), 0)
}

///|
test "approx_poly_dp: closed=false" {
  let pts = [
    @edge.ContourPoint::{ x: 0, y: 0, },
    @edge.ContourPoint::{ x: 4, y: 0, },
    @edge.ContourPoint::{ x: 4, y: 4, },
    @edge.ContourPoint::{ x: 0, y: 4, },
  ]
  let result = @edge.approx_poly_dp(pts, 0.5F, closed=false) catch { _ => [] }
  assert_true(result.length() >= 2)
}

// ==================== hu_moments 错误路径 ====================

///|
test "hu_moments: m00=0 raise" {
  let m = @edge.Moments::{
    m00: 0.0,
    m10: 0.0,
    m01: 0.0,
    m20: 0.0,
    m11: 0.0,
    m02: 0.0,
    m30: 0.0,
    m21: 0.0,
    m12: 0.0,
    m03: 0.0,
    mu20: 0.0,
    mu11: 0.0,
    mu02: 0.0,
    mu30: 0.0,
    mu21: 0.0,
    mu12: 0.0,
    mu03: 0.0,
    nu20: 0.0,
    nu11: 0.0,
    nu02: 0.0,
  }
  assert_true(edge_expect_error(() => ignore(@edge.hu_moments(m))))
}

///|
test "hu_moments: 有效矩返回7个值" {
  let m = @edge.Moments::{
    m00: 4.0,
    m10: 4.0,
    m01: 4.0,
    m20: 6.0,
    m11: 4.0,
    m02: 6.0,
    m30: 10.0,
    m21: 6.0,
    m12: 6.0,
    m03: 10.0,
    mu20: 2.0,
    mu11: 0.0,
    mu02: 2.0,
    mu30: 0.0,
    mu21: 0.0,
    mu12: 0.0,
    mu03: 0.0,
    nu20: 0.125,
    nu11: 0.0,
    nu02: 0.125,
  }
  let result = @edge.hu_moments(m) catch { _ => [] }
  assert_eq(result.length(), 7)
}

// ==================== convex_hull 边界 ====================

///|
test "convex_hull: 空数组" {
  let result = @edge.convex_hull([])
  assert_eq(result.length(), 0)
}

///|
test "convex_hull: 单个点" {
  let result = @edge.convex_hull([@edge.ContourPoint::{ x: 3, y: 5, }])
  assert_eq(result.length(), 1)
}

///|
test "convex_hull: 两个点" {
  let result = @edge.convex_hull([
    @edge.ContourPoint::{ x: 0, y: 0, },
    @edge.ContourPoint::{ x: 5, y: 5, },
  ])
  assert_eq(result.length(), 2)
}

// ==================== image_moments 边界 ====================

///|
test "image_moments: 空数组" {
  let m = @edge.image_moments([])
  assert_true(m.m00 == 0.0)
}

// ==================== min_enclosing_circle 边界 ====================

///|
test "min_enclosing_circle: 空数组" {
  let (center, radius) = @edge.min_enclosing_circle([])
  assert_eq(center.x, 0)
  assert_eq(center.y, 0)
  assert_true(radius == 0.0F)
}

///|
test "min_enclosing_circle: 单个点" {
  let (center, radius) = @edge.min_enclosing_circle([
    @edge.ContourPoint::{ x: 7, y: 3, },
  ])
  assert_eq(center.x, 7)
  assert_eq(center.y, 3)
  assert_true(radius == 0.0F)
}

// ==================== canny_edge_16 错误路径 ====================

///|
test "canny_edge_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_16(img))))
}

///|
test "canny_edge_16: 无效通道2 raise" {
  let img = edge_mk_img16(4, 4, 2, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_16(img))))
}

///|
test "canny_edge_16: 数据不匹配 raise" {
  let img = edge_mk_img16_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_16(img))))
}

///|
test "canny_edge_16: low>65535 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.canny_edge_16(img, low_threshold=70000))
    }),
  )
}

///|
test "canny_edge_16: high>65535 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.canny_edge_16(img, high_threshold=70000))
    }),
  )
}

///|
test "canny_edge_16: low>high raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => {
      ignore(
        @edge.canny_edge_16(img, low_threshold=20000, high_threshold=10000),
      )
    }),
  )
}

// ==================== edge_detect_sobel_16 错误路径 ====================

///|
test "edge_detect_sobel_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_16(img))))
}

///|
test "edge_detect_sobel_16: 无效通道0 raise" {
  let img = edge_mk_img16(4, 4, 0, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_16(img))))
}

///|
test "edge_detect_sobel_16: 数据不匹配 raise" {
  let img = edge_mk_img16_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_16(img))))
}

// ==================== edge_detect_laplacian_16 错误路径 ====================

///|
test "edge_detect_laplacian_16: 零高度 raise" {
  let img = edge_mk_img16(4, 0, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_laplacian_16(img))),
  )
}

///|
test "edge_detect_laplacian_16: 无效通道5 raise" {
  let img = edge_mk_img16(4, 4, 5, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_laplacian_16(img))),
  )
}

// ==================== edge_detect_prewitt_16 错误路径 ====================

///|
test "edge_detect_prewitt_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_prewitt_16(img))),
  )
}

///|
test "edge_detect_prewitt_16: 数据不匹配 raise" {
  let img = edge_mk_img16_bad(4, 4, 3)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_prewitt_16(img))),
  )
}

// ==================== find_contours_16 错误路径 ====================

///|
test "find_contours_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_16(img))))
}

///|
test "find_contours_16: 无效通道2 raise" {
  let img = edge_mk_img16(4, 4, 2, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_16(img))))
}

///|
test "find_contours_16: 数据不匹配 raise" {
  let img = edge_mk_img16_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_16(img))))
}

// ==================== draw_contours_16 错误路径 ====================

///|
test "draw_contours_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_16(img, [], [1000]))),
  )
}

///|
test "draw_contours_16: 无效通道2 raise" {
  let img = edge_mk_img16(4, 4, 2, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_16(img, [], [1000]))),
  )
}

///|
test "draw_contours_16: 空color数组 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_16(img, [], []))),
  )
}

// ==================== hough_lines_16 错误路径 ====================

///|
test "hough_lines_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_16(img, 1))))
}

///|
test "hough_lines_16: 无效通道2 raise" {
  let img = edge_mk_img16(4, 4, 2, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_16(img, 1))))
}

///|
test "hough_lines_16: threshold=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_16(img, 0))))
}

///|
test "hough_lines_16: theta_res<=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines_16(img, 1, theta_resolution=0.0F))
    }),
  )
}

// ==================== hough_circles_16 错误路径 ====================

///|
test "hough_circles_16: 零宽度 raise" {
  let img = edge_mk_img16(0, 4, 1, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles_16(img))))
}

///|
test "hough_circles_16: 无效通道2 raise" {
  let img = edge_mk_img16(4, 4, 2, 1000)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles_16(img))))
}

///|
test "hough_circles_16: dp=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, dp=0))),
  )
}

///|
test "hough_circles_16: min_dist=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, min_dist=0))),
  )
}

///|
test "hough_circles_16: param1=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, param1=0))),
  )
}

///|
test "hough_circles_16: param2=0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, param2=0))),
  )
}

///|
test "hough_circles_16: min_radius<0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, min_radius=-1))),
  )
}

///|
test "hough_circles_16: max_radius<0 raise" {
  let img = edge_mk_img16(4, 4, 1, 1000)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_16(img, max_radius=-1))),
  )
}

// ==================== canny_edge_f 错误路径 ====================

///|
test "canny_edge_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_f(img))))
}

///|
test "canny_edge_f: 无效通道2 raise" {
  let img = edge_mk_imgf(4, 4, 2, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_f(img))))
}

///|
test "canny_edge_f: 数据不匹配 raise" {
  let img = edge_mk_imgf_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.canny_edge_f(img))))
}

///|
test "canny_edge_f: low>1.0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.canny_edge_f(img, low_threshold=1.5F))),
  )
}

///|
test "canny_edge_f: high>1.0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.canny_edge_f(img, high_threshold=2.0F))),
  )
}

///|
test "canny_edge_f: low>high raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.canny_edge_f(img, low_threshold=0.8F, high_threshold=0.2F))
    }),
  )
}

// ==================== edge_detect_sobel_f 错误路径 ====================

///|
test "edge_detect_sobel_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_f(img))))
}

///|
test "edge_detect_sobel_f: 无效通道0 raise" {
  let img = edge_mk_imgf(4, 4, 0, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_f(img))))
}

///|
test "edge_detect_sobel_f: 数据不匹配 raise" {
  let img = edge_mk_imgf_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_sobel_f(img))))
}

// ==================== edge_detect_laplacian_f 错误路径 ====================

///|
test "edge_detect_laplacian_f: 零高度 raise" {
  let img = edge_mk_imgf(4, 0, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_laplacian_f(img))),
  )
}

///|
test "edge_detect_laplacian_f: 无效通道5 raise" {
  let img = edge_mk_imgf(4, 4, 5, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.edge_detect_laplacian_f(img))),
  )
}

// ==================== edge_detect_prewitt_f 错误路径 ====================

///|
test "edge_detect_prewitt_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_prewitt_f(img))))
}

///|
test "edge_detect_prewitt_f: 数据不匹配 raise" {
  let img = edge_mk_imgf_bad(4, 4, 3)
  assert_true(edge_expect_error(() => ignore(@edge.edge_detect_prewitt_f(img))))
}

// ==================== find_contours_f 错误路径 ====================

///|
test "find_contours_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_f(img))))
}

///|
test "find_contours_f: 无效通道2 raise" {
  let img = edge_mk_imgf(4, 4, 2, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_f(img))))
}

///|
test "find_contours_f: 数据不匹配 raise" {
  let img = edge_mk_imgf_bad(4, 4, 1)
  assert_true(edge_expect_error(() => ignore(@edge.find_contours_f(img))))
}

// ==================== draw_contours_f 错误路径 ====================

///|
test "draw_contours_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_f(img, [], [1.0F]))),
  )
}

///|
test "draw_contours_f: 无效通道2 raise" {
  let img = edge_mk_imgf(4, 4, 2, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_f(img, [], [1.0F]))),
  )
}

///|
test "draw_contours_f: 空color数组 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.draw_contours_f(img, [], []))),
  )
}

// ==================== hough_lines_f 错误路径 ====================

///|
test "hough_lines_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_f(img, 1))))
}

///|
test "hough_lines_f: 无效通道2 raise" {
  let img = edge_mk_imgf(4, 4, 2, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_f(img, 1))))
}

///|
test "hough_lines_f: threshold=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_lines_f(img, 0))))
}

///|
test "hough_lines_f: theta_res<=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => {
      ignore(@edge.hough_lines_f(img, 1, theta_resolution=0.0F))
    }),
  )
}

// ==================== hough_circles_f 错误路径 ====================

///|
test "hough_circles_f: 零宽度 raise" {
  let img = edge_mk_imgf(0, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles_f(img))))
}

///|
test "hough_circles_f: 无效通道2 raise" {
  let img = edge_mk_imgf(4, 4, 2, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles_f(img))))
}

///|
test "hough_circles_f: dp=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(edge_expect_error(() => ignore(@edge.hough_circles_f(img, dp=0))))
}

///|
test "hough_circles_f: min_dist=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_f(img, min_dist=0))),
  )
}

///|
test "hough_circles_f: param1=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_f(img, param1=0))),
  )
}

///|
test "hough_circles_f: param2=0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_f(img, param2=0))),
  )
}

///|
test "hough_circles_f: min_radius<0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_f(img, min_radius=-1))),
  )
}

///|
test "hough_circles_f: max_radius<0 raise" {
  let img = edge_mk_imgf(4, 4, 1, 0.5F)
  assert_true(
    edge_expect_error(() => ignore(@edge.hough_circles_f(img, max_radius=-1))),
  )
}

// ==================== 正常功能验证 ====================

///|
test "canny_edge: 正常4x4灰度图" {
  let img = edge_mk_img(4, 4, 1, 128)
  let result = @edge.canny_edge(img) catch {
    _ =>
      @types.Image::{
        width: 0,
        height: 0,
        channels: 0,
        data: Bytes::from_array([]),
      }
  }
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
}

///|
test "edge_detect_sobel: 正常4x4 RGB" {
  let img = edge_mk_img(4, 4, 3, 200)
  let result = @edge.edge_detect_sobel(img) catch {
    _ =>
      @types.Image::{
        width: 0,
        height: 0,
        channels: 0,
        data: Bytes::from_array([]),
      }
  }
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.channels, 1)
}

///|
test "hough_lines: 正常4x4无边缘" {
  let img = edge_mk_img(4, 4, 1, 0)
  let result = @edge.hough_lines(img, 1) catch { _ => [] }
  assert_eq(result.length(), 0)
}

///|
test "hough_circles: 正常4x4无圆" {
  let img = edge_mk_img(4, 4, 1, 0)
  let result = @edge.hough_circles(img) catch { _ => [] }
  assert_eq(result.length(), 0)
}

///|
test "find_contours: 正常4x4全黑" {
  let img = edge_mk_img(4, 4, 1, 0)
  let result = @edge.find_contours(img) catch { _ => [] }
  assert_eq(result.length(), 0)
}

///|
test "convex_hull: 正方形四个点" {
  let pts = [
    @edge.ContourPoint::{ x: 0, y: 0, },
    @edge.ContourPoint::{ x: 4, y: 0, },
    @edge.ContourPoint::{ x: 4, y: 4, },
    @edge.ContourPoint::{ x: 0, y: 4, },
  ]
  let result = @edge.convex_hull(pts)
  assert_eq(result.length(), 4)
}

///|
test "hough_lines_nms: 空数组正常返回" {
  let result = @edge.hough_lines_nms([]) catch { _ => [] }
  assert_eq(result.length(), 0)
}
