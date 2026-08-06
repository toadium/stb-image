# `stb-image` 技术方案设计（v2）

> 本设计为技术方案级设计，承接架构级 OOD 设计（design_v3.md），为编码实现铺路。聚焦技术选型决策、数据流方向、关键类型轮廓与方案决策，不涉及完整代码片段与逐字段签名。目标语言为 MoonBit v0.10.5（新格式 `moon.mod`/`moon.pkg` DSL，native 后端）。
>
> **v2 修订说明**：基于 `deliberations/202608060953_tech-v1-review/output_v1.md` 的独立审查报告，对 v1 进行三处修订（问题 1/3/4），问题 2 为 v1 相对架构设计的正向纠偏（亮点确认，无需修订）。修订位置见文末「修订说明（v2）」。

---

## 一、概述

### 设计定位

本技术方案是架构设计与编码实现之间的桥梁。比架构设计更具体（落实到工具链配置、C API 签名、FFI 机制级别），比代码更抽象（不给出完整实现）。实现者在编码时查阅 MoonBit / stb_image API 文档是正常编码活动。

### 技术方案范围

MVP 阶段（v0.1）需明确的技术事项：

1. **工具链配置**：`moon.mod`/`moon.pkg` 新格式 DSL 语法、native 后端声明、文件门控
2. **Vendoring 方案**：stb_image.h 单头文件库的特殊 vendoring 策略、版本固定、幂等脚本
3. **FFI 边界层方案**：C wrapper 的 ABI 归一化机制、所有权转移、失败信号、extern "c" 声明
4. **安全 API 层方案**：类型轮廓、错误处理流程、条件编译策略
5. **测试与验证方案**：测试图片生成、ASan 验证、验证门
6. **文档方案**：SKILL.md 结构、README.mbt.md 示例
7. **Windows 兼容性**：非 ASCII 路径处理决策
8. **格式嗅探增强决策**：是否在 MVP 纳入格式签名预检查

---

## 二、技术选型决策

### 2.1 MoonBit 工具链版本与配置格式

**决策**：采用 MoonBit v0.10.5 规范，新格式 `moon.mod`/`moon.pkg` DSL 语法（非旧 `moon.mod.json`/`moon.pkg.json`，后者在 v0.10.4 弃用）。

**已核实事实**（来源：`moonbit_wp/llvm.mbt` 同类型 native FFI 绑定项目先例 + `moonbit_wiki/toolchain/package-management.md`）：

- `moon.mod` 新 DSL：`preferred_target = "native"`（下划线，非旧 JSON 的 `"preferred-target"`）
- `moon.pkg` 新 DSL：`options("native-stub": [...], targets: { ... })`
- 38 处 `preferred_target = "native"` 先例确认下划线语法
- `moon fmt` 可自动从旧格式迁移到新格式

**理由**：v0.10.5 是当前稳定规范，新格式 DSL 是官方推荐方向；旧 JSON 格式已弃用，新项目不应采用。

### 2.2 目标后端策略

**决策**：MVP 仅 native 后端。`moon.mod` 设 `preferred_target = "native"`；`moon.pkg` 设 `supported_targets = "native"`（包级声明仅支持 native）。

**`supported_targets` 语法决策**：采用 `"native"`（非 `"+native"`）。

**已核实事实**：
- `llvm.mbt/unsafe/moon.pkg`（同为 native FFI 绑定项目）用 `supported_targets = "native"`
- `moonbit_wiki/toolchain/package-management.md` 示例用 `supported_targets = "native"`
- `"+native"` 语义为"在默认支持集合上追加 native"（适用于 async examples 等 native-only 应用），`"native"` 语义为"声明仅支持 native"（排他性）

**理由**：本项目是 native-only FFI 绑定，`"native"` 准确表达排他性声明，与 `llvm.mbt` 先例一致。架构设计 D13 提示的 `"+native"` 适用于"追加"语义场景，不适用于本项目的"仅 native"定位。

**权衡**：`supported_targets = "native"` 会阻止 `moon check --target all` 构建其他目标，这正是 MVP 期望行为（wasm/js 目标不支持 `extern "c"`）。

**与 c-binding skill 提示的关系**（v2 补充）：`moonbit_wiki/agent-guide/c-binding.md` 提示"勿用 `supported-targets: ["native"]`（阻止下游包在其他 target 构建）；用 `targets` 门控单文件"。该提示针对**希望被下游跨目标复用的一般库**——此类库需保留在其他 target 上的可构建性，故仅用文件级 `targets` 门控 FFI 部分。本项目是 **native-only FFI 绑定**，`extern "c"` 仅 native 后端支持，不存在"在其他 target 上构建本包"的合法场景；排他性声明 `supported_targets = "native"` 是准确语义，与 `llvm.mbt` 先例一致。故本项目采用包级 `supported_targets = "native"`，而非仅用文件级 `targets` 门控。

### 2.3 stb_image.h Vendoring 策略

**决策**：stb_image.h 是**单头文件库**（header-only），vendoring 策略与一般多文件 C 库不同。

**关键事实**（已 webfetch 核实 stb_image.h v2.30 上游）：
- stb_image.h 是单头文件，使用时需在**一个 C 文件**中 `#define STB_IMAGE_IMPLEMENTATION` 然后 `#include "stb_image.h"` 来生成实现
- 头文件本身包含 API 声明与实现（通过 `#ifdef STB_IMAGE_IMPLEMENTATION` 控制）
- 无需 vendoring 多个 `.c` 文件，只需一个 `.h` 文件

