# walkzzz/image/process/image_colorization_advanced

> 图像上色高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 13 |
| 公开类型 | 11 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ColorCorrectionResult {
pub(all) struct ColorEnhancementResult {
pub(all) struct ColorRestorationResult {
pub(all) enum ColorSpaceType {
pub(all) struct ColorTransferResult {
pub(all) enum ColorizationModelType {
pub(all) struct ColorizationResult {
pub(all) enum ColorizationTaskType {
pub(all) struct ImageColorizationConfig {
pub(all) struct OldPhotoColorizationResult {
pub(all) struct ReferenceColorizationResult {
```

## API

```moonbit
pub fn automatic_colorization(Array[Double], Int, Int, ImageColorizationConfig) -> ColorizationResult
pub fn create_default_colorization_config() -> ImageColorizationConfig
pub fn enhance_colors(Array[Double], Int, Int, ImageColorizationConfig) -> ColorEnhancementResult
pub fn image_colorization_report_to_string(ColorizationTaskType, ImageColorizationConfig, String) -> String
pub fn old_photo_colorization(Array[Double], Int, Int, ImageColorizationConfig) -> OldPhotoColorizationResult
pub fn reference_based_colorization(Array[Double], Array[Double], Int, Int, ImageColorizationConfig) -> ReferenceColorizationResult
pub fn transfer_colors(Array[Double], Array[Double], Int, Int, ImageColorizationConfig) -> ColorTransferResult
pub fn ColorSpaceType::equal(Self, Self) -> Bool
pub fn ColorSpaceType::not_equal(Self, Self) -> Bool
pub fn ColorizationModelType::equal(Self, Self) -> Bool
pub fn ColorizationModelType::not_equal(Self, Self) -> Bool
pub fn ColorizationTaskType::equal(Self, Self) -> Bool
pub fn ColorizationTaskType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
