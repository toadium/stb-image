# R4: lib/format + lib/meta

审查时间：2026-08-11

### 审查范围

- `src/lib/lib.mbt`、`src/lib/lib_test.mbt`、`src/lib/moon.pkg`、`src/lib/pkg.generated.mbti`
- `src/format/qoi.mbt`、`src/format/gif_encode.mbt`、`src/format/pnm_encode.mbt`、`src/format/moon.pkg`、`src/format/pkg.generated.mbti`
- `src/meta/exif.mbt`、`src/meta/exif_write.mbt`、`src/meta/png_meta.mbt`、`src/meta/moon.pkg`、`src/meta/pkg.generated.mbti`
- 关联文件：`src/types/image_types.mbt`、`src/pure/codec/apng_codec.mbt`、`src/reexport.mbt`（用于确认委托路径与类型归属）

### 发现

#### [严重] `src/format/` 与 `src/pure/codec/` 存在大规模重复实现

- **位置**：`src/format/qoi.mbt:13`（`decode_qoi`）、`src/format/qoi.mbt:121`（`encode_qoi`）、`src/format/gif_encode.mbt:119`（`encode_gif`）、`src/format/gif_encode.mbt:184`（`encode_gif_animation`）、`src/format/pnm_encode.mbt:6/37/70`（`encode_ppm`/`encode_pgm`/`encode_pnm`）
- **描述**：`src/format/` 包含 QOI 解码/编码、GIF 编码/动画编码、PNM 编码的完整独立实现，而 `src/pure/codec/` 中存在同名 `_pure` 后缀的对应实现。`pure/codec` 各文件头部注释明确标注"移植自 src/format/xxx.mbt"（见 `src/pure/codec/qoi_encode.mbt:3`、`src/pure/codec/qoi_decode.mbt:3`、`src/pure/codec/pnm_encode.mbt:2`），证明二者是同一算法的两份拷贝。更严重的是，两条 reexport 路径指向不同实现：`src/reexport.mbt:1051-1069` 中 `encode_qoi`/`encode_gif`/`encode_pnm` 等委托给 `@format`，而 `src/lib/lib.mbt:126-181` 中 `encode_qoi_auto`/`encode_gif_auto`/`encode_pnm_auto` 等委托给 `@codec`。下游用户通过 `@image.encode_qoi` 与 `@lib.encode_qoi_auto` 访问的是两份独立代码，维护负担加倍且存在行为漂移风险。
- **建议**：删除 `src/format/` 包，将 `src/reexport.mbt:1051-1069` 中 7 个 `@format.xxx` 委托改为 `@codec.xxx_pure`，与 `src/lib` 的委托路径统一。`encode_gif_animation` 需确认 `pure/codec` 中是否有对应实现，若无则将 `format/gif_encode.mbt` 的动画编码逻辑迁入 `pure/codec`。

#### [严重] `PngAnimation` 与 `GifAnimation` 类型归属不一致

- **位置**：`src/types/image_types.mbt:38`（`GifAnimation`）、`src/pure/codec/apng_codec.mbt:8`（`PngAnimation`）
- **描述**：两个语义对称的动画类型分属不同包：`GifAnimation` 定义在公共 `types` 包，而 `PngAnimation` 定义在 `pure/codec` 包内部。这导致 `src/reexport.mbt:10` 通过 `@types.GifAnimation` reexport，而 `src/reexport.mbt:13` 通过 `@codec.PngAnimation` reexport。下游用户引用动画类型时需要分别从两个不同包导入，违反"最小惊讶"与"正交性"原则。`src/reexport.mbt:1099` 中 `decode_apng` 返回 `@codec.PngAnimation` 也暴露了这一不一致。
- **建议**：将 `PngAnimation` 定义迁移至 `src/types/image_types.mbt`，与 `GifAnimation` 并列。`pure/codec/apng_codec.mbt` 改为引用 `@types.PngAnimation`，与 `gif_animation_decode.mbt` 引用 `@types.GifAnimation` 的方式一致。

#### [一般] `encode_xxx_auto` 命名中 `auto` 后缀语义不一致

- **位置**：`src/lib/lib.mbt:126`（`encode_qoi_auto`）、`src/lib/lib.mbt:150`（`encode_gif_auto`）、`src/lib/lib.mbt:156`（`encode_png_auto`）、`src/lib/lib.mbt:162`（`encode_jpeg_auto`）、`src/lib/lib.mbt:168`（`encode_hdr_auto`）、`src/lib/lib.mbt:174`（`encode_bmp_auto`）、`src/lib/lib.mbt:180`（`encode_tga_auto`）
- **描述**：`load_from_bytes_auto`（`lib.mbt:78`）的 `auto` 表示"自动格式分派"，`encode_pnm_auto`（`lib.mbt:132`）的 `auto` 表示"自动选择 PGM/PPM"，二者都有分派语义。但 `encode_qoi_auto`、`encode_gif_auto`、`encode_png_auto` 等 7 个函数只是对 `@codec.encode_xxx_pure` 的简单单格式委托，无任何分派逻辑，`auto` 后缀冗余且误导下游用户以为存在格式自动选择行为。
- **建议**：对无分派语义的 7 个函数去掉 `auto` 后缀，直接命名为 `encode_qoi`/`encode_gif`/`encode_png`/`encode_jpeg`/`encode_hdr`/`encode_bmp`/`encode_tga`，与 `pure/codec` 的 `encode_xxx_pure` 形成清晰对应。保留 `load_from_bytes_auto`、`load_16_from_bytes_auto`、`encode_pnm_auto` 的 `auto` 后缀。