**Vendoring 方案**：
- `scripts/prepare.py` 下载 pinned `stb_image.h` 到 `src/stb_image.h`（保留原名，不扁平化）
- `src/wrapper.c` 中 `#define STB_IMAGE_IMPLEMENTATION` + `#include "stb_image.h"` 生成实现
- `moon.pkg` 的 `native-stub` 仅列 `wrapper.c`（stb_image.h 通过 `#include` 被 wrapper.c 纳入编译，无需单独列出）
- stb_image.h 放在 `src/` 目录（与 wrapper.c 同目录，便于 `#include "stb_image.h"`）

**理由**：单头文件库无需扁平化命名（无 `upstream#include#stb_image.h` 必要），保留原名提升可读性与维护性。wrapper.c 集中管理 IMPLEMENTATION 宏定义，避免宏泄漏。

### 2.4 C wrapper 与 moonbit.h 运行时

**决策**：C wrapper 负责 ABI 归一化，使用 `moonbit.h` 运行时 API 管理 MoonBit 对象。

**已核实事实**（来源：`moonbit_wp/moonbit-native-runtime/include/moonbit.h`）：
- `moonbit_make_bytes(int32_t size, int value) -> moonbit_bytes_t`（第 343 行）：创建 GC 管理的 `Bytes`
- `moonbit_make_external_object(void (*finalize)(void*), uint32_t payload_size) -> void*`（第 374 行）：创建 GC 管理的 external object（MVP 不需要，无 handle 场景）
- `MOONBIT_FFI_EXPORT` 宏（第 50/53 行）：导出 C 函数给 MoonBit 调用
- `Moonbit_array_length(obj)` 宏（第 228 行）：获取 GC 管理数组/Bytes 长度
- `moonbit_incref`/`moonbit_decref`（第 311-312 行）：引用计数管理（MVP 不需要，无回调场景）

**MVP 仅需使用的 moonbit.h API**：`moonbit_make_bytes`（创建输出 Bytes）+ `MOONBIT_FFI_EXPORT`（导出 wrapper 函数）。无 external object、无 incref/decref（MVP 无 handle、无回调）。

### 2.5 ASan 验证工具

**决策**：采用 `moonbit-c-binding` skill 的 `scripts/run-asan.py` 脚本，复制到项目 `scripts/run-asan.py`。

**已核实事实**（来源：`make-moonbit-c-bindings` skill + `moonbit-c-binding` skill）：
- `moonbit-c-binding/scripts/run-asan.py` 是现成的 ASan 验证脚本
- 脚本职责：强制 clang 作为 C 编译器、禁用 tcc、设置 ASan 编译/链接标志、运行后恢复 `moon.pkg`
- 不重新发明 ASan 脚本，除非现成脚本无法适配项目

---

## 三、项目配置方案

### 3.1 文件布局

```
stb-image/                          # 项目根
├── moon.mod                        # 模块配置（新 DSL）
├── scripts/
│   ├── prepare.py                  # vendoring 脚本
│   └── run-asan.py                 # ASan 验证脚本（从 moonbit-c-binding 复制）
├── src/
│   ├── moon.pkg                    # 包配置（新 DSL）
│   ├── stb_image.h                 # vendored 上游头文件
│   ├── wrapper.c                   # ABI 归一化 C wrapper
│   ├── ffi.mbt                     # 私有 extern "c" 声明（native 门控）
│   ├── image_types.mbt             # Image / LoadError 类型定义（全后端可用）
│   ├── image_load_native.mbt       # load_from_* 实现（native 门控，调用 FFI）
│   ├── image_test.mbt              # 回归测试（native 门控）
│   └── README.mbt.md               # 测试过的文档示例（native 门控）
├── testdata/                       # vendored 测试图片
│   ├── png/ jpeg/ bmp/ gif/ webp/  # 5 种格式目录
│   └── ...                         # 正常 + 损坏样本
├── SKILL.md                        # 包使用说明 / 技能文档
├── README.md -> src/README.mbt.md  # README 软链或复制
└── LICENSE
```

**与架构设计 D13 的对应**：采用"拆 `image_types.mbt` + `image_load_native.mbt`"方案（而非单文件内条件编译），理由见 §6.5 条件编译策略。

### 3.2 `moon.mod` 配置

**决策**：新 DSL 语法，模块级配置。

**配置项轮廓**：
- `name`：`<user>/stb-image`（发布到 mooncakes.io 的模块名，user 待定）
- `version`：`0.1.0`
- `preferred_target = "native"`（下划线，新 DSL）
- `license`：SPDX 标识（建议 `Public Domain` 或 `MIT`，stb_image 本身为 public domain）
- `repository`、`description`、`keywords`：发布元数据
- `readme = "README.mbt.md"`

**不设模块级 `supported_targets`**：模块级不限制，让包级 `moon.pkg` 的 `supported_targets = "native"` 生效（包级声明更精确，未来若拆子包可独立配置）。

### 3.3 `src/moon.pkg` 配置

**决策**：新 DSL 语法，包级配置。

**配置项轮廓**：
- `supported_targets = "native"`（包级声明仅支持 native，与 llvm.mbt 先例一致）
- `options(...)` **单一块**同时承载 `native-stub` 与 `targets`（MoonBit `moon.pkg` DSL 要求二者在同一 `options(...)` 块内，见 `package-management.md:63-75` 示例）：

```moon.pkg
options(
  "native-stub": ["wrapper.c"],
  targets: {
    "ffi.mbt": ["native"],
    "image_load_native.mbt": ["native"],
    "image_test.mbt": ["native"],
    "README.mbt.md": ["native"],
  },
)
```

