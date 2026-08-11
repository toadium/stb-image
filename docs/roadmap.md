# image 迭代路线图

> 基于 mooncakes.io image 库对比（见 [comparison.md](comparison.md)）制定的后续迭代计划。
> 制定日期：2026-08-06 | 最后更新：2026-08-11 | 当前版本：v3.0.0 | 测试：907×3 | 覆盖率：89.8%

## 现状定位

### 版本演进时间线

```mermaid
gantt
    title image 版本演进
    dateFormat YYYY-MM-DD
    axisFormat %m/%d

    section 基础功能
    v0.1 8位加载           :done, v01, 2026-07-20, 1d
    v0.2 写入              :done, v02, after v01, 1d
    v0.3 16位/浮点/配置    :done, v03, after v02, 1d
    v0.4 HDR/GIF           :done, v04, after v03, 1d
    v1.0 API冻结           :done, v10, after v04, 1d

    section 格式扩展
    v1.1 HDR写入/缩放      :done, v11, after v10, 1d
    v1.2 QOI/ICO/GIF编码   :done, v12, after v11, 1d
    v1.5 PNM/GIF动画/EXIF  :done, v15, after v12, 1d
    v1.6 PNG元数据/roundtrip :done, v16, after v15, 1d

    section 图像处理
    v1.3 裁剪/旋转/色彩    :done, v13, after v12, 1d
    v1.4 滤波/直方图/量化   :done, v14, after v13, 1d
    v1.7 API增强           :done, v17, after v16, 1d
    v1.8 更多API           :done, v18, after v17, 1d
    v1.9 拼接/噪声/映射     :done, v19, after v18, 1d
    v1.10 形态学/边缘/质量  :done, v110, after v19, 1d

    section 高级算法
    v1.12 CLAHE/K-means/FFT :done, v112, after v110, 1d
    v1.13 频域/阈值/连通域   :done, v113, after v112, 1d
    v1.14 霍夫/LBP/金字塔    :done, v114, after v113, 1d
    v1.15 轮廓/分割/NLM/Retinex :done, v115, after v114, 1d
    v1.16 Canny/分水岭/GLCM/Haar :done, v116, after v115, 1d
    v1.17 Harris/去雾/距离/Gabor :done, v117, after v116, 1d
```

### 功能增长曲线

```mermaid
flowchart LR
    V01["v0.1<br/>23 测试"] --> V04["v0.4<br/>61 测试"]
    V04 --> V10["v1.0<br/>61 测试<br/>API冻结"]
    V10 --> V12["v1.2<br/>114 测试<br/>格式扩展"]
    V12 --> V16["v1.6<br/>254+29 测试<br/>元数据/基准"]
    V16 --> V110["v1.10<br/>341+29 测试<br/>128 函数"]
    V110 --> V114["v1.14<br/>433+29 测试<br/>164 函数"]
    V114 --> V117["v1.17<br/>533+29 测试<br/>199 函数"]
    V117 --> V20["v2.0<br/>872×3 测试<br/>174 函数<br/>89.8% 覆盖率"]

    classDef milestone fill:#e8f5e9,stroke:#2e7d32
    class V10,V117,V20 milestone
```

- **image v3.0.0 的独特优势**：
- PSD/HDR/PNM 独家格式（其他库均不支持）
- 16-bit/float 像素深度（仅 bikallem 有 16-bit）
- 266 公开函数 + 37 类型，935 测试 × 4 目标
- 全格式 roundtrip 验证
- EXIF/PNG 元数据读取（独家）
- 形态学操作 + 图像质量评估（MSE/PSNR/SSIM）（独家）
- **多子包架构**：types（全目标类型）/ pure（纯 MoonBit 后端，3 子包：codec/color/util）/ lib（统一 API）/ process（图像处理，7 子包）/ meta（元数据）/ util（工具函数），根包 re-export 保持向后兼容

**主要差距**（对比 5 个已有库）：
| 缺失功能 | 已有此功能的库 | 实现路径 |
|---|---|---|
| WebP 编码 | mizchi | 纯 MoonBit (lossless) |
| 流式解码 | mizchi | 纯 MoonBit (架构改动大) |
| TIFF 解码 | — | 纯 MoonBit |
| ~~wasm/js 目标~~ | ~~mizchi~~ | ✅ 已完成（v2.0 纯 MoonBit 全目标） |

