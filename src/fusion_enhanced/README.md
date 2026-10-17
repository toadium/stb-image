# walkzzz/image/process/fusion_enhanced

> 增强图像融合

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 20 |
| 公开类型 | 7 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum FusionAlgorithm {
pub(all) struct FusionConfig {
pub(all) struct FusionResult {
pub(all) enum RegistrationAlgorithm {
pub(all) struct RegistrationConfig {
pub(all) struct RegistrationResult {
pub(all) struct TransformMatrix {
```

## API

```moonbit
pub fn apply_translation(@types.Image, Int, Int) -> @types.Image
pub fn calculate_fusion_quality(@types.Image) -> Double
pub fn create_default_fusion_config() -> FusionConfig
pub fn create_default_registration_config() -> RegistrationConfig
pub fn downsample_fe(@types.Image) -> @types.Image
pub fn fuse_images(Array[@types.Image], FusionConfig) -> FusionResult
pub fn fuse_laplacian_pyramid(Array[@types.Image], Int) -> @types.Image
pub fn fuse_maximum(Array[@types.Image]) -> @types.Image
pub fn fuse_minimum(Array[@types.Image]) -> @types.Image
pub fn fuse_simple_mean(Array[@types.Image]) -> @types.Image
pub fn fuse_weighted_average(Array[@types.Image], Array[Double]) -> @types.Image
pub fn fusion_report_to_string(FusionResult, Double) -> String
pub fn gaussian_blur_fe(@types.Image, Int) -> @types.Image
pub fn register_images(@types.Image, @types.Image, RegistrationConfig) -> RegistrationResult
pub fn register_phase_correlation(@types.Image, @types.Image) -> RegistrationResult
pub fn upsample_fe(@types.Image) -> @types.Image
pub fn FusionAlgorithm::equal(Self, Self) -> Bool
pub fn FusionAlgorithm::not_equal(Self, Self) -> Bool
pub fn RegistrationAlgorithm::equal(Self, Self) -> Bool
pub fn RegistrationAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