- `image_types.mbt` **不门控**：`Image`/`LoadError` 类型定义全后端可用（架构设计 D13），不出现在 `targets` 块中

**门控清单**（已核实 make-moonbit-c-bindings skill 模板 + llvm.mbt 先例；与 §7.2 测试层设计同步）：

| 文件 | 门控 | 理由 |
|------|------|------|
| `ffi.mbt` | `["native"]` | `extern "c"` 仅 native 后端支持 |
| `image_load_native.mbt` | `["native"]` | 调用 FFI 的实现，仅 native |
| `image_types.mbt` | 不门控 | `Image`/`LoadError` 类型定义全后端可用（D13） |
| `image_test.mbt` | `["native"]` | 测试调用 `load_from_*`，仅 native 可用（见 §7.2） |
| `README.mbt.md` | `["native"]` | 含 FFI 示例，仅 native 可运行 |
| `wrapper.c` | `native-stub` | C 源文件，仅 native 编译 |

---

## 四、Vendoring 方案

### 4.1 prepare.py 脚本设计

**决策**：基于 `make-moonbit-c-bindings/templates/prepare.py` 改造，适配 stb_image.h 单头文件库特性。

**与模板的差异**（stb_image.h 单头文件库特殊处理）：
- **下载源**：从 `nothings/stb` GitHub raw URL 下载单个 `stb_image.h` 文件（非 tarball）
- **无需扁平化**：单文件直接复制为 `src/stb_image.h`（保留原名，非 `upstream#include#stb_image.h`）
- **无需 include 重写**：单头文件无 `#include "其他.h"` 依赖
- **无需刷新 native-stub 列表**：stb_image.h 不列入 native-stub（通过 wrapper.c 的 `#include` 纪入），native-stub 仅固定为 `["wrapper.c"]`
- **保留 managed block 标记**：为 v0.2 纳入 `stb_image_write.h` 预留扩展点（见 §4.4）

**脚本职责**：
1. 下载 pinned `stb_image.h`（按 git commit hash 固定 URL）到 `.prepare/` 缓存
2. SHA256 校验（哈希硬编码于脚本，不匹配则非零退出，不自动回退）
3. 复制到 `src/stb_image.h`
4. 幂等：重复运行无 tracked diff（若内容相同则不写文件，避免时间戳变化）

### 4.2 版本固定策略

**决策**：固定为 `nothings/stb` 仓库的特定 git commit hash。

**版本选择**（架构设计 D5）：
- stb_image.h 无正式版本号，当前最新版本标识为 `v2.30`（2024-05-31，文件头注释）
- 建议固定为 v2.30 对应的近期稳定 commit hash
- 脚本中硬编码 commit hash + SHA256，附注释记录 commit 日期与版本标识

**实现者需在编码时确定的具体值**：
- 上游 commit hash（建议选 v2.30 标签对应的 commit）
- 该 commit 的 stb_image.h SHA256 哈希
- 下载 URL（`https://raw.githubusercontent.com/nothings/stb/<commit-hash>/stb_image.h`）

### 4.3 幂等性保证

**决策**：脚本采用"先读后比再写"策略保证幂等。

**机制**：
- 下载到 `.prepare/` 缓存目录（`.gitignore` 忽略）
- 校验 SHA256
- 读取现有 `src/stb_image.h`（若存在），与下载内容比较
- 仅当内容不同时写入（避免时间戳变化产生 tracked diff）
- 重复运行：缓存命中 → 校验通过 → 内容相同 → 不写入 → 无 diff

### 4.4 `--include-write` 扩展预留

**决策**：脚本预留 `--include-write` 参数，供 v0.2 纳入 `stb_image_write.h`。

**预留机制**：
- 脚本支持 `--include-write` 命令行参数
- 不带参数：仅 vendoring `stb_image.h`
- 带 `--include-write`：额外下载 `stb_image_write.h` 到 `src/stb_image_write.h`
- wrapper.c 中预留条件编译块（`#ifdef STB_IMAGE_WRITE_IMPLEMENTATION`），v0.2 时激活

**理由**：避免 v0.2 纳入 write 时修改脚本结构，降低版本迭代成本。

---

## 五、FFI 边界层方案

### 5.1 C wrapper 设计

**决策**：C wrapper 集中处理所有 C/MoonBit 跨越的脏工作，对安全 API 层不可见。

**wrapper.c 职责轮廓**：
1. `#define STB_IMAGE_IMPLEMENTATION` + `#include "stb_image.h"`（生成 stb_image 实现）
2. `#include <moonbit.h>`（使用 moonbit 运行时 API）
3. 定义两个 `MOONBIT_FFI_EXPORT` 函数，对应 `load_from_path` 与 `load_from_bytes`：
   - `stb_image_mbt_load_from_memory`：接收 `Bytes`（#borrow）+ 长度，调用 `stbi_load_from_memory`，拷贝到 `moonbit_make_bytes`，`stbi_image_free` 原始缓冲，返回 `Bytes` + 输出参数（width/height/channels）
   - `stb_image_mbt_load_from_path`：接收 `Bytes`（UTF-8 路径，#borrow），调用 `stbi_load`，同上处理
4. 失败信号处理：stbi_load* 返回 NULL 时，主动将 width/height/channels 输出参数写入 0，返回 NULL（或零长度 Bytes）

