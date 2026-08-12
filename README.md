<div align="center">

# image

**纯 MoonBit 图像处理库** · 零 C 依赖 · 四目标原生支持

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.20260713-blue)](https://www.moonbitlang.com/)
[![Targets](https://img.shields.io/badge/targets-native%20%7C%20wasm--gc%20%7C%20js%20%7C%20wasm-success)]()
[![Tests](https://img.shields.io/badge/tests-1054%20%C3%97%204%20targets-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-89.8%25-brightgreen)]()
[![Functions](https://img.shields.io/badge/API-282%20functions%20%2B%2047%20types-blueviolet)]()
[![Version](https://img.shields.io/badge/version-4.7.0-orange)]()

[亮点](#-亮点) · [格式支持](#-格式支持) · [快速上手](#-快速上手) · [功能一览](#-功能一览) · [多目标](#-多目标支持) · [包结构](#-包结构) · [文档](#-文档) · [构建](#-构建与测试) · [贡献](#-贡献)

</div>

---

## 📖 简介

`image` 是一个纯 MoonBit 实现的图像处理库，**无任何 C FFI 依赖**。覆盖 15 种格式的解码与编码，提供从基础像素操作到高级计算机视觉算法的完整能力。

> [!NOTE]
> `detect_format` 仅通过 magic bytes 识别 PNG/JPEG/BMP/GIF/QOI/PNM/PSD/HDR/WebP。TIFF/ICO/CUR/ICNS/APNG/TGA 需手动调用 `decode_tiff`/`decode_ico`/`decode_cur`/`decode_icns`/`decode_apng` 等函数。

> [!NOTE]
> 四目标（native / wasm-gc / js / wasm）均使用同一套纯 MoonBit 代码，各 1054 测试全部通过，覆盖率 89.8%。

> [!TIP]
> **v4.7 最新更新** — SIFT 特征检测 · SIFT 匹配 + RANSAC 单应性估计 · grabCut 分割 · 流式解码（逐行/分块/指定通道）

---

## ✨ 亮点

| | 特性 | 说明 |
|---|---|---|
| 🟢 | **零 C 依赖** | 全部纯 MoonBit 实现，无需 C 编译器，部署极简 |
| 🟢 | **四目标支持** | native / wasm-gc / js / wasm 共用同一代码库，无条件编译 |
| 🟢 | **格式覆盖广** | PNG / JPEG / BMP / GIF / QOI / TGA / PSD / HDR / PNM / TIFF / APNG / WebP — 含独家 PSD、HDR |
| 🟢 | **像素深度全** | 8 位 `Image`、16 位 `Image16`、HDR 浮点 `ImageF` |
| 🟢 | **282 个 API** | 从基础 I/O 到 FFT、Canny、分水岭、SLIC、ORB、SIFT、SIFT 匹配、RANSAC 单应性、grabCut、流式解码、光流、模板匹配等高级算法 |
| 🟢 | **流式解码** | 逐行 / 分块 / 指定通道回调，大图处理零内存峰值 |
| 🟢 | **多子包架构** | 8 个子包职责清晰，编译并行化，可独立测试 |

---

## 🖼️ 格式支持

| 格式 | 解码 | 编码 | 备注 |
|:----:|:----:|:----:|------|
| PNG | ✅ | ✅ | 8/16-bit，Adam7 隔行扫描 |
| JPEG | ✅ | ✅ | baseline，可调质量 |
| BMP | ✅ | ✅ | 1/4/8/16/24/32-bit |
| GIF | ✅ | ✅ | 动画 GIF 解码/编码 |
| QOI | ✅ | ✅ | Quite OK Image |
| TGA | ✅ | ✅ | 含 RLE |
| PSD | ✅ | — | Photoshop 文档（独家） |
| HDR | ✅ | ✅ | IEEE 754 浮点（独家） |
| PNM | ✅ | ✅ | PPM / PGM |
| TIFF | ✅ | ✅ | 无压缩/LZW/PackBits |
| ICO | ✅ | ✅ | 单尺寸/多尺寸 |
| CUR | ✅ | ✅ | Windows 光标 |
| ICNS | ✅ | ✅ | macOS 图标 |
| APNG | ✅ | ✅ | 动画 PNG |
| WebP | ✅ | — | lossless (VP8L) |

---

## 🚀 快速上手

### 安装

```bash
moon add Toadium/image
```

### 最小示例

```moonbit
// 从字节解码
let img : Image = load_from_bytes(png_bytes)
println("width=\{img.width}, height=\{img.height}, channels=\{img.channels}")

// 编码为 PNG 字节
let out : Bytes = write_png_to_bytes(img)

// 缩放（7 种滤波器 × 4 种边缘模式）
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_bytes(gif_bytes)
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 查询图像信息（不解码像素）
let info : ImageInfo? = info_from_bytes(data)

// 流式解码：逐行回调，大图零内存峰值
decode_stream(data, fn(row, y) {
  // 处理第 y 行像素 row : Array[Array[Int]]
})
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

### 高级示例：SIFT 特征匹配

```moonbit
// 检测 SIFT 特征
let kp1 = sift_detect(img1)
let kp2 = sift_detect(img2)

// L2 距离 + Lowe 比率测试匹配
let matches = sift_match(kp1, kp2, ratio_threshold=0.75)

// RANSAC 鲁棒单应性估计
let homography = ransac_homography(matches, threshold=5.0, iterations=1000)
```

---

## 🧰 功能一览

| 分类 | 关键函数 | 说明 |
|------|---------|------|
| **编解码** | `load_from_bytes`, `write_png_to_bytes`, `decode_any`, `decode_stream` | 15 种格式：PNG/JPEG/BMP/GIF/QOI/TGA/PSD/HDR/PNM/TIFF/ICO/CUR/ICNS/APNG/WebP |
| **流式解码** | `decode_stream`, `decode_stream_chunked`, `decode_stream_channels` | 逐行 / 分块 / 指定通道回调，大图零内存峰值 |
| **几何变换** | `resize`, `crop`, `rotate`, `warp_affine`, `warp_perspective` | 缩放/裁剪/旋转/仿射/透视，7 种滤波器 × 4 种边缘模式 |
| **色彩** | `to_grayscale`, `adjust_gamma`, `rgb_to_hsv`, `clahe` | 色彩转换/调整/空间变换/CLAHE |
| **滤波** | `gaussian_blur`, `bilateral_filter`, `nlm_denoise`, `inpaint` | 高斯/双边/NLM 去噪/图像修复 |
| **边缘** | `canny_edge`, `hough_lines`, `hough_circles`, `find_contours` | Canny/霍夫直线圆/轮廓提取 |
| **特征** | `harris_corners`, `orb_detect`, `sift_detect`, `template_match` | Harris/ORB/SIFT/模板匹配 |
| **特征匹配** | `sift_match`, `ransac_homography` | L2 距离 + Lowe 比率测试 / RANSAC + DLT 单应性估计 |
| **光流** | `lucas_kanade` | Lucas-Kanade 稀疏光流 |
| **分割** | `watershed`, `slic`, `kmeans_segment`, `grab_cut`, `connected_components` | 分水岭/SLIC/K-means/grabCut/连通域 |
| **形态学** | `erode`, `dilate`, `morph_open`, `skeletonize` | 腐蚀/膨胀/开闭运算/骨架化 |
| **频域** | `fft_2d`, `dct_2d`, `haar_transform_2d`, `freq_filter` | FFT/DCT/Haar 小波/频率滤波 |
| **质量** | `mse`, `psnr`, `ssim`, `compute_stats` | MSE/PSNR/SSIM/统计 |

## 🎯 多目标支持

| 目标 | 后端 | 测试 | 状态 |
|:----:|:----:|:----:|:----:|
| **native** | 纯 MoonBit | 1054 | ✅ |
| **wasm-gc** | 纯 MoonBit | 1054 | ✅ |
| **js** | 纯 MoonBit | 1054 | ✅ |
| **wasm** | 纯 MoonBit | 1054 | ✅ |

> [!TIP]
> 四目标共用 `src/pure/` 下的同一套代码，无任何条件编译或目标分支。

---

## 📦 包结构

```
src/
├── types/              # 全目标类型 (Image, Image16, ImageF, LoadError 等)
├── pure/               # 纯 MoonBit 后端 (无 C FFI)
│   ├── codec/          #   格式编解码 (15 种格式)
│   ├── color/          #   颜色操作
│   └── util/           #   工具
├── lib/                # 高层封装 (自动格式分派)
├── meta/               # 元数据 (EXIF, PNG meta)
├── process/            # 高级图像处理算法 (7 子包)
│   ├── color/          #   色彩转换/调整/CLAHE/自适应阈值
│   ├── edge/           #   边缘检测/Canny/霍夫/轮廓
│   ├── feature/        #   特征检测: Harris/ORB/SIFT/模板匹配/光流/GLCM/LBP
│   ├── filter/         #   滤波/去噪/图像修复
│   ├── frequency/      #   FFT/DCT/Haar 小波/频率滤波
│   ├── segment/        #   分水岭/SLIC/grabCut/形态学/连通域
│   └── transform/      #   几何变换/透视/Seam Carving/金字塔
├── util/               # 工具函数 (基于 pure 的上层封装)
├── bench.mbt           # 性能基准测试
└── reexport.mbt        # 顶层 API re-export (282 pub fn + 47 pub type)
```

---

## 📄 文档

| 文档 | 说明 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 架构图、包依赖关系、设计决策 |
| [docs/api_reference.md](docs/api_reference.md) | 完整 API 参考（282 函数 + 47 类型） |
| [docs/roadmap.md](docs/roadmap.md) | 迭代路线图 |
| [docs/comparison.md](docs/comparison.md) | mooncakes.io 图像库对比 |
| [docs/skill.md](docs/skill.md) | AI 辅助开发技能描述 |
| [docs/changelog.md](docs/changelog.md) | 版本变更历史 |

---

## 🔧 构建与测试

```bash
# 编译检查（四目标）
moon check
moon check --target wasm-gc
moon check --target js
moon check --target wasm

# 运行测试（四目标各 1054）
moon test --target native
moon test --target wasm-gc
moon test --target js
moon test --target wasm

# 运行性能基准测试
moon run --target native

# 重新生成 API 接口
moon info
```

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

<details>
<summary><b>📋 开发环境</b></summary>

```bash
# 安装 MoonBit 工具链（需 0.1.20260713+）
# 见 https://www.moonbitlang.com/download/

# 克隆并验证
git clone git@github.com:toadium/stb-image.git
cd stb-image
moon check                          # 编译检查
moon test --target native           # 运行测试（应 1054 通过）
```

</details>

<details>
<summary><b>🔧 开发流程</b></summary>

1. **Fork** 仓库并克隆到本地
2. **创建分支**：`git checkout -b feature/your-feature` 或 `fix/your-fix`
3. **编写代码**，遵循下方代码规范
4. **编写测试**，新功能必须有对应测试
5. **四目标验证**：
   ```bash
   moon test --target native     # 必须通过
   moon test --target wasm-gc    # 必须通过
   moon test --target js         # 必须通过
   moon test --target wasm       # 必须通过
   ```
</details>

<details>
<summary><b>📐 代码规范</b></summary>

| 规范 | 要求 | 示例 |
|------|------|------|
| 命名 | `snake_case` | `gaussian_blur`、`clamp_byte_v` |
| 函数分隔 | 每个顶层定义前用 `///\|` | `///\|` + 换行 + `pub fn ...` |
| 文档注释 | `pub` 函数上方添加 `///` 注释 | `/// 二值化。像素 >= threshold 设为 255` |
| 可见性 | 仅暴露必要函数为 `pub` | 内部辅助函数不加 `pub` |
| 错误处理 | 使用 `raise @types.LoadError` | `raise LoadError::DecodeFailed("msg")` |
| 测试命名 | `"函数名: 场景描述"` | `"threshold_pure: basic binarization"` |

</details>

<details>
<summary><b>🚫 核心约束</b></summary>

> [!WARNING]
> 以下约束不可违反，否则 PR 将被拒绝：

- **禁止引入 C FFI 依赖** — 所有代码必须纯 MoonBit 实现，确保四目标可用
- **禁止破坏已有 API** — 新增功能只添加不修改已有签名，保持向后兼容
- **禁止目标条件编译** — 不使用 `target == "native"` 等条件分支，四目标共用代码
- **新增 `pub` 函数须在 `reexport.mbt` 注册** — 保持顶层 API 完整性

</details>

<details>
<summary><b>📝 提交信息格式</b></summary>

```
<类型>: <简述>

[可选正文，说明动机或细节]
```

**类型**：`功能`（新功能）| `修复`（bug 修复）| `文档`（文档更新）| `重构`（代码重构）| `测试`（测试补充）

**示例**：
```
功能: 新增 WebP lossless 解码器

基于 VP8L 格式规范实现，支持 8-bit RGBA 解码。
新增 42 个测试，四目标均通过。
```

</details>

---

## 📄 许可证

[MIT](LICENSE) — 自由使用、修改、分发。

---

## 🙏 致谢

- **[stb](https://github.com/nothings/stb)** — 原始 C 实现的参考基础
- **[MoonBit](https://www.moonbitlang.com/)** — 纯 MoonBit 语言与工具链
- **[OpenCV](https://opencv.org/)** — 高级算法参考（ORB/Canny/Harris/光流等）

---

<div align="center">

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

</div>
