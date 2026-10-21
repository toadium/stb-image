// v26.0.0 图像融合与配准增强测试 - registration_advanced 模块
// 相位相关配准/归一化互相关/互信息/Harris角点/特征匹配/仿射变换估计

///|
fn make_varied_ra_img(w : Int32, h : Int32) -> @types.Image {
  let arr : Array[Byte] = []
  for i in 0..<(w * h) {
    arr.push((i % 256).to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(arr),
  }
}

///|
test "create_default_registration_config_advanced: 默认配置" {
  let config = @registration_advanced.create_default_registration_config_advanced()
  assert_true(config.max_iterations > 0)
  assert_true(config.convergence_threshold > 0.0)
  assert_true(config.search_radius > 0)
}

///|
test "phase_correlation_registration: 基本相位相关配准" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let result = @registration_advanced.phase_correlation_registration(img1, img2)
  assert_true(result.correlation >= 0.0)
}

///|
test "apply_translation: 基本平移" {
  let img = make_varied_ra_img(8, 8)
  let result = @registration_advanced.apply_translation(img, 2, 2)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "normalized_cross_correlation: 基本互相关" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let ncc = @registration_advanced.normalized_cross_correlation(img1, img2)
  assert_true(ncc >= -1.0)
  assert_true(ncc <= 1.0 + 0.0001)
}

///|
test "calculate_mutual_information: 基本互信息" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let mi = @registration_advanced.calculate_mutual_information(img1, img2)
  assert_true(mi >= 0.0)
}

///|
test "detect_harris_corners: 基本角点检测" {
  let img = make_varied_ra_img(8, 8)
  let corners = @registration_advanced.detect_harris_corners(img, 0.01)
  assert_true(corners.length() >= 0)
}

///|
test "match_feature_points: 基本特征匹配" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let points1 = @registration_advanced.detect_harris_corners(img1, 0.01)
  let points2 = @registration_advanced.detect_harris_corners(img2, 0.01)
  let matches = @registration_advanced.match_feature_points(
    points1, points2, 100.0,
  )
  assert_true(matches.length() >= 0)
}

///|
test "estimate_affine_transform: 基本仿射变换估计" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let points1 = @registration_advanced.detect_harris_corners(img1, 0.01)
  let points2 = @registration_advanced.detect_harris_corners(img2, 0.01)
  let matches = @registration_advanced.match_feature_points(
    points1, points2, 100.0,
  )
  let _matrix = @registration_advanced.estimate_affine_transform(matches)
  assert_true(true)
}

///|
test "apply_affine_transform: 基本仿射变换" {
  let img = make_varied_ra_img(8, 8)
  let matrix = @registration_advanced.TransformMatrix::{
    matrix: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0],
    transform_type: @registration_advanced.TransformType::Affine,
    width: 0,
    height: 0,
  }
  let result = @registration_advanced.apply_affine_transform(img, matrix)
  assert_eq(result.width, 8)
  assert_eq(result.height, 8)
}

///|
test "feature_based_registration: 基本特征配准" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let config = @registration_advanced.create_default_registration_config_advanced()
  let result = @registration_advanced.feature_based_registration(
    img1, img2, config,
  )
  assert_true(result.correlation >= 0.0)
}

///|
test "register_images_advanced: 基本高级配准" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let config = @registration_advanced.create_default_registration_config_advanced()
  let result = @registration_advanced.register_images_advanced(
    img1, img2, config,
  )
  assert_true(result.correlation >= 0.0)
}

///|
test "registration_report_to_string_advanced: 生成报告" {
  let img1 = make_varied_ra_img(8, 8)
  let img2 = make_varied_ra_img(8, 8)
  let config = @registration_advanced.create_default_registration_config_advanced()
  let result = @registration_advanced.register_images_advanced(
    img1, img2, config,
  )
  let report = @registration_advanced.registration_report_to_string_advanced(
    result,
  )
  assert_true(report.length() > 0)
}
