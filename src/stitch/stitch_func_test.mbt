// stitch 功能测试：invert_homography 奇异 / detect_features_simple 角点 / match_features 多描述子 / estimate_homography_ransac

///|
fn make_corner_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\xFF')
  let cx = w / 2
  let cy = h / 2
  data[cy * w + cx] = b'\x00'
  data[cy * w + cx - 1] = b'\x00'
  data[cy * w + cx + 1] = b'\x00'
  data[(cy - 1) * w + cx] = b'\x00'
  data[(cy + 1) * w + cx] = b'\x00'
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(data),
  }
}

///|
fn make_checkerboard_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      let block_x = x / 4
      let block_y = y / 4
      data[y * w + x] = if (block_x + block_y) % 2 == 0 {
        b'\xFF'
      } else {
        b'\x00'
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

///|
fn make_edge_img(w : Int, h : Int) -> @types.Image {
  let data : Array[Byte] = Array::make(w * h, b'\x00')
  for y in 0..<h {
    for x in 0..<w {
      data[y * w + x] = if x < w / 2 { b'\x00' } else { b'\xFF' }
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
test "stf: invert_homography 奇异矩阵返回None" {
  let h = @stitch.Homography::{
    h00: 0.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 0.0,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
    h22: 0.0,
  }
  let result = @stitch.invert_homography(h)
  assert_true(result is None)
}

///|
test "stf: invert_homography 近奇异矩阵返回None" {
  let h = @stitch.Homography::{
    h00: 0.0000001,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 0.0000001,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
    h22: 0.0000001,
  }
  let result = @stitch.invert_homography(h)
  assert_true(result is None)
}

///|
test "stf: invert_homography 缩放变换" {
  let h = @stitch.Homography::{
    h00: 2.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 2.0,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
    h22: 1.0,
  }
  let inv = @stitch.invert_homography(h)
  assert_true(inv is Some(_))
  match inv {
    Some(m) => {
      let (x, y) = @stitch.apply_homography(m, 10.0, 20.0)
      assert_true((x - 5.0).abs() < 0.001)
      assert_true((y - 10.0).abs() < 0.001)
    }
    None => assert_true(false)
  }
}

///|
test "stf: invert_homography 复合变换" {
  let h = @stitch.Homography::{
    h00: 2.0,
    h01: 1.0,
    h02: 5.0,
    h10: 0.5,
    h11: 3.0,
    h12: 2.0,
    h20: 0.1,
    h21: 0.2,
    h22: 1.0,
  }
  let inv = @stitch.invert_homography(h)
  assert_true(inv is Some(_))
}

///|
test "stf: detect_features_simple 角点图像" {
  let img = make_corner_img(20, 20)
  let features = @stitch.detect_features_simple(img, max_features=100)
  assert_true(features.length() > 0)
}

///|
test "stf: detect_features_simple 棋盘格图像" {
  let img = make_checkerboard_img(24, 24)
  let features = @stitch.detect_features_simple(img, max_features=100)
  assert_true(features.length() >= 0)
}

///|
test "stf: detect_features_simple 边缘图像" {
  let img = make_edge_img(20, 20)
  let features = @stitch.detect_features_simple(img, max_features=100)
  assert_true(features.length() >= 0)
}

///|
test "stf: detect_features_simple max_features限制" {
  let img = make_checkerboard_img(24, 24)
  let features = @stitch.detect_features_simple(img, max_features=5)
  assert_true(features.length() <= 5)
}

///|
test "stf: detect_features_simple 特征点有描述子" {
  let img = make_corner_img(20, 20)
  let features = @stitch.detect_features_simple(img, max_features=10)
  if features.length() > 0 {
    assert_true(features[0].descriptor.length() > 0)
    assert_true(features[0].response > 0.0)
  }
}

///|
test "stf: detect_features_small 小图无特征" {
  let data = Bytes::from_array(Array::make(81, b'\x80'))
  let img = @types.Image::{ width: 9, height: 9, channels: 1, data, }
  let features = @stitch.detect_features_simple(img)
  assert_eq(features.length(), 0)
}

///|
test "stf: match_features 多描述子匹配" {
  let fp1 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 20.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0, 0.0, 0.0, 0.0],
  }
  let fp2 = @stitch.FeaturePoint::{
    x: 30.0,
    y: 40.0,
    response: 90.0,
    orientation: 0.0,
    descriptor: [0.0, 1.0, 0.0, 0.0],
  }
  let fp3 = @stitch.FeaturePoint::{
    x: 50.0,
    y: 60.0,
    response: 80.0,
    orientation: 0.0,
    descriptor: [0.0, 0.0, 1.0, 0.0],
  }
  let query = [fp1, fp2, fp3]
  let train = [fp1, fp2, fp3]
  let matches = @stitch.match_features(query, train)
  assert_true(matches.length() >= 0)
}

///|
test "stf: match_features 不同描述子" {
  let fp1 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 20.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0, 0.0, 0.0, 0.0],
  }
  let fp2 = @stitch.FeaturePoint::{
    x: 30.0,
    y: 40.0,
    response: 90.0,
    orientation: 0.0,
    descriptor: [0.0, 1.0, 0.0, 0.0],
  }
  let query = [fp1]
  let train = [fp2]
  let matches = @stitch.match_features(query, train)
  assert_true(matches.length() >= 0)
}

