# R6: 文档与下游可用性综合评估

审查时间：2026-08-11

### 审查范围

- `README.md`
- `src/README.mbt.md`
- `docs/api_reference.md`
- `docs/roadmap.md`
- `docs/changelog.md`
- `docs/architecture.md`
- `AGENTS.md`
- `moon.mod`
- `src/reexport.mbt`（用于核对 API 实际数量）
- `src/types/image_types.mbt`（用于核对类型定义）
- `src/moon.pkg` 及 `src/*/` 目录结构（用于核对包结构）

### 发现

#### [严重] README.md 徽章版本号与 moon.mod 不一致

- **位置**：`README.md:13`、`moon.mod:3`
- **描述**：README.md 徽章显示 `version-3.0.0`，但 `moon.mod` 中 `version = "2.0.0"`。changelog.md 最新条目为 v3.0，roadmap.md 也标记 v3.0 已完成。下游开发者通过 `moon add` 安装时会得到 2.0.0 版本，与文档宣称的 3.0.0 严重不符，违反"最小惊讶"原则。
- **建议**：将 `moon.mod` 版本更新为 `3.0.0` 以与文档和实际功能对齐，或将所有文档回退为 v2.0.0。鉴于 v3.0 功能已交付，推荐前者。

#### [严重] README.md 徽章 API 数量严重失真

- **位置**：`README.md:12`（`API-197 functions + 28 types`）
- **描述**：实际 `src/reexport.mbt` 中有 **252 个 `pub fn`/`pub let`** 和 **36 个 `pub type`**。徽章低估了 55 个函数和 8 个类型。同时 `README.md:38` 文案"197 个 API"、`README.md:205` 注释"197 pub fn + 28 pub type"均与实际不符。下游开发者依赖徽章评估库能力，失真数据误导选型。
- **建议**：统一更新为 `API-252 functions + 36 types`，并同步更新 `README.md:38`、`README.md:205` 文案。

#### [严重] docs/api_reference.md 列出 19 个不存在的函数

- **位置**：`docs/api_reference.md:48-70`、`76-79`、`93-99`、`154-157`
- **描述**：以下 19 个函数在 `api_reference.md` 中列出，但在 `src/reexport.mbt` 和整个 `src/` 中均不存在：
  - **加载**：`load_from_path`、`load_16_from_path`、`loadf_from_path`、`load_gif_from_path`、`load_16_from_bytes`
  - **写入**：`write_png_to_path`、`write_bmp_to_path`、`write_tga_to_path`、`write_jpeg_to_path`、`write_hdr_to_path`
  - **查询**：`info_from_path`、`is_16_bit_from_path`、`is_hdr_from_path`
  - **元数据**：`read_exif_from_path`、`read_png_text_chunks_from_path`
  - **文件 I/O**：`read_file_bytes`
  - **缩放变体**：`resize_srgb`、`resize_16`、`resizef`
  下游开发者按文档调用会直接得到"未定义符号"编译错误，这是文档欺骗性问题。
- **建议**：从 `api_reference.md` 中删除这 19 个不存在的函数条目，或在 `reexport.mbt` 中补齐实现。鉴于项目已声明"纯 MoonBit 三目标"，`_path` 函数需要 `@fs` 包支持，可能仅 native 可用，建议删除文档条目并明确说明仅支持 bytes I/O。

#### [严重] docs/api_reference.md 缺失 54 个实际存在的函数

