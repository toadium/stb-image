# OOD 设计方案审查报告（v1）

## 审查结果

[REJECTED]

## 逐维度审查

### 1. 类型系统可行性

**[通过]** `Image` 选择 `pub(all) struct` + `derive(Eq, @debug.Debug)` 在 MoonBit v0.10.5 类型系统内可行。已核实真实先例：`image-mbt/src/types.mbt:9` 的 `ImageData` 正是 `pub(all) struct { width : Int; height : Int; data : Bytes } derive(Eq, @debug.Debug)` 形态，与设计完全一致。不 derive `Show` 而用手动控制输出的决策合理（避免对大 `Bytes` 完整字符串化）。

**[通过]** `LoadError` 选择 `pub(all) suberror` + 三构造子 `UnsupportedFormat(String)` / `DecodeFailed(String)` / `FileIO(String)` 可行。已核实多构造子 `suberror` 先例：`moonbitlang/async/src/http/parser.mbt:48` 的 `HttpProtocolError { BadRequest; HttpVersionNotSupported(String); NotImplemented }`、`moonbitlang/async/src/websocket/types.mbt:117` 的 `WebSocketError` 四构造子。`pub(all) suberror` 先例：`moonbitlang/async/src/os_error/error.mbt:59` 的 `OSError`。`suberror` + `raise` 是 MoonBit 检查式错误的惯用法，906 处实际使用。

**[通过]** FFI 私有声明集选择顶层 `extern "c" fn` 声明可行。281 处实际使用，`moonbit-tree-sitter` 提供完整的 `extern "c"` + `MOONBIT_FFI_EXPORT` + `native-stub` 先例。小写 `extern "c"` 与大写 `extern "C"` 均有先例（D14 决策选小写，与 skill 模板一致）。

**[通过]** 设计不涉及泛型抽象（MVP 无需），无继承关系（MoonBit 无类继承），协作关系（`Image` 由安全 API 层构造、`LoadError` 由安全 API 层 raise、FFI 声明被安全 API 层调用）的类型交互模式均在 MoonBit 能力范围内。

### 2. 标准库与生态覆盖

**[通过]** 设计所需能力均在标准库或已核实生态覆盖范围内：
- `Bytes` / `Int` / `String` — MoonBit 核心类型
- `raise` / `try` / `catch` — MoonBit 检查式错误机制
- `moonbit_make_bytes(int32_t size, int value)` — 已核实存在于 `moonbit-native-runtime/include/moonbit.h:343`，C wrapper 拷贝路径可行
- `#borrow` 所有权标注 — 656 处实际使用，输入 `Bytes` 借用语义可行
- `moon.pkg` 新格式 `native-stub` + `targets` 门控 — 53 处 `native-stub` 使用，`moonbit-tree-sitter/src/moon.pkg` 提供完整先例
- `moon.mod` 新格式 `preferred_target = "native"` — 38 处使用，下划线语法已核实
- `supported_targets` — 5 处使用（`editor/server/moon.mod` 等简单形式 `"native"` 可行）
- SHA256 校验 — Python `hashlib` 标准库
- 测试框架 — `moon test` / `moon check`

**[通过]** 文件 IO 路径无需 MoonBit 侧额外能力：`load_from_path` 直接调用 C 侧 `stbi_load(const char*)`，由 C wrapper 处理文件读取，MoonBit 侧仅传递路径字符串。`load_from_bytes` 调用 `stbi_load_from_memory`。两个入口直接对应 stb_image 的两个 C API，无需自定义 IO 抽象。

**[通过]** 设计中未假设非常规库能力。Vendoring 脚本用 Python 跨平台脚本（`hashlib` / `urllib`），符合 make-moonbit-c-bindings skill 模板惯例。

### 3. 语言特性可行性

**[通过]** 错误处理策略与 MoonBit 能力匹配：`suberror` + `raise` 是检查式错误的惯用法，`LoadError` 在函数签名中显式声明，调用者无法忽略。不使用 `Result`/`Option` 作为错误载体的决策符合 MoonBit 惯例（`raise` 让正常路径更简洁）。

**[通过]** 并发设计：MVP 不涉及并发，第六节明确说明 stb_image 是同步 C 库，FFI 调用同步完成，无共享可变状态。完整库版本的 thread-local 配置留待 v0.3 评估，MVP 不预设——合理。

**[通过]** 资源管理方案在 MoonBit native FFI 模式内可行：C wrapper 通过 `moonbit_make_bytes` 创建 MoonBit `Bytes`（所有权归 GC），`stbi_image_free` 释放 C 侧原始缓冲，`#borrow` 标注输入 `Bytes` 借用语义。`moonbit-tree-sitter` 的 `tree-sitter.c` 提供了完整的 C wrapper + `MOONBIT_FFI_EXPORT` + `moonbit.h` 先例。

**[通过]** 模块/包结构设计符合 MoonBit 项目组织方式：单包结构（`src/`）+ `moon.pkg` targets 门控 + `native-stub` 配置，均有真实先例。D13 的"`image.mbt` 类型定义全后端可见，FFI 调用部分条件编译到 native"方向可行——`targets` 文件级门控已验证，拆文件方案（`image_types.mbt` + `image_load_native.mbt`）作为备选已识别。

### 4. 设计一致性

**[通过]** 各抽象的"角色"/"职责"/"协作"描述清晰无歧义。四层架构（Vendoring / FFI 边界 / 安全 API / 测试与文档）职责内聚，依赖单向向下，无循环依赖。模块间依赖方向图（第二节）形成闭环，无缺失环节。

