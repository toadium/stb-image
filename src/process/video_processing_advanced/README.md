# walkzzz/image/process/video_processing_advanced

> 视频处理高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 11 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum VideoCodecType {
pub(all) struct VideoDecodingResult {
pub(all) struct VideoEncodingResult {
pub(all) struct VideoEnhancementResult {
pub(all) struct VideoFrame {
pub(all) enum VideoFrameType {
pub(all) struct VideoProcessingConfig {
pub(all) enum VideoProcessingTaskType {
pub(all) struct VideoStabilizationResult {
pub(all) struct VideoStream {
pub(all) struct VideoSummarizationResult {
pub(all) struct VideoSuperResolutionResult {
```

## API

```moonbit
pub fn create_default_video_config() -> VideoProcessingConfig
pub fn enhance_video(Array[VideoFrame], VideoProcessingConfig) -> VideoEnhancementResult
pub fn summarize_video(Array[VideoFrame], VideoProcessingConfig) -> VideoSummarizationResult
pub fn video_processing_report_to_string(VideoProcessingTaskType, VideoProcessingConfig, String) -> String
pub fn video_super_resolution(Array[VideoFrame], VideoProcessingConfig) -> VideoSuperResolutionResult
pub fn VideoCodecType::equal(Self, Self) -> Bool
pub fn VideoCodecType::not_equal(Self, Self) -> Bool
pub fn VideoFrameType::equal(Self, Self) -> Bool
pub fn VideoFrameType::not_equal(Self, Self) -> Bool
pub fn VideoProcessingTaskType::equal(Self, Self) -> Bool
pub fn VideoProcessingTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