**关键 C API 签名**（已 webfetch 核实 stb_image.h v2.30）：
- `stbi_uc *stbi_load(char const *filename, int *x, int *y, int *channels_in_file, int desired_channels)`
- `stbi_uc *stbi_load_from_memory(stbi_uc const *buffer, int len, int *x, int *y, int *channels_in_file, int desired_channels)`
- `void stbi_image_free(void *retval_from_stbi_load)`
- 失败时返回 NULL，`*x, *y, *channels_in_file` **保持不变**（非写入 0），wrapper 需主动写入 0

**ABI 归一化要点**：
- `desired_channels` 传 `0`（STBI_default）：MVP 不强制通道数，返回原始通道（需求文档 §二、MVP 范围）
- 输出参数（width/height/channels）通过 C 指针写回，MoonBit 侧用 `Ref[Int]` 接收（#borrow Ref）
- 返回的 `unsigned char*` 拷贝到 `moonbit_make_bytes(size, 0)` 后，立即 `stbi_image_free` 释放原始缓冲
- 拷贝用 `memcpy`（C 标准库）

**所有权转移流程**（load_from_bytes 为例）：
```
MoonBit Bytes (输入, #borrow) → C wrapper → stbi_load_from_memory → C 分配的 unsigned char*
→ memcpy 到 moonbit_make_bytes (MoonBit GC 接管) → stbi_image_free (释放 C 缓冲)
→ 返回 MoonBit Bytes (输出, GC 管理)
```

**为何 wrapper 而非直接 extern "c" 声明 stb_image**：
- stbi_load 的 `int*` 输出参数与 `unsigned char*` 返回值不能直接映射到 MoonBit 值语义
- 拷贝 + 释放的 ownership 转移必须在 C 侧完成（MoonBit 侧无法 stbi_image_free 一个 C 指针）
- 集中处理 ABI 归一化，让 ffi.mbt 声明保持简单

### 5.2 extern "c" 声明设计

**决策**：`ffi.mbt` 中私有声明 `extern "c"` 函数，对应 wrapper.c 的 `MOONBIT_FFI_EXPORT` 函数。

**声明轮廓**：
- 两个 `extern "c" fn` 声明，对应 `stb_image_mbt_load_from_memory` 与 `stb_image_mbt_load_from_path`
- 输入 `Bytes` 标注 `#borrow`（stb 仅在调用期间读取，不存储引用）
- 输出参数用 `Ref[Int]` 标注 `#borrow`（C 写入 Ref，MoonBit 读取 `.val`）
- 返回 `Bytes`（成功时为像素数据，失败时为空 Bytes 或 NULL）
- 私有：不 `pub`，仅供同包 `image_load_native.mbt` 调用
- `targets: ["native"]` 门控

**extern "c" 大小写**（架构设计 D14）：统一为小写 `extern "c"`（与 make-moonbit-c-bindings skill 模板一致）。

**类型映射**（已核实 moonbit_wiki/language/ffi.md C 后端 ABI 表）：
| C 类型 | MoonBit 类型 | 用途 |
|--------|-------------|------|
| `int32_t` | `Int` | width/height/channels、Bytes 长度 |
| `uint8_t*`（输入） | `Bytes`（#borrow） | 输入像素数据/路径字符串 |
| `uint8_t*`（输出） | `Bytes`（GC 管理） | 输出像素数据 |
| `int32_t*`（输出参数） | `Ref[Int]`（#borrow） | width/height/channels 写回 |

### 5.3 Windows 路径编码兼容性

**决策**：在 wrapper.c 中 `#define STBI_WINDOWS_UTF8`（条件编译，仅 Windows 平台），启用 stb_image.h 内置的 UTF-8 路径支持。

**已核实事实**（webfetch stb_image.h）：
- stb_image.h 提供 `STBI_WINDOWS_UTF8` 编译宏，定义后内部 `stbi__fopen` 使用 `_wfopen` 处理 UTF-8 路径
- 提供 `stbi_convert_wchar_to_utf8` 函数将 `wchar_t*` 转为 UTF-8
- MoonBit `String` 在 native 后端为 UTF-8 编码的 `Bytes`，可直接传递给 `stbi_load` 的 `const char*` 参数

**方案**：
- wrapper.c 中条件定义：`#if defined(_WIN32) \n #define STBI_WINDOWS_UTF8 \n #endif`
- MoonBit 侧 `load_from_path(path : String)` 将 `String` 转为 `Bytes`（UTF-8）传递给 C wrapper
- C wrapper 直接传递给 `stbi_load`（stb_image 内部处理 UTF-8 → wchar_t 转换）

**理由**：利用 stb_image.h 内置机制，无需在 wrapper 侧重新实现宽字符转换，跨平台兼容性最佳。

**FileIO 错误区分**（架构设计 D2 第 4 子点）：
- `stbi_load` 在文件无法打开时返回 NULL（内部 `stbi__fopen` 失败）
- C wrapper 在 `stbi_load` 返回 NULL 时，无法直接区分"文件不存在"与"解码失败"
- **MVP 策略**：path 入口在 MoonBit 侧预检查文件可读性（用 MoonBit 标准库的 `@fs` 或 `try ... catch` 文件读取），预检查失败 → `raise LoadError::FileIO(...)`；预检查通过但 stbi_load 返回 NULL → `raise LoadError::DecodeFailed(...)`
- 此策略将 FileIO 与 DecodeFailed 的区分放在 MoonBit 侧（预检查），而非 C wrapper 侧（errno 检查），简化 wrapper 实现

---

## 六、安全 API 层方案

### 6.1 `Image` 类型轮廓

**决策**：`pub(all) struct`，derive `Eq` 与 `@debug.Debug`，不 derive `Show`（架构设计 D3）。

