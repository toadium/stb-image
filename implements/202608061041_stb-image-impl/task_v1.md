# 任务指令（v1）

## 动作
NEW

## 任务描述

创建 stb-image 项目的 **Vendoring 层 + 项目骨架**，这是四层架构（Vendoring → FFI 边界 → 安全 API → 测试文档）的最底层依赖。

需创建以下文件：

### 1. `moon.mod`（模块配置，新 DSL 语法）

依据技术方案 §3.2。配置项：
- `name`：`<user>/stb-image`（user 可暂用 `stb-image` 占位，发布前再定）
- `version`：`0.1.0`
- `preferred_target = "native"`（下划线，新 DSL；非旧 JSON 的 `"preferred-target"`）
- `license`：`Public Domain`（stb_image 本身为 public domain）或 `MIT`
- `description`：`MoonBit native FFI bindings for stb_image.h`
- `keywords`：`["image", "stb", "ffi", "native"]`
- **不设 `readme` 行**：本任务不创建 `src/README.mbt.md`（后续任务创建），避免 `readme` 指向不存在文件导致 `moon check` 报错或处于"通过但配置语义不完整"的灰色状态。后续任务创建 `src/README.mbt.md` 时再追加 `readme = "README.mbt.md"` 行
- **不设模块级 `supported_targets`**：让包级 `moon.pkg` 的 `supported_targets = "native"` 生效

### 2. `src/moon.pkg`（包配置，新 DSL 语法）

依据技术方案 §3.3。配置项：
- `supported_targets = "native"`（包级声明仅支持 native，排他性，与 llvm.mbt 先例一致；非 `"+native"`）
- **不声明 `options(...)` 块（渐进式声明策略）**：本任务不创建 `wrapper.c`、`ffi.mbt`、`image_load_native.mbt`、`image_test.mbt`、`README.mbt.md`（均后续任务创建）。若 `moon.pkg` 提前声明 `native-stub` 或 `targets` 引用这些不存在文件，`moon check` 将因悬空引用而失败。故本任务 `moon.pkg` 仅声明 `supported_targets = "native"`，彻底消除悬空引用，确保本任务完成后 `moon check` 通过（与验收标准一致）
- **后续任务渐进追加**（MoonBit moon.pkg DSL 要求 `native-stub` 与 `targets` 在同一 `options` 块内，追加时合并到单一 `options(...)` 块）：
  - 创建 `wrapper.c` 时追加 `options("native-stub": ["wrapper.c"])`
  - 创建 `ffi.mbt` 时在 `options` 块追加 `targets: { "ffi.mbt": ["native"] }`
  - 创建 `image_load_native.mbt` 时追加对应 `targets` 条目
  - 创建 `image_test.mbt` 时追加对应 `targets` 条目
  - 创建 `README.mbt.md` 时追加对应 `targets` 条目，并在 `moon.mod` 追加 `readme = "README.mbt.md"` 行

### 3. `scripts/prepare.py`（vendoring 脚本）

依据技术方案 §4.1-§4.4。脚本职责：
1. 下载 pinned `stb_image.h`（按 git commit hash 固定 URL）到 `.prepare/` 缓存目录
   - 下载 URL：`https://raw.githubusercontent.com/nothings/stb/<commit-hash>/stb_image.h`
    - **实现者需确定具体 commit hash**：建议选 stb_image.h v2.30（2024-05-31）对应的近期稳定 commit。可通过 `git ls-remote https://github.com/nothings/stb` 或查阅上游 release tag 确定。脚本中硬编码 commit hash + SHA256，附注释记录 commit 日期与版本标识
    - **SHA256 确定流程**：先在脚本外（如 `curl -sL https://raw.githubusercontent.com/nothings/stb/<commit-hash>/stb_image.h | sha256sum`）下载目标 commit 的 `stb_image.h` 并计算其 SHA256，再将 commit hash + SHA256 一并硬编码入脚本。脚本本身始终执行严格校验，**不存在"未回填跳过校验"的中间态**——首次运行即对硬编码哈希严格校验，若哈希不匹配则非零退出
2. SHA256 校验（哈希硬编码于脚本，不匹配则非零退出，**不自动回退**到其他版本）
3. 读取现有 `src/stb_image.h`（若存在），与下载内容比较；仅当内容不同时写入（幂等，避免时间戳变化产生 tracked diff）
4. 复制到 `src/stb_image.h`（保留原名，不扁平化）
5. 预留 `--include-write` 命令行参数：不带参数仅 vendoring stb_image.h；带参数时额外下载 `stb_image_write.h` 到 `src/stb_image_write.h`（v0.2 激活，本任务仅预留参数骨架，不实际下载 write 头文件）

脚本要求：
- Python 3，跨平台可移植
- 失败时非零退出
- 幂等：重复运行无 tracked diff
- 附注释说明版本固定策略与 SHA256 校验目的

