# 详细设计（v2）

## 概述

本设计为 stb-image 项目的 **R2：FFI 边界层** 任务的具体实现规格。范围包括：

1. C wrapper `src/wrapper.c`（新建）：ABI 归一化 + 所有权转移 + 失败信号统一
2. MoonBit 私有 FFI 声明 `src/ffi.mbt`（新建）：两个 `extern "c" fn` 声明
3. 包配置 `src/moon.pkg`（覆写）：追加单一 `options(...)` 块（native-stub + targets 门控）

本任务是四层架构（Vendoring → FFI 边界 → 安全 API → 测试文档）的第二层，依赖 R1 已落地的 `src/stb_image.h`、`moon.mod`、`src/moon.pkg` 骨架。本任务不创建任何 MoonBit 类型定义、安全包装、测试或文档文件（R3/R4 职责）。

设计依据：需求文档 §三 FFI 实现要点、架构设计 §3.3 FFI 私有声明集 / §3.4 C Wrapper 函数集 / §4.3 FFI 边界契约 / D2 / D14、技术方案 §2.4 moonbit.h API / §5.1 C wrapper 设计 / §5.2 extern "c" 声明设计 / §5.3 Windows 路径编码 / §3.3 moon.pkg 配置、task_v2.md 全文（含 v2 r1/r2 审查修订）。

### 前置条件

- **`src/stb_image.h` 必须已存在**：wrapper.c 通过 `#include "stb_image.h"` 硬依赖。R1 因网络不可达未生成此文件。若不存在，实现者需先运行 `python scripts/prepare.py` 生成（要求网络可达 `raw.githubusercontent.com`），或确认文件存在后再编码。**本任务不得在 `src/stb_image.h` 缺失状态下提交**——`moon check --target native` 会因 `#include` 失败而编译错误。

## 文件规划

| 文件路径 | 操作 | 职责 |
|---------|------|------|
| `src/wrapper.c` | 新建 | C wrapper：ABI 归一化（stbi_load* 的 `int*` 输出参数 + `unsigned char*` 返回值 → moonbit_make_bytes + Ref[Int] 写回）、所有权转移（C 缓冲 → memcpy 到 MoonBit Bytes → stbi_image_free）、失败信号统一（NULL → 零长度 Bytes + 输出参数写 0）、Windows UTF-8 路径支持、NUL 结尾副本构建 |
| `src/ffi.mbt` | 新建 | MoonBit 私有 `extern "c" fn` 声明：两个 FFI 入口（load_from_memory / load_from_path），`#borrow` 标注输入 Bytes 与 Ref[Int]，返回 `Bytes`（非 `Bytes?`），仅 native 后端编译 |
| `src/moon.pkg` | 覆写 | 包配置（新 DSL）：保留 `supported_targets = "native"`，追加单一 `options(...)` 块承载 `native-stub: ["wrapper.c"]` 与 `targets: { "ffi.mbt": ["native"] }` |

## 类型定义

本任务无 MoonBit 类型定义（`Image` / `LoadError` 留待 R3）。以下为 C wrapper 函数与 MoonBit extern 声明的签名规格。

### C wrapper 函数签名（src/wrapper.c）

#### stb_image_mbt_load_from_memory

**形态**：C 函数（`MOONBIT_FFI_EXPORT` 导出）
**包路径**：N/A（C 源文件，由 `native-stub` 编译入 native 后端）
**职责**：从内存字节序列解码图像，ABI 归一化 stbi_load_from_memory 的输出参数与返回值

```c
MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_memory(
    moonbit_bytes_t buffer,
    int32_t len,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
);
```

**公开接口**：如上签名
**构造方式**：由 ffi.mbt 的 `extern "c" fn stb_image_mbt_load_from_memory` 调用
**类型关系**：调用 stb_image.h 的 `stbi_load_from_memory` 与 `stbi_image_free`；调用 moonbit.h 的 `moonbit_make_bytes`；调用 string.h 的 `memcpy`

