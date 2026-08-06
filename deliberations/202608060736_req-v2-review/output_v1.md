# req_v2.md 独立审查报告

## 审查信息

- **审查对象**：`D:\CodeWorkspace\forMoonbit\stb-image\requirements\202608060700_stb-image-requirement\req_v2.md`（306 行）
- **审查框架**：deliberative-execution-harness
- **审查日期**：2026-08-06
- **审查轮次**：第 1 轮（独立全面审查）

## 审查结论

**[APPROVED]** — 文档整体质量高，6 个审查维度均通过。发现 3 项轻微问题与 2 项建议优化，均不影响文档的可支撑下游设计能力，可在技术设计阶段顺带处理。

## 核实工作说明

本审查过程中进行了以下独立核实工作：

| 核实项 | 核实方式 | 结果 |
|--------|---------|------|
| MoonBit 工具链版本 | `moon version` | `0.1.20260713`，feature flags 启用 `rr_moon_mod,rr_moon_pkg`，新格式可用 |
| MoonBit v0.10.5 文档版本 | webfetch `https://docs.moonbitlang.cn/` | 确认 v0.10.5 文档标题 |
| moon.mod/moon.pkg 新格式 | webfetch 模块配置与包配置官方文档 | 旧格式 v0.10.4 弃用，新格式为 DSL，req_v2.md 描述准确 |
| `preferred_target` 下划线语法 | webfetch 模块配置文档 | 新格式 `preferred_target`（下划线），旧格式 `"preferred-target"`（连字符），req_v2.md 准确 |
| `supported_targets` 语法 | webfetch 模块/包配置文档 | 单后端字符串语法 `"native"` 合法，req_v2.md 准确 |
| `targets` 条件编译中 `"native"` 可用性 | 查阅 image-mbt `src/moon.pkg` 第 11 行 + make-moonbit-c-bindings skill 模板 `moon.pkg` 第 8 行 | 两处实际项目均使用 `["native"]`，证实可用（尽管官方文档后端条件列表未明确列出 native） |
| `extern "c"` 语法（小写 vs 大写） | 查阅 make-moonbit-c-bindings skill 模板 `ffi.mbt` | skill 模板使用小写 `extern "c"`，与 req_v2.md 一致；官方 FFI 文档示例用大写 `extern "C"`，两者 MoonBit 均接受 |
| stb_image.h v2.30 完整 API | webfetch `https://raw.githubusercontent.com/nothings/stb/master/stb_image.h` | API 列表与 req_v2.md 第 150-173 行梳理一致 |
| stb_image 支持格式 | 同上，查看头文件注释与 API 声明 | PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC/PNM 共 10 种，req_v2.md 准确 |
| mizchi/image 引用残留 | grep `mizchi|image-mbt` on req_v2.md | 仅出现在第 302、306 行"修订说明"中作为元说明，需求正文无引用 |
| `moonbit_make_bytes` 存在性 | req_v2.md 引用 `moonbit.h:343`，FFI 文档确认 `moonbit.h` 包含 C FFI 辅助函数 | v1 已核实，本次确认 FFI 文档描述一致 |

## 逐维度审查

### 维度 1：完整性

**[通过]**

文档覆盖了"完整库"定位所需的全部方面：

| 方面 | 位置 | 覆盖情况 |
|------|------|---------|
| 目标用户 | 第 7-8 行 | ✓ 前端/游戏/工具开发者 + 个人开发者 |
| 核心问题 | 第 10-16 行 | ✓ MoonBit 生态缺少 stb_image 绑定，含已核实的现状（mooncakes 空白、工作区无通用 codec） |
| 项目定位 | 第 18-19 行 | ✓ "最终目标是提供一个完整的图像处理库"，MVP 为演进路径第一步 |
| 能力范围 | 第 113-128 行（完整库目标）+ 第 150-173 行（能力矩阵） | ✓ 11 项完整库目标 + stb_image.h v2.30 + stb_image_write.h v1.16 完整 API 梳理 |
| MVP 范围 | 第 21-68 行 | ✓ 加载入口、支持格式、Image 类型、错误处理、vendoring |
| API 设计 | 第 39-48 行（Image）+ 第 51-58 行（LoadError）+ 第 175-232 行（各版本 API 增量） | ✓ MVP API + 各版本 API 增量到函数名 |
| FFI 方案 | 第 70-95 行 | ✓ 包布局、moon.mod/moon.pkg 配置、C wrapper、所有权、moonbit_make_bytes |
| 版本迭代计划 | 第 146-258 行 | ✓ v0.1→v0.2→v0.3→v0.4→v1.0，含目标/范围/API 增量/验收标准 |
| 验收标准 | 第 97-107 行 + 各版本"验收标准概要" | ✓ MVP 验收标准 + 各版本概要 |
| 边界约束 | 第 109-144 行 | ✓ 完整库目标 11 项 + MVP 阶段性限制 11 项，一一对应 |
| 下游设计输入 | 第 277-291 行 | ✓ 11 个决策点 |

