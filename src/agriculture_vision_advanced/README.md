# walkzzz/image/process/agriculture_vision_advanced

> 农业视觉高级应用

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 13 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AgricultureVisionConfig {
pub(all) enum AgricultureVisionTaskType {
pub(all) struct CropDetectionResult {
pub(all) enum CropType {
pub(all) struct DiseaseDetectionResult {
pub(all) enum DiseaseType {
pub(all) struct GrowthMonitoringResult {
pub(all) struct PestDetectionResult {
pub(all) enum PestType {
pub(all) struct SoilAnalysisResult {
pub(all) enum SoilType {
pub(all) struct WeedDetectionResult {
pub(all) struct YieldPredictionResult {
```

## API

```moonbit
pub fn agriculture_vision_report_to_string(AgricultureVisionTaskType, AgricultureVisionConfig, String) -> String
pub fn analyze_soil(Array[Double], AgricultureVisionConfig) -> SoilAnalysisResult
pub fn create_default_agriculture_config() -> AgricultureVisionConfig
pub fn detect_crops(Array[Double], Int, Int, AgricultureVisionConfig) -> Array[CropDetectionResult]
pub fn detect_diseases(Array[Double], Int, Int, AgricultureVisionConfig) -> Array[DiseaseDetectionResult]
pub fn detect_pests(Array[Double], Int, Int, AgricultureVisionConfig) -> Array[PestDetectionResult]
pub fn predict_yield(CropType, Double, String, Double, AgricultureVisionConfig) -> YieldPredictionResult
pub fn AgricultureVisionTaskType::equal(Self, Self) -> Bool
pub fn AgricultureVisionTaskType::not_equal(Self, Self) -> Bool
pub fn CropType::equal(Self, Self) -> Bool
pub fn CropType::not_equal(Self, Self) -> Bool
pub fn DiseaseType::equal(Self, Self) -> Bool
pub fn DiseaseType::not_equal(Self, Self) -> Bool
pub fn PestType::equal(Self, Self) -> Bool
pub fn PestType::not_equal(Self, Self) -> Bool
pub fn SoilType::equal(Self, Self) -> Bool
pub fn SoilType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
