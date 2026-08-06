# OOD 设计方案审查报告（v2）

## 审查结果

[APPROVED]

## 上一轮驳回问题核查

本轮独立审查，同时重点核查 v1 驳回的问题 1（一般）与三个轻微问题是否已解决。

### 问题 1（一般）：4.2 节错误路径契约与 D2 权衡不一致 — 已解决

v1 的核心驳回点：4.2 节承诺三种可区分错误类别，但 D2 明确 MVP 阶段无法区分 `UnsupportedFormat` 与 `DecodeFailed`，4.2 节未注明实现限制也未约定默认归类策略。

v2 修订措施已落实且闭合：

1. **4.2 节重写为四个子节**（design_v2.md:202-234）：
   - 4.2.1 完整库目标（语义意图）——保留三构造子语义意图表，明确标注为"语义意图"
   - 4.2.2 MVP 实际契约——明确 `FileIO` 可独立区分、`UnsupportedFormat` 与 `DecodeFailed` 不可精确区分并约定**默认归类 `DecodeFailed`**（附三条理由：语义自洽、调用者处理一致、为 v0.3 保留构造子），提出可选格式嗅探增强作为部分达成路径
   - 4.2.3 错误描述字符串——明确中文提示与示例
   - 4.2.4 内存安全契约
2. **4.2 节开头明确声明**（design_v2.md:205）："三个构造子是**完整库目标的语义意图**...MVP 阶段受限于 stb_image 的失败语义（仅返回 NULL，无原因区分），三类错误的**实际可达区分粒度**如下，调用者应基于此实际契约编写错误处理代码。"——直接消除了 v1 中"契约承诺 vs 实现限制"的不闭合
3. **3.2 节同步修订**（design_v2.md:123）：增加"MVP 阶段区分粒度"说明段，指向 4.2 节与 D2
4. **第五节错误分类表同步修订**（design_v2.md:267-271）：增加"MVP 可达性"列，与 4.2.2 节一致
5. **D2 决策同步修订**（design_v2.md:314-330）：增加默认归类策略（第 2 子点）、格式嗅探增强（第 3 子点）、Windows 路径编码提示（第 4 子点），权衡部分明确"默认归类策略是 MVP 的约定，v0.3 暴露 stbi_failure_reason 后可重新评估"
6. **第八节对应表同步修订**（design_v2.md:437）：D2 行更新为"返回 NULL + 零尺寸输出参数；MVP 默认归类 `DecodeFailed`；可选格式嗅探增强；提示 Windows 路径编码"

内部一致性已完全修复：4.2 节契约 → 3.2 节类型说明 → 第五节错误分类表 → D2 决策 → 第八节对应表，五处描述闭合无歧义。

### 轻微问题 1：3.4 节失败信号描述与 D2 不统一 — 已解决

v2 已统一：3.4 节（design_v2.md:154）"失败时（C 返回 NULL）向 MoonBit 侧返回统一的失败信号：NULL 指针 + 零尺寸输出参数（width/height/channels 写入 0）"；4.3 节（design_v2.md:243）同步统一并明确标注"此为唯一的失败信号方案，与设计决策 D2 一致"。表述与 D2 决策（design_v2.md:317）完全一致。

### 轻微问题 2：错误描述字符串语言选择未明确 — 已解决

v2 的 4.2.3 节（design_v2.md:228）明确："错误描述字符串为**人类可读的中文提示**（符合项目交互语言偏好）"，并给出 `FileIO("文件不存在: /path/to/missing.png")`、`DecodeFailed("stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据")` 示例。

### 轻微问题 3：Windows 路径编码未明确 — 已解决

v2 的 4.3 节（design_v2.md:245）增加"路径编码提示"条目，说明 MoonBit `String`（UTF-8）到 C `const char*` 的平台惯例转换与 Windows 非 ASCII 路径的宽字符处理需求；D2 决策（design_v2.md:320）增加第 4 子点"Windows 路径编码"，提示技术设计阶段需评估 Windows 兼容性。