无遗漏。

### 维度 2：准确性

**[通过]**

逐项核实结果：

| 事实陈述 | 文档位置 | 核实结果 |
|---------|---------|---------|
| MoonBit 标准库无 `InputStream` 类型 | 第 26 行 | ✓ 准确（`core` 中无此类型；`moonbitlang/async/io` 有异步 `Reader` trait） |
| stb_image.h v2.30 默认含 PNM（PPM/PGM） | 第 37、141、166 行 | ✓ 准确（头文件注释与 `STBI_NO_PNM` 宏确认） |
| stb_image 支持格式：PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC/PNM | 第 34-36、166 行 | ✓ 准确（头文件 QUICK NOTES 确认） |
| stb_image_write.h v1.16 提供 PNG/BMP/TGA/JPEG/HDR 写入 | 第 11、117、168-173 行 | ✓ 准确 |
| stb_image 不返回错误码，仅返回 NULL 表示失败 | 第 58 行 | ✓ 准确（头文件文档确认 "return value will be NULL"） |
| `stbi_io_callbacks` 含 read/skip/eof | 第 123、164、228 行 | ✓ 准确（头文件 `stbi_io_callbacks` 结构体确认） |
| `stbi_load_gif_from_memory` 返回多帧 + delays | 第 124、160、229 行 | ✓ 准确（头文件 `stbi_load_gif_from_memory` 签名含 `int **delays`） |
| 16-bit 接口 `stbi_load_16*` 系列 | 第 119、156、210 行 | ✓ 准确（头文件含 `stbi_load_16_from_memory` 等） |
| float 接口 `stbi_loadf*` 系列 | 第 120、157、211 行 | ✓ 准确（头文件含 `stbi_loadf_from_memory` 等） |
| info 接口 `stbi_info*` 系列 | 第 121、158、212 行 | ✓ 准确（头文件含 `stbi_info_from_memory` 等） |
| `stbi_is_16_bit*` / `stbi_is_hdr*` 查询 | 第 121、159、213 行 | ✓ 准确（头文件含 `stbi_is_16_bit_from_memory` 等） |
| flip/iPhone PNG/unpremultiply 配置（含 thread-local 版本） | 第 122、127、161、215 行 | ✓ 准确（头文件含 `_thread` 后缀版本） |
| HDR 配置 `stbi_hdr_to_ldr_gamma/scale` / `stbi_ldr_to_hdr_gamma/scale` | 第 126、162、214 行 | ✓ 准确（头文件确认） |
| `stbi_failure_reason` | 第 58、142、163、217 行 | ✓ 准确（头文件确认） |
| mooncakes stb 绑定空白 | 第 15 行 | ✓ v1 已核实，本次未重新核实（接受 v1 结论） |
| `moonbit_make_bytes` 存在于 `moonbit.h:343` | 第 95 行 | ✓ v1 已核实，FFI 文档确认 `moonbit.h` 包含辅助函数 |
| MoonBit v0.10.5 规范：moon.mod/moon.pkg 新格式 | 第 74、86、87 行 | ✓ 准确（官方文档确认旧格式 v0.10.4 弃用） |
| `preferred_target` 下划线语法 | 第 86、144 行 | ✓ 准确（官方文档确认新格式下划线） |
| `extern "c"` FFI 语法 | 第 70、85 行 | ✓ 准确（skill 模板使用同样小写；官方文档示例用大写 `extern "C"`，两者均接受） |
| `targets` 条件编译中 `"native"` 可用 | 第 87、88、144 行 | ✓ 准确（image-mbt 实际项目 + skill 模板均使用） |

