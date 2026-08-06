# 计划审查报告（v1 r2）

## 审查结果
REJECTED

## 发现

- **[一般]** plan.md R3 路线图留下"单文件 vs 拆文件"可选项，与技术方案 §6.5 的明确决策矛盾。plan.md 第 28 行表述为"创建 `src/image.mbt`（或拆为 `image_types.mbt` + `image_load_native.mbt`）"，但技术方案 §6.5 已明确决策采用"拆文件"方案（`src/image_types.mbt` + `src/image_load_native.mbt`），§3.1 文件布局也仅列出这两个文件、无 `image.mbt`。plan.md 虽声明"路线图仅给出方向与依赖顺序"，但路线图作为后续轮次计划 agent 的指导文件，不应留下与技术方案已决事项矛盾的可选项，否则后续 R3 计划 agent 可能忽略技术方案决策、选择"单文件"方案，导致偏离技术方案 §6.5 的条件编译策略（类型定义全后端可用 + FFI 调用 native 门控）。

- **[轻微]** plan.md R4 路线图遗漏 `scripts/run-asan.py` 的创建。plan.md 第 29 行 R4 描述"运行 ASan 验证"，但未提及创建 `scripts/run-asan.py`（技术方案 §7.3 要求从 `moonbit-c-binding` skill 复制）。虽 R4 具体任务在后续轮次拆分时可补充，但路线图应提及此脚本创建方向以保持完整性。

- **[轻微]** plan.md R2 路线图 moon.pkg 追加表述不够精确。plan.md 第 27 行表述"追加 `options("native-stub": ["wrapper.c"])` 与 `targets: { "ffi.mbt": ["native"] }`"可能被误解为两个独立块，但 task_v1.md 第 29 行已明确要求 `native-stub` 与 `targets` 合并到单一 `options(...)` 块。task_v1.md 已澄清，实际执行不会出错，但 plan.md 表述可更精确。

- **[轻微]** task_v1.md `.gitignore` 仅要求包含 `.prepare/`，未提及 MoonBit 常见构建产物忽略项（如 `target/`）。不影响 R1 任务验收（`moon check` 不产生构建产物），但为项目长期健康可补充。

## 修改要求（仅 REJECTED 时）

### 问题 1：plan.md R3 路线图与技术方案 §6.5 矛盾

**问题是什么**：plan.md 第 28 行 R3 路线图表述"创建 `src/image.mbt`（或拆为 `image_types.mbt` + `image_load_native.mbt`）"，留下"单文件 vs 拆文件"两个可选项。但技术方案 §6.5 已明确决策"采用'拆文件'方案"，§3.1 文件布局也仅列出 `image_types.mbt` + `image_load_native.mbt`。

**为什么是问题**：plan.md 的"后续任务路线图"是后续轮次计划 agent 制定 R3 任务时的指导文件。若路线图留下与技术方案已决事项矛盾的可选项，后续 R3 计划 agent 可能仅依据路线图选择"单文件"方案（`src/image.mbt`），而忽略技术方案 §6.5 的"拆文件"决策。这会导致：
- `Image`/`LoadError` 类型定义与 FFI 调用混在同一文件，无法实现"类型定义全后端可用 + FFI 调用 native 门控"的条件编译策略（架构设计 D13）
- `moon.pkg` 的 `targets` 门控无法按技术方案 §3.3 的门控清单配置（`image_types.mbt` 不门控、`image_load_native.mbt` 门控 `["native"]`）
- 偏离技术方案 §6.5 的明确决策

**期望的修正方向**：plan.md 第 28 行 R3 路线图应删除"创建 `src/image.mbt`（或拆为 ...）"的可选项表述，明确改为"创建 `src/image_types.mbt`（`Image`/`LoadError` 类型定义，不门控）+ `src/image_load_native.mbt`（`load_from_path`/`load_from_bytes` 实现，native 门控）"，与技术方案 §6.5 和 §3.1 文件布局保持一致。