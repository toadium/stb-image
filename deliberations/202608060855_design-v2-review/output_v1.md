# `design_v2.md` 独立全面审查报告

> 审查对象：`D:\CodeWorkspace\forMoonbit\stb-image\designs-oo\202608060801_stb-image-arch-design\design_v2.md`
> 审查框架：deliberative-execution-harness
> 审查日期：2026-08-06
> 审查依据：req.md、stb_image.h v2.30 上游（已 webfetch 核实）、MoonBit v0.10.5 规范（已核实源码先例）、image-mbt 仓库（仅作类型形态先例核实）

## 审查总体结论

**[APPROVED]** — 设计在 7 个审查维度上整体表现良好，职责划分清晰、抽象层次恰当、FFI 边界设计合理、与 MoonBit v0.10.5 规范一致、版本演进有架构落点、自包含、可支撑下游。发现 **1 个轻微技术性错误**（4.3 节 `stbi_load_16` 与宽字符路径的混淆）与 **2 个可改进细节**（失败信号来源澄清、`supported_targets` 语法提示），均不影响架构整体成立，建议在技术设计阶段前修订。

---

## 一、需求响应充分度

**[通过]** 设计充分响应了 req.md 中的全部要求。

**证据**：

1. **完整库定位**：design_v2.md:11 明确"后续按版本迭代计划逐步演进到完整库"，与 req.md:17"最终目标是提供一个完整的图像处理库"一致。第一节"设计目标"将项目定位为"安全、惯用、可演进的图像 load/write 能力"，覆盖了 req.md 的完整库目标。

2. **MVP 范围响应**：
   - 加载入口：design_v2.md:31 "MVP 不引入'加载源'抽象（path 与 bytes 两个入口直接对应 stb_image 的两个 C API）"，对应 req.md:26-28 的 `load_from_path` + `load_from_bytes`。
   - 支持格式：design_v2.md 通过 4.2.2 节"9 种支持格式"与 req.md:33 的 9 种格式一致（PNG/JPEG/BMP/GIF/WebP/TGA/PSD/HDR/PIC，不含 PNM）。
   - `Image` 值类型：design_v2.md:78-98 的 `Image { width, height, channels, data : Bytes }` 与 req.md:40-44 完全一致，保留原始通道、不暴露 `req_channels`。
   - 错误处理：design_v2.md:100-123 的 `LoadError` suberror + raise 与 req.md:49-56 一致。
   - vendoring：design_v2.md:167-185 的 `scripts/prepare.py` 与 req.md:58-66 一致（commit hash 固定、SHA256 校验、幂等、`--include-write` 预留）。

3. **版本迭代计划响应**：design_v2.md 通过 D7（包结构策略）、D8（16-bit/float 编码）、D9（IoCallbacks）、D10（多目标）、D11（零拷贝）、D12（write 回调）六个设计决策，为 req.md 第六节 v0.2/v0.3/v0.4/v1.0 的各版本增量提供了架构落点。第二节"后续版本的模块演进策略"给出了 v0.2/v0.4/v1.0 的模块演进方向。

4. **验收标准响应**：design_v2.md:54-56 的测试与文档层覆盖了 req.md:98-106 的验收标准（`moon check`/`moon test`/ASan/`moon info`/SKILL.md），D4 决策对应 6-10 张测试图片要求，D6 决策对应 SKILL.md 要求。

5. **边界约束响应**：design_v2.md:299 的并发设计、D13 的目标门控、D10 的多目标评估，对应 req.md:108-143 的边界约束（仅 native、不暴露 write/req_channels/16-bit/float/info/flip/callbacks/动画 GIF/PNM/failure_reason/零拷贝）。

**未发现需求遗漏**。设计对 req.md 第七节"澄清与推断汇总"的 9 个澄清点均有响应，对第八节"下游设计输入"的 12 个决策点通过 D1-D14 一一对应（design_v2.md:434-447 的对应表）。

---

## 二、OOD 质量

**[通过]** 职责划分单一内聚、抽象层次合理、协作模式清晰、关键设计决策有充分理由。

**证据**：

1. **职责单一内聚**：四层架构每层职责内聚（design_v2.md:15-22）：
   - Vendoring 层：只处理外部 C 源码引入与版本固定
   - FFI 边界层：只处理 ABI 归一化、所有权转移、失败信号转换
   - 安全 API 层：只做 MoonBit 语义映射与错误构造
   - 测试与文档层：只处理回归测试与文档示例
   - `Image` 只承载数据、`LoadError` 只承载错误、FFI 声明集只声明边界、C wrapper 只处理脏工作、Vendoring 脚本只处理源码引入——5 个核心抽象职责均单一。

