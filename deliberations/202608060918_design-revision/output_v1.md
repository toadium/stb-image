# `design_v2.md` 全面修订摘要

> 修订对象：`D:\CodeWorkspace\forMoonbit\stb-image\designs-oo\202608060801_stb-image-arch-design\design_v2.md`
> 修订产出：`D:\CodeWorkspace\forMoonbit\stb-image\designs-oo\202608060801_stb-image-arch-design\design_v3.md`
> 修订依据：`D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060855_design-v2-review\output_v1.md`（7 维度独立审查报告）
> 修订日期：2026-08-06
> 修订框架：deliberative-execution-harness

## 修订总体结论

审查报告对 `design_v2.md` 进行了 7 维度独立审查（需求响应充分度、OOD 质量、FFI 架构合理性、MoonBit v0.10.5 规范一致性、版本迭代架构支撑、自包含性、可支撑下游），总体结论为 **[APPROVED]**，发现 **3 个需修订问题**（1 个轻微技术性错误 + 2 个可改进细节），均不影响架构整体成立。

本次修订逐项落实审查报告中的修订建议，产出 `design_v3.md`。修订保持已通过部分的稳定性，不引入无关变更；保留架构级 OOD 定位、"只参考不引用已有库"、MoonBit v0.10.5 规范、版本迭代架构支撑等既有约束。

---

## 修订问题逐项落实

### 问题 1（轻微技术性错误）：4.3 节 `stbi_load_16` 与宽字符路径混淆

**审查问题描述**：
- 位置：`design_v2.md:245`（4.3 节"路径编码提示"）
- 问题：原文将 `stbi_load_16` 列为 Windows 非 ASCII 路径的宽字符处理方案之一。`stbi_load_16` 的签名为 `stbi_us *stbi_load_16(char const *filename, int *x, int *y, int *comp, int req_comp)`，是 **16-bit 像素深度**的 load 接口（返回 `unsigned short*`），接收 `char const *` 路径，**与宽字符路径无关**。`16` 指的是像素位深度，不是宽字符（`wchar_t`）。
- 核实证据：已 webfetch 核实 stb_image.h v2.30 上游。stb_image.h 实际提供的 Windows UTF-8 路径支持机制是：编译时定义 `STBI_WINDOWS_UTF8` 宏 → `stbi__fopen` 内部使用 `_wfopen` 打开文件；或调用 `stbi_convert_wchar_to_utf8(char *buffer, size_t bufferlen, const wchar_t* input)` 将 `wchar_t*` 转为 UTF-8。

**修订措施**：将 `stbi_load_16` 表述替换为 stb_image.h 实际提供的 Windows UTF-8 支持机制。