无准确性错误。

### 维度 3：自包含性

**[通过]**

- **grep 核实**：`mizchi` / `image-mbt` 仅出现在第 302、306 行"修订说明（v2）"表格中，作为元说明记录"已移除 mizchi/image 引用"的修订动作，非需求内容中将其作为依赖、互补基准或对比对象的引用。
- **需求正文检查**（第一至八节 + 能力梳理 + 版本迭代计划）：无任何已有库（mizchi/image、image-mbt 等）作为依赖/互补/对比的引用。
- **第 11 行**"MoonBit 生态较少覆盖的格式"为泛指生态现状的定性陈述，未点名任何具体库，属于对 stb_image 价值定位的独立陈述，不违反约束。
- **第 16 行**"moonbit_wp 内仅有 mbtpdf/graphics/pdfimage、office.mbt/pdflite/image"为源码仓库核实事实的陈述，非引用已有库作为依赖/互补基准。

文档自包含，不引用任何已有库作为依赖、互补基准或对比对象。

### 维度 4：版本迭代计划合理性

**[通过]**

**演进路径评估**：

| 版本 | 目标 | 范围合理性 | API 增量与 stb_image 对应 |
|------|------|-----------|-------------------------|
| v0.1 MVP | 验证 FFI 可行性，落地 load 路径 | ✓ 最小 API 面验证可行性 | `load_from_path`/`load_from_bytes`/`Image`/`LoadError` 对应 `stbi_load`/`stbi_load_from_memory` |
| v0.2 | 补齐 write 路径 + req_channels，基本读写闭环 | ✓ write 是"完整库"核心增量 | `write_*_to_path`/`write_*_to_bytes`/`req_channels`/flip 对应 `stbi_write_*` + `desired_channels` |
| v0.3 | 覆盖全部数据类型与查询能力 | ✓ 16-bit/float/info/查询/HDR/PNM/failure_reason | `load_16_*`/`loadf_*`/`info_*`/`is_16_bit_*`/`is_hdr_*` 对应 `stbi_load_16*`/`stbi_loadf*`/`stbi_info*` 等 |
| v0.4 | 暴露流式能力 | ✓ I/O callbacks + 动画 GIF | `IoCallbacks` trait/`load_*_from_callbacks`/`load_gif_from_bytes` 对应 `stbi_io_callbacks`/`stbi_load_gif_from_memory` |
| v1.0 | 多目标支持 + 完整库 | ✓ 评估项而非承诺，表述恰当 | 多目标构建 + API 冻结 + 性能优化 |

**递进逻辑**：
- v0.1→v0.2：从只读到读写闭环，自然递进
- v0.2→v0.3：从基本读写到全部数据类型与查询，覆盖 stb_image load 端完整能力
- v0.3→v0.4：从完整解码到流式与动画，覆盖 stb_image 的 I/O 抽象层
- v0.4→v1.0：从 native 单目标到多目标，达成完整库定位

**API 增量覆盖 stb_image 完整能力**：
- load 端：8-bit/16-bit/float/info/is_16_bit/is_hdr/动画 GIF/配置/HDR 配置/failure_reason/image_free/I/O callbacks/desired_channels/支持格式 — 全部在 v0.1-v0.4 中覆盖
- write 端：PNG/BMP/TGA/JPEG/HDR to file/to func/to mem/flip/配置 — 在 v0.2 中覆盖

**多目标演进表述**（第 249-258 行）：明确标注"v1.0 的核心评估项，而非承诺交付"，评估 wasm/js/wasm-gc 三条路径 + 替代路径，不预设答案，交由技术设计决定。表述合理。

版本迭代计划合理，各版本目标与范围清晰，API 增量覆盖 stb_image 完整能力。

### 维度 5：可支撑下游设计

**[通过]**

**第八节"下游设计输入"列出 11 个决策点**：

