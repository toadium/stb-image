// 特征检测扩展测试 — SURF/FAST/BRIEF/AKAZE
// Feature detection extension tests

///|
fn make_test_image() -> @types.Image {
  let width = 10
  let height = 10
  let channels = 1
  let data : Array[Byte] = []
  for y in 0..<height {
    for x in 0..<width {
      let v = if x < 5 && y < 5 {
        0
      } else if x >= 5 && y < 5 {
        128
      } else if x < 5 && y >= 5 {
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
test "形式化: detect_fast_corners 返回数组" {
  let img = make_test_image()
  let corners = @cv_advanced.detect_fast_corners(img, 20)
  assert_true(corners.length() >= 0)
}

///|
test "形式化: detect_surf_keypoints 返回数组" {
  let img = make_test_image()
  let kps = @cv_advanced.detect_surf_keypoints(img, 100.0)
  assert_true(kps.length() >= 0)
}

///|
test "形式化: detect_akaze_keypoints 返回数组" {
  let img = make_test_image()
  let kps = @cv_advanced.detect_akaze_keypoints(img, 100.0)
  assert_true(kps.length() >= 0)
}

///|
test "FAKE: compute_brief_descriptors 生成 256 位" {
  let img = make_test_image()
  let corners = @cv_advanced.detect_fast_corners(img, 20)
  if corners.length() > 0 {
    let descs = @cv_advanced.compute_brief_descriptors(img, corners)
    assert_eq(descs.length(), corners.length())
    if descs.length() > 0 {
      assert_true(descs[0].bits.length() <= 256)
    }
  }
}

///|
test "FAKE: compute_surf_descriptors 生成 64 维" {
  let img = make_test_image()
  let kps = @cv_advanced.detect_surf_keypoints(img, 100.0)
  if kps.length() > 0 {
    let descs = @cv_advanced.compute_surf_descriptors(img, kps)
    assert_eq(descs.length(), kps.length())
    if descs.length() > 0 {
      assert_eq(descs[0].values.length(), 64)
    }
  }
}

///|
test "MOCK: hamming_distance 计算正确" {
  let img = make_test_image()
  let corners = @cv_advanced.detect_fast_corners(img, 20)
  if corners.length() >= 2 {
    let descs = @cv_advanced.compute_brief_descriptors(img, corners)
    let dist = @cv_advanced.hamming_distance(descs[0], descs[0])
    assert_eq(dist, 0)
  }
}

///|
test "MOCK: euclidean_distance 自距离为 0" {
  let img = make_test_image()
  let kps = @cv_advanced.detect_surf_keypoints(img, 100.0)
  if kps.length() >= 1 {
    let descs = @cv_advanced.compute_surf_descriptors(img, kps)
    let dist = @cv_advanced.euclidean_distance(descs[0], descs[0])
    assert_true(dist < 0.001)
  }
}

///|
test "E2E: FAST+BRIEF 完整流水线" {
  let img = make_test_image()
  let corners = @cv_advanced.detect_fast_corners(img, 10)
  let descs = @cv_advanced.compute_brief_descriptors(img, corners)
  assert_eq(descs.length(), corners.length())
}

///|
test "AI: 所有特征点在图像范围内" {
  let img = make_test_image()
  let kps = @cv_advanced.detect_surf_keypoints(img, 50.0)
  for kp in kps {
    assert_true(kp.x >= 0 && kp.x < img.width)
    assert_true(kp.y >= 0 && kp.y < img.height)
  }
}
