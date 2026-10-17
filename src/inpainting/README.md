# walkzzz/image/process/inpainting

> 图像修复与补全

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 17 |
| 公开类型 | 7 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) enum DehazeAlgorithm {
pub(all) struct DehazeResult {
pub(all) enum DerainAlgorithm {
pub(all) struct DerainResult {
pub(all) enum InpaintingAlgorithm {
pub(all) struct InpaintingConfig {
pub(all) struct InpaintingResult {
```

## API

```moonbit
pub fn create_default_inpainting_config() -> InpaintingConfig
pub fn create_rect_mask(Int, Int, Int, Int, Int, Int) -> @types.Image
pub fn dehaze(@types.Image, DehazeAlgorithm) -> DehazeResult
pub fn dehaze_clahe(@types.Image, Double, Int) -> @types.Image
pub fn dehaze_dark_channel(@types.Image, Double, Double) -> DehazeResult
pub fn derain(@types.Image, DerainAlgorithm) -> DerainResult
pub fn derain_morphological(@types.Image) -> DerainResult
pub fn inpaint(@types.Image, @types.Image, InpaintingConfig) -> InpaintingResult
pub fn inpaint_diffusion(@types.Image, @types.Image, Int) -> @types.Image
pub fn inpaint_simple(@types.Image, @types.Image, Int) -> @types.Image
pub fn inpainting_report_to_string(InpaintingResult) -> String
pub fn DehazeAlgorithm::equal(Self, Self) -> Bool
pub fn DehazeAlgorithm::not_equal(Self, Self) -> Bool
pub fn DerainAlgorithm::equal(Self, Self) -> Bool
pub fn DerainAlgorithm::not_equal(Self, Self) -> Bool
pub fn InpaintingAlgorithm::equal(Self, Self) -> Bool
pub fn InpaintingAlgorithm::not_equal(Self, Self) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
