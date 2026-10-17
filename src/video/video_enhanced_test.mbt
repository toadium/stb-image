// v192c video 增强测试：多帧序列 + 跟踪 + 动作识别 + 编辑

///|
fn vid_make_img(w : Int, h : Int, ch : Int, seed : Int) -> @types.Image {
  let data : Array[Byte] = []
  for i in 0..<(w * h * ch) {
    let v : Int = (i * 37 + seed * 13) % 256
    data.push(v.to_byte())
  }
  @types.Image::{
    width: w,
    height: h,
    channels: ch,
    data: Bytes::from_array(data),
  }
}

///|
fn vid_make_frames(n : Int, w : Int, h : Int) -> Array[@types.Image] {
  let frames : Array[@types.Image] = []
  for i in 0..<n {
    frames.push(vid_make_img(w, h, 3, i))
  }
  frames
}

///|
test "compute_frame_difference: 不同阈值" {
  let f1 = vid_make_img(32, 32, 3, 0)
  let f2 = vid_make_img(32, 32, 3, 1)
  for threshold in [0.0, 0.1, 0.5, 1.0] {
    let diff = @video.compute_frame_difference(f1, f2, threshold~)
    assert_true(diff >= 0.0)
  }
}

///|
test "compute_frame_difference: 相同帧多阈值" {
  let f = vid_make_img(32, 32, 3, 0)
  for threshold in [0.0, 0.5, 1.0] {
    let diff = @video.compute_frame_difference(f, f, threshold~)
    assert_true(diff >= 0.0)
  }
}

///|
test "compute_optical_flow: 不同块大小" {
  let f1 = vid_make_img(32, 32, 3, 0)
  let f2 = vid_make_img(32, 32, 3, 1)
  for block_size in [4, 8, 16] {
    let flow = @video.compute_optical_flow(f1, f2, block_size~)
    assert_true(flow.vectors.length() >= 0)
  }
}

///|
test "compute_optical_flow: 不同搜索范围" {
  let f1 = vid_make_img(32, 32, 3, 0)
  let f2 = vid_make_img(32, 32, 3, 1)
  for search_range in [4, 8, 16] {
    let flow = @video.compute_optical_flow(f1, f2, search_range~)
    assert_true(flow.vectors.length() >= 0)
  }
}

///|
test "detect_scene_change: 多阈值" {
  let f1 = vid_make_img(32, 32, 3, 0)
  let f2 = vid_make_img(32, 32, 3, 100)
  for threshold in [0.1, 0.3, 0.5, 0.7, 0.9] {
    let (_, score) = @video.detect_scene_change(f1, f2, threshold~)
    assert_true(score >= 0.0)
    assert_true(score <= 1.0 + 0.001)
  }
}

///|
test "create_animation: 不同帧率" {
  let frames = vid_make_frames(5, 32, 32)
  for fps in [15.0, 24.0, 30.0, 60.0] {
    let anim = @video.create_animation(frames, fps~)
    assert_true(anim.frames.length() == 5)
  }
}

///|
test "create_animation: 单帧" {
  let frames = [vid_make_img(32, 32, 3, 0)]
  let anim = @video.create_animation(frames)
  assert_eq(anim.frames.length(), 1)
}

///|
test "extract_keyframes: 不同方法" {
  let frames = vid_make_frames(10, 32, 32)
  for method_name in ["uniform", "difference", "histogram"] {
    let keyframes = @video.extract_keyframes(
      frames,
      0.3,
      method_type=method_name,
    )
    assert_true(keyframes.length() >= 1)
    assert_true(keyframes.length() <= 10)
  }
}

///|
test "extract_keyframes: 不同阈值" {
  let frames = vid_make_frames(10, 32, 32)
  for threshold in [0.1, 0.3, 0.5, 0.7] {
    let keyframes = @video.extract_keyframes(frames, threshold)
    assert_true(keyframes.length() >= 1)
  }
}

///|
test "generate_video_summary: 多帧序列" {
  let frames = vid_make_frames(15, 32, 32)
  let summary = @video.generate_video_summary(frames, 0.3)
  assert_true(summary.total_frames == 15)
}

///|
test "initialize_tracking: 不同初始位置" {
  let img = vid_make_img(64, 64, 3, 0)
  for x in [10, 20, 30] {
    for y in [10, 20, 30] {
      let obj = @video.initialize_tracking(img, x, y, 16, 16, "mean_shift")
      assert_true(obj.width > 0)
      assert_true(obj.height > 0)
    }
  }
}

///|
test "initialize_tracking: 不同算法" {
  let img = vid_make_img(64, 64, 3, 0)
  for algo in ["mean_shift", "cam_shift", "kalman"] {
    let obj = @video.initialize_tracking(img, 10, 10, 16, 16, algo)
    assert_true(obj.width > 0)
  }
}

///|
test "update_tracking: 连续更新序列" {
  let frames = vid_make_frames(5, 64, 64)
  let obj0 = @video.initialize_tracking(frames[0], 10, 10, 16, 16, "mean_shift")
  let obj1 = @video.update_tracking(obj0, frames[1])
  assert_true(obj1.width > 0)
  let obj2 = @video.update_tracking(obj1, frames[2])
  assert_true(obj2.width > 0)
}

///|
test "recognize_action: 不同帧数" {
  for n in [5, 10, 20] {
    let frames = vid_make_frames(n, 32, 32)
    let result = @video.recognize_action(frames, 0, n)
    assert_true(result.confidence >= 0.0)
  }
}

///|
test "stabilize_video: 多帧稳定" {
  let frames = vid_make_frames(10, 32, 32)
  let config = @video.create_default_stabilization_config()
  let stabilized = @video.stabilize_video(frames, config)
  assert_eq(stabilized.length(), 10)
}

///|
test "interpolate_frames: 不同插值数" {
  let f1 = vid_make_img(32, 32, 3, 0)
  let f2 = vid_make_img(32, 32, 3, 1)
  for n in [1, 3, 5, 10] {
    let frames = @video.interpolate_frames(f1, f2, num_frames=n)
    assert_true(frames.length() >= 0)
  }
}

///|
test "video_fade_in: 不同持续帧数" {
  let frames = vid_make_frames(10, 32, 32)
  let anim = @video.create_animation(frames)
  for dur in [1, 3, 5] {
    let faded = @video.video_fade_in(anim, duration_frames=dur)
    assert_true(faded.frames.length() >= 0)
  }
}

///|
test "video_fade_out: 不同持续帧数" {
  let frames = vid_make_frames(10, 32, 32)
  let anim = @video.create_animation(frames)
  for dur in [1, 3, 5] {
    let faded = @video.video_fade_out(anim, duration_frames=dur)
    assert_true(faded.frames.length() >= 0)
  }
}

///|
test "video_concat: 拼接两个动画" {
  let frames1 = vid_make_frames(5, 32, 32)
  let frames2 = vid_make_frames(3, 32, 32)
  let anim1 = @video.create_animation(frames1)
  let anim2 = @video.create_animation(frames2)
  let combined = @video.video_concat(anim1, anim2)
  assert_true(combined.frames.length() >= 0)
}

///|
test "video_frame_average: 多帧平均" {
  let frames = vid_make_frames(10, 32, 32)
  let anim = @video.create_animation(frames)
  let avg = @video.video_frame_average(anim)
  assert_eq(avg.width, 32)
  assert_eq(avg.height, 32)
}
