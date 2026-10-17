# walkzzz/image/process/stylize

> 图像风格化处理

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 6 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct StylizeConfig {
```

## API

```moonbit
pub fn cartoon(@types.Image, levels? : Int, edge_threshold? : Double) -> @types.Image
pub fn oil_paint(@types.Image, radius? : Int, intensity? : Int) -> @types.Image
pub fn sketch(@types.Image, blend? : Double) -> @types.Image
pub fn stylize(@types.Image, String, config? : StylizeConfig) -> @types.Image
pub fn stylize_default_config() -> StylizeConfig
pub fn watercolor(@types.Image, blur_radius? : Int) -> @types.Image
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
