# walkzzz/image/process/image_generation

> 图像生成

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 8 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct CompositionConfig {
pub(all) struct EditingConfig {
pub(all) struct EditingResult {
pub(all) struct GenerationConfig {
pub(all) struct GenerationResult {
pub(all) enum ImageEditingAlgorithm {
pub(all) enum ImageGenerationAlgorithm {
pub(all) struct LatentVector {
```

## API

```moonbit
pub fn colorize_image(@types.Image, EditingConfig) -> EditingResult
pub fn compose_images(@types.Image, @types.Image, @types.Image, CompositionConfig) -> @types.Image
pub fn create_default_editing_config() -> EditingConfig
pub fn create_default_generation_config() -> GenerationConfig
pub fn edit_image(@types.Image, @types.Image, EditingConfig) -> EditingResult
pub fn editing_report_to_string(EditingResult) -> String
pub fn generate_from_latent(LatentVector, GenerationConfig) -> GenerationResult
pub fn generate_random_image(GenerationConfig) -> GenerationResult
pub fn generate_random_latent(Int, Int) -> LatentVector
pub fn generation_report_to_string(GenerationResult) -> String
pub fn inpaint_image(@types.Image, @types.Image, EditingConfig) -> EditingResult
pub fn outpaint_image(@types.Image, Int, Int, EditingConfig) -> EditingResult
pub fn remove_background(@types.Image, EditingConfig) -> EditingResult
pub fn ImageEditingAlgorithm::equal(Self, Self) -> Bool
pub fn ImageEditingAlgorithm::not_equal(Self, Self) -> Bool
pub fn ImageGenerationAlgorithm::equal(Self, Self) -> Bool
pub fn ImageGenerationAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
