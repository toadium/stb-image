# walkzzz/image/process/computational_photography_advanced

> computational_photography_advanced 图像处理模块

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 19 |
| 公开类型 | 14 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ColorManagementResult {
pub(all) struct ComputationalPhotographyConfig {
pub(all) struct ComputationalPhotographySRResult {
pub(all) enum ComputationalPhotographyTaskType {
pub(all) enum DeblurringMethod {
pub(all) struct DeblurringResult {
pub(all) enum DehazingMethod {
pub(all) struct DehazingResult {
pub(all) struct FocusStackingResult {
pub(all) struct HDRImage {
pub(all) enum HDRToneMappingMethod {
pub(all) struct MultiFrameDenoisingResult {
pub(all) struct PanoramaImage {
pub(all) enum PanoramaStitchingMethod {
```

## API

```moonbit
pub fn computational_photography_report_to_string(ComputationalPhotographyTaskType, ComputationalPhotographyConfig, String) -> String
pub fn create_default_computational_photography_config() -> ComputationalPhotographyConfig
pub fn create_hdr_image(Array[Array[Double]], Array[Double], Int, Int, ComputationalPhotographyConfig) -> HDRImage
pub fn deblur_image(Array[Double], Int, Int, ComputationalPhotographyConfig) -> DeblurringResult
pub fn dehaze_image(Array[Double], Int, Int, ComputationalPhotographyConfig) -> DehazingResult
pub fn focus_stack(Array[Array[Double]], Int, Int, ComputationalPhotographyConfig) -> FocusStackingResult
pub fn multi_frame_denoise(Array[Array[Double]], Int, Int, ComputationalPhotographyConfig) -> MultiFrameDenoisingResult
pub fn stitch_panorama(Array[Array[Double]], Int, Int, ComputationalPhotographyConfig) -> PanoramaImage
pub fn tone_map_hdr(HDRImage, ComputationalPhotographyConfig) -> Array[Double]
pub fn ComputationalPhotographyTaskType::equal(Self, Self) -> Bool
pub fn ComputationalPhotographyTaskType::not_equal(Self, Self) -> Bool
pub fn DeblurringMethod::equal(Self, Self) -> Bool
pub fn DeblurringMethod::not_equal(Self, Self) -> Bool
pub fn DehazingMethod::equal(Self, Self) -> Bool
pub fn DehazingMethod::not_equal(Self, Self) -> Bool
pub fn HDRToneMappingMethod::equal(Self, Self) -> Bool
pub fn HDRToneMappingMethod::not_equal(Self, Self) -> Bool
pub fn PanoramaStitchingMethod::equal(Self, Self) -> Bool
pub fn PanoramaStitchingMethod::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
