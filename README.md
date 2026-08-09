<div align="center">

# image

**MoonBit 图像处理库** — 纯 MoonBit 实现，native/wasm-gc/js 三目标支持

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-native%2Bwasm%2Bjs-blue)](https://www.moonbitlang.com/)
[![Tests](https://img.shields.io/badge/tests-645%20passed%20%C3%973%20targets-brightgreen)]()

[快速上手](#-快速上手) · [功能特性](#-功能特性) · [文档](#-文档) · [构建测试](#-构建与测试)

</div>

---

## 📖 简介

纯 MoonBit 图像处理库，无 C FFI 依赖。支持 PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM 等格式的解码与编码，以及完整的图像处理能力（几何变换、色彩调整、滤波、形态学、直方图、频域分析、特征检测等）。

**三目标支持**：native、wasm-gc、js 均编译通过，各 645 测试全部通过。

---

## 🚀 快速上手

### 安装

```bash
moon add toadium/image
```

### 最小示例

```moonbit
// 从字节解码
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 使用默认滤波器缩放
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_bytes(gif_bytes)
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 查询图像信息（不解码）
let info : ImageInfo? = info_from_bytes(data)
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

---

## ✨ 功能特性

### 基础能力

| 能力 | 说明 |
|------|------|
| **格式解码** | PNG、JPEG、BMP、GIF、PSD、TGA、HDR、PNM (PPM/PGM)、QOI |
| **格式编码** | PNG、BMP、TGA、JPEG、HDR、QOI、GIF、PNM (PPM/PGM) |
| **像素类型** | 8位 `Image`、16位 `Image16`、HDR浮点 `ImageF` |
| **缩放** | 多种滤波器 × 边缘模式 |
| **格式检测** | `detect_format` / `decode_any` |
| **动画 GIF** | 多帧解码/编码，支持逐帧延迟 |
| **元数据** | EXIF 读取、PNG 文本块 |
| **信息查询** | 不解码像素即可获取尺寸 |

### 图像处理

| 类别 | 功能 |
|------|------|
| **几何变换** | 裁剪、旋转（90°/180°/270°/任意角度）、翻转、仿射变换 |
| **色彩** | 亮度/对比度/伽马/反色调整、HSV/HSL 转换、灰度/RGB/RGBA 转换 |
| **滤波器** | 方框模糊、高斯模糊、锐化、Sobel 边缘检测 |
| **直方图** | 计算、均衡化、归一化 |
| **形态学** | 腐蚀、膨胀、开运算、闭运算 |
| **混合模式** | 13 种（正片叠底、滤色、叠加、变暗/变亮、差值、排除等） |
| **质量评估** | MSE、PSNR、SSIM |

### 高级分析

| 类别 | 功能 |
|------|------|
| **CLAHE** | 对比度受限自适应直方图均衡 |
| **K-means** | 色彩量化、颜色分割、区域生长、泛洪填充 |
| **FFT** | 频域变换、频域滤波 |
| **自适应阈值** | 均值法、高斯加权法、Otsu 大津法 |
| **连通域** | 4/8 连通标记 |
| **积分图像** | O(1) 矩形区域求和/均值/方差查询 |
| **霍夫变换** | 直线检测 |
| **LBP** | 局部二值模式 |
| **图像金字塔** | 高斯/拉普拉斯金字塔 |
| **双边滤波** | 保边去噪 |
| **Canny 边缘** | 高斯 → Sobel → 非极大值抑制 → 滞后连接 |
| **分水岭** | 沉浸式分割 |
| **GLCM 纹理** | 对比度/相关性/能量/同质性/熵 |
| **Haar 小波** | 1D/2D 变换，多级分解 |
| **Harris 角点** | 结构张量 + 非极大值抑制 |
| **去雾** | 暗通道先验 + 引导滤波 |
| **Retinex** | SSR、MSR、MSRCR |
| **Gabor 滤波** | 多方向多尺度纹理分析 |

### 多目标支持

| 目标 | 后端 | 测试 |
|------|------|------|
| **native** | 纯 MoonBit | 645 passed |
| **wasm-gc** | 纯 MoonBit | 645 passed |
| **js** | 纯 MoonBit | 645 passed |

---

## 📦 包结构

```
src/
├── types/              # 基础类型 (Image, Image16, ImageF, LoadError 等)
├── pure/               # 纯 MoonBit 实现 (无 C FFI)
│   ├── codec/          # 格式编解码 (20 文件: BMP/GIF/JPEG/PNG/PNM/QOI/TGA/PSD/HDR)
│   ├── pixel/          # 像素操作 (pixel_ops, pixel_advanced)
│   ├── color/          # 颜色操作 (color_adjust, color_convert, color_map)
│   ├── process/        # 图像处理 (filter, geometry, transform, morphology, blend 等)
│   └── util/           # 工具 (config, image_info, resize, zlib)
├── lib/                # 高层封装 (自动格式分派)
├── format/             # 格式扩展 (gif_animation, qoi, pnm 编码)
├── meta/               # 元数据 (EXIF, PNG meta)
├── process/            # 高级图像处理算法
│   ├── color/          # CLAHE, Retinex, 去雾, 颜色分割
│   ├── edge/           # Canny, Hough, 轮廓提取
│   ├── feature/        # Harris, LBP, GLCM, Gabor, 积分图像
│   ├── filter/         # 双边滤波, NLM 去噪
│   ├── frequency/      # FFT, Haar 小波
│   ├── segment/        # K-means, 分水岭, 形态学
│   └── transform/      # 几何变换, 绘制, 金字塔
├── util/               # 工具函数 (基于 pure 的上层封装)
├── testdata/           # 测试数据
└── reexport.mbt        # 顶层 API re-export
```

---

## 📄 文档

| 文档 | 说明 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 架构图、包依赖关系 |
| [docs/api_reference.md](docs/api_reference.md) | API 参考 |
| [docs/roadmap.md](docs/roadmap.md) | 迭代路线图 |
| [docs/comparison.md](docs/comparison.md) | 图像库对比 |

---

## 🔧 构建与测试

```bash
moon check                       # 检查编译 (native 默认)
moon check --target wasm-gc      # 检查 wasm-gc 编译
moon check --target js           # 检查 js 编译
moon test --target native        # 运行 native 测试 (645)
moon test --target wasm-gc       # 运行 wasm-gc 测试 (645)
moon test --target js            # 运行 js 测试 (645)
moon info                        # 重新生成 API 接口
```

---

## 📄 许可证

MIT 许可证 — 详见 [LICENSE](LICENSE)。

---

如果对你有用，欢迎 Star ⭐，感谢支持！