### 4. `src/stb_image.h`（vendored 上游头文件）

由运行 `python3 scripts/prepare.py` 生成。本任务需实际运行脚本下载并校验。

### 5. `.gitignore`（忽略缓存目录与构建产物）

至少包含：
```
.prepare/
target/
.mooncakes/
```
注：`target/` 为 MoonBit 构建产物目录，`.mooncakes/` 为 mooncakes 依赖缓存，均不应纳入版本控制。

## 选择理由

Vendoring 层是四层架构的最底层依赖。FFI 边界层（wrapper.c/ffi.mbt）需要 `#include "stb_image.h"`，安全 API 层与测试层都需要项目配置（moon.mod/moon.pkg）才能编译。没有项目骨架与 vendored 头文件，后续任何 MoonBit/C 代码都无法构建。按"底层优先、依赖单向向下"原则，这是第一个任务。

本任务产物紧密相关：项目配置（moon.mod/moon.pkg）+ vendoring 脚本（prepare.py）+ vendored 头文件（stb_image.h）共同构成"项目骨架 + Vendoring 层"，是后续所有任务的基础设施。

## 任务上下文

摘录需求文档/架构设计/技术方案中与本任务直接相关的决策：

### 技术方案 §2.1 工具链版本
- 采用 MoonBit v0.10.5 规范，新格式 `moon.mod`/`moon.pkg` DSL 语法（非旧 `moon.mod.json`/`moon.pkg.json`，后者在 v0.10.4 弃用）
- `moon.mod` 新 DSL：`preferred_target = "native"`（下划线）
- `moon.pkg` 新 DSL：`options("native-stub": [...], targets: { ... })`

### 技术方案 §2.2 目标后端策略
- MVP 仅 native 后端
- `moon.mod` 设 `preferred_target = "native"`
- `moon.pkg` 设 `supported_targets = "native"`（包级声明仅支持 native，排他性，与 llvm.mbt 先例一致）
- 不设模块级 `supported_targets`

### 技术方案 §2.3 stb_image.h Vendoring 策略
- stb_image.h 是**单头文件库**（header-only），使用时需在一个 C 文件中 `#define STB_IMAGE_IMPLEMENTATION` 然后 `#include "stb_image.h"` 生成实现
- 无需 vendoring 多个 `.c` 文件，只需一个 `.h` 文件
- `scripts/prepare.py` 下载 pinned `stb_image.h` 到 `src/stb_image.h`（保留原名，不扁平化）
- `moon.pkg` 的 `native-stub` 仅列 `wrapper.c`（stb_image.h 通过 `#include` 被 wrapper.c 纳入编译，无需单独列出）
- stb_image.h 放在 `src/` 目录（与 wrapper.c 同目录，便于 `#include "stb_image.h"`）

### 技术方案 §4 Vendoring 方案
- §4.1 prepare.py 脚本设计：基于 make-moonbit-c-bindings/templates/prepare.py 改造，适配单头文件库特性（无需扁平化、无需 include 重写、无需刷新 native-stub 列表）
- §4.2 版本固定策略：固定为 nothings/stb 仓库特定 git commit hash，建议 v2.30（2024-05-31）对应近期稳定 commit，硬编码 commit hash + SHA256
- §4.3 幂等性保证：先读后比再写策略，下载到 .prepare/ 缓存（.gitignore 忽略），仅当内容不同时写入
- §4.4 --include-write 扩展预留：脚本支持 --include-write 参数，v0.2 激活

### 架构设计 §3.5 Vendoring 脚本职责
- 下载 pinned 版本的 stb_image.h（按 git commit hash 固定，SHA256 校验）
- 将头文件复制到 src/ 目录
- 幂等：重复运行无 tracked diff
- 失败时非零退出，不自动回退
- 预留多文件扩展能力（--include-write 参数）

### 需求文档 §四验收标准（本任务相关部分）
- `moon check` 通过：本任务采用渐进式声明策略，`moon.mod` 不设 `readme` 行、`moon.pkg` 仅声明 `supported_targets = "native"` 不声明 `options` 块，无悬空引用，本任务完成后 `moon check` 应通过
- vendoring 脚本幂等：重复运行 scripts/prepare.py 无 tracked diff

## 已有代码上下文

项目根目录 `D:\CodeWorkspace\forMoonbit\stb-image` 当前状态：
- 仅有 `image-mbt/`（参考实现，**不引用**）、文档目录（`deliberations/`、`designs-oo/`、`designs-tech/`、`implements/`、`instructions/`、`requirements/`）、`README.md`、`LICENSE`、`req.md`、`需求文档.md`
- **无任何 MoonBit 项目文件**（无 moon.mod、无 src/moon.pkg、无 .mbt/.c/.h 文件）
- git 仅有 Initial commit，所有内容均为 untracked

