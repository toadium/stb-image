# 实现计划

任务描述：将 stb_image.h 以 MoonBit 原生 FFI 绑定形式暴露为 MoonBit 包，MVP 聚焦 8-bit load 路径（native 目标），提供 load_from_path/load_from_bytes 两个入口 + Image + LoadError，覆盖 9 种格式解码。
项目根目录：D:\CodeWorkspace\forMoonbit\stb-image

---

## R1 NEW Vendoring 层 + 项目骨架

任务：创建项目配置（moon.mod 新 DSL、src/moon.pkg 新 DSL）+ vendoring 脚本（scripts/prepare.py）+ 运行脚本下载 pinned stb_image.h 到 src/stb_image.h + .gitignore。预期文件路径：
- `moon.mod`（模块配置，preferred_target = "native"，不设 readme 行）
- `src/moon.pkg`（包配置，supported_targets = "native"，渐进式声明——本任务仅声明 supported_targets，options 块待后续任务追加）
- `scripts/prepare.py`（vendoring 脚本：下载 pinned stb_image.h + SHA256 校验 + 幂等 + 预留 --include-write）
- `src/stb_image.h`（vendored 上游头文件，由脚本生成）
- `.gitignore`（忽略 .prepare/ 缓存目录）

选择理由：Vendoring 层是四层架构的最底层依赖，FFI 边界层（wrapper.c/ffi.mbt）与所有上层都依赖 vendored 的 stb_image.h 与项目配置。没有项目骨架（moon.mod/moon.pkg）与 vendored 头文件，后续任何 MoonBit 代码都无法编译。底层优先，一次一个任务。

上下文：项目根目录当前为空（仅有 image-mbt 参考实现与文档目录，无任何 MoonBit 项目文件），需从零搭建。技术方案 §3.1 文件布局、§3.2 moon.mod 配置、§3.3 moon.pkg 配置、§4 Vendoring 方案已给出完整决策。stb_image.h 是单头文件库（header-only），vendoring 策略与一般多文件 C 库不同：只需下载单个 .h 文件，wrapper.c 中 #define STB_IMAGE_IMPLEMENTATION + #include 生成实现，stb_image.h 不列入 native-stub（通过 wrapper.c 的 #include 纯入）。

---

## 后续任务路线图

R1 完成后，按"底层优先、依赖单向向下"原则推进：

- **R2 FFI 边界层**：创建 `src/wrapper.c`（ABI 归一化、`moonbit_make_bytes` 拷贝、`stbi_image_free` 释放、NULL→失败信号）+ `src/ffi.mbt`（私有 `extern "c"` 声明，native 门控）；同步向 `moon.pkg` 的单一 `options(...)` 块追加 `"native-stub": ["wrapper.c"]` 与 `targets: { "ffi.mbt": ["native"] }`（两者合并到同一 `options` 块，非两个独立块）
- **R3 安全 API 层**：创建 `src/image_types.mbt`（`Image` struct + `LoadError` suberror 类型定义，不门控，全后端可用）+ `src/image_load_native.mbt`（`load_from_path`/`load_from_bytes` 公开 API 实现 + 错误映射，native 门控）；同步向 `moon.pkg` 的 `options` 块 `targets` 追加 `"image_load_native.mbt": ["native"]` 条目（`image_types.mbt` 不门控）
- **R4 测试与文档层**：创建 `src/image_test.mbt`（回归测试，happy + error path）+ `testdata/`（vendored 测试图片）+ `src/README.mbt.md`（测试过的文档示例）+ `SKILL.md` + `scripts/run-asan.py`（从 `moonbit-c-binding` skill 复制 ASan 验证脚本）；同步向 `moon.pkg` 的 `options` 块 `targets` 追加对应条目，向 `moon.mod` 追加 `readme = "README.mbt.md"` 行；运行 ASan 验证

各轮任务粒度与具体拆分由计划 agent 在对应轮次决定，本路线图仅给出方向与依赖顺序。

---

## R1 PASSED Vendoring 层 + 项目骨架

结果：创建 `moon.mod`（新 DSL，preferred_target="native"）、`src/moon.pkg`（新 DSL，supported_targets="native"，渐进式不声明 options 块）、`scripts/prepare.py`（下载 pinned stb_image.h commit `013ac3beddff3dbffafd5177e7972067cd2b5083` + SHA256 校验 + 幂等写入 + --include-write 骨架）、`.gitignore`（忽略 .prepare/、target/、.mooncakes/）。`src/stb_image.h` 待网络可达后由脚本生成（脚本就绪，SHA256 硬编码校验保证一致性）。
测试：`tests/test_prepare.py` + `tests/test_project_skeleton.py` + `tests/test_acceptance.py`，52 个用例，47 个离线用例全部通过，5 个依赖网络用例 skip。`moon check` / `moon check --target native` / `moon info` 通过。
涉及文件：moon.mod、src/moon.pkg、scripts/prepare.py、.gitignore、tests/test_prepare.py、tests/test_project_skeleton.py、tests/test_acceptance.py

---

## R2 NEW FFI 边界层（wrapper.c + ffi.mbt + moon.pkg options 块）

