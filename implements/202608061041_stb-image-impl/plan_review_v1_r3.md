# 计划审查报告（v1 r3）

## 审查结果
APPROVED

## 发现

- **[轻微]** `task_v1.md` 第 16 行 `moon.mod` 的 `name` 占位表述"`<user>/stb-image`（user 可暂用 `stb-image` 占位）"会得到 `stb-image/stb-image`，语义略显怪异。此为发布前再定的占位值，不影响本任务正确性，实现者可选用更自然的占位（如 `guest/stb-image`）。

- **[轻微]** `task_v1.md` 第 18 行 `license` 给出 `Public Domain` 选项，但 SPDX 标识符列表中 `Public Domain` 非标准标识符（public domain 通常用 `Unlicense` 表示）。task 同时给出 `MIT` 选项，实现者可选用合规 SPDX 标识符，不影响本任务正确性。

- **[轻微]** `task_v1.md` 第 46 行 `prepare.py` 的 `--include-write` 参数"仅预留参数骨架，不实际下载 write 头文件"，但带参数时的具体行为（no-op / 打印提示 / argparse 仅声明）未明确。实现者可合理推断为 argparse 接受参数但跳过下载，不影响本任务正确性。

## 核实项

1. **`supported_targets = "native"` 新 DSL 语法**：经 `moonbit_wiki/toolchain/package-management.md:60` 与 `tutorial.md:107` 确认，`supported_targets = "native"` 为 `moon.pkg`/`moon.mod` 新 DSL 合法语法，取值可为单字符串。task_v1.md 语法声明正确。

2. **空包 `moon check` 可行性**：本任务完成后 `src/` 下仅有 `stb_image.h`（C 头文件）与 `moon.pkg`，无任何 `.mbt` 文件。经实测（临时项目 `moon.mod` + `src/moon.pkg` 仅声明 `supported_targets = "native"` + `src/stb_image.h`），`moon check` 返回 `Finished. moon: no work to do`，`moon info` 正常。渐进式声明策略下 `moon check`/`moon info` 均通过，验收标准可达。

3. **`preferred_target = "native"` 新 DSL 语法**：经 `maria/moon.mod:22` 确认为合法新 DSL 语法（下划线，非旧 JSON 连字符）。

4. **`options("native-stub": [...])` 语法**：经 `maria/internal/tty/moon.pkg:7-8` 确认为合法新 DSL 语法。本任务不声明 `options` 块，后续任务渐进追加，符合 MoonBit moon.pkg DSL 要求（`native-stub` 与 `targets` 在同一 `options` 块内）。

5. **plan.md 路线图与 task_v1.md 一致性**：R2/R3/R4 路线图的文件布局、`moon.pkg` 渐进追加策略、`moon.mod` readme 追加策略与 task_v1.md 第 29-34 行的后续任务渐进追加清单一致。R3 明确拆分为 `image_types.mbt`（不门控）+ `image_load_native.mbt`（native 门控），与技术方案 §6.5 一致。R4 包含 `scripts/run-asan.py` 创建，路线图完整。

6. **需求覆盖**：task_v1.md + plan.md 路线图覆盖需求文档 MVP 范围（`load_from_path`/`load_from_bytes` + `Image` + `LoadError` + 9 种格式 + 6-10 张测试图片 + ASan + SKILL.md + README）。本任务（R1 Vendoring 层 + 项目骨架）为后续 R2/R3/R4 的底层依赖，选择理由充分。