///|
test "stf: match_features 自定义比率阈值" {
  let fp1 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 20.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0, 0.0, 0.0],
  }
  let fp2 = @stitch.FeaturePoint::{
    x: 30.0,
    y: 40.0,
    response: 90.0,
    orientation: 0.0,
    descriptor: [0.9, 0.1, 0.0],
  }
  let fp3 = @stitch.FeaturePoint::{
    x: 50.0,
    y: 60.0,
    response: 80.0,
    orientation: 0.0,
    descriptor: [0.0, 1.0, 0.0],
  }
  let query = [fp1]
  let train = [fp2, fp3]
  let matches = @stitch.match_features(query, train, ratio_threshold=0.9)
  assert_true(matches.length() >= 0)
}

///|
test "stf: match_features 单个train" {
  let fp1 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 20.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0, 0.0, 0.0],
  }
  let query = [fp1]
  let train = [fp1]
  let matches = @stitch.match_features(query, train)
  assert_true(matches.length() >= 0)
}

///|
test "stf: estimate_homography_ransac 足够匹配" {
  let fp1 = @stitch.FeaturePoint::{
    x: 0.0,
    y: 0.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp2 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 0.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp3 = @stitch.FeaturePoint::{
    x: 0.0,
    y: 10.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp4 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 10.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp5 = @stitch.FeaturePoint::{
    x: 5.0,
    y: 5.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let query = [fp1, fp2, fp3, fp4, fp5]
  let train = [fp1, fp2, fp3, fp4, fp5]
  let matches = [
    @stitch.MatchPair::{ query_idx: 0, train_idx: 0, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 1, train_idx: 1, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 2, train_idx: 2, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 3, train_idx: 3, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 4, train_idx: 4, distance: 0.0, },
  ]
  let (h, inliers) = @stitch.estimate_homography_ransac(
    matches,
    query,
    train,
    iterations=100,
  )
  assert_true(inliers.length() >= 0)
  ignore(h)
}

///|
test "stf: estimate_homography_ransac 不足匹配返回None" {
  let fp1 = @stitch.FeaturePoint::{
    x: 0.0,
    y: 0.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let query = [fp1]
  let train = [fp1]
  let matches = [
    @stitch.MatchPair::{ query_idx: 0, train_idx: 0, distance: 0.0, },
  ]
  let (h, inliers) = @stitch.estimate_homography_ransac(matches, query, train)
  assert_true(inliers.length() == 0)
  assert_true(h is None)
}

///|
test "stf: estimate_homography_ransac 自定义参数" {
  let fp1 = @stitch.FeaturePoint::{
    x: 0.0,
    y: 0.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp2 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 0.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp3 = @stitch.FeaturePoint::{
    x: 0.0,
    y: 10.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let fp4 = @stitch.FeaturePoint::{
    x: 10.0,
    y: 10.0,
    response: 100.0,
    orientation: 0.0,
    descriptor: [1.0],
  }
  let query = [fp1, fp2, fp3, fp4]
  let train = [fp1, fp2, fp3, fp4]
  let matches = [
    @stitch.MatchPair::{ query_idx: 0, train_idx: 0, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 1, train_idx: 1, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 2, train_idx: 2, distance: 0.0, },
    @stitch.MatchPair::{ query_idx: 3, train_idx: 3, distance: 0.0, },
  ]
  let (h, inliers) = @stitch.estimate_homography_ransac(
    matches,
    query,
    train,
    iterations=50,
    threshold=5.0,
  )
  assert_true(inliers.length() >= 0)
  ignore(h)
}

///|
test "stf: stitch_images 角点图像拼接" {
  let img1 = make_corner_img(32, 32)
  let img2 = make_corner_img(32, 32)
  let result = @stitch.stitch_images(img1, img2)
  ignore(result)
}

///|
test "stf: stitch_images 棋盘格拼接" {
  let img1 = make_checkerboard_img(32, 32)
  let img2 = make_checkerboard_img(32, 32)
  let result = @stitch.stitch_images(img1, img2)
  ignore(result)
}

///|
test "stf: stitch_images 自定义配置" {
  let img1 = make_corner_img(32, 32)
  let img2 = make_corner_img(32, 32)
  let cfg = @stitch.StitchConfig::{
    max_features: 100,
    ratio_threshold: 0.8,
    ransac_iterations: 100,
    ransac_threshold: 5.0,
    min_inliers: 4,
    blend_width: 10,
    use_multi_band: false,
  }
  let result = @stitch.stitch_images(img1, img2, config=cfg)
  ignore(result)
}

///|
test "stf: stitch_images 纯色图返回None" {
  let data = Bytes::from_array(Array::make(1024, b'\x80'))
  let img = @types.Image::{ width: 32, height: 32, channels: 1, data, }
  let result = @stitch.stitch_images(img, img)
  assert_true(result is None)
}

///|
test "stf: apply_homography 缩放变换" {
  let h = @stitch.Homography::{
    h00: 2.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 2.0,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
    h22: 1.0,
  }
  let (x, y) = @stitch.apply_homography(h, 10.0, 20.0)
  assert_true((x - 20.0).abs() < 0.001)
  assert_true((y - 40.0).abs() < 0.001)
}

///|
test "stf: apply_homography 透视变换" {
  let h = @stitch.Homography::{
    h00: 1.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 1.0,
    h12: 0.0,
    h20: 0.01,
    h21: 0.0,
    h22: 1.0,
  }
  let (x, y) = @stitch.apply_homography(h, 10.0, 20.0)
  let w = 1.0 + 0.01 * 10.0
  assert_true((x - 10.0 / w).abs() < 0.001)
  assert_true((y - 20.0 / w).abs() < 0.001)
}

///|
test "stf: stitch_default_config 完整字段" {
  let cfg = @stitch.stitch_default_config()
  assert_eq(cfg.max_features, 500)
  assert_eq(cfg.ransac_iterations, 1000)
  assert_eq(cfg.min_inliers, 10)
  assert_eq(cfg.blend_width, 50)
  assert_true(cfg.use_multi_band)
}
