# walkzzz/image/process/slam

> SLAM 同步定位与建图

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 11 |
| 公开类型 | 8 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CameraPose {
pub(all) struct FeatureTrackingResult {
pub(all) struct KeyFrame {
pub(all) struct LoopClosureResult {
pub(all) struct MapPoint {
pub(all) enum SLAMAlgorithm {
pub(all) struct SLAMConfig {
pub(all) struct SLAMState {
```

## API

```moonbit
pub fn create_default_slam_config() -> SLAMConfig
pub fn detect_features_slam(@types.Image, Int, Double) -> Array[Array[Double]]
pub fn detect_loop_closure(Array[Array[Double]], Array[KeyFrame], Double) -> LoopClosureResult
pub fn estimate_camera_pose(FeatureTrackingResult, SLAMConfig, CameraPose) -> CameraPose
pub fn initialize_slam(SLAMConfig) -> SLAMState
pub fn process_frame_slam(SLAMState, @types.Image, SLAMConfig) -> SLAMState
pub fn slam_report_to_string(SLAMState) -> String
pub fn track_features_slam(@types.Image, @types.Image, Array[Array[Double]], Int) -> FeatureTrackingResult
pub fn triangulate_points(Array[Array[Double]], CameraPose, CameraPose, SLAMConfig) -> Array[MapPoint]
pub fn SLAMAlgorithm::equal(Self, Self) -> Bool
pub fn SLAMAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