## 迭代原则

1. **纯 MoonBit 优先**：所有功能用纯 MoonBit 实现，确保四目标 (native/wasm-gc/js/wasm) 支持
2. **格式覆盖优先**：优先补齐常用格式，再考虑高级功能
3. **不破坏 v1.0 API**：新增功能只添加，不修改已有签名
4. **测试先行**：每个新功能必须有测试，三目标均通过
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

## v1.7 — API 增强 ✅

**目标**：补齐常用图像处理工具函数

### 功能
1. **图像工具**（4 函数）— `pad` / `add_border` / `resize_to_cover` / `resize_to_contain`
2. **像素操作**（3 函数）— `threshold` / `posterize` / `extract_channel`
3. **混合模式**（3 函数）— `blend_multiply` / `blend_screen` / `blend_overlay`

### 交付物
- 275 测试 + 29 基准测试

---

## v1.8 — 更多 API 增强 ✅

**目标**：继续扩展像素级操作和统计

### 功能
1. **更多混合模式**（4 函数）— `blend_darken` / `blend_lighten` / `blend_difference` / `blend_exclusion`
2. **图像统计**（2 函数 + 1 类型）— `compute_stats` / `mean_value` + `ImageStats`
3. **高级像素操作**（4 函数）— `pixelate` / `replace_color` / `convolve` / `swap_channels`

### 交付物
- 292 测试 + 29 基准测试

---

## v1.9 — 拼接/噪声/色彩映射 ✅

**目标**：图像合成和噪声生成

### 功能
1. **图像拼接**（5 函数）— `hstack` / `vstack` / `tile` / `flip_vertical` / `transpose`
2. **噪声**（2 函数）— `add_noise_gaussian` / `add_noise_salt_pepper`（LCG + Box-Muller）
3. **色彩映射**（4 函数）— `apply_lut` / `gradient_map` / `set_alpha` / `fill_alpha`

### 交付物
- 315 测试 + 29 基准测试

---

## v1.10 — 形态学 + 边缘检测 + 质量评估 ✅

**目标**：补齐形态学操作和图像质量评估

### 功能
1. **形态学操作**（4 函数）— `erode` / `dilate` / `morph_open` / `morph_close`（3x3 结构元素）
2. **边缘检测扩展**（2 函数）— `edge_detect_laplacian` / `edge_detect_prewitt`
3. **图像质量评估**（3 函数）— `mse` / `psnr` / `ssim`

### 交付物
- 341 测试 + 29 基准测试
- 128 公开函数 + 12 类型/枚举

---

## v1.10.1 — 子包重构 + 代码清理 ✅

**目标**：将单包拆分为多子包，提升可维护性

### 功能
1. **多子包架构** — `types/`（全目标类型）+ `pure/{codec,pixel,color,process,util}/`（纯 MoonBit 后端）+ `lib/`（统一 API）+ `process/`（图像处理）+ `meta/`（元数据）+ `util/`（工具函数）
2. **reexport.mbt** — 根包 re-export 保持向后兼容 API（`pub let` 用于普通函数，`pub fn` 包装器用于带标签参数的函数）
3. **中文 README** — `README.md`（中文），文档统一存放 `docs/` 目录
4. **警告清理** — 删除未使用的 test_helpers，0 警告 0 错误

### 交付物
- 341 测试 + 29 基准测试，0 警告
- 五子包 + reexport，向后兼容

---

## v1.12 — 高级图像处理算法 ✅

**目标**：添加更多高级图像处理算法

### 功能
1. **混合模式扩展**（6 函数）— `blend_color_dodge` / `blend_color_burn` / `blend_hard_light` / `blend_soft_light` / `blend_linear_dodge` / `blend_linear_burn`
2. **CLAHE**（1 函数）— `clahe`（对比度受限自适应直方图均衡，分块直方图+裁剪+双线性插值）
3. **K-means 量化**（1 函数）— `k_means_quantize`（K-means 聚类色彩量化）
4. **FFT 频域变换**（4 函数 + 2 类型）— `fft_2d` / `ifft_2d` / `fft_magnitude` / `fft_shift` + `Complex` / `FFTResult`（Cooley-Tukey radix-2，自动补零到 2 的幂次方）