- **位置**：`docs/api_reference.md`（全文）
- **描述**：以下 54 个函数在 `src/reexport.mbt` 中实际导出，但 `api_reference.md` 完全未列出：
  - **绘图原语**（4）：`draw_line`、`draw_rectangle`、`draw_circle`、`draw_polygon`
  - **中值滤波**（1）：`median_blur`
  - **感知哈希**（4）：`ahash`、`dhash`、`phash`、`hamming_distance`
  - **DCT**（2）：`dct_2d`、`idct_2d`
  - **色调映射**（2）：`reinhard_tonemap`、`gamma_tonemap`
  - **Shi-Tomasi 角点**（1）：`good_features_to_track`
  - **直方图比较**（2）：`compare_hist`、`histogram_matching`
  - **形态学衍生**（3）：`morph_gradient`、`morph_tophat`、`morph_blackhat`
  - **自定义结构元素**（7）：`se_rect`、`se_cross`、`se_ellipse`、`erode_custom`、`dilate_custom`、`morph_open_custom`、`morph_close_custom`
  - **色彩空间转换**（8）：`rgb_to_ycbcr`、`ycbcr_to_rgb`、`rgb_to_xyz`、`xyz_to_rgb`、`rgb_to_lab`、`lab_to_rgb`、`rgb_to_cmyk`、`cmyk_to_rgb`
  - **伪彩色映射**（1）：`apply_colormap`
  - **透视变换**（4）：`get_perspective_transform`、`warp_perspective`、`get_affine_transform`、`get_rotation_matrix_2d`
  - **轮廓分析**（5）：`convex_hull`、`approx_poly_dp`、`image_moments`、`hu_moments`、`min_enclosing_circle`
  - **霍夫圆**（1）：`hough_circles`
  - **拉普拉斯金字塔融合**（1）：`multi_band_blend`
  - **格式编解码**（8）：`decode_tiff`、`encode_tiff`、`decode_ico`、`decode_cur`、`encode_cur`、`decode_icns`、`decode_apng`、`encode_apng`
  这意味着 v2.1-v3.0 新增的 54 个 API 完全没有文档覆盖，下游开发者无法发现和使用。
- **建议**：按现有分类风格补齐这 54 个函数的签名与说明；同时补充 `PngAnimation`、`HistCompareMethod`、`StructuringElement`、`PerspectiveMatrix`、`AffineMatrix`、`Moments`、`Circle`、`Colormap` 等 8 个缺失类型。

#### [严重] docs/architecture.md 引用不存在的 core/ 包

- **位置**：`docs/architecture.md:84`、`148`、`196`、`200`、`363`、`551`
- **描述**：architecture.md 在 6 处引用 `core/` 包（含 mermaid 图、依赖关系图、序列图、项目结构树），但实际 `src/` 下不存在 `core/` 目录。R1 已发现此问题，但文档未修复。`src/reexport.mbt:93` 注释 `// From core/ (replaced with @pure/@lib — all-target pure MoonBit)` 也残留了对 core/ 的引用。下游开发者按架构文档理解项目会完全迷失。
- **建议**：将 architecture.md 中所有 `core/` 引用替换为 `lib/` + `pure/` 的实际架构；删除 `reexport.mbt:93` 的过时注释。

#### [严重] docs/architecture.md 引用不存在的 scripts/ 和 roundtrip_test.mbt

- **位置**：`docs/architecture.md:77`、`146`、`547`、`599-604`
- **描述**：architecture.md 项目结构树中列出 `scripts/` 目录（含 `prepare.py`、`gen_testdata.py`、`run-asan.py`、`gen_reexport.py`）和 `src/roundtrip_test.mbt`，但两者均不存在。这些是 v1.x C FFI 时代的遗留引用。
- **建议**：从 architecture.md 项目结构树中删除 `scripts/` 和 `roundtrip_test.mbt` 条目。

#### [一般] docs/api_reference.md 头部统计与实际不符

- **位置**：`docs/api_reference.md:3`
- **描述**：头部声明 `219 公开函数 + 28 类型 | 1056 测试 × 3 目标`，实际 252 函数 + 36 类型。函数统计表（`api_reference.md:545-601`）总和为 219，但该表本身遗漏了 v2.1-v3.0 新增的 54 个函数。测试数 1056 正确。
- **建议**：补齐缺失函数后，更新头部统计和函数统计表总计行为 252。

#### [一般] docs/architecture.md 头部统计严重过时

- **位置**：`docs/architecture.md:3`
- **描述**：头部声明 `版本 v2.0.0 | 196 公开函数 + 27 类型 | 645 测试 × 3 目标`，实际为 v3.0 / 252 函数 + 36 类型 / 1056 测试。`architecture.md:534` 项目结构树中 `moon.mod` 注释 `v2.0.0` 也过时。API 分类图（`architecture.md:411-457`）的数字（I/O 41、处理 119、工具 22、编解码 10、元数据 4，合计 196）全部基于 v2.0，与当前 v3.0 严重脱节。
- **建议**：全面更新 architecture.md 的版本号、API 数量、测试数量、分类数字。

