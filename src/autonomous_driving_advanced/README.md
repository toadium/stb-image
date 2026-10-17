# walkzzz/image/process/autonomous_driving_advanced

> 自动驾驶视觉高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ADConfig {
pub(all) struct ADDetectedObject {
pub(all) enum ADObjectType {
pub(all) enum AutonomousDrivingTaskType {
pub(all) struct ControlCommand {
pub(all) enum DrivingBehaviorType {
pub(all) struct LaneLine {
pub(all) struct PathPoint {
pub(all) struct PlannedPath {
pub(all) struct SensorData {
pub(all) enum SensorType {
pub(all) struct TrafficLight {
```

## API

```moonbit
pub fn autonomous_driving_report_to_string(AutonomousDrivingTaskType, ADConfig, String) -> String
pub fn create_default_ad_config() -> ADConfig
pub fn create_detected_object(Int, ADObjectType, Array[Double], Double) -> ADDetectedObject
pub fn create_sensor_data(SensorType, String, Double, Int) -> SensorData
pub fn decision_control(PlannedPath, Double, Array[ADDetectedObject], ADConfig) -> ControlCommand
pub fn fuse_sensors(Array[SensorData], ADConfig) -> Array[ADDetectedObject]
pub fn plan_path(Array[Double], Array[Double], Array[ADDetectedObject], ADConfig) -> PlannedPath
pub fn ADObjectType::equal(Self, Self) -> Bool
pub fn ADObjectType::not_equal(Self, Self) -> Bool
pub fn AutonomousDrivingTaskType::equal(Self, Self) -> Bool
pub fn AutonomousDrivingTaskType::not_equal(Self, Self) -> Bool
pub fn DrivingBehaviorType::equal(Self, Self) -> Bool
pub fn DrivingBehaviorType::not_equal(Self, Self) -> Bool
pub fn SensorType::equal(Self, Self) -> Bool
pub fn SensorType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