**行为契约**：
- **前置条件**：`buffer` 非 NULL（MoonBit Bytes 保证），`len == Moonbit_array_length(buffer)`，`w_ref`/`h_ref`/`c_ref` 非 NULL（MoonBit Ref[Int] 保证）
- **成功路径**（`stbi_load_from_memory` 返回非 NULL）：
  1. 调用 `stbi_uc *result = stbi_load_from_memory((stbi_uc const *)buffer, len, &w, &h, &c, 0)`（desired_channels=0，返回原始通道）
  2. `moonbit_bytes_t out = moonbit_make_bytes(w * h * c, 0)` 创建输出 Bytes（MoonBit GC 接管）
  3. `memcpy(out, result, (size_t)(w * h * c))` 拷贝像素数据
  4. `stbi_image_free(result)` 释放 C 缓冲
  5. `*w_ref = w; *h_ref = h; *c_ref = c;` 写回输出参数
  6. 返回 `out`
- **失败路径**（`stbi_load_from_memory` 返回 NULL）：
  1. `*w_ref = 0; *h_ref = 0; *c_ref = 0;` 主动写入 0（stb_image 失败时输出参数保持不变，wrapper 需主动归零）
  2. 返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes，**不返回 NULL**）
- **后置条件**：无论成功失败，C 侧分配的所有临时缓冲均被释放（成功时 stbi_image_free 释放 stbi 缓冲；失败时无缓冲需释放）；MoonBit 侧不直接 free 任何 C 指针

#### stb_image_mbt_load_from_path

**形态**：C 函数（`MOONBIT_FFI_EXPORT` 导出）
**包路径**：N/A
**职责**：从文件路径解码图像，构建 NUL 结尾副本后调用 stbi_load，ABI 归一化同 load_from_memory

```c
MOONBIT_FFI_EXPORT moonbit_bytes_t stb_image_mbt_load_from_path(
    moonbit_bytes_t path_bytes,
    int32_t path_len,
    int32_t *w_ref,
    int32_t *h_ref,
    int32_t *c_ref
);
```

**公开接口**：如上签名
**构造方式**：由 ffi.mbt 的 `extern "c" fn stb_image_mbt_load_from_path` 调用
**类型关系**：调用 stb_image.h 的 `stbi_load` 与 `stbi_image_free`；调用 moonbit.h 的 `moonbit_make_bytes`；调用 string.h 的 `memcpy`；调用 stdlib.h 的 `malloc` / `free`

**行为契约**：
- **前置条件**：`path_bytes` 非 NULL，`path_len == Moonbit_array_length(path_bytes)`，`path_bytes` 为 UTF-8 编码路径（不保证 NUL 结尾），`w_ref`/`h_ref`/`c_ref` 非 NULL
- **NUL 结尾处理**（明确方案，不依赖 MoonBit Bytes ABI 约定）：
  1. `char *path_cstr = (char *)malloc((size_t)path_len + 1)` 分配副本
  2. `memcpy(path_cstr, path_bytes, (size_t)path_len)` 拷贝路径字节
  3. `path_cstr[path_len] = '\0'` 显式 NUL 结尾
  4. 调用 `stbi_uc *result = stbi_load(path_cstr, &w, &h, &c, 0)`（desired_channels=0）
  5. `free(path_cstr)` 释放副本（**无论 stbi_load 成功或失败均释放**）
- **成功路径**（`stbi_load` 返回非 NULL）：同 load_from_memory 成功路径（moonbit_make_bytes + memcpy + stbi_image_free + 写回输出参数）
- **失败路径**（`stbi_load` 返回 NULL）：同 load_from_memory 失败路径（输出参数写 0 + 返回零长度 Bytes）
- **后置条件**：无论成功失败，`path_cstr` 副本与 stbi 缓冲（若成功）均被释放；MoonBit 侧不直接 free 任何 C 指针

### C wrapper 头文件包含顺序（src/wrapper.c 顶部）

严格按以下顺序排列，避免宏定义顺序错误：

```c
/* 1. Windows UTF-8 路径支持：必须在 #include "stb_image.h" 之前定义 */
#if defined(_WIN32)
#define STBI_WINDOWS_UTF8
#endif

/* 2. stb_image 实现宏：必须在 #include "stb_image.h" 之前定义 */
#define STB_IMAGE_IMPLEMENTATION

/* 3. vendored 上游头文件（生成 stb_image 实现） */
#include "stb_image.h"

/* 4. MoonBit 运行时 API */
#include <moonbit.h>

/* 5. C 标准库（memcpy、malloc、free） */
#include <string.h>
#include <stdlib.h>
```