#### [一般] README.md 包结构文件数全部不准确

- **位置**：`README.md:194-198`
- **描述**：README.md 包结构注释中 pure 子包文件数全部错误：
  - `codec/` 注释 "20 文件"，实际 43 文件
  - `pixel/` 注释 "2 文件"，实际 4 文件
  - `color/` 注释 "3 文件"，实际 6 文件
  - `process/` 注释 "10 文件"，实际 20 文件
  - `util/` 注释 "4 文件"，实际 7 文件
- **建议**：更新文件数注释，或改为不写具体数字以避免维护负担。

#### [一般] ImageFormat 枚举与文档格式支持表不一致

- **位置**：`src/types/image_types.mbt:53-64`、`README.md:45-61`、`src/README.mbt.md:39-54`
- **描述**：`ImageFormat` 枚举只有 9 种格式 + `Unknown`：`Png/Jpeg/Bmp/Gif/Tga/Psd/Hdr/Pnm/Qoi`。但 README.md 格式支持表列出 14 种格式（含 TIFF/ICO/CUR/ICNS/APNG），且 `reexport.mbt` 确实导出了 `decode_tiff/encode_tiff/decode_ico/decode_cur/encode_cur/decode_icns/decode_apng/encode_apng`。这意味着 `detect_format` 和 `decode_any` 无法识别这 5 种格式，与文档宣称的"格式覆盖广"矛盾。
- **建议**：在 `ImageFormat` 枚举中补充 `Tiff/Ico/Cur/Icns/Apng` 变体，并更新 `detect_format` 实现；或在文档中明确标注这些格式需手动调用 `decode_*` 函数。

#### [一般] docs/changelog.md 与 docs/roadmap.md 测试数不一致

- **位置**：`docs/changelog.md:28`、`docs/roadmap.md:606`
- **描述**：changelog.md 中 v2.0 记为 `645×3` 测试，roadmap.md 中 v2.0 计为 `872×3` 测试。两份文档对同一版本的测试数相差 227。
- **建议**：核对 v2.0 实际测试数并统一。根据 roadmap.md 功能增长曲线（v1.17 为 533+29，v2.0 为 872×3），872 更可信，changelog.md 应更正。

#### [一般] README.md 安装命令大小写与 moon.mod 不一致

- **位置**：`README.md:69`、`moon.mod:1`
- **描述**：README.md 安装命令为 `moon add toadium/image`，但 `moon.mod` 中模块名为 `Toadium/image`（首字母大写）。MoonBit mooncakes 包名大小写敏感，下游开发者直接复制安装命令可能失败。
- **建议**：确认 mooncakes.io 上的实际包名大小写，统一 README.md 和 moon.mod。

#### [一般] README.md 功能列表严重不完整

- **位置**：`README.md:110-171`
- **描述**：README.md "功能一览"分为"基础能力/图像处理（119 函数）/高级分析（90+ 函数）"，但缺失大量 v2.1-v3.0 新增功能：
  - 绘图原语（draw_line/rectangle/circle/polygon）
  - 中值滤波、形态学衍生（gradient/tophat/blackhat）、自定义结构元素
  - 色彩空间转换（YCbCr/XYZ/Lab/CMYK）、伪彩色映射
  - 感知哈希（ahash/dhash/phash）、直方图比较/匹配
  - 透视变换、轮廓分析（凸包/逼近/Hu矩/最小外接圆）
  - 霍夫圆、Shi-Tomasi 角点、DCT、色调映射、拉普拉斯金字塔融合
  - TIFF/ICO/CUR/ICNS/APNG 格式
  "图像处理（119 函数）"和"高级分析（90+ 函数）"的数字也因新增功能而过时。
- **建议**：补齐功能列表，更新函数计数，或在功能列表中添加"完整列表见 api_reference.md"的指引。

#### [一般] src/README.mbt.md API 数量与实际不符

- **位置**：`src/README.mbt.md:8`
- **描述**：徽章显示 `API-197 fn + 28 types`，与 README.md 同样失真。作为 mooncakes.io 上展示的包说明文档（`moon.mod:29` 指向），数据不准确直接影响下游选型。
- **建议**：同步更新为 `API-252 fn + 36 types`。

#### [一般] docs/api_reference.md 类型总览"包"列标注 core 不准确

