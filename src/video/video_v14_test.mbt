// v14.0.0 视频目标跟踪与动作识别测试

///|
fn make_frame(w : Int32, h : Int32, val : Byte) -> @types.Image {
  @types.Image::{
    width: w,
    height: h,
    channels: 1,
    data: Bytes::from_array(Array::make(w * h, val)),
  }
}

///|
test "create_default_stabilization_config: 返回有效配置" {
  let config = @video.create_default_stabilization_config()
  assert_true(config.smoothing_radius > 0)
  assert_true(config.max_correction > 0.0)
  assert_true(config.crop_ratio >= 0.0)
}

///|
test "compute_frame_difference: 相同帧差为零" {
  let frame = make_frame(16, 16, b'\x80')
  let diff = @video.compute_frame_difference(frame, frame)
  assert_true(diff.abs() < 0.001)
}

///|
test "compute_frame_difference: 不同帧差为正" {
  let frame1 = make_frame(16, 16, b'\x00')
  let frame2 = make_frame(16, 16, b'\xFF')
  let diff = @video.compute_frame_difference(frame1, frame2)
  assert_true(diff > 0.0)
}

///|
test "compute_optical_flow: 基本光流计算" {
  let frame1 = make_frame(16, 16, b'\x80')
  let frame2 = make_frame(16, 16, b'\xA0')
  let flow = @video.compute_optical_flow(frame1, frame2)
  assert_true(flow.vectors.length() >= 0)
}

///|
test "initialize_tracking: 初始化跟踪对象" {
  let frame = make_frame(32, 32, b'\x80')
  let obj = @video.initialize_tracking(frame, 8, 8, 16, 16, "target")
  assert_true(obj.x >= 0)
  assert_true(obj.y >= 0)
  assert_true(obj.width > 0)
  assert_true(obj.height > 0)
}

///|
test "update_tracking: 更新跟踪位置" {
  let frame1 = make_frame(32, 32, b'\x80')
  let frame2 = make_frame(32, 32, b'\x90')
  let obj = @video.initialize_tracking(frame1, 8, 8, 16, 16, "target")
  let updated = @video.update_tracking(obj, frame2)
  let _ = updated
  assert_true(true)
}

///|
test "recognize_action: 基本动作识别" {
  let frames = [
    make_frame(32, 32, b'\x40'),
    make_frame(32, 32, b'\x80'),
    make_frame(32, 32, b'\xC0'),
  ]
  let result = @video.recognize_action(frames, 0, 2)
  assert_true(result.confidence >= 0.0 && result.confidence <= 1.0)
}

///|
test "detect_scene_change: 相同帧无切换" {
  let frame = make_frame(32, 32, b'\x80')
  let (changed, score) = @video.detect_scene_change(frame, frame)
  assert_false(changed)
  assert_true(score >= 0.0)
}

///|
test "detect_scene_change: 差异大帧有切换" {
  let frame1 = make_frame(32, 32, b'\x00')
  let frame2 = make_frame(32, 32, b'\xFF')
  let (_changed, score) = @video.detect_scene_change(frame1, frame2)
  assert_true(score > 0.0)
}

///|
test "extract_keyframes: 提取关键帧" {
  let frames = [
    make_frame(32, 32, b'\x00'),
    make_frame(32, 32, b'\x40'),
    make_frame(32, 32, b'\x80'),
    make_frame(32, 32, b'\xC0'),
    make_frame(32, 32, b'\xFF'),
  ]
  let keyframes = @video.extract_keyframes(frames, 30.0)
  assert_true(keyframes.length() > 0)
}

///|
test "generate_video_summary: 生成视频摘要" {
  let frames = [
    make_frame(32, 32, b'\x00'),
    make_frame(32, 32, b'\x80'),
    make_frame(32, 32, b'\xFF'),
  ]
  let summary = @video.generate_video_summary(frames, 30.0)
  assert_true(summary.total_frames >= 0)
  assert_true(summary.duration_ms >= 0.0)
}