2. **抽象层次恰当**（避免过度设计也避免设计不足）：
   - **避免过度设计**：MVP 不引入"加载源"抽象（design_v2.md:31）、不引入 opaque handle（design_v2.md:144）、不引入 `IoCallbacks` trait（留待 v0.4，design_v2.md:71）、单包结构而非过早拆包（design_v2.md:38-43）。
   - **避免设计不足**：引入 `LoadError` 三构造子而非单一字符串错误（design_v2.md:118）、保留 `UnsupportedFormat` 构造子为 v0.3 精确区分预留（design_v2.md:123）、四层架构而非扁平结构。
   - **演进友好**：D7 的"v0.2 评估后倾向保持单包"是倾向性决策而非硬编码，留有拆包余地。

3. **协作模式清晰**：每个抽象的"协作"小节（design_v2.md:86-89, 109-112, 134-137, 157-160, 179-182）描述了交互关系，而非静态成员列表。模块间依赖方向图（design_v2.md:60-64）形成闭环，无缺失环节、无循环依赖。

4. **关键设计决策有充分理由**：14 个设计决策（D1-D14）均给出"决策-理由-权衡"三段式记录：
   - D1（LoadError 统一并入 FileIO）：给出理由与权衡（失去与 IOError 互操作）
   - D2（错误信号 + 默认归类 + 格式嗅探 + Windows 路径）：四子点详细记录
   - D3（Image 导出级别）：derive Eq/@debug.Debug 而非 Show 的理由明确
   - D5（vendoring 版本）：commit hash 的理由与权衡（不如语义版本号直观）
   - D7（包结构策略）：单包理由与拆包权衡
   - D13（ffi.mbt 门控）：类型定义全后端可见的理由与实现方式留待技术设计
   - 各决策的权衡部分均明确指出代价与接受理由。

5. **设计原则遵循**（design_v2.md:451-458）：聚焦职责和抽象、抽象层次适当、协作优于结构、可行性已核实、单一职责、接口隔离——六项原则均有遵循说明。

**未发现 OOD 质量问题**。

---

## 三、FFI 架构合理性

**[通过]** MoonBit ↔ C 边界划分清晰、所有权/生命周期管理合理、错误传递机制明确、安全封装层次恰当。

**证据**：

1. **边界划分**：FFI 边界层是唯一的"语言边界"（design_v2.md:22），承担所有 C/MoonBit 跨越的脏工作。安全 API 层不直接接触 C 头文件，只通过 `ffi.mbt` 的 `extern "c"` 声明间接调用（design_v2.md:66）。C wrapper 是 FFI 边界层内部组件，对安全 API 层不可见。边界划分清晰且唯一。

2. **所有权/生命周期管理**：
   - 输入 `Bytes` 用 `#borrow`（design_v2.md:131, 241）：stb 仅在调用期间读取，不存储引用，调用返回后 MoonBit 侧的 `Bytes` 仍有效。语义正确。
   - 输出 `Bytes` 由 C wrapper 通过 `moonbit_make_bytes` 创建，所有权归 MoonBit GC（design_v2.md:242）。已核实 `moonbit_make_bytes(int32_t size, int value)` 存在于 `moonbit-native-runtime/include/moonbit.h:343`，方案可行。
   - C 侧原始缓冲在拷贝后立即 `stbi_image_free` 释放（design_v2.md:242）。已核实 stb_image.h 中 `stbi_image_free` 存在（实现为 `STBI_FREE`，即 `free`），方案可行。
   - 无 opaque handle（design_v2.md:144）：MVP 一次性解码无需长期管理 handle，避免 finalizer 复杂度。合理。

3. **错误传递机制**：C wrapper 在 stb_image 返回 NULL 时，向 MoonBit 侧返回 NULL 指针 + 零尺寸输出参数，安全 API 层检查并 raise（design_v2.md:243, 317）。机制简洁且与 stb_image 的失败语义（仅返回 NULL）匹配。不采用 `Ref[Int]` 错误码或 C 异常的理由明确（design_v2.md:282-283）。

4. **安全封装层次**：FFI 边界层通过私有 `extern "c"` 声明（不 `pub`）与安全 API 层隔离（design_v2.md:132）；安全 API 层通过 `pub` 暴露的 `load_from_*` 函数与调用者隔离（design_v2.md:458）。`ffi.mbt` 通过 `targets: ["native"]` 门控，不泄漏到其他后端（design_v2.md:52, 417）。