**字段轮廓**（需求文档 §二、MVP 范围）：
- `width : Int`
- `height : Int`
- `channels : Int`（原始通道数，1/2/3/4，不归一化）
- `data : Bytes`（像素数据，长度 = width * height * channels）

**类型形态**：`struct`（值类型），非 `enum`/`type`/`suberror`。理由：数据的简单聚合，无不变式、无资源释放（`data : Bytes` 由 GC 接管），值语义符合"解码快照"的领域直觉。

**导出级别**：`pub(all)` 允许外部构造与字段访问（完整库 write 路径需接收 `Image` 输入，调用者可能从其他来源拼装 `Image`）。

**derive 决策**：
- `Eq`：支持测试断言 `assert_eq(loaded, expected)`
- `@debug.Debug`：支持 `debug_inspect` 用于测试快照与调试
- 不 derive `Show`：`Image.data` 可能很大，完整字符串化不适用

**定义位置**：`src/image_types.mbt`（不门控，全后端可用，架构设计 D13）。

### 6.2 `LoadError` 类型轮廓

**决策**：`pub(all) suberror`，三个构造子（架构设计 D1 + D2）。

**构造子轮廓**：
- `FileIO(String)`：path 入口的文件不存在/不可读/权限不足
- `UnsupportedFormat(String)`：stb_image 无法识别字节序列的图像格式（MVP 阶段不主动构造，保留供 v0.3）
- `DecodeFailed(String)`：格式可识别但数据损坏/不完整，或 stb_image 返回 NULL 的默认归类

**类型形态**：`suberror`（MoonBit 检查式错误），非 `enum`。理由：`suberror` 是 `Error` 的子类型，可直接 `raise`；让错误类型在函数签名中显式声明，调用者无法忽略。

**导出级别**：`pub(all)` 允许外部 `raise` 该错误（如更上层包装）。

**错误描述字符串**：人类可读的**中文提示**（符合项目交互语言偏好），不暴露 C 错误码或 `stbi_failure_reason` 原始字符串（MVP 阶段性限制）。

**定义位置**：`src/image_types.mbt`（不门控，全后端可用）。

### 6.3 `load_from_path` / `load_from_bytes` 设计

**决策**：两个公开函数，`raise LoadError` 抛出错误。

**函数轮廓**：
- `pub fn load_from_path(path : String) -> Image raise LoadError`
- `pub fn load_from_bytes(data : Bytes) -> Image raise LoadError`

**`load_from_path` 流程**：
1. MoonBit 侧预检查文件可读性（用标准库文件 API 或 `try` 读取文件头）：失败 → `raise LoadError::FileIO("文件不存在或不可读: " + path)`
2. 将 `path : String` 转为 UTF-8 `Bytes`（MoonBit String 在 native 后端即 UTF-8）
3. 调用 FFI `stb_image_mbt_load_from_path`（传入 path Bytes + 三个 `Ref[Int]` 接收 width/height/channels）
4. 检查返回的 `Bytes` 是否为空（或 width == 0）：是 → `raise LoadError::DecodeFailed("stb_image 解码返回 NULL，输入可能为不支持的格式或损坏数据")`
5. 构造 `Image { width, height, channels, data }` 返回

**`load_from_bytes` 流程**：
1. 检查 `data` 是否为空：是 → `raise LoadError::DecodeFailed("输入数据为空")`（边界保护）
2. 调用 FFI `stb_image_mbt_load_from_memory`（传入 data + data.length() + 三个 `Ref[Int]`）
3. 检查返回的 `Bytes` 是否为空（或 width == 0）：是 → `raise LoadError::DecodeFailed(...)`
4. 构造 `Image` 返回

**定义位置**：`src/image_load_native.mbt`（门控 `["native"]`，调用 FFI）。

### 6.4 错误处理流程与格式嗅探决策

**决策**：MVP **不纳入**格式嗅探增强，采用默认归类策略（架构设计 D2）。

**MVP 错误区分粒度**：
- `FileIO`：可独立区分（path 入口 MoonBit 侧预检查）
- `UnsupportedFormat` vs `DecodeFailed`：**不可精确区分**，stb_image 返回 NULL 时默认归类为 `DecodeFailed`
- `UnsupportedFormat` 构造子保留但不主动构造（供 v0.3 暴露 `stbi_failure_reason` 后精确区分）

**不纳入格式嗅探的理由**：
- 嗅探需维护 9 种格式的签名表（PNG `\x89PNG\r\n\x1a\n`、JPEG `0xFFD8` 等），增加安全 API 层的格式知识负担
- 嗅探本身可能误判（边缘编码场景）
- MVP 的目标是验证 FFI 可行性，格式嗅探属增强功能，可后版本纳入
- 调用者对 `DecodeFailed` 的典型处理（重新获取源文件、报告输入无效）对"格式不支持"场景同样适用，不会产生误导性处理差异

**权衡**：若后续用户反馈需要精确区分格式不支持，可在 v0.2 或 v0.3 纳入嗅探（不依赖 `stbi_failure_reason`，可在 MVP 后增量实现）。

### 6.5 条件编译策略

**决策**：采用"拆文件"方案实现类型定义全后端可用 + FFI 调用 native 门控（架构设计 D13）。

**文件拆分**：
- `src/image_types.mbt`：`Image`/`LoadError` 类型定义，**不门控**（全后端可用）
- `src/image_load_native.mbt`：`load_from_path`/`load_from_bytes` 实现，**门控 `["native"]`**（调用 FFI）

