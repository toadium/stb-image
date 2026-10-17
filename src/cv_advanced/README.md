# walkzzz/image/process/cv_advanced

> 计算机视觉高级算法

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ActionRecognitionAlgorithm {
pub(all) struct ActionRecognitionResult {
pub(all) struct CVAdvancedConfig {
pub(all) enum CVAdvancedTaskType {
pub(all) struct ImageCaptioningResult {
pub(all) struct SceneParsingResult {
pub(all) struct TrackedObject {
pub(all) enum TrackingAlgorithm {
pub(all) struct VQAResult {
```

## API

```moonbit
pub fn calculate_iou(Array[Int], Array[Int]) -> Double
pub fn create_default_cv_advanced_config() -> CVAdvancedConfig
pub fn create_tracked_object(Int, Array[Int], String, Double) -> TrackedObject
pub fn cv_advanced_report_to_string(CVAdvancedTaskType, CVAdvancedConfig, String) -> String
pub fn generate_caption(String) -> ImageCaptioningResult
pub fn parse_scene(String, Int, Int, CVAdvancedConfig) -> SceneParsingResult
pub fn recognize_action(String, Int, CVAdvancedConfig) -> ActionRecognitionResult
pub fn update_tracked_object(TrackedObject, Array[Int], Double) -> TrackedObject
pub fn visual_question_answering(String, String) -> VQAResult
pub fn ActionRecognitionAlgorithm::equal(Self, Self) -> Bool
pub fn ActionRecognitionAlgorithm::not_equal(Self, Self) -> Bool
pub fn CVAdvancedTaskType::equal(Self, Self) -> Bool
pub fn CVAdvancedTaskType::not_equal(Self, Self) -> Bool
pub fn TrackingAlgorithm::equal(Self, Self) -> Bool
pub fn TrackingAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
