# walkzzz/image/process/video

> 视频处理（帧差、光流、运动检测）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 25 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ActionRecognitionResult {
pub(all) enum ActionType {
pub(all) struct Keyframe {
pub(all) enum KeyframeType {
pub(all) struct OpticalFlowField {
pub(all) struct OpticalFlowVector {
pub(all) struct TrackedObject {
pub(all) struct TrackingResult {
pub(all) struct VideoFrames {
pub(all) struct VideoStabilizationConfig {
pub(all) struct VideoSummary {
```

## API

```moonbit
pub fn compute_frame_difference(@types.Image, @types.Image, threshold? : Double) -> Double
pub fn compute_optical_flow(@types.Image, @types.Image, block_size? : Int, search_range? : Int) -> OpticalFlowField
pub fn create_animation(Array[@types.Image], fps? : Double) -> VideoFrames
pub fn create_default_stabilization_config() -> VideoStabilizationConfig
pub fn detect_scene_change(@types.Image, @types.Image, threshold? : Double) -> (Bool, Double)
pub fn extract_keyframes(Array[@types.Image], Double, method_type? : String) -> Array[Keyframe]
pub fn generate_video_summary(Array[@types.Image], Double) -> VideoSummary
pub fn initialize_tracking(@types.Image, Int, Int, Int, Int, String) -> TrackedObject
pub fn interpolate_frames(@types.Image, @types.Image, num_frames? : Int) -> Array[@types.Image]
pub fn recognize_action(Array[@types.Image], Int, Int) -> ActionRecognitionResult
pub fn stabilize_video(Array[@types.Image], VideoStabilizationConfig) -> Array[@types.Image]
pub fn update_tracking(TrackedObject, @types.Image) -> TrackedObject
pub fn video_concat(VideoFrames, VideoFrames) -> VideoFrames
pub fn video_fade_in(VideoFrames, duration_frames? : Int) -> VideoFrames
pub fn video_fade_out(VideoFrames, duration_frames? : Int) -> VideoFrames
pub fn video_frame_average(VideoFrames) -> @types.Image
pub fn video_frame_count(VideoFrames) -> Int
pub fn video_frames_new(Array[@types.Image], fps? : Double) -> VideoFrames
pub fn video_get_frame(VideoFrames, Int) -> @types.Image?
pub fn video_reverse(VideoFrames) -> VideoFrames
pub fn video_sample(VideoFrames, interval? : Int) -> VideoFrames
pub fn ActionType::equal(Self, Self) -> Bool
pub fn ActionType::not_equal(Self, Self) -> Bool
pub fn KeyframeType::equal(Self, Self) -> Bool
pub fn KeyframeType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
