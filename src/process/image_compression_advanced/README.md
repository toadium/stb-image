# walkzzz/image/process/image_compression_advanced

> 图像压缩高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 14 |
| 公开类型 | 9 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum CompressionMode {
pub(all) struct CompressionQualityResult {
pub(all) struct CompressionResult {
pub(all) enum CompressionStandardType {
pub(all) struct DecompressionResult {
pub(all) struct ImageCompressionConfig {
pub(all) enum ImageCompressionTaskType {
pub(all) struct RateDistortionOptimizationResult {
pub(all) enum TransformType {
```

## API

```moonbit
pub fn compress_image(Array[Double], Int, Int, ImageCompressionConfig) -> CompressionResult
pub fn create_default_compression_config() -> ImageCompressionConfig
pub fn decompress_image(Array[Byte], Int, Int, ImageCompressionConfig) -> DecompressionResult
pub fn evaluate_compression_quality(Array[Double], Array[Double], Int, Int) -> CompressionQualityResult
pub fn image_compression_report_to_string(ImageCompressionTaskType, ImageCompressionConfig, String) -> String
pub fn optimize_rate_distortion(Array[Double], Int, Int, ImageCompressionConfig) -> RateDistortionOptimizationResult
pub fn CompressionMode::equal(Self, Self) -> Bool
pub fn CompressionMode::not_equal(Self, Self) -> Bool
pub fn CompressionStandardType::equal(Self, Self) -> Bool
pub fn CompressionStandardType::not_equal(Self, Self) -> Bool
pub fn ImageCompressionTaskType::equal(Self, Self) -> Bool
pub fn ImageCompressionTaskType::not_equal(Self, Self) -> Bool
pub fn TransformType::equal(Self, Self) -> Bool
pub fn TransformType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