5. **内存安全契约**（design_v2.md:234, 244）：无论成功或失败，C 侧分配的所有临时缓冲都被释放；MoonBit 侧不直接 `free` 任何 C 指针。契约清晰。

**未发现 FFI 架构合理性问题**。

---

## 四、MoonBit v0.10.5 规范一致性

**[通过]** moon.mod/moon.pkg 新格式、preferred_target、targets 门控、native-stub 等配置均与已核实的 v0.10.5 规范先例一致。

**证据**：

1. **moon.mod 新格式**：design_v2.md 使用 `preferred_target = "native"`（下划线，design_v2.md:84 引用 req.md）。已核实先例 `moonbit_wp/.mooncakes/moonbitlang/async/examples/moon.mod:19` 正是 `preferred_target = "native"`，语法正确。design_v2.md:3 明确"新格式 `moon.mod`/`moon.pkg`，旧 `moon.mod.json`/`moon.pkg.json` 已在 v0.10.4 弃用"，与规范一致。

2. **moon.pkg 新格式**：design_v2.md:52-55 描述的 `options("native-stub": [...], targets: {...})` 配置。已核实先例：
   - `moonbit_wp/x/fs/moon.pkg:9-15`：`options("native-stub": [ "fs_native.c" ], targets: { "fs_js.mbt": [ "js" ], "fs_native.mbt": [ "native", "llvm" ] })` —— 与 design_v2.md 描述的配置形式完全一致。
   - `moonbit_wp/.mooncakes/moonbitlang/async/src/types/moon.pkg`：`"native-stub": [ "stub.c" ]` —— native-stub 配置形式一致。

3. **targets 文件级门控**：design_v2.md:52 `targets: ["native"]` 门控 `ffi.mbt`。已核实先例 `moonbit_wp/x/fs/moon.pkg:11-14` 的 `targets: { "fs_native.mbt": [ "native", "llvm" ] }`，语法一致。

4. **native-stub 目录约定**：design_v2.md:41 "extern `c` 声明、C wrapper、vendored 头文件必须在同一 `native-stub` 目录"。已核实先例（`moonbit_wp/async/src/types/moon.pkg` 等 53 处）均将 C 文件放入 native-stub 同目录，约定一致。

5. **类型语法一致性**：
   - `pub(all) struct` + `derive(Eq, @debug.Debug)`：已核实 `image-mbt/src/types.mbt:9-13` 的 `ImageData` 正是此形态，与 design_v2.md:91-96 的 `Image` 设计一致。
   - `pub(all) suberror` + 多构造子：已核实 `image-mbt/src/types.mbt:124-130` 的 `DecodeError` 正是五构造子 `pub(all) suberror`，与 design_v2.md:114-119 的 `LoadError` 设计一致。
   - `#borrow` 所有权标注、`raise`/`try`/`catch` 检查式错误机制：均为 MoonBit 核心能力。

6. **extern "c" 大小写**：D14 决策统一为小写 `extern "c"`（design_v2.md:424-428），与 make-moonbit-c-bindings skill 模板一致。MoonBit 官方文档用大写 `extern "C"`，两者均接受。决策合理，不影响规范一致性。

**未发现规范一致性问题**。

---

## 五、版本迭代架构支撑

**[通过]** 架构清晰支撑从 MVP 到完整库的演进路径，各版本增量在架构上有清晰落点。

**证据**：

1. **v0.2（write + req_channels）落点**：
   - 包结构策略：D7 决策（design_v2.md:368-378）"v0.2 纳入 write 时倾向保持单包按文件分职责（`image_load.mbt` / `image_write.mbt`）"，给出理由（FFI 边界层共享同一 wrapper.c）与权衡（若 API 面显著增长可重新评估拆包）。
   - write 回调设计：D12 决策（design_v2.md:409-413）"v0.2 的 `write_*_to_bytes` 基于 `stbi_write_*_to_func` 回调写入"，与 D9 的 load 端 IoCallbacks 对偶但独立设计。
   - vendoring 扩展：design_v2.md:177 "`--include-write` 参数，供 v0.2 纬入 `stb_image_write.h`"。

