# walkzzz/image/process/image_generation_advanced

> 图像生成高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 18 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ColorizationResult {
pub(all) enum DiffusionModelType {
pub(all) enum GANType {
pub(all) struct GeneratedImage {
pub(all) enum GenerativeModelType {
pub(all) struct ImageGenerationConfig {
pub(all) enum ImageGenerationTaskType {
pub(all) struct ImageToImageResult {
pub(all) struct InpaintingResult {
pub(all) struct StyleTransferResult {
pub(all) struct TextToImageResult {
pub(all) enum VAEType {
```

## API

```moonbit
pub fn create_default_generation_config() -> ImageGenerationConfig
pub fn diffuse_sample(Array[Double], Int, Int) -> Array[Double]
pub fn generate_noise(Int, Int, Int, Int) -> Array[Double]
pub fn image_generation_report_to_string(ImageGenerationTaskType, ImageGenerationConfig, String) -> String
pub fn image_to_image(Array[Double], ImageGenerationConfig) -> ImageToImageResult
pub fn inpaint_image(Array[Double], Array[Bool], Int, Int, ImageGenerationConfig) -> InpaintingResult
pub fn text_to_image(ImageGenerationConfig) -> TextToImageResult
pub fn transfer_style(Array[Double], Array[Double], Int, Int, ImageGenerationConfig) -> StyleTransferResult
pub fn DiffusionModelType::equal(Self, Self) -> Bool
pub fn DiffusionModelType::not_equal(Self, Self) -> Bool
pub fn GANType::equal(Self, Self) -> Bool
pub fn GANType::not_equal(Self, Self) -> Bool
pub fn GenerativeModelType::equal(Self, Self) -> Bool
pub fn GenerativeModelType::not_equal(Self, Self) -> Bool
pub fn ImageGenerationTaskType::equal(Self, Self) -> Bool
pub fn ImageGenerationTaskType::not_equal(Self, Self) -> Bool
pub fn VAEType::equal(Self, Self) -> Bool
pub fn VAEType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
