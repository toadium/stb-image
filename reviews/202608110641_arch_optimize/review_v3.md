# R3: pure/color + pure/process

审查时间：2026-08-11 07:25

### 审查范围

- `src/pure/color/*.mbt`（color_convert、color_map、color_adjust 及测试）
- `src/pure/process/*.mbt`（blend、transform、geometry、filter、morphology、histogram、image_util、image_compose、image_stats、image_noise 及测试）
- `src/pure/color/moon.pkg`、`src/pure/process/moon.pkg`、`pkg.generated.mbti`
- 参照：`src/process/color/*.mbt`、`src/util/*.mbt`、`src/process/transform/*.mbt`、`src/process/filter/filter.mbt`、`src/process/segment/morphology.mbt`、`src/process/feature/histogram.mbt`、`src/lib/lib.mbt`、`src/reexport.mbt`、`src/moon.pkg`、`src/lib/moon.pkg`

### 发现

#### [严重] pure/process 全部为死代码，与 src/process + src/util 逐行重复

- **位置**：`src/pure/process/` 全部 10 个实现文件 vs `src/process/transform/transform.mbt`、`src/process/transform/geometry.mbt`、`src/process/filter/filter.mbt`、`src/process/segment/morphology.mbt`、`src/process/feature/histogram.mbt`、`src/util/image_util.mbt`、`src/util/image_compose.mbt`、`src/util/image_stats.mbt`、`src/util/image_noise.mbt`、`src/util/pixel_ops.mbt`
- **描述**：`pure/process` 公开 35 个函数 + 1 个类型，全部在 `src/process` 或 `src/util` 中有同名无后缀副本，实现逐行相同，仅差 `_pure` 后缀。具体重复对应：
  - `crop_pure`/`rotate_90_pure`/`rotate_180_pure`/`rotate_270_pure`/`flip_horizontal_pure` ↔ `src/process/transform/transform.mbt:6,40,66,90,116`
  - `warp_affine_pure`/`rotate_pure` ↔ `src/process/transform/geometry.mbt:40,77`
  - `box_blur_pure`/`gaussian_blur_pure`/`sharpen_pure`/`edge_detect_sobel_pure` ↔ `src/process/filter/filter.mbt:18,83,216,288`
  - `erode_pure`/`dilate_pure`/`morph_open_pure`/`morph_close_pure` ↔ `src/process/segment/morphology.mbt:6,86,167,173`
  - `histogram_pure`/`histogram_equalize_pure`/`histogram_normalize_pure` ↔ `src/process/feature/histogram.mbt:6,31,87`
  - `pad_pure`/`add_border_pure` ↔ `src/util/image_util.mbt:6,51`
  - `hstack_pure`/`vstack_pure`/`tile_pure`/`flip_vertical_pure`/`transpose_pure` ↔ `src/util/image_compose.mbt:5,44,74,107,131`
  - `add_noise_gaussian_pure`/`add_noise_salt_pepper_pure` ↔ `src/util/image_noise.mbt:39,70`
  - `compute_stats_pure`/`mean_value_pure`/`ImageStats` ↔ `src/util/image_stats.mbt:15,40,5`
  - `blend_*_pure`（13 个）↔ `src/util/pixel_ops.mbt:103-478`
  
  关键证据：
  - 全代码库 grep `@pure.process` / `@pure_process` 结果为 **0 次引用**（非测试代码）
  - `src/moon.pkg` 顶层包依赖未列出 `src/pure/process`
  - `src/lib/moon.pkg` 未列出 `src/pure/process`
  - `src/reexport.mbt` 全部 46 处 `@color`/`@process` 引用都指向 `src/process/color` 等，无一处指向 `@pure.process`
  - `pure/process` 各文件头注释明确写着"移植自 src/util/..."、"移植自 src/process/.../..."，即承认是复制而来
  
  这意味着 `pure/process` 整个包是**完全孤立的死代码**，35 个公开 API + 1 个类型对顶层 API 零贡献，仅被自身测试覆盖。维护成本翻倍且存在行为偏离风险。
