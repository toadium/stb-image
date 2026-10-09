# walkzzz/image/process/security_surveillance_advanced

> 安防监控高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 15 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum AlertLevel {
pub(all) struct AnomalyEvent {
pub(all) struct BehaviorAnalysisResult {
pub(all) enum BehaviorType {
pub(all) struct CrowdAnalysisResult {
pub(all) struct DetectedPerson {
pub(all) struct IntrusionEvent {
pub(all) enum IntrusionType {
pub(all) struct LicensePlateResult {
pub(all) struct SecuritySurveillanceConfig {
pub(all) enum SecuritySurveillanceTaskType {
```

## API

```moonbit
pub fn analyze_behavior(DetectedPerson, SecuritySurveillanceConfig) -> BehaviorAnalysisResult
pub fn analyze_crowd(Array[DetectedPerson], Int, Int, SecuritySurveillanceConfig) -> CrowdAnalysisResult
pub fn create_default_security_config() -> SecuritySurveillanceConfig
pub fn detect_intrusion(Array[DetectedPerson], Array[Int], SecuritySurveillanceConfig) -> Array[IntrusionEvent]
pub fn detect_people(Array[Double], Int, Int, SecuritySurveillanceConfig) -> Array[DetectedPerson]
pub fn recognize_license_plate(Array[Double], Int, Int, SecuritySurveillanceConfig) -> LicensePlateResult
pub fn security_surveillance_report_to_string(SecuritySurveillanceTaskType, SecuritySurveillanceConfig, String) -> String
pub fn AlertLevel::equal(Self, Self) -> Bool
pub fn AlertLevel::not_equal(Self, Self) -> Bool
pub fn BehaviorType::equal(Self, Self) -> Bool
pub fn BehaviorType::not_equal(Self, Self) -> Bool
pub fn IntrusionType::equal(Self, Self) -> Bool
pub fn IntrusionType::not_equal(Self, Self) -> Bool
pub fn SecuritySurveillanceTaskType::equal(Self, Self) -> Bool
pub fn SecuritySurveillanceTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
