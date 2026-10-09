# walkzzz/image/process/compression

> 图像压缩算法

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 7 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum CompressionAlgorithm {
pub(all) struct CompressionConfig {
pub(all) struct CompressionQualityMetrics {
pub(all) struct CompressionResult {
pub(all) struct DCTBlock {
pub(all) struct HuffmanTable {
pub(all) enum QuantizationTableType {
```

## API

```moonbit
pub fn calculate_bits_per_pixel(Int, Int, Int) -> Double
pub fn calculate_compression_quality(@types.Image, @types.Image, Int, Int) -> CompressionQualityMetrics raise @types.LoadError
pub fn calculate_compression_ratio(Int, Int) -> Double
pub fn calculate_image_entropy(@types.Image) -> Double raise @types.LoadError
pub fn compress_image(@types.Image, CompressionConfig) -> CompressionResult raise @types.LoadError
pub fn compress_jpeg_simple(@types.Image, Double) -> CompressionResult raise @types.LoadError
pub fn compress_png_simple(@types.Image) -> CompressionResult raise @types.LoadError
pub fn compression_algorithm_to_string(CompressionAlgorithm) -> String
pub fn compression_report_to_string(CompressionResult, CompressionQualityMetrics) -> String
pub fn create_default_compression_config() -> CompressionConfig
pub fn predictive_encode(@types.Image) -> Bytes raise @types.LoadError
pub fn quantize_image(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn run_length_decode(Bytes) -> Bytes
pub fn run_length_encode(Bytes) -> Bytes
pub fn CompressionAlgorithm::equal(Self, Self) -> Bool
pub fn CompressionAlgorithm::not_equal(Self, Self) -> Bool
pub fn QuantizationTableType::equal(Self, Self) -> Bool
pub fn QuantizationTableType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
