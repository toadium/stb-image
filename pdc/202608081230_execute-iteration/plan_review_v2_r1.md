# 计划审查报告（v2 r1）

## 审查结果
REJECTED

## 发现

- **[严重] re-export 机制对 core 包内裸引用的可行性未论证，"预期产出"与实际修改范围严重不符**
  task_v2.md 计划在 core 包通过 `pub alias Image = @types.Image` 或等价机制 re-export 类型，使 core 包内代码与外部 `@core.Image` 等引用"保持不变"，并在"预期产出"中仅列出：修改 `src/core/moon.pkg`（+ import types）、删除 `src/core/image_types.mbt`、新增 core 包类型 re-export 声明。

  但实际 core 包内有 69+ 处裸引用待迁移的 6 个类型（已核实）：
  - 函数签名：`image_load_native.mbt:6/38`、`image_detect.mbt:90`、`image_resize_native.mbt:53/82/111/140`、`image_float_native.mbt:6/38`、`image_16_native.mbt:6/38`、`image_gif_native.mbt:6/73`、`image_info_native.mbt:3` 等形如 `-> Image raise LoadError` / `-> Image16` / `-> ImageF` / `-> GifAnimation` / `-> ImageInfo?`
  - 错误构造：`image_write_native.mbt`、`image_load_native.mbt`、`file_io_native.mbt:18`（`LoadError::FileIO`）、`icon_encode.mbt` 等形如 `raise LoadError::DecodeFailed(...)`
  - 模式匹配：`image_test.mbt`、`image_resize_test.mbt`、`image_info_test.mbt`、`image_float_test.mbt`、`image_gif_test.mbt`、`image_16_test.mbt`、`icon_encode_test.mbt` 形如 `catch LoadError::DecodeFailed(_)`

  删除 `image_types.mbt` 后，这些裸引用能否在 core 包自有的 `pub type Image = @types.Image` 别名下继续编译——尤其是 struct 字面量构造 `Image::{width:..., ...}`、suberror 变体构造 `LoadError::DecodeFailed(...)`、模式匹配 `catch LoadError::DecodeFailed(_)`——是整个计划可行性与工作量的分水岭：若透明别名可行，core 包内代码无需改；若不可行，core 包内 20+ 文件需改类型引用，工作量翻倍且"预期产出"完全遗漏。

  Planner 未引用项目内 `src/reexport.mbt` 已大量使用 `pub type X = @core.X` 且 554 测试通过的先例来论证机制可行性，也未在计划中区分两种情形的应对，仅以"若 alias 不可行则评估最小改动方案"带过，把核心可行性留作 Doer 现场待定。这是导致后续环节可能失败或大幅返工的缺陷。

- **[一般] pure 包跨类型对比测试可行性未独立论证，与严重问题耦合**
  task_v2.md 第 21-23 行让 pure 包主代码依赖 types、测试 `for "test"` 依赖 core，`decode_bmp_pure` 返回 `@types.Image`，`@core.load_from_bytes` 返回 `@core.Image`，对比测试（测试 5-6）跨类型。其可行性直接依赖严重问题中的 re-export 透明性（若 `@core.Image` 是 `@types.Image` 透明别名则 `assert_eq(pure_img.width, ffi_img.width)` 等字段比较可行；若不透明则需引入转换）。计划未独立论证，也未说明当前测试代码 `assert_eq(pure_img.data, ffi_img.data)`（`bmp_decode_test.mbt:95/106`）是否需改写。

- **[一般] pure 包是否移除 native 限制表述模糊，与本轮"奠定多目标基础"目标不一致**
  task_v2.md 第 21 行用"可移除"（可选语气）描述 pure 包 `supported_targets = "native"` 的去留，并给条件"若测试仍需对比验证则保留 core 依赖仅用于测试目标"。但验证仅要求 `moon check --target native` + `moon test --target native`（第 26-27 行），未要求 `moon check`（不限 target）。pure 包若移除 native 限制声称全目标可用却只 native 验证，"为 v2.0 多目标支持奠定基础"的目标未实际推进；若不移除则本轮 pure 包仍 native-only，与 T1 状态无异。本轮架构重构的核心价值（pure 包真正脱离 native）是否落地应在计划中明确，不应模糊留给 Doer。