2. **v0.3（16-bit/float/info/配置/PNM）落点**：
   - 数据编码：D8 决策（design_v2.md:380-389）"v0.3 的 `Image16.data` 与 `ImageF.data` 以 little-endian 存放于 `Bytes`"，给出理由（主流平台原生字节序、零开销）与权衡（big-endian 平台需转换）。
   - failure_reason 暴露：design_v2.md:230, 288 "v0.3 暴露 `stbi_failure_reason` 后可重新评估错误归类策略"。
   - 错误精确区分：design_v2.md:123, 325 "保留 `UnsupportedFormat` 构造子是为了 v0.3 暴露 `stbi_failure_reason` 后能精确区分"。

3. **v0.4（callbacks/动画 GIF/流式）落点**：
   - IoCallbacks trait：D9 决策（design_v2.md:391-395）"v0.4 引入 `IoCallbacks` trait，映射 stb_image 的 `stbi_io_callbacks`（read/skip/eof）语义"，给出理由（涉及 C→MoonBit 反向调用 trampoline，复杂度高于 MVP）。
   - 模块演进：design_v2.md:71 "`IoCallbacks` trait 作为安全 API 层的新抽象，不改变分层结构"。

4. **v1.0（多目标/完整库）落点**：
   - 多目标支持：D10 决策（design_v2.md:397-401）"v1.0 评估 wasm/js 目标支持路径，不预设答案"，给出理由（重大设计决策需独立评估）。
   - 零拷贝：D11 决策（design_v2.md:403-407）"v1.0 评估零拷贝路径的可行性与收益"。
   - 模块演进：design_v2.md:72 "若纳入 wasm/js，可能引入 `src/wasm/` 子目录承载 Emscripten 产物，FFI 边界层按目标分文件门控"。

5. **架构不阻碍演进**：MVP 的单包结构不阻碍后续拆分（design_v2.md:43）、native-only 限制通过 `preferred_target` 与 `targets` 门控实现不阻碍后续扩展（design_v2.md:401）、类型定义全后端可见（D13）为多目标预留。各版本增量均在现有四层架构内有清晰落点，无需破坏性重构。

**未发现版本迭代架构支撑问题**。

---

## 六、自包含性

**[通过]** 设计自包含，不引用 mizchi/image 或任何已有库作为依赖、互补基准或对比对象。

**证据**：

1. **无 mizchi/image 引用**：全文搜索 design_v2.md，未出现 "mizchi" 或 "image" 作为外部库引用。design_v2.md 中的 "image" 仅指 stb_image.h 上游 C 库（项目绑定目标）或 `Image` 类型（项目自身定义），非对已有 MoonBit 库的引用。

2. **无 image-mbt 引用**：design_v2.md 未引用 `image-mbt` 仓库作为依赖、互补基准或对比对象。image-mbt 仅在本审查报告中作为类型形态先例核实使用，design_v2.md 本身不依赖它。

3. **无已有库作为依赖基准**：design_v2.md 中的"依赖"一词仅出现在：
   - 架构层依赖描述（分层架构、模块间依赖，design_v2.md:15, 22, 58, 66）—— 项目内部结构
   - "外部依赖"（design_v2.md:169）—— 指 vendoring 上游 C 源码，非 MoonBit 库依赖
   - "MoonBit core"（design_v2.md:63）—— 语言核心，合理引用
   均不涉及对已有 MoonBit 图像库的引用或对比。

4. **参考资源合理**：design_v2.md 引用的 make-moonbit-c-bindings skill 模板（design_v2.md:142, 173, 184）是项目 `.codeartsdoer/skills` 下的工作流技能，非外部库依赖。引用 MoonBit 官方文档（design_v2.md:142）是语言规范引用，合理。

**未发现自包含性问题**。

---

## 七、可支撑下游

**[通过]** 架构设计足以指导后续详细设计和编码实现，不直接包含可执行代码规格。

**证据**：

1. **足以指导下游**：
   - 14 个设计决策（D1-D14）记录了所有关键决策的"决策-理由-权衡"，为技术设计阶段提供了清晰的决策上下文。
   - 与需求文档决策点对应表（design_v2.md:434-447）确保 12 个下游设计输入点均有架构决策对应，可追溯。
   - 四个关键行为契约（4.1 happy path / 4.2 error path / 4.3 FFI 边界 / 4.4 vendoring）描述完整到足以指导实现。
   - 4.2.2 节明确了 MVP 实际契约（默认归类 `DecodeFailed`、可选格式嗅探增强），为错误映射实现提供清晰指导。
   - 包内文件职责划分表（design_v2.md:47-56）给出了每个文件的所属层、职责、门控，为编码实现提供清晰落点。