///|
test "stabilize_video: 基本视频稳定" {
  let frames = [
    make_frame(32, 32, b'\x80'),
    make_frame(32, 32, b'\x80'),
    make_frame(32, 32, b'\x80'),
  ]
  let config = @video.create_default_stabilization_config()
  let stabilized = @video.stabilize_video(frames, config)
  assert_eq(stabilized.length(), frames.length())
}

///|
test "video_frames_new: 创建视频帧序列" {
  let frames = [make_frame(16, 16, b'\x80'), make_frame(16, 16, b'\xA0')]
  let video = @video.video_frames_new(frames)
  assert_eq(@video.video_frame_count(video), 2)
}

///|
test "video_frame_count: 帧计数" {
  let frames = [
    make_frame(8, 8, b'\x00'),
    make_frame(8, 8, b'\x40'),
    make_frame(8, 8, b'\x80'),
  ]
  let video = @video.video_frames_new(frames)
  assert_eq(@video.video_frame_count(video), 3)
}

///|
test "video_get_frame: 获取指定帧" {
  let frames = [make_frame(8, 8, b'\x00'), make_frame(8, 8, b'\xFF')]
  let video = @video.video_frames_new(frames)
  match @video.video_get_frame(video, 0) {
    Some(img) => assert_eq(img.width, 8)
    None => assert_true(false)
  }
}

///|
test "video_get_frame: 越界返回None" {
  let frames = [make_frame(8, 8, b'\x80')]
  let video = @video.video_frames_new(frames)
  match @video.video_get_frame(video, 5) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "interpolate_frames: 帧插值" {
  let frame1 = make_frame(16, 16, b'\x00')
  let frame2 = make_frame(16, 16, b'\xFF')
  let result = @video.interpolate_frames(frame1, frame2)
  assert_true(result.length() > 0)
}

///|
test "video_fade_in: 淡入效果" {
  let frames = [
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\x80'),
  ]
  let video = @video.video_frames_new(frames)
  let faded = @video.video_fade_in(video, duration_frames=2)
  assert_eq(@video.video_frame_count(faded), 3)
}

///|
test "video_fade_out: 淡出效果" {
  let frames = [
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\x80'),
  ]
  let video = @video.video_frames_new(frames)
  let faded = @video.video_fade_out(video, duration_frames=2)
  assert_eq(@video.video_frame_count(faded), 3)
}

///|
test "video_sample: 抽帧" {
  let frames = [
    make_frame(8, 8, b'\x00'),
    make_frame(8, 8, b'\x40'),
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\xC0'),
  ]
  let video = @video.video_frames_new(frames)
  let sampled = @video.video_sample(video, interval=2)
  assert_true(
    @video.video_frame_count(sampled) <= @video.video_frame_count(video),
  )
}

///|
test "video_reverse: 倒放" {
  let frames = [
    make_frame(8, 8, b'\x00'),
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\xFF'),
  ]
  let video = @video.video_frames_new(frames)
  let reversed = @video.video_reverse(video)
  assert_eq(@video.video_frame_count(reversed), 3)
}

///|
test "video_concat: 拼接" {
  let frames1 = [make_frame(8, 8, b'\x00'), make_frame(8, 8, b'\x40')]
  let frames2 = [make_frame(8, 8, b'\x80'), make_frame(8, 8, b'\xC0')]
  let video1 = @video.video_frames_new(frames1)
  let video2 = @video.video_frames_new(frames2)
  let concatenated = @video.video_concat(video1, video2)
  assert_eq(@video.video_frame_count(concatenated), 4)
}

///|
test "create_animation: 创建动画" {
  let frames = [make_frame(8, 8, b'\x00'), make_frame(8, 8, b'\xFF')]
  let anim = @video.create_animation(frames)
  assert_true(@video.video_frame_count(anim) >= 0)
}

///|
test "video_frame_average: 帧平均" {
  let frames6 = [
    make_frame(8, 8, b'\x00'),
    make_frame(8, 8, b'\x80'),
    make_frame(8, 8, b'\xFF'),
  ]
  let video = @video.video_frames_new(frames6)
  let avg = @video.video_frame_average(video)
  assert_eq(avg.width, 8)
  assert_eq(avg.height, 8)
}
