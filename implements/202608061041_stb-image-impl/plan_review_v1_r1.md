# 计划审查报告（v1 r1）

## 审查结果
REJECTED

## 发现

### [一般] 发现 1：`moon.mod` 的 `readme` 字段策略含糊试探

`task_v1.md` 第 21 行对 `readme = "README.mbt.md"` 的处理表述为："README 暂可不存在，后续任务创建；若 moon check 报错可先省略此行或后续补"。

**问题**：本任务（R1）不创建 `README.mbt.md`（后续任务创建），但 `moon.mod` 若声明 `readme = "README.mbt.md"` 指向不存在的文件，`moon check` 大概率报错。task 用"若...可..."的试探性表述将判断推给实现者，而这是计划阶段应已明确的事项——本任务产物清单是否包含 `README.mbt.md` 是确定的（不包含），因此 `readme` 行是否应出现也是确定的。

**为什么是问题**：实现者需实际运行 `moon check` 试探行为，浪费往返；且"若报错可先省略"隐含"不报错则保留"，但保留一个指向不存在文件的 `readme` 行会让本任务的 `moon check` 处于"通过但配置语义不完整"的灰色状态，与验收标准"`moon check` 通过"的语义模糊。

**期望的修正方向**：明确采用"最小化声明"策略——本任务 `moon.mod` **不设 `readme` 行**，并在任务中注明"后续任务创建 `src/README.mbt.md` 时再追加 `readme = "README.mbt.md"` 行"。删除"若...可..."试探表述。

---

### [一般] 发现 2：`moon.pkg` 的 `options` 块声明策略未定，把决策推给实现者

`task_v1.md` 第 42 行对 `moon.pkg` 的 `options(targets: {...})` 块给出两个互斥方案，并以"**由实现者根据 moon check 行为决定**"收尾。

**问题**：本任务产物不包含 `wrapper.c`、`ffi.mbt`、`image_load_native.mbt`、`image_test.mbt`、`README.mbt.md`（均后续任务创建）。无论采用哪个方案，`moon.pkg` 都会引用本任务不创建的文件：
- 方案 A（提前声明全部 targets + native-stub）：`moon check` 因引用不存在文件而失败
- 方案 B（降级，仅声明 `supported_targets` + `options("native-stub": ["wrapper.c"])`）：`native-stub` 仍引用不存在的 `wrapper.c`，`moon check` 同样失败

两个方案均不能让本任务 `moon check` 通过，且 task 未明确选定其一，让实现者自行试探 `moon` 行为后决定。计划阶段应给出确定策略。

**为什么是问题**：这是本任务的核心产物之一（`moon.pkg`），其内容应在计划中确定而非留给实现者试探。含糊策略会导致实现者反复修改 `moon.pkg`、反复运行 `moon check`，且不同实现者可能产出不同的 `moon.pkg`，破坏计划的可重复性。

**期望的修正方向**：明确采用"渐进式声明"策略——本任务 `moon.pkg` 仅声明 `supported_targets = "native"`，**不声明 `options(...)` 块**（`native-stub` 与 `targets` 均不出现）。在任务中注明：后续任务创建 `wrapper.c` 时追加 `options("native-stub": ["wrapper.c"])`；创建各 `.mbt`/`README.mbt.md` 文件时追加 `targets` 块对应条目。这样本任务 `moon check` 可通过（无悬空引用），且 `moon.pkg` 随后续任务渐进完善。同时明确：本任务完成后 `moon check` 应通过（与验收标准一致），而非"预期失败"。

---

### [一般] 发现 3：`moon.pkg` 降级方案仍引用不存在的 `wrapper.c`，降级不完整

`task_v1.md` 第 42 行给出的降级方案为"先只声明 `supported_targets = "native"` 与 `options("native-stub": ["wrapper.c"])`"。

**问题**：`wrapper.c` 在本任务中不创建（后续 FFI 边界层任务创建）。降级方案保留了 `native-stub: ["wrapper.c"]`，仍引用不存在文件，降级不彻底——若 `moon` 要求 `native-stub` 列出文件必须存在，降级方案同样失败。

**为什么是问题**：降级方案的目的是覆盖"moon 要求引用文件必须存在"的场景，但该方案本身未覆盖 `native-stub` 的悬空引用，降级形同虚设。实现者按降级方案执行仍会遇到 `moon check` 失败，且失败原因（`native-stub` 引用不存在）比原方案更隐蔽。

