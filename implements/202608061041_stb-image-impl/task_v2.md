# 任务指令（v2）

## 动作
NEW

## 前置条件
- **`src/stb_image.h` 必须已存在**：wrapper.c 通过 `#include "stb_image.h"` 硬依赖此文件。若不存在，实现者需先运行 `python scripts/prepare.py` 生成（要求网络可达 `raw.githubusercontent.com`），或确认网络可达性后运行脚本。R1 因网络不可达未生成此文件，本任务不得在 `src/stb_image.h` 缺失状态下提交——`moon check --target native` 会因 `#include` 失败而编译错误。

## 任务描述
创建 FFI 边界层：C wrapper（ABI 归一化 + 所有权转移 + 失败信号）+ MoonBit 私有 extern "c" 声明 + 更新 moon.pkg 的单一 options 块。预期文件路径：
- `src/wrapper.c`（新建）
- `src/ffi.mbt`（新建）
- `src/moon.pkg`（覆写：在现有 `supported_targets = "native"` 基础上追加单一 `options(...)` 块）

### src/wrapper.c 职责
1. **头文件包含顺序**（严格按以下顺序排列，避免宏定义顺序错误）：
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
   完整顺序为：`STBI_WINDOWS_UTF8`（Windows 条件）→ `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → `#include <moonbit.h>` → `#include <string.h>` / `<stdlib.h>`。`STBI_WINDOWS_UTF8` 启用 stb_image 内部 `_wfopen` 处理 UTF-8 路径。

2. 两个 `MOONBIT_FFI_EXPORT` 函数：
   - `stb_image_mbt_load_from_memory(moonbit_bytes_t buffer, int32_t len, int32_t* w_ref, int32_t* h_ref, int32_t* c_ref) -> moonbit_bytes_t`
     - 调用 `stbi_load_from_memory((stbi_uc const*)buffer, len, &w, &h, &c, 0)`（desired_channels=0，返回原始通道）
     - 成功：`moonbit_make_bytes(w*h*c, 0)` 创建输出 Bytes，`memcpy` 拷贝像素数据，`stbi_image_free` 释放 C 缓冲，将 w/h/c 写入三个 Ref 输出参数，返回输出 Bytes
     - 失败（stbi_load_from_memory 返回 NULL）：主动将 w/h/c 输出参数写入 0，**返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）**，不返回 NULL 指针
   - `stb_image_mbt_load_from_path(moonbit_bytes_t path_bytes, int32_t path_len, int32_t* w_ref, int32_t* h_ref, int32_t* c_ref) -> moonbit_bytes_t`
     - **NUL 结尾处理（明确方案）**：wrapper.c 内部始终构建 NUL 结尾副本，不依赖 MoonBit String/Bytes 的 ABI 约定。具体步骤：`char* path_cstr = (char*)malloc(path_len + 1);` → `memcpy(path_cstr, path_bytes, path_len);` → `path_cstr[path_len] = '\0';` → 调用 `stbi_load(path_cstr, &w, &h, &c, 0)` → `free(path_cstr);` 释放副本 → 后续处理同 load_from_memory。此方案安全、自包含，避免 `Bytes` 类型不保证 NUL 结尾导致的缓冲区越界读取风险
     - 成功/失败处理同 load_from_memory

3. **失败信号统一契约**（wrapper.c 与 ffi.mbt 之间的统一方案）：
   - stb_image 失败时输出参数保持不变（非写入 0），wrapper 需**主动**将 width/height/channels 写入 0 以统一失败信号（架构设计 D2、技术方案 §5.1）
   - **失败时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes），不返回 NULL**。此方案让 ffi.mbt 可安全声明返回类型为 `Bytes`（非 `Bytes?`），R3 通过 `bytes.length() == 0` 或 `w_ref.val == 0` 检查失败，避免 NULL 指针解引用段错误风险。架构设计 D2 给出的两种合法方案（`moonbit_make_bytes(0, 0)` 或直接返回 NULL）中，本任务选择更安全的零长度 Bytes 方案

