# R5: lib/process + lib/util（src/process + src/util）

审查时间：2026-08-11 08:10

### 审查范围

- `src/process/` 下 7 个子包共 80+ 源文件：`color/`、`edge/`、`feature/`、`filter/`、`frequency/`、`segment/`、`transform/`
- `src/util/` 下 7 个源文件：`image_util.mbt`、`image_compose.mbt`、`image_stats.mbt`、`image_noise.mbt`、`pixel_ops.mbt`、`pixel_advanced.mbt`、`color_map.mbt`
- 各子包 `moon.pkg`、`pkg.generated.mbti`
- 参照：`src/pure/process/pkg.generated.mbti`、`src/pure/color/pkg.generated.mbti`（R3 已发现重复）

### 发现

#### [严重] process/color 与 process/segment 职责交叉错位

- **位置**：`src/process/color/color_segment.mbt:29,133,256,328`；`src/process/segment/quantize.mbt:7,75`；`src/process/segment/kmeans_quantize.mbt:7`
- **描述**：两个子包的职责严重交叉错位，违反单一职责与最小惊讶原则：
  - **color 包做分割**：`kmeans_segment`、`region_growing_segment`、`flood_fill`、`segment_to_color` 是分割/区域操作，却在 color 包。`SegmentLabelImage`、`SegmentRegion` 类型也在 color 包定义（`color_segment.mbt:5,14`），但语义属于 segment。
  - **segment 包做颜色量化**：`floyd_steinberg`（Floyd-Steinberg 抖动）、`median_cut`（Median Cut 量化）、`k_means_quantize`（K-means 色彩量化）是颜色量化操作，却在 segment 包。
  - 下游开发者寻找分割函数时会在 segment 包扑空，寻找量化函数时会在 color 包扑空，与包名语义冲突。
- **建议**：将 `kmeans_segment`/`region_growing_segment`/`flood_fill`/`segment_to_color` 及 `SegmentLabelImage`/`SegmentRegion` 类型迁移到 `src/process/segment/`；将 `floyd_steinberg`/`median_cut`/`k_means_quantize` 迁移到 `src/process/color/`。迁移后 segment 包专注分割，color 包专注颜色操作。

#### [严重] util 依赖 process/transform，层次倒置

- **位置**：`src/util/moon.pkg:4`（`import "Toadium/image/src/process/transform"`）；`src/util/image_util.mbt:112,131`（`@transform.crop` 调用）
- **描述**：`src/util` 是工具层，`src/process` 是高级算法层。按 scope.md 第 18 行的层次定义，util 应是底层工具，process 应是高级算法。但 util 反向依赖 process/transform：
  - `resize_to_cover`（`image_util.mbt:96`）调用 `@transform.crop`
  - `resize_to_contain`（`image_util.mbt:117`）调用 `@transform.crop`（经 `pad` 间接）和 `@pure_util.resize_pure`
  - 这意味着 util 包无法独立使用，必须拖入整个 process/transform 依赖链。层次倒置导致编译依赖图不清晰，违反正交性原则。
- **建议**：将 `resize_to_cover`/`resize_to_contain` 迁移到 `src/process/transform/`（它们是高级 resize 操作，含裁剪和填充逻辑），util 包仅保留底层工具。或让 util 通过参数注入 crop 函数，消除硬依赖。

#### [严重] K-means 命名风格不一致

- **位置**：`src/process/color/color_segment.mbt:29`（`kmeans_segment`）；`src/process/segment/kmeans_quantize.mbt:7`（`k_means_quantize`）
- **描述**：同一 K-means 算法族的两个函数命名风格不一致：
  - `kmeans_segment`：`kmeans` 无下划线
  - `k_means_quantize`：`k_means` 有下划线
  - 项目其余 API 一致使用 snake_case（如 `floyd_steinberg`、`median_cut`、`hough_circles`），但 K-means 的两种写法并存，下游开发者无法判断哪个是规范。
- **建议**：统一为 `kmeans`（无下划线，更符合行业惯用写法 K-means→kmeans）或 `k_means`（严格 snake_case）。推荐 `kmeans_segment`/`kmeans_quantize`，因 `kmeans` 作为算法专名在 OpenCV/PIL 等库中均作为单词处理。

#### [一般] edge_detect_sobel 在 filter 包，其余 edge_detect_* 在 edge 包

- **位置**：`src/process/filter/filter.mbt:288`（`edge_detect_sobel`）；`src/process/edge/edge_detect.mbt:8,74`（`edge_detect_laplacian`、`edge_detect_prewitt`）
- **描述**：同一功能族（边缘检测）分散在两个包：
  - `edge_detect_sobel` 在 filter 包
  - `edge_detect_laplacian`、`edge_detect_prewitt` 在 edge 包
  - 三者命名风格一致（`edge_detect_*`），但归属不一致。下游开发者寻找 Sobel 边缘检测时，自然会在 edge 包查找，而非 filter 包。
