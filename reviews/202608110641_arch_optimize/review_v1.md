# R1: 顶层架构 + types + reexport

审查时间：2026-08-11

### 审查范围

- `moon.mod`
- `src/moon.pkg`
- `src/types/image_types.mbt`、`src/types/moon.pkg`、`src/types/pkg.generated.mbti`
- `src/reexport.mbt`、`src/reexport_test.mbt`
- `src/lib/lib.mbt`、`src/lib/moon.pkg`、`src/lib/pkg.generated.mbti`
- `src/pure/{codec,color,pixel,process,util}/moon.pkg`
- `src/process/{color,edge,feature,filter,frequency,segment,transform}/moon.pkg`
- `src/format/moon.pkg`、`src/meta/moon.pkg`、`src/util/moon.pkg`、`src/testdata/moon.pkg`
- `README.md`、`src/README.mbt.md`、`docs/architecture.md`（参照）

### 发现

#### [严重] reexport.mbt 中 `decode_any` 与 `load_from_bytes` 静默丢弃 `req_channels` 参数

- **位置**：`src/reexport.mbt:99-105`、`src/reexport.mbt:145-151`
- **描述**：两个函数均声明了 `req_channels? : Int? = None` 参数，但函数体内 `ignore(req_channels)` 后调用 `@lib.load_from_bytes_auto(arg0)` 时未传递该参数。而 `@lib.load_from_bytes_auto`（`src/lib/lib.mbt:78-102`）实际支持 `req_channels` 并会通过 `@color.convert_channels_pure` 进行通道转换。用户调用 `decode_any(data, req_channels=Some(4))` 期望强制输出 RGBA，但参数被静默忽略，输出通道数由原始数据决定，违反"最小惊讶原则"，可能导致下游处理因通道数不符而崩溃。
- **建议**：将 `@lib.load_from_bytes_auto(arg0)` 改为 `@lib.load_from_bytes_auto(arg0, req_channels~)`，删除 `ignore(req_channels)`。

#### [严重] `ImageStats` 类型在两个包中重复定义

- **位置**：`src/util/image_stats.mbt:5-10`、`src/pure/process/image_stats.mbt:7-12`
- **描述**：两个包各自定义了字段完全相同的 `pub(all) struct ImageStats { mean, stddev, min_val, max_val }`。`src/pure/process/image_stats.mbt` 注释明确写着"移植自 src/util/image_stats.mbt:1-47"，即承认是复制而来。reexport.mbt:31 与 reexport.mbt:1172 转发的是 `@util.ImageStats` / `@util.compute_stats`，`pure/process` 中的 `compute_stats_pure` 未被 reexport 使用。这造成类型归属歧义：下游若同时引用 `@util.ImageStats` 与 `@pure.process.ImageStats` 会得到两个不兼容的类型。
- **建议**：删除 `src/pure/process/image_stats.mbt` 与对应测试，或反过来让 `src/util` 委托 `@pure.process` 实现并删除 `src/util` 中的副本。统一只有一个 `ImageStats` 定义。

#### [严重] `src/util` 与 `src/pure/process` 之间存在大量重复实现

- **位置**：`src/util/image_compose.mbt`、`src/util/image_noise.mbt`、`src/util/image_util.mbt`、`src/util/image_stats.mbt` 与 `src/pure/process/` 下同名文件
- **描述**：以下函数对在两个包中独立实现，逻辑相同仅差 `_pure` 后缀：
  - `hstack` / `hstack_pure`、`vstack` / `vstack_pure`、`tile` / `tile_pure`
  - `flip_vertical` / `flip_vertical_pure`、`transpose` / `transpose_pure`
  - `add_noise_gaussian` / `add_noise_gaussian_pure`、`add_noise_salt_pepper` / `add_noise_salt_pepper_pure`
  - `pad` / `pad_pure`、`add_border` / `add_border_pure`、`compute_stats` / `compute_stats_pure`
  
  `src/util/moon.pkg` 未 import `@pure/process`，证明两套实现互不委托。reexport.mbt 全部转发 `@util` 版本，`@pure.process` 中的 `_pure` 版本仅被自身测试覆盖，对顶层 API 无贡献。这违反 DRY 原则，且 `src/util` 与 `src/pure/process` 职责重叠，破坏了"pure 是底层全目标实现、util 是上层封装"的层次划分。