任务：创建 C wrapper 与 FFI 私有声明，向 `moon.pkg` 追加单一 `options(...)` 块。预期文件路径：
- `src/wrapper.c`（新建）：头文件包含顺序为 `STBI_WINDOWS_UTF8`（Windows 条件）→ `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → `#include <moonbit.h>` → `#include <string.h>`/`<stdlib.h>`；两个 `MOONBIT_FFI_EXPORT` 函数 `stb_image_mbt_load_from_memory` / `stb_image_mbt_load_from_path`，调用 stbi_load_from_memory / stbi_load（desired_channels=0），memcpy 到 `moonbit_make_bytes`，`stbi_image_free` 释放原始缓冲；`stb_image_mbt_load_from_path` 内部构建 NUL 结尾副本（malloc+memcpy+`\0`）传递给 stbi_load 后 free；失败时主动将 width/height/channels 写入 0 并返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes，非 NULL）
- `src/ffi.mbt`（新建）：两个私有 `extern "c" fn` 声明（小写，与 skill 模板一致），输入 `Bytes` + `Ref[Int]` 输出参数均 `#borrow`（语法形式 `= #borrow(参数名列表)`），返回 `Bytes`，不 `pub`
- `src/moon.pkg`（覆写）：在 `supported_targets = "native"` 基础上追加单一 `options("native-stub": ["wrapper.c"], targets: { "ffi.mbt": ["native"] })` 块（两者合并到同一 options 块，非两个独立块）

前置条件：`src/stb_image.h` 必须已存在（wrapper.c 硬依赖 `#include "stb_image.h"`）。若不存在需先运行 `python scripts/prepare.py` 生成（要求网络可达）。

选择理由：FFI 边界层是四层架构的第二层，依赖 R1 的 vendored `stb_image.h` 与项目配置。wrapper.c 是 C/MoonBit 唯一语言边界，承担 ABI 归一化（int* 输出参数 + unsigned char* 返回值不能直接映射 MoonBit 值语义）、所有权转移（C 分配 → moonbit_make_bytes 拷贝 → stbi_image_free）、失败信号统一（零长度 Bytes + 零尺寸输出参数，规避 NULL 指针解引用风险）。ffi.mbt 是 wrapper.c 的 MoonBit 侧声明，供 R3 安全 API 层调用。无此层，R3 的 `load_from_*` 无 FFI 入口可调。

上下文：R1 已落地 vendored `stb_image.h`（待网络可达生成，wrapper.c 通过 `#include "stb_image.h"` 纯入编译，stb_image.h 不列入 native-stub）。技术方案 §5.1 C wrapper 设计、§5.2 extern "c" 声明设计、§5.3 Windows 路径编码、§2.4 moonbit.h 运行时 API 已给出完整决策。关键 C API 签名：`stbi_load(char const*, int*, int*, int*, int)`、`stbi_load_from_memory(stbi_uc const*, int, int*, int*, int*, int)`、`stbi_image_free(void*)`。moonbit.h 关键 API：`moonbit_make_bytes(int32_t size, int value)`（第 343 行）、`MOONBIT_FFI_EXPORT`（第 50/53 行）。类型映射：`int32_t`↔`Int`、`uint8_t*`输入↔`Bytes`#borrow、`uint8_t*`输出↔`Bytes` GC 管理、`int32_t*`输出参数↔`Ref[Int]`#borrow。本任务不涉及 MoonBit 安全 API 层（`Image`/`LoadError`/`load_from_*` 留待 R3），仅 FFI 边界层 + 配置更新。

---

## R2 审议修订（v2 r1）

依据 `plan_review_v2_r1.md`（REJECTED，3 一般 + 2 轻微问题）修订 task_v2.md，覆写原文件并追加修订说明。修订要点：
1. **[一般] 统一失败信号方案**：wrapper.c 失败时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）而非 NULL，规避 NULL 指针解引用段错误风险，与 ffi.mbt 返回类型 `Bytes` 匹配
2. **[一般] 明确前置条件**：在 task 顶部新增"前置条件"节，声明 `src/stb_image.h` 必须已存在，若不存在需先运行 `python scripts/prepare.py` 生成
3. **[一般] 明确 NUL 结尾处理方案**：wrapper.c 内部始终构建 NUL 结尾副本（malloc+memcpy+`\0`），不依赖 MoonBit String/Bytes ABI 约定
4. **[轻微] 补充 `#borrow` 实际语法形式**：在 ffi.mbt 声明模板中给出 `= #borrow(参数名列表)` 完整语法
5. **[轻微] 给出完整头文件包含顺序**：明确排列 `STBI_WINDOWS_UTF8` → `STB_IMAGE_IMPLEMENTATION` → `#include "stb_image.h"` → `#include <moonbit.h>` → `#include <string.h>`/`<stdlib.h>`

---

## R2 审议修订（v2 r2）

依据 `plan_review_v2_r2.md`（REJECTED，1 一般 + 1 轻微问题）修订 task_v2.md，覆写原文件并追加修订说明。修订要点：
1. **[一般] 修正 ffi.mbt 的 `#borrow` 语法形式**：v2 r1 修订引入的 `= #borrow(...)` 语法与 MoonBit 官方文档矛盾。正确语法为 `#borrow(params..)` 作为独立属性标注放在 `extern "c" fn` 声明**之前**，函数末尾 `= "symbol_name"` 显式指定 C 符号名。依据 `moonbit_wiki/language/ffi.md` 第 444-446 行、`attributes.md` 第 354-356 行与先例 `moonbitlang/async` 的 `c_buffer.mbt` 第 20-27 行、`process_unix.mbt` 第 59 行修正
2. **[轻微] 修正 wrapper.c 参数类型名 `moonbit_ref_t`**：moonbit.h 中无 `moonbit_ref_t` 类型定义，`Ref[Int]` 在 C 侧映射为 `int32_t*` / `int*`。依据先例 `process.c` 第 41 行 `int *out` 对应 MoonBit `out : Ref[Int]`，将 `moonbit_ref_t*` 改为 `int32_t*`
