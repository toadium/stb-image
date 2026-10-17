# walkzzz/image/process/remote_sensing_advanced

> 遥感图像高级处理

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ChangeDetectionResult {
pub(all) enum ChangeType {
pub(all) struct DetectedRemoteSensingObject {
pub(all) struct LandCoverClassificationResult {
pub(all) enum LandCoverType {
pub(all) struct RemoteSensingConfig {
pub(all) struct RemoteSensingFusionResult {
pub(all) enum RemoteSensingImageType {
pub(all) enum RemoteSensingObjectType {
pub(all) struct RemoteSensingSuperResolutionResult {
pub(all) enum RemoteSensingTaskType {
pub(all) struct TimeSeriesAnalysisResult {
```

## API

```moonbit
pub fn calculate_ndvi(Array[Double], Array[Double], Int) -> Array[Double]
pub fn calculate_ndwi(Array[Double], Array[Double], Int) -> Array[Double]
pub fn classify_land_cover(Array[Double], Int, Int, RemoteSensingConfig) -> LandCoverClassificationResult
pub fn create_default_remote_sensing_config() -> RemoteSensingConfig
pub fn detect_changes(Array[Double], Array[Double], Int, Int, RemoteSensingConfig) -> ChangeDetectionResult
pub fn detect_remote_sensing_objects(Array[Double], Int, Int, RemoteSensingConfig) -> Array[DetectedRemoteSensingObject]
pub fn remote_sensing_report_to_string(RemoteSensingTaskType, RemoteSensingConfig, String) -> String
pub fn ChangeType::equal(Self, Self) -> Bool
pub fn ChangeType::not_equal(Self, Self) -> Bool
pub fn LandCoverType::equal(Self, Self) -> Bool
pub fn LandCoverType::not_equal(Self, Self) -> Bool
pub fn RemoteSensingImageType::equal(Self, Self) -> Bool
pub fn RemoteSensingImageType::not_equal(Self, Self) -> Bool
pub fn RemoteSensingObjectType::equal(Self, Self) -> Bool
pub fn RemoteSensingObjectType::not_equal(Self, Self) -> Bool
pub fn RemoteSensingTaskType::equal(Self, Self) -> Bool
pub fn RemoteSensingTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
