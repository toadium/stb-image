# 计划审查报告（v2 r3）

## 审查结果
APPROVED

## 发现
经独立审查 task_v2.md（FFI 边界层任务指令），并交叉验证 moonbit.h API、MoonBit ffi.md 官方语法、R1 产出状态，未发现严重或一般问题。以下为审查中验证的关键技术点与轻微观察：

**验证项**：
1. **`#borrow` 语法形式**（task_v2.md:55-73）：与 `moonbit_wiki/language/ffi.md` 第 444-446 行官方语法一致——`#borrow(params..)` 作为独立属性标注放在 `extern "c" fn` 声明之前，函数末尾 `= "symbol_name"` 显式指定 C 符号名。v2 r2 修订已正确修正 v2 r1 引入的语法错误。
2. **moonbit.h API 存在性**：`moonbit_make_bytes(int32_t size, int value)`（moonbit.h:269）与 `MOONBIT_FFI_EXPORT`（moonbit.h:50/53）均已核实存在，task_v2.md 引用准确。
3. **前置条件一致性**：task_v2.md 声明 `src/stb_image.h` 必须已存在；实际检查确认该文件当前缺失（R1 因网络不可达未生成），前置条件声明准确反映现实状态，且给出了补救路径（运行 `python scripts/prepare.py`）。
4. **R1 产出一致性**：task_v2.md "已有代码上下文"描述 `src/moon.pkg` 为 28 字节仅 `supported_targets = "native"`；实际读取确认一致。
5. **失败信号统一契约**（task_v2.md:47-50）：wrapper.c 失败时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）而非 NULL，ffi.mbt 返回类型为 `Bytes`（非 `Bytes?`），两者匹配，规避 NULL 指针解引用段错误风险。方案自洽。
6. **NUL 结尾处理**（task_v2.md:44）：wrapper.c 内部 `malloc(path_len + 1)` + `memcpy` + `'\0'` + `free`，不依赖 MoonBit String/Bytes ABI 约定，方案安全自包含。
7. **头文件包含顺序**（task_v2.md:17-35）：`STBI_WINDOWS_UTF8` → `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → `#include <moonbit.h>` → `<string.h>`/`<stdlib.h>`，顺序正确（宏定义在 include 之前）。
8. **wrapper.c 参数类型**（task_v2.md:39,43）：`int32_t* w_ref` 等输出参数类型正确（v2 r2 已修正 v2 r1 的 `moonbit_ref_t*` 错误），与 MoonBit `Ref[Int]` 映射一致，有 `moonbitlang/async` 的 `process.c` 先例佐证。
9. **moon.pkg 单一 options 块**（task_v2.md:82-91）：`native-stub` 与 `targets` 合并到单一 `options(...)` 块，符合 MoonBit moon.pkg DSL 要求；不门控未创建文件，避免悬空引用。
10. **边界约束**（task_v2.md:141-149）：明确列出本任务不创建 R3/R4 文件、不追加悬空引用、不暴露 `stbi_failure_reason`、不处理 FileIO 与 DecodeFailed 区分（R3 职责），边界清晰。

**轻微观察**（不影响正确性，不要求修正）：
- **[轻微]** wrapper.c 中 `malloc(path_len + 1)` 失败（返回 NULL）的处理未明确说明。属 C 编程常见假设（stb_image 内部亦不处理 malloc 失败），且为实现细节，不影响 task 指令的完整性与自包含性。
- **[轻微]** task_v2.md 未给出 wrapper.c 两个函数的完整 C 代码，仅给出职责描述与关键步骤。此为 task 的合理粒度（描述契约而非实现），实现者可据此编码。

## 修改要求（不适用）
无严重或一般问题，无需修改。