# walkzzz/image/process/enhance

> 图像增强（直方图均衡、对比度、锐化）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 24 |
| 公开类型 | 4 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct DehazeConfig {
pub(all) struct HdrConfig {
pub(all) struct InpaintConfig {
pub(all) struct NlmConfig {
```

## API

```moonbit
pub fn create_rect_mask(Int, Int, Int, Int, Int, Int) -> @types.Image raise @types.LoadError
pub fn dark_channel(@types.Image, patch_size? : Int) -> @types.Image raise @types.LoadError
pub fn dehaze_advanced(@types.Image, config? : DehazeConfig) -> @types.Image raise @types.LoadError
pub fn dehaze_default_config() -> DehazeConfig
pub fn dehaze_recover(@types.Image, @types.Image, Array[Int], t_min? : Double) -> @types.Image raise @types.LoadError
pub fn denoise(@types.Image, String) -> @types.Image raise @types.LoadError
pub fn denoise_bilateral(@types.Image, diameter? : Int, sigma_color? : Double, sigma_space? : Double) -> @types.Image raise @types.LoadError
pub fn denoise_median(@types.Image, kernel_size? : Int) -> @types.Image raise @types.LoadError
pub fn denoise_nlm(@types.Image, config? : NlmConfig) -> @types.Image raise @types.LoadError
pub fn estimate_atmospheric_light(@types.Image, @types.Image, top_percent? : Int) -> Array[Int] raise @types.LoadError
pub fn estimate_transmission(@types.Image, Array[Int], omega? : Double, patch_size? : Int) -> @types.Image raise @types.LoadError
pub fn guided_filter_image(@types.Image, @types.Image, radius? : Int, eps? : Double) -> @types.Image raise @types.LoadError
pub fn hdr_default_config() -> HdrConfig
pub fn hdr_fusion_average(Array[@types.Image]) -> @types.Image raise @types.LoadError
pub fn hdr_fusion_weighted(Array[@types.Image]) -> @types.Image raise @types.LoadError
pub fn hdr_process(Array[@types.Image], config? : HdrConfig) -> @types.Image raise @types.LoadError
pub fn inpaint_advanced(@types.Image, @types.Image, radius? : Int) -> @types.Image raise @types.LoadError
pub fn inpaint_default_config() -> InpaintConfig
pub fn nlm_default_config() -> NlmConfig
pub fn remove_small_objects(@types.Image, max_size? : Int) -> @types.Image raise @types.LoadError
pub fn remove_watermark(@types.Image, Int, Int, Int, Int) -> @types.Image raise @types.LoadError
pub fn tone_mapping_gamma(@types.Image, gamma? : Double) -> @types.Image raise @types.LoadError
pub fn tone_mapping_reinhard(@types.Image, key? : Double) -> @types.Image raise @types.LoadError
pub fn tone_mapping_sigmoid(@types.Image, strength? : Double) -> @types.Image raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
