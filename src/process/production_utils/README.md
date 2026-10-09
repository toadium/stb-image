# walkzzz/image/process/production_utils

> 生产环境工具函数

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 21 |
| 公开类型 | 6 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ImageValidationResult {
pub(all) struct MemoryUsageStats {
pub(all) struct PerformanceTimer {
pub(all) struct ProductionError {
pub(all) enum ProductionErrorCode {
pub(all) struct RetryConfig {
```

## API

```moonbit
pub fn calculate_retry_delay(RetryConfig, Int) -> Double
pub fn clamp_pixel_value(Int) -> Int
pub fn clamp_pixel_value_double(Double) -> Double
pub fn create_default_retry_config() -> RetryConfig
pub fn create_memory_stats() -> MemoryUsageStats
pub fn create_performance_timer(String) -> PerformanceTimer
pub fn create_production_error(ProductionErrorCode, String, String) -> ProductionError
pub fn is_valid_2d_index(Int, Int, Int, Int) -> Bool
pub fn is_valid_index(Int, Int) -> Bool
pub fn production_error_to_string(ProductionError) -> String
pub fn validate_channels(@types.Image, Array[Int]) -> Bool
pub fn validate_channels_or_raise(@types.Image, Array[Int], String) -> Unit raise @types.LoadError
pub fn validate_image(@types.Image) -> ImageValidationResult
pub fn validate_image_or_raise(@types.Image) -> Unit raise @types.LoadError
pub fn validate_int_range(Int, Int, Int, String) -> Result[Unit, String]
pub fn validate_int_range_or_raise(Int, Int, Int, String) -> Unit raise @types.LoadError
pub fn validate_range(Double, Double, Double, String) -> Result[Unit, String]
pub fn validate_range_or_raise(Double, Double, Double, String) -> Unit raise @types.LoadError
pub fn validation_result_to_string(ImageValidationResult) -> String
pub fn ProductionErrorCode::equal(Self, Self) -> Bool
pub fn ProductionErrorCode::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