- **建议**：明确职责归属——要么 `src/util` 委托 `@pure.process` 实现（删除 `src/util` 中的重复代码，改为转发），要么删除 `src/pure/process` 中的重复文件。结合 scope.md 中"pure 是全目标底层"的定位，推荐方案 A：`src/util` 中的函数改为委托 `@pure.process` 的 `_pure` 版本。

#### [一般] `f` 后缀与 `_16` 后缀命名风格不一致

- **位置**：`src/reexport.mbt:222,231,321,440,818,824,830`（`f` 直接附加）vs `src/reexport.mbt:219,228,318,437,815,821,827`（`_16` 下划线分隔）
- **描述**：对 `ImageF` 的函数使用 `f` 直接附加词干（`adjust_brightnessf`、`cropf`、`rotate_90f`、`flip_horizontalf`、`loadf_from_bytes`），对 `Image16` 的函数使用 `_16` 下划线分隔（`adjust_brightness_16`、`crop_16`、`rotate_90_16`、`flip_horizontal_16`、`load_16_from_bytes`）。同一组泛化函数采用两种分隔规则，违反 API 命名一致性。MoonBit 标准 API 中类型后缀通常用下划线分隔（如 `_u8`、`_unchecked`）。
- **建议**：统一为 `_f` / `_16` 风格。将 `adjust_brightnessf` → `adjust_brightness_f`、`cropf` → `crop_f`、`rotate_90f` → `rotate_90_f`、`flip_horizontalf` → `flip_horizontal_f`、`loadf_from_bytes` → `load_f_from_bytes`、`adjust_contrastf` → `adjust_contrast_f`、`rotate_180f` → `rotate_180_f`、`rotate_270f` → `rotate_270_f`。同步修改 `src/process/transform`、`src/process/color` 等实现侧。

#### [一般] `edge_detect_sobel` 归属包与同类函数不一致

- **位置**：`src/reexport.mbt:399`（转发至 `@filter.edge_detect_sobel`）、`src/process/filter/filter.mbt:288`（实现）、`src/process/edge/edge_detect.mbt:8,74`（`edge_detect_laplacian`、`edge_detect_prewitt`）
- **描述**：三个 `edge_detect_*` 函数中，`edge_detect_laplacian` 与 `edge_detect_prewitt` 位于 `process/edge`，而 `edge_detect_sobel` 位于 `process/filter`。同一前缀族函数分散在两个包中，违反"同类同包"的职责划分原则，下游按前缀查找时会遗漏。reexport.mbt:393-399 也反映了这种分裂。
- **建议**：将 `edge_detect_sobel` 从 `src/process/filter/filter.mbt` 迁移到 `src/process/edge/edge_detect.mbt`，更新 `src/process/filter/moon.pkg` 与 `src/process/edge/moon.pkg` 的依赖，更新 reexport.mbt:399 的转发目标为 `@edge.edge_detect_sobel`。

#### [一般] `PngAnimation` 与 `GifAnimation` 类型归属不一致

- **位置**：`src/reexport.mbt:13`（`pub type PngAnimation = @codec.PngAnimation`）、`src/reexport.mbt:10`（`pub type GifAnimation = @types.GifAnimation`）、`src/pure/codec/apng_codec.mbt:8`（定义）
- **描述**：两个动画类型语义对等，但 `GifAnimation` 定义在 `@types`（全目标类型包），`PngAnimation` 定义在 `@codec`（编解码包）。类型归属策略不一致，下游若按"类型在 types 包"的约定查找 `PngAnimation` 会落空。
- **建议**：将 `PngAnimation` 定义迁移到 `src/types/image_types.mbt`，`src/pure/codec/apng_codec.mbt` 改为使用 `@types.PngAnimation`。同步更新 reexport.mbt:13 为 `pub type PngAnimation = @types.PngAnimation`。

#### [一般] `load_gif_from_bytes`、`loadf_from_bytes`、`write_jpeg_to_bytes` 声明了未实现的参数

