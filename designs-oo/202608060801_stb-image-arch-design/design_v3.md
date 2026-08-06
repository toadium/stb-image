# `stb-image` 架构级 OOD 设计（v2）

> 本设计为架构级 OOD 设计，聚焦职责划分、抽象层次、协作模式与关键设计决策。具体字段、方法签名、算法细节留待技术设计阶段。设计目标语言为 MoonBit（v0.10.5 规范，新格式 `moon.mod`/`moon.pkg`，native 后端）。

---

## 一、概述

### 设计目标

将 C 单头文件库 `stb_image.h`（及后续 `stb_image_write.h`）以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，提供安全、惯用、可演进的图像 load/write 能力。MVP 阶段聚焦最常用的 8-bit load 路径（native 目标），后续按版本迭代计划逐步演进到完整库。

### 核心架构思路

采用**分层架构**，自下而上四层，每层职责内聚、依赖单向向下：

1. **Vendoring 层** — 外部 C 源码的受控引入与版本固定
2. **FFI 边界层** — ABI 归一化、所有权转移、失败信号转换
3. **安全 API 层** — MoonBit 语义的公开接口，错误抛出，类型构造
4. **测试与文档层** — 回归测试、文档示例、ASan 验证

层间依赖严格单向：上层只依赖下层，下层不感知上层。FFI 边界层是唯一的"语言边界"，承担所有 C/MoonBit 跨越的脏工作；安全 API 层对调用者呈现纯粹的 MoonBit 语义。

### 核心抽象

- **`Image`** — 解码结果的值对象，承载像素数据与元信息
- **`LoadError`** — 加载失败的领域错误类型
- **FFI 私有声明集** — `extern "c"` 声明与 C wrapper 函数，不对外可见
- **Vendoring 脚本** — 可重复的 C 源码引入流程

设计刻意保持抽象面最小：MVP 不引入"加载源"抽象（path 与 bytes 两个入口直接对应 stb_image 的两个 C API），避免过度设计。流式能力（`IoCallbacks`）留待 v0.4 作为正交扩展引入。

---

## 二、模块划分

### MVP 阶段：单包结构

MVP 采用单包结构（`src/`），所有源码与 vendored C 头文件同居一目录。这一选择基于以下考量：

- **FFI 局部性**：`extern "c"` 声明、C wrapper、vendored 头文件必须在同一 `native-stub` 目录，物理上不可拆
- **API 面小**：MVP 仅 `load_from_path`/`load_from_bytes` 两个入口 + `Image` + `LoadError`，无按职责拆包的规模驱动
- **演进可控**：单包不阻碍后续拆分，v0.2 纳入 write 时再评估拆子包（见设计决策 D7）

### 包内文件职责划分

| 文件 | 所属层 | 职责 | 门控 |
|------|--------|------|------|
| `scripts/prepare.py` | Vendoring | 下载 pinned 上游头文件、SHA256 校验、刷新 `moon.pkg` 的 native-stub 列表 | 不参与编译 |
| `src/stb_image.h`（vendored） | Vendoring | 上游 C 头文件本体 | 由 `native-stub` 编译 |
| `src/wrapper.c` | FFI 边界 | ABI 归一化、`moonbit_make_bytes` 拷贝、`stbi_image_free` 释放、NULL→失败信号 | `native-stub` |
| `src/ffi.mbt` | FFI 边界 | 私有 `extern "c"` 声明，仅 native 后端编译 | `targets: ["native"]` |
| `src/image.mbt` | 安全 API | 公开 `Image`/`LoadError`/`load_from_*`，错误映射，类型构造 | 类型定义全后端可用；FFI 调用部分条件编译到 native |
| `src/image_test.mbt` | 测试 | 回归测试（happy + error path） | 测试模式 |
| `src/README.mbt.md` | 测试与文档 | 测试过的文档示例（`mbt check` 块） | `targets: ["native"]`（含 FFI 示例） |
| `testdata/` | 测试 | vendored 测试图片（正常 + 损坏样本） | 不参与编译 |

### 模块间依赖方向

```
测试与文档层 ──→ 安全 API 层 ──→ FFI 边界层 ──→ Vendoring 层
     │                │                │
     └─→ testdata/    └─→ (MoonBit core) └─→ (C runtime + moonbit.h)
```

无环依赖。安全 API 层不直接接触 C 头文件，只通过 `ffi.mbt` 的 `extern "c"` 声明间接调用；C wrapper 是 FFI 边界层内部组件，对安全 API 层不可见。

### 后续版本的模块演进策略

- **v0.2（write 纳入）**：评估是否拆 `src/read/` + `src/write/` 子包，或保持单包按文件分职责（`image_load.mbt` / `image_write.mbt`）。倾向后者，因 FFI 边界层仍共享同一 `wrapper.c` 与 vendored 头文件，拆包收益有限（见设计决策 D7）
- **v0.4（callbacks）**：`IoCallbacks` trait 作为安全 API 层的新抽象，不改变分层结构
- **v1.0（多目标）**：若纳入 wasm/js，可能引入 `src/wasm/` 子目录承载 Emscripten 产物，FFI 边界层按目标分文件门控

---

## 三、核心抽象

### 3.1 `Image` — 解码结果值对象

**角色**：领域值对象，表示一次成功解码的图像数据。

**职责**：
- 承载图像的几何元信息（宽、高、通道数）与像素数据
- 作为不可变值在调用者间传递；MVP 不提供变换方法（变换属完整库后续版本或调用者侧职责）