### 交付物
- 369 测试 + 29 基准测试
- 140 公开函数 + 14 类型/枚举

---

## v1.13 — 频域滤波 + 自适应阈值 + 连通域 + 积分图像 ✅

**目标**：扩展图像分析能力

### 功能
1. **频域滤波**（2 函数 + 1 类型）— `freq_filter` / `freq_filter_gaussian` + `FreqFilterType`（低通/高通/带通/带阻，理想+高斯传递函数）
2. **自适应阈值**（3 函数）— `adaptive_threshold_mean` / `adaptive_threshold_gaussian` / `threshold_otsu`（均值法、高斯加权法、Otsu 大津法）
3. **连通域标记**（1 函数 + 2 类型）— `connected_components` + `ConnectedComponent` / `ConnectedComponentLabelImage`（两遍扫描 + Union-Find，4/8 连通，含面积/边界框/质心）
4. **积分图像**（6 函数 + 2 类型）— `integral_image` / `integral_image_sq` / `integral_sum` / `integral_sum_sq` / `integral_mean` / `integral_variance` + `IntegralImage` / `IntegralImageSq`（O(1) 矩形区域查询）

### 交付物
- 402 测试 + 29 基准测试
- 152 公开函数 + 21 类型/枚举

---

## v1.14 — 霍夫变换 + LBP + 图像金字塔 + 双边滤波 ✅

**目标**：扩展特征提取和滤波能力

### 功能
1. **霍夫变换**（2 函数 + 1 类型）— `hough_lines` / `hough_lines_nms` + `HoughLine`（直线检测，极坐标累加器，非极大值抑制）
2. **局部二值模式**（2 函数）— `lbp` / `lbp_uniform`（基本 LBP + 均匀 LBP，58 种均匀模式映射）
3. **图像金字塔**（4 函数）— `pyr_down` / `pyr_up` / `build_gaussian_pyramid` / `build_laplacian_pyramid`（高斯金字塔 + 拉普拉斯金字塔，下采样2x2均值 + 上采样双线性插值）
4. **双边滤波**（2 函数）— `bilateral_filter` / `bilateral_filter_fast`（保边去噪，空间+值域高斯加权，快速版降采样近似）

### 交付物
- 433 测试 + 29 基准测试
- 164 公开函数 + 22 类型/枚举

---

## v1.15 — 轮廓提取 + 颜色分割 + NLM 去噪 + Retinex ✅

**目标**：扩展轮廓分析和高级去噪能力

### 功能
1. **轮廓提取与绘制**（4 函数 + 2 类型）— `find_contours` / `draw_contours` / `contour_perimeter` / `contour_area` + `ContourPoint` / `Contour`（Moore 边界跟踪，外轮廓/孔洞标记，鞋带公式面积）
2. **颜色分割**（4 函数 + 2 类型）— `kmeans_segment` / `region_growing_segment` / `flood_fill` / `segment_to_color` + `SegmentLabelImage` / `SegmentRegion`（K-means 聚类分割 + 区域生长 + 泛洪填充 + 标签可视化）
3. **非局部均值去噪**（2 函数）— `nlm_denoise` / `nlm_denoise_fast`（块匹配加权平均，快速版降采样搜索）
4. **多尺度 Retinex**（3 函数）— `ssr` / `msr` / `msrcr`（单尺度/多尺度/带颜色恢复，可分离高斯模糊）

### 交付物
- 472 测试 + 29 基准测试
- 177 公开函数 + 26 类型/枚举

---

## v1.16 — Canny 边缘 + 分水岭 + GLCM + Haar 小波 ✅

**目标**：扩展边缘检测、分割、纹理分析和多分辨率分析能力

