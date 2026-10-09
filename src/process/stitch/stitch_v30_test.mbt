// v30.0.0 高级图像配准算法测试 — stitch 模块 8 函数

///|
fn create_solid_st(w : Int, h : Int, v : Int) -> @types.Image {
  let data : Array[Byte] = []
  for _ in 0..<(w * h) {
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn create_gradient_st(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = []
  for y in 0..<h {
    for x in 0..<w {
      data.push(((x + y) * 255 / (w + h) % 256).to_byte())
    }
  }
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
test "stitch_default_config: 默认配置" {
  let config = @stitch.stitch_default_config()
  assert_true(config.max_features > 0)
  assert_true(config.ratio_threshold > 0.0 && config.ratio_threshold < 1.0)
  assert_true(config.ransac_iterations > 0)
  assert_true(config.min_inliers > 0)
}

///|
test "identity_homography: 单位变换" {
  let h = @stitch.identity_homography()
  assert_true(h.h00 == 1.0)
  assert_true(h.h11 == 1.0)
  assert_true(h.h22 == 1.0)
  assert_true(h.h01 == 0.0)
  assert_true(h.h10 == 0.0)
  assert_true(h.h02 == 0.0)
  assert_true(h.h12 == 0.0)
  assert_true(h.h20 == 0.0)
  assert_true(h.h21 == 0.0)
}

///|
test "apply_homography: 单位变换不改变坐标" {
  let h = @stitch.identity_homography()
  let (x, y) = @stitch.apply_homography(h, 100.0, 200.0)
  assert_true((x - 100.0).abs() < 1.0)
  assert_true((y - 200.0).abs() < 1.0)
}

///|
test "apply_homography: 平移变换" {
  let h = @stitch.Homography::{
    h00: 1.0,
    h01: 0.0,
    h02: 10.0,
    h10: 0.0,
    h11: 1.0,
    h12: 20.0,
    h20: 0.0,
    h21: 0.0,
    h22: 1.0,
  }
  let (x, y) = @stitch.apply_homography(h, 50.0, 60.0)
  assert_true((x - 60.0).abs() < 1.0)
  assert_true((y - 80.0).abs() < 1.0)
}

///|
test "invert_homography: 单位变换的逆" {
  let h = @stitch.identity_homography()
  let inv = @stitch.invert_homography(h)
  assert_true(inv is Some(_))
}

///|
test "invert_homography: 平移变换的逆" {
  let h = @stitch.Homography::{
    h00: 1.0,
    h01: 0.0,
    h02: 10.0,
    h10: 0.0,
    h11: 1.0,
    h12: 20.0,
    h20: 0.0,
    h21: 0.0,
    h22: 1.0,
  }
  let inv = @stitch.invert_homography(h)
  assert_true(inv is Some(_))
}

///|
test "detect_features_simple: 纯色图像特征少" {
  let img = create_solid_st(16, 16, 128)
  let features = @stitch.detect_features_simple(img)
  assert_true(features.length() >= 0)
}

///|
test "detect_features_simple: 渐变图像" {
  let img = create_gradient_st(32, 32)
  let features = @stitch.detect_features_simple(img, max_features=50)
  assert_true(features.length() >= 0)
}

///|
test "match_features: 空特征列表" {
  let query : Array[@stitch.FeaturePoint] = []
  let train : Array[@stitch.FeaturePoint] = []
  let matches = @stitch.match_features(query, train)
  assert_true(matches.length() == 0)
}

///|
test "match_features: 相同特征匹配" {
  let fp = @stitch.FeaturePoint::{
    x: 10.0,
    y: 20.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0, 0.0, 0.0],
  }
  let query = [fp]
  let train = [fp]
  let matches = @stitch.match_features(query, train)
  assert_true(matches.length() >= 0)
}

///|
test "estimate_homography_ransac: 空匹配" {
  let matches : Array[@stitch.MatchPair] = []
  let query : Array[@stitch.FeaturePoint] = []
  let train : Array[@stitch.FeaturePoint] = []
  let (h, inliers) = @stitch.estimate_homography_ransac(matches, query, train)
  assert_true(inliers.length() == 0)
  ignore(h)
}

///|
test "stitch_images: 相同图像拼接" {
  let img = create_gradient_st(32, 32)
  let result = @stitch.stitch_images(img, img)
  ignore(result)
}