**协作**：
- 由安全 API 层的 `load_from_path`/`load_from_bytes` 构造
- 调用者读取其字段用于后续处理（写入文件、转换格式、上传等）
- 不与 FFI 边界层直接协作——`Image` 在 FFI 调用返回后由安全 API 层一次性构造，构造完成即脱离 FFI 边界

**类型形态选择**：`struct`（值类型）。理由：
- `Image` 是数据的简单聚合，无不变式需要维护、无资源需要释放（`data : Bytes` 由 MoonBit GC 接管，无需 finalizer）
- `struct` 的值语义符合"解码快照"的领域直觉
- 不用 `enum`：无多态分支；不用 `type`（opaque）：字段需对调用者可见
- 导出级别 `pub(all)`：允许外部构造与字段访问（调用者可能从其他来源拼装 `Image`，如完整库的 write 路径需接收 `Image` 输入）
- derive `Eq`/`@debug.Debug`：支持测试断言与调试输出，不 derive `Show`（避免对大 `Bytes` 的完整字符串化）

**为何不是 `Bytes` 直接包装**：`Image` 需同时携带几何元信息，单一 `Bytes` 无法表达"这是 100×100×3 的像素"还是"30000 字节的裸数据"。元信息与数据共生，struct 是自然形态。

### 3.2 `LoadError` — 加载失败领域错误

**角色**：领域错误类型，表示加载过程中可向调用者暴露的失败类别。

**职责**：
- 分类失败原因：不支持的格式、解码失败（损坏数据/不完整文件）、文件 IO 失败（路径不存在/不可读）
- 携带人类可读的失败描述字符串供调试
- 不暴露 C 错误码或 `stbi_failure_reason` 的原始 C 字符串（MVP 阶段性限制）

**协作**：
- 由安全 API 层在 FFI 返回失败信号时构造并 `raise`
- 调用者通过 `try ... catch { LoadError::... => ... }` 模式匹配处理
- 不与 FFI 边界层直接协作——FFI 边界层只负责把 C 失败转换为可被安全 API 层识别的信号（如 NULL 指针、零尺寸输出参数），错误类型的构造是安全 API 层职责

**类型形态选择**：`suberror`（MoonBit 检查式错误）。理由：
- MoonBit 惯例：领域错误用 `suberror` + `raise`，不用 `Result`（需求文档已澄清）
- `suberror` 让错误类型在函数签名中显式声明，调用者无法忽略
- 不用 `enum`：`suberror` 是 `Error` 的子类型，可直接 `raise`；普通 `enum` 需额外 `impl Error`
- 构造子至少三个：`UnsupportedFormat(String)`、`DecodeFailed(String)`、`FileIO(String)`（文件路径入口的 IO 失败，统一并入 `LoadError` 而非复用标准库 `IOError`，理由见设计决策 D1）
- `pub(all)`：允许外部 `raise` 该错误（如更上层包装）

**为何不区分更细的解码失败子类**：MVP 阶段 stb_image 的失败信号只有"返回 NULL"一种，无法区分"格式不支持"与"数据损坏"的深层原因。细分到 `UnsupportedFormat` vs `DecodeFailed` 已是 MVP 可支撑的粒度；更细的分类留待 v0.3 暴露 `stbi_failure_reason` 后再评估。

**MVP 阶段 `UnsupportedFormat` 与 `DecodeFailed` 的区分粒度**：见 4.2 节"MVP 实际契约"与设计决策 D2。三个构造子是完整库目标的语义意图，MVP 阶段 `FileIO` 可独立区分（path 入口预检查），但 `UnsupportedFormat` 与 `DecodeFailed` 在 stb_image 仅返回 NULL 的失败语义下不可精确区分，需约定默认归类策略。

### 3.3 FFI 私有声明集 — 语言边界抽象

**角色**：FFI 边界层的内部抽象，将 C wrapper 函数声明为 MoonBit 可调用。

**职责**：
- 声明 `extern "c"` 函数，对应 `wrapper.c` 中的 `MOONBIT_FFI_EXPORT` 函数
- 标注所有权：输入 `Bytes` 用 `#borrow`（stb 仅在调用期间读取）
- 保持私有：不 `pub`，仅供同包 `image.mbt` 调用

**协作**：
- 被 `image.mbt` 的安全包装函数调用
- 调用 `wrapper.c` 中的对应函数（通过符号名匹配）
- 不被外部包直接访问

**类型形态选择**：顶层 `extern "c" fn` 声明（非 trait、非 struct）。理由：
- FFI 声明是函数级别的语言机制，无需封装为类型
- 保持私有 + `targets: ["native"]` 门控，确保不泄漏到其他后端或外部包
- 使用小写 `extern "c"`（与 make-moonbit-c-bindings skill 模板一致；MoonBit 官方文档用大写 `extern "C"`，两者均接受，技术设计阶段统一）

**为何不引入 opaque handle 类型**：MVP 的 load 路径是"一次性解码返回数据"模式，C 侧不返回需要长期管理的 handle（返回的是裸 `unsigned char*`，立即拷贝到 MoonBit `Bytes` 后释放）。无 handle 就无需 `type Handle` + finalizer 模式。后续版本若暴露 `stbi_image_load` 的流式变体或需延迟释放的场景，再引入 opaque handle。

### 3.4 C Wrapper 函数集 — ABI 归一化抽象

**角色**：FFI 边界层的 C 侧组件，承担所有 C/MoonBit 跨越的脏工作。

