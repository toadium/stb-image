///|
test "Point2D: 构造与字段" {
  let p : @cv_advanced.Point2D = { x: 3.0, y: 4.0, }
  assert_eq(p.x, 3.0)
  assert_eq(p.y, 4.0)
}

///|
test "PerspectiveTransform: 恒等变换构造" {
  let t = @cv_advanced.identity_perspective_transform()
  assert_eq(t.h00, 1.0)
  assert_eq(t.h01, 0.0)
  assert_eq(t.h02, 0.0)
  assert_eq(t.h10, 0.0)
  assert_eq(t.h11, 1.0)
  assert_eq(t.h12, 0.0)
  assert_eq(t.h20, 0.0)
  assert_eq(t.h21, 0.0)
}

///|
test "DocumentDetectionResult: 构造与字段" {
  let corners : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 10.0, y: 0.0, },
    { x: 10.0, y: 10.0, },
    { x: 0.0, y: 10.0, },
  ]
  let r : @cv_advanced.DocumentDetectionResult = {
    corners,
    confidence: 0.95,
    width: 10,
    height: 10,
  }
  assert_eq(r.confidence, 0.95)
  assert_eq(r.width, 10)
  assert_eq(r.height, 10)
  assert_eq(r.corners.length(), 4)
}

///|
test "identity_perspective_transform: 返回恒等矩阵" {
  let t = @cv_advanced.identity_perspective_transform()
  let pt : @cv_advanced.Point2D = { x: 5.0, y: 7.0, }
  let out = @cv_advanced.apply_perspective(t, pt)
  assert_eq(out.x, 5.0)
  assert_eq(out.y, 7.0)
}

///|
test "apply_perspective: 平移变换" {
  let t : @cv_advanced.PerspectiveTransform = {
    h00: 1.0,
    h01: 0.0,
    h02: 3.0,
    h10: 0.0,
    h11: 1.0,
    h12: 5.0,
    h20: 0.0,
    h21: 0.0,
  }
  let pt : @cv_advanced.Point2D = { x: 2.0, y: 4.0, }
  let out = @cv_advanced.apply_perspective(t, pt)
  assert_eq(out.x, 5.0)
  assert_eq(out.y, 9.0)
}

///|
test "apply_perspective: 缩放变换" {
  let t : @cv_advanced.PerspectiveTransform = {
    h00: 2.0,
    h01: 0.0,
    h02: 0.0,
    h10: 0.0,
    h11: 3.0,
    h12: 0.0,
    h20: 0.0,
    h21: 0.0,
  }
  let pt : @cv_advanced.Point2D = { x: 4.0, y: 5.0, }
  let out = @cv_advanced.apply_perspective(t, pt)
  assert_eq(out.x, 8.0)
  assert_eq(out.y, 15.0)
}

///|
test "compute_perspective_transform: 恒等对应" {
  let src : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 1.0, y: 0.0, },
    { x: 1.0, y: 1.0, },
    { x: 0.0, y: 1.0, },
  ]
  let dst : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 1.0, y: 0.0, },
    { x: 1.0, y: 1.0, },
    { x: 0.0, y: 1.0, },
  ]
  let t = @cv_advanced.compute_perspective_transform(src, dst)
  assert_eq(t.h00, 1.0)
  assert_eq(t.h11, 1.0)
  assert_eq(t.h02, 0.0)
  assert_eq(t.h12, 0.0)
}

///|
test "compute_perspective_transform: 点数不足返回恒等" {
  let src : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 1.0, y: 0.0, },
  ]
  let dst : Array[@cv_advanced.Point2D] = [
    { x: 5.0, y: 5.0, },
    { x: 6.0, y: 5.0, },
  ]
  let t = @cv_advanced.compute_perspective_transform(src, dst)
  let id = @cv_advanced.identity_perspective_transform()
  assert_eq(t, id)
}