**顺序约束说明**：
- `STBI_WINDOWS_UTF8` 必须在 `#include "stb_image.h"` 之前定义，启用 stb_image 内部 `_wfopen` 处理 UTF-8 路径（技术方案 §5.3）
- `STB_IMAGE_IMPLEMENTATION` 必须在 `#include "stb_image.h"` 之前定义，触发 stb_image 实现体的编译（单头文件库惯例）
- `#include "stb_image.h"` 用双引号（同目录 vendored 头文件），`#include <moonbit.h>` 用尖括号（系统包含路径）
- `#include <string.h>` / `<stdlib.h>` 在最后，因 stb_image.h 内部可能定义某些宏影响标准库（防御性顺序）

### MoonBit extern 声明签名（src/ffi.mbt）

#### stb_image_mbt_load_from_memory（MoonBit 侧）

**形态**：MoonBit 私有 `extern "c" fn` 声明
**包路径**：`MoonBit-Toadium/stb-image`（src 包）
**职责**：声明 C 函数 `stb_image_mbt_load_from_memory` 的 MoonBit 侧入口

```moonbit
///|
#borrow(buffer, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_memory(
  buffer : Bytes,
  len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_memory"
```

**公开接口**：如上签名
**构造方式**：模块级声明，由 R3 的 `image_load_native.mbt` 调用
**类型关系**：对应 C 侧 `stb_image_mbt_load_from_memory`

**语法要点**：
- `#borrow(buffer, w_ref, h_ref, c_ref)` 作为**独立属性标注**放在 `extern "c" fn` 声明**之前**（非函数末尾），多个参数逗号分隔。依据 MoonBit 官方文档（`moonbit_wiki/language/ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行）与实际代码先例（`moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行、`moonbit_wp/x/fs/fs_native.mbt` 第 52 行 `#borrow(path, mode)` 在 `extern "C" fn` 之前）
- 函数末尾 `= "stb_image_mbt_load_from_memory"` 显式指定 C 符号名（先例：`moonbit_wp/x/fs/fs_native.mbt` 第 53 行 `= "moonbitlang_x_fs_fopen_ffi"`）
- `///|` 文档注释分隔符在 `#borrow` 之前（MoonBit 惯例，先例：`moonbit_wp/x/fs/fs_native.mbt` 第 51-53 行）
- 小写 `extern "c"`（架构设计 D14，与 make-moonbit-c-bindings skill 模板一致）
- **私有**：不 `pub`，仅供同包 R3 的 `image_load_native.mbt` 调用
- 返回类型 `Bytes`（非 `Bytes?`），与 wrapper.c 失败时返回零长度 Bytes 的方案匹配

#### stb_image_mbt_load_from_path（MoonBit 侧）

**形态**：MoonBit 私有 `extern "c" fn` 声明
**包路径**：`MoonBit-Toadium/stb-image`（src 包）
**职责**：声明 C 函数 `stb_image_mbt_load_from_path` 的 MoonBit 侧入口

```moonbit
///|
#borrow(path, w_ref, h_ref, c_ref)
extern "c" fn stb_image_mbt_load_from_path(
  path : Bytes,
  path_len : Int,
  w_ref : Ref[Int],
  h_ref : Ref[Int],
  c_ref : Ref[Int],
) -> Bytes = "stb_image_mbt_load_from_path"
```

**公开接口**：如上签名
**构造方式**：模块级声明，由 R3 的 `image_load_native.mbt` 调用
**类型关系**：对应 C 侧 `stb_image_mbt_load_from_path`

**语法要点**：同 `stb_image_mbt_load_from_memory`（`#borrow` 在 `extern "c" fn` 之前、`= "symbol_name"` 显式指定、小写 `extern "c"`、私有、返回 `Bytes`）

**类型映射表**（技术方案 §5.2）：

| C 类型 | MoonBit 类型 | 用途 | 所有权 |
|--------|-------------|------|--------|
| `moonbit_bytes_t`（输入 buffer） | `Bytes` | 输入像素数据/路径字节 | `#borrow`（stb 仅调用期间读取） |
| `int32_t`（len / path_len） | `Int` | Bytes 长度 | 值传递 |
| `int32_t *`（w_ref / h_ref / c_ref） | `Ref[Int]` | width/height/channels 写回 | `#borrow`（wrapper 写入，不持有） |
| `moonbit_bytes_t`（返回） | `Bytes` | 输出像素数据 / 零长度失败信号 | GC 接管（moonbit_make_bytes 创建） |

### moon.pkg 配置（src/moon.pkg）

**形态**：MoonBit 包配置（新 DSL 语法）
**职责**：声明 native-stub C 源文件与 ffi.mbt 的 native 后端门控