4. **内存安全契约**：无论成功或失败，C 侧分配的所有临时缓冲都被释放（包括 NUL 结尾副本、stbi_load 返回的缓冲）；MoonBit 侧不直接 free 任何 C 指针

### src/ffi.mbt 职责
1. 两个私有 `extern "c" fn` 声明（小写 `extern "c"`，与 make-moonbit-c-bindings skill 模板一致；架构设计 D14），**含 `#borrow` 标注的完整语法形式**：
   ```moonbit
   #borrow(buffer, w_ref, h_ref, c_ref)
   extern "c" fn stb_image_mbt_load_from_memory(
     buffer : Bytes,
     len : Int,
     w_ref : Ref[Int],
     h_ref : Ref[Int],
     c_ref : Ref[Int],
   ) -> Bytes = "stb_image_mbt_load_from_memory"

   #borrow(path, w_ref, h_ref, c_ref)
   extern "c" fn stb_image_mbt_load_from_path(
     path : Bytes,
     path_len : Int,
     w_ref : Ref[Int],
     h_ref : Ref[Int],
     c_ref : Ref[Int],
   ) -> Bytes = "stb_image_mbt_load_from_path"
   ```
   - `#borrow(params..)` 作为独立属性标注放在 `extern "c" fn` 声明**之前**，函数末尾 `= "symbol_name"` 显式指定 C 符号名，多个参数逗号分隔。此语法形式依据 MoonBit 官方文档（`moonbit_wiki/language/ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行）与实际代码先例（`moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行 `#borrow(src)` 在 `pub extern "C" fn` 之前、`process_unix.mbt` 第 59 行 `extern "C" fn get_process_result(pid : Int, out : Ref[Int]) -> Int = "moonbitlang_async_get_process_result"` 符号名显式指定）
   - 输入 `Bytes` 与 `Ref[Int]` 均标注 `#borrow`（stb 仅在调用期间读取，不存储引用；架构设计 §3.3、技术方案 §5.2）
   - 返回类型为 `Bytes`（非 `Bytes?`），与 wrapper.c 失败时返回零长度 Bytes 的方案匹配
2. 私有：不 `pub`，仅供同包 R3 的 `image_load_native.mbt` 调用
3. 不包含任何 MoonBit 类型定义或安全包装逻辑（纯 FFI 声明）

### src/moon.pkg 更新
覆写为：
```
supported_targets = "native"

options(
  "native-stub": ["wrapper.c"],
  targets: {
    "ffi.mbt": ["native"],
  },
)
```
- `native-stub` 与 `targets` 合并到**单一** `options(...)` 块（MoonBit moon.pkg DSL 要求，见 package-management.md:63-75 示例），非两个独立块
- `wrapper.c` 列入 `native-stub`（C 源文件，仅 native 编译）
- `ffi.mbt` 门控 `["native"]`（extern "c" 仅 native 后端支持）
- 不门控 `image_types.mbt` / `image_load_native.mbt` / `image_test.mbt` / `README.mbt.md`（这些文件本任务不创建，留待 R3/R4，避免悬空引用导致 moon check 失败）

## 选择理由
FFI 边界层是四层架构（Vendoring → FFI 边界 → 安全 API → 测试文档）的第二层，依赖 R1 的 vendored `stb_image.h` 与项目配置。wrapper.c 是 C/MoonBit 唯一语言边界，承担：
- ABI 归一化：stbi_load 的 `int*` 输出参数 + `unsigned char*` 返回值不能直接映射 MoonBit 值语义，需 C 侧转换为 moonbit_make_bytes + Ref[Int] 写回
- 所有权转移：C 分配的缓冲 → memcpy 到 moonbit_make_bytes（MoonBit GC 接管）→ stbi_image_free 释放 C 缓冲
- 失败信号统一：stb_image 失败时仅返回 NULL（输出参数保持不变），wrapper 需主动写入 0 并返回零长度 Bytes，让 MoonBit 侧可安全检查 `bytes.length() == 0` 或 `w_ref.val == 0` 判断失败

