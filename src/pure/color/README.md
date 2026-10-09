# walkzzz/image/pure/color

> 纯 MoonBit 颜色操作（色彩空间转换、调整、映射）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 6 |
| 公开类型 | 0 |
| 常量 | 0 |
| 错误类型 | 0 |

## API

```moonbit
pub fn convert_channels_pure(@types.Image, Int) -> @types.Image raise @types.LoadError
pub fn premultiply_alpha_pure(@types.Image) -> @types.Image raise @types.LoadError
pub fn to_grayscale_pure(@types.Image) -> @types.Image
pub fn to_rgb_pure(@types.Image) -> @types.Image
pub fn to_rgba_pure(@types.Image) -> @types.Image
pub fn unpremultiply_alpha_pure(@types.Image) -> @types.Image raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