| # | 决策点 | 明确程度 | 是否预设答案 |
|---|--------|---------|-------------|
| 1 | `LoadError` 的具体构造子与层级 | ✓ 是否复用 `IOError` 还是全部并入 `LoadError` | 否 |
| 2 | C wrapper 的错误信号机制 | ✓ 返回 NULL、输出参数、还是其他方式 | 否 |
| 3 | `Image` struct 的导出级别 | ✓ `pub(all)` 还是 `pub`，是否 derive | 否 |
| 4 | 测试图片的取得方式 | ✓ 脚本生成、公开库下载、还是手工制作 | 否 |
| 5 | vendoring 的 stb_image.h 具体版本 | ✓ 选择哪个 commit hash | 否（给出建议） |
| 6 | `SKILL.md` 的具体内容结构 | ✓ 是否参照 `.codeartsdoer/skills` 格式 | 否 |
| 7 | 版本迭代的包结构策略 | ✓ write API 放同一包还是拆子包 | 否 |
| 8 | 16-bit / float 数据的 `Bytes` 编码 | ✓ little-endian 还是 native endian | 否 |
| 9 | `IoCallbacks` trait 的设计 | ✓ read/skip/eof 签名如何映射 MoonBit 语义 | 否 |
| 10 | 多目标支持的路径选择 | ✓ Emscripten + wasm、js + wasm、还是纯 MoonBit | 否 |
| 11 | 零拷贝可行性评估 | ✓ 是否在 v1.0 或之后提供零拷贝路径 | 否 |

所有决策点均明确，不预设答案（部分给出建议），下游架构设计与技术设计可据此推进。

**其他可支撑性检查**：
- FFI 方案要点（第 70-95 行）提供了包布局、moon.mod/moon.pkg 配置、C wrapper 职责、所有权管理的具体指导
- vendoring 要求（第 60-68 行）提供了脚本名、版本标识方式、校验方式、失败行为、幂等性要求
- 验收标准（第 97-107 行）提供了具体的命令、测试数量、测试格式、ASan 验证、moon info、SKILL.md 要求

文档足够支撑下游架构设计与技术设计，决策点明确。

### 维度 6：MoonBit v0.10.5 规范一致性

**[通过]**

| 规范项 | 文档位置 | 规范要求 | req_v2.md 描述 | 一致性 |
|--------|---------|---------|---------------|--------|
| moon.mod 新格式 | 第 74、86 行 | 新格式 `moon.mod`（DSL），旧 `moon.mod.json` v0.10.4 弃用 | "使用新格式 `moon.mod`/`moon.pkg`，旧 `moon.mod.json`/`moon.pkg.json` 已在 v0.10.4 弃用" | ✓ 一致 |
| moon.pkg 新格式 | 第 74、87 行 | 新格式 `moon.pkg`（DSL），旧 `moon.pkg.json` v0.10.4 弃用 | 同上 | ✓ 一致 |
| `preferred_target` 下划线 | 第 86、144 行 | 新格式 `preferred_target`（下划线），旧 `"preferred-target"`（连字符） | "`preferred_target = "native"`（下划线，非旧 JSON 的 `"preferred-target"`）" | ✓ 一致 |
| `supported_targets` 语法 | 第 144 行 | 单后端字符串语法 `"native"` 合法 | "可设 `supported_targets = "native"` 声明仅 native" | ✓ 一致 |
| `native-stub` 配置 | 第 87 行 | `options("native-stub": ["wrapper.c"])` | "`options("native-stub": ["wrapper.c"], ...)`" | ✓ 一致 |
| `targets` 条件编译 | 第 87、88、144 行 | `options(targets: { "ffi.mbt": ["native"] })`，`"native"` 可用 | "`options(..., targets: { "ffi.mbt": ["native"] })`" | ✓ 一致（已通过 image-mbt 实际项目 + skill 模板证实） |
| `extern "c"` FFI 语法 | 第 70、85 行 | 官方文档示例 `extern "C"`（大写），skill 模板 `extern "c"`（小写），两者均接受 | "`extern "c"` 声明" | ✓ 一致（与 skill 模板一致） |
| `#borrow` 所有权标记 | 第 94 行 | FFI 文档确认 `#borrow` 语法 | "输入 `Bytes` 用 `#borrow`" | ✓ 一致 |