#### [一般] `load_16_from_bytes_auto` 中 `req_channels` 参数传递不一致

- **位置**：`src/lib/lib.mbt:115-116`
- **描述**：PNG 分支调用 `@codec.decode_png_16_pure(data, req_channels~)` 传递了 `req_channels`，而 PNM 分支调用 `@codec.decode_pnm_16_pure(data)` 未传递。函数签名声明了 `req_channels? : Int? = None` 参数，但 PNM 分支忽略该参数，导致下游传入 `req_channels` 时对 PNM 格式静默无效，违反"最小惊讶"原则。
- **建议**：确认 `decode_pnm_16_pure` 是否支持 `req_channels` 参数。若支持，则传递 `req_channels~`；若不支持，则在函数文档中明确标注"req_channels 仅对 PNG 生效"，或在 PNM 分支中当 `req_channels` 非空时 raise 警告。

#### [一般] `src/lib/` 包名语义模糊

- **位置**：`src/lib/moon.pkg:1`
- **描述**：包名 `lib` 未表达其"统一入口/格式分派层"的职责。项目已有 `pure/codec`（编解码）、`format`（格式实现）、`reexport`（顶层 reexport），`lib` 的命名无法让下游用户理解其与 `format`/`codec` 的层次关系。从 `src/lib/pkg.generated.mbti` 可见其公开面为 `detect_format` + `load_from_bytes_auto` + 11 个 `encode_xxx_auto`，本质是分派门面（facade）。
- **建议**：将 `src/lib/` 重命名为语义更准确的包名，如 `api`（统一 API 入口）或 `dispatch`（分派层）。若重命名成本过高，至少在包级文档注释中明确其"统一分派入口"职责。

#### [一般] `src/format/` 包名与职责不清，与 `pure/codec` 职责重叠

- **位置**：`src/format/moon.pkg:1`
- **描述**：`format` 包含 QOI/GIF/PNM 的编解码实现，与 `pure/codec` 职责完全重叠。`format` 的 `moon.pkg` 不依赖 `pure/codec`（生产代码无 import），是独立实现而非委托。从 `pure/codec` 各文件注释"移植自 src/format"可见，`format` 是历史遗留的旧实现，`pure/codec` 是新纯 MoonBit 实现，但 `format` 未被删除。`format` 测试（如 `gif_animation_test.mbt:3`）反而依赖 `@lib` 和 `@codec`，进一步证明 `format` 已无独立存在价值。
- **建议**：与第一个严重问题联动处理，删除 `src/format/` 包，将其唯一独有功能 `encode_gif_animation` 迁入 `pure/codec`。

#### [一般] `exif.mbt` 文件命名与 `exif_write.mbt` 不对称

- **位置**：`src/meta/exif.mbt:1`、`src/meta/exif_write.mbt:1`
- **描述**：`exif.mbt` 包含 EXIF 读取逻辑（`read_exif_from_bytes` 及辅助函数），`exif_write.mbt` 包含写入逻辑（`write_exif_to_bytes`、`create_exif_segment`）。文件命名不对称：读取侧无 `_read` 后缀，写入侧有 `_write` 后缀。下游或维护者浏览文件时无法从命名对称性快速识别职责。
- **建议**：将 `exif.mbt` 重命名为 `exif_read.mbt`，与 `exif_write.mbt` 形成对称命名；或合并为单一 `exif.mbt` 文件（读写逻辑量不大，合计约 380 行，可接受）。

#### [一般] 错误信息语言不一致

- **位置**：`src/lib/lib.mbt:119`（`"16-bit 解码不支持此格式，仅支持 PNG 和 PNM"`）、`src/lib/lib.mbt:92`（`"HDR format requires decode_hdr_pure for float image"`）、`src/lib/lib.mbt:96`（`"unsupported or unrecognized format"`）
- **描述**：`load_16_from_bytes_auto` 的错误信息为中文，而 `load_from_bytes_auto` 的错误信息为英文。同一文件内错误信息语言混用，违反一致性原则。`src/format/gif_encode.mbt:122` 的 `"GIF 编码需要 channels 为 3 (RGB) 或 4 (RGBA)"` 也是中文，`src/pure/codec/gif_encode.mbt:124` 同样，说明中文错误信息在 codec 层已广泛使用，但 `lib` 层未统一。
- **建议**：统一错误信息语言。考虑到项目注释和文档以中文为主，建议统一为中文；或统一为英文以匹配国际化需求。无论哪种，需全项目一致。