- **位置**：`docs/api_reference.md:9-20`
- **描述**：类型总览表中 `Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError/ImageFormat/ResizeFilter/ResizeEdge/SuperpixelResult` 等 10 个类型的"包"列标注为 `core`，但实际定义在 `types` 包（见 `src/types/image_types.mbt`）。不存在 `core` 包。
- **建议**：将"包"列更正为 `types`/`meta`/`util`/`process` 等实际定义包。

#### [轻微] AGENTS.md 未提及 reexport.mbt 注册约束

- **位置**：`AGENTS.md`
- **描述**：AGENTS.md "Coding convention" 部分未提及"新增 `pub` 函数须在 `reexport.mbt` 注册"的约束。该约束仅在 README.md:306 的"核心约束"中提及。AGENTS.md 作为 AI 代理指南，缺失此关键约束可能导致新增 API 时遗漏 reexport 注册。
- **建议**：在 AGENTS.md "Coding convention" 部分补充 reexport 注册要求。

#### [轻微] src/README.mbt.md 格式支持表未标注独家格式

- **位置**：`src/README.mbt.md:47,48`
- **描述**：PSD 和 HDR 行的 Notes 分别为 "Photoshop document" 和 "IEEE 754 float"，未像 README.md 那样标注"独家"。作为对外展示文档，未突出差异化优势。
- **建议**：补充"独家"标注以保持与 README.md 一致。

#### [轻微] docs/roadmap.md v3.0 函数数标记为 ~248

- **位置**：`docs/roadmap.md:610`
- **描述**：roadmap.md 版本时间线中 v3.0 标记 `~248` 函数，实际 252，接近但不够精确。同时该行标记"部分完成"，但根据 reexport.mbt 实际导出和 changelog.md 的 v3.0 条目，v3.0 计划的 4 项功能（EXIF 写入/seam carving/SLIC/16-bit float 泛化）均已完成。
- **建议**：更新为精确数 252，状态改为"已完成"。

#### [轻微] reexport.mbt 残留 core/ 引用注释

- **位置**：`src/reexport.mbt:93`
- **描述**：注释 `// From core/ (replaced with @pure/@lib — all-target pure MoonBit)` 仍引用不存在的 core/ 包。虽然注释不影响功能，但误导维护者。
- **建议**：改为 `// From @lib/@pure (all-target pure MoonBit)`。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 6 |
| 一般 | 9 |
| 轻微 | 4 |

### 总评

文档与实际代码的一致性存在**系统性失效**。最严重的问题是 `docs/api_reference.md` 既列出了 19 个不存在的函数（幽灵 API），又缺失了 54 个实际存在的函数（隐形 API），这直接破坏了文档作为下游开发者契约的价值。`docs/architecture.md` 对 `core/` 包的 6 处引用和 `scripts/`、`roundtrip_test.mbt` 的幽灵引用，表明该文档停留在 v1.x C FFI 时代，未随 v2.0 架构重构更新。

README.md 徽章中的版本号（v3.0.0 vs moon.mod 的 2.0.0）和 API 数量（197 vs 实际 252）失真，是下游可用性的首要障碍。`ImageFormat` 枚举与文档格式支持表的 5 格式差距，导致 `decode_any`/`detect_format` 无法覆盖文档宣称的 14 种格式，违反"最小惊讶"原则。

**下游可用性综合评估**：当前文档状态下，新用户**无法**通过文档准确理解项目能力边界。README.md 快速上手示例本身可运行（使用的 6 个 API 均存在），但用户若按 api_reference.md 查找 `_path` 函数或 `resize_srgb/resize_16/resizef` 会直接碰壁。54 个隐形 API 中包含绘图、色彩空间、透视变换等常用功能，文档缺失使其对下游完全不可见。

**根因分析**：项目在 v2.0→v2.1→v2.2→v2.3→v3.0 快速迭代中，源码与文档未同步维护。`api_reference.md` 和 `architecture.md` 停留在 v2.0 初期，README.md 停留在 v1.x 末。建议建立文档同步检查机制：每次新增 `pub` 函数时，同步更新 `api_reference.md` 和 `README.md` 功能列表；每次版本发布时，核对 `moon.mod` 版本与文档徽章一致。