```
supported_targets = "native"

options(
  "native-stub": ["wrapper.c"],
  targets: {
    "ffi.mbt": ["native"],
  },
)
```

**配置要点**：
- `supported_targets = "native"`：保留 R1 已有声明，包级排他性声明仅支持 native 后端（先例：`moonbit_wp/llvm.mbt/unsafe/moon.pkg` 第 1 行）
- `options(...)` 单一块：`native-stub` 与 `targets` 合并到同一 `options(...)` 块（MoonBit moon.pkg DSL 要求，见 package-management.md:63-75 示例；先例：`moonbit_wp/llvm.mbt/unsafe/moon.pkg` 第 3-12 行单一 options 块承载 native-stub + link）
- `"native-stub": ["wrapper.c"]`：wrapper.c 列入 native-stub，仅 native 后端编译为 C 源文件
- `targets: { "ffi.mbt": ["native"] }`：ffi.mbt 门控到 native 后端（`extern "c"` 仅 native 支持）
- **不门控** `image_types.mbt` / `image_load_native.mbt` / `image_test.mbt` / `README.mbt.md`：这些文件本任务不创建，门控会致悬空引用使 `moon check` 失败（R3/R4 创建时再追加 targets 条目）
- `stb_image.h` 不列入 `native-stub`：它是头文件而非 C 源文件，由 wrapper.c 的 `#include "stb_image.h"` 纯入编译

## 错误处理

### wrapper.c 错误处理策略

- **stb_image 失败**（`stbi_load` / `stbi_load_from_memory` 返回 NULL）：wrapper 主动将 `*w_ref`/`*h_ref`/`*c_ref` 写入 0，返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）。**不返回 NULL 指针**，避免 ffi.mbt 侧 NULL 解引用段错误风险（task_v2.md v2 r1 审查发现 1 的统一方案）
- **失败信号统一契约**：wrapper.c 与 ffi.mbt 之间约定——成功时返回非零长度 Bytes + 输出参数为真实尺寸；失败时返回零长度 Bytes + 输出参数全 0。R3 通过 `bytes.length() == 0` 或 `w_ref.val == 0` 检查失败（R3 职责，本任务仅传递信号）
- **不暴露 C 错误码**：stb_image 失败时仅返回 NULL，wrapper 不调用 `stbi_failure_reason`（MVP 阶段性限制，v0.3 可选暴露）
- **不处理 errno / FileIO 区分**：wrapper 仅传递解码失败信号，FileIO 错误（路径不存在/不可读）与 DecodeFailed 的区分在 R3 的 MoonBit 侧预检查（R3 职责）
- **malloc 失败**（`stb_image_mbt_load_from_path` 的 NUL 结尾副本）：`malloc` 返回 NULL 时，C 标准库行为未定义（stbi_load 将收到 NULL 路径）。wrapper 不显式检查 malloc 返回值——此为 MVP 简化策略，假设路径长度合理不会 OOM。完整库版本可追加 malloc NULL 检查并返回失败信号

### ffi.mbt 错误处理策略

- ffi.mbt 为纯 FFI 声明，**不含任何错误处理逻辑**（无 try/catch、无 raise、无 NULL 检查）
- 错误映射（零长度 Bytes → LoadError）是 R3 的 `image_load_native.mbt` 职责
- 返回类型 `Bytes`（非 `Bytes?`）：与 wrapper.c 失败时返回零长度 Bytes 的方案匹配，ffi.mbt 侧无需处理 NULL

### moon.pkg 错误处理策略

- 配置文件无运行时错误
- `moon check --target native` 应通过：wrapper.c 的 `#include "stb_image.h"` 解析成功（前置条件：stb_image.h 存在）、ffi.mbt 的 `extern "c"` 声明有 wrapper.c 的 `MOONBIT_FFI_EXPORT` 对应符号、无悬空 targets 引用

## 行为契约

### wrapper.c 行为契约

**前置条件**：
- `src/stb_image.h` 已存在（R1 vendoring 产物，由 `python scripts/prepare.py` 生成）
- MoonBit native 后端编译环境（moon 0.1.20260713+，moonbit.h 可用）
- 调用时 `buffer` / `path_bytes` 为有效 MoonBit Bytes，`len` / `path_len` 等于其长度，`w_ref` / `h_ref` / `c_ref` 为有效 Ref[Int]

