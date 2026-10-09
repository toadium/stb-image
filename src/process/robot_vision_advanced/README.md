# walkzzz/image/process/robot_vision_advanced

> 机器人视觉高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 13 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct EndEffectorState {
pub(all) struct GraspConfig {
pub(all) enum GraspType {
pub(all) struct JointState {
pub(all) struct MeshData {
pub(all) struct ObjectPose {
pub(all) struct PointCloudData {
pub(all) struct RobotTrajectory {
pub(all) enum RobotType {
pub(all) struct RobotVisionConfig {
pub(all) enum RobotVisionTaskType {
pub(all) struct TrajectoryPoint {
pub(all) enum VisualServoingType {
```

## API

```moonbit
pub fn create_default_robot_vision_config() -> RobotVisionConfig
pub fn estimate_object_pose(Int, Array[Double], Array[Double], RobotVisionConfig) -> ObjectPose
pub fn generate_point_cloud(Array[Double], Array[Array[Int]], RobotVisionConfig) -> PointCloudData
pub fn plan_arm_trajectory(ObjectPose, ObjectPose, RobotVisionConfig) -> RobotTrajectory
pub fn plan_grasp(ObjectPose, Array[Double], RobotVisionConfig) -> GraspConfig
pub fn robot_vision_report_to_string(RobotVisionTaskType, RobotVisionConfig, String) -> String
pub fn visual_servoing(ObjectPose, ObjectPose, RobotVisionConfig) -> Array[Double]
pub fn GraspType::equal(Self, Self) -> Bool
pub fn GraspType::not_equal(Self, Self) -> Bool
pub fn RobotType::equal(Self, Self) -> Bool
pub fn RobotType::not_equal(Self, Self) -> Bool
pub fn RobotVisionTaskType::equal(Self, Self) -> Bool
pub fn RobotVisionTaskType::not_equal(Self, Self) -> Bool
pub fn VisualServoingType::equal(Self, Self) -> Bool
pub fn VisualServoingType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