**期望的修正方向**：与发现 2 合并修正——采用"渐进式声明"，本任务 `moon.pkg` 不声明任何 `options` 块，`native-stub` 与 `targets` 均待后续任务创建对应文件时再追加。彻底消除悬空引用。

---

### [轻微] 发现 4：`plan.md` 仅列 R1，缺后续任务路线图概览

`plan.md` 仅含 R1 任务，无 R2 及之后的任务大纲。虽渐进式规划每轮聚焦一个任务是 harness 常规模式，但 `plan.md` 完全不提后续方向（FFI 边界层 → 安全 API 层 → 测试文档层），审查者难以判断 R1 的拆分粒度与依赖顺序是否合理置于整体规划中。

**为什么是问题**：不影响 R1 本身正确性，但降低计划的可审查性。`plan.md` 开头的"任务描述"是整个 MVP 的描述，读者期望看到该任务在整体中的位置。

**期望的修正方向**：`plan.md` 增加简短的"后续任务路线图"段（一行即可，如"R2 FFI 边界层（wrapper.c + ffi.mbt）→ R3 安全 API 层（image_types.mbt + image_load_native.mbt）→ R4 测试与文档层"），不展开细节。

---

### [轻微] 发现 5：`prepare.py` 的 commit hash 与 SHA256 确定流程可更明确

`task_v1.md` 第 49-50 行要求实现者确定 stb_image.h v2.30 对应的 commit hash 与 SHA256，给出"可通过 `git ls-remote` 或查阅上游 release tag 确定"与"若无法预先确定 SHA256，可先下载计算哈希后回填脚本"两条路径。

**问题**：两条路径中"先下载计算哈希后回填"会破坏脚本的"硬编码哈希 + 首次运行校验"不变式——首次运行时脚本哈希尚未回填，校验逻辑需特殊处理"未回填则跳过校验"，与"SHA256 校验是脚本核心职责"的表述矛盾。task 未说明这一特殊处理。

**为什么是问题**：不影响正确性（实现者可自行处理），但"先下载后回填"路径的校验语义需要实现者额外设计，task 未提示。

**期望的修正方向**：明确采用"先在脚本外下载目标 commit 的 stb_image.h，计算 SHA256，再将 hash + SHA256 硬编码入脚本"流程，脚本本身始终执行严格校验，不存在"未回填跳过校验"的中间态。task 可一句话点明此流程。

## 修改要求（仅 REJECTED 时）

### 问题 1（readme 字段策略含糊）
- **问题是什么**：`moon.mod` 的 `readme` 行用"若 moon check 报错可先省略"的试探性表述，未明确本任务是否设置该行。
- **为什么是问题**：本任务不创建 `README.mbt.md`，`readme` 行是否应出现是确定的，不应留给实现者试探 `moon check` 行为。含糊表述增加实现往返且可能产出灰色状态（`moon check` 通过但配置语义不完整）。
- **期望的修正方向**：明确"本任务 `moon.mod` 不设 `readme` 行，后续任务创建 `src/README.mbt.md` 时再追加"，删除"若...可..."试探表述。

### 问题 2（moon.pkg options 块策略未定）
- **问题是什么**：`moon.pkg` 的 `options(targets: {...})` 块给出两个互斥方案，以"由实现者根据 moon check 行为决定"收尾，未明确选定其一。
- **为什么是问题**：`moon.pkg` 是本任务核心产物，其内容应在计划中确定。两个方案均引用本任务不创建的文件，`moon check` 均失败，实现者需反复试探，且不同实现者可能产出不同 `moon.pkg`，破坏计划可重复性。
- **期望的修正方向**：明确采用"渐进式声明"——本任务 `moon.pkg` 仅声明 `supported_targets = "native"`，不声明 `options(...)` 块。后续任务创建对应文件时再追加 `native-stub` 与 `targets` 条目。本任务完成后 `moon check` 应通过。

### 问题 3（降级方案仍引用不存在的 wrapper.c）
- **问题是什么**：降级方案保留 `options("native-stub": ["wrapper.c"])`，而 `wrapper.c` 本任务不创建，降级不彻底。
- **为什么是问题**：降级方案旨在覆盖"moon 要求引用文件必须存在"的场景，但自身仍含悬空引用，形同虚设。实现者按降级执行仍遇 `moon check` 失败，且失败更隐蔽。
- **期望的修正方向**：与问题 2 合并——本任务 `moon.pkg` 不声明任何 `options` 块，彻底消除悬空引用。