- **建议**：将 `edge_detect_sobel` 迁移到 `src/process/edge/edge_detect.mbt`，与 `edge_detect_laplacian`/`edge_detect_prewitt` 合并到同一文件。

#### [一般] flip_horizontal 在 transform，flip_vertical 在 util

- **位置**：`src/process/transform/transform.mbt:116`（`flip_horizontal`）；`src/util/image_compose.mbt:107`（`flip_vertical`）
- **描述**：水平翻转和垂直翻转是一对对称操作，但分散在两个不同层级的包：
  - `flip_horizontal` 在 process/transform（高级算法层）
  - `flip_vertical` 在 util（工具层）
  - 两者实现复杂度相当（均为 O(n) 像素拷贝），无理由分属不同层级。下游开发者需要翻转时必须在两个包中分别查找。
- **建议**：统一到 `src/process/transform/`，将 `flip_vertical` 从 util 迁移到 transform。同时补充 `flip_vertical_16`/`flip_verticalf` 变体以与 `flip_horizontal_16`/`flip_horizontalf` 对称。

#### [一般] process/feature 职责过宽，混合三类不同功能

- **位置**：`src/process/feature/`（22 个文件）
- **描述**：feature 包混合了三类语义不同的功能：
  - **特征提取**（合理）：`harris_corners`、`shi_tomasi`、`good_features_to_track`、`gabor_filter`、`glcm_features`、`lbp`、`ahash`/`dhash`/`phash`、`integral_image`
  - **直方图操作**（应属 color）：`histogram_equalize`、`histogram_normalize`、`histogram_matching` 是对比度/颜色调整操作，与 `process/color/adjust_contrast`/`adjust_gamma` 语义同族
  - **质量评估**（可独立）：`mse`、`psnr`、`ssim` 是图像质量度量，与特征提取语义不同
  - feature 包 22 个文件、29 个公开 API，职责过宽，违反单一职责。
- **建议**：将 `histogram_equalize`/`histogram_normalize`/`histogram_matching` 迁移到 `src/process/color/`（与 `adjust_contrast`/`adjust_gamma` 同包）；`mse`/`psnr`/`ssim` 可保留在 feature（作为质量特征）或独立为 `src/process/quality/`。

#### [一般] process/transform 职责过宽，6 类功能混于一包

- **位置**：`src/process/transform/`（19 个文件）
- **描述**：transform 包混合了 6 类语义不同的功能：
  - **基本变换**：`crop`/`rotate_*`/`flip_horizontal`（transform.mbt、transform_16f.mbt）
  - **几何变换**：`warp_affine`/`warp_perspective`/`get_affine_transform`/`get_perspective_transform`/`get_rotation_matrix_2d`（geometry.mbt、perspective.mbt）
  - **绘图**：`draw_circle`/`draw_line`/`draw_rectangle`/`draw_polygon`/`draw_copy`/`draw_over`（draw.mbt）
  - **内容感知缩放**：`seam_carve_resize`/`compute_energy`/`find_*_seam`/`remove_*_seam`（seam_carving.mbt）
  - **多频带融合**：`multi_band_blend`（multi_band_blend.mbt）
  - **金字塔**：`pyr_down`/`pyr_up`/`build_gaussian_pyramid`/`build_laplacian_pyramid`（pyramid.mbt）
  - 19 个文件、34 个公开 API，是 process 下最大的子包。绘图与变换语义差异显著，下游开发者寻找绘图函数时在 transform 包查找不符合直觉。
- **建议**：至少将 `draw_*` 独立为 `src/process/draw/`（或归入 util）；`seam_carving` 可独立为 `src/process/seam_carving/` 或保留；`multi_band_blend` 可考虑归入 `src/process/blend/` 或保留。

#### [一般] util/convolve 与 process/filter 职责重叠

- **位置**：`src/util/pixel_advanced.mbt:85`（`convolve`）；`src/process/filter/filter.mbt`（`box_blur`/`gaussian_blur`/`sharpen`/`median_blur`）
- **描述**：`convolve` 是通用 3×3 卷积操作，语义上属于滤波，却在 util 包。`process/filter` 包的 `box_blur`/`gaussian_blur`/`sharpen` 都是卷积的特化，但 `convolve` 作为通用基础却在另一个包。下游开发者需要自定义卷积核时，会在 filter 包扑空。
- **建议**：将 `convolve` 迁移到 `src/process/filter/`，与具体滤波器同包。