- **位置**：`src/reexport.mbt:154-160`（`load_gif_from_bytes` 的 `req_channels`）、`src/reexport.mbt:163-169`（`loadf_from_bytes` 的 `req_channels`）、`src/reexport.mbt:197-203`（`write_jpeg_to_bytes` 的 `quality`）
- **描述**：三个函数分别声明了 `req_channels?` / `quality?` 参数并 `ignore`，但底层 `@codec.decode_gif_animation_pure(Bytes)`、`@codec.decode_hdr_pure(Bytes)`、`@codec.encode_jpeg_pure(@types.Image)` 均不接受这些参数。API 表面承诺了功能（强制通道、质量控制），实际未实现，用户传入参数无任何效果。这不同于 `decode_any` 的 bug（底层支持但未传递），此处是底层根本不支持。
- **建议**：两种选择：(1) 在底层实现这些参数后再在 reexport 中转发；(2) 在 reexport 中移除这些参数，保持 API 与实现一致。在参数未实现前，至少应在文档注释中明确标注"当前忽略"以避免误导。

#### [一般] moon.mod 版本号与文档严重不一致

- **位置**：`moon.mod:3`（`version = "2.0.0"`）、`README.md:13`（`version-3.0.0`）、`src/README.mbt.md:8`（无版本）、`docs/architecture.md:3`（`v2.0.0`）、`scope.md:26`（"已迭代至 v3.0"）
- **描述**：moon.mod 声明 2.0.0，README.md 徽章显示 3.0.0，architecture.md 标题写 v2.0.0，scope.md 称已迭代至 v3.0。版本号在四处出现三种不同值。moon.mod 是 mooncakes 发布的权威来源，若实际为 v3.0 则发布版本号错误，会导致下游依赖解析异常。
- **建议**：确认实际版本，统一更新 moon.mod、README.md、docs/architecture.md、docs/changelog.md 中的版本号。

#### [一般] API 数量在文档中与实际不一致

- **位置**：`README.md:12`（`API-197 functions + 28 types`）、`src/reexport.mbt:2`（注释 `197 pub fn + 28 pub type`）、`scope.md:26`（`219 个公开 API、28 个公开类型`）、实际 `src/pkg.generated.mbti`
- **描述**：实测 `src/reexport.mbt` 含 208 个 `pub fn` + 44 个 `pub let` = 252 个公开 API，36 个 `pub type`。README.md 与 reexport.mbt 注释称 197 functions + 28 types，scope.md 称 219 API + 28 types，三者互相矛盾且均与实际不符。API 数量是下游评估库能力的重要指标，文档失真会误导用户。
- **建议**：以 `moon info` 生成的 `src/pkg.generated.mbti` 为准，更新 README.md、src/README.mbt.md、reexport.mbt 顶部注释、docs/architecture.md 中的 API 统计数字。

#### [一般] docs/architecture.md 引用了不存在的 `core/` 包

- **位置**：`docs/architecture.md:84-88,148,196-214,363,551`
- **描述**：architecture.md 多处描述 `core/ — 统一入口 + 类型 + I/O`，列出 `image_load.mbt`、`image_write.mbt`、`image_resize.mbt` 等文件，但项目中不存在 `src/core` 目录。实际对应功能由 `src/lib` 承担。文档与实际架构脱节，会误导新开发者。
- **建议**：将 architecture.md 中所有 `core/` 引用替换为 `lib/`，并更新对应的文件列表与职责描述以匹配 `src/lib/lib.mbt` 的实际内容。

#### [轻微] reexport.mbt 顶部注释引用不可见的生成脚本

- **位置**：`src/reexport.mbt:2`（`Auto-generated by scripts/gen_reexport.py`）
- **描述**：注释声称由 `scripts/gen_reexport.py` 自动生成，但 `scripts/` 被 `.gitignore` 忽略，仓库中不存在该脚本。维护者无法确定 reexport.mbt 是手工维护还是自动生成，也无法重新生成。若为自动生成，脚本应纳入版本控制或注释应改为生成方式说明；若为手工维护，注释应删除。
- **建议**：若脚本存在且有价值，从 `.gitignore` 中移除 `scripts/` 并提交；否则删除 reexport.mbt:2 的注释。

#### [轻微] `is_supported_format` 中 `ImageFormat` 引用路径绕远

- **位置**：`src/reexport.mbt:135`（`@lib.ImageFormat::Unknown`）
- **描述**：`is_supported_format` 使用 `@lib.ImageFormat::Unknown` 判断，而 `ImageFormat` 的权威定义在 `@types`，reexport.mbt:25 也已 `pub type ImageFormat = @types.ImageFormat`。`@lib.ImageFormat` 是 `src/lib/lib.mbt:2` 的二次 re-export。通过 lib 间接引用 types 的类型，路径绕远且引入了对 `@lib` 的不必要依赖。
- **建议**：改为 `@types.ImageFormat::Unknown`，与同文件中其他 `@types.ImageFormat` 引用一致（如 reexport.mbt:102,108 等）。

