# 缩放

7 种滤波器 × 4 种边缘模式，支持 8/16/float/sRGB。

## 滤波器

| 滤波器 | 说明 |
|--------|------|
| `Default` | 默认 |
| `Box` | 盒式 |
| `Triangle` | 三角 |
| `CubicBSPline` | 三次 B 样条 |
| `CatmullROM` | Catmull-Rom |
| `Mitchell` | Mitchell-Netravali |
| `PointSample` | 点采样 |

## 边缘模式

| 模式 | 说明 |
|------|------|
| `Clamp` | 钳制 |
| `Reflect` | 反射 |
| `Wrap` | 环绕 |
| `Zero` | 零填充 |

## API

```moonbit
pub fn resize(img : Image, out_w : Int, out_h : Int, ~filter : ResizeFilter = ..., ~edge : ResizeEdge = ...) -> Image raise LoadError
pub fn resize_srgb(img : Image, ...) -> Image raise LoadError
pub fn resize_16(img16 : Image16, ...) -> Image16 raise LoadError
pub fn resizef(imgf : ImageF, ...) -> ImageF raise LoadError
```
