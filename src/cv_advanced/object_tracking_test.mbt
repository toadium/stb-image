// 目标跟踪测试 — KCF/MOSSE/CSRT/Kalman
// Object tracking tests

///|
fn make_track_params() -> @cv_advanced.TrackerParams {
  {
    kind: @cv_advanced.TrackerKind::KCF,
    learning_rate: 0.1,
    sigma: 2.0,
    max_gap: 5,
  }
}

///|
fn make_test_track() -> @cv_advanced.Track {
  { x: 10.0, y: 10.0, width: 20.0, height: 20.0, id: 1, score: 1.0, }
}

///|
test "形式化: init_tracker 返回正确初始状态" {
  let params = make_track_params()
  let track = @cv_advanced.init_tracker(10.0, 20.0, 30.0, 40.0, params)
  assert_eq(track.x, 10.0)
  assert_eq(track.y, 20.0)
  assert_eq(track.width, 30.0)
  assert_eq(track.height, 40.0)
}

///|
test "形式化: update_tracker 平滑更新位置" {
  let params = make_track_params()
  let track = make_test_track()
  let updated = @cv_advanced.update_tracker(track, 15.0, 15.0, params)
  assert_true(updated.x > track.x)
  assert_true(updated.y > track.y)
  assert_eq(updated.id, track.id)
}

///|
test "形式化: compute_iou 完全重叠返回 1" {
  let a = make_test_track()
  let iou = @cv_advanced.compute_iou(a, a)
  assert_true(iou > 0.99)
}

///|
test "形式化: compute_iou 不重叠返回 0" {
  let a : @cv_advanced.Track = {
    x: 0.0,
    y: 0.0,
    width: 10.0,
    height: 10.0,
    id: 1,
    score: 1.0,
  }
  let b : @cv_advanced.Track = {
    x: 100.0,
    y: 100.0,
    width: 10.0,
    height: 10.0,
    id: 2,
    score: 1.0,
  }
  let iou = @cv_advanced.compute_iou(a, b)
  assert_eq(iou, 0.0)
}

///|
test "FAKE: kalman_predict 预测下一位置" {
  let state : @cv_advanced.KalmanState = {
    x: 10.0,
    y: 20.0,
    vx: 1.0,
    vy: 2.0,
    px: 1.0,
    py: 1.0,
    pvx: 1.0,
    pvy: 1.0,
  }
  let predicted = @cv_advanced.kalman_predict(state)
  assert_eq(predicted.x, 11.0)
  assert_eq(predicted.y, 22.0)
}

///|
test "MOCK: kalman_correct 校正状态" {
  let state : @cv_advanced.KalmanState = {
    x: 10.0,
    y: 20.0,
    vx: 1.0,
    vy: 2.0,
    px: 1.0,
    py: 1.0,
    pvx: 1.0,
    pvy: 1.0,
  }
  let corrected = @cv_advanced.kalman_correct(state, 12.0, 22.0)
  assert_true(corrected.x > 10.0)
  assert_true(corrected.y > 20.0)
}

///|
test "E2E: 完整跟踪流程" {
  let params = make_track_params()
  let track = @cv_advanced.init_tracker(10.0, 10.0, 20.0, 20.0, params)
  let updated = @cv_advanced.update_tracker(track, 12.0, 12.0, params)
  let detections : Array[@cv_advanced.Track] = [
    { x: 13.0, y: 13.0, width: 20.0, height: 20.0, id: 0, score: 0.9, },
  ]
  let result = @cv_advanced.track_objects([updated], detections, 0.3)
  assert_true(result.length() >= 1)
}

///|
test "AI: TrackerKind 枚举完整" {
  let kcf = @cv_advanced.TrackerKind::KCF
  let mosse = @cv_advanced.TrackerKind::MOSSE
  let csrt = @cv_advanced.TrackerKind::CSRT
  assert_true(kcf != mosse)
  assert_true(mosse != csrt)
  assert_true(kcf != csrt)
}

///|
test "AI: track_objects 保留所有检测" {
  let existing : Array[@cv_advanced.Track] = []
  let detections : Array[@cv_advanced.Track] = [
    { x: 10.0, y: 10.0, width: 20.0, height: 20.0, id: 0, score: 0.9, },
    { x: 50.0, y: 50.0, width: 20.0, height: 20.0, id: 0, score: 0.8, },
  ]
  let result = @cv_advanced.track_objects(existing, detections, 0.3)
  assert_eq(result.length(), 2)
}