**理由**：
- MoonBit 的 `targets` 门控以文件为单位，单文件内条件编译不支持
- 拆文件让类型定义在其他后端可见（如 wasm 目标的纯 MoonBit 代码可构造 `LoadError` 用于错误处理）
- FFI 调用仅 native：`extern "c"` 仅 native 后端支持，其他后端调用 FFI 需报编译错误
- 拆文件比单文件内条件编译更清晰，符合 MoonBit 文件组织惯例

**非 native 后端的影响**：
- `image_load_native.mbt` 在非 native 后端不编译，`load_from_path`/`load_from_bytes` 在非 native 后端不可用
- 这是 MVP 的预期行为（完整库 v1.0 才评估多目标支持）
- 调用者在非 native 后端引用 `load_from_*` 会得到"函数未定义"编译错误，符合预期

---

## 七、测试与验证方案

### 7.1 测试图片生成策略

**决策**：由 `scripts/prepare.py`（或独立 `scripts/gen_testdata.py`）生成小尺寸样本，vendoring 到 `testdata/`（架构设计 D4）。

**样本规格**：
- 尺寸：4×4 或 8×8（小尺寸，测试快）
- 格式：PNG、JPEG、BMP、GIF、WebP（5 种常见格式，需求文档 §四）
- 每种格式：1 张正常图片 + 1 张损坏图片
- 损坏样本生成方式：对正常样本施加字节破坏（截断、翻转关键字节、清零魔数）

**生成方式**（实现者决策，技术方案不预设）：
- **脚本生成**：用 Python PIL-Pillow 生成小尺寸样本（需 Python 环境依赖）
- **或手工制作**：预先制作好小尺寸样本，vendoring 到 `testdata/`，脚本仅校验哈希
- **或混合**：正常样本手工制作，损坏样本由脚本从正常样本生成

**技术方案建议**：倾向"手工制作正常样本 + 脚本生成损坏样本"，避免 Python 依赖，损坏样本可确定性生成（截断、翻转字节）。

**testdata 目录结构**：
```
testdata/
├── png/
│   ├── normal.png      # 4×4 纯色 PNG
│   └── corrupt.png     # 截断或魔数破坏的 PNG
├── jpeg/
├── bmp/
├── gif/
└── webp/
```

**测试图片加载方式**：测试代码用 MoonBit 标准库读取 `testdata/` 下文件（相对路径），或 vendored 为 `Bytes` 字面量（若文件小）。实现者根据 MoonBit 测试框架能力选择。

### 7.2 测试层设计

**决策**：遵循 `make-moonbit-c-bindings` skill 的测试层建议。

**测试层轮廓**：
1. **Unit 测试**：安全 MoonBit 验证（空输入拒绝、错误类型匹配）
2. **Smoke 测试**：每个公开 FFI 函数的 happy path（5 种格式正常解码）
3. **Regression 测试**：error path（5 种格式损坏文件 → `LoadError`）
4. **ASan 测试**：C 内存安全（通过 `scripts/run-asan.py`）
5. **Doctest**：`README.mbt.md` 的 `mbt check` 块
6. **幂等测试**：`scripts/prepare.py` 重复运行无 diff

**测试文件门控决策**：
- `image_test.mbt` 调用 `load_from_*`，而 `load_from_*` 仅在 native 后端可用（见 §6.5）
- 若 `image_test.mbt` 不门控，在非 native 后端会因 `load_from_*` 未定义而编译失败
- MoonBit 条件编译以文件为单位，无法在文件内跳过单个测试
- **结论**：`image_test.mbt` 门控到 `["native"]`（`targets: { "image_test.mbt": ["native"] }`），因为测试核心是验证 FFI 行为，仅 native 有意义

**与 §3.3 门控清单的同步**（v2 修订）：§3.3 门控清单已同步本结论，`image_test.mbt` 在 §3.3 与此处均为 `["native"]` 门控，两处表述一致。

### 7.3 ASan 验证

**决策**：采用 `moonbit-c-binding/scripts/run-asan.py`，复制为 `scripts/run-asan.py`。

**ASan 验证关注点**：
- C wrapper 的 `moonbit_make_bytes` 拷贝后是否正确 `stbi_image_free` 原始缓冲（避免泄漏）
- `#borrow` 输入 Bytes 在 C 调用期间是否有效（避免 use-after-free）
- 失败路径（stbi_load 返回 NULL）是否正确清理临时分配
- 输出参数（Ref[Int]）写入是否越界

**ASan 脚本职责**（已核实 `moonbit-c-binding` skill）：
- 临时强制 clang 作为 C 编译器
- 禁用 tcc -run（debug 构建默认用 tcc）
- 设置 `MOON_CC`/`MOON_AR` + ASan 编译/链接标志
- 运行 `moon test --target native`
- 恢复 `moon.pkg`（若脚本修改了配置）

### 7.4 标准验证门

**决策**：遵循 `make-moonbit-c-bindings` skill 的标准验证门。

**验证命令序列**（实现完成后运行）：
```bash
moon fmt                                    # 格式化
moon check --target native --warn-list +73  # 类型检查（native）
moon test --target native                   # 运行测试
python3 scripts/run-asan.py                 # ASan 验证
moon info --target native                   # 生成接口信息
python3 scripts/prepare.py                  # vendoring 幂等性
git status --short                          # 确认无意外 diff
```

**注意**：不使用 `moon check --target all`（因 `supported_targets = "native"` 会阻止其他目标构建，这正是 MVP 期望行为）。

---

## 八、文档方案

### 8.1 SKILL.md 结构

**决策**：参照项目 `.codeartsdoer/skills` 下 SKILL.md 格式（YAML frontmatter + Markdown 正文），架构设计 D6。