### 功能
1. **Canny 边缘检测**（1 函数）— `canny_edge`（高斯模糊→Sobel 梯度→非极大值抑制→双阈值滞后连接）
2. **分水岭分割**（2 函数）— `watershed` / `watershed_auto`（沉浸式分水岭算法，基于种子标记，自动寻找局部最小值）
3. **GLCM 纹理分析**（3 函数 + 1 类型）— `compute_glcm` / `glcm_features` / `glcm_features_multi_direction` + `GlcmFeatures`（灰度共生矩阵，对比度/相关性/能量/同质性/熵/ASM/不相似性，4 方向）
4. **Haar 小波变换**（5 函数 + 1 类型）— `haar_transform_1d` / `haar_inverse_transform_1d` / `haar_transform_2d` / `haar_inverse_transform_2d` / `haar_denoise` + `HaarWaveletResult`（多级分解重构，软/硬阈值去噪）

### 交付物
- 501 测试 + 29 基准测试
- 188 公开函数 + 28 类型/枚举

---

## v1.17 — Harris 角点 + 去雾 + 距离变换 + Gabor 滤波 ✅

**目标**：扩展特征检测、去雾、形态学和纹理分析能力

### 功能
1. **Harris 角点检测**（2 函数 + 1 类型）— `harris_corners` / `draw_corners` + `CornerPoint`（Sobel 梯度→结构张量→Harris 响应→NMS→距离过滤）
2. **暗通道先验去雾**（2 函数）— `dehaze` / `guided_filter`（暗通道先验+大气光估计+透射率恢复+引导滤波优化）
3. **距离变换**（3 函数）— `distance_transform` / `distance_transform_visualize` / `skeletonize`（两遍扫描，L1/L2/Linf 距离，骨架化）
4. **Gabor 滤波**（3 函数）— `gabor_filter` / `gabor_filter_bank` / `gabor_kernel`（多方向多尺度纹理分析）

### 交付物
- 533 测试 + 29 基准测试
- 199 公开函数 + 29 类型/枚举

---

## v2.0 — 多目标支持（架构升级）✅

**目标**：支持 wasm/js 目标，与 mizchi 拉平

### 方案

此版本需要重大架构决策，两个可选路径：

**路径 A：双后端**
- native 目标：保持现有 C FFI 绑定
- wasm/js 目标：纯 MoonBit fallback（移植 stb 核心解码逻辑）
- 优点：native 性能保留
- 缺点：维护两套代码

**路径 B：全纯 MoonBit**（已选择 ✅）
- 移除 C FFI，全部用纯 MoonBit 重写
- 优点：单一代码库，全目标支持
- 缺点：失去 stb 的格式覆盖（PSD/HDR/PNM）、失去 ASan 验证、工作量巨大

**已选择路径 B**，v2.0 已完成全纯 MoonBit 实现，三目标各 872 测试通过，覆盖率 89.8%。

### 交付物（已完成）
- `src/pure/{codec,color,util}/` — 纯 MoonBit 后端：9 格式编解码 + 几何/色彩/滤波/直方图/形态学/仿射/像素/混合等
- `src/process/{color,edge,feature,filter,frequency,segment,transform}/` — 高级算法 7 子包
- `src/lib/` — pure 侧统一 API + 自动格式分派
- `src/types/` — 全目标类型包
- `src/bench.mbt` — 性能基准测试（编解码 + 滤波 + 色彩 + 几何）
- 测试：三目标各 872 通过，覆盖率 89.8%，174 公开函数 + 27 类型

---

## v2.1 — 基础补齐（低难度高价值）✅

**目标**：补齐业界标配但缺失的低难度高价值功能，消除"基础短板"

### 功能

#### 1. 中值滤波 `median_blur`（低难度·高价值）
- 去椒盐噪声唯一有效手段，OpenCV/Pillow 标配
- 滑动窗口 + 快速排序（直方图法 O(1) 更新）
- `median_blur(img, ksize) -> Image`

#### 2. 形态学衍生操作（低难度·高价值）
- 已有 `erode`/`dilate`/`morph_open`/`morph_close`，补三个衍生操作各一行
- `morph_gradient(img) -> Image` — dilate - erode，形态学梯度
- `morph_tophat(img) -> Image` — original - open，顶帽变换
- `morph_blackhat(img) -> Image` — close - original，黑帽变换

#### 3. 自定义结构元素 + 形态学参数化（低难度·高价值）
- 现有形态学固定 3×3 核，严重限制实用性
- `get_structuring_element(shape, ksize) -> StructElement` — 椭圆/十字/矩形
- 更新 `erode`/`dilate` 等支持 `struct_element?` 和 `iterations?` 参数

