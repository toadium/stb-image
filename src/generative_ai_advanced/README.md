# walkzzz/image/process/generative_ai_advanced

> 生成式 AI 高级

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 10 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DiffusionConfig {
pub(all) enum DiffusionModelType {
pub(all) struct GANConfig {
pub(all) enum GANType {
pub(all) struct GenerationResult {
pub(all) enum GenerativeAITaskType {
pub(all) struct SamplingConfig {
pub(all) struct TrainingState {
pub(all) struct VAEConfig {
pub(all) enum VAEType {
```

## API

```moonbit
pub fn create_default_diffusion_config() -> DiffusionConfig
pub fn create_default_gan_config() -> GANConfig
pub fn create_default_sampling_config() -> SamplingConfig
pub fn create_default_vae_config() -> VAEConfig
pub fn generate_noise(Int, Int, Int) -> Array[Array[Double]]
pub fn generative_ai_report_to_string(GenerativeAITaskType, GenerationResult, String) -> String
pub fn simulate_diffusion_sampling(DiffusionConfig, SamplingConfig) -> GenerationResult
pub fn simulate_gan_generation(GANConfig, SamplingConfig) -> GenerationResult
pub fn simulate_vae_reconstruction(VAEConfig, Array[Array[Double]]) -> GenerationResult
pub fn DiffusionModelType::equal(Self, Self) -> Bool
pub fn DiffusionModelType::not_equal(Self, Self) -> Bool
pub fn GANType::equal(Self, Self) -> Bool
pub fn GANType::not_equal(Self, Self) -> Bool
pub fn GenerativeAITaskType::equal(Self, Self) -> Bool
pub fn GenerativeAITaskType::not_equal(Self, Self) -> Bool
pub fn VAEType::equal(Self, Self) -> Bool
pub fn VAEType::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