## 逐维度审查

### 1. 类型系统可行性

**[通过]** `Image` 选择 `pub(all) struct` + `derive(Eq, @debug.Debug)` 在 MoonBit v0.10.5 类型系统内可行。已核实真实先例：`image-mbt/src/types.mbt:9` 的 `ImageData` 正是 `pub(all) struct { width : Int; height : Int; data : Bytes } derive(Eq, @debug.Debug)` 形态，与设计完全一致。不 derive `Show` 而用 `@debug.Debug` 控制输出的决策合理（避免对大 `Bytes` 完整字符串化）。

**[通过]** `LoadError` 选择 `pub(all) suberror` + 三构造子 `UnsupportedFormat(String)` / `DecodeFailed(String)` / `FileIO(String)` 可行。已核实多构造子 `pub(all) suberror` 先例：`image-mbt/src/types.mbt:124` 的 `DecodeError { InvalidSignature(String); InvalidChunkCrc(String); MissingChunk(String); UnsupportedFeature(String); CorruptData(String) }` 正是五构造子 `pub(all) suberror`，与设计形态一致。`suberror` + `raise` 是 MoonBit 检查式错误的惯用法。

**[通过]** FFI 私有声明集选择顶层 `extern "c" fn` 声明可行。小写 `extern "c"` 与大写 `extern "C"` 均接受（D14 决策选小写，与 skill 模板一致）。

**[通过]** 设计不涉及泛型抽象（MVP 无需），无继承关系（MoonBit 无类继承），协作关系（`Image` 由安全 API 层构造、`LoadError` 由安全 API 层 raise、FFI 声明被安全 API 层调用）的类型交互模式均在 MoonBit 能力范围内。

### 2. 标准库与生态覆盖

**[通过]** 设计所需能力均在标准库或已核实生态覆盖范围内：
- `Bytes` / `Int` / `String` — MoonBit 核心类型
- `raise` / `try` / `catch` — MoonBit 检查式错误机制
- `moonbit_make_bytes(int32_t size, int value)` — 已核实存在于 `moonbit-native-runtime/include/moonbit.h:343`，C wrapper 拷贝路径可行
- `#borrow` 所有权标注 — 输入 `Bytes` 借用语义可行
- `moon.pkg` 新格式 `native-stub` + `targets` 门控 — 已核实先例
- `moon.mod` 新格式 `preferred_target = "native"` — 已核实先例
- `supported_targets` — 已核实先例（`moonbit_wp/.mooncakes/moonbitlang/async/examples/cat/moon.pkg` 的 `supported_targets = "+native"`）
- SHA256 校验 — Python `hashlib` 标准库
- 测试框架 — `moon test` / `moon check`

**[通过]** 文件 IO 路径无需 MoonBit 侧额外能力：`load_from_path` 直接调用 C 侧 `stbi_load(const char*)`，由 C wrapper 处理文件读取，MoonBit 侧仅传递路径字符串。`load_from_bytes` 调用 `stbi_load_from_memory`。两个入口直接对应 stb_image 的两个 C API，无需自定义 IO 抽象。

**[通过]** 设计中未假设非常规库能力。Vendoring 脚本用 Python 跨平台脚本（`hashlib` / `urllib`），符合 make-moonbit-c-bindings skill 模板惯例。

### 3. 语言特性可行性

**[通过]** 错误处理策略与 MoonBit 能力匹配：`suberror` + `raise` 是检查式错误的惯用法，`LoadError` 在函数签名中显式声明，调用者无法忽略。不使用 `Result`/`Option` 作为错误载体的决策符合 MoonBit 惯例。v2 进一步明确了 MVP 阶段的错误可达粒度（4.2.2 节），错误处理契约与语言能力匹配且无误导性承诺。

**[通过]** 并发设计：MVP 不涉及并发，第六节明确说明 stb_image 是同步 C 库，FFI 调用同步完成，无共享可变状态。完整库版本的 thread-local 配置留待 v0.3 评估，MVP 不预设——合理。