**后置条件（成功路径）**：
- 返回的 `moonbit_bytes_t` 长度为 `w * h * c`，内容为 stb_image 解码的像素数据
- `*w_ref` / `*h_ref` / `*c_ref` 为图像真实宽高通道数
- C 侧 stbi 缓冲已释放（`stbi_image_free`），MoonBit Bytes 由 GC 接管

**后置条件（失败路径）**：
- 返回的 `moonbit_bytes_t` 长度为 0（`moonbit_make_bytes(0, 0)`）
- `*w_ref` = `*h_ref` = `*c_ref` = 0
- 无 C 缓冲泄漏（stbi_load 失败时不分配缓冲；path 副本已 free）

**内存安全契约**：
- 无论成功或失败，C 侧分配的所有临时缓冲均被释放：
  - `stb_image_mbt_load_from_memory`：成功时 `stbi_image_free(result)`；失败时无缓冲需释放
  - `stb_image_mbt_load_from_path`：`free(path_cstr)` 释放 NUL 结尾副本（无论 stbi_load 成功失败）；成功时 `stbi_image_free(result)`
- MoonBit 侧不直接 `free` 任何 C 指针（所有权单向：C 分配 → memcpy 到 MoonBit → C 释放原缓冲 → MoonBit GC 管理拷贝）

**ABI 归一化契约**：
- `stbi_load` / `stbi_load_from_memory` 的 `int *x, int *y, int *channels_in_file` 输出参数 → wrapper 内部 `int w, h, c` 局部变量接收 → 写入 `int32_t *w_ref, h_ref, c_ref` 输出参数（MoonBit Ref[Int] 在 native 后端映射为 `int32_t*`，先例：`moonbitlang/async` 的 `process.c` 第 41 行 `int *out` 对应 MoonBit `out : Ref[Int]`）
- `stbi_uc *` 返回值 → `moonbit_make_bytes(w*h*c, 0)` 创建 MoonBit Bytes + `memcpy` 拷贝
- `desired_channels` 传 0（STBI_default，返回原始通道，不强制转换）

### ffi.mbt 行为契约

**前置条件**：
- 仅 native 后端编译（`moon.pkg` 的 `targets: { "ffi.mbt": ["native"] }` 门控）
- 调用者（R3 的 `image_load_native.mbt`）传入有效 `Bytes` 与 `Ref[Int]`

**后置条件**：
- 调用 C 侧对应符号，返回 `Bytes`（成功时非零长度，失败时零长度）
- 不修改输入 `Bytes`（`#borrow` 语义，stb 仅读取）
- 通过 `Ref[Int]` 输出参数写回 width/height/channels（`#borrow` 语义，wrapper 写入）

**私有性契约**：
- 不 `pub`：仅同包可见，不暴露给包外调用者
- 仅供 R3 的 `image_load_native.mbt` 调用，不直接供最终用户调用

### moon.pkg 行为契约

- `supported_targets = "native"`：包级仅 native 后端，非 native 后端 `moon check` 不编译此包
- `options("native-stub": ["wrapper.c"])`：wrapper.c 由 moon 编译为 C 源文件并链接到 native 后端
- `options(targets: { "ffi.mbt": ["native"] })`：ffi.mbt 仅在 native 后端编译，其他后端忽略此文件
- **不门控**未创建文件：避免悬空引用致 `moon check` 失败

### 验收契约

- `moon check --target native` 通过：wrapper.c 编译成功（stb_image.h 存在 + moonbit.h 可用）、ffi.mbt 的 extern "c" 声明有对应 C 符号、moon.pkg 配置有效
- `moon info --target native` 通过：生成 `src/pkg.generated.mbti`（无公开 API，因 ffi.mbt 私有）
- `moon test --target native`：no test entry（本任务无测试代码，测试留待 R4）
- **前置条件**：`src/stb_image.h` 必须存在。若不存在，需先运行 `python scripts/prepare.py` 生成

## 依赖关系

### 本任务依赖

- **R1 产出**：
  - `src/stb_image.h`（vendored 上游头文件，commit `013ac3beddff3dbffafd5177e7972067cd2b5083`，SHA256 `594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3`）——wrapper.c 通过 `#include "stb_image.h"` 硬依赖
  - `moon.mod`（已配置 preferred_target="native"，本任务不修改）
  - `src/moon.pkg`（当前仅 `supported_targets = "native"`，本任务覆写追加 options 块）