**职责**：
- 调用 vendored `stb_image.h` 的 `stbi_load`/`stbi_load_from_memory`
- 将返回的 `unsigned char*` 拷贝到 `moonbit_make_bytes` 创建的 MoonBit `Bytes`
- 调用 `stbi_image_free` 释放 C 侧原始缓冲（避免泄漏）
- 失败时（C 返回 NULL）向 MoonBit 侧返回统一的失败信号：NULL 指针 + 零尺寸输出参数（width/height/channels 写入 0），由安全 API 层检查并 raise。注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号
- 输出参数（width/height/channels）通过指针写回，MoonBit 侧读取

**协作**：
- 被 `ffi.mbt` 的 `extern "c"` 声明调用
- 调用 `stb_image.h` 的 C API 与 `moonbit.h` 的运行时 API（`moonbit_make_bytes`）
- 不直接被 MoonBit 安全 API 调用（经 `ffi.mbt` 间接）

**为何需要 wrapper 而非直接 `extern "c"` 声明 stb_image**：
- stb_image 的 `stbi_load` 返回 `unsigned char*` 并通过 `int*` 输出参数返回 width/height/channels，这一 ABI 不能直接映射到 MoonBit 的值语义
- 拷贝 + 释放的 ownership 转移必须在 C 侧完成（MoonBit 侧无法直接 `stbi_image_free` 一个 C 指针）
- 集中在 wrapper 中处理 ABI 归一化，让 `ffi.mbt` 声明保持简单

### 3.5 Vendoring 脚本 — 可重复构建抽象

**角色**：Vendoring 层的流程抽象，将"获取上游 C 源码"这一外部依赖固化。

**职责**：
- 下载 pinned 版本的 `stb_image.h`（按 git commit hash 固定，SHA256 校验）
- 将头文件复制到 `src/` 目录（按 make-moonbit-c-bindings 模板的扁平化命名约定）
- 刷新 `moon.pkg` 的 `native-stub` 受管块
- 幂等：重复运行无 tracked diff
- 失败时非零退出，不自动回退
- 预留多文件扩展能力（`--include-write` 参数，供 v0.2 纳入 `stb_image_write.h`）

**协作**：
- 被 CI 或开发者手动调用
- 读写 `src/` 目录与 `moon.pkg` 文件
- 不参与编译流程

**类型形态选择**：Python 脚本（非 MoonBit 代码）。理由：vendoring 是构建期流程，在 MoonBit 编译之前发生；用 Python 跨语言脚本符合 make-moonbit-c-bindings skill 模板惯例，且 Python 跨平台可移植性优于 shell。

---

## 四、关键行为契约

### 4.1 加载契约（happy path）

**场景**：调用者提供有效路径或字节序列，期望得到 `Image`。

**契约**：
- `load_from_path(path)`：若 `path` 指向一个可读的、stb_image 支持格式的有效图像文件，返回 `Image`，其 `width`/`height`/`channels` 为图像原始维度与原始通道数，`data` 长度为 `width * height * channels`，像素数据为 8-bit
- `load_from_bytes(data)`：若 `data` 是一个 stb_image 支持格式的有效图像编码，返回 `Image`，语义同上
- 两个入口的解码语义等价：同一图像的文件内容与 `load_from_path` 读取的字节应产生相同的 `Image`（浮点精度差异除外，MVP 仅 8-bit 无此问题）
- 通道数保留原始值（1/2/3/4），不做归一化；调用者决定是否转换
- 返回后，C 侧不持有任何指向输入或输出的指针（所有权完全转移至 MoonBit GC）

### 4.2 加载契约（error path）

**场景**：调用者提供无效输入，期望得到 `LoadError`。

`LoadError` 的三个构造子（`FileIO` / `UnsupportedFormat` / `DecodeFailed`）是**完整库目标的语义意图**——表达"加载图像"操作中可向调用者暴露的三类失败类别。MVP 阶段受限于 stb_image 的失败语义（仅返回 NULL，无原因区分），三类错误的**实际可达区分粒度**如下，调用者应基于此实际契约编写错误处理代码。

#### 4.2.1 完整库目标（语义意图）

| 错误类别 | 构造子 | 语义意图的触发条件 |
|---------|--------|------------------|
| 文件 IO 失败 | `FileIO(String)` | path 入口：文件不存在、不可读、权限不足 |
| 格式不支持 | `UnsupportedFormat(String)` | stb_image 无法识别字节序列的图像格式 |
| 解码失败 | `DecodeFailed(String)` | 格式可识别但数据损坏、不完整、或违反格式约束 |

#### 4.2.2 MVP 实际契约

MVP 阶段 stb_image 失败时仅返回 NULL 指针，无失败原因字符串（`stbi_failure_reason` 未暴露）。安全 API 层可达的错误区分粒度为：

- **`FileIO` 可独立区分**：path 入口在调用 FFI 前可预检查文件可读性（或由 C wrapper 在 `stbi_load` 返回 NULL 时辅以 `errno`/平台 IO 错误检查），将"文件系统层失败"与"解码层失败"分离。`load_from_bytes` 入口不产生 `FileIO`。
- **`UnsupportedFormat` 与 `DecodeFailed` 在 MVP 阶段不可精确区分**：两者在 stb_image 侧均表现为 NULL 返回，无附加信号。MVP 约定**默认归类为 `DecodeFailed`**，理由：
  - "格式不支持"本质是"字节序列不符合任何已知格式的解码约束"，是"解码失败"的广义形式，归入 `DecodeFailed` 语义自洽
  - 调用者对 `DecodeFailed` 的典型处理（重新获取源文件、报告输入无效）对"格式不支持"场景同样适用，不会产生误导性处理差异
  - 保留 `UnsupportedFormat` 构造子是为了 v0.3 暴露 `stbi_failure_reason` 后能精确区分，避免届时破坏性地新增构造子；MVP 阶段安全 API 层不主动构造 `UnsupportedFormat`（除非未来引入格式签名预嗅探机制，见下文）
