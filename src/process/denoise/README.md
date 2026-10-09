# walkzzz/image/process/denoise

> 图像去噪算法集合

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 22 |
| 公开类型 | 6 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum DenoiseAlgorithm {
pub(all) struct DenoiseConfig {
pub(all) struct DenoiseResult {
pub(all) enum EnhancementAlgorithm {
pub(all) struct EnhancementResult {
pub(all) enum NoiseType {
```

## API

```moonbit
pub fn bilateral_filter_denoise(@types.Image, Int, Double, Double) -> @types.Image raise @types.LoadError
pub fn calculate_brightness(@types.Image) -> Double raise @types.LoadError
pub fn calculate_contrast(@types.Image) -> Double raise @types.LoadError
pub fn calculate_noise_level(@types.Image) -> Double raise @types.LoadError
pub fn calculate_sharpness(@types.Image) -> Double raise @types.LoadError
pub fn create_default_denoise_config() -> DenoiseConfig
pub fn denoise_algorithm_to_string(DenoiseAlgorithm) -> String
pub fn denoise_image(@types.Image, DenoiseConfig) -> DenoiseResult raise @types.LoadError
pub fn denoise_report_to_string(DenoiseResult) -> String
pub fn enhance_image_advanced(@types.Image, EnhancementAlgorithm) -> EnhancementResult raise @types.LoadError
pub fn gamma_correction_enhance(@types.Image, Double) -> @types.Image raise @types.LoadError
pub fn gaussian_filter_denoise(@types.Image, Int, Double) -> @types.Image raise @types.LoadError
pub fn histogram_equalization_enhance(@types.Image) -> @types.Image raise @types.LoadError
pub fn mean_filter_denoise(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn median_filter_denoise(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn unsharp_mask_enhance(@types.Image, Double, Int) -> @types.Image raise @types.LoadError
pub fn DenoiseAlgorithm::equal(Self, Self) -> Bool
pub fn DenoiseAlgorithm::not_equal(Self, Self) -> Bool
pub fn EnhancementAlgorithm::equal(Self, Self) -> Bool
pub fn EnhancementAlgorithm::not_equal(Self, Self) -> Bool
pub fn NoiseType::equal(Self, Self) -> Bool
pub fn NoiseType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