- **MoonBit 运行时 API**（moonbit.h，`C:\Users\Administrator\.moon\include\moonbit.h`）：
  - `moonbit_make_bytes(int32_t size, int value) -> moonbit_bytes_t`（第 269 行）——创建输出 Bytes
  - `moonbit_bytes_t`（`uint8_t *`，第 248 行）——Bytes 的 C 侧类型
  - `MOONBIT_FFI_EXPORT`（第 50/53 行）——导出 C 函数供 MoonBit 调用
  - `Moonbit_array_length(obj)`（第 224 行）——可选，用于断言 len 与 buffer 长度一致（本任务 wrapper 通过参数接收 len，不强制调用 Moonbit_array_length）
- **C 标准库**：`string.h`（`memcpy`）、`stdlib.h`（`malloc` / `free`）
- **stb_image.h API**（v2.30，已 webfetch 核实）：
  - `stbi_uc *stbi_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels)`
  - `stbi_uc *stbi_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels)`
  - `void stbi_image_free(void *retval_from_stbi_load)`
  - 失败时返回 NULL，`*x, *y, *channels_in_file` 保持不变（非写入 0），wrapper 需主动写入 0

### 暴露给后续任务的公开接口

- **`src/wrapper.c`**：两个 `MOONBIT_FFI_EXPORT` 函数（`stb_image_mbt_load_from_memory` / `stb_image_mbt_load_from_path`），供 ffi.mbt 声明调用。后续版本（v0.2+）追加 write / 16-bit / float / info / callbacks 等 C 函数时扩展此文件
- **`src/ffi.mbt`**：两个私有 `extern "c" fn` 声明，供 R3 的 `image_load_native.mbt` 调用。后续版本追加 FFI 入口时扩展此文件
- **`src/moon.pkg`**：options 块已建立，后续任务（R3/R4）在 `targets` 块渐进追加 `image_types.mbt` / `image_load_native.mbt` / `image_test.mbt` / `README.mbt.md` 条目（合并到同一 options 块，避免多块冲突）

### 与已有代码的关系

- **参考** `moonbit_wp/llvm.mbt/unsafe/moon.pkg`：`supported_targets = "native"` + 单一 `options(...)` 块（native-stub + link）先例。本任务不设 link 块（stb_image 无外部库依赖，仅 moonbit.h 与 C 标准库）
- **参考** `moonbit_wp/x/fs/fs_native.mbt` 第 52-53 行：`#borrow(path, mode)` 在 `extern "C" fn` 之前的语法先例
- **参考** `moonbit_wp/x/fs/fs_native.c` 第 87-89 行：`moonbit_make_bytes(len, 0)` + `memcpy` 拷贝先例
- **参考** `moonbit_wp/SWE-AGI-Eval/.../decode_native.c` 第 49-50, 198, 206 行：`moonbit_make_bytes(0, 0)` 作为失败信号先例
- **参考** `moonbitlang/async` 的 `process.c` 第 41 行：`int *out` 对应 MoonBit `Ref[Int]` 的 ABI 先例（本任务用 `int32_t*` 明确 32 位宽度）
- **参考** `make-moonbit-c-bindings` skill 模板：wrapper.c 结构（`#define IMPLEMENTATION` + `#include` + `MOONBIT_FFI_EXPORT`）、ffi.mbt 小写 `extern "c"` + `#borrow` 惯例
- **不引用** `image-mbt/`（参考实现，仅参考 DSL 语法，不引用其代码）

### 边界约束（本任务不做）

- 不创建 `src/image_types.mbt`（`Image` / `LoadError` 类型定义，R3 职责）
- 不创建 `src/image_load_native.mbt`（`load_from_*` 安全包装 + 错误映射，R3 职责）
- 不创建 `src/image_test.mbt` / `testdata/` / `src/README.mbt.md` / `SKILL.md`（R4 职责）
- 不向 moon.pkg 的 targets 块追加 `image_types.mbt` / `image_load_native.mbt` / `image_test.mbt` / `README.mbt.md` 条目（避免悬空引用致 `moon check` 失败）
- 不向 moon.mod 追加 `readme` 行（`README.mbt.md` 未创建，R4 追加）
- 不创建 `scripts/run-asan.py`（R4 职责）
- 不暴露 `stbi_failure_reason`（MVP 阶段性限制）
- 不处理 FileIO 与 DecodeFailed 的区分（R3 的 MoonBit 侧预检查职责，wrapper 仅传递失败信号）
- 不暴露 `req_channels` 参数（MVP 始终 desired_channels=0，返回原始通道）