**[通过]** 资源管理方案在 MoonBit native FFI 模式内可行：C wrapper 通过 `moonbit_make_bytes` 创建 MoonBit `Bytes`（所有权归 GC），`stbi_image_free` 释放 C 侧原始缓冲，`#borrow` 标注输入 `Bytes` 借用语义。4.2.4 节与 4.3 节的内存安全契约明确：无论成功或失败，C 侧分配的所有临时缓冲都被释放；MoonBit 侧不直接 `free` 任何 C 指针。

**[通过]** 模块/包结构设计符合 MoonBit 项目组织方式：单包结构（`src/`）+ `moon.pkg` targets 门控 + `native-stub` 配置，均有真实先例。D13 的"`image.mbt` 类型定义全后端可见，FFI 调用部分条件编译到 native"方向可行——`targets` 文件级门控已验证，拆文件方案（`image_types.mbt` + `image_load_native.mbt`）作为备选已识别。

### 4. 设计一致性

**[通过]** 各抽象的"角色"/"职责"/"协作"描述清晰无歧义。四层架构（Vendoring / FFI 边界 / 安全 API / 测试与文档）职责内聚，依赖单向向下，无循环依赖。模块间依赖方向图（第二节）形成闭环，无缺失环节。

**[通过]** 行为契约（4.1 happy path / 4.2 error path / 4.3 FFI 边界 / 4.4 vendoring）描述完整到足以指导后续实现。v2 的 4.2 节通过四子节结构清晰区分了"完整库语义意图"与"MVP 实际契约"，消除了 v1 中契约与权衡的不闭合。14 个设计决策（D1-D14）记录了关键决策与权衡，第八节与需求文档 12 个决策点一一对应。

**[通过]** v2 修复了 v1 的所有内部一致性问题：
- 4.2 节契约与 D2 权衡一致（默认归类 `DecodeFailed` 明确约定）
- 3.4 节失败信号描述与 D2 决策统一（NULL 指针 + 零尺寸输出参数）
- 4.3 节失败信号标注"此为唯一的失败信号方案，与设计决策 D2 一致"
- 错误描述字符串语言明确（中文）
- Windows 路径编码提示已补充（4.3 节 + D2 第 4 子点）
- 3.2 节、第五节错误分类表、第八节对应表均同步修订，五处描述闭合

### 5. 设计质量

**[通过]** 职责划分遵循单一职责原则：`Image` 只承载数据、`LoadError` 只承载错误、FFI 边界层只处理跨语言脏工作、Vendoring 脚本只处理源码引入、安全 API 层只做语义映射与错误构造。四层架构每层职责内聚。

**[通过]** 抽象层次恰当，未过度设计也未设计不足：
- MVP 不引入"加载源"抽象（path/bytes 直接对应 C API）——避免过度设计
- 不引入 opaque handle（MVP 一次性解码无需）——避免过度设计
- 不引入 `IoCallbacks` trait（留待 v0.4）——避免过度设计
- 引入 `LoadError` 三构造子而非单一字符串错误——避免设计不足
- 保留 `UnsupportedFormat` 构造子为 v0.3 精确区分预留——演进友好
- 四层架构 + 5 个核心抽象——层次恰当

**[通过]** 设计便于后续详细设计和实现：14 个设计决策记录权衡、版本演进策略（D7/D9-D12）给出未来方向、与需求文档决策点对应表（第八节）确保可追溯。v2 的 4.2.2 节明确约定了默认归类策略与可选格式嗅探增强，为技术设计阶段的错误映射实现提供了清晰指导。

**[通过]** 设计便于单元测试：`Image` derive `Eq` 支持断言、`LoadError` 可模式匹配、FFI 边界层通过私有声明隔离使安全 API 层可独立测试、测试图片 vendoring 到 `testdata/` 使测试自包含。FFI 边界层本身难以 mock 是 FFI 项目固有特性，非设计缺陷（D4 的脚本生成测试样本策略合理）。