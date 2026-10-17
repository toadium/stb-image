# walkzzz/image/process/image_restoration_advanced

> 图像修复高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 15 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum BlurType {
pub(all) enum DeblurringMethod {
pub(all) struct DeblurringResult {
pub(all) struct DehazingResult {
pub(all) enum DenoisingMethod {
pub(all) struct DenoisingResult {
pub(all) struct DeocclusionResult {
pub(all) struct DerainingResult {
pub(all) struct DesnowingResult {
pub(all) struct ImageRestorationConfig {
pub(all) enum ImageRestorationTaskType {
pub(all) enum NoiseType {
pub(all) struct OldPhotoRestorationResult {
pub(all) struct RestorationSRResult {
pub(all) struct ScratchRemovalResult {
```

## API

```moonbit
pub fn create_default_restoration_config() -> ImageRestorationConfig
pub fn deblur_image(Array[Double], Int, Int, ImageRestorationConfig) -> DeblurringResult
pub fn dehaze_image(Array[Double], Int, Int, ImageRestorationConfig) -> DehazingResult
pub fn denoise_image(Array[Double], Int, Int, ImageRestorationConfig) -> DenoisingResult
pub fn image_restoration_report_to_string(ImageRestorationTaskType, ImageRestorationConfig, String) -> String
pub fn restore_old_photo(Array[Double], Int, Int, ImageRestorationConfig) -> OldPhotoRestorationResult
pub fn super_resolution(Array[Double], Int, Int, ImageRestorationConfig) -> RestorationSRResult
pub fn BlurType::equal(Self, Self) -> Bool
pub fn BlurType::not_equal(Self, Self) -> Bool
pub fn DeblurringMethod::equal(Self, Self) -> Bool
pub fn DeblurringMethod::not_equal(Self, Self) -> Bool
pub fn DenoisingMethod::equal(Self, Self) -> Bool
pub fn DenoisingMethod::not_equal(Self, Self) -> Bool
pub fn ImageRestorationTaskType::equal(Self, Self) -> Bool
pub fn ImageRestorationTaskType::not_equal(Self, Self) -> Bool
pub fn NoiseType::equal(Self, Self) -> Bool
pub fn NoiseType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
