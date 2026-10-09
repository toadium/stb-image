# walkzzz/image/util

> 工具函数（颜色映射、图像合成、统计、像素操作）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 52 |
| 公开类型 | 2 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct ImageStats {
pub(all) struct ImageStatsF {
```

## API

```moonbit
pub fn add_border(@types.Image, Int, Int, Int, Int, Array[Byte]) -> @types.Image raise @types.LoadError
pub fn add_noise_gaussian(@types.Image, Float, UInt) -> @types.Image
pub fn add_noise_salt_pepper(@types.Image, Float, UInt) -> @types.Image
pub fn alpha_blend(@types.Image, @types.Image, Float) -> @types.Image raise @types.LoadError
pub fn apply_lut(@types.Image, Array[Byte]) -> @types.Image raise @types.LoadError
pub fn blend_color_burn(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_color_dodge(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_darken(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_difference(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_exclusion(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_hard_light(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_lighten(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_linear_burn(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_linear_dodge(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_multiply(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_overlay(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_screen(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn blend_soft_light(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn brightness_value(@types.Image) -> Float
pub fn compute_stats(@types.Image) -> ImageStats
pub fn compute_stats_16(@types.Image16) -> ImageStats
pub fn compute_stats_f(@types.ImageF) -> ImageStatsF
pub fn contrast_value(@types.Image) -> Float
pub fn entropy_value(@types.Image) -> Float
pub fn extract_channel(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn fill_alpha(@types.Image, Int, Byte, Byte, Byte) -> @types.Image raise @types.LoadError
pub fn flip_horizontal(@types.Image) -> @types.Image
pub fn flip_vertical(@types.Image) -> @types.Image
pub fn gradient_map(@types.Image, Array[(Int, Byte, Byte, Byte)]) -> @types.Image raise @types.LoadError
pub fn hstack(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn mask_blend(@types.Image, @types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn mean_value(@types.Image) -> Float
pub fn mean_value_16(@types.Image16) -> Float
pub fn mean_value_f(@types.ImageF) -> Float
pub fn median_value(@types.Image) -> Int
pub fn pad(@types.Image, Int, Int, Array[Byte]) -> @types.Image raise @types.LoadError
pub fn pixelate(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn posterize(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn replace_color(@types.Image, Array[Byte], Array[Byte], Int) -> @types.Image raise @types.LoadError
pub fn set_alpha(@types.Image, Byte) -> @types.Image raise @types.LoadError
pub fn swap_channels(@types.Image, Int, Int) -> @types.Image raise @types.LoadError
pub fn threshold(@types.Image, Int) -> @types.Image
pub fn tile(@types.Image, Int, Int) -> @types.Image raise @types.LoadError
pub fn transpose(@types.Image) -> @types.Image
pub fn variance_value(@types.Image) -> Float
pub fn vstack(@types.Image, @types.Image) -> @types.Image raise @types.LoadError
pub fn ImageStats::equal(Self, Self) -> Bool
pub fn ImageStats::not_equal(Self, Self) -> Bool
pub fn ImageStats::to_repr(Self) -> @debug.Repr
pub fn ImageStatsF::equal(Self, Self) -> Bool
pub fn ImageStatsF::not_equal(Self, Self) -> Bool
pub fn ImageStatsF::to_repr(Self) -> @debug.Repr
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
