# stb-image 迭代路线图

> 基于 mooncakes.io image 库对比（见 `COMPARISON.md`）制定的后续迭代计划。
> 制定日期：2026-08-06 | 最后更新：2026-08-07 | 当前版本：v1.8.0

## 现状定位

**stb-image v1.6.0 的独特优势**：
- PSD/HDR/PNM 独家格式（其他库均不支持）
- 16-bit/float 像素深度（仅 bikallem 有 16-bit）
- ASan 内存安全验证（独家）
- 88 公开函数 + 11 类型，254 测试 + 29 基准测试
- 全格式 roundtrip 验证
- EXIF/PNG 元数据读取（独家）

**主要差距**（对比 5 个已有库）：
| 缺失功能 | 已有此功能的库 | 实现路径 |
|---|---|---|
| WebP 编码 | mizchi | 纯 MoonBit (lossless) |
| 流式解码 | mizchi | 纯 MoonBit (架构改动大) |
| TIFF 解码 | — | 纯 MoonBit 或 FFI |
| wasm/js 目标 | mizchi | 需要完全不同的 FFI 方案 |

## 迭代原则

1. **FFI 优先**：stb 库本身支持的功能优先通过 FFI 绑定（低成本、高质量、ASan 可验证）
2. **纯 MoonBit 补齐**：stb 不支持的功能用纯 MoonBit 实现，放在单独包中
3. **不破坏 v1.0 API**：新增功能只添加，不修改已有签名
4. **测试先行**：每个新功能必须有测试 + ASan 验证（FFI 部分）
5. **差异化优先**：优先补齐其他库都有的功能，再考虑独特功能

---

## v1.1 — HDR 写入 + resize（FFI 绑定）✅

**目标**：补齐 HDR 全生命周期 + resize 能力

### 功能

1. **HDR 写入**（FFI，stb_image_write.h 已有 `stbi_write_hdr`）
   - `write_hdr_to_path(path, image_f)` — 写入 HDR 文件
   - `write_hdr_to_bytes(image_f)` — 写入 HDR 字节流

2. **resize**（FFI，vendor `stb_image_resize2.h`）
   - `resize(image, new_w, new_h, filter?, edge?) -> Image` — 8-bit resize
   - `resize_srgb(image, new_w, new_h, filter?, edge?) -> Image` — sRGB colorspace
   - `resize_16(image16, new_w, new_h, filter?, edge?) -> Image16` — 16-bit resize
   - `resizef(imagef, new_w, new_h, filter?, edge?) -> ImageF` — float resize
   - 7 种滤波器 + 4 种边缘模式

### 交付物
- `src/stb_image_resize2.h` — vendored v2.07
- 75 测试，ASan 通过

---

## v1.2 — 纯 MoonBit 格式扩展 ✅

**目标**：补齐其他库普遍有的格式，消除"格式短板"

### 功能

1. **GIF 编码**（纯 MoonBit）— `encode_gif` / `encode_gif_animation`
2. **ICO/ICNS 编码**（纯 MoonBit）— `encode_ico` / `encode_ico_sizes` / `encode_icns`
3. **QOI 解码/编码**（纯 MoonBit）— `decode_qoi` / `encode_qoi`
4. **格式自动检测**（纯 MoonBit）— `detect_format` / `decode_any` / `is_supported_format` + `ImageFormat` 枚举

### 交付物
- 114 测试，ASan 通过

---

## v1.3 — 图像处理操作 ✅

**目标**：补齐图像处理能力

### 功能

1. **crop/rotate/flip** — `crop` / `crop_16` / `cropf` / `rotate_90` / `rotate_180` / `rotate_270` / `flip_horizontal`
2. **色彩模型转换** — `to_grayscale` / `to_rgb` / `to_rgba` / `premultiply_alpha` / `unpremultiply_alpha`
3. **draw/compositing** — `draw_copy` / `draw_over`

### 交付物
- 145 测试，ASan 通过

---

## v1.4 — 图像处理增强 ✅

**目标**：补齐高级图像处理能力

### 功能

1. **色彩调整**（8 函数）— `adjust_brightness` / `adjust_contrast` / `adjust_gamma` / `invert` / `rgb_to_hsv` / `hsv_to_rgb` / `rgb_to_hsl` / `hsl_to_rgb`
2. **滤波/卷积**（4 函数）— `box_blur`（滑动窗口优化）/ `gaussian_blur`（可分离高斯核）/ `sharpen`（拉普拉斯锐化）/ `edge_detect_sobel`（Sobel 算子）
3. **几何变换**（2 函数）— `warp_affine`（仿射变换+双线性插值）/ `rotate`（任意角度旋转）
4. **直方图**（3 函数）— `histogram` / `histogram_equalize` / `histogram_normalize`
5. **量化**（2 函数）— `floyd_steinberg`（误差扩散抖动）/ `median_cut`（中位切分量化）

