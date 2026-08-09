# 检查审查报告（v2 r1）

## 审查结果
APPROVED

## 发现
- **[轻微]** do_v2.md 与 check_v2.md 对 bmp_decode.mbt 改造处数描述不一致：do_v2.md 称"4 处 `@core.*` → `@types.*`（函数签名 1 + raise 构造 3）"，check_v2.md 独立 grep 发现"实际 9 处（函数签名 1 + raise 构造 7 + struct 字面量 1）"。经我独立 grep 验证，bmp_decode.mbt 确有 9 行匹配 `@types\.`（第 8/12/16/22/32/36/40/67/83 行），do_v2.md 的"4 处"系低估。check_v2.md 已通过独立 grep 记录了实际数量，隐含纠正了 do_v2.md 的描述，但未显式标注 do_v2.md 的数量错误。此为文档描述偏差，实际代码改造完整（无 @core. 残留），不影响 PASSED 结论。
- **[轻微]** check_v2.md 检查项"pure 包 bmp_decode.mbt 改造"计数口径按行而非按引用：第 8 行函数签名 `-> @types.Image raise @types.LoadError` 实含 2 个 @types 引用，但计为 1 处。按行计 9 处、按引用计 10 处，check_v2.md 采用按行计口径，与 grep 行数一致，合理但口径未显式说明。

## 独立验证摘要
- **types 包**：`src/types/moon.pkg` 仅 import `moonbitlang/core/debug`，无 `supported_targets`，无 C stub；`src/types/image_types.mbt` 含 6 个类型定义（Image/Image16/ImageF/ImageInfo/GifAnimation/LoadError），保持 `pub(all)` + `derive(Eq, @debug.Debug)` + 文档注释 ✓
- **core 包**：`image_types.mbt` 已删除（glob 无匹配）；`moon.pkg` 增加 import types，保留 `supported_targets = "native"` + `native-stub`；`image_types_reexport.mbt` 含 6 个 `pub type X = @types.X` 声明 ✓
- **pure 包**：`moon.pkg` 增加 import types，@core 改为 `for "test"` 条件依赖，保留 `supported_targets = "native"`；`bmp_decode.mbt` 主代码无 @core 残留，9 行 @types 引用；`bmp_decode_test.mbt` 测试 7-8 错误路径 2 处 @types.LoadError，测试 5-6 保留 @core.load_from_bytes 对比验证 ✓
- **偏差先例**：`src/format/moon.pkg` 第 8 行确有 `} for "test"` 先例 ✓
- **构建验证**：`moon check --target native` 通过（no work to do，无错误）✓
- **全量测试**：`moon test --target native` 554/554 passed, 0 failed ✓

## 覆盖度评估
check_v2.md 检查项覆盖了 task_v2.md 的全部关键要求：types 包创建、core 包改造（删除+import+re-export）、pure 包改造（moon.pkg+bmp_decode.mbt+bmp_decode_test.mbt）、构建验证、全量测试验证、偏差合理性评估。检查方法可靠（文件实际读取、glob/grep 实际执行、构建和测试命令实际执行）。PASSED 结论有充分证据支撑（0 errors + 554/554 通过）。未发现遗漏的关键检查维度。