ffi.mbt 是 wrapper.c 的 MoonBit 侧声明，供 R3 安全 API 层的 `load_from_*` 调用。无此层，R3 无 FFI 入口可调。底层优先，一次一个任务。

## 任务上下文
### 来自需求文档
- §三 FFI 实现要点：C wrapper 负责 ABI 归一化；`moonbit_make_bytes` 拷贝后由 MoonBit GC 接管；C 侧用 `stbi_image_free` 释放原始指针；失败时返回 NULL 让 MoonBit 侧 raise；输入 Bytes 用 #borrow；数据返回统一用 Bytes
- §四 验收标准：`moon check` 通过、`moon test --target native` 通过、ASan 无内存泄漏/越界

### 来自架构设计（design_v3.md）
- §3.3 FFI 私有声明集：私有 extern "c" fn，输入 Bytes 用 #borrow，保持私有不 Pub，targets: ["native"] 门控
- §3.4 C Wrapper 函数集：调用 stbi_load/stbi_load_from_memory，拷贝到 moonbit_make_bytes，stbi_image_free 释放，失败时主动写入 0 输出参数
- §4.3 FFI 边界契约：输入 Bytes #borrow，输出 Bytes 由 moonbit_make_bytes 创建 GC 接管，失败信号 NULL + 零尺寸输出参数
- D2：C wrapper 错误信号——返回 NULL + 零尺寸输出参数；MVP 默认归类 DecodeFailed（R3 职责，本任务仅传递信号）。D2 给出两种合法失败返回方案（`moonbit_make_bytes(0, 0)` 或直接返回 NULL），本任务选择更安全的零长度 Bytes 方案（见任务描述 §wrapper.c 失败信号统一契约）
- D14：统一小写 `extern "c"`

### 来自技术方案（tech_v2.md）
- §2.4 moonbit.h 运行时 API：`moonbit_make_bytes(int32_t size, int value) -> moonbit_bytes_t`（第 343 行）、`MOONBIT_FFI_EXPORT`（第 50/53 行）。MVP 仅需这两个 API，无 external object、无 incref/decref
- §5.1 C wrapper 设计：关键 C API 签名已 webfetch 核实 stb_image.h v2.30：
  - `stbi_uc *stbi_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels)`
  - `stbi_uc *stbi_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels)`
  - `void stbi_image_free(void *retval_from_stbi_load)`
  - 失败时返回 NULL，`*x, *y, *channels_in_file` 保持不变（非写入 0），wrapper 需主动写入 0
- §5.1 ABI 归一化要点：desired_channels 传 0（STBI_default，返回原始通道）；输出参数通过 C 指针写回，MoonBit 侧用 Ref[Int] 接收（#borrow Ref）；memcpy 拷贝
- §5.2 extern "c" 声明设计：类型映射表
  | C 类型 | MoonBit 类型 | 用途 |
  |--------|-------------|------|
  | `int32_t` | `Int` | width/height/channels、Bytes 长度 |
  | `uint8_t*`（输入） | `Bytes`（#borrow） | 输入像素数据/路径字符串 |
  | `uint8_t*`（输出） | `Bytes`（GC 管理） | 输出像素数据 |
  | `int32_t*`（输出参数） | `Ref[Int]`（#borrow） | width/height/channels 写回 |
- §5.3 Windows 路径编码：wrapper.c 中 `#if defined(_WIN32)` `#define STBI_WINDOWS_UTF8` `#endif`，启用 stb_image.h 内置 UTF-8 路径支持（内部 _wfopen）。FileIO 错误区分在 MoonBit 侧预检查（R3 职责），本任务 wrapper 不处理 errno
- §3.3 moon.pkg 配置：单一 options(...) 块同时承载 native-stub 与 targets，`image_types.mbt` 不门控（全后端可用）
- §九 需验证的技术假设第 5 点：空 Bytes 作为失败信号的可靠性——本任务通过选择 `moonbit_make_bytes(0, 0)` 方案规避 NULL 返回风险，R3 可安全通过 `bytes.length() == 0` 检查失败