### 交付物
- 206 测试，ASan 通过

---

## v1.5 — PNM/GIF 动画/EXIF ✅

**目标**：格式扩展 + 元数据读取

### 功能

1. **PNM 编码**（3 函数）— `encode_ppm` / `encode_pgm` / `encode_pnm`
2. **GIF 动画**（1 函数）— `encode_gif_animation`（多帧 GIF89a + Netscape 循环扩展 + Graphic Control Extension）
3. **EXIF 读取**（2 函数 + 1 类型）— `read_exif_from_bytes` / `read_exif_from_path` + `ExifInfo` 结构

### 交付物
- 229 测试，ASan 通过

---

## v1.6 — PNG 元数据 + roundtrip + 性能基准 ✅

**目标**：质量增强 + 元数据扩展

### 功能

1. **PNG text chunks 读取**（2 函数 + 1 类型）— `read_png_text_chunks` / `read_png_text_chunks_from_path` + `PngTextChunk` 结构
2. **全格式 roundtrip 测试**（19 测试）— PNG/BMP/TGA/JPEG/QOI/GIF/PPM/PGM/ICO/HDR + transform/color/resize/filter/quantize pipeline
3. **性能基准测试套件**（29 bench）— 覆盖 load/write/resize/filter/transform/color/histogram/quantize/detect

### 交付物
- 254 测试 + 29 基准测试，ASan 通过
- 88 公开函数 + 11 类型/枚举

---

## v2.0 — 多目标支持（架构升级）

**目标**：支持 wasm/js 目标，与 mizchi 拉平

### 方案

此版本需要重大架构决策，两个可选路径：

**路径 A：双后端**
- native 目标：保持现有 C FFI 绑定
- wasm/js 目标：纯 MoonBit fallback（移植 stb 核心解码逻辑）
- 优点：native 性能保留
- 缺点：维护两套代码

**路径 B：全纯 MoonBit**
- 移除 C FFI，全部用纯 MoonBit 重写
- 优点：单一代码库，全目标支持
- 缺点：失去 stb 的格式覆盖（PSD/HDR/PNM）、失去 ASan 验证、工作量巨大

**推荐路径 A**，但需要评估维护成本。

### 交付物
- `src/native/` — native 后端（现有 C FFI）
- `src/pure/` — 纯 MoonBit 后端（wasm/js）
- `src/lib.mbt` — 后端选择层

---

## v2.1 — 高级格式（远期）

**目标**：进一步扩展格式覆盖

### 功能

1. **WebP 编码**（纯 MoonBit，lossless only）
   - `encode_webp(image) -> Bytes`
   - 参考 mizchi/image

2. **流式解码**（纯 MoonBit）
   - `decode_png_stream(bytes, on_row~) -> StreamInfo`
   - `decode_bmp_stream(bytes, on_row~) -> StreamInfo`
   - 参考 mizchi/image

3. **TIFF 解码**（纯 MoonBit 或 FFI）
   - stb 不支持 TIFF，需要独立实现或绑定 libtiff

4. **APNG 解码**（纯 MoonBit）
   - Animated PNG 支持

---

## 版本时间线

| 版本 | 内容 | 测试数 | 优先级 |
|---|---|---|---|
| v1.0 | API freeze, complete docs, ASan verified | 61 | 高 |
| v1.1 | HDR write + resize (FFI) | 75 | 高 |
| v1.2 | QOI/ICO/ICNS/GIF 编码 + auto-detect | 114 | 高 |
| v1.3 | crop/rotate/color/draw | 145 | 中 |
| v1.4 | 色彩调整/滤波/几何/直方图/量化 | 206 | 中 |
| v1.5 | PNM/GIF 动画/EXIF | 229 | 中 |
| **v1.6** | **PNG meta/roundtrip/bench** | **254+29** | **中** |
| **v1.7** | **API 增强: pad/border/resize_to_cover/contain + threshold/posterize/extract_channel + blend** | **275+29** | **中** |
| **v1.8** | **更多 blend + stats + pixelate/replace_color/convolve/swap_channels** | **292+29** | **中** |
| v2.0 | 多目标支持 | — | 中 — 架构升级 |
| v2.1 | WebP/stream/TIFF/APNG | — | 低 — 远期 |

## 不做的事情

以下功能明确不在计划内：

- **AVIF 编码**：需要外部编解码器（libaom/svt-av1），与"零 C 依赖"理念冲突
- **JPEG progressive 编码**：stb_image_write.h 不支持，纯 MoonBit 实现成本过高
- **I/O callbacks**：MoonBit FFI 不支持闭包传递给 C（已评估）
- **Go 风格 API**：bikallem/gmlewis 已覆盖此定位，不重复