2. **不包含可执行代码规格**：
   - 无完整字段定义：`Image` 和 `LoadError` 仅描述类型形态选择（struct vs enum vs suberror）和构造子名称，未给出完整字段定义语法（如 `struct Image { width : Int; height : Int; channels : Int; data : Bytes }` 的完整定义）。
   - 无方法签名：`load_from_path`/`load_from_bytes` 仅在 req.md 引用中出现签名，design_v2.md 本身仅描述职责与协作，未给出完整方法签名。
   - 无算法细节：C wrapper 的 ABI 归一化仅描述职责（拷贝、释放、失败信号），未给出 C 代码实现。
   - 无完整配置内容：moon.mod/moon.pkg 仅描述配置项（`preferred_target = "native"`、`targets: ["native"]`、`"native-stub": ["wrapper.c"]`），未给出完整配置文件内容。
   - 保持了架构级设计的抽象层次，符合 design_v2.md:3 "具体字段、方法签名、算法细节留待技术设计阶段"的声明。

3. **下游设计输入明确**：design_v2.md:453-458 的设计原则遵循说明明确"聚焦职责和抽象"、"抽象层次适当"、"协作优于结构"、"可行性已核实"，为下游技术设计提供了清晰的抽象边界。

**未发现可支撑下游问题**。

---

## 发现的问题与建议修订

### 问题 1（轻微技术性错误）：4.3 节 `stbi_load_16` 与宽字符路径混淆

**位置**：design_v2.md:245（4.3 节"路径编码提示"）

**问题性质**：技术性事实错误。原文将 `stbi_load_16` 列为 Windows 非 ASCII 路径的宽字符处理方案之一：

> Windows 上非 ASCII 路径可能需要宽字符（`wchar_t` / `stbi_load_16` 变体或平台 `fopen` 宽字符包装）处理

**核实证据**：已 webfetch 核实 stb_image.h v2.30 上游。`stbi_load_16` 的签名为：
```c
STBIDEF stbi_us *stbi_load_16(char const *filename, int *x, int *y, int *comp, int req_comp);
```
`stbi_load_16` 是 **16-bit 像素深度**的 load 接口（返回 `stbi_us*` 即 `unsigned short*`），接收 `char const *` 路径（UTF-8 或 ANSI），**与宽字符路径无关**。`16` 指的是像素位深度，不是宽字符（`wchar_t`）。

stb_image.h 实际提供的 Windows UTF-8 路径支持机制是：
- 编译时定义 `STBI_WINDOWS_UTF8` 宏
- 调用 `stbi_convert_wchar_to_utf8(char *buffer, size_t bufferlen, const wchar_t* input)` 将 `wchar_t*` 转为 UTF-8
- `stbi__fopen` 内部在 `STBI_WINDOWS_UTF8` 定义时使用 `_wfopen` 打开文件

**建议修订**：将 4.3 节"路径编码提示"中的 `stbi_load_16` 替换为 stb_image.h 实际提供的 Windows UTF-8 支持机制：

