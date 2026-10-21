// v45.0.0 视频处理高级测试

///|
test "create_default_video_config: 基本测试" {
  let config = @video_processing_advanced.create_default_video_config()
  assert_true(
    config.task_type
    is @video_processing_advanced.VideoProcessingTaskType::VideoEnhancement,
  )
  assert_true(config.codec is @video_processing_advanced.VideoCodecType::H264)
}

///|
test "enhance_video: 基本测试" {
  let frames = [make_test_frame(4, 4, 0), make_test_frame(4, 4, 1)]
  let config = @video_processing_advanced.create_default_video_config()
  let result = @video_processing_advanced.enhance_video(frames, config)
  assert_eq(result.num_frames, 2)
  assert_true(result.enhanced_frames.length() > 0)
}

///|
test "video_super_resolution: 基本测试" {
  let frames = [make_test_frame(4, 4, 0), make_test_frame(4, 4, 1)]
  let config = @video_processing_advanced.create_default_video_config()
  let result = @video_processing_advanced.video_super_resolution(frames, config)
  assert_true(result.sr_width > 0)
  assert_true(result.sr_height > 0)
}

///|
test "summarize_video: 基本测试" {
  let frames = [
    make_test_frame(4, 4, 0),
    make_test_frame(4, 4, 1),
    make_test_frame(4, 4, 2),
  ]
  let config = @video_processing_advanced.create_default_video_config()
  let result = @video_processing_advanced.summarize_video(frames, config)
  assert_true(result.num_keyframes > 0)
  assert_true(result.keyframes.length() > 0)
}

///|
test "video_processing_report_to_string: 基本测试" {
  let config = @video_processing_advanced.create_default_video_config()
  let report = @video_processing_advanced.video_processing_report_to_string(
    @video_processing_advanced.VideoProcessingTaskType::VideoEnhancement,
    config,
    "测试结果",
  )
  assert_true(report.length() > 0)
}

///|
fn make_test_frame(
  w : Int32,
  h : Int32,
  idx : Int32,
) -> @video_processing_advanced.VideoFrame {
  @video_processing_advanced.VideoFrame::{
    frame_data: Array::make(w * h * 3, 128.0),
    width: w,
    height: h,
    num_channels: 3,
    frame_index: idx,
    timestamp_ms: idx.to_double() * 33.33,
    frame_type: @video_processing_advanced.VideoFrameType::IFrame,
    quality_score: 0.9,
    motion_vectors: [],
  }
}