### 来自 R1 产出
- `src/stb_image.h`：vendored 上游头文件（待网络可达后由 `python scripts/prepare.py` 生成，commit `013ac3beddff3dbffafd5177e7972067cd2b5083`，SHA256 `594c2fe35d49488b4382dbfaec8f98366defca819d916ac95becf3e75f4200b3`）。wrapper.c 通过 `#include "stb_image.h"` 纯入编译，stb_image.h 不列入 native-stub。**本任务前置条件：此文件必须已存在**
- `src/moon.pkg`：当前仅 `supported_targets = "native"`，本任务追加 options 块
- `moon.mod`：已配置 preferred_target="native"，本任务不修改

### 边界约束（本任务不做）
- 不创建 `src/image_types.mbt`（Image / LoadError 类型定义，R3 职责）
- 不创建 `src/image_load_native.mbt`（load_from_* 安全包装，R3 职责）
- 不创建 `src/image_test.mbt` / `testdata/` / `src/README.mbt.md` / `SKILL.md`（R4 职责）
- 不向 moon.pkg 的 targets 块追加 image_types.mbt / image_load_native.mbt / image_test.mbt / README.mbt.md 条目（避免悬空引用导致 moon check 失败）
- 不向 moon.mod 追加 readme 行（README.mbt.md 未创建，R4 追加）
- 不创建 `scripts/run-asan.py`（R4 职责）
- 不暴露 `stbi_failure_reason`（MVP 阶段性限制）
- 不处理 FileIO 与 DecodeFailed 的区分（R3 的 MoonBit 侧预检查职责，wrapper 仅传递失败信号）

## 已有代码上下文
### R1 已落地文件
- `moon.mod`（新 DSL）：name="MoonBit-Toadium/stb-image"、version="0.1.0"、license="MIT"、preferred_target="native"
- `src/moon.pkg`（新 DSL）：`supported_targets = "native"`（仅此一行，无 options 块）
- `scripts/prepare.py`：vendoring 脚本，下载 pinned stb_image.h + SHA256 校验 + 幂等写入 + --include-write 骨架
- `.gitignore`：忽略 .prepare/、target/、.mooncakes/
- `tests/test_prepare.py` / `tests/test_project_skeleton.py` / `tests/test_acceptance.py`：R1 行为契约测试（52 用例，47 离线通过）

### 参考先例
- `moonbit_wp/llvm.mbt/unsafe/`：同为 native FFI 绑定项目，moon.pkg 用 `supported_targets = "native"` + options(native-stub + targets) 单一块先例
- `make-moonbit-c-bindings` skill 模板：wrapper.c 结构（#define IMPLEMENTATION + #include + MOONBIT_FFI_EXPORT）、ffi.mbt 小写 extern "c" + #borrow 惯例
- `moonbit_wp/moonbit-native-runtime/include/moonbit.h`：moonbit_make_bytes（第 343 行）、MOONBIT_FFI_EXPORT（第 50/53 行）已核实

### 当前 src/ 目录状态
- `src/moon.pkg`（28 字节，仅 supported_targets）
- `src/pkg.generated.mbti`（moon info 生成产物，159 字节）
- 无 stb_image.h（待网络可达生成）、无 wrapper.c、无 ffi.mbt、无任何 .mbt 文件

