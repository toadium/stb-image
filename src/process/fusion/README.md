# walkzzz/image/process/fusion

> 图像融合（拉普拉斯金字塔、小波、多曝光融合）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 5 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct FusionConfig {
```

## API

```moonbit
pub fn fuse_alpha(@types.Image, @types.Image, alpha? : Double) -> @types.Image
pub fn fuse_exposure(Array[@types.Image]) -> @types.Image
pub fn fuse_images(@types.Image, @types.Image, config? : FusionConfig) -> @types.Image
pub fn fuse_multifocus(@types.Image, @types.Image) -> @types.Image
pub fn fusion_default_config() -> FusionConfig
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