- **可选的格式嗅探增强**：技术设计阶段可评估在安全 API 层增加轻量格式签名预检查（如检查 PNG 的 8 字节魔数 `\x89PNG\r\n\x1a\n`、JPEG 的 `0xFFD8` 等），对 9 种支持格式做嗅探级区分——嗅探失败 → `UnsupportedFormat`，嗅探通过但 stb_image 返回 NULL → `DecodeFailed`。此增强不依赖 `stbi_failure_reason`，可在 MVP 内实现，但增加安全 API 层的格式知识负担。是否纳入由技术设计权衡（见设计决策 D2）。

#### 4.2.3 错误描述字符串

- 错误描述字符串为**人类可读的中文提示**（符合项目交互语言偏好），不暴露 C 错误码或 `stbi_failure_reason` 原始字符串（MVP 阶段性限制）
- 示例：`FileIO("文件不存在: /path/to/missing.png")`、`DecodeFailed("stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据")`
- v0.3 暴露 `stbi_failure_reason` 后，可将 C 侧原因字符串附加至描述，届时可重新评估 `UnsupportedFormat` 的精确构造

#### 4.2.4 内存安全契约

任何失败情况下，C 侧不泄漏内存（即使解码中途失败，wrapper 负责清理临时分配）；MoonBit 侧不直接 `free` 任何 C 指针。

### 4.3 FFI 边界契约

**场景**：安全 API 层调用 FFI 边界层。

