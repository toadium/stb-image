# walkzzz/image/process/image_watermark_advanced

> 图像水印高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DigitalFingerprintResult {
pub(all) struct ImageWatermarkConfig {
pub(all) enum ImageWatermarkTaskType {
pub(all) struct VisibleWatermarkConfig {
pub(all) struct WatermarkAttackResult {
pub(all) enum WatermarkAttackType {
pub(all) struct WatermarkDetectionResult {
pub(all) enum WatermarkDomain {
pub(all) struct WatermarkEmbeddingResult {
pub(all) struct WatermarkPerformanceResult {
pub(all) enum WatermarkType {
```

## API

```moonbit
pub fn attack_watermark(Array[Double], Int, Int, WatermarkAttackType, Double) -> WatermarkAttackResult
pub fn create_default_watermark_config() -> ImageWatermarkConfig
pub fn detect_watermark(Array[Double], Int, Int, Int, ImageWatermarkConfig) -> WatermarkDetectionResult
pub fn embed_visible_watermark(Array[Double], Int, Int, ImageWatermarkConfig) -> Array[Double]
pub fn embed_watermark(Array[Double], Int, Int, Array[Byte], ImageWatermarkConfig) -> WatermarkEmbeddingResult
pub fn image_watermark_report_to_string(ImageWatermarkTaskType, ImageWatermarkConfig, String) -> String
pub fn ImageWatermarkTaskType::equal(Self, Self) -> Bool
pub fn ImageWatermarkTaskType::not_equal(Self, Self) -> Bool
pub fn WatermarkAttackType::equal(Self, Self) -> Bool
pub fn WatermarkAttackType::not_equal(Self, Self) -> Bool
pub fn WatermarkDomain::equal(Self, Self) -> Bool
pub fn WatermarkDomain::not_equal(Self, Self) -> Bool
pub fn WatermarkType::equal(Self, Self) -> Bool
pub fn WatermarkType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
