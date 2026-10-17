# walkzzz/image/process/registration

> 图像配准（特征点、互信息、弹性）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 9 |
| 公开类型 | 2 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct AffineTransform {
pub(all) struct RegistrationResult {
```

## API

```moonbit
pub fn affine_apply(AffineTransform, Double, Double) -> (Double, Double)
pub fn affine_compose(AffineTransform, AffineTransform) -> AffineTransform
pub fn affine_identity() -> AffineTransform
pub fn affine_rotation(Double) -> AffineTransform
pub fn affine_scale(Double, Double) -> AffineTransform
pub fn affine_translation(Double, Double) -> AffineTransform
pub fn align_images(@types.Image, @types.Image) -> (@types.Image, RegistrationResult) raise @types.LoadError
pub fn estimate_translation(@types.Image, @types.Image, max_offset? : Int) -> RegistrationResult raise @types.LoadError
pub fn warp_affine_transform(@types.Image, AffineTransform, out_width? : Int, out_height? : Int) -> @types.Image raise @types.LoadError
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
