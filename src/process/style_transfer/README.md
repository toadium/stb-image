# walkzzz/image/process/style_transfer

> 风格迁移（NST、快速风格化）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 13 |
| 公开类型 | 6 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum ArtStyle {
pub(all) struct ColorStatistics {
pub(all) enum StyleTransferAlgorithm {
pub(all) struct StyleTransferConfig {
pub(all) struct StyleTransferResult {
pub(all) struct StyleTransferTextureFeatures {
```

## API

```moonbit
pub fn calculate_color_statistics(@types.Image) -> ColorStatistics raise @types.LoadError
pub fn calculate_texture_features(@types.Image) -> StyleTransferTextureFeatures raise @types.LoadError
pub fn cartoonize(@types.Image, Double) -> @types.Image raise @types.LoadError
pub fn color_transfer(@types.Image, @types.Image, Double) -> @types.Image raise @types.LoadError
pub fn create_default_style_transfer_config() -> StyleTransferConfig
pub fn oil_painting(@types.Image, Int, Int) -> @types.Image raise @types.LoadError
pub fn sketch_effect(@types.Image, Double) -> @types.Image raise @types.LoadError
pub fn style_transfer(@types.Image, @types.Image, StyleTransferConfig) -> StyleTransferResult raise @types.LoadError
pub fn style_transfer_report_to_string(StyleTransferResult, ColorStatistics, ColorStatistics, StyleTransferTextureFeatures) -> String
pub fn ArtStyle::equal(Self, Self) -> Bool
pub fn ArtStyle::not_equal(Self, Self) -> Bool
pub fn StyleTransferAlgorithm::equal(Self, Self) -> Bool
pub fn StyleTransferAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
