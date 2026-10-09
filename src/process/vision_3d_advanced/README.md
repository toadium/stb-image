# walkzzz/image/process/vision_3d_advanced

> 三维视觉高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 10 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DepthMap {
pub(all) struct Point3D {
pub(all) struct PointCloud {
pub(all) enum PointCloudType {
pub(all) struct PoseEstimationResult {
pub(all) struct Reconstruction3DResult {
pub(all) struct SLAMResult {
pub(all) struct StereoMatchingResult {
pub(all) struct Vision3DConfig {
pub(all) enum Vision3DTaskType {
```

## API

```moonbit
pub fn create_default_vision_3d_config() -> Vision3DConfig
pub fn estimate_depth(Array[Double], Int, Int, Vision3DConfig) -> DepthMap
pub fn estimate_pose(Array[Array[Double]], Array[Array[Double]], Vision3DConfig) -> PoseEstimationResult
pub fn reconstruct_3d(Array[Array[Double]], Array[DepthMap], Vision3DConfig) -> Reconstruction3DResult
pub fn stereo_match(Array[Double], Array[Double], Int, Int, Vision3DConfig) -> StereoMatchingResult
pub fn vision_3d_report_to_string(Vision3DTaskType, Vision3DConfig, String) -> String
pub fn PointCloudType::equal(Self, Self) -> Bool
pub fn PointCloudType::not_equal(Self, Self) -> Bool
pub fn Vision3DTaskType::equal(Self, Self) -> Bool
pub fn Vision3DTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
