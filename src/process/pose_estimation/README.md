# walkzzz/image/process/pose_estimation

> 姿态估计

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ActionRecognitionAlgorithm {
pub(all) struct ActionRecognitionConfig {
pub(all) struct ActionRecognitionResult {
pub(all) struct GestureRecognitionResult {
pub(all) enum GestureType {
pub(all) struct HumanPose {
pub(all) struct Keypoint {
pub(all) enum PoseEstimationAlgorithm {
pub(all) struct PoseEstimationConfig {
pub(all) struct SkeletonConnection {
```

## API

```moonbit
pub fn calculate_joint_angle(HumanPose, Int, Int, Int) -> Double
pub fn create_default_action_config() -> ActionRecognitionConfig
pub fn create_default_pose_config() -> PoseEstimationConfig
pub fn detect_keypoints(@types.Image, PoseEstimationConfig) -> Array[HumanPose] raise @types.LoadError
pub fn extract_skeleton(HumanPose) -> Array[SkeletonConnection]
pub fn get_coco_keypoint_names() -> Array[String]
pub fn get_coco_skeleton_connections() -> Array[Array[Int]]
pub fn pose_estimation_report_to_string(Array[HumanPose], ActionRecognitionResult) -> String
pub fn recognize_action(Array[HumanPose], ActionRecognitionConfig) -> ActionRecognitionResult
pub fn recognize_gesture(HumanPose) -> GestureRecognitionResult
pub fn visualize_pose(@types.Image, HumanPose) -> @types.Image raise @types.LoadError
pub fn ActionRecognitionAlgorithm::equal(Self, Self) -> Bool
pub fn ActionRecognitionAlgorithm::not_equal(Self, Self) -> Bool
pub fn GestureType::equal(Self, Self) -> Bool
pub fn GestureType::not_equal(Self, Self) -> Bool
pub fn PoseEstimationAlgorithm::equal(Self, Self) -> Bool
pub fn PoseEstimationAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