**契约**：
- 输入 `Bytes` 用 `#borrow`：C 侧仅在调用期间读取，不存储引用；调用返回后 MoonBit 侧的 `Bytes` 仍有效
- 输出 `Bytes` 由 C wrapper 通过 `moonbit_make_bytes` 创建，所有权归 MoonBit GC；C 侧的原始缓冲在拷贝后立即 `stbi_image_free`
- **失败信号**：C wrapper 在 stb_image 返回 NULL 时，向 MoonBit 侧返回 NULL 指针（或零长度 `Bytes`），width/height/channels 输出参数写入 0。安全 API 层检查该信号（返回的 `Bytes` 为空或 width==0）并 `raise LoadError`。此为唯一的失败信号方案，与设计决策 D2 一致。注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号
- 内存安全：无论成功或失败，C 侧分配的所有临时缓冲都被释放；MoonBit 侧不直接 `free` 任何 C 指针
- **路径编码提示**：`load_from_path` 的 `path : String` 在 MoonBit 侧为 UTF-8，传递到 C 侧 `stbi_load(const char*)` 时按平台惯例转换。Windows 上非 ASCII 路径可利用 stb_image.h 提供的 `STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）或调用 `stbi_convert_wchar_to_utf8` 将 `wchar_t*` 转为 UTF-8 后传递，亦可在 C wrapper 侧用平台 `fopen` 宽字符包装处理——此为 C wrapper 的实现细节，架构层仅提示技术设计需评估 Windows 路径编码兼容性（见设计决策 D2）

### 4.4 Vendoring 契约

**场景**：CI 或开发者运行 `scripts/prepare.py`。

**契约**：
- 下载的 `stb_image.h` 的 SHA256 必须与脚本中硬编码的期望值匹配，否则非零退出
- 重复运行脚本，`src/` 下 vendored 文件与 `moon.pkg` 的 native-stub 列表无变化（幂等）
- 脚本不自动回退到其他版本：哈希不匹配即失败，强制开发者显式更新 pinned 版本
- `--include-write` 参数（预留）：运行时额外 vendoring `stb_image_write.h`，供 v0.2 使用

---

## 五、错误处理策略

### 整体策略

采用 MoonBit 检查式错误（`suberror` + `raise`），不使用 `Result`/`Option` 作为正常返回值的错误载体。理由：符合 MoonBit 惯例，且加载失败是"异常路径"而非"常规分支"，用 `raise` 让正常路径的代码更简洁。

### 错误分类

| 错误类别 | 构造子 | 语义意图触发场景 | MVP 可达性 |
|---------|--------|----------------|-----------|
| 文件 IO 失败 | `FileIO(String)` | path 入口：文件不存在、不可读、权限不足 | 可独立区分（path 入口预检查或 C wrapper 辅以平台 IO 错误） |
| 格式不支持 | `UnsupportedFormat(String)` | stb_image 无法识别字节序列的图像格式 | MVP 阶段不可与 `DecodeFailed` 精确区分；默认归入 `DecodeFailed`；可选格式嗅探增强可部分达成 |
| 解码失败 | `DecodeFailed(String)` | 格式可识别但数据损坏、不完整、或违反格式约束 | MVP 阶段作为 NULL 返回的默认归类 |

### 错误层级决策

- **统一并入 `LoadError`**：文件 IO 失败不复用标准库 `IOError`，而是作为 `LoadError::FileIO` 的一个构造子。理由：调用者面对的是"加载图像"这一单一领域操作，错误处理只需匹配 `LoadError` 一个类型；若同时暴露 `IOError` 与 `LoadError`，调用者需 `catch` 两层，增加心智负担且无实际收益（MVP 的 IO 失败场景简单，不需要 `IOError` 的细粒度）
- **不嵌套错误**：`LoadError` 不包含 `cause : Error` 字段。理由：MVP 的失败原因链路简单（C 返回 NULL → MoonBit raise），无多层包装需求

### FFI 错误信号机制

C wrapper 与安全 API 层之间的失败信号约定（设计决策 D2）：
- **方案**：C wrapper 在 stb_image 返回 NULL 时，向 MoonBit 侧返回 NULL 指针（输出参数 width/height/channels 写入 0）；安全 API 层检查返回的 `Bytes` 是否为空（或检查 width==0）并 `raise`
- **不采用**：通过 `Ref[Int]` 输出错误码——增加 FFI 参数复杂度，且 MVP 不需要区分 C 侧的失败原因
- **不采用**：抛出 C 异常——C 无异常机制，且 stb_image 本身仅返回 NULL

### 不暴露的内容

- C 错误码（stb_image 本身不返回错误码）
- `stbi_failure_reason()` 的原始 C 字符串（MVP 阶段性限制，v0.3 可选暴露）
- C 层的 `errno` 或系统错误码（文件 IO 失败仅描述为字符串）

---

## 六、并发设计

MVP 不涉及并发设计。

- stb_image 是同步 C 库，所有 load 操作在调用线程同步完成
- MoonBit native 后端的 FFI 调用是同步的，不引入异步运行时
- 无共享可变状态：每次 `load_from_*` 调用是独立的，不共享 C 侧全局状态（stb_image 的配置 API 如 `stbi_set_flip_vertically_on_load` 是全局状态，但 MVP 不暴露）
- 完整库版本若暴露 thread-local 配置（v0.3 的 `set_unpremultiply_on_load` thread-local 变体），需评估 MoonBit native 后端的线程模型与 stb_image thread-local 的交互——此为 v0.3 设计议题，MVP 不预设

---

## 七、设计决策

### D1. `LoadError` 统一并入文件 IO 失败，不复用标准库 `IOError`

**决策**：`LoadError` 包含 `FileIO(String)` 构造子，path 入口的文件不存在/不可读统一 `raise LoadError::FileIO(...)`。

**理由**：调用者面对"加载图像"单一领域操作，只需匹配一个 `LoadError` 类型。若同时暴露 `IOError` 与 `LoadError`，调用者需 `catch` 两层，心智负担增加而无实际收益（MVP 的 IO 失败场景简单）。

**权衡**：失去与标准库 `IOError` 的互操作——若调用者上层有通用 IO 错误处理逻辑，需额外 `match LoadError::FileIO(s) => raise IOError::...(s)` 转换。MVP 判断这一场景不常见，可接受。

### D2. C wrapper 错误信号：返回 NULL + 零尺寸输出参数；MVP 默认归类 `DecodeFailed`；可选格式嗅探增强

**决策**：
1. C wrapper 在 stb_image 返回 NULL 时，向 MoonBit 侧返回 NULL 指针（`moonbit_make_bytes(0, 0)` 或直接返回 NULL），width/height/channels 输出参数写入 0。安全 API 层检查返回的 `Bytes` 是否为空并 `raise LoadError`。注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需主动写入 0 以统一失败信号。
2. MVP 阶段 NULL 返回时，安全 API 层**默认 `raise LoadError::DecodeFailed(...)`**（含中文提示"stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据"）。`FileIO` 通过 path 入口的预检查（或 C wrapper 辅以平台 IO 错误）独立区分。
3. **可选的格式嗅探增强**：技术设计阶段可评估在安全 API 层增加轻量格式签名预检查（检查 9 种支持格式的魔数/文件头签名），嗅探失败 → `raise UnsupportedFormat`，嗅探通过但 stb_image 返回 NULL → `raise DecodeFailed`。此增强不依赖 `stbi_failure_reason`，可在 MVP 内实现，但增加安全 API 层的格式知识负担（需维护 9 种格式的签名表）。是否纳入由技术设计权衡复杂度与区分收益。
4. **Windows 路径编码**：技术设计阶段需评估 `load_from_path` 在 Windows 上非 ASCII 路径的兼容性。C wrapper 可在 `stbi_load` 返回 NULL 时辅以平台 IO 错误检查（如 Windows 的 `GetLastError` / `_wfopen`）以区分 `FileIO` 与解码失败；非 ASCII 路径可利用 stb_image.h 提供的 `STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）或调用 `stbi_convert_wchar_to_utf8` 将 `wchar_t*` 转为 UTF-8 后传递。此为 C wrapper 实现细节，架构层仅提示。

**理由**：
- stb_image 的失败信号本身就是"返回 NULL"，wrapper 忠实传递这一信号即可，无需发明额外的错误码通道。MoonBit 侧检查空 `Bytes` 是廉价操作
- 默认归类 `DecodeFailed` 而非 `UnsupportedFormat`：前者语义更广义（"格式不支持"是"解码失败"的子情形），且调用者对两者的典型处理（重新获取源文件、报告输入无效）一致，不会产生误导性处理差异
- 保留 `UnsupportedFormat` 构造子是为了 v0.3 暴露 `stbi_failure_reason` 后能精确区分，避免届时破坏性地新增构造子

**权衡**：
- 无法在 MoonBit 侧精确区分"格式不支持"与"数据损坏"——两者都表现为 NULL 返回。MVP 接受这一损失。v0.3 暴露 `stbi_failure_reason` 后可改进
- 格式嗅探增强若纳入，可将"格式不支持"从"解码失败"中部分分离，但嗅探本身可能误判（如格式签名正确但数据损坏，嗅探通过 → `DecodeFailed`，符合预期；如格式签名错误但实际是 stb_image 支持的某种边缘编码，嗅探失败 → `UnsupportedFormat`，可能误归）。技术设计需评估嗅探的精确度
- 默认归类策略（`DecodeFailed`）是 MVP 的约定，v0.3 暴露 `stbi_failure_reason` 后可重新评估归类策略，届时可基于 C 侧原因字符串精确构造 `UnsupportedFormat` 或 `DecodeFailed`