> Windows 上非 ASCII 路径可利用 stb_image.h 提供的 `STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）或调用 `stbi_convert_wchar_to_utf8` 将 `wchar_t*` 转为 UTF-8 后传递，亦可在 C wrapper 侧用平台 `fopen` 宽字符包装处理——此为 C wrapper 的实现细节，架构层仅提示技术设计需评估 Windows 路径编码兼容性（见设计决策 D2）

同步修订 D2 决策第 4 子点（design_v2.md:320）中如有类似表述。

**影响评估**：不影响架构整体设计。此为 4.3 节实现提示中的事实性错误，若不修订可能在技术设计阶段误导实现者尝试用 `stbi_load_16` 处理宽字符路径（错误方向）。

---

### 问题 2（可改进细节）：失败信号"写入 0"的来源未澄清

**位置**：design_v2.md:154（3.4 节）、design_v2.md:243（4.3 节）、design_v2.md:317（D2 决策）

**问题性质**：描述精度可改进。多处表述"width/height/channels 输出参数写入 0"作为失败信号，但未明确这是 **C wrapper 的主动行为**还是 stb_image 的自然行为。

**核实证据**：已核实 stb_image.h v2.30 上游文档明确说：

> If image loading fails for any reason, the return value will be NULL, and *x, *y, *channels_in_file will be **unchanged**.

即 stb_image 本身在失败时**保持输出参数不变**（而非写入 0）。design_v2.md 中"写入 0"是 C wrapper 需要主动执行的约定行为。

**当前状态**：design_v2.md:154 的上下文（3.4 节 C Wrapper 函数集职责）暗示这是 wrapper 的行为，但未显式澄清"stb_image 本身保持不变，wrapper 主动写入 0 以统一信号"。实现者若直接阅读 stb_image.h 文档可能误以为 stb_image 已写入 0 而省略 wrapper 的主动写入步骤。

**建议修订**：在 3.4 节或 4.3 节增加一句澄清：

> 注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号

**影响评估**：不影响架构整体设计。此为实现细节澄清，修订后可避免技术设计阶段的实现误解。

---

### 问题 3（可改进细节）：`supported_targets` 语法提示缺失

**位置**：design_v2.md:84（引用 req.md 的配置描述）、design_v2.md:417（D13 决策）

**问题性质**：语法细节提示缺失。req.md:84, 143 提到 `supported_targets = "native"`，但实际 v0.10.5 规范先例使用 `supported_targets = "+native"`（带 `+` 前缀）。

**核实证据**：已核实 14 处先例（`moonbit_wp/.mooncakes/moonbitlang/async/examples/*/moon.pkg`、`moonbit_wp/moonbit-tree-sitter/src/*/moon.pkg`）均使用 `supported_targets = "+native"` 形式，无一使用 `"native"` 形式。`+` 前缀表示"追加"语义（在默认目标基础上追加 native）。

**当前状态**：design_v2.md 本身未直接给出 `supported_targets` 的具体语法表述（仅在引用 req.md 内容时提及），所以不存在直接语法错误。但 design_v2.md 作为架构设计，在 D13 决策讨论目标门控时未提示这一语法细节，技术设计阶段可能沿用 req.md 的 `"native"` 表述而导致配置不生效。

**建议修订**：在 D13 决策或第二节配置描述中增加一句提示：

> 注：`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准

**影响评估**：不影响架构整体设计。此为语法细节提示，修订后可避免技术设计阶段的配置错误。

---

## 与前序 review_v2.md 的对比

本审查与 review_v2.md（architecture-design-harness 第 2 轮 verifier 报告）的结论一致：**[APPROVED]**。两份审查的差异：

1. **审查维度不同**：review_v2.md 聚焦"类型系统可行性、标准库覆盖、语言特性、设计一致性、设计质量"5 个维度；本审查覆盖 task.md 要求的 7 个维度（需求响应充分度、OOD 质量、FFI 架构合理性、v0.10.5 规范一致性、版本迭代架构支撑、自包含性、可支撑下游）。

2. **核实深度不同**：review_v2.md 核实了 image-mbt 类型形态先例；本审查额外核实了 stb_image.h v2.30 上游完整 API（webfetch）、`moonbit_make_bytes` 存在性、`supported_targets` 语法先例（14 处）、`native-stub` 配置先例（53 处）。

3. **本审查发现的问题**：review_v2.md 未发现的技术性错误（问题 1：`stbi_load_16` 与宽字符路径混淆）和两个可改进细节（问题 2、3）。这些问题均不影响架构整体成立，但修订后可提升设计精度。

---

## 审查总结

`design_v2.md` 是一份高质量的架构级 OOD 设计文档，在 7 个审查维度上均表现良好：

- **需求响应充分**：完整覆盖 req.md 的完整库定位、MVP 范围、版本迭代计划、验收标准、边界约束。
- **OOD 质量良好**：四层架构职责内聚、抽象层次恰当（避免过度设计与设计不足）、协作模式清晰、14 个设计决策有充分理由与权衡。
- **FFI 架构合理**：边界划分唯一、所有权管理清晰（`#borrow` + `moonbit_make_bytes` + `stbi_image_free`）、错误传递简洁（NULL + 零尺寸）、安全封装分层。
- **v0.10.5 规范一致**：moon.mod/moon.pkg 新格式、preferred_target、targets 门控、native-stub 均有已核实先例。
- **版本迭代有架构落点**：D7-D12 为 v0.2/v0.3/v0.4/v1.0 各版本增量提供清晰架构落点，不阻碍演进。
- **自包含**：不引用 mizchi/image 或任何已有库作为依赖、互补基准或对比对象。
- **可支撑下游**：14 个设计决策 + 4 个行为契约 + 文件职责划分表足以指导技术设计，不包含可执行代码规格。

发现的问题均为轻微或细节级别，不影响架构整体成立。建议在技术设计阶段前修订问题 1（技术性错误），问题 2、3 可一并修订以提升设计精度。