# walkzzz/image/process/intelligent_vision

> 智能视觉

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 21 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum AgriculturalVisionTask {
pub(all) enum AstronomicalImageTask {
pub(all) enum AutonomousDrivingTask {
pub(all) struct CropDetectionResult {
pub(all) struct DefectDetectionResult {
pub(all) struct DetectionResultIV {
pub(all) enum IndustrialInspectionTask {
pub(all) struct IntelligentVisionConfig {
pub(all) struct IntrusionDetectionResult {
pub(all) struct LaneDetectionResult {
pub(all) enum RobotVisionTask {
pub(all) enum SecurityMonitoringTask {
pub(all) struct StarDetectionResult {
pub(all) struct TrafficSignResult {
```

## API

```moonbit
pub fn create_default_intelligent_vision_config() -> IntelligentVisionConfig
pub fn detect_crops(@types.Image, IntelligentVisionConfig) -> Array[CropDetectionResult]
pub fn detect_defects(@types.Image, IntelligentVisionConfig) -> Array[DefectDetectionResult]
pub fn detect_intrusion(@types.Image, Array[Double], IntelligentVisionConfig) -> IntrusionDetectionResult
pub fn detect_lanes(@types.Image, IntelligentVisionConfig) -> LaneDetectionResult
pub fn detect_objects_iv(@types.Image, IntelligentVisionConfig) -> Array[DetectionResultIV]
pub fn detect_stars(@types.Image, IntelligentVisionConfig) -> StarDetectionResult
pub fn intelligent_vision_report_to_string(String, Int, Double, IntelligentVisionConfig) -> String
pub fn recognize_traffic_signs(@types.Image, IntelligentVisionConfig) -> Array[TrafficSignResult]
pub fn AgriculturalVisionTask::equal(Self, Self) -> Bool
pub fn AgriculturalVisionTask::not_equal(Self, Self) -> Bool
pub fn AstronomicalImageTask::equal(Self, Self) -> Bool
pub fn AstronomicalImageTask::not_equal(Self, Self) -> Bool
pub fn AutonomousDrivingTask::equal(Self, Self) -> Bool
pub fn AutonomousDrivingTask::not_equal(Self, Self) -> Bool
pub fn IndustrialInspectionTask::equal(Self, Self) -> Bool
pub fn IndustrialInspectionTask::not_equal(Self, Self) -> Bool
pub fn RobotVisionTask::equal(Self, Self) -> Bool
pub fn RobotVisionTask::not_equal(Self, Self) -> Bool
pub fn SecurityMonitoringTask::equal(Self, Self) -> Bool
pub fn SecurityMonitoringTask::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
