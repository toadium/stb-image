///|
test "MultiTrackingMethod: 枚举值" {
  assert_true(@video.Centroid is @video.Centroid)
  assert_true(@video.KalmanFilter is @video.KalmanFilter)
  assert_true(@video.MeanShift is @video.MeanShift)
}

///|
test "MultiTrackState: 枚举值" {
  assert_true(@video.Active is @video.Active)
  assert_true(@video.Lost is @video.Lost)
  assert_true(@video.Terminated is @video.Terminated)
}

///|
test "MultiTrackedObject: 构造与字段" {
  let obj : @video.MultiTrackedObject = {
    id: 1,
    x: 10.0,
    y: 20.0,
    width: 5.0,
    height: 5.0,
    state: @video.Active,
    age: 3,
    lost_count: 0,
  }
  assert_eq(obj.id, 1)
  assert_eq(obj.x, 10.0)
  assert_eq(obj.age, 3)
  assert_true(obj.state is @video.Active)
}

///|
test "MultiDetectedObject: 构造与字段" {
  let det : @video.MultiDetectedObject = {
    x: 15.0,
    y: 25.0,
    width: 10.0,
    height: 10.0,
    confidence: 0.9,
  }
  assert_eq(det.x, 15.0)
  assert_eq(det.confidence, 0.9)
}

///|
test "MultiTrackingConfig: 构造与字段" {
  let config : @video.MultiTrackingConfig = {
    track_method: @video.KalmanFilter,
    max_lost_frames: 10,
    association_threshold: 100.0,
    min_confidence: 0.3,
  }
  assert_eq(config.max_lost_frames, 10)
  assert_eq(config.association_threshold, 100.0)
  assert_true(config.track_method is @video.KalmanFilter)
}

///|
test "default_tracking_config: 默认值" {
  let config = @video.default_tracking_config()
  assert_eq(config.max_lost_frames, 5)
  assert_eq(config.association_threshold, 50.0)
  assert_eq(config.min_confidence, 0.5)
  assert_true(config.track_method is @video.Centroid)
}

///|
test "init_tracker: 基本初始化" {
  let dets : Array[@video.MultiDetectedObject] = [
    { x: 10.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
    { x: 50.0, y: 50.0, width: 5.0, height: 5.0, confidence: 0.8, },
  ]
  let config = @video.default_tracking_config()
  let tracked = @video.init_tracker(dets, config)
  assert_eq(tracked.length(), 2)
  assert_eq(tracked[0].id, 0)
  assert_eq(tracked[1].id, 1)
  assert_true(tracked[0].state is @video.Active)
}

///|
test "init_tracker: 过滤低置信度" {
  let dets : Array[@video.MultiDetectedObject] = [
    { x: 10.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
    { x: 50.0, y: 50.0, width: 5.0, height: 5.0, confidence: 0.1, },
  ]
  let config = @video.default_tracking_config()
  let tracked = @video.init_tracker(dets, config)
  assert_eq(tracked.length(), 1)
}

///|
test "associate_objects: 基本关联" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 10.0,
      y: 10.0,
      width: 5.0,
      height: 5.0,
      state: @video.Active,
      age: 1,
      lost_count: 0,
    },
  ]
  let detected : Array[@video.MultiDetectedObject] = [
    { x: 12.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
  ]
  let config = @video.default_tracking_config()
  let pairs = @video.associate_objects(tracked, detected, config)
  assert_eq(pairs.length(), 1)
}

///|
test "update_tracker: 基本更新" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 10.0,
      y: 10.0,
      width: 5.0,
      height: 5.0,
      state: @video.Active,
      age: 1,
      lost_count: 0,
    },
  ]
  let detected : Array[@video.MultiDetectedObject] = [
    { x: 15.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
  ]
  let config = @video.default_tracking_config()
  let updated = @video.update_tracker(tracked, detected, config)
  assert_eq(updated.length(), 1)
  assert_eq(updated[0].age, 2)
  assert_true(updated[0].state is @video.Active)
}

///|
test "update_tracker: 未关联增加丢失计数" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 10.0,
      y: 10.0,
      width: 5.0,
      height: 5.0,
      state: @video.Active,
      age: 1,
      lost_count: 0,
    },
  ]
  let detected : Array[@video.MultiDetectedObject] = []
  let config = @video.default_tracking_config()
  let updated = @video.update_tracker(tracked, detected, config)
  assert_eq(updated[0].lost_count, 1)
  assert_true(updated[0].state is @video.Lost)
}

///|
test "multi_object_track: 多帧跟踪" {
  let frame1_dets : Array[@video.MultiDetectedObject] = [
    { x: 10.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
  ]
  let frame2_dets : Array[@video.MultiDetectedObject] = [
    { x: 15.0, y: 10.0, width: 5.0, height: 5.0, confidence: 0.9, },
  ]
  let config = @video.default_tracking_config()
  let results = @video.multi_object_track([frame1_dets, frame2_dets], config)
  assert_eq(results.length(), 2)
}

///|
test "compute_track_length: 最长跟踪" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 0.0,
      y: 0.0,
      width: 1.0,
      height: 1.0,
      state: @video.Active,
      age: 5,
      lost_count: 0,
    },
    {
      id: 1,
      x: 0.0,
      y: 0.0,
      width: 1.0,
      height: 1.0,
      state: @video.Active,
      age: 10,
      lost_count: 0,
    },
  ]
  let len = @video.compute_track_length(tracked)
  assert_eq(len, 10)
}

///|
test "count_active_tracks: 活跃计数" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 0.0,
      y: 0.0,
      width: 1.0,
      height: 1.0,
      state: @video.Active,
      age: 1,
      lost_count: 0,
    },
    {
      id: 1,
      x: 0.0,
      y: 0.0,
      width: 1.0,
      height: 1.0,
      state: @video.Lost,
      age: 1,
      lost_count: 1,
    },
  ]
  let count = @video.count_active_tracks(tracked)
  assert_eq(count, 1)
}

///|
test "tracking_stability: 稳定性评分" {
  let tracked : Array[@video.MultiTrackedObject] = [
    {
      id: 0,
      x: 0.0,
      y: 0.0,
      width: 1.0,
      height: 1.0,
      state: @video.Active,
      age: 10,
      lost_count: 0,
    },
  ]
  let score = @video.tracking_stability(tracked)
  assert_true(score > 0.0 && score <= 1.0)
}

///|
test "tracking_stability: 空跟踪" {
  let tracked : Array[@video.MultiTrackedObject] = []
  let score = @video.tracking_stability(tracked)
  assert_eq(score, 0.0)
}

///|
test "filter_detections: 过滤低置信度" {
  let dets : Array[@video.MultiDetectedObject] = [
    { x: 0.0, y: 0.0, width: 1.0, height: 1.0, confidence: 0.9, },
    { x: 0.0, y: 0.0, width: 1.0, height: 1.0, confidence: 0.1, },
  ]
  let filtered = @video.filter_detections(dets, 0.5)
  assert_eq(filtered.length(), 1)
}