#### 4. 色彩空间转换（低难度·高价值）
- JPEG 内部已有 YCbCr，Lab 是 K-means/分割感知空间
- `rgb_to_ycbcr` / `ycbcr_to_rgb` — 视频/JPEG 标准
- `rgb_to_xyz` / `xyz_to_rgb` — 色彩转换枢纽（sRGB gamma 编解码）
- `rgb_to_lab` / `lab_to_rgb` — CIELAB 感知均匀空间（经 XYZ 中转）
- `rgb_to_cmyk` / `cmyk_to_rgb` — 印刷标准

#### 5. 绘图原语（低难度·高价值）
- 任何图像库标配，现有仅 draw_contours/corners
- `draw_line(img, x1, y1, x2, y2, color, thickness?) -> Image` — Bresenham + 线宽
- `draw_rectangle(img, x, y, w, h, color, thickness?, fill?) -> Image`
- `draw_circle(img, cx, cy, r, color, thickness?, fill?) -> Image` — 中点画圆
- `draw_polygon(img, points, color, thickness?, fill?) -> Image` — 多边形光栅化

#### 6. 伪彩色映射 `apply_colormap`（低难度·高价值）
- 可视化标配，查表实现，apply_lut 已有基础
- `apply_colormap(img, colormap) -> Image` — 预设 LUT
- `Colormap` 枚举：`JET` / `HOT` / `COOL` / `VIRIDIS` / `TURBO` / `GRAY` / `BONE` / `COPPER`

#### 7. 感知哈希（低难度·高价值）
- 图像去重/检索，MoonBit 生态稀缺
- `phash(img) -> Array[Bit]` — pHash（DCT → 中值哈希）
- `ahash(img) -> Array[Bit]` — aHash（均值哈希）
- `dhash(img) -> Array[Bit]` — dHash（差值哈希）
- `hamming_distance(h1, h2) -> Int` — 汉明距离

#### 8. 直方图比较（低难度·高价值）
- `compare_hist(h1, h2, method) -> Double` — 巴氏/相关性/交叉熵
- `histogram_matching(img, target_hist) -> Image` — 直方图规定化

### 交付物目标
- ~960 测试（+88），~190 公开函数（+16）
- 三目标 0 warning

---

## v2.2 — 几何与轮廓分析（中难度高价值）✅

**目标**：补齐几何变换和轮廓分析链路，达到 OpenCV 级分析能力

### 功能

#### 1. 透视变换（中难度·高价值）
- 文档/车牌/扫描矫正常规需求，已有 warp_affine 基础
- `get_perspective_transform(src_points, dst_points) -> Matrix3x3` — 4 点求矩阵，解 8×8 线性方程组
- `warp_perspective(img, matrix, dsize?) -> Image` — 透视变换 + 双线性插值
- `get_affine_transform(src_points, dst_points) ->0 -> Matrix2x3` — 3 点求仿射矩阵
- `get_rotation_matrix_2d(center, angle, scale) -> Matrix2x3` — 中心+角度+缩放

#### 2. 轮廓分析完整链路（低-中难度·高价值）
- 已有 `find_contours`，补后处理形成 OpenCV 级轮廓分析
- `convex_hull(points) -> Array[Point]` — Graham 扫描凸包
- `convexity_defects(contour, hull) -> Array[Defect]` — 凸缺陷
- `approx_poly_dp(contour, epsilon, closed) -> Array[Point]` — Douglas-Peucker 多边形逼近
- `image_moments(contour) -> Moments` — 空间矩/中心矩（m00/m10/m01/m20/m11/m02/...）
- `hu_moments(moments) -> Array[Double]` — Hu 矩不变量（7 个）
- `fit_ellipse(contour) -> Ellipse` — 最小二乘椭圆拟合
- `min_area_rect(contour) -> RotatedRect` — 最小外接旋转矩形
- `min_enclosing_circle(contour) -> (Point, Float)` — 最小外接圆

#### 3. 霍夫圆检测（中难度·高价值）
- 工业视觉/医学图像常用，已有直线霍夫基础
- `hough_circles(img, dp, min_dist, param1?, param2?) -> Array[Circle]` — 梯度法降复杂度