#### [一般] clamp 辅助函数在 5+ 个子包重复定义且命名不统一

- **位置**：
  - `src/process/color/helpers.mbt:2`（`clamp_i`）
  - `src/process/color/color_adjust.mbt:5`（`clamp_byte`）
  - `src/process/edge/helpers.mbt:2,13`（`clamp_b`、`clamp_i`）
  - `src/process/feature/helpers.mbt:2`（`clamp_i`）
  - `src/process/segment/morphology.mbt:235`（`clamp_i`）
  - `src/process/filter/filter.mbt:5`（`clamp_coord`）
  - `src/util/pixel_advanced.mbt:4`（`clamp_b`）
  - `src/util/pixel_ops.mbt:4`（`clamp_byte_v`）
- **描述**：字节 clamp 函数有 4 个不同命名（`clamp_b`、`clamp_byte`、`clamp_byte_v`、`clamp_coord`），整数 clamp 有 2 个不同命名（`clamp_i`、`clamp_coord`）。这些是包内私有函数（`fn` 而非 `pub fn`），无法跨包复用，导致每个包各自定义。R3 已发现 pure/color、pure/process 与上层包的 clamp 重复，本轮确认 process 子包间也存在同样问题。
- **建议**：提取到共享工具包（如 `src/types/` 或新建 `src/pure/math/`）作为 `pub fn`，各包删除本地定义改为引用。统一命名为 `clamp_byte`/`clamp_int`。

#### [一般] haar 变换命名风格与 fft/dct 不一致

- **位置**：`src/process/frequency/haar_wavelet.mbt:15,40`（`haar_transform_1d`/`haar_inverse_transform_1d`）；`src/process/frequency/fft.mbt:22`（`fft_2d`/`ifft_2d`）；`src/process/frequency/dct.mbt`（`dct_2d`/`idct_2d`）
- **描述**：同一 frequency 包内，逆变换命名风格不一致：
  - FFT/DCT：正变换 `fft_2d`/`dct_2d`，逆变换 `ifft_2d`/`idct_2d`（`i` 前缀）
  - Haar：正变换 `haar_transform_1d`，逆变换 `haar_inverse_transform_1d`（`inverse_` 前缀）
  - 两种风格并存，违反一致性原则。
- **建议**：统一为 `i` 前缀风格：`haar_transform_1d`→`haar_1d`（与 `fft_2d` 对称），`haar_inverse_transform_1d`→`ihaar_1d`（与 `ifft_2d` 对称）。或保留 `haar_transform_1d` 但逆变换改为 `ihaar_transform_1d`。

#### [一般] AffineMatrix 在 perspective.mbt 中定义，文件命名与内容不符

- **位置**：`src/process/transform/perspective.mbt:6,22`（`PerspectiveMatrix`、`AffineMatrix`）；`perspective.mbt:43`（`get_affine_transform`）；`perspective.mbt:73`（`get_rotation_matrix_2d`）
- **描述**：`perspective.mbt` 文件名暗示仅含透视变换内容，但实际包含：
  - `PerspectiveMatrix` + `warp_perspective` + `get_perspective_transform`（透视相关，合理）
  - `AffineMatrix` + `get_affine_transform` + `get_rotation_matrix_2d`（仿射相关，应在 affine.mbt 或 geometry.mbt）
  - 文件名与内容不符，下游开发者寻找仿射相关 API 时不会在 perspective.mbt 查找。
- **建议**：将 `AffineMatrix`/`get_affine_transform`/`get_rotation_matrix_2d` 迁移到 `geometry.mbt`（已含 `warp_affine`）或新建 `affine.mbt`。`perspective.mbt` 仅保留透视相关内容。

#### [轻微] util 包内 clamp 函数重复定义且命名不同

- **位置**：`src/util/pixel_ops.mbt:4`（`clamp_byte_v`）；`src/util/pixel_advanced.mbt:4`（`clamp_b`）
- **描述**：同一 util 包内两个文件分别定义了字节 clamp 函数，命名不同（`clamp_byte_v` vs `clamp_b`），实现完全相同。`color_map.mbt` 和 `image_noise.mbt` 使用 `clamp_b`（来自 pixel_advanced.mbt），`pixel_ops.mbt` 使用自己的 `clamp_byte_v`。
- **建议**：统一为单一定义，提取到 `image_util.mbt` 或新建 `helpers.mbt` 作为包内共享。

#### [轻微] SuperpixelResult 在 types 包，其余功能类型在各 process 子包，归属不一致

