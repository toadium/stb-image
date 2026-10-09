# walkzzz/image/process/industrial_inspection_advanced

> 工业检测高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 12 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AnomalyDetectionResult {
pub(all) enum DefectType {
pub(all) struct DetectedDefect {
pub(all) struct DimensionalMeasurementResult {
pub(all) struct IndustrialInspectionConfig {
pub(all) enum IndustrialInspectionTaskType {
pub(all) struct ProductClassificationResult {
pub(all) enum SurfaceQualityGrade {
pub(all) struct SurfaceQualityResult {
```

## API

```moonbit
pub fn create_default_industrial_config() -> IndustrialInspectionConfig
pub fn detect_anomalies(Array[Double], Array[Double], Int, Int, IndustrialInspectionConfig) -> AnomalyDetectionResult
pub fn detect_defects(Array[Double], Int, Int, IndustrialInspectionConfig) -> Array[DetectedDefect]
pub fn evaluate_surface_quality(Array[Double], Int, Int, Array[DetectedDefect], IndustrialInspectionConfig) -> SurfaceQualityResult
pub fn industrial_inspection_report_to_string(IndustrialInspectionTaskType, IndustrialInspectionConfig, String) -> String
pub fn measure_dimensions(Array[Double], Int, Int, Double, IndustrialInspectionConfig) -> Array[DimensionalMeasurementResult]
pub fn DefectType::equal(Self, Self) -> Bool
pub fn DefectType::not_equal(Self, Self) -> Bool
pub fn IndustrialInspectionTaskType::equal(Self, Self) -> Bool
pub fn IndustrialInspectionTaskType::not_equal(Self, Self) -> Bool
pub fn SurfaceQualityGrade::equal(Self, Self) -> Bool
pub fn SurfaceQualityGrade::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