**修订位置**：
1. `design_v3.md:245`（4.3 节 FFI 边界契约 - 路径编码提示条目）
   - 原文：`Windows 上非 ASCII 路径可能需要宽字符（`wchar_t` / `stbi_load_16` 变体或平台 `fopen` 宽字符包装）处理`
   - 修订为：`Windows 上非 ASCII 路径可利用 stb_image.h 提供的 `STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）或调用 `stbi_convert_wchar_to_utf8` 将 `wchar_t*` 转为 UTF-8 后传递，亦可在 C wrapper 侧用平台 `fopen` 宽字符包装处理`
2. `design_v3.md:320`（D2 决策第 4 子点 - Windows 路径编码）
   - 原文：`非 ASCII 路径可能需宽字符处理`
   - 修订为：`非 ASCII 路径可利用 stb_image.h 提供的 `STBI_WINDOWS_UTF8` 编译宏（内部使用 `_wfopen`）或调用 `stbi_convert_wchar_to_utf8` 将 `wchar_t*` 转为 UTF-8 后传递`

**影响评估**：不影响架构整体设计。此为 4.3 节实现提示中的事实性错误，修订后可避免技术设计阶段误导实现者尝试用 `stbi_load_16` 处理宽字符路径（错误方向）。

---

### 问题 2（可改进细节）：失败信号"写入 0"的来源未澄清

**审查问题描述**：
- 位置：`design_v2.md:154`（3.4 节）、`design_v2.md:243`（4.3 节）、`design_v2.md:317`（D2 决策）
- 问题：多处表述"width/height/channels 输出参数写入 0"作为失败信号，但未明确这是 **C wrapper 的主动行为**还是 stb_image 的自然行为。
- 核实证据：已核实 stb_image.h v2.30 上游文档明确说："If image loading fails for any reason, the return value will be NULL, and *x, *y, *channels_in_file will be **unchanged**."。即 stb_image 本身在失败时**保持输出参数不变**（而非写入 0）。`design_v2.md` 中"写入 0"是 C wrapper 需要主动执行的约定行为。

**修订措施**：在三处增加澄清句，明确"stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需主动写入 0 以统一失败信号"。

**修订位置**：
1. `design_v3.md:154`（3.4 节 C Wrapper 函数集职责 - 失败信号条目）
   - 追加：`注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号`
2. `design_v3.md:243`（4.3 节 FFI 边界契约 - 失败信号条目）
   - 追加：`注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需在 stb_image 返回 NULL 时**主动**将 width/height/channels 写入 0 以统一失败信号`
3. `design_v3.md:317`（D2 决策第 1 子点）
   - 追加：`注意：stb_image 失败时输出参数保持不变（非写入 0），C wrapper 需主动写入 0 以统一失败信号。`

**影响评估**：不影响架构整体设计。此为实现细节澄清，修订后可避免技术设计阶段的实现误解（实现者若直接阅读 stb_image.h 文档可能误以为 stb_image 已写入 0 而省略 wrapper 的主动写入步骤）。

---

### 问题 3（可改进细节）：`supported_targets` 语法提示缺失

**审查问题描述**：
- 位置：`design_v2.md:84`（引用 req.md 的配置描述）、`design_v2.md:417`（D13 决策）
- 问题：req.md 提到 `supported_targets = "native"`，但实际 v0.10.5 规范先例使用 `supported_targets = "+native"`（带 `+` 前缀表示追加语义）。
- 核实证据：已核实 14 处先例（`moonbit_wp/.mooncakes/moonbitlang/async/examples/*/moon.pkg`、`moonbit_wp/moonbit-tree-sitter/src/*/moon.pkg`）均使用 `supported_targets = "+native"` 形式，无一使用 `"native"` 形式。
- 当前状态：`design_v2.md` 本身未直接给出 `supported_targets` 的具体语法表述（仅在引用 req.md 内容时提及），不存在直接语法错误。但作为架构设计，在 D13 决策讨论目标门控时未提示这一语法细节，技术设计阶段可能沿用 req.md 的 `"native"` 表述而导致配置不生效。

**修订措施**：在 D13 决策末尾增加一句语法提示。

**修订位置**：
1. `design_v3.md:417`（D13 决策）
   - 追加：`注：`supported_targets` 的实际语法为 `"+native"`（带 `+` 前缀表示追加语义），非 `"native"`；技术设计阶段应以此为准。`

**影响评估**：不影响架构整体设计。此为语法细节提示，修订后可避免技术设计阶段的配置错误。

---

## 未修订部分（审查通过）

审查报告确认通过的 7 个维度的相关内容均保留原样，不引入无关变更：

| 审查维度 | 结论 | 保留情况 |
|---------|------|---------|
| 一、需求响应充分度 | [通过] | 完整库定位、MVP 范围、版本迭代计划、验收标准、边界约束响应均保留 |
| 二、OOD 质量 | [通过] | 四层架构职责划分、抽象层次、协作模式、14 个设计决策均保留 |
| 三、FFI 架构合理性 | [通过] | 边界划分、所有权管理、错误传递、安全封装层次均保留（仅增加失败信号来源澄清） |
| 四、MoonBit v0.10.5 规范一致性 | [通过] | moon.mod/moon.pkg 新格式、preferred_target、targets 门控、native-stub 均保留（仅增加 `supported_targets` 语法提示） |
| 五、版本迭代架构支撑 | [通过] | D7-D12 为各版本增量提供的架构落点均保留 |
| 六、自包含性 | [通过] | 不引用 mizchi/image 或任何已有库的约束保留 |
| 七、可支撑下游 | [通过] | 14 个设计决策 + 4 个行为契约 + 文件职责划分表均保留 |

---

## 既有约束保留情况

| 既有约束 | 保留情况 |
|---------|---------|
| 架构级 OOD 设计定位（职责划分、抽象层次、协作模式、关键设计决策，非具体实现细节） | ✅ 保留。修订仅涉及实现提示澄清与语法提示，未引入具体实现细节 |
| "只参考，不引用已有库"（不得引用 mizchi/image 或任何已有库作为依赖、互补基准或对比对象） | ✅ 保留。修订未引入任何已有库引用 |
| MoonBit v0.10.5 最新规范（moon.mod/moon.pkg 新格式，preferred_target 下划线语法） | ✅ 保留。修订增加的 `supported_targets` 语法提示进一步强化了 v0.10.5 规范一致性 |
| 版本迭代架构支撑 | ✅ 保留。D7-D12 及各版本演进策略均未变更 |

---

## 修订产出验证

`design_v3.md` 已通过以下验证：
1. **修订点完整性**：6 处修订（3.4 节、4.3 节失败信号、4.3 节路径编码、D2 决策第 1 子点、D2 决策第 4 子点、D13 决策）均已正确应用
2. **`stbi_load_16` 消除**：正文修订位置不再出现 `stbi_load_16` 作为宽字符路径方案（仅保留在修订说明章节中作为问题描述）
3. **`STBI_WINDOWS_UTF8` / `stbi_convert_wchar_to_utf8` 引入**：4.3 节路径编码提示与 D2 决策第 4 子点均已引入正确的 Windows UTF-8 支持机制
4. **失败信号来源澄清**：3.4 节、4.3 节、D2 决策第 1 子点均已增加"stb_image 失败时输出参数保持不变，C wrapper 需主动写入 0"澄清
5. **`supported_targets` 语法提示**：D13 决策已增加 `"+native"` 语法提示
6. **修订说明章节**：`design_v3.md` 末尾已追加"修订说明（v3）"章节，记录本次修订的 3 个问题、修订位置与修订措施
7. **既有内容保留**：审查通过的 7 个维度内容、既有约束均保留，未引入无关变更

---

## 修订产出文件

- **修订后完整架构设计文档**：`D:\CodeWorkspace\forMoonbit\stb-image\designs-oo\202608060801_stb-image-arch-design\design_v3.md`
- **本修订摘要文件**：`D:\CodeWorkspace\forMoonbit\stb-image\deliberations\202608060918_design-revision\output_v1.md`

`design_v3.md` 为完整、自包含的架构设计文档，可直接替代 `design_v2.md` 作为最终架构设计，指导后续技术设计与编码实现。