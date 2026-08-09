<div align="center">

# stb-image

**MoonBit 图像处理库** — 封装 stb 系列单头文件库，多目标支持

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native%2Bwasm%2Bjs-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-847%20passed-brightgreen)]()
[![Bench](https://img.shields.io/badge/bench-75%20passed-brightgreen)]()
[![ASan](https://img.shields.io/badge/ASan-passed-brightgreen)]()

[快速上手](#-快速上手) · [功能特性](#-功能特性) · [文档](#-文档) · [构建测试](#-构建与测试)

</div>

---

## 📖 简介

MoonBit 原生 FFI 绑定库，封装 [stb_image.h](https://github.com/nothings/stb) v2.30 + [stb_image_write.h](https://github.com/nothings/stb) v1.16 + [stb_image_resize2.h](https://github.com/nothings/stb) v2.07。

**多目标架构**：native 目标使用 C FFI（stb_image），wasm/js 目标使用纯 MoonBit 后端（`src/pure/`）。提供完整图像解码/编码/缩放/处理能力，847 测试 + 75 基准测试全部通过 AddressSanitizer。

---

## 🚀 快速上手

### 安装

```bash
moon add toadium/stb-image
```

### 最小示例

```moonbit
// 从文件解码
let img : Image = load_from_path("photo.png")
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 使用默认滤波器缩放
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_path("animation.gif")
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 读取 EXIF 元数据
let exif : ExifInfo? = read_exif_from_path("photo.jpg")

// 查询图像信息（不解码）
let info : ImageInfo? = info_from_path("large.hdr")
```

### 错误处理

```moonbit
try {
  let img = load_from_bytes(data)
} catch {
  LoadError::FileIO(msg) => println("文件IO错误: \{msg}")
  LoadError::DecodeFailed(msg) => println("解码失败: \{msg}")
  LoadError::UnsupportedFormat(msg) => println("不支持的格式: \{msg}")
}
```

> `UnsupportedFormat` 和 `DecodeFailed` 无法精确区分；stb_image 返回 NULL 时默认为 `DecodeFailed`。使用 `failure_reason()` 获取 stb_image 内部错误字符串。

---

## ✨ 功能特性

### 基础能力

| 能力 | 说明 |
|------|------|
| **格式解码** | 10+ 格式：PNG、JPEG、BMP、GIF、PSD、TGA、HDR、PIC、WebP、PNM (PPM/PGM)、QOI |
| **格式编码** | 8 格式：PNG、BMP、TGA、JPEG、HDR、QOI、GIF、PNM (PPM/PGM) |
| **像素类型** | 8位 `Image`、16位 `Image16`、HDR浮点 `ImageF` |
| **缩放** | 7种滤波器 × 4种边缘模式，支持 8位/16位/浮点/sRGB |
| **格式检测** | `detect_format` / `decode_any` / `is_supported_format` |
| **动画 GIF** | 多帧解码/编码，支持逐帧延迟 |
| **元数据** | EXIF 读取、PNG 文本块 |
| **信息查询** | 不解码像素即可获取尺寸 |

### 图像处理

| 类别 | 功能 |
|------|------|
| **几何变换** | 裁剪、旋转（90°/180°/270°/任意角度）、翻转、仿射变换 |
| **色彩** | 亮度/对比度/伽马/反色调整、HSV/HSL 转换、灰度/RGB/RGBA 转换 |
| **滤波器** | 方框模糊、高斯模糊、锐化、Sobel/Laplacian/Prewitt 边缘检测 |
| **直方图** | 计算、均衡化、归一化 |
| **量化** | Floyd-Steinberg 抖动、中位切割 |
| **形态学** | 腐蚀、膨胀、开运算、闭运算（3×3 结构元素） |
| **绘制** | 图像复制、Alpha 混成 |
| **混合模式** | 13 种（正片叠底、滤色、叠加、变暗/变亮、差值、排除等） |
| **质量评估** | MSE、PSNR、SSIM |

### 高级分析

| 类别 | 功能 |
|------|------|
| **CLAHE** | 对比度受限自适应直方图均衡 |
| **K-means** | 色彩量化、颜色分割、区域生长、泛洪填充 |
| **FFT** | 频域变换、频域滤波（低通/高通/带通/带阻） |
| **自适应阈值** | 均值法、高斯加权法、Otsu 大津法 |
| **连通域** | 4/8 连通标记，含面积/边界框/质心 |
| **积分图像** | O(1) 矩形区域求和/均值/方差查询 |
| **霍夫变换** | 直线检测，含非极大值抑制 |
| **LBP** | 局部二值模式（基本 + 均匀） |
| **图像金字塔** | 高斯/拉普拉斯金字塔构建与上下采样 |
| **双边滤波** | 保边去噪（完整版 + 快速版） |
| **轮廓提取** | Moore 边界跟踪，周长，面积 |
| **NLM 去噪** | 非局部均值（完整版 + 快速版） |
| **Retinex** | SSR、MSR、MSRCR（多尺度带颜色恢复） |
| **Canny 边缘** | 高斯 → Sobel → 非极大值抑制 → 滞后连接 |
| **分水岭** | 沉浸式分割，自动寻找种子 |
| **GLCM 纹理** | 对比度/相关性/能量/同质性/熵（4 方向） |
| **Haar 小波** | 1D/2D 变换，多级分解，去噪 |
| **Harris 角点** | 结构张量 + 非极大值抑制 + 距离过滤 |
| **去雾** | 暗通道先验 + 引导滤波 |
| **距离变换** | L1/L2/L∞ 距离，骨架化 |
| **Gabor 滤波** | 多方向多尺度纹理分析 |

### 多目标支持

| 目标 | 后端 | 测试 |
|------|------|------|
| **native** | C FFI（stb_image） | 847 测试 + 75 基准测试 |
| **wasm/js** | 纯 MoonBit 后端（`src/pure/`） | 225 测试 |

纯 MoonBit 后端含 6 解码器（BMP/QOI/TGA/PNM/PSD/GIF）+ 3 编码器（QOI/PNM/GIF）+ 完整图像处理。

---

## 📄 文档

| 文档 | 说明 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 架构图、包依赖关系、FFI 边界、数据流、设计决策 |
| [docs/api_reference.md](docs/api_reference.md) | 完整 API 参考（196 个函数，27 个类型） |
| [docs/changelog.md](docs/changelog.md) | 版本历史与上游来源 |
| [docs/roadmap.md](docs/roadmap.md) | 迭代路线图 |
| [docs/comparison.md](docs/comparison.md) | mooncakes.io 图像库对比 |
| [docs/skill.md](docs/skill.md) | 包使用指南 |

---

## 🔧 构建与测试

```bash
moon check --target native     # 检查编译
moon test --target native      # 运行 847 个测试
moon bench --target native     # 运行 75 个基准测试
moon info                      # 重新生成 API 接口
```

---

## ⚠️ 限制

- **I/O 回调**（`stbi_io_callbacks`）：未实现。MoonBit FFI 不支持将闭包作为 C 函数指针传递。
- **零拷贝**：未实现。所有加载路径通过 `memcpy` 将像素数据从 C 缓冲区复制到 MoonBit `Bytes`。

---

## 📄 许可证

MIT 许可证 — 详见 [LICENSE](LICENSE)。

stb_image.h、stb_image_write.h 和 stb_image_resize2.h 属于公共领域（Sean Barrett）。

---

如果对你有用，欢迎 Star ⭐，感谢支持！