#### 4. Shi-Tomasi 角点（低难度·高价值）
- Harris 替代，min eigenvalue，光流前置
- `good_features_to_track(img, max_corners, quality_level, min_distance) -> Array[CornerPoint]`

#### 5. DCT 公共 API（低难度·高价值）
- JPEG 内部已有 DCT，暴露为公共 API
- `dct_2d(img) -> Array[Array[Double]]` — 2D DCT-II
- `idct_2d(coeffs) -> Image` — 2D IDCT-III

#### 6. 色调映射（低难度·高价值）
- 已有 HDR 编解码，补色调映射形成 HDR 全链路
- `reinhard_tonemap(imgf, key?) -> Image` — Reinhard 全局色调映射
- `gamma_tonemap(imgf, gamma) -> Image` — Gamma 色调映射

#### 7. 拉普拉斯金字塔融合（中难度·高价值）
- 已有拉普拉斯金字塔，拼接融合自然延伸
- `multi_band_blend(img_a, img_b, mask, num_bands?) -> Image` — 多频带融合

### 交付物目标
- ~1050 测试（+90），~215 公开函数（+25）

---

## v2.3 — 格式扩展 ✅

**目标**：补齐常用格式，消除"格式短板"

### 功能

#### 1. TIFF 解码/编码（高难度·高价值）
- 业界极常用，格式复杂（多种压缩、tile/strip、多页）
- 分阶段实现：uncompressed → LZW → PackBits → Deflate（复用 zlib）
- `decode_tiff(bytes) -> Image raise LoadError`
- `encode_tiff(img) -> Bytes`

#### 2. ICO/CUR 解码与编码（低难度·中价值）
- 曾实现后被移除，BMP/PNG 子图封装，简单
- `decode_ico(bytes) -> Image`
- `encode_ico(img) -> Bytes` / `encode_ico_sizes(images) -> Bytes`
- `decode_cur(bytes) -> Image` / `encode_cur(img) -> Bytes`

#### 3. ICNS 解码与编码（低难度·低价值）
- macOS 图标格式，类似 ICO
- `decode_icns(bytes) -> Image` / `encode_icns(img) -> Bytes`

#### 4. APNG 解码/编码（中难度·中价值）
- 动画 PNG，已有 PNG 基础
- `decode_apng(bytes) -> PngAnimation raise LoadError`
- `encode_apng(anim) -> Bytes`

### 交付物目标
- ~1150 测试（+100），~225 公开函数（+10）

---

## v3.0 — 高级特性 ✅

**目标**：差异化竞争力，对标 OpenCV 高级功能

### 功能

#### 1. WebP 解码/编码（高难度·高价值）
- lossy 需 VP8，lossless 需 VP8L，纯实现工作量大
- `decode_webp(bytes) -> Image` / `encode_webp(img, quality?) -> Bytes`

#### 2. 16-bit/float 操作泛化（中难度·高价值）✅
- 现多数算法仅 8-bit，HDR/医学图像受限
- 为 `Image16`/`ImageF` 补齐 transform/color 操作（rotate/flip/brightness/contrast）
- 已完成 14 个 API：rotate_90_16/rotate_90f, rotate_180_16/rotate_180f, rotate_270_16/rotate_270f, flip_horizontal_16/flip_horizontalf, adjust_brightness_16/adjust_brightnessf, adjust_contrast_16/adjust_contrastf

#### 3. SLIC 超像素（中难度·高价值）✅
- 现代分割预处理标配
- `slic(img, k, m, max_iters) -> SuperpixelResult`

#### 4. ORB 特征匹配（高难度·高价值）
- FAST+BRIEF+旋转不变，特征匹配标配
- `orb_detect(img) -> Array[KeyPoint]` + `orb_compute(img, keypoints) -> Array[Descriptor]`
- `match_descriptors(d1, d2) -> Array[Match]`

#### 5. SIFT 特征（高难度·高价值）
- 尺度不变，DoG+描述子，专利已过期
- `sift_detect(img) -> Array[KeyPoint]` + `sift_compute(img, keypoints) -> Array[Descriptor]`

