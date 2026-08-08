# 计划审查报告（v2 r2）

## 审查结果
APPROVED

## 发现

- **[轻微] types 包"全目标可用"声明与验证范围不匹配**
  task_v2.md 第 12 行声明 types 包"不设 `supported_targets` 限制（全目标可用）"，但第 26-28 行验证仅要求 `moon check --target native` + `moon test --target native`，未要求 `moon check`（不限 target）或 `moon check --target wasm` 确认 types 包全目标编译通过。types 包为纯类型定义（6 个 `pub(all) struct`/`suberror` + `derive(Eq, @debug.Debug)`，无 FFI、无 C stub），native 验证通过可合理推断全目标可用，且本轮 pure 包仍 native-only、多目标落地留待后续轮次，验证范围与本轮目标一致。不影响计划可行性。

- **[轻微] "预期产出"未显式声明根包与其他子包不需修改**
  task_v2.md 第 31-35 行"预期产出"列出新建/修改/不修改的文件范围，"不修改"仅声明"core 包内其他 20+ 文件"，未显式声明根包 `src/reexport.mbt` 及 process/format/meta/util 等子包无需修改。计划第 72 行已声明"依赖 core 类型的子包均通过 `@core.Image` 等引用类型（别名透明下 re-export 保持这些引用不变）"，别名透明性已实验验证，故这些包确实无需修改。表述完整性的小缺口，不影响 Doer 执行（构建验证会捕获任何遗漏）。

### 上一轮 4 项问题修正核实

1. **[严重] re-export 机制透明性** — 已修正。task_v2.md 第 19 行明确声明已通过临时双包实验验证 `pub type T = @other.T` 别名对包内裸引用完全透明（struct 字面量构造、suberror 变体构造、模式匹配、函数签名 4 种用法均通过），第 18 行明确语法 `pub type Image = @types.Image`（与 `src/reexport.mbt` 先例一致，已核实该文件大量使用此语法且 554 测试通过），第 34 行明确"不修改 core 包内其他 20+ 文件"（已核实 core 包约 22 个 .mbt 文件，69+ 处裸引用分布已列出）。核心可行性已从"现场待定"变为"实验论证 + 先例引用"。

2. **[一般] pure 包对比测试** — 已修正。task_v2.md 第 24 行明确测试 1-6 保持现状（字段级比较 `assert_eq(pure_img.width, ffi_img.width)` 等，别名透明下 `@core.Image` 即 `@types.Image`，Int/Bytes 字段直接可比），测试 7-8 错误路径 `@core.LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed`（2 处，与主代码 `raise @types.LoadError` 一致）。

3. **[一般] pure 包 native 限制** — 已修正。task_v2.md 第 22 行明确选择保留 `supported_targets = "native"`（选项 b），显式声明"本轮 pure 包仍 native-only，多目标落地留待后续轮次——需先确认 moon.pkg 条件依赖语法以分离主代码全目标 import types 与测试 native-only import core"。与本轮"core 包类型分离（多目标基础）"目标一致——核心价值是 types 包全目标可用 + core re-export 机制验证，而非 pure 包全目标落地。

4. **[轻微] types 包 import 列表** — 已修正。task_v2.md 第 12 行明确"import 列表仅 `moonbitlang/core/debug`"，并解释 `Array[Image]`（GifAnimation.frames）用内置 Array、Int/Bytes/String 内置无需显式 import。