#### [轻微] `src/lib/` 中 `ImageFormat` 类型别名冗余

- **位置**：`src/lib/lib.mbt:2`（`pub type ImageFormat = @types.ImageFormat`）、`src/lib/pkg.generated.mbti:40`
- **描述**：`lib` 包 reexport 了 `ImageFormat` 类型别名，但 `detect_format` 返回类型已声明为 `@types.ImageFormat`。下游用户需通过 `@lib.ImageFormat::Png` 还是 `@types.ImageFormat::Png` 访问枚举值存在歧义，且增加了 `lib` 包的公开面。从 `lib_test.mbt:264` 可见测试中直接使用 `ImageFormat::Bmp`（依赖 reexport），说明别名被使用，但 `@types.ImageFormat` 同样可直接访问。
- **建议**：评估是否可移除该别名，让下游统一通过 `@types.ImageFormat` 访问。若移除成本过高（需修改下游引用），可保留但在文档中明确"优先使用 `@types.ImageFormat`"。

#### [轻微] `png_meta.mbt` 命名风格与 exif 系列不一致

- **位置**：`src/meta/png_meta.mbt:1`
- **描述**：`png_meta.mbt` 用下划线分隔格式名（`png`）和功能（`meta`），而 `exif.mbt`/`exif_write.mbt` 直接用功能名（exif 本身就是格式+功能）。虽然 exif 是专有名词无需分隔，但 `png_meta` 的命名风格若推广，`exif_read` 应命名为 `exif_read`（一致），但 `png_meta` 内部同时包含读取功能（`read_png_text_chunks`），无对应写入文件，命名未体现读写分离。
- **建议**：若 exif 拆分为 `exif_read`/`exif_write`，则 `png_meta` 可保持不变（仅读取）；若 exif 合并为 `exif`，则 `png_meta` 可考虑重命名为 `png`（与 `exif` 风格一致）。关键是全包内命名风格统一。

#### [轻微] `load_from_bytes_auto` 中 HDR 与 TGA 处理路径不对称

- **位置**：`src/lib/lib.mbt:90-96`（HDR 分支 raise）、`src/lib/lib.mbt:94`（TGA 分支）、`src/lib/lib.mbt:9`（detect_format 注释说明 TGA 返回 Unknown）
- **描述**：HDR 在 `detect_format` 中能被识别（返回 `Hdr`），但在 `load_from_bytes_auto` 中 raise "需显式调用 decode_hdr_pure"；TGA 因无固定 magic 在 `detect_format` 中返回 `Unknown`，在 `load_from_bytes_auto` 中走 `Unknown` 分支 raise "unsupported or unrecognized format"。两者都是"检测到但无法自动分派"，但 HDR 有明确错误提示，TGA 的错误提示（"unsupported or unrecognized format"）未说明 TGA 需显式调用 `decode_tga_pure`，对下游用户不友好。
- **建议**：在 `Unknown` 分支的错误信息中补充 TGA 提示，如 `"unsupported or unrecognized format (TGA has no magic bytes, use decode_tga_pure explicitly)"`；或在文档中集中说明各格式的自动分派支持情况。

### 本轮统计

| 严重程度 | 数量 |
|---------|------|
| 严重 | 2 |
| 一般 | 6 |
| 轻微 | 3 |

### 总评

本轮审查发现 `lib/format/meta` 三个子包存在两个严重架构问题：

1. **`format` 与 `pure/codec` 的大规模重复实现**是最突出的问题。`pure/codec` 各文件注释明确标注"移植自 format"，证明 `format` 是历史遗留包，但未删除，导致同一算法存在两份独立代码，且通过不同 reexport 路径（`reexport→format` vs `lib→codec`）暴露给下游。这违反"最小化公开面"和"DRY"原则，应优先处理。

2. **`PngAnimation` 与 `GifAnimation` 类型归属不一致**违反"正交性"原则，两个对称的动画类型分属不同包，增加下游认知负担。

`lib` 层的 `encode_xxx_auto` 命名问题（`auto` 后缀语义滥用）和包名 `lib` 语义模糊属于设计层面的一般问题，影响下游可用性。`meta` 层整体质量较好，EXIF/PNG 元数据实现完整，主要问题是文件命名不对称（`exif.mbt` vs `exif_write.mbt`）和错误信息语言不一致。

`lib` 与 `pure/codec` 的委托路径本身是清晰的（`lib→codec`+`color`），问题在于 `format` 包的存在打破了这一清晰层次。删除 `format`、统一类型归属后，`lib/format/meta` 的架构将显著紧凑。
