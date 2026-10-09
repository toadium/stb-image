# walkzzz/image/process/vlm_multimodal

> 视觉语言多模态

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 19 |
| 公开类型 | 12 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DiffusionConfig {
pub(all) enum DiffusionModelType {
pub(all) struct DiffusionResult {
pub(all) struct FusionConfig {
pub(all) struct FusionResult {
pub(all) struct GenerativeAIConfig {
pub(all) struct GenerativeAIResult {
pub(all) enum GenerativeAITaskType {
pub(all) enum MultimodalFusionStrategy {
pub(all) struct VLMConfig {
pub(all) enum VisionLanguageModelType {
pub(all) struct VisionTextEmbedding {
```

## API

```moonbit
pub fn compute_image_text_similarity(@types.Image, String, VLMConfig) -> VisionTextEmbedding
pub fn create_default_diffusion_config() -> DiffusionConfig
pub fn create_default_fusion_config() -> FusionConfig
pub fn create_default_genai_config() -> GenerativeAIConfig
pub fn create_default_vlm_config() -> VLMConfig
pub fn diffusion_generate(String, String, DiffusionConfig, Int) -> DiffusionResult
pub fn fuse_modalities(Array[Double], Array[Double], FusionConfig) -> FusionResult
pub fn fusion_report_to_string(FusionResult) -> String
pub fn image_to_text(@types.Image, GenerativeAIConfig) -> GenerativeAIResult
pub fn text_to_image(String, GenerativeAIConfig, Int) -> GenerativeAIResult
pub fn vlm_report_to_string(VisionTextEmbedding, VisionLanguageModelType) -> String
pub fn DiffusionModelType::equal(Self, Self) -> Bool
pub fn DiffusionModelType::not_equal(Self, Self) -> Bool
pub fn GenerativeAITaskType::equal(Self, Self) -> Bool
pub fn GenerativeAITaskType::not_equal(Self, Self) -> Bool
pub fn MultimodalFusionStrategy::equal(Self, Self) -> Bool
pub fn MultimodalFusionStrategy::not_equal(Self, Self) -> Bool
pub fn VisionLanguageModelType::equal(Self, Self) -> Bool
pub fn VisionLanguageModelType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