MoonBit v0.10.5 规范一致性全部通过。

## 发现的问题与建议

### 问题 1（轻微）：`extern "c"` 大小写

- **位置**：第 70、85 行
- **问题**：req_v2.md 使用 `extern "c"`（小写），与 make-moonbit-c-bindings skill 模板一致；但 MoonBit 官方 FFI 文档示例使用 `extern "C"`（大写）。
- **影响**：无功能影响（MoonBit 两者均接受），但与官方文档规范形式不一致。
- **建议**：技术设计阶段可统一采用官方文档的大写形式 `extern "C"`，或保持与 skill 模板一致的小写形式并注明。非阻塞性问题。

### 问题 2（轻微）：`supported_targets` 声明级别表述

- **位置**：第 144 行
- **问题**：原文"可设 `supported_targets = "native"` 声明包级支持范围"中"包级"一词可能产生歧义。根据 MoonBit 文档，`supported_targets` 可在 `moon.mod`（模块级）和 `moon.pkg`（包级）两个级别设置；当两者都声明时，实际生效的后端集合是它们的交集。req_v2.md 此处上下文是在讨论 `moon.mod` 配置，因此"包级"可能意指"模块级"。
- **影响**：轻微表述不精确，不影响理解（上下文明确是在讨论 `moon.mod`）。
- **建议**：将"声明包级支持范围"改为"声明模块级支持范围"，或在技术设计阶段明确 `supported_targets` 是在模块级还是包级设置。非阻塞性问题。

### 问题 3（轻微）：moon.pkg 配置示例未展示 api.mbt / README.mbt.md 门控

- **位置**：第 87 行
- **问题**：moon.pkg 配置示例 `options("native-stub": ["wrapper.c"], targets: { "ffi.mbt": ["native"] })` 仅展示 `ffi.mbt` 的 native 门控，但包布局（第 75-85 行）中列出的 `src/image.mbt`（安全公开 MoonBit API）和 `src/README.mbt.md`（测试过的文档示例）在 make-moonbit-c-bindings skill 模板中也被门控到 native（`"api.mbt": ["native"]`、`"README.mbt.md": ["native"]`）。
- **影响**：配置示例不完整，但 req_v2.md 第 74 行已说明"建议，由技术设计最终确定"，且这是技术设计细节。
- **建议**：技术设计阶段参考 skill 模板补全 `targets` 门控列表。非阻塞性问题。

### 建议 1（优化）：vendoring 脚本可考虑 `stb_image_write.h` 预留方式

- **位置**：第 68 行
- **现状**：req_v2.md 说"完整库版本会追加 vendoring `stb_image_write.h`，脚本应预留扩展能力"。
- **建议**：可在技术设计阶段考虑脚本是否支持一次性 vendoring 多个头文件（如 `--include-write` 参数），避免 v0.2 时修改脚本结构。非阻塞性建议。

### 建议 2（优化）：v0.2 write 入口可考虑 `write_png_to_bytes` 的内存管理

- **位置**：第 196 行
- **现状**：v0.2 范围列出 `write_*_to_bytes` 版本（基于 `stbi_write_*_to_func`）。
- **建议**：`stbi_write_*_to_func` 使用回调写入，MoonBit 侧需设计回调机制将 C 侧的写入回调转换为 `Bytes` 累积。这一设计可在第八节决策点中补充（当前决策点 9 `IoCallbacks` trait 设计覆盖了 load 端回调，但 write 端回调设计未明确列为决策点）。非阻塞性建议，可在技术设计阶段补充。

## 总结

req_v2.md 是一份高质量的需求文档，完整覆盖了"完整库"定位所需的全部方面，事实陈述经过独立核实均准确，自包含性良好（不引用任何已有库作为依赖/互补/对比），版本迭代计划合理且覆盖 stb_image 完整能力，可支撑下游架构设计与技术设计，MoonBit v0.10.5 规范一致性全部通过。

发现的 3 项轻微问题与 2 项建议优化均不影响文档的整体质量和可支撑下游设计能力，可在技术设计阶段顺带处理。建议 **APPROVED**。