#### [轻微] `decode_any` 与 `load_from_bytes` 实现完全相同

- **位置**：`src/reexport.mbt:99-105`、`src/reexport.mbt:145-151`
- **描述**：两个函数签名与实现完全相同（除函数名外）。`decode_any` 语义上强调"自动检测格式"，`load_from_bytes` 语义上强调"加载"，但实际行为一致。两个名称指同一操作，可能让下游困惑该用哪个。
- **建议**：保留一个主名称，另一个作为别名并在文档注释中标注"等价于 XXX"。或合并为单一入口。

#### [轻微] 功能特定类型归属策略不统一

- **位置**：`src/types/image_types.mbt:89`（`SuperpixelResult` 在 `@types`）vs `src/reexport.mbt:46-91`（`Complex`/`FFTResult`/`Contour`/`CornerPoint`/`GlcmFeatures` 等在各自功能包）
- **描述**：`SuperpixelResult` 定义在 `@types` 中，但同样功能特定的 `FFTResult`（`@frequency`）、`Contour`（`@edge`）、`CornerPoint`（`@feature`）、`GlcmFeatures`（`@feature`）、`ConnectedComponent`（`@segment`）等定义在各自功能包。类型归属策略不一致：核心类型在 types，功能类型有的在 types、有的在功能包。下游需从多个包导入类型。
- **建议**：明确策略并统一。推荐：核心类型（Image/Image16/ImageF/ImageInfo/LoadError/ImageFormat/ResizeFilter/ResizeEdge）放 `@types`，功能特定类型放功能包（与实现同包，高内聚）。据此将 `SuperpixelResult` 迁移到 `src/process/segment`。

#### [轻微] `src/process/moon.pkg` 与 `src/testdata/moon.pkg` 为空文件无注释

- **位置**：`src/process/moon.pkg`（1 行空）、`src/testdata/moon.pkg`（1 行空）
- **描述**：`src/process` 是 7 个子包的目录容器而非包，`src/testdata` 是无依赖的测试数据包。两个 moon.pkg 为空且无注释说明意图。虽然 MoonBit 约定空 moon.pkg 表示无依赖包，但 `src/process` 实际不是包而是容器，空 moon.pkg 的存在可能误导。
- **建议**：`src/process/moon.pkg` 可删除（目录容器不需要 moon.pkg），或添加注释说明"此目录为 process 子包容器，本身非包"。`src/testdata/moon.pkg` 保留但可加注释说明用途。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 3 |
| 一般 | 7 |
| 轻微 | 5 |

### 总评

顶层架构的"types（类型）+ pure（全目标底层）+ lib（格式分派）+ process（高级算法）+ format/meta/util（扩展）+ reexport（统一入口）"分层清晰，依赖图无环，types 包仅依赖 `moonbitlang/core/debug`，pure 各子包仅依赖 types 与同级 pure 包，层次方向正确。`image_types.mbt` 中 9 个核心类型定义紧凑（Image/Image16/ImageF 三变体字段一致、LoadError 三变体覆盖完整、ImageFormat 枚举无冗余），`pub(all)` 可见性与 `derive(Eq, Debug)` 派生统一，类型系统设计质量良好。

但本轮发现三类显著问题：(1) **reexport 转发层存在参数静默丢弃的严重 bug**（`decode_any`/`load_from_bytes` 的 `req_channels`），直接影响下游正确性；(2) **`src/util` 与 `src/pure/process` 之间存在大规模代码重复**（9+ 对函数独立实现、`ImageStats` 类型重复定义），职责边界模糊，是架构层面的设计缺陷，建议尽快明确"pure 是底层实现、util 是委托封装"的层次关系；(3) **命名与文档的一致性失修**——`f` vs `_16` 后缀风格分裂、`edge_detect_sobel` 跨包归属、`PngAnimation` vs `GifAnimation` 归属不一、moon.mod 版本号与三处文档矛盾、API 数量三处文档互相矛盾、architecture.md 引用不存在的 `core/` 包。这些问题不影响当前功能正确性，但随 v3.0 后功能持续增长会加剧认知负担，建议在 R2-R6 各轮审查前先修复本严重与一般级问题以建立稳定基线。