**内容轮廓**：
- **YAML frontmatter**：`name`、`description`（包用途简述）
- **包用途**：一句话说明 stb-image 是 stb_image.h 的 MoonBit 原生 FFI 绑定
- **快速开始**：安装命令 + 最小示例（load_from_path + load_from_bytes）
- **API 概览**：`Image`、`LoadError`、`load_from_path`、`load_from_bytes` 的简要说明
- **最小示例**：完整可运行的代码片段
- **错误处理**：`try ... catch LoadError` 模式示例
- **目标后端限制**：MVP 仅 native，说明 wasm/js 支持在 v1.0 评估
- **版本演进路线**：v0.1 → v0.2 → v0.3 → v0.4 → v1.0 的概要

**位置**：项目根目录 `SKILL.md`。

### 8.2 README.mbt.md 文档示例

**决策**：测试过的文档示例，`mbt check` 块（`make-moonbit-c-bindings` skill 惯例）。

**内容轮廓**：
- 包简介
- `mbt check` 块：最小可用示例（load_from_bytes 解码一个小 PNG 字面量，inspect 结果）
- 错误处理示例（try-catch LoadError）

**位置**：`src/README.mbt.md`，门控 `["native"]`（含 FFI 示例）。`README.md` 软链或复制到项目根。

---

## 九、需要验证的技术假设

以下假设在编码实现时需通过实际构建验证：

1. **MoonBit 标准库文件读取 API**：`load_from_path` 的 MoonBit 侧预检查需用标准库文件 API（如 `@fs` 或类似）。需核实 MoonBit v0.10.5 native 后端可用的文件读取 API（`moonbitlang/core/fs` 或 `moonbitlang/x`）。若标准库无现成 API，可降级为"不预检查，直接调用 FFI，失败时统一归为 DecodeFailed"（牺牲 FileIO 区分能力）。

2. **`Ref[Int]` 作为 C 输出参数的 ABI 兼容性**：`moonbit-c-binding` skill 的类型映射表列出 `int *result` → `Ref[T]` with `#borrow`。需在编码时验证 C wrapper 写入 `Ref[Int].val` 的正确性（C 侧通过指针写回，MoonBit 侧读取 `.val`）。

3. **stb_image.h 在 MoonBit native 编译链下的编译兼容性**：stb_image.h 是标准 C99 代码，MoonBit native 后端用 tcc（debug）或 clang/gcc（release）编译。需验证 stb_image.h 在 tcc/clang/gcc 下均能编译通过（特别是 SIMD 代码路径）。

4. **`moonbit_make_bytes` 的 `init` 参数语义**：`moonbit_make_bytes(int32_t size, int value)` 的 `value` 参数用于初始化字节值。wrapper 创建输出 Bytes 时应传 `0`（零初始化），随后 `memcpy` 覆盖。需验证 `init=0` 不会影响 `memcpy` 后的数据正确性。

5. **空 Bytes 作为失败信号的可靠性**：C wrapper 在 stbi_load 返回 NULL 时返回 `moonbit_make_bytes(0, 0)`（零长度 Bytes）或 NULL。需验证 MoonBit 侧检查 `Bytes` 是否为空（`bytes.length() == 0`）的可靠性，以及 NULL 返回在 MoonBit 侧的表现（是否需要包装为 `Bytes?` 或统一返回空 Bytes）。

6. **testdata 文件在测试中的访问路径**：MoonBit 测试运行时的工作目录与 `testdata/` 的相对路径关系需验证。若测试无法通过相对路径访问 `testdata/`，可能需将测试图片 vendored 为 `Bytes` 字面量（base64 编码嵌入测试代码）。

---

## 十、版本演进技术支撑

本技术方案的 MVP 决策如何支撑后续版本迭代（需求文档 §六）：

### v0.2（write + req_channels）技术支撑
- **vendoring 脚本预留 `--include-write`**：§4.4 已预留，v0.2 激活即可
- **wrapper.c 预留条件编译块**：v0.2 纳入 `stb_image_write.h` 的 IMPLEMENTATION 宏
- **包结构保持单包**：架构设计 D7，v0.2 按文件分职责（`image_load.mbt` / `image_write.mbt`），不拆子包
- **`req_channels` 参数**：v0.2 在 `load_from_*` 增加可选参数，C wrapper 透传 `desired_channels`

### v0.3（16-bit / float / info / 配置 / PNM）技术支撑
- **类型定义全后端可用**：§6.5 拆文件策略让 `Image16`/`ImageF` 等新类型可定义在 `image_types.mbt`，全后端可见
- **little-endian 编码**：架构设计 D8，C wrapper 直接 `memcpy`（native 平台 little-endian，零开销）
- **`stbi_failure_reason` 暴露**：v0.3 可在 wrapper 增加 `stb_image_mbt_failure_reason` 函数，返回 C 字符串为 `Bytes`，MoonBit 侧 `@utf8.decode_lossy` 转为 `String`，用于精确区分 `UnsupportedFormat` 与 `DecodeFailed`

### v0.4（callbacks / 动画 GIF）技术支撑
- **`IoCallbacks` trait**：架构设计 D9，涉及 C→MoonBit 反向调用（trampoline），需 `moonbit_incref`/`moonbit_decref` 管理回调状态生命周期
- **FFI 边界层扩展**：wrapper.c 增加 callbacks 相关函数，ffi.mbt 增加对应 `extern "c"` 声明
- **单包结构仍可容纳**：callbacks 作为安全 API 层新抽象，不改变分层结构