#### 6. grabCut 分割（高难度·高价值）
- 交互式前景提取，GMM+max-flow
- `grab_cut(img, rect, iter?) -> (Mask, Mask)`

#### 7. 图像修复 `inpaint`（高难度·中价值）
- Navier-Stokes / Telea 方法，去水印/修复
- `inpaint(img, mask, radius, method?) -> Image`

#### 8. 接缝裁剪 `seam_carving`（中难度·高价值）✅
- 内容感知缩放，独特卖点
- `seam_carve_resize(img, new_w, new_h) -> Image` + 5 个辅助 API

#### 9. EXIF 写入（中难度·高价值）✅
- 现仅读，写需完整 TIFF/IFD 构造
- `write_exif_to_bytes(info, jpeg_data) -> Bytes` + `create_exif_segment(info) -> Bytes`

#### 10. 流式解码（中难度·中价值）
- 大图内存友好
- `decode_png_stream(bytes, on_row~) -> StreamInfo`

---

## 版本时间线

| 版本 | 内容 | 测试数 | 函数数 | 状态 |
|---|---|---|---|---|
| v1.0 | API freeze, complete docs | 61 | — | ✅ |
| v1.1 | HDR write + resize | 75 | — | ✅ |
| v1.2 | QOI/ICO/ICNS/GIF + auto-detect | 114 | — | ✅ |
| v1.3 | crop/rotate/color/draw | 145 | — | ✅ |
| v1.4 | 色彩/滤波/几何/直方图/量化 | 206 | — | ✅ |
| v1.5 | PNM/GIF 动画/EXIF | 229 | — | ✅ |
| v1.6 | PNG meta/roundtrip/bench | 254+29 | 88 | ✅ |
| v1.7 | API 增强 (pad/border/blend) | 275+29 | — | ✅ |
| v1.8 | 更多 blend + stats + pixel ops | 292+29 | — | ✅ |
| v1.9 | 拼接/噪声/色彩映射 | 315+29 | — | ✅ |
| v1.10 | 形态学 + 边缘 + 质量评估 | 341+29 | 128 | ✅ |
| v1.10.1 | 子包重构 + 警告清理 | 341+29 | — | ✅ |
| v1.12 | CLAHE + K-means + FFT | 369+29 | 140 | ✅ |
| v1.13 | 频域/阈值/连通域/积分图 | 402+29 | 152 | ✅ |
| v1.14 | 霍夫/LBP/金字塔/双边 | 433+29 | 164 | ✅ |
| v1.15 | 轮廓/分割/NLM/Retinex | 472+29 | 177 | ✅ |
| v1.16 | Canny/分水岭/GLCM/Haar | 501+29 | 188 | ✅ |
| v1.17 | Harris/去雾/距离/Gabor | 533+29 | 199 | ✅ |
| **v2.0** | **纯 MoonBit 多目标重构** | **872×3** | **174** | **✅ 已完成** |
| **v2.1** | **中值滤波/形态学补全/色彩空间/绘图/伪彩色/哈希** | **927** | **~190** | **✅ 已完成** |
| **v2.2** | **透视变换/轮廓分析/霍夫圆/DCT/色调映射** | **965** | **~215** | **✅ 已完成** |
| **v2.3** | **TIFF/ICO/ICNS/APNG 格式扩展** | **995** | **~225** | **✅ 已完成** |
| **v3.0** | **EXIF写入/seam carving/SLIC超像素/16-bit float泛化** | **907×3** | **253** | **✅ 已完成** |

## 不做的事情

以下功能明确不在计划内：

- **AVIF 编码**：需要外部编解码器（libaom/svt-av1），与"零 C 依赖"理念冲突
- **JPEG progressive 编码**：纯 MoonBit 实现成本过高
- **JPEG2000 解码**：需小波变换+算术编码，纯实现极难且使用率低
- **Go 风格 API**：bikallem/gmlewis 已覆盖此定位，不重复
- **BM3D 去噪**：状态最优去噪，纯实现极复杂，性价比低
- **超分辨率 (SRCNN/EDSR)**：深度学习类，纯 MoonBit 实现不现实
- **光流 (Farneback/Lucas-Kanade)**：视频领域，纯图像库不做