- **位置**：`src/types/`（`SuperpixelResult`）；`src/process/color/color_segment.mbt:5,14`（`SegmentLabelImage`、`SegmentRegion`）；`src/process/segment/`（`ConnectedComponent`、`ConnectedComponentLabelImage`、`StructuringElement`）；`src/process/edge/`（`Circle`、`Contour`、`HoughLine`、`Moments`）；`src/process/feature/`（`CornerPoint`、`GlcmFeatures`、`IntegralImage`）；`src/process/frequency/`（`FFTResult`、`Complex`、`HaarWaveletResult`）；`src/process/transform/`（`AffineMatrix`、`PerspectiveMatrix`）
- **描述**：功能特定类型的归属策略不一致：
  - `SuperpixelResult` 在 types 包（全局共享层）
  - `SegmentLabelImage`/`ConnectedComponentLabelImage` 等同类分割结果类型却在 process 子包
  - `ImageStats` 在 util 包
  - 无统一规则：哪些类型应放 types 包（跨包共享），哪些应放功能子包（局部使用）。
- **建议**：明确归属规则：仅跨多个子包共享的类型放 types 包（如 `Image`/`Image16`/`ImageF`），功能特定类型放各自子包。据此 `SuperpixelResult` 应迁移到 `src/process/segment/`（仅 slic 使用）。

#### [轻微] color_convert.mbt 包含通道操作，文件名与内容不完全匹配

- **位置**：`src/process/color/color_convert.mbt`（含 `to_grayscale`/`to_rgb`/`to_rgba`/`premultiply_alpha`/`unpremultiply_alpha`/`convert_channels_pure` 等）
- **描述**：`color_convert` 文件名暗示色彩空间转换（如 `rgb_to_hsv`/`hsv_to_rgb`），但实际还包含通道操作（`to_grayscale`/`to_rgb`/`to_rgba`/`premultiply_alpha`/`unpremultiply_alpha`）。这些操作语义上属于通道/格式转换，与色彩空间转换不同。
- **建议**：可拆分为 `color_space.mbt`（rgb_to_hsv 等色彩空间转换）和 `channel_ops.mbt`（to_grayscale/to_rgb/premultiply_alpha 等通道操作），或保留但更新文件头注释明确范围。

#### [轻微] distance_transform_visualize 命名过长且语序与其他可视化函数不一致

- **位置**：`src/process/segment/distance_transform.mbt`（`distance_transform_visualize`）
- **描述**：`distance_transform_visualize` 函数名过长（30 字符），且语序为"操作_可视化"，而项目中其他可视化函数如 `segment_to_color`（color_segment.mbt:328）用"操作_to_color"语序。虽无严格规范，但命名冗长。
- **建议**：可简化为 `visualize_distance_transform`（动词前缀，更符合英语语序）或 `distance_transform_to_image`（与 `segment_to_color` 风格一致）。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 3 |
| 一般 | 8 |
| 轻微 | 4 |

### 总评

`src/process` 7 个子包和 `src/util` 的整体设计存在**结构性职责错位**问题，需要系统性重构：

1. **职责交叉**（严重）：color 与 segment 包职责互换——color 做分割、segment 做量化。这是最紧迫的问题，直接导致下游 API 入口与包名语义冲突。建议按功能语义交换两个包中的错位函数。

2. **层次倒置**（严重）：util 反向依赖 process/transform，破坏了 scope.md 定义的层次架构。`resize_to_cover`/`resize_to_contain` 应迁出 util。

3. **命名不一致**（严重+一般）：K-means 两种命名风格、edge_detect 分散两包、flip_horizontal/flip_vertical 分散两包、haar 与 fft/dct 逆变换命名风格不同。这些不一致增加下游学习成本。

4. **职责过宽**（一般）：transform 包混合 6 类功能（19 文件 34 API），feature 包混合 3 类功能（22 文件 29 API）。建议拆分。

5. **重复代码**（一般）：clamp 辅助函数在 5+ 个子包重复定义且命名不统一（4 种不同命名），与 R3 发现的 pure 层重复问题同源。需提取共享工具包。

6. **与 R3 关联**：R3 已发现 pure/process 全部为死代码（与 src/process + src/util 重复）、pure/color 16 个函数为死代码。本轮确认 src/process 子包间和 src/util 内部也存在重复（clamp 函数），重复问题贯穿 pure 层和 process/util 层，需统一治理。

正面方面：`_16`/`f` 后缀命名一致（crop/crop_16/cropf、adjust_brightness/adjust_brightness_16/adjust_brightnessf）；snake_case 风格整体贯彻良好；frequency 包无 process 内部依赖，独立性良好；filter→transform、segment→color 的依赖虽有争议但方向单一无环。核心问题集中在职责划分和命名一致性，重构成本可控。
