# 计划审查报告（v2 r1）

## 审查结果
REJECTED

## 发现

- **[一般]** ffi.mbt 返回类型 `Bytes` 与 wrapper.c 失败时返回 NULL 存在类型不匹配风险。task_v2.md 第 19 行明确 wrapper.c 失败时"返回 NULL（moonbit_bytes_t NULL）"，第 29-30 行 ffi.mbt 声明返回 `Bytes`（非 `Bytes?` 可选类型）。技术方案 §6.3 第 1163 行描述 R3 的失败检查方式为"检查返回的 Bytes 是否为空（或 width == 0）"——若 R3 实现者选择 `bytes.length() == 0` 路径检查而 bytes 为 NULL 指针，native 后端将段错误。技术方案 §九第 5 点已将"NULL 返回在 MoonBit 侧的表现"列为需验证的技术假设，但 task_v2.md 既未提示此风险，也未在 wrapper.c 与 ffi.mbt 之间统一失败信号方案。架构设计 D2 第 617 行给出两种合法方案（`moonbit_make_bytes(0, 0)` 或直接返回 NULL），task_v2.md 选择了风险更高的 NULL 方案却未说明理由或给出配套的 R3 检查策略约束。

- **[一般]** 网络可达性前提条件（`src/stb_image.h` 存在）未在任务描述中明确声明。code_v1.md 第 15 行明确记录 R1 因网络不可达未生成 `src/stb_image.h`。task_v2.md 仅在第 127 行验证命令注释中提及"若 `src/stb_image.h` 未生成，wrapper.c 的 `#include "stb_image.h"` 将编译失败"，但未在任务描述、前置条件或边界约束中声明此要求。wrapper.c 的 `#include "stb_image.h"` 是硬依赖，无 stb_image.h 则 `moon check --target native` 必然失败，R2 任务无法完成验证。任务指令应明确声明前置条件（"本任务要求 `src/stb_image.h` 已存在，若不存在需先运行 `python scripts/prepare.py` 生成"），或将 stb_image.h 的生成纳入本任务范围。

- **[一般]** wrapper.c 中 `stb_image_mbt_load_from_path` 的 NUL 结尾处理不够明确。task_v2.md 第 21 行给出两种方案："wrapper 内部构建 NUL 结尾缓冲"或"依赖 MoonBit String 的 NUL 结尾约定——实现时核实 MoonBit String ABI"。但 ffi.mbt 第 30 行声明的参数类型是 `path : Bytes`（非 `String`），`Bytes` 类型不保证 NUL 结尾。若实现者选择"依赖 MoonBit String 的 NUL 结尾约定"方案，而 R3 的 `load_from_path` 将 `String` 转为 `Bytes` 后传递，转换后的 `Bytes` 是否保留 NUL 结尾取决于 MoonBit 运行时实现——若不保留，`stbi_load` 将缓冲区越界读取。对于安全关键的路径处理，task 应推荐明确安全的方案（wrapper 内部始终构建 NUL 结尾副本），而非将安全选择留给实现者推断。

- **[轻微]** ffi.mbt 的 extern "c" 声明模板缺少 `#borrow` 标注的实际语法形式。task_v2.md 第 29-30 行给出的声明未包含 `#borrow`，仅在第 31 行说"输入 `Bytes` 与 `Ref[Int]` 均标注 `#borrow`"。实现者需查阅 MoonBit FFI 文档确定 `#borrow` 的正确语法位置，不影响正确性但降低 task 指令的自包含性。

- **[轻微]** wrapper.c 头文件包含顺序表述可能让实现者困惑。task_v2.md 第 13 行先列出"`#define STB_IMAGE_IMPLEMENTATION` + `#include "stb_image.h"`"，第 14 行才说"`STBI_WINDOWS_UTF8` 必须在 `#include "stb_image.h"` 之前定义"。两行均要求在 `#include` 之前定义宏，但表述顺序未给出完整的头文件排列顺序（应为 `STBI_WINDOWS_UTF8` → `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → 其他），实现者需自行推断正确顺序。

## 修改要求

1. **统一失败信号方案**（对应发现 1）：task_v2.md 应在 wrapper.c 与 ffi.mbt 之间统一失败信号处理。建议采用更安全的方案：wrapper.c 失败时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）而非 NULL，ffi.mbt 返回 `Bytes`，R3 通过 `bytes.length() == 0` 或 `w_ref.val == 0` 检查失败。若坚持返回 NULL，则应明确声明此为需验证的技术假设，并约束 R3 必须通过 `w_ref.val == 0`（而非 Bytes 长度）判断失败，避免 NULL 指针解引用。

2. **明确前置条件**（对应发现 2）：task_v2.md 应在任务描述或"任务上下文"节明确声明前置条件——"本任务要求 `src/stb_image.h` 已存在。若不存在，实现者需先运行 `python scripts/prepare.py` 生成，或确认网络可达性"。不应将此前置条件仅埋在验证命令注释中。

3. **明确 NUL 结尾处理方案**（对应发现 3）：task_v2.md 应为 `stb_image_mbt_load_from_path` 的 NUL 结尾处理给出明确推荐方案。建议 wrapper.c 内部始终构建 NUL 结尾副本（`malloc(path_len + 1)` + `memcpy` + `buf[path_len] = '\0'`），传递给 `stbi_load` 后释放，不依赖 MoonBit String/Bytes 的 ABI 约定。此方案安全、自包含，无需实现者核实 MoonBit 运行时内部表示。