- **建议**：删除整个 `src/pure/process/` 目录，或反过来让 `src/process` + `src/util` 委托 `@pure.process` 实现并删除重复副本。结合 R1 发现 1（`src/util` 与 `src/pure/process` 重复）和 scope.md"pure 是底层全目标实现"定位，推荐方案 A：**删除 `src/pure/process/`**，因为 `src/process` + `src/util` 已是实际生效的实现，`pure/process` 从未进入顶层 API。若未来需要全目标纯实现，应先建立 `pure/process → reexport` 的转发路径再迁移。

#### [严重] pure/color 16 个函数为死代码，仅 convert_channels_pure 被 lib 使用

- **位置**：`src/pure/color/color_convert.mbt`、`src/pure/color/color_map.mbt`、`src/pure/color/color_adjust.mbt` vs `src/process/color/color_convert.mbt`、`src/process/color/color_adjust.mbt`、`src/util/color_map.mbt`
- **描述**：`pure/color` 公开 17 个函数，其中 16 个在 `src/process/color` 或 `src/util` 中有同名无后缀副本，实现逐行相同：
  - `to_grayscale_pure`/`to_rgb_pure`/`to_rgba_pure`/`premultiply_alpha_pure`/`unpremultiply_alpha_pure` ↔ `src/process/color/color_convert.mbt:6,34,58,90,125`
  - `adjust_brightness_pure`/`adjust_contrast_pure`/`adjust_gamma_pure`/`invert_pure`/`rgb_to_hsv_pure`/`hsv_to_rgb_pure`/`rgb_to_hsl_pure`/`hsl_to_rgb_pure` ↔ `src/process/color/color_adjust.mbt:18,46,75,106,131,156,199,228`
  - `apply_lut_pure`/`gradient_map_pure`/`set_alpha_pure`/`fill_alpha_pure` ↔ `src/util/color_map.mbt:8,39,114,141`
  
  唯一例外：`convert_channels_pure`（`color_convert.mbt:95`）被 `src/lib/lib.mbt:99` 引用，是 `pure/color` 唯一进入顶层 API 的函数。但 `src/process/color/color_convert.mbt` 中**没有** `convert_channels` 的对应实现，`src/util` 中也没有——`convert_channels` 仅存在于 `pure/color`。
  
  关键证据：
  - 全代码库 grep `@pure.color` 仅 `src/lib/lib.mbt:99` 一处引用 `@color.convert_channels_pure`
  - `src/moon.pkg` 顶层包依赖未列出 `src/pure/color`（仅 `src/lib/moon.pkg` 列出）
  - `src/reexport.mbt` 中 `to_grayscale`/`to_rgb`/`to_rgba`/`premultiply_alpha`/`unpremultiply_alpha`/`adjust_brightness`/`adjust_contrast`/`adjust_gamma`/`invert`/`rgb_to_hsv`/`hsv_to_rgb`/`rgb_to_hsl`/`hsl_to_rgb` 全部转发 `@color`（即 `src/process/color`），无一处转发 `@pure.color`
  
  结论：`pure/color` 17 个函数中 16 个是死代码，仅 `convert_channels_pure` 有效。这 16 个函数与 `src/process/color` + `src/util` 重复实现，违反 DRY。
- **建议**：将 `convert_channels_pure` 保留（或迁移到 `src/process/color/color_convert.mbt` 并让 `src/lib` 改为委托 `@color.convert_channels`），删除 `pure/color` 中其余 16 个重复函数。若要保留 `pure/color` 作为底层全目标实现，应让 `src/process/color` 和 `src/util` 委托 `@pure.color` 并更新 reexport 转发路径。

#### [严重] pure/color 与 src/process/color 职责划分违背 scope.md 定位