**[通过]** 行为契约（4.1 happy path / 4.3 FFI 边界 / 4.4 vendoring）描述完整到足以指导后续实现。14 个设计决策（D1-D14）记录了关键决策与权衡，第八节与需求文档 12 个决策点一一对应。

**[一般]** 4.2 节错误路径契约与 D2 权衡存在内部不一致。4.2 节承诺三种可区分的错误类别及其触发条件：
- "字节序列或文件内容不是 stb_image 可识别的格式 → `raise LoadError::UnsupportedFormat(...)`"
- "格式可识别但数据损坏/不完整 → `raise LoadError::DecodeFailed(...)`"

但 D2 权衡明确指出："无法在 MoonBit 侧区分'格式不支持'与'数据损坏'——两者都表现为 NULL 返回。MVP 接受这一损失"。即 MVP 阶段 `UnsupportedFormat` 与 `DecodeFailed` 在实现上不可区分（stb_image 失败时仅返回 NULL，无原因区分）。

4.2 节作为"行为契约"是对外可见的承诺，若调用者依赖"格式不支持 → UnsupportedFormat"与"数据损坏 → DecodeFailed"的区分编写代码，将因实现无法区分而误导。4.2 节未注明 MVP 阶段的实现限制，也未说明 NULL 返回时的默认归类策略，与 D2 的权衡不闭合。这会误导后续技术设计——技术设计阶段若按 4.2 节契约实现，将发现无法区分两者，需回头调整。

**[轻微]** 3.4 节描述失败信号为"NULL 指针或负数尺寸"（两种可能），D2 明确选择"NULL 指针 + 零尺寸输出参数"（一种具体方案）。3.4 节的宽泛描述与 D2 的具体决策虽不算矛盾（3.4 是抽象描述，D2 是具体决策），但可统一表述以减少歧义。

**[轻微]** 4.2 节"错误描述字符串为人类可读的英文/中文提示"中"英文/中文"的选择未明确。是两者都支持（i18n）还是选其一？若选其一，选哪个？此细节不阻塞但建议澄清。

**[轻微]** 设计未明确 `load_from_path` 的 path 参数在 Windows 上的编码处理。MoonBit `String` 是 UTF-8，C 侧 `stbi_load` 接受 `const char*` 文件名，Windows 上非 ASCII 路径可能需要宽字符处理。此为实现细节，架构级可不展开，但建议在 D2 或 4.3 中提一句以提示技术设计。

### 5. 设计质量

**[通过]** 职责划分遵循单一职责原则：`Image` 只承载数据、`LoadError` 只承载错误、FFI 边界层只处理跨语言脏工作、Vendoring 脚本只处理源码引入、安全 API 层只做语义映射与错误构造。四层架构每层职责内聚。

**[通过]** 抽象层次恰当，未过度设计也未设计不足：
- MVP 不引入"加载源"抽象（path/bytes 直接对应 C API）——避免过度设计
- 不引入 opaque handle（MVP 一次性解码无需）——避免过度设计
- 不引入 `IoCallbacks` trait（留待 v0.4）——避免过度设计
- 引入 `LoadError` 三构造子而非单一字符串错误——避免设计不足
- 四层架构 + 5 个核心抽象——层次恰当

**[通过]** 设计便于后续详细设计和实现：14 个设计决策记录权衡、版本演进策略（D7/D9-D12）给出未来方向、与需求文档决策点对应表（第八节）确保可追溯。

**[通过]** 设计便于单元测试：`Image` derive `Eq` 支持断言、`LoadError` 可模式匹配、FFI 边界层通过私有声明隔离使安全 API 层可独立测试、测试图片 vendoring 到 `testdata/` 使测试自包含。FFI 边界层本身难以 mock 是 FFI 项目固有特性，非设计缺陷（D4 的脚本生成测试样本策略合理）。

## 修改要求（REJECTED 时存在）

### 问题 1：4.2 节错误路径契约与 D2 权衡不一致

- **问题**：4.2 节承诺三种可区分的错误类别（`FileIO` / `UnsupportedFormat` / `DecodeFailed`）及其触发条件，但 D2 权衡明确指出 MVP 阶段无法区分 `UnsupportedFormat` 与 `DecodeFailed`（stb_image 失败时仅返回 NULL，无原因区分）。4.2 节未注明此实现限制，也未说明 NULL 返回时的默认归类策略。

- **原因**：4.2 节作为行为契约是对外承诺，若调用者依赖 `UnsupportedFormat` vs `DecodeFailed` 的区分编写代码，将因实现无法区分而误导。后续技术设计若按 4.2 节契约实现，将发现无法区分两者，需回头调整。设计文档内部（4.2 节 vs D2）存在不闭合的一致性缺陷。

- **建议方向**：在 4.2 节注明 MVP 阶段的实现限制，使之与 D2 权衡一致。具体可选：
  1. 在 4.2 节错误类别描述后追加注记："注：MVP 阶段 stb_image 失败时仅返回 NULL，`UnsupportedFormat` 与 `DecodeFailed` 的精确区分需 v0.3 暴露 `stbi_failure_reason` 后达成；MVP 阶段 NULL 返回时默认归类为 `DecodeFailed`（或 `UnsupportedFormat`，由技术设计确定）"
  2. 或将 4.2 节三个错误类别明确标注为"语义意图（完整库目标）"，并补充"MVP 实际契约"小节说明当前可达的区分粒度（`FileIO` vs 其他可通过 path 入口预检查区分；`UnsupportedFormat` vs `DecodeFailed` 在 MVP 阶段不可区分）
  3. 同时建议明确 NULL 返回时的默认归类策略，以指导技术设计阶段的错误映射实现