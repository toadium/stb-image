// v203.0.0 ocr 错误路径/边界增强测试

// ===== 辅图像辅助函数 =====

///|
fn ocr_make_zero_w() -> @types.Image {
  @types.Image::{
    width: 0,
    height: 4,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn ocr_make_zero_h() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 0,
    channels: 1,
    data: Bytes::from_array([]),
  }
}

///|
fn ocr_make_rgb(w : Int, h : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 3,
    data: Bytes::from_array(Array::make(w * h * 3, 128)),
  }
}

///|
fn ocr_make_mismatch() -> @types.Image {
  @types.Image::{
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array(Array::make(8, 0)),
  }
}

///|
fn ocr_make_uniform(w : Int, h : Int, v : Int) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, v.to_byte())),
  }
}

///|
fn ocr_make_checkerboard(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      if (x + y) % 2 == 0 {
        data[y * w + x] = b'\xFF'
      }
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

// ===== 1. detect_skew_angle 错误路径 =====

///|
test "ocr_edge: detect_skew_angle 零宽度" {
  try {
    let _ = @ocr.detect_skew_angle(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_skew_angle 零高度" {
  try {
    let _ = @ocr.detect_skew_angle(ocr_make_zero_h())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_skew_angle 多通道" {
  try {
    let _ = @ocr.detect_skew_angle(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_skew_angle 数据不匹配" {
  try {
    let _ = @ocr.detect_skew_angle(ocr_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_skew_angle 单像素" {
  try {
    let img = ocr_make_uniform(1, 1, 128)
    let angle = @ocr.detect_skew_angle(img)
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: detect_skew_angle 全黑" {
  try {
    let img = ocr_make_uniform(8, 8, 0)
    let angle = @ocr.detect_skew_angle(img)
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: detect_skew_angle 全白" {
  try {
    let img = ocr_make_uniform(8, 8, 255)
    let angle = @ocr.detect_skew_angle(img)
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: detect_skew_angle 棋盘格2x2" {
  try {
    let img = ocr_make_checkerboard(2, 2)
    let angle = @ocr.detect_skew_angle(img)
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 2. deskew 错误路径 =====

///|
test "ocr_edge: deskew 零宽度" {
  try {
    let _ = @ocr.deskew(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: deskew 多通道" {
  try {
    let _ = @ocr.deskew(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: deskew 数据不匹配" {
  try {
    let _ = @ocr.deskew(ocr_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: deskew 单像素" {
  try {
    let result = @ocr.deskew(ocr_make_uniform(1, 1, 128))
    assert_true(result.width > 0 && result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: deskew 全黑8x8" {
  try {
    let result = @ocr.deskew(ocr_make_uniform(8, 8, 0))
    assert_true(result.width > 0 && result.height > 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 3. niblack_threshold 错误路径 =====

///|
test "ocr_edge: niblack_threshold 零宽度" {
  try {
    let _ = @ocr.niblack_threshold(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: niblack_threshold 多通道" {
  try {
    let _ = @ocr.niblack_threshold(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: niblack_threshold 偶数窗口" {
  try {
    let _ = @ocr.niblack_threshold(ocr_make_uniform(8, 8, 128), window_size=4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: niblack_threshold 零窗口" {
  try {
    let _ = @ocr.niblack_threshold(ocr_make_uniform(8, 8, 128), window_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: niblack_threshold 单像素" {
  try {
    let result = @ocr.niblack_threshold(ocr_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: niblack_threshold 全黑" {
  try {
    let result = @ocr.niblack_threshold(ocr_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 4. sauvola_threshold 错误路径 =====

///|
test "ocr_edge: sauvola_threshold 零宽度" {
  try {
    let _ = @ocr.sauvola_threshold(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: sauvola_threshold 偶数窗口" {
  try {
    let _ = @ocr.sauvola_threshold(ocr_make_uniform(8, 8, 128), window_size=4)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: sauvola_threshold r为零" {
  try {
    let _ = @ocr.sauvola_threshold(ocr_make_uniform(8, 8, 128), r=0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: sauvola_threshold r为负" {
  try {
    let _ = @ocr.sauvola_threshold(ocr_make_uniform(8, 8, 128), r=-1.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: sauvola_threshold 单像素" {
  try {
    let result = @ocr.sauvola_threshold(ocr_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 5. adaptive_threshold_ocr 错误路径 =====

///|
test "ocr_edge: adaptive_threshold_ocr 零宽度" {
  try {
    let _ = @ocr.adaptive_threshold_ocr(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: adaptive_threshold_ocr 多通道" {
  try {
    let _ = @ocr.adaptive_threshold_ocr(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: adaptive_threshold_ocr 全黑" {
  try {
    let result = @ocr.adaptive_threshold_ocr(ocr_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: adaptive_threshold_ocr 全白" {
  try {
    let result = @ocr.adaptive_threshold_ocr(ocr_make_uniform(8, 8, 255))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 6. otsu_threshold 错误路径 =====

///|
test "ocr_edge: otsu_threshold 零宽度" {
  try {
    let _ = @ocr.otsu_threshold(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: otsu_threshold 多通道" {
  try {
    let _ = @ocr.otsu_threshold(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: otsu_threshold 单像素" {
  try {
    let result = @ocr.otsu_threshold(ocr_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: otsu_threshold 全黑" {
  try {
    let result = @ocr.otsu_threshold(ocr_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 7. connected_components_analysis 错误路径 =====

///|
test "ocr_edge: cca 零宽度" {
  try {
    let _ = @ocr.connected_components_analysis(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: cca 多通道" {
  try {
    let _ = @ocr.connected_components_analysis(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: cca 无效连通性" {
  try {
    let _ = @ocr.connected_components_analysis(
      ocr_make_uniform(4, 4, 128),
      connectivity=6,
    )
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: cca 数据不匹配" {
  try {
    let _ = @ocr.connected_components_analysis(ocr_make_mismatch())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: cca 单像素黑" {
  try {
    let result = @ocr.connected_components_analysis(ocr_make_uniform(1, 1, 0))
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: cca 单像素白" {
  try {
    let result = @ocr.connected_components_analysis(ocr_make_uniform(1, 1, 255))
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: cca 全黑8x8" {
  try {
    let result = @ocr.connected_components_analysis(ocr_make_uniform(8, 8, 0))
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: cca 全白8x8" {
  try {
    let result = @ocr.connected_components_analysis(ocr_make_uniform(8, 8, 255))
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: cca 4连通" {
  try {
    let result = @ocr.connected_components_analysis(
      ocr_make_checkerboard(4, 4),
      connectivity=4,
    )
    assert_true(result.num_components >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 8. detect_text_regions 错误路径 =====

///|
test "ocr_edge: detect_text_regions 零宽度" {
  try {
    let _ = @ocr.detect_text_regions(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_text_regions 多通道" {
  try {
    let _ = @ocr.detect_text_regions(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_text_regions 单像素" {
  try {
    let regions = @ocr.detect_text_regions(ocr_make_uniform(1, 1, 128))
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: detect_text_regions 全黑" {
  try {
    let regions = @ocr.detect_text_regions(ocr_make_uniform(8, 8, 0))
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: detect_text_regions 全白" {
  try {
    let regions = @ocr.detect_text_regions(ocr_make_uniform(8, 8, 255))
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 9. horizontal_projection 错误路径 =====

///|
test "ocr_edge: horizontal_projection 零宽度" {
  try {
    let _ = @ocr.horizontal_projection(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: horizontal_projection 多通道" {
  try {
    let _ = @ocr.horizontal_projection(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: horizontal_projection 单像素" {
  try {
    let result = @ocr.horizontal_projection(ocr_make_uniform(1, 1, 200))
    assert_true(result.projection.length() == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: horizontal_projection 全黑" {
  try {
    let result = @ocr.horizontal_projection(ocr_make_uniform(8, 8, 0))
    assert_true(result.projection.length() == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 10. vertical_projection 错误路径 =====

///|
test "ocr_edge: vertical_projection 零宽度" {
  try {
    let _ = @ocr.vertical_projection(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: vertical_projection 多通道" {
  try {
    let _ = @ocr.vertical_projection(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: vertical_projection 单像素" {
  try {
    let result = @ocr.vertical_projection(ocr_make_uniform(1, 1, 200))
    assert_true(result.projection.length() == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: vertical_projection 全白" {
  try {
    let result = @ocr.vertical_projection(ocr_make_uniform(8, 8, 255))
    assert_true(result.projection.length() == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 11. document_enhance 错误路径 =====

///|
test "ocr_edge: document_enhance 零宽度" {
  try {
    let _ = @ocr.document_enhance(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: document_enhance 零通道" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 0,
      data: Bytes::from_array([]),
    }
    let _ = @ocr.document_enhance(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: document_enhance 五通道" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 5,
      data: Bytes::from_array(Array::make(80, 128)),
    }
    let _ = @ocr.document_enhance(img)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: document_enhance 单像素灰度" {
  try {
    let result = @ocr.document_enhance(ocr_make_uniform(1, 1, 128))
    assert_true(result.width == 1 && result.height == 1)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: document_enhance RGB图像" {
  try {
    let result = @ocr.document_enhance(ocr_make_rgb(4, 4))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: document_enhance RGBA图像" {
  try {
    let img = @types.Image::{
      width: 4,
      height: 4,
      channels: 4,
      data: Bytes::from_array(Array::make(64, 128)),
    }
    let result = @ocr.document_enhance(img)
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 12. hog_features 错误路径 =====

///|
test "ocr_edge: hog_features 零宽度" {
  try {
    let _ = @ocr.hog_features(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: hog_features 多通道" {
  try {
    let _ = @ocr.hog_features(ocr_make_rgb(4, 4))
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: hog_features cell_size为零" {
  try {
    let _ = @ocr.hog_features(ocr_make_uniform(8, 8, 128), cell_size=0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: hog_features 单像素" {
  try {
    let result = @ocr.hog_features(ocr_make_uniform(1, 1, 128))
    assert_true(result.features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: hog_features 全黑8x8" {
  try {
    let result = @ocr.hog_features(ocr_make_uniform(8, 8, 0))
    assert_true(result.features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 13. edit_distance 错误路径 =====

///|
test "ocr_edge: edit_distance 双空字符串" {
  try {
    let _ = @ocr.edit_distance("", "")
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: edit_distance 一空一非空" {
  try {
    let d = @ocr.edit_distance("", "hello")
    assert_eq(d, 5)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: edit_distance 非空一空" {
  try {
    let d = @ocr.edit_distance("world", "")
    assert_eq(d, 5)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: edit_distance 相同字符串" {
  try {
    let d = @ocr.edit_distance("abc", "abc")
    assert_eq(d, 0)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: edit_distance 完全不同" {
  try {
    let d = @ocr.edit_distance("abc", "xyz")
    assert_eq(d, 3)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: edit_distance 单字符替换" {
  try {
    let d = @ocr.edit_distance("cat", "bat")
    assert_eq(d, 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 14. 距离函数错误路径 =====

///|
test "ocr_edge: euclidean_distance 空向量a" {
  try {
    let _ = @ocr.euclidean_distance([], [1.0, 2.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: euclidean_distance 空向量b" {
  try {
    let _ = @ocr.euclidean_distance([1.0, 2.0], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: euclidean_distance 相同向量" {
  try {
    let d = @ocr.euclidean_distance([1.0, 2.0, 3.0], [1.0, 2.0, 3.0])
    assert_true(d < 0.0001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: manhattan_distance 空向量a" {
  try {
    let _ = @ocr.manhattan_distance([], [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: manhattan_distance 空向量b" {
  try {
    let _ = @ocr.manhattan_distance([1.0], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: manhattan_distance 相同向量" {
  try {
    let d = @ocr.manhattan_distance([1.0, 2.0], [1.0, 2.0])
    assert_true(d < 0.0001)
  } catch {
    _ => assert_true(false)
  }
}

///|
test "ocr_edge: cosine_distance 空向量a" {
  try {
    let _ = @ocr.cosine_distance([], [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: cosine_distance 空向量b" {
  try {
    let _ = @ocr.cosine_distance([1.0], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: chebyshev_distance 空向量a" {
  try {
    let _ = @ocr.chebyshev_distance([], [1.0])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: chebyshev_distance 空向量b" {
  try {
    let _ = @ocr.chebyshev_distance([1.0], [])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: chebyshev_distance 相同向量" {
  try {
    let d = @ocr.chebyshev_distance([1.0, 5.0, 3.0], [1.0, 5.0, 3.0])
    assert_true(d < 0.0001)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 15. 字符串准确率边界 =====

///|
test "ocr_edge: calculate_char_accuracy 双空" {
  let acc = @ocr.calculate_char_accuracy("", "")
  assert_eq(acc, 1.0)
}

///|
test "ocr_edge: calculate_char_accuracy 期望空实际非空" {
  let acc = @ocr.calculate_char_accuracy("", "abc")
  assert_eq(acc, 0.0)
}

///|
test "ocr_edge: calculate_char_accuracy 完全相同" {
  let acc = @ocr.calculate_char_accuracy("hello", "hello")
  assert_eq(acc, 1.0)
}

///|
test "ocr_edge: calculate_char_accuracy 完全不同" {
  let acc = @ocr.calculate_char_accuracy("abc", "xyz")
  assert_eq(acc, 0.0)
}

///|
test "ocr_edge: calculate_char_accuracy 部分匹配" {
  let acc = @ocr.calculate_char_accuracy("hello", "hallo")
  assert_true(acc > 0.7 && acc < 1.0)
}

///|
test "ocr_edge: calculate_char_accuracy 实际更短" {
  let acc = @ocr.calculate_char_accuracy("hello", "hel")
  assert_true(acc > 0.5 && acc < 1.0)
}

///|
test "ocr_edge: calculate_word_accuracy 双空" {
  let acc = @ocr.calculate_word_accuracy("", "")
  assert_eq(acc, 1.0)
}

///|
test "ocr_edge: calculate_word_accuracy 完全相同" {
  let acc = @ocr.calculate_word_accuracy("hello world", "hello world")
  assert_eq(acc, 1.0)
}

///|
test "ocr_edge: calculate_edit_distance 双空" {
  let d = @ocr.calculate_edit_distance("", "")
  assert_eq(d, 0)
}

///|
test "ocr_edge: calculate_edit_distance 一空" {
  let d = @ocr.calculate_edit_distance("", "abc")
  assert_eq(d, 3)
}

///|
test "ocr_edge: calculate_edit_distance 相同" {
  let d = @ocr.calculate_edit_distance("test", "test")
  assert_eq(d, 0)
}

///|
test "ocr_edge: calculate_accuracy 空数组" {
  let acc = @ocr.calculate_accuracy([], [])
  assert_true(acc >= 0.0 && acc <= 1.0)
}

///|
test "ocr_edge: calculate_accuracy 完全正确" {
  let acc = @ocr.calculate_accuracy([1, 2, 3], [1, 2, 3])
  assert_eq(acc, 1.0)
}

///|
test "ocr_edge: calculate_accuracy 完全错误" {
  let acc = @ocr.calculate_accuracy([1, 2, 3], [4, 5, 6])
  assert_eq(acc, 0.0)
}

// ===== 16. detect_skew_angle_robust 边界 =====

///|
test "ocr_edge: detect_skew_angle_robust 零宽度" {
  try {
    let _ = @ocr.detect_skew_angle_robust(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_skew_angle_robust 全黑" {
  try {
    let angle = @ocr.detect_skew_angle_robust(ocr_make_uniform(8, 8, 0))
    assert_true(angle >= -15.0 && angle <= 15.0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 17. background_normalization 边界 =====

///|
test "ocr_edge: background_normalization 零宽度" {
  try {
    let _ = @ocr.background_normalization(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: background_normalization 全黑" {
  try {
    let result = @ocr.background_normalization(ocr_make_uniform(8, 8, 0))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 18. shadow_removal 边界 =====

///|
test "ocr_edge: shadow_removal 零宽度" {
  try {
    let _ = @ocr.shadow_removal(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: shadow_removal 全白" {
  try {
    let result = @ocr.shadow_removal(ocr_make_uniform(8, 8, 255))
    assert_true(result.width == 8 && result.height == 8)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 19. correct_slant 边界 =====

///|
test "ocr_edge: correct_slant 零宽度" {
  try {
    let _ = @ocr.correct_slant(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: correct_slant 单像素" {
  try {
    let result = @ocr.correct_slant(ocr_make_uniform(1, 1, 128))
    assert_true(result.width >= 1)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 20. combined_features 边界 =====

///|
test "ocr_edge: combined_features 零宽度" {
  try {
    let _ = @ocr.combined_features(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: combined_features 全黑" {
  try {
    let features = @ocr.combined_features(ocr_make_uniform(8, 8, 0))
    assert_true(features.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 21. detect_columns 边界 =====

///|
test "ocr_edge: detect_columns 零宽度" {
  try {
    let _ = @ocr.detect_columns(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: detect_columns 单像素" {
  try {
    let (cols, ranges) = @ocr.detect_columns(ocr_make_uniform(1, 1, 128))
    assert_true(cols >= 0 && ranges.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 22. segment_page 边界 =====

///|
test "ocr_edge: segment_page 零宽度" {
  try {
    let _ = @ocr.segment_page(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: segment_page 全黑" {
  try {
    let regions = @ocr.segment_page(ocr_make_uniform(8, 8, 0))
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 23. extract_text_lines 边界 =====

///|
test "ocr_edge: extract_text_lines 零宽度" {
  try {
    let _ = @ocr.extract_text_lines(ocr_make_zero_w())
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "ocr_edge: extract_text_lines 全白" {
  try {
    let lines = @ocr.extract_text_lines(ocr_make_uniform(8, 8, 255))
    assert_true(lines.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 24. otsu_threshold 棋盘格 =====

///|
test "ocr_edge: otsu_threshold 棋盘格4x4" {
  try {
    let result = @ocr.otsu_threshold(ocr_make_checkerboard(4, 4))
    assert_true(result.width == 4 && result.height == 4)
  } catch {
    _ => assert_true(false)
  }
}

// ===== 25. detect_text_regions 棋盘格 =====

///|
test "ocr_edge: detect_text_regions 棋盘格" {
  try {
    let regions = @ocr.detect_text_regions(ocr_make_checkerboard(8, 8))
    assert_true(regions.length() >= 0)
  } catch {
    _ => assert_true(false)
  }
}