### 验证命令（本任务完成后）
- `moon check --target native`：应通过（wrapper.c + ffi.mbt 编译，ffi.mbt 的 extern "c" 声明有 wrapper.c 的 MOONBIT_FFI_EXPORT 对应符号）
- `moon info --target native`：应通过
- 注意：本任务无 MoonBit 测试代码（测试留待 R4），`moon test --target native` 应为 no test entry
- 注意：本任务前置条件为 `src/stb_image.h` 已存在。若不存在，需先运行 `python scripts/prepare.py` 生成（要求网络可达）

## 修订说明（v2 r1）
| 审查意见 | 修改措施 |
|---------|---------|
| **[一般] 发现 1**：ffi.mbt 返回类型 `Bytes` 与 wrapper.c 失败时返回 NULL 存在类型不匹配风险。若 R3 实现者选择 `bytes.length() == 0` 路径检查而 bytes 为 NULL 指针，native 后端将段错误。task 未提示此风险，也未在 wrapper.c 与 ffi.mbt 之间统一失败信号方案 | 统一失败信号方案：wrapper.c 失败时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）而非 NULL。在"任务描述 §wrapper.c 职责"第 2 点的两个函数失败分支明确"返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes），不返回 NULL 指针"；新增第 3 点"失败信号统一契约"专节说明此方案与 D2 两种合法方案的选择理由；ffi.mbt 返回类型保持 `Bytes`（非 `Bytes?`），与零长度 Bytes 方案匹配；在"任务上下文 §来自技术方案"补充 §九第 5 点技术假设的规避说明；R3 可安全通过 `bytes.length() == 0` 或 `w_ref.val == 0` 检查失败 |
| **[一般] 发现 2**：网络可达性前提条件（`src/stb_image.h` 存在）未在任务描述中明确声明。R1 因网络不可达未生成此文件，wrapper.c 的 `#include "stb_image.h"` 是硬依赖，无此文件则 `moon check --target native` 必然失败 | 在任务指令顶部新增"前置条件"节，明确声明 `src/stb_image.h` 必须已存在，若不存在需先运行 `python scripts/prepare.py` 生成或确认网络可达性；在"任务上下文 §来自 R1 产出"补充"本任务前置条件：此文件必须已存在"；在"验证命令"注释中保留前置条件提示 |
| **[一般] 发现 3**：wrapper.c 中 `stb_image_mbt_load_from_path` 的 NUL 结尾处理不够明确。task 给出两种方案（内部构建 NUL 结尾缓冲或依赖 MoonBit String ABI），但 ffi.mbt 声明参数类型为 `Bytes`（非 `String`），`Bytes` 不保证 NUL 结尾。若依赖 MoonBit String ABI 而转换后的 Bytes 不保留 NUL 结尾，`stbi_load` 将缓冲区越界读取 | 明确推荐方案：wrapper.c 内部始终构建 NUL 结尾副本（`malloc(path_len + 1)` + `memcpy` + `buf[path_len] = '\0'`），传递给 `stbi_load` 后 `free` 释放，不依赖 MoonBit String/Bytes 的 ABI 约定。在"任务描述 §wrapper.c 职责"第 2 点的 `stb_image_mbt_load_from_path` 函数描述中给出明确方案与具体步骤；在"内存安全契约"补充"包括 NUL 结尾副本"的释放说明 |
| **[轻微] 发现 4**：ffi.mbt 的 extern "c" 声明模板缺少 `#borrow` 标注的实际语法形式。task 仅说"标注 `#borrow`"未给出语法位置，实现者需查阅文档确定 | 在"任务描述 §ffi.mbt 职责"第 1 点补充完整的 extern "c" 声明代码块，含 `#borrow` 的实际语法形式（函数声明末尾 `= #borrow(参数名列表)`，多参数逗号分隔），实现者无需查阅外部文档即可编码 |
| **[轻微] 发现 5**：wrapper.c 头文件包含顺序表述可能让实现者困惑。task 先列 `#define STB_IMAGE_IMPLEMENTATION` + `#include "stb_image.h"`，后说 `STBI_WINDOWS_UTF8` 必须在 `#include` 之前定义，未给出完整排列顺序 | 在"任务描述 §wrapper.c 职责"第 1 点给出完整的头文件包含顺序代码块，明确排列为：`STBI_WINDOWS_UTF8`（Windows 条件）→ `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → `#include <moonbit.h>` → `#include <string.h>` / `<stdlib.h>`，实现者直接按顺序编码 |