- **位置**：`src/pure/color/pkg.generated.mbti`（17 函数）、`src/process/color/pkg.generated.mbti`（38 函数）
- **描述**：scope.md 第 18 行定义"pure 是底层全目标实现，process 是高级算法"。但实际：
  - `src/process/color` 既包含底层函数（`to_grayscale`/`to_rgb`/`adjust_brightness`/`adjust_contrast`/`adjust_gamma`/`invert`/`rgb_to_hsv` 等 13 个与 `pure/color` 重复的函数），也包含高级算法（`clahe`/`dehaze`/`msr`/`msrcr`/`ssr`/`kmeans_segment`/`region_growing_segment`/`guided_filter`/`flood_fill`/`adaptive_threshold_*`/`threshold_otsu`/`reinhard_tonemap`/`gamma_tonemap` 等 25 个高级算法）
  - `pure/color` 的 17 个函数全部在 `src/process/color` 中有同名副本（除 `convert_channels_pure`）
  - `src/process/color` 没有委托 `pure/color`，而是独立重复实现
  - 两者形成两套并行 API，`pure/color` 的"底层全目标实现"定位未实际生效
  
  这违背了 scope.md 的层次划分，也违背了"最小化公开面"原则——同一功能暴露两个入口（`@pure.color.to_grayscale_pure` 和 `@color.to_grayscale`），下游不知该用哪个。
- **建议**：明确职责归属。推荐方案：`src/process/color` 中的 13 个底层函数改为委托 `@pure.color`（删除 `src/process/color` 中的重复代码，改为 `pub fn to_grayscale(img) = @pure.color.to_grayscale_pure(img)`），`src/process/color` 仅保留 25 个高级算法。这样 `pure/color` 成为底层唯一实现，`process/color` 成为高级算法层，符合 scope.md 定位。

#### [一般] pure/process 文件命名风格不统一

- **位置**：`src/pure/process/` 目录
- **描述**：10 个实现文件命名存在三种风格：
  - `image_` 前缀：`image_util.mbt`、`image_compose.mbt`、`image_stats.mbt`、`image_noise.mbt`
  - 功能名：`blend.mbt`、`transform.mbt`、`geometry.mbt`、`filter.mbt`、`morphology.mbt`、`histogram.mbt`
  
  对比 `src/process/` 按功能分目录（`transform/`、`filter/`、`segment/`、`feature/`、`edge/`、`color/`、`frequency/`），`pure/process` 把所有功能放在一个包里，文件命名风格混乱。`image_util` 与 `image_compose` 实为几何操作（pad/add_border/hstack/vstack/tile），却用 `image_` 前缀；`transform` 与 `geometry` 都是几何变换却分两文件。
  
  此外，`histogram.mbt` 注释写"移植自 src/process/feature/histogram.mbt"，但 `pure/process` 把 histogram 归在 process 根下，而 `src/process` 把 histogram 归在 `feature/` 子目录下，归属层级不一致。
- **建议**：若保留 `pure/process`，统一命名为功能名风格（删除 `image_` 前缀）：`geometry.mbt`（合并 transform+geometry+image_util+image_compose 的几何操作）、`filter.mbt`、`morphology.mbt`、`histogram.mbt`、`noise.mbt`、`blend.mbt`、`stats.mbt`。或按 `src/process` 的分目录模式重组。

#### [一般] pure/color/color_map.mbt 与 src/process/color/colormap.mbt 文件命名不一致

- **位置**：`src/pure/color/color_map.mbt`（下划线分隔）、`src/process/color/colormap.mbt`（无下划线）
- **描述**：同族功能（色彩映射）在两个包中文件命名风格不同：
  - `pure/color` 用 `color_map.mbt`（下划线分隔，含 `apply_lut_pure`/`gradient_map_pure`/`set_alpha_pure`/`fill_alpha_pure`）
  - `src/process/color` 用 `colormap.mbt`（无下划线，含 `Colormap` 枚举 + `apply_colormap`）
  
  两者功能相关但非完全对应（`pure/color` 是 LUT/渐变/alpha 操作，`src/process/color` 是伪彩色映射预设），但命名相似易混淆。
