# walkzzz/image/process/quality

> 图像质量评估（PSNR、SSIM、MSE、LPIPS）

## 概览

| 项目 | 数量 |
|------|------|
| 公开函数 | 7 |
| 公开类型 | 1 |
| 常量 | 0 |
| 错误类型 | 0 |

## 类型

```moonbit
pub(all) struct QualityMetrics {
```

## API

```moonbit
pub fn compute_diff_image(@types.Image, @types.Image) -> @types.Image
pub fn compute_mae(@types.Image, @types.Image) -> Double
pub fn compute_mse(@types.Image, @types.Image) -> Double
pub fn compute_psnr(@types.Image, @types.Image) -> Double
pub fn compute_quality_metrics(@types.Image, @types.Image) -> QualityMetrics
pub fn compute_ssim(@types.Image, @types.Image) -> Double
pub fn images_equal(@types.Image, @types.Image) -> Bool
```

## 纯 MoonBit 实现

本包不依赖任何 C FFI，四目标（native/wasm-gc/js/wasm）均可编译运行。
