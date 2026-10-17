# walkzzz/image/process/superres

> 超分辨率重建（双三次、插值、学习类）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 22 |
| 公开类型 | 6 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct EnhancementConfig {
pub(all) struct ImageQualityMetrics {
pub(all) struct InterpolationConfig {
pub(all) enum SuperResolutionAlgorithm {
pub(all) struct SuperResolutionConfig {
pub(all) struct SuperResolutionResult {
```

## API

```moonbit
pub fn bicubic_interpolate(@types.Image, Double) -> @types.Image
pub fn bilinear_interpolate(@types.Image, Double) -> @types.Image
pub fn calculate_image_quality_metrics(@types.Image, @types.Image) -> ImageQualityMetrics
pub fn calculate_psnr_sr(@types.Image, @types.Image) -> Double
pub fn calculate_ssim_sr(@types.Image, @types.Image) -> Double
pub fn create_default_enhancement_config() -> EnhancementConfig
pub fn create_default_interpolation_config() -> InterpolationConfig
pub fn denoise_image(@types.Image, Double) -> @types.Image
pub fn enhance_image(@types.Image, EnhancementConfig) -> @types.Image
pub fn nearest_neighbor_interpolate(@types.Image, Double) -> @types.Image
pub fn sharpen_image(@types.Image, Double) -> @types.Image
pub fn sr_default_config() -> SuperResolutionConfig
pub fn super_resolution(@types.Image, config? : SuperResolutionConfig) -> @types.Image
pub fn super_resolution_bicubic(@types.Image, Double) -> @types.Image
pub fn super_resolution_edge_preserving(@types.Image, Double, edge_threshold? : Double, sharpen_amount? : Double) -> @types.Image
pub fn super_resolution_lanczos(@types.Image, Double, a? : Int) -> @types.Image
pub fn super_resolution_report_to_string(SuperResolutionResult, ImageQualityMetrics) -> String
pub fn super_resolve(@types.Image, InterpolationConfig) -> SuperResolutionResult
pub fn upscale_2x(@types.Image) -> @types.Image
pub fn upscale_4x(@types.Image) -> @types.Image
pub fn SuperResolutionAlgorithm::equal(Self, Self) -> Bool
pub fn SuperResolutionAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