### D3. `Image` 导出级别 `pub(all)`，derive `Eq`/`@debug.Debug`

**决策**：`Image` 为 `pub(all) struct`，derive `Eq` 与 `@debug.Debug`，不 derive `Show`。

**理由**：
- `pub(all)`：允许外部构造与字段访问。完整库的 write 路径需接收 `Image` 作为输入，调用者也可能从其他来源拼装 `Image`（如手动构造测试 fixture）
- `Eq`：支持测试断言（`assert_eq(loaded, expected)`）
- `@debug.Debug`：支持 `debug_inspect` 用于测试快照与调试输出
- 不 derive `Show`：`Image.data` 可能很大，`Show` 的完整字符串化不适用；调试用 `Debug` 即可

### D4. 测试图片 vendoring 到 `testdata/`，由脚本生成小尺寸样本

**决策**：测试图片放入 `testdata/` 目录，由 `scripts/prepare.py`（或独立的 `scripts/gen_testdata.py`）生成小尺寸样本（如 4×4 纯色 PNG/JPEG/BMP/GIF/WebP），损坏样本通过对正常样本施加字节破坏生成。

**理由**：
- 脚本生成避免下载外部图片的版权与可重复性问题
- 小尺寸样本（4×4 或 8×8）足以覆盖解码逻辑，且测试快
- 损坏样本可确定性生成（如截断、翻转关键字节），覆盖 error path
- vendoring 到 `testdata/` 让测试自包含，无需网络

**权衡**：脚本生成的样本可能无法覆盖真实图片的某些边缘情况（如 JPEG 的多种采样因子）。MVP 接受这一风险，后续版本可补充从公开测试图片库下载的样本（固定哈希）。

### D5. vendoring 的 stb_image.h 版本：固定为近期稳定 commit

**决策**：`scripts/prepare.py` 中硬编码 `stb_image.h` 的 git commit hash（建议选 nothings/stb 仓库近 6 个月内标记为 release 的 commit），附 SHA256 校验。

**理由**：stb_image.h 无正式版本号，commit hash 是最精确的版本标识。选近期稳定 commit 平衡"新功能/修复"与"已验证稳定性"。

**权衡**：commit hash 不如语义版本号直观。脚本中应附注释记录 commit 日期与上游 release tag（若存在），供维护者理解。

### D6. `SKILL.md` 内容结构：参照 `.codeartsdoer/skills` 下 SKILL.md 格式

**决策**：包根目录的 `SKILL.md` 参照项目 `.codeartsdoer/skills` 下各技能的 SKILL.md 格式（YAML frontmatter + Markdown 正文），内容覆盖：包用途、快速开始、API 概览、最小示例、错误处理、目标后端限制、版本演进路线。

**理由**：与项目既有技能格式一致，便于复用工具链；`SKILL.md` 作为"包使用说明/技能文档"的角色在需求文档中已明确。

### D7. 版本迭代的包结构策略：MVP 单包，v0.2 评估后倾向保持单包按文件分职责

**决策**：MVP 单包（`src/`）。v0.2 纳入 write 时，倾向保持单包，通过文件名分职责（`image_load.mbt` / `image_write.mbt` / `image_info.mbt`），而非拆 `src/read/` + `src/write/` 子包。

**理由**：
- FFI 边界层共享同一 `wrapper.c` 与 vendored 头文件，物理上同居 `src/`，拆包需重复配置 native-stub
- `Image`/`LoadError` 等类型 read/write 共用，拆包需提取到 `src/common/` 子包，增加导入复杂度
- 单包内按文件分职责已足够组织代码，MoonBit 文件名纯组织性、不创建命名空间
- 拆包的收益（独立版本化、独立可见性控制）在当前规模下不显著

**权衡**：若完整库 API 面显著增长（v0.4+），单包可能过于庞大。届时可重新评估拆包，但拆分边界应基于"FFI 边界层 vs 安全 API 层"或"read vs write"而非细粒度功能。

### D8. 16-bit / float 数据的 `Bytes` 编码：little-endian

**决策**：v0.3 的 `Image16.data`（`UInt16` 序列）与 `ImageF.data`（`Float` 序列）以 little-endian 字节序存放于 `Bytes`。

**理由**：
- little-endian 是 x86/ARM 等主流平台的原生字节序，C wrapper 可直接 `memcpy` 而无需字节序转换，零开销
- MoonBit native 后端运行在 little-endian 平台（x86_64/aarch64），与 C 侧一致
- 文档化字节序后，调用者可明确解码（`Bytes` 索引 0..1 为第一个 `UInt16` 的低/高字节）

**权衡**：若未来支持 big-endian 平台（如某些嵌入式场景），需在 wrapper 中加字节序转换。MVP 不考虑该场景。

### D9. `IoCallbacks` trait 设计：留待 v0.4，映射 stb_image 的 read/skip/eof 语义

**决策**：v0.4 引入 `IoCallbacks` trait，映射 stb_image 的 `stbi_io_callbacks`（read/skip/eof）语义。MVP 不预设其具体签名，但确立设计方向：trait 方法对应 C 的三个回调，read 返回实际读取字节数，skip 支持负值（unget），eof 返回 `Bool`。

**理由**：v0.4 的 callbacks 涉及 C→MoonBit 反向调用（trampoline），需 `moonbit_incref`/`moonbit_decref` 管理回调状态生命周期，复杂度高于 MVP 的正向 FFI。留待 v0.4 专项设计，MVP 不引入该抽象。

### D10. 多目标支持路径：留待 v1.0 评估，不预设