本任务从零创建项目骨架。参考（不引用）：
- `image-mbt/` 的 moon.mod/moon.pkg 结构（纯 MoonBit 包，非 FFI 绑定，仅参考 DSL 语法）
- `D:\CodeWorkspace\moonbit_wp` 下 llvm.mbt 等 native FFI 绑定项目先例（参考 moon.pkg 的 native-stub + supported_targets 配置）
- make-moonbit-c-bindings skill 模板的 prepare.py（参考 vendoring 脚本结构）

---

## 修订说明（v1 r1）

| 审查意见 | 修改措施 |
|---------|---------|
| 发现 1：`moon.mod` 的 `readme` 字段用"若 moon check 报错可先省略"的试探表述，策略含糊 | 删除试探表述，明确"本任务 `moon.mod` 不设 `readme` 行"，并注明"后续任务创建 `src/README.mbt.md` 时再追加 `readme = "README.mbt.md"` 行" |
| 发现 2：`moon.pkg` 的 `options(targets: {...})` 块给出两个互斥方案，以"由实现者根据 moon check 行为决定"收尾，策略未定 | 明确采用"渐进式声明"策略：本任务 `moon.pkg` 仅声明 `supported_targets = "native"`，不声明 `options(...)` 块；列出后续任务渐进追加 `native-stub` 与 `targets` 条目的明确清单 |
| 发现 3：降级方案保留 `options("native-stub": ["wrapper.c"])`，仍引用不存在的 `wrapper.c`，降级不彻底 | 与发现 2 合并修正：本任务 `moon.pkg` 不声明任何 `options` 块，`native-stub` 与 `targets` 均待后续任务创建对应文件时再追加，彻底消除悬空引用 |
| 发现 4：`plan.md` 仅列 R1，缺后续任务路线图概览 | 同步更新 `plan.md`，在 R1 任务后追加"后续任务路线图"段，列出 R2/R3/R4 方向 |
| 发现 5：`prepare.py` 的"先下载计算哈希后回填"路径破坏"硬编码哈希 + 首次运行校验"不变式 | 明确 SHA256 确定流程："先在脚本外下载目标 commit 的 `stb_image.h` 并计算 SHA256，再将 hash + SHA256 一并硬编码入脚本"，脚本本身始终执行严格校验，不存在"未回填跳过校验"的中间态 |
| 连带修订：验收标准中"`moon check` 可能不完全通过"与渐进式声明策略矛盾 | 修订验收标准描述为"本任务完成后 `moon check` 应通过"，并注明依据渐进式声明策略无悬空引用 |

---

## 修订说明（v1 r2）

| 审查意见 | 修改措施 |
|---------|---------|
| 发现 1（一般）：`plan.md` R3 路线图留下"单文件 vs 拆文件"可选项（`src/image.mbt`（或拆为 ...）），与技术方案 §6.5 已明确的"拆文件"决策矛盾，可能误导后续 R3 计划 agent 选择单文件方案，破坏"类型定义全后端可用 + FFI 调用 native 门控"的条件编译策略 | 同步更新 `plan.md` R3 路线图：删除"创建 `src/image.mbt`（或拆为 ...）"的可选项表述，明确改为"创建 `src/image_types.mbt`（`Image` struct + `LoadError` suberror 类型定义，不门控，全后端可用）+ `src/image_load_native.mbt`（`load_from_path`/`load_from_bytes` 公开 API 实现 + 错误映射，native 门控）"，并明确 `moon.pkg` 的 `targets` 仅对 `image_load_native.mbt` 门控、`image_types.mbt` 不门控，与技术方案 §6.5 和 §3.1 文件布局保持一致 |
| 发现 2（轻微）：`plan.md` R4 路线图遗漏 `scripts/run-asan.py` 的创建，仅提"运行 ASan 验证" | 同步更新 `plan.md` R4 路线图：在创建清单中补充 `scripts/run-asan.py`（从 `moonbit-c-binding` skill 复制 ASan 验证脚本），保持路线图完整性 |
| 发现 3（轻微）：`plan.md` R2 路线图 moon.pkg 追加表述"追加 `options("native-stub": ["wrapper.c"])` 与 `targets: { "ffi.mbt": ["native"] }`"可能被误解为两个独立块 | 同步更新 `plan.md` R2 路线图：明确表述为"向 `moon.pkg` 的单一 `options(...)` 块追加 `"native-stub": ["wrapper.c"]` 与 `targets: { "ffi.mbt": ["native"] }`（两者合并到同一 `options` 块，非两个独立块）"，与 task_v1.md 第 29 行的合并要求一致 |
| 发现 4（轻微）：task_v1.md `.gitignore` 仅要求包含 `.prepare/`，未提及 MoonBit 常见构建产物忽略项（如 `target/`） | 修订 task_v1.md `.gitignore` 部分：补充 `target/`（MoonBit 构建产物目录）与 `.mooncakes/`（mooncakes 依赖缓存）忽略项，并附注释说明用途，为项目长期健康补充 |