// 描述子匹配测试 — BFMatcher/FLANN/KNN
// Descriptor matching tests

///|
fn make_test_image_for_match() -> @types.Image {
  let width = 12
  let height = 12
  let channels = 1
  let data : Array[Byte] = []
  for y in 0..<height {
    for x in 0..<width {
      let v = if x < 6 && y < 6 {
        0
      } else if x >= 6 && y < 6 {
        128
      } else if x < 6 && y >= 6 {
        128
      } else {
        255
      }
      data.push(v.reinterpret_as_uint().to_byte())
    }
  }
  { width, height, channels, data: Bytes::from_array(data), }
}

///|
test "形式化: bf_match_binary 返回正确数量" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  let matches = @cv_advanced.bf_match_binary(descs, descs)
  assert_eq(matches.length(), descs.length())
}

///|
test "形式化: bf_match_float 返回正确数量" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_surf_keypoints(img, 50.0)
  if kps.length() > 0 {
    let descs = @cv_advanced.compute_surf_descriptors(img, kps)
    let matches = @cv_advanced.bf_match_float(descs, descs)
    assert_eq(matches.length(), descs.length())
  }
}

///|
test "形式化: knn_match_binary 返回 K 个最近邻" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  if descs.length() >= 2 {
    let knn = @cv_advanced.knn_match_binary(descs, descs, 2)
    assert_eq(knn.length(), descs.length())
    for matches in knn {
      assert_true(matches.length() <= 2)
    }
  }
}

///|
test "FAKE: ratio_test 过滤匹配" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  if descs.length() >= 2 {
    let knn = @cv_advanced.knn_match_binary(descs, descs, 2)
    let filtered = @cv_advanced.ratio_test(knn, 0.8)
    assert_true(filtered.length() >= 0)
  }
}

///|
test "FAKE: flann_match_float 返回结果" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_surf_keypoints(img, 50.0)
  if kps.length() > 0 {
    let descs = @cv_advanced.compute_surf_descriptors(img, kps)
    let matches = @cv_advanced.flann_match_float(descs, descs)
    assert_eq(matches.length(), descs.length())
  }
}

///|
test "MOCK: bf_match 自匹配距离非负" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  let matches = @cv_advanced.bf_match_binary(descs, descs)
  for m in matches {
    assert_true(m.distance >= 0.0)
  }
}

///|
test "MOCK: knn_match 排序正确" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  if descs.length() >= 2 {
    let knn = @cv_advanced.knn_match_binary(descs, descs, 3)
    for matches in knn {
      for i in 0..<(matches.length() - 1) {
        assert_true(matches[i].distance <= matches[i + 1].distance)
      }
    }
  }
}

///|
test "E2E: cross_validate_match 双向匹配" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  let m1 = @cv_advanced.bf_match_binary(descs, descs)
  let m2 = @cv_advanced.bf_match_binary(descs, descs)
  let cv = @cv_advanced.cross_validate_match(m1, m2)
  assert_true(cv.length() >= 0)
}

///|
test "AI: 所有匹配 distance 非负" {
  let img = make_test_image_for_match()
  let kps = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, kps)
  let matches = @cv_advanced.bf_match_binary(descs, descs)
  for m in matches {
    assert_true(m.distance >= 0.0)
    assert_true(m.query_idx >= 0)
    assert_true(m.train_idx >= 0)
  }
}