///|
test "compute_perspective_transform: 平移对应" {
  let src : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 2.0, y: 0.0, },
    { x: 2.0, y: 2.0, },
    { x: 0.0, y: 2.0, },
  ]
  let dst : Array[@cv_advanced.Point2D] = [
    { x: 3.0, y: 4.0, },
    { x: 5.0, y: 4.0, },
    { x: 5.0, y: 6.0, },
    { x: 3.0, y: 6.0, },
  ]
  let t = @cv_advanced.compute_perspective_transform(src, dst)
  assert_eq(t.h02, 3.0)
  assert_eq(t.h12, 4.0)
  assert_eq(t.h00, 1.0)
  assert_eq(t.h11, 1.0)
}

///|
test "correct_perspective: 恒等变换保持图像" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 20, 30, 40]),
  }
  let t = @cv_advanced.identity_perspective_transform()
  let out = @cv_advanced.correct_perspective(img, t, 2, 2)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
  assert_eq(out.channels, 1)
  assert_eq(out.data[0], 10)
  assert_eq(out.data[1], 20)
  assert_eq(out.data[2], 30)
  assert_eq(out.data[3], 40)
}

///|
test "correct_perspective: 输出尺寸正确" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 3,
    data: Bytes::from_array([
      100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50,
      100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50,
      100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50, 100, 50, 50,
    ]),
  }
  let t = @cv_advanced.identity_perspective_transform()
  let out = @cv_advanced.correct_perspective(img, t, 6, 8)
  assert_eq(out.width, 6)
  assert_eq(out.height, 8)
  assert_eq(out.channels, 3)
  assert_eq(out.data.length(), 6 * 8 * 3)
}

///|
test "detect_document_edges: 基本检测" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 10, 10, 10, 10, 10, 10, 10, 200, 200, 200, 200, 200, 200, 200, 200,
    ]),
  }
  let result = @cv_advanced.detect_document_edges(img)
  assert_eq(result.width, 4)
  assert_eq(result.height, 4)
  assert_eq(result.corners.length(), 4)
  assert_true(result.confidence >= 0.0)
}

///|
test "detect_document_edges: 均匀图像置信度为零" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([50, 50, 50, 50, 50, 50, 50, 50, 50]),
  }
  let result = @cv_advanced.detect_document_edges(img)
  assert_eq(result.confidence, 0.0)
}

///|
test "document_scan: 基本扫描" {
  let img : @types.Image = {
    width: 4,
    height: 4,
    channels: 1,
    data: Bytes::from_array([
      10, 10, 10, 10, 10, 10, 10, 10, 200, 200, 200, 200, 200, 200, 200, 200,
    ]),
  }
  let out = @cv_advanced.document_scan(img, 4, 4)
  assert_eq(out.width, 4)
  assert_eq(out.height, 4)
  assert_eq(out.channels, 1)
}

///|
test "perspective_correction_pipeline: 点数不足返回原图" {
  let img : @types.Image = {
    width: 2,
    height: 2,
    channels: 1,
    data: Bytes::from_array([10, 20, 30, 40]),
  }
  let corners : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 1.0, y: 0.0, },
  ]
  let out = @cv_advanced.perspective_correction_pipeline(img, corners, 4, 4)
  assert_eq(out.width, 2)
  assert_eq(out.height, 2)
}

///|
test "perspective_correction_pipeline: 恒等角点" {
  let img : @types.Image = {
    width: 3,
    height: 3,
    channels: 1,
    data: Bytes::from_array([10, 20, 30, 40, 50, 60, 70, 80, 90]),
  }
  let corners : Array[@cv_advanced.Point2D] = [
    { x: 0.0, y: 0.0, },
    { x: 2.0, y: 0.0, },
    { x: 2.0, y: 2.0, },
    { x: 0.0, y: 2.0, },
  ]
  let out = @cv_advanced.perspective_correction_pipeline(img, corners, 3, 3)
  assert_eq(out.width, 3)
  assert_eq(out.height, 3)
  assert_eq(out.channels, 1)
}