**决策**：MVP 仅 native 目标。v1.0 评估 wasm/js 目标支持路径（Emscripten + wasm 导入 / js + wasm / 纯 MoonBit 实现 / wasm-gc C FFI 可行性），不预设答案。

**理由**：多目标支持是重大设计决策，涉及构建链集成、ABI 差异、性能权衡，需独立评估。MVP 的 native-only 限制通过 `moon.mod` 的 `preferred_target = "native"` 与 `moon.pkg` 的 `targets` 门控实现，不阻碍后续扩展。

### D11. 零拷贝可行性：留待 v1.0 评估

**决策**：MVP 允许解码后从 C 缓冲拷贝到 MoonBit `Bytes`。v1.0 评估零拷贝路径（如直接暴露 C 指针包装的 `Bytes` 视图）的可行性与收益。

**理由**：零拷贝需权衡 MoonBit GC 与 C 分配的边界安全，复杂度高。MVP 的拷贝路径简单可靠，性能损失在解码本身（远大于拷贝）面前可忽略。v1.0 在性能基准测试的指导下评估零拷贝的收益是否值得复杂度。

### D12. write 端回调设计：留待 v0.2，与 load 端 `IoCallbacks` 对偶但独立设计

**决策**：v0.2 的 `write_*_to_bytes` 基于 `stbi_write_*_to_func` 回调写入，MoonBit 侧设计回调机制将 C 侧的写入回调转换为 `Bytes` 累积（动态缓冲 + 容量扩展）。此设计与 D9 的 load 端 `IoCallbacks` 对偶（read vs write），但方向相反，独立设计。

**理由**：write 回调是 C→MoonBit 的数据流（C 产生数据，MoonBit 累积），与 load 回调（MoonBit 产生数据，C 消费）方向相反，需独立的缓冲管理策略。v0.2 专项设计，MVP 不涉及。

### D13. `ffi.mbt` 门控 native，`image.mbt` 类型定义全后端可用但 FFI 调用条件编译

**决策**：`ffi.mbt` 通过 `moon.pkg` 的 `targets: ["ffi.mbt": ["native"]]` 门控到 native。`image.mbt` 的类型定义（`Image`/`LoadError`）在所有后端可见，但 FFI 调用部分通过条件编译或文件门控限制到 native。注：`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准。

**理由**：
- 类型定义全后端可用：让 `Image`/`LoadError` 可被其他后端的代码引用（如 wasm 目标的纯 MoonBit 代码可构造 `LoadError` 用于错误处理）
- FFI 调用仅 native：`extern "c"` 仅 native 后端支持，其他后端调用 FFI 需报编译错误
- 具体实现方式（单文件内条件编译 vs 拆 `image_types.mbt` + `image_load_native.mbt`）留待技术设计

### D14. `extern "c"` 大小写：统一为小写 `extern "c"`

**决策**：本项目统一使用小写 `extern "c"`（与 make-moonbit-c-bindings skill 模板一致）。

**理由**：skill 模板使用小写，保持一致性便于工具复用。MoonBit 官方文档用大写 `extern "C"`，两者均接受；技术设计阶段可在 skill 模板与官方文档之间选择，本设计不强制。

---

## 八、与需求文档决策点的对应

| 需求文档决策点 | 本设计决策 | 说明 |
|--------------|----------|------|
| 1. `LoadError` 构造子与层级 | D1 | 统一并入 `LoadError`，不复用 `IOError` |
| 2. C wrapper 错误信号机制 | D2 | 返回 NULL + 零尺寸输出参数；MVP 默认归类 `DecodeFailed`；可选格式嗅探增强；提示 Windows 路径编码 |
| 3. `Image` struct 导出级别 | D3 | `pub(all)`，derive `Eq`/`@debug.Debug` |
| 4. 测试图片取得方式 | D4 | 脚本生成小尺寸样本，vendoring 到 `testdata/` |
| 5. vendoring 的 stb_image.h 版本 | D5 | 固定近期稳定 commit hash + SHA256 |
| 6. `SKILL.md` 内容结构 | D6 | 参照 `.codeartsdoer/skills` 下 SKILL.md 格式 |
| 7. 版本迭代的包结构策略 | D7 | MVP 单包，v0.2 倾向保持单包按文件分职责 |
| 8. 16-bit/float 数据的 `Bytes` 编码 | D8 | little-endian |
| 9. `IoCallbacks` trait 设计 | D9 | 留待 v0.4，映射 read/skip/eof 语义 |
| 10. 多目标支持路径选择 | D10 | 留待 v1.0 评估，不预设 |
| 11. 零拷贝可行性评估 | D11 | 留待 v1.0 评估 |
| 12. write 端回调设计 | D12 | 留待 v0.2，与 load 端对偶但独立设计 |

---

## 九、设计原则遵循说明

- **聚焦职责和抽象**：每个抽象的角色与职责用自然语言描述，未列出完整字段/方法签名
- **抽象层次适当**：类型形态选择（`struct` vs `enum` vs `suberror` vs `type`）仅在影响设计语义时讨论（如 `Image` 为何用 `struct` 而非 `type`）
- **协作优于结构**：每个抽象的"协作"小节描述交互关系，而非静态成员列表
- **可行性**：所有设计在 MoonBit v0.10.5 类型系统与 native FFI 能力范围内（`suberror`/`raise`/`struct`/`extern "c"`/`#borrow`/`moon.pkg` targets 门控均已核实）
- **单一职责**：四层架构每层职责内聚；`Image` 只承载数据，`LoadError` 只承载错误，FFI 边界层只处理跨语言脏工作
- **接口隔离**：FFI 边界层通过私有 `extern "c"` 声明与安全 API 层隔离；安全 API 层通过 `pub` 暴露的 `load_from_*` 函数与调用者隔离