- **[轻微] types 包 import 列表未穷尽**
  task_v2.md 第 13 行描述 types 包"仅 import 基础依赖（`moonbitlang/core/debug` 等）"，"等"字未穷尽。`derive(Eq, @debug.Debug)` 需 `moonbitlang/core/debug`，`Array[Image]`（`GifAnimation.frames`）用内置 Array 无需显式 import。建议明确列出 import 列表，避免 Doer 现场试错。

## 修改要求

1. **（严重）论证 re-export 机制透明性并据此明确 core 包修改范围**
   - 问题：计划未论证 `pub type Image = @types.Image`（或 `pub alias`）能否让 core 包内 69+ 处裸引用（struct 字面量构造 `Image::{...}`、suberror 构造 `LoadError::DecodeFailed(...)`、模式匹配 `catch LoadError::DecodeFailed(_)`、函数签名 `-> Image raise LoadError`）继续编译，也未区分透明/不透明两种情形的应对，"预期产出"遗漏 core 包内其他文件的潜在修改。
   - 为什么是问题：这是整个任务可行性与工作量的分水岭。若机制不可行，Doer 按现计划仅做"moon.pkg + 删除 image_types.mbt + re-export 声明"则构建必然失败；若可行，现计划可成立。核心决策不应留作现场待定。
   - 期望修正方向：
     a. 引用项目内 `src/reexport.mbt` 已用 `pub type X = @core.X` 且 554 测试通过的先例，明确 MoonBit 的 `pub type` 别名对 `pub(all) struct` 字段构造、`pub(all) suberror` 变体构造与模式匹配是透明传播的（或明确指出先例仅覆盖跨包引用、未覆盖包内裸引用，需另行验证）；并明确本轮采用 `pub type` 还是 `pub alias` 语法。
     b. 据此明确 core 包内其他文件是否需要修改：若透明别名可行，显式声明"core 包内 69+ 处裸引用无需修改，解析到 core 包自有别名"；若不可行，列出需修改的文件清单与改动模式（裸 `Image` → `@types.Image`、`LoadError::DecodeFailed` → `@types.LoadError::DecodeFailed` 等），并纳入"预期产出"。

2. **（一般）明确 pure 包对比测试的改写方案**
   - 问题：跨类型对比测试可行性依附于严重问题未独立论证，且未说明现有 `assert_eq(pure_img.data, ffi_img.data)` 是否需改。
   - 为什么是问题：Doer 可能误以为测试无需改，或过度改写。
   - 期望修正方向：结合修改要求 1 的结论，明确测试 5-6 是保持现状（透明别名下 `@core.Image` = `@types.Image`，`assert_eq` 直接可行）、还是改为字段级比较（已有字段比较，仅 `data` 行需确认）、还是需引入类型转换。

3. **（一般）明确 pure 包本轮是否移除 native 限制及对应验证要求**
   - 问题：pure 包 native 限制去留模糊，验证仅 native，与"奠定多目标基础"目标不一致。
   - 为什么是问题：本轮架构重构的核心价值是否落地不明确，Doer 可能选择保守路径（不移除）使本轮产出对 v2.0 多目标无实质推进。
   - 期望修正方向：二选一并明确——
     a. 移除 native 限制：pure 包 `moon.pkg` 不设 `supported_targets`，主代码 import types，测试 `for "test"` import core；验证增加 `moon check`（不限 target）确认 pure 包全目标编译通过。
     b. 暂不移除：pure 包仍 `supported_targets = "native"`，在计划中显式声明"本轮 pure 包仍 native-only，多目标落地留待后续轮次（待 core 包类型分离稳定后再解除 pure 包 native 限制）"，避免与任务目标"为多目标奠定基础"产生误导。
