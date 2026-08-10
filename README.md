<div align="center">

# image

**纯 MoonBit 图像处理库** · 零 C 依赖 · 三目标原生支持

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![MoonBit](https://img.shields.io/badge/MoonBit-0.1.20260713-blue)](https://www.moonbitlang.com/)
[![Targets](https://img.shields.io/badge/targets-native%20%7C%20wasm--gc%20%7C%20js-success)]()
[![Tests](https://img.shields.io/badge/tests-1056%20%C3%97%203%20targets-brightgreen)]()
[![Coverage](https://img.shields.io/badge/coverage-89.8%25-brightgreen)]()
[![Functions](https://img.shields.io/badge/API-197%20functions%20%2B%2028%20types-blueviolet)]()
[![Version](https://img.shields.io/badge/version-3.0.0-orange)]()

[亮点](#-亮点) · [格式支持](#-格式支持) · [快速上手](#-快速上手) · [功能一览](#-功能一览) · [包结构](#-包结构) · [文档](#-文档)

</div>

---

## 📖 简介

`image` 是一个纯 MoonBit 实现的图像处理库，**无任何 C FFI 依赖**。覆盖 10+ 种格式的解码与编码，提供从基础像素操作到高级计算机视觉算法的完整能力。

> [!NOTE]
> 三目标（native / wasm-gc / js）均使用同一套纯 MoonBit 代码，各 1056 测试全部通过，覆盖率 89.8%。

---

## ✨ 亮点

| | 特性 | 说明 |
|---|---|---|
| 🟢 | **零 C 依赖** | 全部纯 MoonBit 实现，无需 C 编译器，部署极简 |
| 🟢 | **三目标支持** | native / wasm-gc / js 共用同一代码库，无条件编译 |
| 🟢 | **格式覆盖广** | PNG / JPEG / BMP / GIF / QOI / TGA / PSD / HDR / PNM / TIFF / APNG — 含独家 PSD、HDR |
| 🟢 | **像素深度全** | 8 位 `Image`、16 位 `Image16`、HDR 浮点 `ImageF` |
| 🟢 | **197 个 API** | 从基础 I/O 到 FFT、Canny、分水岭、SLIC、Seam Carving 等高级算法 |
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

// 缩放（7 种滤波器 × 4 种边缘模式）
let resized : Image = resize(img, 128, 128)

// 自动检测格式并解码
let any : Image = decode_any(data, req_channels=Some(3))

// 加载动画 GIF
let anim : GifAnimation = load_gif_from_bytes(gif_bytes)
println("frames=\{anim.frames.length()}, delays=\{anim.delays}")

// 查询图像信息（不解码像素）
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

## 🧰 功能一览

<details>
<summary><b>基础能力</b></summary>

| 能力 | 说明 |
|------|------|
| 格式检测 | `detect_format` / `decode_any` / `is_supported_format` |
| 像素类型 | 8 位 `Image`、16 位 `Image16`、HDR 浮点 `ImageF` |
| 缩放 | 7 种滤波器 × 4 种边缘模式，sRGB 色彩空间 |
| 动画 GIF | 多帧解码/编码，支持逐帧延迟 |
| 元数据 | EXIF 读取/写入、PNG 文本块 |
| 信息查询 | 不解码像素即可获取尺寸/通道/位深 |

</details>

<details>
<summary><b>图像处理（119 函数）</b></summary>

| 类别 | 功能 |
|------|------|
| 几何变换 | 裁剪、旋转（90°/180°/270°/任意角度）、翻转、仿射变换 |
| 色彩 | 亮度/对比度/伽马/反色、HSV/HSL 转换、灰度/RGB/RGBA、预乘 Alpha |
| 滤波器 | 方框模糊、高斯模糊、锐化、Sobel/Laplacian/Prewitt 边缘检测 |
| 直方图 | 计算、均衡化、归一化 |
| 形态学 | 腐蚀、膨胀、开运算、闭运算、骨架化 |
| 混合模式 | 13 种（正片叠底、滤色、叠加、变暗/变亮、差值、排除等） |
| 质量评估 | MSE、PSNR、SSIM |
| 绘制 | `draw_copy`、`draw_over`（Alpha 混合） |

</details>

<details>
<summary><b>高级分析（90+ 函数）</b></summary>

| 类别 | 功能 |
|------|------|
| CLAHE | 对比度受限自适应直方图均衡 |
| K-means | 色彩量化、颜色分割、区域生长、泛洪填充 |
| FFT | 2D 频域变换、频域滤波（理想/高斯，低通/高通/带通/带阻） |
| 自适应阈值 | 均值法、高斯加权法、Otsu 大津法 |
| 连通域 | 4/8 连通标记（Union-Find），含面积/边界框/质心 |
| 积分图像 | O(1) 矩形区域求和/均值/方差查询 |
| 霍夫变换 | 直线检测 + 非极大值抑制 |
| LBP | 局部二值模式（基本 + 均匀 58 模式） |
| 图像金字塔 | 高斯/拉普拉斯金字塔 |
| 双边滤波 | 保边去噪（标准 + 快速降采样） |
| NLM 去噪 | 非局部均值（标准 + 快速） |
| Canny 边缘 | 高斯 → Sobel → 非极大值抑制 → 滞后连接 |
| 分水岭 | 沉浸式分割（标记/自动） |
| GLCM 纹理 | 对比度/相关性/能量/同质性/熵/ASM/不相似性 |
| Haar 小波 | 1D/2D 变换，多级分解，软/硬阈值去噪 |
| Harris 角点 | 结构张量 + 非极大值抑制 + 距离过滤 |
| 去雾 | 暗通道先验 + 引导滤波 |
| Retinex | SSR、MSR、MSRCR |
| Gabor 滤波 | 多方向多尺度纹理分析 |
| 距离变换 | L1/L2/Linf 距离，骨架化 |
| **SLIC 超像素** | **Simple Linear Iterative Clustering 超像素分割** |
| **Seam Carving** | **内容感知缩放（能量 + DP + seam 移除/插入）** |
| **16-bit/float 泛化** | **rotate/flip/brightness/contrast 支持 Image16/ImageF** |

</details>

---

## 🎯 多目标支持

| 目标 | 后端 | 测试 | 状态 |
|:----:|:----:|:----:|:----:|
| **native** | 纯 MoonBit | 1056 | ✅ |
| **wasm-gc** | 纯 MoonBit | 1056 | ✅ |
| **js** | 纯 MoonBit | 1056 | ✅ |

> [!TIP]
> 三目标共用 `src/pure/` 下的同一套代码，无任何条件编译或目标分支。

---

## 📦 包结构

```
src/
├── types/              # 全目标类型 (Image, Image16, ImageF, LoadError 等)
├── pure/               # 纯 MoonBit 后端 (无 C FFI)
│   ├── codec/          #   格式编解码 (20 文件)
│   ├── pixel/          #   像素操作 (2 文件)
│   ├── color/          #   颜色操作 (3 文件)
│   ├── process/        #   图像处理 (10 文件)
│   └── util/           #   工具 (4 文件)
├── lib/                # 高层封装 (自动格式分派)
├── format/             # 格式扩展 (GIF 动画, QOI, PNM 编码)
├── meta/               # 元数据 (EXIF, PNG meta)
├── process/            # 高级图像处理算法 (7 子包)
├── util/               # 工具函数 (基于 pure 的上层封装)
├── bench.mbt           # 性能基准测试 (编解码 + 滤波 + 色彩 + 几何)
└── reexport.mbt        # 顶层 API re-export (197 pub fn + 28 pub type)
```

---

## 📄 文档

| 文档 | 说明 |
|------|------|
| [docs/architecture.md](docs/architecture.md) | 架构图、包依赖关系、设计决策 |
| [docs/api_reference.md](docs/api_reference.md) | 完整 API 参考（197 函数 + 28 类型） |
| [docs/roadmap.md](docs/roadmap.md) | 迭代路线图 |
| [docs/comparison.md](docs/comparison.md) | mooncakes.io 图像库对比 |
| [docs/skill.md](docs/skill.md) | AI 辅助开发技能描述 |
| [docs/changelog.md](docs/changelog.md) | 版本变更历史 |

---

## 🔧 构建与测试

```bash
# 编译检查（三目标）
moon check
moon check --target wasm-gc
moon check --target js

# 运行测试（三目标各 1056）
moon test --target native
moon test --target wasm-gc
moon test --target js

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
moon test --target native           # 运行测试（应 1056 通过）
```

</details>

<details>
<summary><b>🔧 开发流程</b></summary>

1. **Fork** 仓库并克隆到本地
2. **创建分支**：`git checkout -b feature/your-feature` 或 `fix/your-fix`
3. **编写代码**，遵循下方代码规范
4. **编写测试**，新功能必须有对应测试
5. **三目标验证**：
   ```bash
   moon test --target native     # 必须通过
   moon test --target wasm-gc    # 必须通过
   moon test --target js         # 必须通过
   ```
6. **提交**：`git commit -m "功能: 简述你的改动"`
7. **推送并发起 PR**，描述改动内容和动机

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

- **禁止引入 C FFI 依赖** — 所有代码必须纯 MoonBit 实现，确保三目标可用
- **禁止破坏已有 API** — 新增功能只添加不修改已有签名，保持向后兼容
- **禁止目标条件编译** — 不使用 `target == "native"` 等条件分支，三目标共用代码
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
新增 42 个测试，三目标均通过。
```

</details>

---

## 📄 许可证

[MIT](LICENSE) — 自由使用、修改、分发。

---

<div align="center">

如果这个项目对你有帮助，欢迎 ⭐ Star 支持一下！

</div>