---

## 修订说明（v2）

| 审查意见 | 修改措施 |
|---------|---------|
| **问题 1（主要）**：4.2 节错误路径契约与 D2 权衡不一致。4.2 节承诺三种可区分的错误类别（`FileIO`/`UnsupportedFormat`/`DecodeFailed`）及其触发条件，但 D2 明确指出 MVP 阶段无法区分 `UnsupportedFormat` 与 `DecodeFailed`（stb_image 失败时仅返回 NULL）。4.2 节未注明此实现限制，也未说明 NULL 返回时的默认归类策略 | 重写 4.2 节为四个子节：4.2.1 完整库目标（语义意图）——保留三构造子的语义意图表；4.2.2 MVP 实际契约——明确 `FileIO` 可独立区分、`UnsupportedFormat` 与 `DecodeFailed` 不可精确区分并约定**默认归类 `DecodeFailed`**（附理由）、提出可选格式嗅探增强作为部分达成路径；4.2.3 错误描述字符串——明确中文提示与示例；4.2.4 内存安全契约。同步修订 3.2 节增加"MVP 阶段区分粒度"说明段，修订第五节错误分类表增加"MVP 可达性"列，修订 D2 决策增加默认归类策略、格式嗅探增强、Windows 路径编码提示三个子点，修订第八节对应表 D2 行 |
| **轻微问题 1**：3.4 节描述失败信号为"NULL 指针或负数尺寸"（两种可能），D2 明确选择"NULL 指针 + 零尺寸输出参数"（一种具体方案），表述不统一 | 3.4 节失败信号描述统一为"NULL 指针 + 零尺寸输出参数（width/height/channels 写入 0）"，与 D2 一致；4.3 节 FFI 边界契约的失败信号描述同步统一，并明确标注"此为唯一的失败信号方案，与设计决策 D2 一致" |
| **轻微问题 2**：4.2 节"错误描述字符串为人类可读的英文/中文提示"中"英文/中文"的选择未明确 | 4.2.3 节明确错误描述字符串为**中文提示**（符合项目交互语言偏好），给出 `FileIO`/`DecodeFailed` 的示例字符串，并说明 v0.3 暴露 `stbi_failure_reason` 后可附加 C 侧原因 |
| **轻微问题 3**：设计未明确 `load_from_path` 的 path 参数在 Windows 上的编码处理 | 4.3 节 FFI 边界契约增加"路径编码提示"条目，说明 MoonBit `String`（UTF-8）到 C `const char*` 的平台惯例转换与 Windows 非 ASCII 路径的宽字符处理需求；D2 决策增加第 4 子点"Windows 路径编码"，提示技术设计阶段需评估 Windows 兼容性 |

---

## 修订说明（v3）

> 修订依据：`deliberations/202608060855_design-v2-review/output_v1.md`（7 维度独立审查报告）
> 修订日期：2026-08-06
> 修订范围：3 个问题（1 个轻微技术性错误 + 2 个可改进细节），均不影响架构整体成立

| 审查问题 | 问题性质 | 修订位置 | 修订措施 |
|---------|---------|---------|---------|
| **问题 1**：4.3 节 `stbi_load_16` 与宽字符路径混淆。`stbi_load_16` 是 16-bit 像素深度的 load 接口（返回 `unsigned short*`），与宽字符路径（`wchar_t`）无关，原文将其列为 Windows 非 ASCII 路径处理方案之一属技术性事实错误 | 轻微技术性错误 | 3.4 节 C Wrapper 职责（路径编码提示条目）、4.3 节 FFI 边界契约（路径编码提示条目）、D2 决策第 4 子点（Windows 路径编码） | 将 `stbi_load_16` 表述替换为 stb_image.h 实际提供的 Windows UTF-8 支持机制：`STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）+ `stbi_convert_wchar_to_utf8` 转换函数。已 webfetch 核实 stb_image.h v2.30 上游 |
| **问题 2**：失败信号"写入 0"的来源未澄清。多处表述"width/height/channels 输出参数写入 0"作为失败信号，但未明确这是 C wrapper 的主动行为还是 stb_image 的自然行为。stb_image 失败时输出参数保持不变（非写入 0），"写入 0"是 C wrapper 需主动执行的约定行为 | 可改进细节 | 3.4 节 C Wrapper 职责（失败信号条目）、4.3 节 FFI 边界契约（失败信号条目）、D2 决策第 1 子点 | 在三处增加澄清句："注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号"。避免技术设计阶段实现者误以为 stb_image 已写入 0 而省略 wrapper 的主动写入步骤 |
| **问题 3**：`supported_targets` 语法提示缺失。req.md 提到 `supported_targets = "native"`，但实际 v0.10.5 规范先例使用 `supported_targets = "+native"`（带 `+` 前缀表示追加语义）。已核实 14 处先例均使用 `"+native"` 形式 | 可改进细节 | D13 决策 | 在 D13 决策末尾增加提示："注：`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准"。避免技术设计阶段沿用 req.md 的 `"native"` 表述而导致配置不生效 |

**未修订部分**：审查报告确认通过的 7 个维度（需求响应充分度、OOD 质量、FFI 架构合理性、MoonBit v0.10.5 规范一致性、版本迭代架构支撑、自包含性、可支撑下游）的相关内容均保留原样，不引入无关变更。既有约束（架构级 OOD 定位、"只参考不引用已有库"、MoonBit v0.10.5 规范、版本迭代架构支撑）均保留。