### v1.0（多目标支持）技术支撑
- **类型定义全后端可用**：§6.5 拆文件策略让 `Image`/`LoadError` 在 wasm/js 后端可用，为多目标提供类型基础
- **`supported_targets` 可扩展**：§2.2 采用包级 `supported_targets = "native"`，v1.0 评估多目标时可改为 `"+native+wasm"` 或移除限制
- **FFI 边界层按目标分文件门控**：v1.0 若纳入 wasm/js，可引入 `src/wasm/` 子目录承载 Emscripten 产物，`targets` 门控按目标编译不同 FFI 实现

---

## 十一、与架构设计决策的对应

| 架构设计决策 | 本技术方案落实 |
|------------|-------------|
| D1. `LoadError` 统一并入 FileIO | §6.2 三构造子，FileIO 独立区分（path 入口预检查） |
| D2. C wrapper 错误信号 + 默认归类 + 格式嗅探 + Windows | §5.1 失败信号（NULL + 零尺寸输出参数）、§6.4 不纳入嗅探、§5.3 STBI_WINDOWS_UTF8 |
| D3. `Image` pub(all) + derive Eq/Debug | §6.1 类型轮廓 |
| D4. 测试图片脚本生成 | §7.1 testdata 生成策略 |
| D5. vendoring 固定 commit hash | §4.2 版本固定策略 |
| D6. SKILL.md 参照技能格式 | §8.1 SKILL.md 结构 |
| D7. MVP 单包，v0.2 保持单包 | §3.1 文件布局，单包按文件分职责 |
| D8. 16-bit/float little-endian | §10 v0.3 技术支撑 |
| D9. IoCallbacks 留待 v0.4 | §10 v0.4 技术支撑 |
| D10. 多目标留待 v1.0 | §10 v1.0 技术支撑 |
| D11. 零拷贝留待 v1.0 | MVP 允许拷贝，§5.1 所有权转移流程 |
| D12. write 回调留待 v0.2 | §10 v0.2 技术支撑 |
| D13. ffi.mbt 门控 native，类型定义全后端 | §6.5 拆文件条件编译策略 |
| D14. extern "c" 小写 | §5.2 统一小写 |

---

## 十二、设计原则遵循说明

- **决策明确**：所有技术选型（工具链版本、配置格式、目标后端、vendoring 策略、FFI 机制、类型轮廓、错误处理、测试策略、文档结构）均已确定，不存在需实现者自行探索的方向性问题
- **路径清晰**：实现者知道该走哪条技术路径（新 DSL 语法、单头文件 vendoring、C wrapper ABI 归一化、拆文件条件编译、脚本生成测试图片、ASan 验证）
- **准确可信**：涉及的技术选型决策经过文档或代码验证（moonbit_wiki、llvm.mbt 先例、stb_image.h 上游、moonbit.h 头文件、skill 模板）
- **深度适当**：停留在决策层，不深入实现层（未给出完整代码片段、逐字段类型定义、逐方法签名）
- **不凭假设设计**：关键决策（moon.mod/moon.pkg 新 DSL 语法、supported_targets 语法、moonbit_make_bytes 签名、stb_image.h API、STBI_WINDOWS_UTF8 机制）均通过查阅文档或代码确认

---

## 修订说明（v2）

基于 `deliberations/202608060953_tech-v1-review/output_v1.md` 的独立审查报告（APPROVED_WITH_MINOR_ISSUES），对 v1 进行修订。审查报告发现 4 个问题，处理如下：

| 问题 | 审查意见摘要 | 处理方式 | 修订位置 |
|------|------------|---------|---------|
| 问题 1 | §2.2 未明确引用 c-binding skill 的"勿用 supported-targets"提示，实现者若同时查阅该 skill 可能困惑 | **修改**：在 §2.2 权衡段后新增"与 c-binding skill 提示的关系"段落，明确引用该提示并解释为何对本项目（native-only FFI 绑定）不适用 | §2.2 末尾 |
| 问题 2 | supported_targets 语法：架构设计 D13 末尾"`+native`"提示本身错误，tech_v1 §2.2 正向纠偏 | **保留+确认**：这是 v1 的亮点，tech_v2 维持 §2.2 原决策（`"native"` 排他性声明）。建议后续修订 design_v3.md D13 末尾错误提示（不在本次技术方案修订范围） | §2.2（未改动，记录确认） |
| 问题 3 | §3.3 门控清单 `image_test.mbt` 标注"不门控"与 §7.2 修正结论"`["native"]`"不同步 | **修改**：§3.3 门控清单表 `image_test.mbt` 行改为 `["native"]`，理由改为"测试调用 `load_from_*`，仅 native 可用（见 §7.2）"；§3.1 文件布局注释同步；§7.2 表述整理为决策结论 + 与 §3.3 同步说明 | §3.1、§3.3 门控清单、§7.2 测试文件门控 |
| 问题 4 | §3.3 将 `options("native-stub": ...)` 与 `options(targets: ...)` 分两行分写，可能误解为两个独立块 | **修改**：§3.3 配置项轮廓合并为单一 `options(...)` 块示意，并注明"`native-stub` 与 `targets` 在同一 `options(...)` 块内"，引用 `package-management.md:63-75` | §3.3 配置项轮廓 |

**未修订部分**：审查报告 8 维度中 7 项通过、1 项基本通过，所有通过部分的技术内容均保留不变，仅做上述三处定点修订与必要的同步表述调整。既有约束（技术方案级别定位、"只参考不引用已有库"、MoonBit v0.10.5 规范、FFI 最佳实践、版本迭代技术支撑）全部保留。