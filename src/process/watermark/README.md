# walkzzz/image/process/watermark

> 数字水印（嵌入、提取、鲁棒性）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 8 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct WatermarkConfig {
```

## API

```moonbit
pub fn batch_embed_watermark(Array[@types.Image], @types.Image, key? : Int) -> Array[@types.Image]
pub fn embed_text_watermark(@types.Image, String, key? : Int) -> @types.Image
pub fn embed_watermark_lsb(@types.Image, @types.Image, key? : Int) -> @types.Image
pub fn extract_text_watermark(@types.Image, Int, key? : Int) -> String
pub fn extract_watermark_lsb(@types.Image) -> @types.Image
pub fn watermark_default_config() -> WatermarkConfig
pub fn watermark_psnr(@types.Image, @types.Image) -> Double
pub fn watermark_robustness_test(@types.Image, @types.Image, noise_level? : Double) -> Double
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