- **建议**：统一命名风格。`pure/color` 的 `color_map.mbt` 可重命名为 `lut.mbt`（反映其 LUT/渐变/alpha 操作本质），或 `src/process/color/colormap.mbt` 重命名为 `color_map.mbt` 保持一致。

#### [一般] pure/process 包名 process 与 src/process 目录同名，语义歧义

- **位置**：`src/pure/process/`（包名 `@pure.process`）、`src/process/`（目录容器，含 7 子包）
- **描述**：`pure/process` 是一个 MoonBit 包，`src/process` 是目录容器（含 `color`/`edge`/`feature`/`filter`/`frequency`/`segment`/`transform` 7 个子包）。两者同名 `process` 但层次不同：
  - `@pure.process` 是单包，含 35 个函数
  - `src/process` 是 7 个子包的容器，每个子包含若干函数
  
  下游开发者看到 `process` 难以区分指的是 `pure/process` 还是 `src/process/*`。scope.md 第 18 行的"pure/{codec,pixel,color,process,util}"与"lib/format/meta/process/util"并列，但 `pure/process` 与 `src/process` 同名导致语义歧义。
- **建议**：若保留 `pure/process`，重命名为更具体的名字，如 `pure/ops`（图像操作）或 `pure/iproc`（image processing）。或按 R3 严重问题 1 建议直接删除 `pure/process`。

#### [一般] 私有辅助函数在 pure/color、pure/process 与 src/process、src/util 间重复定义

- **位置**：
  - `src/pure/color/color_adjust.mbt:6` `clamp_byte` ↔ `src/process/color/color_adjust.mbt:5` `clamp_byte`
  - `src/pure/color/color_map.mbt:84` `interp_gradient` ↔ `src/util/color_map.mbt:83` `interp_gradient`
  - `src/pure/process/morphology.mbt:178` `clamp_i` ↔ `src/process/segment/morphology.mbt` `clamp_i`
  - `src/pure/process/filter.mbt:6` `clamp_coord` ↔ `src/process/filter/filter.mbt:5` `clamp_coord`
  - `src/pure/process/geometry.mbt:7` `sample_bilinear` ↔ `src/process/transform/geometry.mbt:6` `sample_bilinear`
  - `src/pure/process/image_noise.mbt:9-35` `LCG`/`lcg_next`/`lcg_float`/`lcg_gaussian` ↔ `src/util/image_noise.mbt:6-32`
- **描述**：6 组私有辅助函数在 `pure/color`、`pure/process` 与对应的上层包中重复定义，实现完全相同。这些是包内私有函数（`fn` 而非 `pub fn`），无法跨包复用，导致每个包各自定义一份。
- **建议**：提取到共享工具包（如 `pure/pixel` 或新建 `pure/util`）作为 `pub fn`，各包删除本地定义改为引用。或按 R3 严重问题 1/2 建议删除 `pure/color`/`pure/process` 的重复实现，问题自然消失。

#### [一般] pure/color 与 pure/process 之间无直接依赖，但共享 pure/pixel 工具，依赖关系合理但孤立

- **位置**：`src/pure/color/moon.pkg`（依赖 types、pure/pixel、math）、`src/pure/process/moon.pkg`（依赖 types、pure/pixel、math、debug）
- **描述**：
  - `pure/color` 依赖 `pure/pixel`（使用 `clamp_b`，见 `color_map.mbt:107`）
  - `pure/process` 依赖 `pure/pixel`（使用 `clamp_b`、`clamp_byte_v`，见 `blend.mbt:85`、`image_noise.mbt:54`）
  - 两者之间无直接依赖，依赖关系本身合理
  
  但结合 R3 严重问题 1/2，`pure/color` 和 `pure/process` 整体是孤立的死代码岛，依赖关系"合理"但无意义——`pure/pixel` 本身也是死代码（R2 严重问题 1 已发现）。三个 pure 子包形成自闭环，与顶层 API 完全断开。