## 修订说明（v2 r2）
| 审查意见 | 修改措施 |
|---------|---------|
| **[一般] 发现 1**：ffi.mbt 的 `#borrow` 语法形式与 MoonBit 官方文档及实际代码不一致。task_v2.md 第 55-73 行将 `#borrow(...)` 放在函数声明末尾 `-> Bytes =` 之后（`-> Bytes = #borrow(...)`），且用 `= #borrow(...)` 替代 C 符号名指定。但 MoonBit 官方文档（`moonbit_wiki/language/ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行）明确 `#borrow(params..)` 应作为独立属性标注放在 `extern "c" fn` 声明**之前**，函数末尾的 `= "symbol_name"` 用于指定 C 符号名。实际代码先例印证同一语法：`moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行（`#borrow(src)` 在 `pub extern "C" fn` 之前）、`process_unix.mbt` 第 59 行（`extern "C" fn get_process_result(pid : Int, out : Ref[Int]) -> Int = "moonbitlang_async_get_process_result"`，符号名显式指定）。task_v2.md 第 74 行进一步断言"`#borrow` 语法形式为函数声明末尾的 `= #borrow(参数名列表)`"，与官方文档直接矛盾。此为 v2 r1 审查[轻微]发现 4 的修订结果，修订本意是补全 `#borrow` 语法形式以提升自包含性，但引入了错误的语法，会误导实现者 | 修正 ffi.mbt 声明代码块：将 `#borrow(...)` 从函数声明末尾移至 `extern "c" fn` 声明之前作为独立属性标注，函数末尾改为 `= "stb_image_mbt_load_from_memory"` / `= "stb_image_mbt_load_from_path"` 显式指定 C 符号名。两个函数（`stb_image_mbt_load_from_memory`、`stb_image_mbt_load_from_path`）同步修正。同时修正第 74 行对 `#borrow` 语法形式的断言描述，改为"`#borrow(params..)` 作为独立属性标注放在 `extern "c" fn` 声明之前，函数末尾 `= "symbol_name"` 显式指定 C 符号名"，并附官方文档与先例引用（`ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行、`c_buffer.mbt` 第 20-27 行、`process_unix.mbt` 第 59 行） |
| **[轻微] 发现 2**：wrapper.c 参数类型名 `moonbit_ref_t` 在 moonbit.h 中不存在。task_v2.md 第 39、43 行 wrapper.c 函数签名使用 `moonbit_ref_t* w_ref`，但 `C:\Users\Administrator\.moon\include\moonbit.h`（moon 0.1.20260713）中无 `moonbit_ref_t` 类型定义。实际 `Ref[Int]` 在 native 后端 C 侧映射为 `int32_t*` / `int*`，有先例：`moonbitlang/async` 的 `process.c` 第 41 行 `int moonbitlang_async_get_process_result(pid_t pid, int *out)`，对应 MoonBit 侧 `out : Ref[Int]`。不影响正确性但降低 task 自包含性 | 将 wrapper.c 两个函数签名中的 `moonbit_ref_t* w_ref, moonbit_ref_t* h_ref, moonbit_ref_t* c_ref` 改为 `int32_t* w_ref, int32_t* h_ref, int32_t* c_ref`。选用 `int32_t*` 以明确 32 位宽度，与 MoonBit `Int`（32 位）对应，且与 wrapper.c 中 `int32_t len` / `int32_t path_len` 类型一致。先例佐证：`moonbitlang/async` 的 `process.c` 第 41 行用 `int *out` 对应 MoonBit `out : Ref[Int]`，`int` 在 32 位平台等价于 `int32_t` |