- **建议**：在解决 R3 严重问题 1/2 后，此问题自然消解。若保留 `pure/color` 的 `convert_channels_pure`，应确保 `pure/pixel` 的 `clamp_b` 也保留。

#### [轻微] pure/process/image_stats.mbt 的 ImageStats 与 src/util/image_stats.mbt 重复（R1 已发现）

- **位置**：`src/pure/process/image_stats.mbt:7-12`、`src/util/image_stats.mbt:5-10`
- **描述**：R1 严重问题 2 已记录。`ImageStats` 类型在两个包中重复定义，字段完全相同。reexport 转发的是 `@util.ImageStats`，`pure/process.ImageStats` 未被使用。
- **建议**：按 R3 严重问题 1 建议删除 `pure/process`，此问题自然消解。

#### [轻微] pure/color 注释中"移植自"路径已过时

- **位置**：`src/pure/color/color_convert.mbt:3`（"移植自 src/process/color/color_convert.mbt:1-162"）、`src/pure/color/color_map.mbt:3`（"移植自 src/util/color_map.mbt:1-174"）、`src/pure/color/color_adjust.mbt:3`（"移植自 src/process/color/color_adjust.mbt:1-264"）
- **描述**：注释标注的源文件行数范围与实际不符：
  - `color_convert.mbt:3` 写"1-162"，但 `src/process/color/color_convert.mbt` 实际 288 行（含 ycbcr/xyz/lab/cmyk 等额外函数）
  - `color_adjust.mbt:3` 写"1-264"，实际 264 行，匹配
  - `color_map.mbt:3` 写"1-174"，实际 174 行，匹配
  
  `color_convert.mbt` 的行数范围过时，且"移植自"注释本身暗示了重复关系。
- **建议**：按 R3 严重问题 2 建议删除重复函数时一并删除注释。若保留，更新行数范围或改为引用功能描述而非具体行号。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 3 |
| 一般 | 5 |
| 轻微 | 2 |

### 总评

`pure/color` 与 `pure/process` 两个包存在严重的架构问题：**两者整体上是对 `src/process/color` + `src/util` + `src/process/{transform,filter,segment,feature}` 的逐行复制，且几乎完全未进入顶层 API**。`pure/process` 35 个函数 + 1 类型全部为死代码（`@pure.process` 全代码库 0 次引用），`pure/color` 17 个函数中仅 1 个（`convert_channels_pure`）被 `src/lib` 使用。这与 R1 发现的"`src/util` 与 `src/pure/process` 重复"、R2 发现的"`pure/pixel` 与 `src/util` 重复"形成一致的架构缺陷：**pure 层（除 `pure/codec` 外）整体未建立到 reexport 的转发路径，沦为孤立死代码**。

核心矛盾在于 scope.md 定义了"pure 是底层全目标实现、process/util 是上层"的层次，但实际 `src/process` 和 `src/util` 没有委托 `pure` 实现，而是各自独立实现，`pure` 反而成了一份多余的副本。这违反 DRY、最小化公开面、最小惊讶三原则，且随功能增长维护成本翻倍。

命名一致性方面，`_pure` 后缀在 `pure/color` 和 `pure/process` 内部使用统一，但与 `src/process/color`/`src/util` 的无后缀同名函数形成两套并行 API，下游困惑。`pure/process` 文件命名风格不统一（`image_` 前缀 vs 功能名），`pure/color/color_map.mbt` 与 `src/process/color/colormap.mbt` 命名分歧。`pure/process` 包名与 `src/process` 目录同名导致语义歧义。

**建议优先级**：(1) 决定 `pure/color`/`pure/process` 的去留——若保留则建立到 reexport 的转发路径并删除 `src/process`/`src/util` 中的重复副本，若删除则将 `convert_channels_pure` 迁移到 `src/process/color` 后删除整个 `pure/color` 和 `pure/process`；(2) 统一文件命名风格；(3) 消除私有辅助函数重复。建议在 R4-R6 各轮审查前先修复本严重问题以建立稳定基线。
